-- mini.nvim text modules (icons come from nvim-web-devicons, see neotree.lua).
local gh = require('config.pack').gh

vim.pack.add({ gh 'nvim-mini/mini.nvim' }, { confirm = false })

-- Better Around/Inside textobjects
--
-- Examples:
--  - va) - visually select around )paren
--  - yiiq - yank inside i+1 quote
--  - ci' - change inside 'quote
local mini_ai = require 'mini.ai'
mini_ai.setup {
  -- aa/ii instead of defaults: no clash with treesitter incremental selection.
  mappings = {
    around_next = 'aa',
    inside_next = 'ii',
  },
  n_lines = 500,
  custom_textobjects = {
    o = mini_ai.gen_spec.treesitter { -- code block
      a = { '@block.outer', '@conditional.outer', '@loop.outer' },
      i = { '@block.inner', '@conditional.inner', '@loop.inner' },
    },
    f = mini_ai.gen_spec.treesitter { a = '@function.outer', i = '@function.inner' }, -- function
    c = mini_ai.gen_spec.treesitter { a = '@class.outer', i = '@class.inner' }, -- class
    t = { '<([%p%w]-)%f[^<%w][^<>]->.-</%1>', '^<.->().*()</[^/]->$' }, -- tags
    d = { '%f[%d]%d+' }, -- digits
    e = { -- word with case
      { '%u[%l%d]+%f[^%l%d]', '%f[%S][%l%d]+%f[^%l%d]', '%f[%P][%l%d]+%f[^%l%d]', '^[%l%d]+%f[^%l%d]' },
      '^().*()$',
    },
    g = function() -- whole buffer
      local from = { line = 1, col = 1 }
      local to = { line = vim.fn.line '$', col = math.max(vim.fn.getline('$'):len(), 1) }
      return { from = from, to = to }
    end,
    u = mini_ai.gen_spec.function_call(), -- usage
    U = mini_ai.gen_spec.function_call { name_pattern = '[%w_]' }, -- usage without dot
  },
}

-- Add/delete/replace surroundings, LazyVim `gs` prefix.
--
-- - gsaiw) - surround add inner word )paren
-- - gsd' - surround delete 'quotes
-- - gsr)' - surround replace ) with '
require('mini.surround').setup {
  mappings = {
    add = 'gsa',
    delete = 'gsd',
    find = 'gsf',
    find_left = 'gsF',
    highlight = 'gsh',
    replace = 'gsr',
    update_n_lines = 'gsn',
  },
}

-- Auto-close brackets and quotes.
require('mini.pairs').setup {}
