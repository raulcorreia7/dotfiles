# Work Plan: Add Multi-Distro Linux Support

## TL;DR

Add Ubuntu/Debian installer to complement existing Arch support. Enable `install-linux` entrypoint that detects distro and dispatches to appropriate installer.

**Deliverables:**
- New `installers/install-debian.sh` for Ubuntu/Debian
- New `packages/debian/` with apt package lists
- Refactored `install` script with distro detection
- New `install-linux` convenience script
- Updated documentation

**Estimated Effort:** Medium (2-3 hours)
**Parallel Execution:** Partial - package lists can be created in parallel
**Critical Path:** Research packages → Create installer → Update main script → Test

---

## Context

### Current State
The installation system only supports Arch Linux on Linux:
```bash
# From install script
case "$os" in
  linux)
    # ONLY runs install-arch.sh
    "$INSTALL_DIR/install-arch.sh"
```

This breaks on Ubuntu, Debian, Fedora, etc.

### Problem
1. **Hardcoded Arch-only** - No flexibility for other distros
2. **Poor error handling** - Just says "unsupported OS"
3. **No clear path for users** - They have to manually figure out packages
4. **False advertising** - README says "Linux" but means "Arch"

### Solution
1. Add `installers/install-debian.sh` for Ubuntu/Debian
2. Add distro detection in main `install` script
3. Create `packages/debian/` with apt package lists
4. Add `install-linux` convenience script that auto-detects

---

## Work Objectives

### Core Objective
Enable dotfiles installation on Ubuntu/Debian systems with automatic distro detection.

### Concrete Deliverables
1. `installers/install-debian.sh` - Debian/Ubuntu package installer
2. `packages/debian/apt` - Main package list
3. `packages/debian/optional` - Optional packages
4. Updated `install` script with distro detection
5. New `install-linux` convenience script
6. Updated README with Linux compatibility info

### Definition of Done
- [ ] `install` works on Ubuntu 22.04/24.04
- [ ] `install` works on Debian 12
- [ ] `install-linux` auto-detects distro
- [ ] Package lists are reasonable (not too many, not too few)
- [ ] Documentation updated

### Must Have
- Core tools: git, curl, wget, fzf, fd-find, ripgrep, bat, eza
- Dev tools: neovim, git-delta, lazygit
- Terminal: ghostty or alacritty
- Package installer that handles apt

### Must NOT Have (Guardrails)
- NO support for every Linux distro (start with Debian/Ubuntu)
- NO GUI app installation (focus on CLI/dev tools)
- NO external repositories unless necessary (keep it simple)
- NO breaking changes to Arch support

---

## Verification Strategy

### Test Infrastructure
No automated tests. Use Docker for verification.

### Manual QA Procedures

**Test 1: Ubuntu Installation**
```bash
# Run in Ubuntu Docker container
docker run -it --rm -v $(pwd):/dotfiles ubuntu:24.04 bash

# Inside container
apt-get update && apt-get install -y git sudo
/dotfiles/install

# Expected: Detects Ubuntu, runs install-debian.sh, installs packages
```

**Test 2: Debian Installation**
```bash
# Run in Debian Docker container
docker run -it --rm -v $(pwd):/dotfiles debian:12 bash

# Inside container
apt-get update && apt-get install -y git sudo
/dotfiles/install

# Expected: Detects Debian, runs install-debian.sh
```

**Test 3: Distro Detection**
```bash
# On any Linux system
./install-linux --dry-run

# Expected: Prints detected distro and would-run command
```

**Test 4: Arch Still Works**
```bash
# On Arch system (or container)
./install

# Expected: Still works exactly as before
```

**Test 5: Unknown Distro Handling**
```bash
# Simulate unknown distro
./install

# Expected: Helpful error message with instructions
```

---

## Execution Strategy

### Parallel Execution

**Wave 1 (Can start immediately):**
- Task 1: Research Debian packages
- Task 2: Create package lists

**Wave 2 (After Wave 1):**
- Task 3: Create install-debian.sh

**Wave 3 (After Wave 2):**
- Task 4: Update main install script
- Task 5: Create install-linux helper

**Wave 4 (Final):**
- Task 6: Update documentation
- Task 7: Test all scenarios

---

## TODOs

- [ ] 1. Research Debian Package Names

  **What to do**:
  - Map Arch packages to Debian equivalents
  - Identify packages with different names (e.g., fd → fd-find)
  - Note any missing equivalents
  - Check Ubuntu vs Debian differences

  **Key Mappings to Research:**
  - Arch `fd` → Debian `fd-find` (binary is `fdfind`)
  - Arch `bat` → Debian `bat` (may need testing)
  - Arch `eza` → Debian `eza` (check availability)
  - Arch `ripgrep` → Debian `ripgrep`
  - Arch `fzf` → Debian `fzf`
  - Arch `zoxide` → May need cargo install
  - Arch `ghostty` → Not in repos, use alacritty

  **Recommended Agent Profile**:
  - **Category**: `unspecified-low` (research task)
  - **Skills**: `git-master` (for researching package lists)

  **Parallelization**: YES - Wave 1

  **References**:
  - `packages/arch/pacman` - Arch package list to map from
  - https://packages.ubuntu.com/ - Ubuntu package search
  - https://packages.debian.org/ - Debian package search

  **Acceptance Criteria**:
  - [ ] All core Arch packages mapped to Debian equivalents
  - [ ] Noted which packages need alternative install methods
  - [ ] Documented name differences (fd vs fd-find)

  **Commit**: NO (research phase)

