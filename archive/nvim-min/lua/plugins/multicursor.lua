-- Multiple cursors with VS Code-like next-occurrence selection.
local gh = require('config.pack').gh

vim.pack.add({ { src = gh 'jake-stewart/multicursor.nvim', version = '1.0' } }, { confirm = false })

local multicursor = require 'multicursor-nvim'
multicursor.setup {}

vim.keymap.set({ 'n', 'x' }, '<leader>md', function() multicursor.matchAddCursor(1) end, { desc = 'add next cursor' })
vim.keymap.set({ 'n', 'x' }, '<leader>mD', multicursor.matchAllAddCursors, { desc = 'add all cursors' })

multicursor.addKeymapLayer(function(map) map('n', '<Esc>', multicursor.clearCursors) end)
