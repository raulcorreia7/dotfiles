-- LazyGit terminal UI in a floating window (project root).
local gh = require('config.pack').gh

vim.pack.add({ gh 'kdheepak/lazygit.nvim' }, { confirm = false })

local lazygit = require 'lazygit'
local root = require('config.helpers').root

vim.keymap.set('n', '<leader>gg', function() lazygit.lazygit(root()) end, { desc = 'lazygit (root dir)' })
vim.keymap.set('n', '<leader>gG', function() lazygit.lazygit(vim.fn.getcwd()) end, { desc = 'lazygit (cwd)' })
