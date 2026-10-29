-- LSP servers, Mason tools, and buffer-local LSP keymaps.
local gh = require('config.pack').gh


vim.pack.add({ gh 'b0o/SchemaStore.nvim' }, { confirm = false })
local schemastore = require 'schemastore'
  -- Servers to enable. Mason installs any missing ones below.
  -- See `:help lsp-config` for keys and per-server settings.
  ---@type table<string, vim.lsp.Config>
  local servers = {
    gopls = {},
    basedpyright = {}, -- pyright-compatible types; ruff handles lint/format
    vtsls = {}, -- VS Code-parity TypeScript
    bashls = {},
    clangd = {},
    cmake = {
      root_markers = { 'CMakeLists.txt', 'CMakePresets.json', 'CTestConfig.cmake', '.git', 'build', 'cmake' },
    },
    taplo = {}, -- TOML (formats itself)
    zls = {},
    docker_language_server = {},
    rust_analyzer = {}, -- system rustup binary (see ensure skip below)
    marksman = {}, -- Markdown references and completion
    harper_ls = { -- prose grammar; empty object (backend rejects null)
      settings = {
        ['harper-ls'] = vim.empty_dict(),
      },
    },
    rumdl = {}, -- Markdown lint and format
    jsonls = {
      settings = {
        json = {
          schemas = schemastore.json.schemas(),
          validate = { enable = true },
        },
      },
    },
    yamlls = {
      settings = {
        yaml = {
          schemaStore = { enable = false, url = '' },
          schemas = schemastore.yaml.schemas(),
        },
      },
    },

    -- Lua, tuned for Neovim config editing (stylua formats via conform).
    lua_ls = {
      on_init = function(client)
        client.server_capabilities.documentFormattingProvider = false

        if client.workspace_folders then
          local path = client.workspace_folders[1].name
          if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
        end

        local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
        client.config.settings.Lua = vim.tbl_deep_extend('force', current_settings.Lua, {
          runtime = {
            version = 'LuaJIT',
            path = { 'lua/?.lua', 'lua/?/init.lua' },
          },
          workspace = {
            checkThirdParty = false,
            -- Slow on large projects; see nvim-lspconfig#3189.
            library = vim.api.nvim_get_runtime_file('', true),
          },
        })
      end,
      ---@type lspconfig.settings.lua_ls
      settings = {
        Lua = {
          format = { enable = false },
        },
      },
    },
  }
