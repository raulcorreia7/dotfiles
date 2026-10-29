-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Icons: Nerd Font available (statusline, which-key, pickers)
vim.g.have_nerd_font = true
-- No format-on-save; format explicitly with <leader>cf
vim.g.autoformat = false
-- No .swp files; recovery via :h undo (undodir is already on)
vim.opt.swapfile = false
