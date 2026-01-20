#!/usr/bin/env lua
-- fzfs/preview/git.lua - Git commit and branch preview
package.cpath = package.cpath .. ';' .. os.getenv('HOME') .. '/.luarocks/lib/lua/5.4/?.so'
package.path = package.path .. ';' .. os.getenv('HOME') .. '/.dotfiles/scripts/fzfs/?.lua'
local core = require('core')
local shell_utils = require('shell_utils')
local M = {}

function M.preview_commit(hash)
  local h = hash:match('^(%w+)') or hash
  print(core.colors.bold_cyan .. 'Commit:' .. core.colors.reset .. ' ' .. h)
  local diff_tool = 'cat'
  if core.get_tools().has_delta then
    diff_tool = 'delta --width ' .. (tonumber(os.getenv('COLUMNS') or 80))
  elseif core.get_tools().cat == 'bat' then
    diff_tool = 'bat -pl diff'
  end
  os.execute('git log -1 --color=always --date=short --format="%C(yellow)%h%Creset %C(magenta)%ad%Creset %C(cyan)%an%Creset%n%n%C(auto)%s%Creset%n" ' .. h)
  print(core.colors.bold_yellow .. 'Changes:' .. core.colors.reset)
  os.execute('git show --color=always --stat --patch ' .. h .. ' | ' .. diff_tool .. ' | head -n 150')
end


function M.preview_branch(ref)
  local r = ref:match('^(%w+)') or ref
  print(core.colors.bold_cyan .. 'Branch:' .. core.colors.reset .. ' ' .. r)
  local base = 'main'
  local master_check = shell_utils.exec_cmd('git show-ref --verify --quiet refs/heads/master 2>/dev/null')
  if master_check then base = 'master' end
  local ab = shell_utils.exec_cmd('git rev-list --left-right --count ' .. base .. '...' .. r .. ' 2>/dev/null')
  if ab and ab:match('%d') then
    local ahead, behind = ab:match('(%d+)%s+(%d+)')
    print(core.colors.bold .. 'Diff vs ' .. base .. ':' .. core.colors.reset .. ' Ahead ' .. (ahead or 0) .. ', Behind ' .. (behind or 0))
  end
  print('')
  print(core.colors.bold_yellow .. 'Branch Graph:' .. core.colors.reset)
  os.execute('git log --oneline --abbrev-commit --graph --decorate --color ' .. base .. ' ' .. r .. ' -20 2>/dev/null | cut -c1-120')
  print('')
  print(core.colors.bold_yellow .. 'Latest Commit:' .. core.colors.reset)
  os.execute('git log -1 --color=always --date=short --format="%C(yellow)%h%Creset %C(magenta)%ad%Creset %C(cyan)%an%Creset %s" ' .. r)
  print('')
  print(core.colors.bold_yellow .. 'Changes Overview:' .. core.colors.reset)
  os.execute('git diff --stat --color=always ' .. base .. '...' .. r .. ' 2>/dev/null | head -n 10')
end

return M
