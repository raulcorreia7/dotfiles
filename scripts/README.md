# scripts/

Legacy compatibility loader.

## Status

This directory exists for backward compatibility. New code should use
`init.sh` as the single entrypoint.

## Files

- `index.sh` - Alternative entrypoint (deprecated, use `init.sh`)
- `lint.sh` - Shell script linter utility

## Migration

If you're sourcing `scripts/index.sh`, migrate to:

```bash
source "$HOME/.dotfiles/init.sh"
```

## When to Use

Generally, you should not need this directory. Use `init.sh` instead.
