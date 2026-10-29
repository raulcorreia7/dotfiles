-- Fuzzy finder: files, grep, search menus, colorschemes, and LSP pickers.
-- Snacks keeps undo, GitHub, projects, and icons (no Telescope equivalent).
local gh = require('config.pack').gh
local root = require('config.helpers').root

do
  ---@type (string|vim.pack.Spec)[]
  local telescope_plugins = {
    gh 'nvim-lua/plenary.nvim',
    gh 'nvim-telescope/telescope.nvim',
    gh 'nvim-telescope/telescope-fzf-native.nvim',
  }

  vim.pack.add(telescope_plugins, { confirm = false })

  require('telescope').setup {
    extensions = {
      fzf = {
        fuzzy = true,
        override_generic_sorter = true,
        override_file_sorter = true,
      },
    },
  }

  pcall(require('telescope').load_extension, 'fzf')

  local builtin = require 'telescope.builtin'
  -- Files and buffers.
  vim.keymap.set('n', '<leader>,', builtin.buffers, { desc = 'buffers' })
  vim.keymap.set('n', '<leader><space>', function() builtin.find_files { cwd = root() } end, { desc = 'find files' })
  vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'buffers' })
  vim.keymap.set('n', '<leader>fc', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = 'find config file' })
  vim.keymap.set('n', '<leader>ff', function() builtin.find_files { cwd = root() } end, { desc = 'find files' })
  vim.keymap.set('n', '<leader>fF', function() builtin.find_files { cwd = vim.fn.getcwd() } end, { desc = 'find files (cwd)' })
  vim.keymap.set('n', '<leader>fg', builtin.git_files, { desc = 'find files (git)' })
  vim.keymap.set('n', '<leader>fr', builtin.oldfiles, { desc = 'recent' })
  vim.keymap.set('n', '<leader>fR', function() builtin.oldfiles { only_cwd = true } end, { desc = 'recent (cwd)' })
  -- Grep.
  vim.keymap.set('n', '<leader>sb', builtin.current_buffer_fuzzy_find, { desc = 'buffer lines' })
  vim.keymap.set('n', '<leader>sB', function() builtin.live_grep { grep_open_files = true } end, { desc = 'grep open buffers' })
  vim.keymap.set('n', '<leader>sg', function() builtin.live_grep { cwd = root() } end, { desc = 'grep' })
  vim.keymap.set('n', '<leader>sG', function() builtin.live_grep { cwd = vim.fn.getcwd() } end, { desc = 'grep (cwd)' })
  vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = 'visual selection or word' })
  -- Search menus.
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = 'telescope pickers' })
  vim.keymap.set('n', '<leader>:', builtin.command_history, { desc = 'command history' })
  vim.keymap.set('n', '<leader>s"', builtin.registers, { desc = 'registers' })
  vim.keymap.set('n', '<leader>s/', builtin.search_history, { desc = 'search history' })
  vim.keymap.set('n', '<leader>sa', builtin.autocommands, { desc = 'autocmds' })
  vim.keymap.set('n', '<leader>sc', builtin.command_history, { desc = 'command history' })
  vim.keymap.set('n', '<leader>sC', builtin.commands, { desc = 'commands' })
  vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = 'diagnostics' })
  vim.keymap.set('n', '<leader>sD', function() builtin.diagnostics { bufnr = 0 } end, { desc = 'buffer diagnostics' })
  vim.keymap.set('n', '<leader>sH', builtin.highlights, { desc = 'highlights' })
  vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = 'help pages' })
  vim.keymap.set('n', '<leader>sj', builtin.jumplist, { desc = 'jumps' })
  vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = 'keymaps' })
  vim.keymap.set('n', '<leader>sl', builtin.loclist, { desc = 'location list' })
  vim.keymap.set('n', '<leader>sM', builtin.man_pages, { desc = 'man pages' })
  vim.keymap.set('n', '<leader>sm', builtin.marks, { desc = 'marks' })
  vim.keymap.set('n', '<leader>sR', builtin.resume, { desc = 'resume' })
  vim.keymap.set('n', '<leader>sq', builtin.quickfix, { desc = 'quickfix list' })
  vim.keymap.set('n', '<leader>uC', function()
    require('plugins.theme').ensure_extra()
    local colors = vim.fn.getcompletion('', 'color')
    table.sort(colors) -- getcompletion returns rtp order; current scheme stays pinned first by the picker
    builtin.colorscheme { enable_preview = true, colors = colors }
  end, { desc = 'colorschemes' })
  -- Git.
  vim.keymap.set('n', '<leader>gl', function() builtin.git_commits { cwd = root() } end, { desc = 'git log' })
  vim.keymap.set('n', '<leader>gb', builtin.git_bcommits, { desc = 'git blame line' })
  vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = 'git status' })
  vim.keymap.set('n', '<leader>gS', builtin.git_stash, { desc = 'git stash' })
  vim.keymap.set('n', '<leader>gL', function() builtin.git_commits { cwd = vim.fn.getcwd() } end, { desc = 'git log (cwd)' })
  vim.keymap.set('n', '<leader>gf', builtin.git_bcommits, { desc = 'current file history' })
  vim.keymap.set('n', '<leader>gc', builtin.git_branches, { desc = 'checkout branch' })

  --- Buffer-local Telescope LSP pickers.
  ---@param event table LspAttach event with buf
  local function set_lsp_pickers(event)
    local buf = event.buf
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = 'references' })
    vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = 'goto implementation' })
    vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = 'goto definition' })
    vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'open document symbols' })
    vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'open workspace symbols' })
    vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = 'goto type definition' })
    if client and client:supports_method('callHierarchy/incomingCalls', buf) then
      vim.keymap.set('n', 'gai', builtin.lsp_incoming_calls, { buffer = buf, desc = 'incoming calls' })
    end
    if client and client:supports_method('callHierarchy/outgoingCalls', buf) then
      vim.keymap.set('n', 'gao', builtin.lsp_outgoing_calls, { buffer = buf, desc = 'outgoing calls' })
    end
    vim.keymap.set('n', 'gd', builtin.lsp_definitions, { buffer = buf, desc = 'goto definition' })
    vim.keymap.set('n', 'gr', builtin.lsp_references, { buffer = buf, desc = 'references' })
    vim.keymap.set('n', 'gI', builtin.lsp_implementations, { buffer = buf, desc = 'goto implementation' })
    vim.keymap.set('n', 'gy', builtin.lsp_type_definitions, { buffer = buf, desc = 'goto type definition' })
  end

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
    callback = set_lsp_pickers,
  })
end
