#!/usr/bin/env lua
-- fzfs/preview/handler.lua - Preview dispatcher
package.cpath = package.cpath .. ';' .. os.getenv('HOME') .. '/.luarocks/lib/lua/5.4/?.so'
package.path = package.path .. ';' .. os.getenv('HOME') .. '/.dotfiles/scripts/fzfs/?.lua'
local M = {}

function M.show_help(friendly)
  local core = require('core')
  local c = core.colors
  
  if friendly then
    print(c.bold .. 'FZFS Keyboard Bindings' .. c.reset)
    print('')
    print(c.bold .. 'Navigation:' .. c.reset)
    print('  ' .. core.key_bindings.preview .. '  - Toggle preview window')
    print('  alt-up      - Scroll preview up')
    print('  alt-down    - Scroll preview down')
    print('')
    print(c.bold .. 'Actions:' .. c.reset)
    print('  ' .. core.key_bindings.edit .. '  - Edit selected file in $EDITOR')
    print('  ' .. core.key_bindings.cd .. '   - Change directory to selection')
    print('  ' .. core.key_bindings.yank .. '  - Copy selection to clipboard')
    print('  ' .. core.key_bindings.hidden .. '  - Toggle hidden files')
    print('')
    print(c.bold .. 'Other:' .. c.reset)
    print('  ctrl-r       - Reload the source')
    print('  ?            - Show this help')
    print('')
    print(c.bold .. 'Examples:' .. c.reset)
    print('  Press ' .. c.cyan .. 'ctrl-e' .. c.reset .. ' to quickly edit the selected file')
    print('  Use ' .. c.cyan .. 'ctrl-p' .. c.reset .. ' to toggle the preview pane on/off')
  else
    print(c.bold .. 'FZFS Key Reference' .. c.reset)
    print('')
    print(core.key_bindings.edit .. '  Edit  |  ' .. core.key_bindings.cd .. '   Cd    |  ' .. core.key_bindings.preview .. '  Preview')
    print(core.key_bindings.yank .. '  Yank  |  ' .. core.key_bindings.hidden .. '  Hidden |  ?   Help')
    print('ctrl-r Reload |  alt-up/down Scroll')
  end
end

function M.preview(preview_type, path)
  local core = require('core')
  
  if path:sub(1, 1) == '?' or path:sub(1, 5) == 'help:' then
    local friendly = tonumber(os.getenv('FZFS_FRIENDLY_MODE') or 1) == 1
    M.show_help(friendly)
    return
  end
  
  local file_preview = require('preview.file')
  local git_preview = require('preview.git')
  if preview_type == 'file' or preview_type == 'dir' then
    file_preview.preview(path)
  elseif preview_type == 'commit' then
    git_preview.preview_commit(path)
  elseif preview_type == 'branch' then
    git_preview.preview_branch(path)
  else
    io.stderr:write('Unknown preview type: ' .. preview_type .. '\n')
  end
end

return M
