-- Git signs and hunk actions (LazyVim key scheme, under <leader>g).
local gh = require('config.pack').gh
local icons = require 'config.icons'

vim.pack.add({ gh 'lewis6991/gitsigns.nvim' }, { confirm = false })
local gitsigns = require 'gitsigns'
gitsigns.setup {
  signs = {
    add = { text = icons.gitsigns.add },
    change = { text = icons.gitsigns.change },
    delete = { text = icons.gitsigns.delete },
    topdelete = { text = icons.gitsigns.delete },
    changedelete = { text = icons.gitsigns.change },
    untracked = { text = icons.gitsigns.add },
  },
  signs_staged = {
    add = { text = icons.gitsigns.add },
    change = { text = icons.gitsigns.change },
    delete = { text = icons.gitsigns.delete },
    topdelete = { text = icons.gitsigns.delete },
    changedelete = { text = icons.gitsigns.change },
  },
  on_attach = function(buffer)
    --- Buffer-local map with description.
    ---@param mode string|string[] vim mode
    ---@param keys string left-hand side
    ---@param func any right-hand side
    ---@param desc string lowercase label
    local function map(mode, keys, func, desc) vim.keymap.set(mode, keys, func, { buffer = buffer, desc = desc, silent = true }) end

    map('n', ']h', function()
      if vim.wo.diff then
        vim.cmd.normal { ']c', bang = true }
      else
        gitsigns.nav_hunk 'next'
      end
    end, 'next hunk')
    map('n', '[h', function()
      if vim.wo.diff then
        vim.cmd.normal { '[c', bang = true }
      else
        gitsigns.nav_hunk 'prev'
      end
    end, 'prev hunk')
    map('n', ']H', function() gitsigns.nav_hunk 'last' end, 'last hunk')
    map('n', '[H', function() gitsigns.nav_hunk 'first' end, 'first hunk')
    map({ 'n', 'x' }, '<leader>ghs', ':Gitsigns stage_hunk<CR>', 'stage hunk')
    map({ 'n', 'x' }, '<leader>ghr', ':Gitsigns reset_hunk<CR>', 'reset hunk')
    map('n', '<leader>ghS', gitsigns.stage_buffer, 'stage buffer')
    map('n', '<leader>ghR', gitsigns.reset_buffer, 'reset buffer')
    map('n', '<leader>ghp', gitsigns.preview_hunk_inline, 'preview hunk inline')
    map('n', '<leader>ghb', function() gitsigns.blame_line { full = true } end, 'blame line')
    map('n', '<leader>ghB', function() gitsigns.blame() end, 'blame buffer')
    map('n', '<leader>ghd', gitsigns.diffthis, 'diff this')
    map('n', '<leader>ghD', function() gitsigns.diffthis '~' end, 'diff this ~')
    map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', 'gitsigns select hunk')

    -- Sign toggles live with the other editor toggles.
    map('n', '<leader>uB', gitsigns.toggle_current_line_blame, 'toggle git show blame line')
    map('n', '<leader>uW', gitsigns.toggle_word_diff, 'toggle git intra-line word diff')
  end,
}
