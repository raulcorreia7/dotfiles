-- Repository and file-history diff UI.
local gh = require('config.pack').gh

vim.pack.add({ gh 'sindrets/diffview.nvim' }, { confirm = false })

vim.keymap.set('n', '<leader>gd', '<cmd>DiffviewOpen<CR>', { desc = 'diffview' })
vim.keymap.set('n', '<leader>gD', '<cmd>DiffviewClose<CR>', { desc = 'close diffview' })
vim.keymap.set('n', '<leader>gH', '<cmd>DiffviewFileHistory %<CR>', { desc = 'file history' })
