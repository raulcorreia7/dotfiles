# Comprehensive Dotfiles Cleanup Plan

## Executive Summary

Based on critical reviews of naming, composability, loading, and maintainability.

**Current State:** 6/10 - Functional but inconsistent
**Target State:** 8.5/10 - Clean, consistent, maintainable

---

## Phase 1: Naming & Conventions (1-2 hours)

### Task 1.1: Fix TMUX Plugin Prefixes
**Files:** `config/plugins/tmux/init.sh`

**Changes:**
```sh
# BEFORE:
__dot_session_name() { ... }
__dot_tmux_autostart() { ... }

# AFTER:
_tmux_session_name() { ... }
_tmux_autostart() { ... }
```

**Rationale:** `__dot_*` is reserved for core system functions.

---

### Task 1.2: Fix ARCH Plugin Prefixes  
**Files:** `config/plugins/os/arch/init.sh`

**Changes:**
```sh
# BEFORE:
__arch_assume_yes_flag()
arch_pacmanupdate()
arch_paruupdate()
arch_sysupdate()
arch_sysupdatefull()

# AFTER:
_arch_assume_yes_flag()           # Single underscore for private
arch_pacman_update()              # Snake case
arch_paru_update()
arch_sys_update()
arch_sys_update_full()
```

**Update callers in:** `config/aliases`

---

### Task 1.3: Add Shell Type Helper
**Files:** `config/shell/core.sh`

**Add:**
```sh
# Detect shell type for tool initialization
__dot_shell_type() {
  [ -n "${ZSH_VERSION:-}" ] && printf 'zsh' && return
  [ -n "${BASH_VERSION:-}" ] && printf 'bash' && return
  printf 'sh'
}
```

**Then update:** `config/plugins/mise/init.sh`, `config/plugins/zoxide/init.sh`

---

## Phase 2: Composability & Architecture (2-3 hours)

### Task 2.1: Fix __dot_plugin_enabled Eval
**Files:** `config/shell/core.sh`

**Current (problematic):**
```sh
__dot_plugin_enabled() {
  plugin_key=$(__dot_plugin_key "$1")
  eval "enabled=\${DOTFILES_ENABLE_${plugin_key}:-1}"  # Security risk
  [ "$enabled" != "0" ]
}
```

**Improved:**
```sh
__dot_plugin_enabled() {
  _plugin_key=$(__dot_plugin_key "$1")
  # Safer indirect expansion
  _var_name="DOTFILES_ENABLE_${_plugin_key}"
  _enabled=$(eval "printf '%s' \"\${${_var_name}:-1}\"")
  [ "$_enabled" != "0" ]
}
```

---

### Task 2.2: Add Plugin Error Isolation
**Files:** `config/shell/core.sh`

**Add tracking variables and improved loader:**
```sh
# Track loaded plugins (for re-entrancy)
__DOT_PLUGIN_LOADED=""

__dot_load_plugin() {
  _plugin="$1"
  
  # Skip if already loaded
  case " $__DOT_PLUGIN_LOADED " in
    *" $_plugin "*) return 0 ;;
  esac
  
  _plugin_init="$DOTFILES_PLUGINS_DIR/$_plugin/init.sh"
  [ -r "$_plugin_init" ] || return 0
  __dot_plugin_enabled "$_plugin" || return 0
  
  __dot_debug "dotfiles: loading plugin $_plugin"
  
  # Load with basic error isolation
  if ( . "$_plugin_init" ); then
    __DOT_PLUGIN_LOADED="$__DOT_PLUGIN_LOADED $_plugin"
  else
    __dot_log "dotfiles: warning: plugin '$_plugin' failed to load"
  fi
}
```

---

### Task 2.3: Fix TMUX Autostart on Reload
**Files:** `config/plugins/tmux/init.sh`

**Add guard to prevent running on reload:**
```sh
# Only autostart on first shell init, not on reload
[ -z "${__DOTFILES_INIT:-}" ] || return 0

__dot_tmux_autostart
```

---

