-- Buffer tabs with powerline separators (icons via nvim-web-devicons)
-- https://github.com/akinsho/bufferline.nvim
local gh = require('config.pack').gh
local icons = require 'config.icons'

local separator_style = 'thick' -- e.g. 'slant', 'slope', 'thick', 'thin'

vim.pack.add({ { src = gh 'akinsho/bufferline.nvim', version = vim.version.range '*' } }, { confirm = false })

require('bufferline').setup {
  options = {
    diagnostics = 'nvim_lsp',
    separator_style = separator_style, -- powerline look
    show_buffer_close_icons = false,
    show_buffer_icons = icons.nerd,
    always_show_bufferline = false, -- hide the tabline with a single buffer
    offsets = {
      { filetype = 'neo-tree', text = 'explorer', highlight = 'Directory', text_align = 'left' },
    },
  },
}

vim.keymap.set('n', '<leader>bp', '<cmd>BufferLineTogglePin<CR>', { desc = 'toggle pin buffer' })
vim.keymap.set('n', '<leader>bj', '<cmd>BufferLinePick<CR>', { desc = 'pick buffer' })
vim.keymap.set('n', '<leader>bl', '<cmd>BufferLineCloseLeft<CR>', { desc = 'close buffers left' })
vim.keymap.set('n', '<leader>br', '<cmd>BufferLineCloseRight<CR>', { desc = 'close buffers right' })
vim.keymap.set('n', '<leader>bP', '<cmd>BufferLineGroupClose ungrouped<CR>', { desc = 'close non-pinned buffers' })
vim.keymap.set('n', '[B', '<cmd>BufferLineMovePrev<CR>', { desc = 'move buffer prev' })
vim.keymap.set('n', ']B', '<cmd>BufferLineMoveNext<CR>', { desc = 'move buffer next' })
