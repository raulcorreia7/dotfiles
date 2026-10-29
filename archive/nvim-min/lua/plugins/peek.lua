-- LSP definition previews in floating windows.
local gh = require('config.pack').gh
local telescope_themes = require 'telescope.themes'

vim.pack.add({
  gh 'rmagatti/logger.nvim',
  gh 'rmagatti/goto-preview',
}, { confirm = false })

local preview = require 'goto-preview'
preview.setup {
  default_mappings = false,
  references = {
    provider = 'telescope',
    telescope = telescope_themes.get_dropdown { hide_preview = false },
  },
}

vim.keymap.set('n', '<leader>pd', preview.goto_preview_definition, { desc = 'peek definition' })
vim.keymap.set('n', '<leader>pt', preview.goto_preview_type_definition, { desc = 'peek type definition' })
vim.keymap.set('n', '<leader>pi', preview.goto_preview_implementation, { desc = 'peek implementation' })
vim.keymap.set('n', '<leader>pD', preview.goto_preview_declaration, { desc = 'peek declaration' })
vim.keymap.set('n', '<leader>pr', preview.goto_preview_references, { desc = 'peek references' })
vim.keymap.set('n', '<leader>pP', preview.close_all_win, { desc = 'close previews' })