-- Full setup on first file event (LazyVim lspconfig uses BufReadPre + BufNewFile).
local function setup()
  -- Progress notifications for LSP work.
  vim.pack.add({ gh 'j-hui/fidget.nvim' }, { confirm = false })
  require('fidget').setup {}

  --- Toggle CodeLens annotations, including reference counts, for the current buffer.
  local function toggle_codelens()
    local buf = vim.api.nvim_get_current_buf()
    local available = false
    for _, client in ipairs(vim.lsp.get_clients { bufnr = buf }) do
      if client:supports_method('textDocument/codeLens', buf) then
        available = true
        break
      end
    end
    if not available then
      vim.notify('CodeLens is unavailable for this buffer', vim.log.levels.INFO)
      return
    end
    local enabled = vim.lsp.codelens.is_enabled { bufnr = buf }
    vim.b[buf].lsp_codelens_enabled = not enabled
    vim.lsp.codelens.enable(not enabled, { bufnr = buf })
  end
  vim.keymap.set('n', '<leader>cC', toggle_codelens, { desc = 'toggle codelens' })

  --- Buffer-local setup when a server attaches: maps, highlights, inlay hints.
  ---@param event table LspAttach event with buf and client_id
  local function on_lsp_attach(event)
    --- Buffer-local LSP map with description.
    ---@param keys string left-hand side
    ---@param func any right-hand side
    ---@param desc string lowercase label
    ---@param mode? string|string[] vim mode, default 'n'
    local map = function(keys, func, desc, mode)
      mode = mode or 'n'
      vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = desc })
    end

    -- Code actions (rename/action ride 0.12 defaults; declaration has none).
    map('gD', vim.lsp.buf.declaration, 'goto declaration')
    map('<leader>cr', vim.lsp.buf.rename, 'rename')
    map('<leader>ca', vim.lsp.buf.code_action, 'code action', { 'n', 'x' })
    map('<leader>cA', function() vim.lsp.buf.code_action { context = { only = { 'source' }, diagnostics = {} } } end, 'source action')
    map('<leader>cL', '<cmd>checkhealth vim.lsp<CR>', 'lsp info')
    map('<leader>cm', '<cmd>Mason<CR>', 'mason')
    map('gK', vim.lsp.buf.signature_help, 'signature help')

    -- Highlight references under the cursor; cleared on move and detach.
    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method('textDocument/documentHighlight', event.buf) then
      local highlight_augroup = vim.api.nvim_create_augroup('lsp-highlight', { clear = false })
      vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.document_highlight,
      })

      vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
        buffer = event.buf,
        group = highlight_augroup,
        callback = vim.lsp.buf.clear_references,
      })

      vim.api.nvim_create_autocmd('LspDetach', {
        group = vim.api.nvim_create_augroup('lsp-detach', { clear = true }),
        callback = function(event2)
          vim.lsp.buf.clear_references()
          vim.api.nvim_clear_autocmds { group = 'lsp-highlight', buffer = event2.buf }
        end,
      })
    end

    -- Inlay hints, when the server supports them.
    if client and client:supports_method('textDocument/inlayHint', event.buf) then
      map('<leader>uh', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, 'toggle inlay hints')
      vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
    end
    -- Codelens, when the server provides them (`refresh()` is deprecated).
    if client and client:supports_method('textDocument/codeLens', event.buf) then
      if vim.b[event.buf].lsp_codelens_enabled == nil then vim.b[event.buf].lsp_codelens_enabled = true end
      local codelens_on = function()
        if vim.b[event.buf].lsp_codelens_enabled then vim.lsp.codelens.enable(true, { bufnr = event.buf }) end
      end
      map('<leader>cc', vim.lsp.codelens.run, 'run codelens', { 'n', 'x' })
      codelens_on()
      vim.api.nvim_create_autocmd({ 'BufEnter', 'CursorHold', 'InsertLeave' }, {
        buffer = event.buf,
        group = vim.api.nvim_create_augroup('lsp-codelens', { clear = false }),
        callback = codelens_on,
      })
    end
  end

  vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('lsp-attach', { clear = true }),
    callback = on_lsp_attach,
  })

  vim.pack.add({
    gh 'neovim/nvim-lspconfig',
    gh 'mason-org/mason.nvim',
    gh 'mason-org/mason-lspconfig.nvim',
    gh 'WhoIsSethDaniel/mason-tool-installer.nvim',
  }, { confirm = false })

  require('mason').setup {}

  -- Mason-installed servers enable themselves, except lua_ls's doubles:
  -- emmylua and stylua attach their own Lua clients; lua_ls owns Lua here.
  -- The loop below only adds per-server settings (its explicit enable keeps custom configs first).
  require('mason-lspconfig').setup { automatic_enable = { exclude = { 'emmylua_ls', 'stylua' } } }

  -- Server and tool installation (:Mason to inspect; `g?` for help).
  -- Server keys translated to Mason package names below.
  -- Linters self-install from lint.lua; only non-linters listed here.
  -- rust_analyzer comes from rustup (toolchain match), not Mason.
  local to_package = require('mason-lspconfig').get_mappings().lspconfig_to_package
  local system_servers = { rust_analyzer = true }
  local servers_to_install = vim.tbl_filter(function(server) return not system_servers[server] end, vim.tbl_keys(servers or {}))
  local ensure_installed = vim.tbl_map(function(server) return to_package[server] or server end, servers_to_install)
  vim.list_extend(ensure_installed, {
    -- Non-LSP tools (servers map from above; linters self-install from lint.lua).
    -- Mirror of formatters_by_ft in format.lua.
    'stylua', -- Lua formatter (used by conform)
    'gofumpt', -- Go formatter (used by conform)
    'shfmt', -- shell formatter (used by conform)
    'oxfmt', -- JS/TS/JSON formatter (used by conform)
    'prettierd', -- YAML/CSS/HTML formatter (used by conform)
    'cmakelang', -- CMake formatter and linter (used by conform and nvim-lint)
    'clang-format', -- C/C++ formatter (used by conform)
    'actionlint', -- GitHub Actions workflow linter (invoked manually, not in linters_by_ft)
    'delve', -- Go debugger (used by nvim-dap-go)
    'tree-sitter-cli', -- compiles treesitter parsers on demand
  })

  require('mason-tool-installer').setup { ensure_installed = ensure_installed }

  for name, server in pairs(servers) do
    vim.lsp.config(name, server)
    vim.lsp.enable(name)
  end

end
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  group = vim.api.nvim_create_augroup('lsp-lazy', { clear = true }),
  callback = setup,
})

return { servers = servers }
