# Work Plan: General Dotfiles Cleanup

## TL;DR

Clean up dead code, fix empty directories, and improve documentation. Quick wins for maintainability.

**Deliverables:**
- Remove dead code from `config/aliases`
- Document or populate `bin/` directory
- Clarify status of `scripts/` directory
- Add package management documentation
- General polish

**Estimated Effort:** Low (1 hour)
**Parallel Execution:** YES - all tasks are independent
**Critical Path:** None - all tasks can run in parallel

---

## Context

### Current State
Several minor issues identified in review:
1. **Dead code**: Commented alias in `config/aliases`
2. **Empty directory**: `bin/` is empty but documented
3. **Unclear status**: `scripts/` called "legacy" but present
4. **Missing docs**: Package format not documented

### Problem
These are small issues that add friction and confusion. Easy to fix.

### Solution
Quick cleanup tasks that can be done independently.

---

## Work Objectives

### Core Objective
Clean up minor issues and improve documentation clarity.

### Concrete Deliverables
1. Clean `config/aliases` - remove dead code
2. Add `bin/README.md` or example scripts
3. Add `scripts/README.md` explaining status
4. Add `packages/README.md` documenting format
5. Minor README improvements

### Definition of Done
- [ ] No commented-out code in aliases
- [ ] `bin/` has clear purpose documented
- [ ] `scripts/` status clarified
- [ ] Package format documented

### Must NOT Have (Guardrails)
- NO breaking changes
- NO removing working code
- NO major refactoring

---

## Verification Strategy

### Manual QA

**Test 1: Aliases Clean**
```bash
grep -E '^#alias' config/aliases
# Expected: No output (no dead code)
```

**Test 2: bin/ Documented**
```bash
cat bin/README.md
# Expected: Explains purpose, maybe lists example scripts
```

**Test 3: Scripts Status Clear**
```bash
cat scripts/README.md
# Expected: Explains why it exists, when to use
```

**Test 4: Packages Documented**
```bash
cat packages/README.md
# Expected: Format explanation, how to add packages
```

---

## Execution Strategy

### Parallel Execution

ALL tasks can run in parallel - no dependencies.

**Wave 1 (All tasks):**
- Task 1: Clean aliases
- Task 2: Document bin/
- Task 3: Document scripts/
- Task 4: Document packages/
- Task 5: README improvements

---

## TODOs

- [ ] 1. Clean Dead Code from Aliases

  **What to do**:
  - Remove commented line: `#alias fzfs='fzf_snacks'`
  - Check for any other dead code
  - Verify remaining aliases work

  **Current state:**
  ```bash
  # Line 15 in config/aliases
  #alias fzfs='fzf_snacks'
  ```

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: None

  **Parallelization**: YES - independent

  **References**:
  - `config/aliases` - File to edit

  **Acceptance Criteria**:
  - [ ] Commented alias removed
  - [ ] No other dead code found
  - [ ] File still works

  **Manual Verification**:
  ```bash
  grep -c '^#alias' config/aliases
  # Verify: Output is 0
  ```

  **Commit**: YES
  - Message: `chore(aliases): remove dead code`
  - Files: `config/aliases`

- [ ] 2. Document `bin/` Directory

  **What to do**:
  - Create `bin/README.md` explaining:
    - Purpose of bin/ directory
    - How scripts get linked to `~/.local/bin`
    - Maybe add 1-2 example scripts

  **Option A: Add README only**
  ```markdown
  # bin/

  Userland scripts that get symlinked to `~/.local/bin/`.

  Add your custom scripts here. They will be available in your PATH
  after running `installers/link.sh`.

  ## Example

  ```bash
  #!/bin/sh
  # my-script: does something useful
  echo "Hello from my script!"
  ```
  ```

  **Option B: Add example script**
  Create `bin/hello` as a working example.

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: None

  **Parallelization**: YES - independent

  **References**:
  - `installers/link.sh:56-61` - How bin/ gets linked
  - `readme.md:38` - Current bin/ documentation

  **Acceptance Criteria**:
  - [ ] `bin/README.md` created
  - [ ] Purpose clearly explained
  - [ ] Optional: Example script added

  **Manual Verification**:
  ```bash
  ls bin/
  # Verify: Shows README.md (and maybe example)
  ```

  **Commit**: YES
  - Message: `docs(bin): add README explaining purpose`
  - Files: `bin/README.md`, maybe `bin/hello`

