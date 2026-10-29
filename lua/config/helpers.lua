-- Shared helpers for config and plugin modules.
local M = {}

--- Nerd Font capability flag for UI symbols. `NVIM_NERD_FONT=0/1` wins;
--- nerd assumed otherwise (portable fallback when unset elsewhere).
---@return boolean
function M.has_nerd_font()
  local value = vim.env.NVIM_NERD_FONT
  if value then
    value = value:lower():match '^%s*(.-)%s*$'
    if value == '0' then return false end
    if value == '1' then return true end
    if value ~= '' then vim.notify('Ignoring NVIM_NERD_FONT=' .. value, vim.log.levels.WARN) end
  end
  return true
end

--- Project root: git ancestor of the current file, else working directory.
---@return string
function M.root() return vim.fs.root(0, '.git') or vim.fn.getcwd() end

--- Full config reload with clean module state. Re-runs init.lua.
function M.reload()
  -- Setups that defer work until VimEnter (e.g. todo-comments) race a
  -- reload issued before startup finishes; wait for enter instead.
  if vim.v.vim_did_enter == 0 then
    vim.api.nvim_create_autocmd('VimEnter', {
      desc = 'run pending config reload',
      group = vim.api.nvim_create_augroup('nvim-min-reload-once', { clear = true }),
      once = true,
      callback = M.reload,
    })
    vim.notify('Reload scheduled after startup', vim.log.levels.INFO)
    return
  end
  for name in pairs(package.loaded) do
    local keep = name:match '^vim%.' or name:match '^_' or name == 'jit' or name:match '^jit%.' or name == 'ffi' or name == 'bit'
    if not keep then package.loaded[name] = nil end
  end
  -- Re-sync globals that plugins set once at startup.
  if _G.Snacks ~= nil then _G.Snacks = require 'snacks' end
  _G.nvim_min_snacks_setup = nil
  local ok, err = pcall(dofile, vim.fn.stdpath 'config' .. '/init.lua')
  if ok then
    vim.notify('Config reloaded', vim.log.levels.INFO)
  else
    vim.notify('Reload failed: ' .. err, vim.log.levels.ERROR)
  end
end

return M
