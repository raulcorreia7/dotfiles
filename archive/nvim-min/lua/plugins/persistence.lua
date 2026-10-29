-- Sessions auto-saved per directory; restored on demand.
local gh = require('config.pack').gh

vim.pack.add({ gh 'folke/persistence.nvim' }, { confirm = false })
local persistence = require 'persistence'
persistence.setup {}

vim.keymap.set('n', '<leader>qs', function() persistence.load() end, { desc = 'restore session' })
vim.keymap.set('n', '<leader>qS', function() persistence.select() end, { desc = 'select session' })
vim.keymap.set('n', '<leader>ql', function() persistence.load { last = true } end, { desc = 'restore last session' })
vim.keymap.set('n', '<leader>qd', function() persistence.stop() end, { desc = 'stop saving session' })
