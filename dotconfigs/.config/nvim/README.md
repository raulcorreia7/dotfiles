# nvim

Personal Neovim config on [LazyVim](https://www.lazyvim.org) (stable).
Stowed to `~/.config/nvim`; plugin versions pinned in the committed
`lazy-lock.json`.

## Layout

|Path|Owns|
|---|---|
|`init.lua`|bootstrap into `config.lazy`|
|`lua/config/`|options, keymaps, autocmds (loaded by LazyVim)|
|`lua/plugins/`|per-plugin overrides; `themes.lua` holds all extra colorschemes|
|`lazyvim.json`|enabled LazyVim extras (clangd, fzf, python, …)|

## Deviations from stock LazyVim

- No format on save (`autoformat` off); format explicitly with `<leader>cf`.
- No swap files; undo persistence only.
- `text`/`markdown`/`gitcommit` filetypes get spell, not wrap.
- `nvim <dir>` adopts the directory as cwd (autocmd in
  `lua/config/autocmds.lua`), so terminal, pickers and `:!` start there.
- Theme: `<leader>uC` lists all installed schemes (lazy — they cost nothing
  at startup). The picked one is persisted to `stdpath("data")/theme`
  (machine-local, never committed) and re-applied at startup by
  `lua/plugins/colorscheme.lua`.
- Minimal statusline: mode · branch · path · diagnostics · location.
- Git/diff via Diffview: `<leader>gv` working tree, `<leader>gV` compare
  branch, `<leader>gF` file history, `<leader>gH` repo history.
  `<leader>gB` (gitsigns blame) stays stock.
- `<leader>cJ` splits/joins a block with treesj.

## Maintenance

```vim
:Lazy update        " then commit lazy-lock.json — it pins the first
                    " install on a new machine; never edit it by hand
:LazyExtras         " toggle language/tooling extras
```

clangd comes from the `lang.clangd` extra; do not add a `servers.clangd`
override for plain registration.
