#!/usr/bin/env lua
-- fzfs/sources.lua - Streaming command builders for fzf sources
package.cpath = package.cpath .. ';' .. os.getenv('HOME') .. '/.luarocks/lib/lua/5.4/?.so'
package.path = package.path .. ';' .. os.getenv('HOME') .. '/.dotfiles/scripts/fzfs/?.lua'
package.path = package.path .. ';' .. os.getenv('HOME') .. '/.luarocks/share/lua/5.4/?.lua'

local core = require('core')
local path_utils = require('path_utils')
local shell_utils = require('shell_utils')
local sh

local sh_available = pcall(function()
  sh = require('sh')
end)

core.init()
core.detect_tools()

local M = {}

local function stream_command(cmd)
  return coroutine.wrap(function()
    local pipe = io.popen(cmd .. ' 2>/dev/null')
    if not pipe then return end
    for line in pipe:lines() do
      coroutine.yield(line)
    end
    pipe:close()
  end)
end


local function build_fd_command(base, opts)
  local path = path_utils.expand_path(base or '.')
  local tools = core.get_tools()
  local excludes = core.get_excludes()

  local args = {opts or ''}
  if excludes and #excludes > 0 then
    for _, ex in ipairs(excludes) do
      table.insert(args, '--exclude=' .. shell_utils.shell_quote(ex))
    end
  end

  if path ~= '.' and path ~= './' then
    table.insert(args, '.')
    table.insert(args, shell_utils.shell_quote(path))
  else
    table.insert(args, '--strip-cwd-prefix')
  end

  local cmd_str = 'fd ' .. table.concat(args, ' ')
  return cmd_str
end


local function build_find_command(base, opts)
  local path = path_utils.expand_path(base or '.')
  local tools = core.get_tools()
  local excludes = core.get_excludes()

  local args = {}
  if excludes and #excludes > 0 then
    for _, ex in ipairs(excludes) do
      table.insert(args, '-not -path ' .. shell_utils.shell_quote('*/' .. ex .. '/*'))
      table.insert(args, '-not -path ' .. shell_utils.shell_quote('*/' .. ex))
    end
  end

  local cmd_str = string.format('find %s %s 2>/dev/null', shell_utils.shell_quote(path), opts or '')
  if #args > 0 then
    cmd_str = string.format('find %s %s %s 2>/dev/null', shell_utils.shell_quote(path), table.concat(args, ' '), opts or '')
  end
  return cmd_str
end


function M.files(base, show_hidden)
  return coroutine.wrap(function()
    local tools = core.get_tools()
    local hidden = tonumber(show_hidden or core.get('show_hidden') or 1)
    local cmd

    if tools.has_fd then
      local opts = '--follow --color=never --type f'
      if hidden == 1 then opts = opts .. ' --hidden' end
      cmd = build_fd_command(base, opts)
    else
      local opts = '-type f'
      if hidden == 1 then opts = opts .. ' -name .*' end
      cmd = build_find_command(base, opts)
    end

    for line in stream_command(cmd) do
      coroutine.yield(line)
    end
  end)
end


function M.dirs(base, show_hidden)
  return coroutine.wrap(function()
    local tools = core.get_tools()
    local hidden = tonumber(show_hidden or core.get('show_hidden') or 1)
    local cmd

    if tools.has_fd then
      local opts = '--follow --color=never --type d'
      if hidden == 1 then opts = opts .. ' --hidden' end
      cmd = build_fd_command(base, opts)
    else
      local opts = '-type d'
      if hidden == 1 then opts = opts .. ' -name .*' end
      cmd = build_find_command(base, opts)
    end

    for line in stream_command(cmd) do
      coroutine.yield(line)
    end
  end)
end


function M.all(base, show_hidden)
  return coroutine.wrap(function()
    local tools = core.get_tools()
    local hidden = tonumber(show_hidden or core.get('show_hidden') or 1)
    local cmd

    if tools.has_fd then
      local opts = '--follow --color=never'
      if hidden == 1 then opts = opts .. ' --hidden' end
      cmd = build_fd_command(base, opts)
    else
      local opts = ''
      if hidden == 1 then opts = opts .. ' -name .*' end
      cmd = build_find_command(base, opts)
    end

    for line in stream_command(cmd) do
      coroutine.yield(line)
    end
  end)
end


function M.recent(base, show_hidden)
  return coroutine.wrap(function()
    local tools = core.get_tools()
    local hidden = tonumber(show_hidden or core.get('show_hidden') or 1)
    local cmd

    if tools.has_fd then
      local opts = '--follow --color=never --type f --changed-within 24h'
      if hidden == 1 then opts = opts .. ' --hidden' end
      cmd = build_fd_command(base, opts)
    else
      local opts = '-type f -mtime -1'
      if hidden == 1 then opts = opts .. ' -name .*' end
      cmd = build_find_command(base, opts)
    end

    for line in stream_command(cmd) do
      coroutine.yield(line)
    end
  end)
