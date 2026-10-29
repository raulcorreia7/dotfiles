-- Throwaway functional sweep: `nvim --headless +"luafile /tmp/nvim_check.lua" "+qa"`.
-- Prints PASS/FAIL per check; exit code is qa's, not the checks'.
local failures = 0
local function check(name, ok)
  if ok then
    print('PASS ' .. name)
  else
    failures = failures + 1
    print('FAIL ' .. name)
  end
end

-- 0. Fire lazy triggers so deferred setups run before assertions.
vim.api.nvim_exec_autocmds('InsertEnter', {})
vim.api.nvim_exec_autocmds('BufReadPre', { buffer = vim.api.nvim_get_current_buf() })
require('plugins.neotree').load()

-- 1. Every plugin module loads.
local modules = {
  'snacks',
  'telescope',
  'telescope.builtin',
  'conform',
  'lint',
  'neotest',
  'dap',
  'dapui',
  'flash',
  'goto-preview',
  'multicursor-nvim',
  'persistence',
  'overseer',
  'dropbar',
  'blink.cmp',
  'luasnip',
  'todo-comments',
  'which-key',
  'lualine',
  'bufferline',
  'gitsigns',
  'neo-tree',
  'mini.ai',
  'mini.pairs',
  'mini.surround',
  'guess-indent',
  'fidget',
  'mason',
  'mason-tool-installer',
  'mason-lspconfig',
  'mason-nvim-lint',
  'lazygit',
  'diffview',
  'tokyonight',
  'nvim-treesitter',
}
for _, mod in ipairs(modules) do
  local ok = pcall(require, mod)
  check('require ' .. mod, ok)
end

-- 2. User commands exist.
for _, cmd in ipairs { 'OverseerRun', 'OverseerToggle', 'DiffviewOpen', 'Mason', 'ReloadConfig', 'Neotree', 'TodoTelescope', 'MasonToolsInstall' } do
  check('cmd :' .. cmd, vim.api.nvim_create_user_command ~= nil and vim.fn.exists(':' .. cmd) == 2)
end

-- 3. Fire UIEnter so deferred Snacks hooks run, then check owners.
vim.api.nvim_exec_autocmds('UIEnter', {})
check('vim.ui.input=snacks', vim.ui.input == Snacks.input.input or tostring(vim.ui.input):find('snacks', 1, true) ~= nil)
check('vim.ui.select=snacks', vim.ui.select == Snacks.picker.select)

-- 4. Picker entry points exist.
check('Snacks.picker.colorschemes', type(Snacks.picker.colorschemes) == 'function')
check('Snacks.picker.files', type(Snacks.picker.files) == 'function')

-- 5. Format/lint tables wired.
check('conform stylua', vim.tbl_contains(require('conform').formatters_by_ft.lua or {}, 'stylua'))
check('conform oxfmt', vim.tbl_contains(require('conform').formatters_by_ft.javascript or {}, 'oxfmt'))
check('lint selene', vim.tbl_contains((require 'lint').linters_by_ft.lua or {}, 'selene'))
check('lint oxlint', vim.tbl_contains((require 'lint').linters_by_ft.javascript or {}, 'oxlint'))

-- 6. Mason binaries executable.
for _, tool in ipairs { 'stylua', 'selene', 'shellcheck', 'actionlint', 'oxlint', 'oxfmt', 'lua-language-server' } do
  check('bin ' .. tool, vim.fn.executable(vim.fn.stdpath 'data' .. '/mason/bin/' .. tool) == 1)
end

-- 7. DAP adapters registered.
local dap_ok, dap = pcall(require, 'dap')
check('dap local-lua adapter', dap_ok and dap.adapters['local-lua'] ~= nil)
check('dap lua config', dap_ok and dap.configurations.lua ~= nil)

-- 8. Treesitter base parsers present.
for _, lang in ipairs { 'lua', 'vim', 'bash', 'markdown', 'python' } do
  check('parser ' .. lang, vim.tbl_contains(require('nvim-treesitter').get_installed 'parsers', lang))
end

-- 9. Leader maps from every module present.
for _, lhs in ipairs {
  '<leader>uC',
  '<leader>e',
  '<leader>ff',
  '<leader>gg',
  '<leader>cf',
  '<leader>cl',
  '<leader>cC',
  '<leader>or',
  '<leader>db',
  '<leader>tt',
  '<leader>qs',
  '<leader>pP',
} do
  check('map ' .. lhs, vim.fn.maparg(lhs, 'n') ~= '')
end

-- 10. Every configured server is installed (mason) or on PATH (system).
do
  local lsp_ok, lsp_mod = pcall(require, 'plugins.lsp')
  if lsp_ok then
    local to_package = require('mason-lspconfig').get_mappings().lspconfig_to_package
    local registry = require 'mason-registry'
    for name in pairs(lsp_mod.servers) do
      local pkg = to_package[name] or name
      local ok_pkg, package = pcall(registry.get_package, pkg)
      local installed = ok_pkg and package:is_installed()
      local dashed = pkg:gsub('_', '-')
      local on_path = vim.fn.executable(name) == 1 or vim.fn.executable(dashed) == 1
      check('server ' .. name, installed or on_path)
    end
  else
    check('lsp servers exposed', false)
  end
end

-- 11. Every configured formatter/linter resolves to a binary.
do
  local bin_alias = { ruff_format = 'ruff', zigfmt = 'zig', cmake_format = 'cmake-format', golangcilint = 'golangci-lint', cmakelint = 'cmake-lint' }
  local function have_bin(name)
    local bin = bin_alias[name] or name
    return vim.fn.executable(vim.fn.stdpath 'data' .. '/mason/bin/' .. bin) == 1 or vim.fn.executable(bin) == 1
  end
  for _, formatters in pairs(require('conform').formatters_by_ft) do
    for _, f in ipairs(formatters) do
      if type(f) == 'string' then check('formatter ' .. f, have_bin(f)) end
    end
  end
  for _, linters in pairs((require 'lint').linters_by_ft) do
    for _, l in ipairs(linters) do
      check('linter ' .. l, have_bin(l))
    end
  end
end

print(failures == 0 and 'ALL GREEN' or (failures .. ' FAILURES'))