- [ ] 3. Clarify `scripts/` Status

  **What to do**:
  - Create `scripts/README.md` explaining:
    - Why it exists (legacy compatibility)
    - When to use it (if ever)
    - Relationship to `init.sh`

  **Content:**
  ```markdown
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
  ```

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: None

  **Parallelization**: YES - independent

  **References**:
  - `scripts/index.sh` - Current content
  - `readme.md:37` - "legacy loader (compat)" note

  **Acceptance Criteria**:
  - [ ] `scripts/README.md` created
  - [ ] Status clearly explained
  - [ ] Migration path documented

  **Manual Verification**:
  ```bash
  cat scripts/README.md
  # Verify: Clear explanation
  ```

  **Commit**: YES
  - Message: `docs(scripts): clarify legacy status`
  - Files: `scripts/README.md`

- [ ] 4. Document Package Format

  **What to do**:
  - Create `packages/README.md` explaining:
    - Package file format (one per line, comments with #)
    - How to add/remove packages
    - OS-specific structure
    - How packages are parsed

  **Content:**
  ```markdown
  # packages/

  Package lists for automated installation.

  ## Format

  One package per line. Comments start with `#`:

  ```
  # Core utilities
  git
  curl
  wget

  # Search tools
  fzf
  fd
  ripgrep
  ```

  ## Structure

  ```
  packages/
  ├── arch/
  │   ├── pacman     # Official repository packages
  │   └── aur        # AUR packages
  ├── debian/
  │   ├── apt        # APT packages
  │   └── optional   # Nice-to-have extras
  └── macos/
      ├── base
      ├── cli
      ├── development
      └── gui
  ```

  ## Adding Packages

  1. Edit the appropriate file for your OS
  2. One package per line
  3. Use comments to organize by category
  4. Run the installer to apply

  ## How It Works

  Installers read these files using `lib.sh:read_packages()`:
  - Filters out comments and blank lines
  - Sorts and deduplicates
  - Compares with installed packages
  - Installs only missing packages
  ```

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: None

  **Parallelization**: YES - independent

  **References**:
  - `installers/lib.sh:41-45` - read_packages function
  - `packages/arch/pacman` - Example format

  **Acceptance Criteria**:
  - [ ] `packages/README.md` created
  - [ ] Format explained clearly
  - [ ] Directory structure documented
  - [ ] How to add packages explained

  **Manual Verification**:
  ```bash
  cat packages/README.md
  # Verify: Clear documentation
  ```

  **Commit**: YES
  - Message: `docs(packages): document package list format`
  - Files: `packages/README.md`

- [ ] 5. Minor README Improvements

  **What to do**:
  - Check for any outdated info
  - Add link to new documentation
  - Maybe add "Quick Tips" section
  - Ensure all environment variables documented

  **Quick checks:**
  - [ ] All 11 knobs documented in README?
  - [ ] Installation flow accurate?
  - [ ] Mindmaps match reality?

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: None

  **Parallelization**: YES - independent

  **References**:
  - `readme.md` - Current documentation

  **Acceptance Criteria**:
  - [ ] No outdated information
  - [ ] Links to new docs added
  - [ ] Consistent with changes from other tasks

  **Manual Verification**:
  ```bash
  # Read through README
  cat readme.md
  ```

  **Commit**: YES (can combine with other doc commits)
  - Message: `docs: minor README improvements`
  - Files: `readme.md`

---

## Commit Strategy

| After Task | Message | Files |
|------------|---------|-------|
| 1 | `chore(aliases): remove dead code` | `config/aliases` |
| 2 | `docs(bin): add README explaining purpose` | `bin/README.md` |
| 3 | `docs(scripts): clarify legacy status` | `scripts/README.md` |
| 4 | `docs(packages): document package list format` | `packages/README.md` |
| 5 | `docs: minor README improvements` | `readme.md` |

---

## Success Criteria

### Verification Commands
```bash
# 1. No dead code
grep -c '^#alias' config/aliases  # Should be 0

# 2. bin/ documented
ls bin/README.md  # Should exist

# 3. scripts/ documented
ls scripts/README.md  # Should exist

# 4. packages documented
ls packages/README.md  # Should exist
```

### Final Checklist
- [ ] Dead code removed from aliases
- [ ] bin/ has README
- [ ] scripts/ has README
- [ ] packages/ has README
- [ ] README updated if needed

---

## Notes

This plan is designed for quick wins. All tasks are:
- Low risk
- Independent
- Easy to verify
- Non-breaking

Can be done in any order, or even skipped if not desired.
