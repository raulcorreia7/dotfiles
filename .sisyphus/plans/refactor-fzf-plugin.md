# Work Plan: Refactor FZF Plugin

## TL;DR

Extract the 806-line `config/plugins/fzf/init.sh` into a standalone CLI tool `bin/fzfs` with reduced complexity. Target: ~200 lines for core plugin, 300 lines for standalone tool.

**Deliverables:**
- New `bin/fzfs` executable (standalone CLI)
- Simplified `config/plugins/fzf/init.sh` (~50 lines)
- Remove `config/plugins/fzf/callbacks.sh` and `config/plugins/fzf/bindings.sh`
- Updated aliases and documentation

**Estimated Effort:** Medium (2-3 hours)
**Parallel Execution:** NO - sequential refactoring
**Critical Path:** Extract core → Create standalone → Simplify plugin → Test

---

## Context

### Current State
The fzf plugin has grown into a complex application:
- `config/plugins/fzf/init.sh`: 806 lines
- `config/plugins/fzf/callbacks.sh`: ~300 lines (preview engine)
- `config/plugins/fzf/bindings.sh`: 359 lines
- **Total: ~1,465 lines for fuzzy finding**

Features: 12 modes (files, dirs, all, search, git_all, git-files, status, staged, git-dirs, branches, commits, projects, recent)

### Problem
1. **Too complex for dotfiles** - This is a standalone tool's worth of code
2. **Hard to maintain** - 800+ lines of shell script with complex callback system
3. **Over-featured** - Most users use 2-3 modes, not all 12
4. **Embedded in config** - Doesn't belong in shell initialization

### Solution
Extract to standalone `bin/fzfs` CLI tool with:
- Core modes only: files, dirs, git
- Simple argument parsing (no complex callback system)
- Proper CLI interface (`fzfs --files`, `fzfs --git`)
- Reduced to essential functionality

---

## Work Objectives

### Core Objective
Extract fzf functionality into a standalone, maintainable CLI tool while preserving essential fuzzy-finding capabilities.

### Concrete Deliverables
1. `bin/fzfs` - New standalone executable (POSIX sh)
2. Simplified `config/plugins/fzf/init.sh` - Just loads fzf shell integration
3. Remove `config/plugins/fzf/callbacks.sh`
4. Remove `config/plugins/fzf/bindings.sh`
5. Update `config/aliases` - Remove dead fzfs alias
6. Update README - Document new fzfs tool

### Definition of Done
- [ ] `bin/fzfs` works standalone: `fzfs --files`, `fzfs --dirs`, `fzfs --git`
- [ ] Plugin loads without errors: `source config/plugins/fzf/init.sh`
- [ ] All old functionality has replacement in new tool
- [ ] No regressions in shell startup time
- [ ] Documentation updated

### Must Have
- File fuzzy finding (`fzfs --files` or `fzfs -f`)
- Directory fuzzy finding (`fzfs --dirs` or `fzfs -d`)
- Git file finding (`fzfs --git` or `fzfs -g`)
- Preview support (using bat/cat)
- Keybindings: Ctrl-E (edit), Ctrl-O (cd), Ctrl-P (preview)

### Must NOT Have (Guardrails)
- NO 12-mode complexity - max 4 modes
- NO internal callback system (`--internal-*` flags)
- NO self-calling script pattern
- NO 4000+ line preview engine
- NO complex ANSI color formatting
- NO projects mode (can be added later if needed)

---

## Verification Strategy

### Test Infrastructure
No test framework currently exists. Will use manual verification.

### Manual QA Procedures

**Test 1: Standalone Tool Works**
```bash
# Command to run
chmod +x bin/fzfs
./bin/fzfs --help

# Expected output
Usage: fzfs [OPTIONS] [PATH]
Options:
  -f, --files     Fuzzy find files
  -d, --dirs      Fuzzy find directories  
  -g, --git       Fuzzy find git files
  -h, --help      Show help

# Verify: Shows clean help output
```