end


function M.git_tracked()
  return stream_command('git ls-files')
end


function M.git_all()
  return stream_command('git ls-files -co --exclude-standard')
end


function M.git_dirs()
  return stream_command('git ls-files -co --exclude-standard | awk -F/ \'BEGIN {OFS=\"/\"} NF>1 {NF--; dir=$0; if (!seen[dir]++) { print dir \"/\"; fflush() }}\'')
end


function M.git_status()
  return stream_command('git status --short')
end


function M.git_staged()
  return stream_command('git diff --name-only --cached')
end


function M.commits(limit)
  local limit_opt = limit and string.format('-n %d', limit) or ''
  local cmd = string.format('git log %s --color=always --format="%%C(yellow)%%h%%Creset %%C(magenta)%%ad%%Creset %%C(cyan)%%an%%Creset %%s" --date=short', limit_opt)
  return stream_command(cmd)
end


function M.branches(remote)
  local fmt = '%(refname:short)'
  local cmd
  local tools = core.get_tools()

  if remote then
    cmd = string.format('git for-each-ref --format="%s" refs/remotes | %s -v "/HEAD$\\\\"', fmt, tools.grep)
  else
    cmd = string.format('git for-each-ref --format="%s" refs/heads', fmt)
  end
  return stream_command(cmd)
end


function M.projects(roots)
  return coroutine.wrap(function()
    local root_list = {}
    if type(roots) == 'string' then
      for part in roots:gmatch('%S+') do
        table.insert(root_list, part)
      end
    elseif type(roots) == 'table' then
      root_list = roots
    else
      root_list = {core.get('project_roots')}
    end

    local tools = core.get_tools()
    local seen = {}

    for _, root in ipairs(root_list) do
      root = path_utils.expand_path(root)
      if path_utils.is_dir(root) then
        local cmd
        if tools.has_fd then
          cmd = string.format('fd --hidden --no-ignore --type d --glob .git %s -x dirname', shell_utils.shell_quote(root))
        else
          cmd = string.format('find %s -type d -name .git -exec dirname {} \\;', shell_utils.shell_quote(root))
        end

        for line in stream_command(cmd) do
          if not seen[line] then
            seen[line] = true
            coroutine.yield(line)
          end
        end
      end
    end
  end)
end


function M.build_fd_command(base, opts)
  return build_fd_command(base, opts)
end


function M.build_find_command(base, opts)
  return build_find_command(base, opts)
end


function M.stream_command(cmd)
  return stream_command(cmd)
end


