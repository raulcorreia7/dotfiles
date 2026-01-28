# Dotfiles Architecture

Modular, POSIX-compliant shell configuration framework.

## Overview

**Goals:** Portability, performance, maintainability.

**Principles:**
- **Modular** - Load only what you need
- **Lazy loading** - Defer heavy initialization
- **XDG compliant** - Standard config locations
- **Feature flags** - Enable/disable via environment variables

## Directory Structure

```
.dotfiles/
├── before/          # Early setup (paths, env)
├── lib/             # Core libraries (loader, utils)
├── modules/         # Feature modules (lazy-loaded)
├── os/              # Platform-specific code
├── after/           # Late loading (aliases, local)
├── config/          # XDG app configs
├── bin/             # User scripts
├── scripts/         # Utility scripts
└── init.sh          # Entry point
```

### Directory Purposes

| Directory | Purpose | Files |
|-----------|---------|-------|
| `before/` | Early setup | `paths.sh`, `env.sh` |
| `lib/` | Core libraries | `loader.sh`, `manifest.sh`, `utils.sh`, `health.sh` |
| `modules/` | Feature modules | `*/init.sh` |
| `os/` | Platform code | `helpers/`, `install/` |
| `after/` | Late loading | `aliases.sh`, `local.sh` |
| `config/` | App configs | nvim, tmux, etc. |

## Load Order

1. **init.sh** - Entry point, re-entrancy guard
2. **before/paths.sh** - Centralized path variables
3. **before/env.sh** - Environment setup (optional)
4. **lib/loader.sh** - Plugin loading functions
5. **lib/manifest.sh** - Ordered plugin loading
6. **modules/** - Feature modules (lazy-loaded)
7. **os/** - Platform-specific code
8. **after/aliases.sh** - Aliases
9. **after/local.sh** - Machine overrides (optional)

## Key Files

### init.sh
Entry point with re-entrancy guard:

```sh
[ -n "${__DOTFILES_INIT:-}" ] && return 0
__DOTFILES_INIT=1
```

### lib/loader.sh
Plugin loading with feature flag support:

```sh
__dot_load_plugin() {
  plugin="$1"
  plugin_init="$DOTFILES_MODULES_DIR/$plugin/init.sh"
  
  # Skip if already loaded
  case " $__DOT_PLUGIN_LOADED " in
    *" $plugin "*) return 0 ;;
  esac
  
  # Skip if disabled or missing
  [ -r "$plugin_init" ] || return 0
  __dot_plugin_enabled "$plugin" || return 0
  
  . "$plugin_init"
  __DOT_PLUGIN_LOADED="$__DOT_PLUGIN_LOADED $plugin"
}
```

### lib/manifest.sh
Defines plugin loading order:

```sh
__dot_load_plugin "tmux"
__dot_load_plugin "zimfw"
__dot_load_plugin "mise"
__dot_load_plugin "fzf"
__dot_load_plugin "zoxide"
__dot_load_plugin "arch"
```

### modules/*/init.sh
Self-contained plugin structure:

```sh
#!/bin/sh
# Guard: run once per session
[ -n "${_PLUGIN_RAN:-}" ] && return 0
_PLUGIN_RAN=1

# Check dependencies
__dot_has cmd || return 0

# Implementation
```

## Naming Conventions

### Functions

| Prefix | Usage | Example |
|--------|-------|---------|
| `__dot_*` | Core internal | `__dot_log`, `__dot_debug` |
| `dot_*` | Core public | `dot_reload` |
| `_plugin_*` | Plugin private | `_tmux_autostart` |
| `plugin_*` | Plugin public | `arch_sys_update` |
| `is_*` | Detection | `is_wsl`, `is_arch` |

### Environment Variables

| Pattern | Purpose | Example |
|---------|---------|---------|
| `DOTFILES_*` | Core config | `DOTFILES_DIR` |
| `DOTFILES_ENABLE_*` | Feature flags | `DOTFILES_ENABLE_FZF` |
| `DOTFILES_*_DIR` | Path variables | `DOTFILES_MODULES_DIR` |
| `__DOTFILES_*` | Internal guards | `__DOTFILES_INIT` |

### Feature Flags

Disable plugins via environment:

```sh
export DOTFILES_ENABLE_TMUX=0
export DOTFILES_ENABLE_FZF=0
```

## Lazy Loading

Heavy tools use deferred initialization:

```sh
# Function wrapper pattern
z() {
  unset -f z 2>/dev/null
  eval "$(zoxide init "$(_shell_type)")"
  z "$@"
}

# Precmd hook pattern (zsh)
_fzf_load() {
  precmd_functions=(${precmd_functions:#_fzf_load})
  eval "$(fzf --zsh)"
}
precmd_functions+=(_fzf_load)
```

## Platform Abstraction

Detection functions in `lib/utils.sh`:

```sh
is_wsl()   { [ -f /proc/sys/fs/binfmt_misc/WSLInterop ]; }
is_darwin() { [ "$(uname -s)" = "Darwin" ]; }
is_arch()  { case "$(get_distro)" in arch*) return 0 ;; esac; return 1; }
```

Platform files sourced conditionally in init sequence.

## Performance

| Component | Target |
|-----------|--------|
| init.sh + paths.sh | < 5ms |
| lib/loader.sh | < 2ms |
| Plugins (lazy) | 0ms (deferred) |
| Total cold start | < 10ms |

**Best practices:**
- Use `__VAR_LOADED` guards to prevent duplicate loading
- Defer heavy work with lazy loading
- Minimize subshells, use built-ins
- Check commands with `__dot_has` first

## Adding Components

### New Plugin

```sh
mkdir modules/myplugin
cat > modules/myplugin/init.sh << 'EOF'
#!/bin/sh
[ -n "${_MYPLUGIN_RAN:-}" ] && return 0
_MYPLUGIN_RAN=1

__dot_has mycmd || return 0
# implementation
EOF
```

Add to `lib/manifest.sh`:
```sh
__dot_load_plugin "myplugin"
```

### New Platform

1. Add detection to `lib/utils.sh`
2. Create `os/myplatform.sh`
3. Source conditionally in init sequence