### Task 2.4: Add Re-entrancy Guard to init.sh
**Files:** `init.sh`

**At top of file:**
```sh
# Guard against double-sourcing
[ -n "${__DOTFILES_INIT:-}" ] && return 0
__DOTFILES_INIT=1
```

---

## Phase 3: Variable Scoping & Globals (1-2 hours)

### Task 3.1: Clean up Global Variable Pollution
**Files:** `config/shell/core.sh`, all plugin init.sh files

**Convention:** All function-local variables in POSIX sh should use:
- `_funcname_varname` for temporary variables (underscore prefix)
- Or just use `local` if we switch to bash

**Audit and fix:**
- `__dot_plugin_enabled`: `plugin_key`, `enabled` → `_plugin_key`, `_enabled`
- `__dot_plugin_key`: cleans up after itself (good)
- Plugin files: check for any temp variables

---

### Task 3.2: Document Environment Variables
**Files:** `config/env`, `readme.md`

**Create complete list of all DOTFILES_* variables:**
```markdown
## Environment Variables

### Core
- `DOTFILES_DIR` - Custom dotfiles path
- `DOTFILES_DEBUG` - Enable debug logging

### Plugin Enable/Disable
- `DOTFILES_ENABLE_FZF`
- `DOTFILES_ENABLE_ZOXIDE`
- `DOTFILES_ENABLE_TMUX`
- `DOTFILES_ENABLE_OS_ARCH`
- `DOTFILES_ENABLE_MISE` (pattern exists)

### Install Options
- `DOTFILES_MISE_INSTALL`
- `DOTFILES_ZIMFW_BUILD`
- `DOTFILES_POST_INSTALL`
- `DOTFILES_ARCH_ASSUME_YES`

### Post-Install Options
- `DOTFILES_POST_INSTALL_ZSH`
- `DOTFILES_POST_INSTALL_PATH`
- `DOTFILES_POST_INSTALL_XDG_DIRS`
- `DOTFILES_POST_INSTALL_GIT`

### Tmux Options
- `DOTFILES_TMUX_AUTOSTART`
- `DOTFILES_TMUX_SESSION`

### FZFS Options (in bin/fzfs)
- `FZFS_PROJECT_ROOTS`
- `FZFS_EXCLUDES`
- `FZFS_SHOW_HIDDEN`
- `FZFS_RELATIVE`
- `FZFS_FRIENDLY`
```

---

## Phase 4: File Organization (3-4 hours)

### Task 4.1: Split bin/fzfs into Modules
**Current:** 328 lines in single file
**Target:** ~50 line main file + modules

**New structure:**
```
bin/fzfs                      # Main entry point (~50 lines)
config/fzfs/                  # Library modules
├── config.sh                 # Configuration defaults
├── utils.sh                  # Utility functions (expand_path, etc.)
├── generators.sh             # File/content generators
├── previews.sh               # Preview functions
└── ui.sh                     # UI functions
```

**Migration steps:**
1. Create `config/fzfs/` directory
2. Extract configuration (lines 8-26)
3. Extract utility functions (lines 37-52)
4. Extract generators (lines 77-131)
5. Extract previews (lines 168-220)
6. Extract UI functions (lines 246-300)
7. Update `bin/fzfs` to source modules

---

### Task 4.2: Consolidate Logging Functions
**Files:** `config/shell/core.sh`, `installers/lib.sh`

**Current state:**
- `core.sh`: `__dot_log()`, `__dot_debug()`
- `lib.sh`: `log()`, `info()`, `error()`
- `lint.sh`: `info()`, `warn()`

**Decision:** Keep separate since they serve different contexts:
- Core logging: for init-time debugging
- Installer logging: for install script output
- Lint logging: for lint script output

**Action:** Just add comments explaining the separation.

---

## Phase 5: Testing & Validation (4-6 hours)

### Task 5.1: Create Test Structure
**New files:**
```
tests/
├── test-runner.sh           # Test harness
├── unit/
│   ├── test_core.sh         # Test core functions
│   └── test_lib.sh          # Test lib functions
└── integration/
    └── test_link.sh         # Test linking behavior
```

