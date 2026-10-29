-- Jump labels, treesitter select, remote actions.
local gh = require('config.pack').gh

vim.pack.add({ gh 'folke/flash.nvim' }, { confirm = false })
local flash = require 'flash'
flash.setup {}

vim.keymap.set({ 'n', 'x', 'o' }, 's', flash.jump, { desc = 'flash' })
vim.keymap.set({ 'n', 'x', 'o' }, 'S', flash.treesitter, { desc = 'flash treesitter' })
vim.keymap.set('c', '<C-s>', flash.toggle, { desc = 'toggle flash search' })
vim.keymap.set('o', 'r', flash.remote, { desc = 'remote flash' })
vim.keymap.set({ 'o', 'x' }, 'R', flash.treesitter_search, { desc = 'treesitter search' })
