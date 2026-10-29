-- Telescope owns find/grep/search (best finder + fzf); Snacks keeps undo,
-- GitHub, projects, icons, terminal, toggles, dashboard (no equal there).
-- https://github.com/folke/snacks.nvim
local gh = require('config.pack').gh
local root = require('config.helpers').root

local picker_layout = 'telescope' -- centered float; e.g. 'select', 'vscode', 'dropdown', 'vertical', 'right'

vim.pack.add({ { src = gh 'folke/snacks.nvim', version = vim.version.range '*' } }, { confirm = false })

-- Setup runs once per session; re-running (e.g. <leader>R) is a noisy no-op upstream.
if not _G.nvim_min_snacks_setup then
  require('snacks').setup {
    bigfile = {}, -- fast path for huge files
    dashboard = {
      preset = {
        keys = {
          { icon = '> ', key = 'f', desc = 'Find File', action = '<leader>ff' },
          { icon = '+ ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
          { icon = '/ ', key = 'g', desc = 'Find Text', action = '<leader>sg' },
          { icon = ' ', key = 'r', desc = 'Recent Files', action = '<leader>fr' },
          { icon = ' ', key = 'c', desc = 'Config', action = '<leader>fc' },
          { icon = ' ', key = 's', desc = 'Restore Session', action = '<leader>qs' },
          { icon = '# ', key = 'm', desc = 'Mason', action = ':Mason' },
          { icon = '* ', key = 't', desc = 'Themes', action = '<leader>uC' },
          { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
        },
      },
      -- Default sections include a `startup` block that requires lazy.nvim;
      -- list ours explicitly without it.
      sections = {
        { section = 'header' },
        { section = 'keys', gap = 1, padding = 1 },
      },
    },
    quickfile = {}, -- snappy filetype for quick reads
    indent = {}, -- indent guides and scopes
    input = {}, -- polished vim.ui.input replacement
    picker = { layout = picker_layout },
    terminal = {},
    zen = {}, -- zen mode (toggle with <leader>uz)
    dim = {}, -- dim inactive text (toggle with <leader>uD)
    notifier = {}, -- pretty notifications with history (<leader>n)
  }
  _G.nvim_min_snacks_setup = true
end
vim.keymap.set('n', '<leader>n', function() Snacks.notifier.show_history() end, { desc = 'notification history' })

-- Snacks-only menus (undo, GitHub, projects, icons); finder lives in
vim.keymap.set('n', '<leader>fB', function() Snacks.picker.buffers { hidden = true, nofile = true } end, { desc = 'buffers (all)' })
vim.keymap.set('n', '<leader>fp', function() Snacks.picker.projects() end, { desc = 'projects' })
vim.keymap.set('n', '<leader>bd', function() Snacks.bufdelete() end, { desc = 'delete buffer' })
vim.keymap.set('n', '<leader>bo', function() Snacks.bufdelete.other() end, { desc = 'delete other buffers' })
vim.keymap.set('n', '<leader>ba', function() Snacks.bufdelete.all() end, { desc = 'delete all buffers' })
vim.keymap.set('n', '<leader>cR', Snacks.rename.rename_file, { desc = 'rename file' })
vim.keymap.set('n', '<leader>gi', function() Snacks.picker.gh_issue() end, { desc = 'github issues (open)' })
vim.keymap.set('n', '<leader>gI', function() Snacks.picker.gh_issue { state = 'all' } end, { desc = 'github issues (all)' })
vim.keymap.set('n', '<leader>gp', function() Snacks.picker.gh_pr() end, { desc = 'github prs (open)' })
vim.keymap.set('n', '<leader>gP', function() Snacks.picker.gh_pr { state = 'all' } end, { desc = 'github prs (all)' })
vim.keymap.set({ 'n', 'x' }, '<leader>gB', function() Snacks.gitbrowse() end, { desc = 'git browse (open)' })
vim.keymap.set({ 'n', 'x' }, '<leader>gY', function()
  Snacks.gitbrowse { open = function(url) vim.fn.setreg('+', url) end, notify = false }
end, { desc = 'git browse (copy)' })
vim.keymap.set('n', '<leader>si', function() Snacks.picker.icons() end, { desc = 'icons' })
vim.keymap.set('n', '<leader>su', function() Snacks.picker.undo() end, { desc = 'undo tree' })

-- One persistent terminal per working directory; toggle from normal or terminal mode.
vim.keymap.set('n', '<leader>ft', function() Snacks.terminal(nil, { cwd = root() }) end, { desc = 'terminal (root dir)' })
vim.keymap.set('n', '<leader>fT', function() Snacks.terminal(nil, { cwd = vim.fn.getcwd() }) end, { desc = 'terminal (cwd)' })
-- Most terminals encode Ctrl-/ as Ctrl-_; map both forms.
vim.keymap.set({ 'n', 't' }, '<C-_>', function() Snacks.terminal() end, { desc = 'toggle terminal' })

--- Window-option toggle affecting every open window plus future ones.
---@param option string window-local vim option name
---@param name string lowercase label shown in toggle feedback
local function global_toggle(option, name)
  return Snacks.toggle.new {
    id = option,
    name = name,
    get = function() return vim.wo[option] end,
    set = function(state)
      vim.api.nvim_set_option_value(option, state, { scope = 'global' })
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        vim.api.nvim_set_option_value(option, state, { scope = 'local', win = win })
      end
    end,
  }
end

global_toggle('spell', 'spelling'):map '<leader>us'
global_toggle('wrap', 'wrap'):map '<leader>uw'
global_toggle('number', 'line numbers'):map '<leader>ul'
global_toggle('relativenumber', 'relative number'):map '<leader>uL'
Snacks.toggle.diagnostics():map '<leader>ud'
Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'dark background' }):map '<leader>ub'
Snacks.toggle.option('conceallevel', { off = 0, on = 2, name = 'conceal level' }):map '<leader>uc'
Snacks.toggle.option('showtabline', { off = 0, on = 2, name = 'tabline' }):map '<leader>uA'
Snacks.toggle.treesitter():map '<leader>uT'
Snacks.toggle.indent():map '<leader>ug'
Snacks.toggle.dim():map '<leader>uD'
Snacks.toggle.zoom():map('<leader>wm'):map '<leader>uZ'
Snacks.toggle.zen():map '<leader>uz'
vim.keymap.set('n', '<leader>un', function() Snacks.notifier.hide() end, { desc = 'dismiss notifications' })
vim.keymap.set('n', '<leader>.', function() Snacks.scratch() end, { desc = 'toggle scratch buffer' })
vim.keymap.set('n', '<leader>S', function() Snacks.scratch.select() end, { desc = 'select scratch buffer' })
