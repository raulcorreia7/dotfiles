-- Save-time linting; linters below auto-install via mason-nvim-lint.
local gh = require('config.pack').gh

vim.pack.add({ gh 'mfussenegger/nvim-lint' }, { confirm = false })

local lint = require 'lint'
lint.linters_by_ft = {
  lua = { 'selene' },
  sh = { 'shellcheck' },
  bash = { 'shellcheck' },
  zsh = { 'shellcheck' },
  javascript = { 'oxlint' },
  javascriptreact = { 'oxlint' },
  typescript = { 'oxlint' },
  typescriptreact = { 'oxlint' },
  python = { 'ruff' },
  go = { 'golangcilint' },
  dockerfile = { 'hadolint' },
  cmake = { 'cmakelint' },
}

-- Installs every linter in linters_by_ft that Mason provides.
-- Deferred: mason-core lands on rtp with plugins/lsp.lua's file-event setup,
-- registered earlier via phases.lua ordering.
vim.api.nvim_create_autocmd({ 'BufReadPre', 'BufNewFile' }, {
  once = true,
  group = vim.api.nvim_create_augroup('nvim-lint-installer', { clear = true }),
  callback = function()
    vim.pack.add({ gh 'rshkarin/mason-nvim-lint' }, { confirm = false })
    require('mason-nvim-lint').setup {}
  end,
})

local function lint_buffer()
  if vim.bo.buftype ~= '' then return end

  lint.try_lint()
  local name = vim.fs.normalize(vim.api.nvim_buf_get_name(0))
  if name:match '/%.github/workflows/.-%.ya?ml$' then lint.try_lint 'actionlint' end
end

vim.api.nvim_create_autocmd('BufWritePost', {
  desc = 'lint saved file',
  group = vim.api.nvim_create_augroup('nvim-min-lint', { clear = true }),
  callback = lint_buffer,
})
vim.keymap.set('n', '<leader>cl', lint_buffer, { desc = 'lint' })