**Test 2: File Finding**
```bash
# Command to run
cd ~/.dotfiles
./bin/fzfs --files

# Expected behavior
# - Opens fzf with file list
# - Preview pane shows file content
# - Ctrl-E opens selected in $EDITOR
# - Returns selected file path on stdout
```

**Test 3: Directory Finding**
```bash
# Command to run
./bin/fzfs --dirs

# Expected behavior
# - Opens fzf with directory list
# - Ctrl-O changes to that directory
# - Returns selected directory on stdout
```

**Test 4: Git Integration**
```bash
# Command to run
cd ~/.dotfiles
./bin/fzfs --git

# Expected behavior
# - Opens fzf with git-tracked files
# - Works in any git repository
```

**Test 5: Plugin Loads**
```bash
# Command to run
DOTFILES_ENABLE_FZF=1 bash -c 'source config/plugins/fzf/init.sh && echo "OK"'

# Expected output
OK

# Verify: No errors, clean load
```

**Test 6: Shell Startup**
```bash
# Command to run
time bash -c 'source init.sh && exit'

# Expected: Startup time < 500ms
# Verify: No significant slowdown
```

---

## Execution Strategy

### Sequential Steps (No Parallelism)

All tasks must complete in order - each builds on the previous.

**Critical Path:**
```
Task 1 (Design) → Task 2 (Extract) → Task 3 (Simplify) → Task 4 (Test) → Task 5 (Cleanup)
```

---

## TODOs

- [ ] 1. Design New FZFS Interface

  **What to do**:
  - Define new CLI interface for `bin/fzfs`
  - Decide on 3-4 core modes only
  - Plan simplified preview logic
  - Remove internal callback system

  **Must NOT do**:
  - Don't keep all 12 modes
  - Don't use `--internal-*` flags
  - Don't make it a sourced script

  **Recommended Agent Profile**:
  - **Category**: `quick` (design task, minimal coding)
  - **Skills**: None needed for design phase

  **Parallelization**: NO - first task

  **References**:
  - `config/plugins/fzf/init.sh` - Current implementation to learn from
  - `config/plugins/fzf/callbacks.sh` - Preview logic to simplify
  - https://github.com/junegunn/fzf - Official fzf docs for best practices

  **Acceptance Criteria**:
  - [ ] CLI interface documented in comments
  - [ ] List of 3-4 modes decided
  - [ ] Preview strategy planned (bat → cat fallback)
  - [ ] Ready to implement

  **Commit**: NO (design phase)

