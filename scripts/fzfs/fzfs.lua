#!/usr/bin/env lua
-- fzfs/fzfs.lua - Main entry point for fzfs

package.cpath = package.cpath .. ';' .. os.getenv('HOME') .. '/.luarocks/lib/lua/5.4/?.so'
package.path = package.path .. ';' .. os.getenv('HOME') .. '/.dotfiles/scripts/fzfs/?.lua'

local core = require('core')
local path_utils = require('path_utils')
local shell_utils = require('shell_utils')
local string_utils = require('string_utils')
local ui = require('ui')
local sources = require('sources')

local function parse_args(args)
  local has_multi_char_short = false
  local multi_char_patterns = {'-gf', '-gd', '-gs', '-gst', '-mr', '-gb', '-gc', '-gp'}
  
  for _, arg_val in ipairs(args) do
    for _, pattern in ipairs(multi_char_patterns) do
      if arg_val == pattern then
        has_multi_char_short = true
        break
      end
    end
    if has_multi_char_short then break end
  end
  
  if not has_multi_char_short then
    local ok, lapp = pcall(require, 'pl.lapp')
    
    if ok then
      local cli = lapp [[
        Fuzzy File System - A fuzzy finder interface
        Usage: fzfs [MODE] [PATH] [-e]
        
        Modes:
          -f, --files        Files only
          -d, --dirs         Directories
          -a, --all          Files and directories (default)
          -s, --search       Live file content search
          -g, --git          Git all (tracked + untracked)
          -r, --recent       Recent files
          -b, --branch       Git branches
          -c, --commits      Git commits
          -p, --projects     Git projects
          --check            Run diagnostics
          --doctor           Run diagnostics (alias for --check)
          -h, --help         Show help
        
        Options:
          -e, --edit         Edit mode (default: false)
          PATH               Optional path (default: .)
      ]]
      
      local mode = 'all'
      if cli.files then mode = 'files'
      elseif cli.dirs then mode = 'dirs'
      elseif cli.search then mode = 'search'
      elseif cli.git then mode = 'git_all'
      elseif cli.recent then mode = 'recent'
      elseif cli.branch then mode = 'branch'
      elseif cli.commits then mode = 'commits'
      elseif cli.projects then mode = 'projects'
      elseif cli.check then mode = 'check'
      elseif cli.doctor then mode = 'check'
      elseif cli.help then mode = 'help'
      end
      
      local base = cli[1] or '.'
      local edit = cli.edit and 1 or 0
      
      return mode, base, edit
    end
  end
  
  local mode = 'all'
  local base = '.'
  local edit = 0

  local arg_to_mode = {
    ['-f'] = 'files',
    ['--files'] = 'files',
    ['-d'] = 'dirs',
    ['--dirs'] = 'dirs',
    ['-a'] = 'all',
    ['--all'] = 'all',
    ['-s'] = 'search',
    ['--search'] = 'search',
    ['-g'] = 'git_all',
    ['--git'] = 'git_all',
    ['-gf'] = 'git_tracked',
    ['--git-files'] = 'git_tracked',
    ['-gd'] = 'git_dirs',
    ['--git-dirs'] = 'git_dirs',
    ['-gs'] = 'git_status',
    ['--status'] = 'git_status',
    ['-gst'] = 'git_staged',
    ['--staged'] = 'git_staged',
    ['-mr'] = 'recent',
    ['--recent'] = 'recent',
    ['-gb'] = 'branch',
    ['--branch'] = 'branch',
    ['-gc'] = 'commits',
    ['--commits'] = 'commits',
    ['-gp'] = 'projects',
    ['--projects'] = 'projects',
    ['--check'] = 'check',
    ['--doctor'] = 'check',
    ['-h'] = 'help',
    ['--help'] = 'help',
  }

  for i = 1, #args do
    local arg_val = args[i]

    if arg_to_mode[arg_val] then
      mode = arg_to_mode[arg_val]
    elseif arg_val == '-e' or arg_val == '--edit' then
      edit = 1
    elseif arg_val:sub(1, 1) ~= '-' then
      base = arg_val
    end
  end

  return mode, base, edit
end