local function get_source_cmd(mode, base)
  local tools = core.get_tools()
  local friendly = core.get('friendly') or 0
  local relative = core.get('relative') or 0
  local expanded_base = path_utils.expand_path(base or '.')
  local builder = {
    files = function()
      local opts = tools.has_fd and '--follow --color=never --type f' or '-type f'
      local hidden = core.get('show_hidden') and (tools.has_fd and ' --hidden' or ' -name .*') or ''
      local base_cmd = tools.has_fd and build_fd_command(base, opts .. hidden) or build_find_command(base, opts .. hidden)
      if relative == 1 and expanded_base ~= '.' then
        local escaped_base = expanded_base:gsub('([/.[\\*?^$])', '\\%1')
        base_cmd = base_cmd .. ' | sed "s|^' .. escaped_base .. '/||"'
      end
      return base_cmd
    end,
    dirs = function()
      local opts = tools.has_fd and '--follow --color=never --type d' or '-type d'
      local hidden = core.get('show_hidden') and (tools.has_fd and ' --hidden' or ' -name .*') or ''
      local base_cmd = tools.has_fd and build_fd_command(base, opts .. hidden) or build_find_command(base, opts .. hidden)
      if relative == 1 and expanded_base ~= '.' then
        local escaped_base = expanded_base:gsub('([/.[\\*?^$])', '\\%1')
        base_cmd = base_cmd .. ' | sed "s|^' .. escaped_base .. '/||"'
      end
      return base_cmd
    end,
    all = function()
      local opts = tools.has_fd and '--follow --color=never' or ''
      local hidden = core.get('show_hidden') and (tools.has_fd and ' --hidden' or ' -name .*') or ''
      local base_cmd = tools.has_fd and build_fd_command(base, opts .. hidden) or build_find_command(base, opts .. hidden)
      if relative == 1 and expanded_base ~= '.' then
        local escaped_base = expanded_base:gsub('([/.[\\*?^$])', '\\%1')
        base_cmd = base_cmd .. ' | sed "s|^' .. escaped_base .. '/||"'
      end
      return base_cmd
    end,
    recent = function()
      local opts = tools.has_fd and '--follow --color=never --type f --changed-within 24h' or '-type f -mtime -1'
      local hidden = core.get('show_hidden') and (tools.has_fd and ' --hidden' or ' -name .*') or ''
      local base_cmd = tools.has_fd and build_fd_command(base, opts .. hidden) or build_find_command(base, opts .. hidden)
      if relative == 1 and expanded_base ~= '.' then
        local escaped_base = expanded_base:gsub('([/.[\\*?^$])', '\\%1')
        base_cmd = base_cmd .. ' | sed "s|^' .. escaped_base .. '/||"'
      end
      return base_cmd
    end,
    search = function()
      local path = path_utils.expand_path(base or '.')
      local search_path = shell_utils.shell_quote(path)
      if tools.grep == 'rg' then
        return string.format('rg -uu -S --no-heading --column --line-number --color=always -- {q} %s', search_path)
      else
        return string.format('grep -rIn --color=always {q} %s', search_path)
      end
    end,
    git_all = function()
      return 'git ls-files -co --exclude-standard'
    end,
    git_tracked = function()
      return 'git ls-files'
    end,
    git_dirs = function()
      return "git ls-files -co --exclude-standard | awk -F/ 'BEGIN {OFS=\"/\"} NF>1 {NF--; dir=$0; if (!seen[dir]++) { print dir \"/\"; fflush() }}'"
    end,
    git_status = function()
      return 'git diff --name-only --diff-filter=d'
    end,
    git_staged = function()
      return 'git diff --cached --name-only --diff-filter=d'
    end,
    commits = function()
      return 'git log --oneline --all --graph --decorate -20'
    end,
    branch = function()
      return 'git branch -a --color=always'
    end,
    projects = function()
      local roots = path_utils.expand_path(base or core.get('project_roots'))
      local root_list = {}
      for part in roots:gmatch('%S+') do
        table.insert(root_list, part)
      end
      local find_cmds = {}
      for _, root in ipairs(root_list) do
        root = path_utils.expand_path(root)
        if path_utils.is_dir(root) then
          if tools.has_fd then
            table.insert(find_cmds, string.format('fd --hidden --no-ignore --type d --glob .git %s -x dirname', shell_utils.shell_quote(root)))
          else
            table.insert(find_cmds, string.format('find %s -type d -name .git -exec dirname {} \\;', shell_utils.shell_quote(root)))
          end
        end
      end
      local result = #find_cmds > 0 and table.concat(find_cmds, ' ; ') or ''
      if relative == 1 and expanded_base ~= '.' and result ~= '' then
        local escaped_base = expanded_base:gsub('([/.[\\*?^$])', '\\%1')
        result = result .. ' | sed "s|^' .. escaped_base .. '/||"'
      end
      return result
    end
  }
  return builder[mode] and builder[mode]() or nil
end


local function get_preview_cmd(mode)
  local preview_script = os.getenv('HOME') .. '/.dotfiles/scripts/fzfs/preview.lua'
  if mode == 'commits' then
    return 'lua ' .. preview_script .. ' commit {}'
  elseif mode == 'branch' then
    return 'lua ' .. preview_script .. ' branch {}'
  else
    return 'lua ' .. preview_script .. ' file {}'
  end
end


function M.get_source_cmd(mode, base)
  core.init()
  return get_source_cmd(mode, base)
end


function M.get_preview_cmd(mode)
  return get_preview_cmd(mode)
end


function M.self_test()
  print('FZFS Sources Module Test')
  print('=========================')
  core.init()
  core.detect_tools()
  local t = core.get_tools()
  print('Tools:')
  print('  Has fd: ' .. tostring(t.has_fd))
  print('  Has luash/sh: ' .. tostring(sh_available))
  print('')
  print('Testing file source:')
  local file_count = 0
  for _ in M.files('.') do
    file_count = file_count + 1
    if file_count >= 5 then break end
  end
  print('  Generated ' .. file_count .. ' files (sample)')
  print('')
  print('Testing dir source:')
  local dir_count = 0
  for _ in M.dirs('.') do
    dir_count = dir_count + 1
    if dir_count >= 5 then break end
  end
  print('  Generated ' .. dir_count .. ' directories (sample)')
  print('')
  print('Testing git sources:')
  local is_git = shell_utils.exec_cmd('git rev-parse --git-dir 2>/dev/null')
  if is_git and is_git:match('%S') then
    local tracked_count = 0
    for _ in M.git_tracked() do
      tracked_count = tracked_count + 1
      if tracked_count >= 5 then break end
    end
    print('  Generated ' .. tracked_count .. ' tracked files (sample)')

    local branch_count = 0
    for _ in M.branches() do
      branch_count = branch_count + 1
      if branch_count >= 5 then break end
    end
    print('  Generated ' .. branch_count .. ' branches (sample)')
  else
    print('  Skipped (not in git repo)')
  end
  print('')
  print('✓ Sources module test passed')
end

if arg and arg[1] == '--self-test' then
  M.self_test()
  os.exit(0)
end

return M
