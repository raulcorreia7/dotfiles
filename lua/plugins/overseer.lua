-- Task runner: builds, tests, servers (see :OverseerRun).
local gh = require('config.pack').gh

vim.pack.add({ gh 'stevearc/overseer.nvim' }, { confirm = false })
require('overseer').setup {}

vim.keymap.set('n', '<leader>or', '<cmd>OverseerRun<CR>', { desc = 'run task' })
vim.keymap.set('n', '<leader>ot', '<cmd>OverseerToggle<CR>', { desc = 'task list' })
