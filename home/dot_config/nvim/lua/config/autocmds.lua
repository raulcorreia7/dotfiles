-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- LazyVim wraps text/plaintex/typst/gitcommit/markdown; keep spell, drop wrap
vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("wrap_spell", { clear = true }),
  pattern = { "text", "plaintex", "typst", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.spell = true
  end,
})

-- `nvim <dir>` is handed to the snacks explorer, which opens a picker but
-- leaves the process cwd at the launch directory. Adopt the directory so the
-- terminal (<c-/>), pickers, and `:!` work where the editor was opened.
-- NOTE: only a single directory argument; opening files keeps the launch cwd.
vim.api.nvim_create_autocmd("VimEnter", {
  group = vim.api.nvim_create_augroup("adopt_dir_arg", { clear = true }),
  once = true,
  callback = function()
    local dir = vim.fn.argv(0)
    if vim.fn.argc() == 1 and vim.fn.isdirectory(dir) == 1 then
      vim.fn.chdir(vim.fn.fnamemodify(dir, ":p"))
    end
  end,
})