local function show_help()
  local c = core.colors
  print(c.bold_cyan .. '███████ ███████ ███████ ███████' .. c.reset)
  print(c.cyan .. '██         ███  ██      ██     ' .. c.reset)
  print(c.bold_cyan .. '█████     ███   █████   ███████' .. c.reset)
  print(c.cyan .. '██       ███    ██           ██ ' .. c.reset)
  print(c.bold_cyan .. '██      ███████ ██      ███████' .. c.reset)
  print('')
  print(c.bold .. '        fuzzy finder snacks' .. c.reset)
  print('')
  print('Usage: fzfs [MODE] [PATH]')
  print('')
  print('MODES:')
  print('  -a,  --all        Files and directories (default)')
  print('  -f,  --files      Files only')
  print('  -d,  --dirs       Directories')
  print('  -s,  --search      Live file content search')
  print('  -g,  --git        Git all (tracked + untracked)')
  print('  -gf, --git-files  Git tracked files')
  print('  -gs, --status    Git status')
  print('  -gst, --staged   Git staged files')
  print('  -gd, --git-dirs  Git directories')
  print('  -gb, --branch    Git branches')
  print('  -gc, --commits   Git commits')
  print('  -gp, --projects  Git projects')
  print('')
  print('KEYS:')
  print('  Enter             Select')
  print('  ctrl-e            Edit file(s)')
  print('  ctrl-o            cd to directory')
  print('  ctrl-p            Toggle preview')
  print('  ctrl-y            Copy path')
  print('  ctrl-h            Toggle hidden files')
  print('  alt-h             Toggle friendly mode')
  print('')
  print('ENVIRONMENT:')
  print('  FZFS_SHOW_HIDDEN  Show hidden files (default: 1)')
  print('  FZFS_RELATIVE     Use relative paths (default: 0)')
  print('  FZFS_FRIENDLY     Friendly output mode (default: 1)')
end


local function show_doctor()
  core.init()
  local tools = core.detect_tools()

  local c = core.colors
  print(c.bold_cyan .. 'FZFS Doctor - Diagnostics' .. c.reset)
  print('  Script: ' .. os.getenv('HOME') .. '/.dotfiles/scripts/fzfs/fzfs.lua')
  print('')
  print(c.bold .. 'Core Dependencies:' .. c.reset)
  print('    luafilesystem: ' .. c.green .. '✓ (required)' .. c.reset)
  print('')
  print(c.bold .. 'Optional Lua Libraries:' .. c.reset)
  print('    penlight: ' .. (tools.has_penlight and c.green .. '✓' .. c.reset or c.yellow .. '✗' .. c.reset))
  print('    luash: ' .. (tools.has_luash and c.green .. '✓' .. c.reset or c.yellow .. '✗' .. c.reset))
  print('')
  print(c.bold .. 'External Tools:' .. c.reset)
  print('    File Finder: ' .. (tools.has_fd and c.green .. 'fd' .. c.reset or c.yellow .. 'find' .. c.reset))
  print('    Content Search: ' .. (tools.grep == 'rg' and c.green .. 'rg' .. c.reset or c.yellow .. 'grep' .. c.reset))
  print('    Directory Listing: ' .. tools.ls)
  print('    File Preview: ' .. tools.cat)
  print('    Git Diff Viewer: ' .. (tools.has_delta and c.green .. 'delta' .. c.reset or c.yellow .. 'cat' .. c.reset))
  print('')
  print(c.bold .. 'Configuration:' .. c.reset)
  print('    FZF binary: ' .. core.get('bin'))
  print('    Project roots: ' .. core.get('project_roots'))
  print('    Cache dir: ' .. core.get('cache_dir'))
  print('    Show hidden: ' .. tostring(core.get('show_hidden')))
  print('    Relative paths: ' .. tostring(core.get('relative')))
  print('    Friendly mode: ' .. tostring(core.get('friendly')))
  print('')
  print(c.bold .. 'Excluded Patterns:' .. c.reset)
  local excludes = core.get_excludes()
  print('    ' .. #excludes .. ' items: ' .. table.concat(excludes, ', '))
end


local function run_mode(mode, base, edit)
  core.init()
  core.detect_tools()

  local source_cmd = sources.get_source_cmd(mode, base)
  local preview_cmd = sources.get_preview_cmd(mode)

  local result = ui.run_fzf(source_cmd, {
    mode = mode,
    base = base,
    preview_cmd = preview_cmd,
    preview_window = core.get('opts_preview'),
    binds = ui.get_bindings(source_cmd, mode, core.get('friendly')),
    expect_key = core.key_bindings.cd,
    multi = true,
    disabled = mode == 'search',
  })

  return result
end

local args = arg or {}
local mode, base, edit = parse_args(args)

if mode == 'help' then
  show_help()
  os.exit(0)
elseif mode == 'check' then
  show_doctor()
  os.exit(0)
end

local result = run_mode(mode, base, edit)

if result then
  local lines = {}
  for line in result:gmatch('[^\r\n]+') do
    table.insert(lines, line)
  end

  if #lines == 0 then
    os.exit(0)
  end

  local first_line = lines[1]
  
  local is_help_preview = false
  for i = 1, #lines do
    if lines[i]:match('^fzfs:.*Enter%(') or lines[i]:match('^KEYS:') or lines[i]:match('^ENVIRONMENT:') then
      is_help_preview = true
      break
    end
  end
  
  if is_help_preview then
    os.exit(0)
  end
  
  if first_line == core.key_bindings.cd then
    if #lines > 1 then
      local target = lines[2]
      if path_utils.is_dir(target) then
        os.execute('cd ' .. shell_utils.shell_quote(target))
        return
      end
    end
  else
    for i = 1, #lines do
      print(lines[i])
    end
  end
end
