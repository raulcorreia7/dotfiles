-- Search and replace across the project.
local gh = require('config.pack').gh

vim.pack.add({ gh 'MagicDuck/grug-far.nvim' }, { confirm = false })
local grug_far = require 'grug-far'
grug_far.setup {}

vim.keymap.set({ 'n', 'x' }, '<leader>sr', function() grug_far.open() end, { desc = 'search and replace' })
