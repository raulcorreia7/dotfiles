-- Ultra-minimal statusline (VS Code flat): letter mode, branch, path.
-- Contextual blocks (search, selection, macro) render only when active.
local gh = require('config.pack').gh
local icons = require 'config.icons'

vim.pack.add({ gh 'nvim-lualine/lualine.nvim' }, { confirm = false })
vim.pack.add({ gh 'Bekaboo/dropbar.nvim' }, { confirm = false })
local dropbar = require 'dropbar'
local lualine = require 'lualine'
dropbar.setup {}

-- Macro recording refreshes the bar the moment recording starts/stops.
vim.api.nvim_create_autocmd({ 'RecordingEnter', 'RecordingLeave' }, {
  desc = 'refresh statusline on macro record',
  group = vim.api.nvim_create_augroup('lualine-macro-refresh', { clear = true }),
  callback = function() lualine.refresh { place = { 'statusline' } } end,
})

lualine.setup {
  options = {
    theme = 'auto',
    globalstatus = true,
    component_separators = '',
    section_separators = '',
  },
  sections = {
    lualine_a = {
      -- Single letter (N/I/V/R/C/T); per-mode color comes from the theme.
      { 'mode', fmt = function(mode) return mode:sub(1, 1) end },
    },
    lualine_b = { 'branch' },
    lualine_c = {
      {
        'filename',
        path = 1,
        symbols = { modified = '●', readonly = '[RO]', unnamed = '[No Name]' },
      },
      'searchcount',
      'selectioncount',
      {
        function()
          local reg = vim.fn.reg_recording()
          return reg ~= '' and '@' .. reg or ''
        end,
      },
    },
    lualine_x = {
      { 'diff', symbols = { added = icons.git.added, modified = icons.git.modified, removed = icons.git.deleted } },
      { 'diagnostics', symbols = icons.diagnostics },
    },
    lualine_y = {},
    lualine_z = { 'location' },
  },
}
