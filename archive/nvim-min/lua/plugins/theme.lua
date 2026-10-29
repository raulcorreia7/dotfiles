-- Themes: installs, default, and `<leader>uC` pick persistence.
local gh = require('config.pack').gh

-- Default when no choice was saved yet (change here to switch the default).
local default_colorscheme = 'tokyonight-night' -- e.g. 'tokyonight-storm', 'tokyonight-moon', 'tokyonight-day'

-- Last `<leader>uC` pick, so restarts keep it instead of resetting to default.
local state_file = vim.fn.stdpath 'data' .. '/colorscheme.txt'
local colorscheme = default_colorscheme
do
  local ok, lines = pcall(vim.fn.readfile, state_file)
  if ok and lines[1] and lines[1] ~= '' then colorscheme = vim.fn.trim(lines[1]) end
end

vim.pack.add({ gh 'folke/tokyonight.nvim' }, { confirm = false })
-- Extra themes load on first `<leader>uC` pick, not at startup
-- (colorscheme plugins are on-demand, like lazy.nvim `cmd`-triggered specs).
---@type (string|vim.pack.Spec)[]
local extra_themes = {
  gh 'catppuccin/nvim',
  gh 'rebelot/kanagawa.nvim',
  gh 'rose-pine/neovim',
  gh 'EdenEast/nightfox.nvim',
  gh 'ellisonleao/gruvbox.nvim',
  gh 'sainnhe/everforest',
  gh 'sainnhe/sonokai',
  gh 'Mofiqul/dracula.nvim',
  gh 'navarasu/onedark.nvim',
  gh 'olimorris/onedarkpro.nvim',
  gh 'marko-cerovac/material.nvim',
  gh 'projekt0n/github-nvim-theme',
  gh 'scottmckendry/cyberdream.nvim',
  gh 'vague2k/vague.nvim',
  gh 'savq/melange-nvim',
  gh 'AlexvZyl/nordic.nvim',
  gh 'Mofiqul/vscode.nvim',
  gh 'nyoom-engineering/oxocarbon.nvim',
  gh 'aktersnurra/no-clown-fiesta.nvim',
}
local extra_loaded = false
local function ensure_extra()
  if extra_loaded then return end
  extra_loaded = true
  vim.pack.add(extra_themes, { confirm = false })
end
---@diagnostic disable-next-line: missing-fields
require('tokyonight').setup {
  styles = {
    comments = { italic = false }, -- Disable italics in comments
  },
}

vim.api.nvim_create_autocmd('ColorScheme', {
  desc = 'remember colorscheme pick',
  group = vim.api.nvim_create_augroup('theme-persist', { clear = true }),
  callback = function()
    if vim.g.colors_name then vim.fn.writefile({ vim.g.colors_name }, state_file) end
  end,
})

-- Load the colorscheme here (fall back when the saved theme is gone).
-- A saved extra-theme pick pulls the deferred themes in first.
if not pcall(vim.cmd.colorscheme, colorscheme) then
  ensure_extra()
  if not pcall(vim.cmd.colorscheme, colorscheme) then vim.cmd.colorscheme(default_colorscheme) end
end

return { ensure_extra = ensure_extra }
