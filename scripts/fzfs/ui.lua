#!/usr/bin/env lua
-- fzfs/ui.lua - FZF integration and bindings
package.cpath = package.cpath .. ';' .. os.getenv('HOME') .. '/.luarocks/lib/lua/5.4/?.so'
package.path = package.path .. ';' .. os.getenv('HOME') .. '/.dotfiles/scripts/fzfs/?.lua'
local core = require('core')
local shell_utils = require('shell_utils')
local M = {}

function M.get_help_text(friendly_mode)
  if friendly_mode then
    return [[Key Bindings:
  Enter     - Select and exit
  C-e       - Edit file
  C-o       - Change directory
  C-p       - Toggle preview
  C-r       - Reload
  C-y       - Copy to clipboard
  C-h       - Toggle hidden files
  ?         - Show this help
  Alt-Up    - Preview scroll up
  Alt-Down  - Preview scroll down
  PgUp/PgDn - Preview page up/down
  C-u/C-d   - Preview half page up/down]]
  else
    return [[Enter(Select) C-e(Edit) C-o(Cd) C-p(Preview) C-r(Reload) C-y(Copy) C-h(Hidden) ?(Help) Alt-Up/Down(Scroll) PgUp/PgDn(Page) C-u/C-d(Half-Page)]]
  end
end


function M.get_header(friendly_mode, relative_mode, mode_name, base_path, show_hidden, has_preview)
  local c = core.colors
  local friendly_ind = friendly_mode and c.green .. '[F]' .. c.reset or ''
  local relative_ind = relative_mode and c.green .. '[R]' .. c.reset or ''
  local mode_display = mode_name or 'browse'
  local hidden_display = show_hidden and 'All' or 'Vis'
  local preview_display = has_preview and 'ON' or 'OFF'
  local path_display = base_path or '.'
  
  if friendly_mode then
    return string.format('fzfs: %s%s Mode: %s | Path: %s | Hidden: %s | Preview: %s | ? for help',
      friendly_ind, relative_ind, mode_display, path_display, hidden_display, preview_display)
  else
    return string.format('%s%s|%s|%s|%s|%s|%s|?',
      friendly_ind, relative_ind, mode_display, path_display, hidden_display, preview_display)
  end
end

function M.build_fzf_command(source_cmd, options)
  core.init()
  options = options or {}
  local friendly_mode = core.get('friendly') ~= 0
  local relative_mode = core.get('relative') ~= 0
  local show_hidden = core.get('show_hidden') ~= 0
  local fzf_opts = {
    core.get('bin'),
    core.get('opts_ui'),
    '--ansi',
    '--no-sort',
    '--header ' .. shell_utils.shell_quote(M.get_header(friendly_mode, relative_mode, options.mode, options.base, show_hidden, options.preview_cmd ~= nil)),
  }
  if options.disabled then
    table.insert(fzf_opts, '--disabled')
  end
  if options.preview_cmd and options.preview_cmd ~= '' then
    table.insert(fzf_opts, '--preview ' .. shell_utils.shell_quote(options.preview_cmd))
  end
  if options.preview_window and options.preview_window ~= '' then
    table.insert(fzf_opts, '--preview-window ' .. shell_utils.shell_quote(options.preview_window))
  end
  if options.binds and options.binds ~= '' then
    table.insert(fzf_opts, '--bind ' .. shell_utils.shell_quote(options.binds))
  end
  if options.expect_key and options.expect_key ~= '' then
    table.insert(fzf_opts, '--expect=' .. options.expect_key)
  end
  if options.multi then
    table.insert(fzf_opts, '--multi')
  end
  return table.concat(fzf_opts, ' ')
end


function M.run_fzf(source_cmd, options)
  local fzf_cmd = M.build_fzf_command(source_cmd, options)
  local full_cmd
  if options.disabled then
    full_cmd = ': | ' .. fzf_cmd
  else
    full_cmd = source_cmd .. ' | ' .. fzf_cmd
  end
  return shell_utils.exec_cmd(full_cmd)
end


function M.get_preview_script_path()
  return os.getenv('HOME') .. '/.dotfiles/scripts/fzfs/preview.lua'
end


function M.get_bindings(source_cmd, mode, friendly_mode)
  local tools = core.get_tools()
  
  local clipboard_cmd
  if tools.has_pbcopy then
    clipboard_cmd = 'pbcopy'
  elseif tools.has_xclip then
    clipboard_cmd = 'xclip -selection clipboard'
  elseif tools.has_xsel then
    clipboard_cmd = 'xsel --clipboard --input'
  else
    clipboard_cmd = 'true'
  end
  
  local safe_source = source_cmd:gsub("'", "'\\''")
  local help_text = M.get_help_text(friendly_mode)
  local help_text_escaped = help_text:gsub("'", "'\\''"):gsub('\n', '\\n')
  
  local binds = {
    'ctrl-y:execute-silent(echo {} | ' .. clipboard_cmd .. ')',
    'ctrl-p:toggle-preview',
    'ctrl-r:reload(' .. safe_source .. ')',
    'ctrl-h:reload(FZFS_SHOW_HIDDEN=$((1-${FZFS_SHOW_HIDDEN:-1})) && ' .. safe_source .. ')+change-prompt(${FZFS_SHOW_HIDDEN:-1}> )',
    'alt-h:reload(FZFS_FRIENDLY=$((1-${FZFS_FRIENDLY:-0})) && ' .. safe_source .. ')',
    'alt-up:preview-up',
    'alt-down:preview-down',
    'pgup:preview-page-up',
    'pgdn:preview-page-down',
    'ctrl-u:preview-half-page-up',
    'ctrl-d:preview-half-page-down',
    '?:execute-silent(echo \'' .. help_text_escaped .. '\')+preview(echo \'' .. help_text_escaped .. '\')',
  }
  if mode == 'search' then
    table.insert(binds, 'change:reload([ -n {q} ] && sleep 0.1 && ' .. safe_source .. ' {q})')
  end
  return table.concat(binds, ',')
end

return M
