-- Snippets (LuaSnip) and completion (blink.cmp).
local gh = require('config.pack').gh
local icons = require 'config.icons'

local keymap_preset = 'default' -- blink keymap style; e.g. 'super-tab', 'enter', 'none'
local fuzzy_matcher = 'prefer_rust_with_warning' -- built via cargo in config/pack.lua; falls back to lua

-- Setup runs on first `InsertEnter` (lazy.nvim `event = "InsertEnter"` for completion).
local function setup()
  vim.pack.add({ { src = gh 'L3MON4D3/LuaSnip', version = vim.version.range '2.*' } }, { confirm = false })
  vim.pack.add({ gh 'rafamadriz/friendly-snippets' }, { confirm = false })
  require('luasnip.loaders.from_vscode').lazy_load()

  vim.pack.add({ { src = gh 'saghen/blink.cmp', version = vim.version.range '1.*' } }, { confirm = false })
  require('blink.cmp').setup {
    -- Preset keymaps (<tab>/<s-tab> snippet jump, <c-space> menu/docs,
    -- <c-n>/<c-p> select, <c-e> hide, <c-k> signature help).
    keymap = { preset = keymap_preset, ['<CR>'] = { 'accept', 'fallback' } },

    appearance = {
      -- 'mono' for 'Nerd Font Mono', 'normal' for 'Nerd Font'.
      nerd_font_variant = icons.nerd and 'mono' or 'normal',
      kind_icons = icons.kinds,
    },

    completion = {
      -- `<c-space>` shows docs; `auto_show = true` shows them after a delay.
      documentation = { auto_show = false, auto_show_delay_ms = 500 },
    },

    sources = {
      default = { 'lsp', 'path', 'snippets' },
    },

    snippets = { preset = 'luasnip' },

    fuzzy = { implementation = fuzzy_matcher },

    signature = { enabled = true },
  }
end
vim.api.nvim_create_autocmd('InsertEnter', {
  once = true,
  group = vim.api.nvim_create_augroup('completion-lazy', { clear = true }),
  callback = setup,
})