- [ ] 2. Create Standalone `bin/fzfs` Tool

  **What to do**:
  - Create new `bin/fzfs` executable
  - Implement core modes: files, dirs, git
  - Add simple preview (bat or cat)
  - Add keybindings (Ctrl-E, Ctrl-O, Ctrl-P)
  - Add help text
  - Target: ~200-300 lines total

  **Must NOT do**:
  - Don't exceed 300 lines
  - Don't use complex callback system
  - Don't support all 12 old modes
  - Don't embed in shell config

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high` (significant scripting work)
  - **Skills**: `git-master` (for shell scripting patterns)

  **Parallelization**: NO - depends on Task 1

  **References**:
  - `config/plugins/fzf/init.sh:710-802` - Argument parsing pattern
  - `config/plugins/fzf/init.sh:242-291` - File generation with fd/find fallback
  - `config/plugins/fzf/init.sh:308-317` - Git file generation
  - `config/plugins/fzf/callbacks.sh` - Preview logic to simplify

  **Acceptance Criteria**:
  - [ ] `bin/fzfs` exists and is executable
  - [ ] `bin/fzfs --help` works
  - [ ] `bin/fzfs --files` opens fzf with files
  - [ ] `bin/fzfs --dirs` opens fzf with directories
  - [ ] `bin/fzfs --git` opens fzf with git files
  - [ ] Preview works with bat or cat fallback
  - [ ] Ctrl-E opens editor
  - [ ] Ctrl-O changes directory
  - [ ] Ctrl-P toggles preview

  **Manual Verification**:
  ```bash
  chmod +x bin/fzfs
  ./bin/fzfs --help
  # Verify: Shows usage information
  
  ./bin/fzfs --files
  # Verify: Opens fzf, can select file
  
  ./bin/fzfs --dirs
  # Verify: Opens fzf, can select directory
  
  ./bin/fzfs --git
  # Verify: Works in git repo
  ```

  **Commit**: YES
  - Message: `feat(bin): add standalone fzfs fuzzy finder tool`
  - Files: `bin/fzfs`

- [ ] 3. Simplify FZF Plugin

  **What to do**:
  - Replace `config/plugins/fzf/init.sh` with minimal version
  - New version: ~50 lines
  - Just load fzf shell integration (keybindings, completions)
  - Remove all the complex fzfs function
  - Keep env var defaults (FZFS_OPTS_UI, etc.)

  **Must NOT do**:
  - Don't keep the 806-line fzfs function
  - Don't source callbacks.sh or bindings.sh
  - Don't duplicate standalone tool logic

  **Recommended Agent Profile**:
  - **Category**: `quick` (mostly deletion)
  - **Skills**: None

  **Parallelization**: NO - depends on Task 2

  **References**:
  - `config/plugins/fzf/init.sh:1-50` - Keep the tool detection and env vars
  - `/usr/share/fzf/shell-integration` - Example fzf integration

  **Acceptance Criteria**:
  - [ ] New `init.sh` is < 100 lines
  - [ ] Loads fzf keybindings if available
  - [ ] Sets FZFS_* env vars
  - [ ] No fzfs function (now in bin/)
  - [ ] No sourcing of callbacks/bindings

  **Manual Verification**:
  ```bash
  bash -c 'source config/plugins/fzf/init.sh && echo "OK"'
  # Verify: Loads without errors
  
  wc -l config/plugins/fzf/init.sh
  # Verify: < 100 lines
  ```

  **Commit**: YES
  - Message: `refactor(plugins): simplify fzf plugin to integration only`
  - Files: `config/plugins/fzf/init.sh`

- [ ] 4. Remove Obsolete Files

  **What to do**:
  - Delete `config/plugins/fzf/callbacks.sh`
  - Delete `config/plugins/fzf/bindings.sh`

  **Must NOT do**:
  - Don't keep old files "just in case"
  - Don't move to backup (git has history)

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: None

  **Parallelization**: NO - depends on Task 3

  **Acceptance Criteria**:
  - [ ] `config/plugins/fzf/callbacks.sh` deleted
  - [ ] `config/plugins/fzf/bindings.sh` deleted
  - [ ] Only `config/plugins/fzf/init.sh` remains

  **Manual Verification**:
  ```bash
  ls config/plugins/fzf/
  # Verify: Only init.sh exists
  ```

  **Commit**: YES
  - Message: `chore(plugins): remove obsolete fzf callback and binding files`
  - Files: `config/plugins/fzf/callbacks.sh`, `config/plugins/fzf/bindings.sh`

- [ ] 5. Update Aliases

  **What to do**:
  - Remove commented `#alias fzfs='fzf_snacks'` from `config/aliases`
  - Add alias: `alias ff='fzfs --files'`
  - Add alias: `alias fd='fzfs --dirs'`
  - Add alias: `alias fg='fzfs --git'`

  **Must NOT do**:
  - Don't keep dead code
  - Don't create conflicting aliases

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: None

  **Parallelization**: NO - can do anytime after Task 2

  **References**:
  - `config/aliases` - Current aliases file

  **Acceptance Criteria**:
  - [ ] Dead alias removed
  - [ ] New shortcuts added
  - [ ] No conflicts with existing aliases

  **Manual Verification**:
  ```bash
  grep -E '^(alias|#alias).*fzfs' config/aliases
  # Verify: No results (dead code removed)
  
  grep 'fzfs' config/aliases
  # Verify: Shows new ff, fd, fg aliases
  ```

  **Commit**: YES
  - Message: `feat(aliases): add fzfs shortcuts (ff, fd, fg)`
  - Files: `config/aliases`

