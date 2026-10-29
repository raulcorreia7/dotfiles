-- Sidebar file tree (LazyVim feel, trimmed).
local gh = require('config.pack').gh
local icons = require 'config.icons'
local root = require('config.helpers').root

-- LazyVim shape: `cmd` + `keys` + dir-open `init`, implemented for vim.pack.
-- load() runs once on first use; maps below stay eager and call it.
local loaded = false
local neotree_cmd, neotree_git_status --- set by load()
local function load()
  if loaded then return end
  loaded = true
  pcall(vim.api.nvim_del_user_command, 'Neotree')
vim.pack.add({
  gh 'nvim-tree/nvim-web-devicons',
  { src = gh 'nvim-neo-tree/neo-tree.nvim', version = vim.version.range '*' },
  gh 'nvim-lua/plenary.nvim',
  gh 'MunifTanjim/nui.nvim',
}, { confirm = false })
neotree_cmd = require 'neo-tree.command'
local neotree_events = require 'neo-tree.events'
neotree_git_status = require 'neo-tree.sources.git_status'

-- Consumers can initialize/cache devicons before our config applies.
if icons.nerd then require('nvim-web-devicons').setup {
  color_icons = true,
  default = true,
  strict = true,
} end

require('neo-tree').setup {
  enable_git_status = true,
  open_files_do_not_replace_types = { 'terminal', 'qf' },
  enable_diagnostics = true,

  default_component_configs = {
    indent = {
      with_expanders = true,
      expander_collapsed = icons.tree.collapsed,
      expander_expanded = icons.tree.expanded,
      expander_highlight = 'NeoTreeExpander',
    },

    icon = {
      folder_closed = icons.tree.folder,
      folder_open = icons.tree.folder_open,
      folder_empty = icons.tree.folder_empty,
      folder_empty_open = icons.tree.folder_empty_open,
      selected = icons.tree.selected,
      -- ASCII mode: stub the devicons provider (installing it would bring
      -- Nerd Font glyphs back) and blank the default file icon.
      default = icons.nerd and '*' or '',
      provider = not icons.nerd and function() end or nil,
    },

    modified = {
      symbol = icons.tree.modified,
      highlight = 'NeoTreeModified',
    },

    diagnostics = {
      symbols = icons.diagnostics,
    },

    git_status = {
      symbols = icons.git,
    },
  },

  event_handlers = {
    {
      event = neotree_events.FILE_MOVED,
      handler = function(data) Snacks.rename.on_rename_file(data.source, data.destination) end,
    },
    {
      event = neotree_events.FILE_RENAMED,
      handler = function(data) Snacks.rename.on_rename_file(data.source, data.destination) end,
    },
  },
  filesystem = {
    bind_to_cwd = false,
    follow_current_file = { enabled = true },
    use_libuv_file_watcher = true,
  },

  window = {
    mappings = {
      ['\\'] = 'close_window',
      Y = {
        function(state) vim.fn.setreg('+', state.tree:get_node():get_id(), 'c') end,
        desc = 'copy path to clipboard',
      },
      O = {
        function(state) vim.ui.open(state.tree:get_node():get_id()) end,
        desc = 'open with system app',
      },
      P = { 'toggle_preview', config = { use_float = false } },
    },
  },
}


-- Refresh git status after lazygit closes.
vim.api.nvim_create_autocmd('TermClose', {
  desc = 'refresh neo-tree git status after lazygit',
  group = vim.api.nvim_create_augroup('neo-tree-lazygit-refresh', { clear = true }),
  pattern = '*lazygit',
  callback = function() neotree_git_status.refresh() end,
})
end

-- Stand-in until load(): the real command replaces this during setup.
vim.api.nvim_create_user_command('Neotree', function(opts)
  load()
  vim.cmd('Neotree' .. (opts.bang and '!' or '') .. (opts.args ~= '' and ' ' .. opts.args or ''))
end, { nargs = '*', bang = true, desc = 'file explorer (lazy)' })

-- Eager maps (LazyVim `keys` equivalent): each handler loads on first press.
vim.keymap.set('n', '<leader>e', function() load() neotree_cmd.execute { toggle = true, dir = root() } end, { desc = 'file explorer' })
vim.keymap.set('n', '<leader>ge', function() load() neotree_cmd.execute { source = 'git_status', toggle = true } end, { desc = 'git explorer' })
vim.keymap.set('n', '<leader>be', function() load() neotree_cmd.execute { source = 'buffers', toggle = true } end, { desc = 'buffer explorer' })
vim.keymap.set('n', '<leader>E', function() load() neotree_cmd.execute { toggle = true, dir = vim.fn.getcwd() } end, { desc = 'file explorer (cwd)' })

-- `nvim <dir>`: load so hijack_netrw opens the tree (LazyVim Neotree_start_directory).
vim.api.nvim_create_autocmd('BufEnter', {
  once = true,
  group = vim.api.nvim_create_augroup('neotree-start-directory', { clear = true }),
  desc = 'load neo-tree for directory argument',
  callback = function()
    local arg = vim.fn.argv(0)
    if arg ~= '' and vim.fn.isdirectory(arg) == 1 then load() end
  end,
})

-- Some themes (e.g. kanagawa) paint DiagnosticSign groups with a gutter
-- background; flat here so tree symbols sit on the tree background.
local function flatten_sign_backgrounds()
  for _, severity in ipairs { 'Error', 'Warn', 'Info', 'Hint' } do
    local name = 'DiagnosticSign' .. severity
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    if hl.bg then
      hl.bg = nil
      vim.api.nvim_set_hl(0, name, hl)
    end
  end
end
flatten_sign_backgrounds()
vim.api.nvim_create_autocmd('ColorScheme', {
  desc = 'flatten diagnostic sign backgrounds',
  group = vim.api.nvim_create_augroup('neo-tree-sign-flat', { clear = true }),
  callback = flatten_sign_backgrounds,
})

return { load = load }