- [ ] 2. Create Debian Package Lists

  **What to do**:
  - Create `packages/debian/apt` - main packages
  - Create `packages/debian/optional` - nice-to-have extras
  - Follow same format as Arch (one per line, comments with #)
  - Include core tools, dev tools, terminal

  **Example structure:**
  ```
  # Core
  git
  curl
  wget
  fzf
  ripgrep

  # Tools with different names
  fd-find  # Arch: fd
  bat      # May be batcat in Debian

  # Dev
  neovim
  git-delta
  ```

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: None

  **Parallelization**: YES - Wave 1 (can do with Task 1)

  **References**:
  - `packages/arch/pacman` - Template format
  - Task 1 findings - Package mappings

  **Acceptance Criteria**:
  - [ ] `packages/debian/apt` created with ~30-50 packages
  - [ ] `packages/debian/optional` created
  - [ ] Format matches Arch lists (one per line)
  - [ ] Comments explain any unusual mappings

  **Manual Verification**:
  ```bash
  cat packages/debian/apt | wc -l
  # Verify: Reasonable count (30-50 lines)

  cat packages/debian/apt | grep -E '^[a-z]'
  # Verify: Valid package names
  ```

  **Commit**: YES
  - Message: `feat(packages): add Debian/Ubuntu package lists`
  - Files: `packages/debian/apt`, `packages/debian/optional`

- [ ] 3. Create `installers/install-debian.sh`

  **What to do**:
  - Create new installer script for Debian/Ubuntu
  - Model after `installers/install-arch.sh`
  - Use `apt-get` instead of `pacman`
  - Handle package name differences (fd-find → fd symlink)
  - Support `DOTFILES_DEBIAN_ASSUME_YES` flag

  **Key Requirements:**
  - Check for sudo access
  - Update apt cache
  - Install packages from `packages/debian/apt`
  - Handle tools not in repos (zoxide via cargo, ghostty skip)
  - Idempotent (safe to run multiple times)

  **Recommended Agent Profile**:
  - **Category**: `unspecified-high` (complex script)
  - **Skills**: `git-master` (for shell scripting)

  **Parallelization**: NO - Wave 2 (depends on Task 2)

  **References**:
  - `installers/install-arch.sh` - Template structure
  - `installers/lib.sh` - Shared helpers
  - `packages/debian/apt` - Package list to read

  **Acceptance Criteria**:
  - [ ] Script created and executable
  - [ ] Uses apt-get for package installation
  - [ ] Reads from `packages/debian/apt`
  - [ ] Handles fd-find → fd naming
  - [ ] Has `--dry-run` or similar testing mode
  - [ ] Good error messages

  **Manual Verification**:
  ```bash
  # Syntax check
  bash -n installers/install-debian.sh
  # Verify: No syntax errors

  # Dry run test (if implemented)
  ./installers/install-debian.sh --dry-run
  # Verify: Shows what it would do
  ```

  **Commit**: YES
  - Message: `feat(installers): add Debian/Ubuntu installer`
  - Files: `installers/install-debian.sh`

- [ ] 4. Update Main `install` Script

  **What to do**:
  - Add distro detection logic
  - Modify Linux case to dispatch to correct installer
  - Detect: Arch, Debian, Ubuntu, Unknown
  - Keep backward compatibility with Arch

  **Detection Logic:**
  ```bash
  detect_distro() {
    if [ -f /etc/arch-release ] || [ -f /etc/cachyos-release ]; then
      echo "arch"
    elif [ -f /etc/debian_version ]; then
      echo "debian"
    else
      echo "unknown"
    fi
  }
  ```

  **Update install script:**
  ```bash
  linux)
    distro=$(detect_distro)
    case "$distro" in
      arch)
        "$INSTALL_DIR/install-arch.sh"
        ;;
      debian)
        "$INSTALL_DIR/install-debian.sh"
        ;;
      *)
        log "error: unsupported Linux distro"
        log "Supported: Arch, Debian, Ubuntu"
        exit 1
        ;;
    esac
    ;;
  ```

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: None

  **Parallelization**: NO - Wave 3 (depends on Task 3)

  **References**:
  - `install` - Current install script
  - `installers/install-arch.sh:211-222` - Arch detection example

  **Acceptance Criteria**:
  - [ ] `install` detects distro correctly
  - [ ] Arch path unchanged (no regression)
  - [ ] Debian/Ubuntu path added
  - [ ] Clear error for unsupported distros

  **Manual Verification**:
  ```bash
  # Test detection (on your system)
  . installers/lib.sh  # for helper functions
  detect_distro
  # Verify: Shows your distro

  # Test full script (dry run if possible)
  ./install
  # Verify: Detects Arch, runs install-arch.sh
  ```

  **Commit**: YES
  - Message: `feat(install): add Linux distro detection`
  - Files: `install`

- [ ] 5. Create `install-linux` Convenience Script

  **What to do**:
  - Create new entrypoint script `install-linux`
  - Thin wrapper around `./install` for Linux
  - Could add Linux-specific flags
  - Provides clear entrypoint for Linux users

  **Alternative:** Just update documentation to clarify `./install` works on Linux.
  This task is optional if Task 4 is sufficient.

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: None

  **Parallelization**: NO - Wave 3 (can do with Task 4)

  **Acceptance Criteria**:
  - [ ] `install-linux` created (optional)
  - [ ] Or: Documentation updated to show `./install` usage

  **Commit**: YES (if implemented)
  - Message: `feat: add install-linux convenience script`
  - Files: `install-linux`

- [ ] 6. Update Documentation

  **What to do**:
  - Update README "Install" section
  - List supported Linux distros
  - Add note about package differences
  - Update "Layout" mindmap if needed

  **Key Updates:**
  - README should say: "Arch, Debian, Ubuntu" not just "Linux"
  - Document any manual steps for non-repo packages
  - Add troubleshooting section for distros

  **Recommended Agent Profile**:
  - **Category**: `writing`
  - **Skills**: None

  **Parallelization**: NO - Wave 4

  **References**:
  - `readme.md` - Current docs

  **Acceptance Criteria**:
  - [ ] README lists supported distros
  - [ ] Installation instructions clear
  - [ ] Package differences noted

  **Manual Verification**:
  ```bash
  grep -i "debian\|ubuntu\|arch" readme.md
  # Verify: All mentioned
  ```

  **Commit**: YES
  - Message: `docs: add Debian/Ubuntu installation instructions`
  - Files: `readme.md`

- [ ] 7. Test on Docker

  **What to do**:
  - Test on Ubuntu 24.04 container
  - Test on Debian 12 container
  - Verify Arch still works
  - Document any issues

  **Test Commands:**
  ```bash
  # Ubuntu
  docker run -it --rm -v $(pwd):/dotfiles ubuntu:24.04 bash
  apt-get update && apt-get install -y git sudo
  /dotfiles/install

  # Debian
  docker run -it --rm -v $(pwd):/dotfiles debian:12 bash
  apt-get update && apt-get install -y git sudo
  /dotfiles/install
  ```

  **Recommended Agent Profile**:
  - **Category**: `quick`
  - **Skills**: None

  **Parallelization**: NO - Wave 4

  **Acceptance Criteria**:
  - [ ] Ubuntu 24.04: Install succeeds
  - [ ] Debian 12: Install succeeds
  - [ ] Arch: Still works (no regression)
  - [ ] Issues documented

  **Commit**: NO (testing only)

---

## Commit Strategy

| After Task | Message | Files |
|------------|---------|-------|
| 2 | `feat(packages): add Debian/Ubuntu package lists` | `packages/debian/*` |
| 3 | `feat(installers): add Debian/Ubuntu installer` | `installers/install-debian.sh` |
| 4 | `feat(install): add Linux distro detection` | `install` |
| 5 | `feat: add install-linux convenience script` | `install-linux` (optional) |
| 6 | `docs: add Debian/Ubuntu installation instructions` | `readme.md` |

---

## Success Criteria

### Verification Commands
```bash
# 1. Detection works
./install --detect-only  # If implemented, or check output

# 2. Debian installer exists
ls installers/install-debian.sh

# 3. Package lists exist
ls packages/debian/

# 4. Docker tests pass
docker run -it --rm -v $(pwd):/dotfiles ubuntu:24.04 /dotfiles/install

# 5. No Arch regression
./install  # On Arch system
```

### Final Checklist
- [ ] `install-debian.sh` created and executable
- [ ] Debian package lists created
- [ ] Distro detection added to main `install`
- [ ] Arch support still works
- [ ] Documentation updated
- [ ] Docker tests pass for Ubuntu
- [ ] Docker tests pass for Debian

---

## Risk Mitigation

| Risk | Mitigation |
|------|------------|
| Break Arch support | Test thoroughly on Arch before merging |
| Package name confusion | Document differences clearly |
| Missing packages | Start with core tools, add more later |
| Docker not available | Test on VM or wait for user feedback |

## Rollback Plan

If issues arise:
1. Restore original `install` script from git
2. Remove new files: `install-debian.sh`, `packages/debian/`
3. Arch users unaffected

Always test on a branch before merging to main.
