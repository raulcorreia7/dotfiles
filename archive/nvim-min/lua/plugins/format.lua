-- Formatting through conform.nvim.
local gh = require('config.pack').gh

-- Milliseconds to wait for format on save.
local format_timeout_ms = 500

do
  vim.pack.add({ gh 'stevearc/conform.nvim' }, { confirm = false })
  --- Format on save unless disabled globally (`<leader>uF`) or for the buffer (`<leader>uf`).
  ---@param bufnr integer buffer number
  ---@return table|nil conform format options
  local function format_on_save(bufnr)
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
    return { timeout_ms = format_timeout_ms }
  end
  local conform = require 'conform'
  conform.setup {
    notify_on_error = false,
    format_on_save = format_on_save,
    default_format_opts = {
      -- External formatters first, LSP fallback.
      lsp_format = 'fallback',
    },
    -- External formatters per filetype (LSP formats as fallback).
    -- Mirror additions in the mason-tool-installer list in plugins/lsp.lua.
    formatters_by_ft = {
      lua = { 'stylua' },
      go = { 'gofumpt' },
      sh = { 'shfmt' },
      python = { 'ruff_format' },
      rust = { 'rustfmt' }, -- system rustup binary
      c = { 'clang-format' },
      cpp = { 'clang-format' },
      cmake = { 'cmake_format' },
      zig = { 'zigfmt' }, -- system zig toolchain
      javascript = { 'oxfmt' },
      javascriptreact = { 'oxfmt' },
      typescript = { 'oxfmt' },
      typescriptreact = { 'oxfmt' },
      json = { 'oxfmt' },
      jsonc = { 'oxfmt' },
      yaml = { 'prettierd' },
      css = { 'prettierd' },
      html = { 'prettierd' },
    },
  }

  vim.keymap.set({ 'n', 'v' }, '<leader>cf', function() conform.format { async = true } end, { desc = 'format' })
  vim.keymap.set(
    { 'n', 'v' },
    '<leader>cF',
    function() conform.format { formatters = { 'injected' }, timeout_ms = 3000 } end,
    { desc = 'format injected langs' }
  )
  vim.keymap.set('n', '<leader>uf', function()
    vim.b.disable_autoformat = not vim.b.disable_autoformat
    vim.notify('Format on save ' .. (vim.b.disable_autoformat and 'off (buffer)' or 'on (global)'), vim.log.levels.INFO)
  end, { desc = 'toggle format on save (buffer)' })
  vim.keymap.set('n', '<leader>uF', function()
    vim.g.disable_autoformat = not vim.g.disable_autoformat
    vim.notify('Format on save ' .. (vim.g.disable_autoformat and 'off (global)' or 'on (global)'), vim.log.levels.INFO)
  end, { desc = 'toggle format on save (global)' })
end