- [ ] 6. Update Documentation

  **What to do**:
  - Update README.md "Knobs" section - remove FZFS_* vars if not needed
  - Update README.md to mention `bin/fzfs` tool
  - Add brief fzfs usage to README

  **Must NOT do**:
  - Don't document removed features
  - Don't over-document (keep it simple)

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: None

  **Parallelization**: NO - final task

  **References**:
  - `readme.md` - Current documentation

  **Acceptance Criteria**:
  - [ ] README mentions `bin/fzfs`
  - [ ] Basic usage examples included
  - [ ] Outdated references removed

  **Manual Verification**:
  ```bash
  grep -A2 'fzfs' readme.md
  # Verify: Shows usage information
  ```

  **Commit**: YES (or combine with Task 5)
  - Message: `docs: update README with fzfs tool documentation`
  - Files: `readme.md`

- [ ] 7. Final Integration Test

  **What to do**:
  - Test full flow: install → source → use tool
  - Verify no broken references
  - Check shell startup time

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: None

  **Parallelization**: NO - final verification

  **Acceptance Criteria**:
  - [ ] `./install` completes without errors
  - [ ] `source init.sh` works
  - [ ] `fzfs --help` works
  - [ ] All three modes work
  - [ ] Shell startup < 500ms

  **Manual Verification**:
  ```bash
  # Full integration test
  ./install
  # Verify: Completes successfully
  
  source init.sh
  # Verify: No errors
  
  time bash -c 'source init.sh'
  # Verify: < 500ms
  
  which fzfs
  # Verify: Shows ~/.local/bin/fzfs
  
  fzfs --files
  # Verify: Opens fzf
  ```

  **Commit**: NO (testing only)

---

## Commit Strategy

| After Task | Message | Files |
|------------|---------|-------|
| 2 | `feat(bin): add standalone fzfs fuzzy finder tool` | `bin/fzfs` |
| 3 | `refactor(plugins): simplify fzf plugin to integration only` | `config/plugins/fzf/init.sh` |
| 4 | `chore(plugins): remove obsolete fzf callback and binding files` | `config/plugins/fzf/callbacks.sh`, `config/plugins/fzf/bindings.sh` |
| 5 | `feat(aliases): add fzfs shortcuts (ff, fd, fg)` | `config/aliases` |
| 6 | `docs: update README with fzfs tool documentation` | `readme.md` |

---

## Success Criteria

### Verification Commands
```bash
# 1. Tool exists and works
bin/fzfs --help

# 2. Plugin loads cleanly
bash -c 'source config/plugins/fzf/init.sh && echo OK'

# 3. Startup time acceptable
time bash -c 'source init.sh'

# 4. Aliases work
source init.sh
alias ff  # Should show fzfs --files

# 5. Line count reduced
wc -l config/plugins/fzf/*.sh  # Should be < 100 total
```

### Final Checklist
- [ ] `bin/fzfs` exists and is executable
- [ ] Core modes work (files, dirs, git)
- [ ] Old files deleted (callbacks.sh, bindings.sh)
- [ ] Plugin simplified (< 100 lines)
- [ ] Dead code removed from aliases
- [ ] Documentation updated
- [ ] No startup time regression
- [ ] All tests pass

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Break existing workflow | Keep old plugin until new tool verified |
| Missing functionality | Implement 3 core modes first, add more later |
| Complexity creeps back | Enforce 300-line limit on bin/fzfs |
| Shell integration breaks | Test thoroughly, have rollback ready |

## Rollback Plan

If issues arise:
1. Restore old `config/plugins/fzf/init.sh` from git
2. Remove `bin/fzfs`
3. User keeps old workflow unchanged

Git history preserves everything - no data loss risk.