**Test runner pattern:**
```sh
#!/bin/sh
# Test runner

PASSED=0
FAILED=0

assert_eq() {
  if [ "$1" = "$2" ]; then
    PASSED=$((PASSED + 1))
    printf '✓ %s\n' "$3"
  else
    FAILED=$((FAILED + 1))
    printf '✗ %s: expected "%s", got "%s"\n' "$3" "$2" "$1"
  fi
}

# Run tests
. ./tests/unit/test_core.sh

printf '\nPassed: %d, Failed: %d\n' "$PASSED" "$FAILED"
[ "$FAILED" -eq 0 ] || exit 1
```

---

### Task 5.2: Add GitHub Actions CI
**New file:** `.github/workflows/test.yml`

```yaml
name: Test
on: [push, pull_request]
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: sudo apt-get install -y shellcheck shfmt
      - run: ./scripts/lint.sh
      - run: shellcheck installers/*.sh scripts/*.sh config/shell/*.sh
  
  test-links:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: ./tests/integration/test_link.sh
```

---

## Phase 6: Documentation (2-3 hours)

### Task 6.1: Add Troubleshooting Section to README
**Add to readme.md:**
```markdown
## Troubleshooting

### Shell not reloading after install
Run: `source ~/.zshrc` (or restart your terminal)

### "command not found: fzfs"
Run: `~/.dotfiles/installers/link.sh` to symlink bin files

### zsh not becoming default
Run: `chsh -s $(which zsh)` and log out/in

### Package install failures
Check: `dot_doctor` to verify tool installation
```

---

### Task 6.2: Add Uninstall Instructions
**Add to readme.md:**
```markdown
## Uninstall

1. Remove shell config line:
   ```sh
   # Edit ~/.zshrc and remove:
   # [ -r "$HOME/.dotfiles/init.sh" ] && . "$HOME/.dotfiles/init.sh"
   ```

2. Remove symlinks:
   ```sh
   rm -rf ~/.config/alacritty ~/.config/nvim ~/.config/tmux
   rm ~/.local/bin/fzfs ~/.local/bin/hello
   ```

3. Optional: Remove dotfiles directory:
   ```sh
   rm -rf ~/.dotfiles
   ```
```

---

## Phase 7: Advanced Improvements (Optional, 4-6 hours)

### Task 7.1: Implement Lazy Loading for Heavy Plugins
**For:** mise, zoxide

**Pattern:**
```sh
# Instead of immediate eval on source
# Create wrapper that initializes on first use

z() {
  unset -f z 2>/dev/null || unfunction z 2>/dev/null
  eval "$(zoxide init $(__dot_shell_type))"
  z "$@"
}
```

---

### Task 7.2: Add Plugin Dependencies
**Allow plugins to declare dependencies:**
```sh
# In plugin init.sh
# DOTFILES_DEPS="plugin1 plugin2"

# In core.sh loader
__dot_load_plugin() {
  # ... check deps file and load first ...
}
```

---

## Implementation Priority

### Week 1 (High Impact, Low Risk)
1. ✅ Fix security issues (DONE)
2. ✅ Fix POSIX violations (DONE)
3. ✅ Simplify FZF plugin (DONE)
4. Fix naming conventions (TMUX, ARCH plugins)
5. Add re-entrancy guards

### Week 2 (Medium Impact)
6. Add error isolation to plugin loader
7. Document all environment variables
8. Split bin/fzfs into modules

### Week 3 (Testing & Polish)
9. Create test structure
10. Add CI/CD
11. Add troubleshooting docs

---

## Success Criteria

- [ ] All function prefixes follow convention (`__dot_*`, `_plugin_*`)
- [ ] No `eval` usage for dynamic variables (or well-validated)
- [ ] Plugin loader has error isolation
- [ ] init.sh is re-entrant
- [ ] bin/fzfs is under 100 lines (with modules)
- [ ] All env vars documented
- [ ] Tests exist and pass
- [ ] CI/CD runs on PRs
