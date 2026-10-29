-- TODO and note highlighting.
local gh = require('config.pack').gh

-- Highlight todo, notes, etc in comments
vim.pack.add({ gh 'folke/todo-comments.nvim' }, { confirm = false })
local todo_comments = require 'todo-comments'
todo_comments.setup { signs = false }

vim.keymap.set('n', ']t', function() todo_comments.jump_next() end, { desc = 'next todo comment' })
vim.keymap.set('n', '[t', function() todo_comments.jump_prev() end, { desc = 'prev todo comment' })
vim.keymap.set('n', '<leader>sT', '<cmd>TodoTelescope keywords=TODO,FIX,FIXME<CR>', { desc = 'todo/fix/fixme' })
vim.keymap.set('n', '<leader>st', '<cmd>TodoTelescope keywords=TODO,FIX,FIXME<CR>', { desc = 'todo/fix/fixme' })
