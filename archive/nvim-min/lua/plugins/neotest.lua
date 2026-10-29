-- Tests through neotest (vitest and go adapters).
local gh = require('config.pack').gh

vim.pack.add({
  gh 'nvim-neotest/neotest',
  gh 'nvim-neotest/nvim-nio',
  gh 'nvim-lua/plenary.nvim',
  gh 'marilari88/neotest-vitest',
  gh 'nvim-neotest/neotest-go',
}, { confirm = false })

require('neotest').setup {
  adapters = {
    require 'neotest-vitest',
    require 'neotest-go',
  },
}

local neotest = require 'neotest'
vim.keymap.set('n', '<leader>tt', function() neotest.run.run() end, { desc = 'test nearest' })
vim.keymap.set('n', '<leader>tT', function() neotest.run.run(vim.fn.expand '%') end, { desc = 'test file' })
vim.keymap.set('n', '<leader>ts', function() neotest.summary.toggle() end, { desc = 'test summary' })
vim.keymap.set('n', '<leader>to', function() neotest.output.open { enter = true } end, { desc = 'test output' })
