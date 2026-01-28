# scripts/

Legacy compatibility loader.

## Status

This directory exists for backward compatibility. New code should use
`init.sh` as the single entrypoint.

## Files

- `index.sh` - Alternative entrypoint (deprecated, use `init.sh`)
- `format.sh` - Format all supported files
- `lint.sh` - Lint runner (editorconfig-checker)

## Usage

```bash
./scripts/format.sh
./scripts/format.sh .
./scripts/lint.sh
./scripts/lint.sh .
```

## Exclusions

Exclude paths via `config/paths.sh`:

- `DOTFILES_EXCLUDE_DIRS` (space-separated, relative to repo)
- `DOTFILES_EXCLUDE_FILES` (space-separated, relative to repo)

## Migration

If you're sourcing `scripts/index.sh`, migrate to:

```bash
source "$HOME/.dotfiles/init.sh"
```

## When to Use

Generally, you should not need this directory. Use `init.sh` instead.
