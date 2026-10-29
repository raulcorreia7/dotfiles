-- Keymap discovery with the LazyVim helix preset.
local gh = require('config.pack').gh
local icons = require 'config.icons'

local preset = 'helix' -- popup style
local popup_delay = 0 -- ms before the popup opens
vim.pack.add({ gh 'folke/which-key.nvim' }, { confirm = false })
local which_key = require 'which-key'
local which_key_extras = require 'which-key.extras'
which_key.setup {
  preset = preset, -- LazyVim look
  delay = popup_delay,
  icons = { mappings = icons.nerd },
  -- Group order mirrors LazyVim; `p`, `t`, and `gr` are local additions.
  spec = {
    { '<leader><tab>', group = 'tabs' },
    { '<leader>c', group = 'code' },
    { '<leader>d', group = 'debug' },
    { '<leader>f', group = 'file/find' },
    { '<leader>g', group = 'git' },
    { '<leader>gh', group = 'hunks' },
    { '<leader>p', group = 'peek' },
    { '<leader>q', group = 'quit/session' },
    { '<leader>s', group = 'search', mode = { 'n', 'v' } },
    { '<leader>u', group = 'ui/toggles' },
    { '<leader>x', group = 'diagnostics/quickfix' },
    { '[', group = 'prev' },
    { ']', group = 'next' },
    { 'g', group = 'goto' },
    { 'gs', group = 'surround' },
    { '<leader>b', group = 'buffer', expand = function() return which_key_extras.expand.buf() end },
    { '<leader>w', group = 'windows', proxy = '<c-w>', expand = function() return which_key_extras.expand.win() end },
    { '<leader>t', group = 'tests' },
    { 'gr', group = 'lsp actions', mode = { 'n' } },
    { 'gx', desc = 'open with system app' },
  },
}

-- Buffer-local hints and window hydra (mirrors LazyVim).
vim.keymap.set('n', '<leader>?', function() which_key.show { global = false } end, { desc = 'buffer keymaps' })
vim.keymap.set('n', '<C-w><space>', function() which_key.show { keys = '<c-w>', loop = true } end, { desc = 'window hydra mode' })
