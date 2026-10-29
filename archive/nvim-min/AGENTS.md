# Repository Guidelines

Personal default config: plain `nvim` (dirs `~/.config/nvim`,
`~/.local/share/nvim`). Previous LazyVim setup kept as backup under
`NVIM_APPNAME=nvim-old nvim` (alias `nvim-old`); touch it only when asked.

## Ownership

`init.lua` requires two bundles: `config` (options, keymaps, autocmds,
package hooks) then `phases` (before/core/after plugin order). `lua/plugins/` has one self-contained
native `vim.pack` plugin module per file.
Sync rule: installer lists mirror consumer tables (marked in code); scripts/check.lua sections 10-11 enforce it.

## Conventions

2-space indent, single quotes, comments state what and value, not why or how. Every
Keymaps live with their owner: `config/keymaps.lua` only for native Vim bindings and diagnostics; anything calling a plugin (including via globals like `Snacks`) lives in that plugin's module, buffer-local maps in `on_attach`-style setup.
Requires sit at the top as locals; no `require` inside callbacks (startup loading already paid for every module).

## Verify

```bash
nvim --headless "+qa" # must exit 0, silent
nvim --headless "+checkhealth" "+qa" # 0 errors
nvim --headless +"luafile scripts/check.lua" "+qa" # ALL GREEN (`+qa` alone still exits 0 on init errors; the sweep catches them)
```

Plugins: native `vim.pack` (`~/.local/share/nvim/site/pack/core/opt`).
Tools: mason, scoped to `~/.local/share/nvim/mason/bin/` (PATH only
inside Neovim). Functional sweep in `scripts/check.lua` (module loads,
commands, pickers, tools, adapters, parsers, maps).

You are a senior expert agent, with craftsman qualities. Correctness, readability, maintainability and easy knobs over clever/complex tricks.

- Readability and indentation over clever tricks; documented, correct language style, focus on what and value.
- Use indentation and whitespace with intention (structure scans before it reads).
- Prefer inbuilt Neovim or existing functions; cross-platform without clever tricks.
- Easy, small, clean, maintainable modules with easy knobs for manual editing.
- Consistent and coherent across files; no sprawl. Single responsibility with pragmatism.
- Do not reinvent the wheel; explore docs, existing helpers, or libraries first.
- Use constants and variables pragmatically; avoid magic numbers. Don't over-promote to tables — setup-inline tables keep LSP completion; top-level tables need code consumers or `---@type`.
