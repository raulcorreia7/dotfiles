# Dotfiles Migration Plan

## Overview

Transform the dotfiles repository into a production-grade, multi-platform configuration system with improved performance, safety, and maintainability.

## Philosophy

- **Goldilocks approach**: Balanced and pragmatic - not over-engineered, not too simple
- **Soft targets for performance**: Goals are aspirational, not hard requirements
- **Maintainability over optimization**: Code should be easy to understand and modify
- **Safe, reversible changes**: Each phase can be rolled back if needed
- **No breaking changes**: Existing user configs continue to work

## Performance Targets (Soft)

| Target | Time | Improvement | Priority |
|--------|------|-------------|----------|
| Baseline | ~127ms | - | Current state |
| Acceptable | <80ms | 40% | **Must achieve** |
| Aspirational | <50ms | 60% | Nice to have |

**Note**: These are soft targets. The primary goal is significant improvement without adding complexity. If we hit <80ms, we succeed. <50ms is a bonus.

## Directory Structure

```
.dotfiles/
├── README.md              # Main entry point
├── init.sh                # Shell entry point
├── install                # Main installer
│
├── before/                # Early setup (first to load)
│   ├── env.sh            # Environment variables
│   └── paths.sh          # Path definitions
│
├── lib/                   # Core libraries
│   ├── init.sh           # Main loader
│   ├── loader.sh         # Plugin loading system
│   ├── utils.sh          # Helper functions
│   ├── health.sh         # Health check functions
│   └── install/          # Install helpers
│       ├── lib.sh
│       ├── link.sh
│       ├── unlink.sh
│       └── post-install.sh
│
├── modules/               # Feature modules (lazy-loaded)
│   ├── mise/             # Runtime version manager
│   ├── fzf/              # Fuzzy finder
│   ├── zoxide/           # Smart cd
│   ├── zimfw/            # Zsh module manager
│   ├── tmux/             # Terminal multiplexer
│   └── arch/             # Arch Linux helpers
│
├── os/                    # Platform-specific
│   ├── arch.sh           # Arch Linux
│   ├── macos.sh          # macOS
│   ├── wsl.sh            # WSL detection/helpers
│   ├── windows.ps1       # Windows PowerShell
│   └── install/          # Platform installers
│       ├── arch.sh
│       └── macos.sh
│
├── after/                 # Late loading (last)
│   ├── aliases.sh        # Shell aliases
│   └── local.sh          # Machine-specific (gitignored)
│
├── config/                # XDG-linked app configs
│   ├── nvim/
│   ├── tmux/
│   ├── alacritty/
│   └── ...
│
├── bin/                   # Public scripts → ~/.local/bin/
│   └── rdotfiles
│
├── scripts/               # Internal/dev tools
│   ├── lint.sh
│   ├── format.sh
│   └── benchmark.sh
│
└── docs/                  # Documentation
    ├── AGENTS.md         # Development contract
    ├── TROUBLESHOOTING.md
    ├── ARCHITECTURE.md
    └── PLATFORMS.md
```

**Load Order**: `before/` → `lib/` → `modules/` (lazy) → `os/` → `after/`

## Migration Phases

### Phase 0: Pre-Migration Safety Setup

**Goal**: Create safety net before any changes

**Tasks**:
1. Create git backup branch: `migration-backup-$(date +%Y%m%d)`
2. Create validation script (`scripts/validate.sh`)
3. Record baseline metrics (startup time, health check)
4. Create file inventory

**Exit Criteria**:
- [ ] Backup branch exists
- [ ] Validation script runs successfully
- [ ] Baseline metrics recorded
- [ ] File inventory created

---

### Phase 1: Critical Safety Fixes

**Goal**: Fix shell safety issues without changing structure

**Tasks** (parallel):
1. Fix unquoted variables in `config/shell/core.sh`
2. Fix unquoted variables in `init.sh`
3. Fix unquoted variables in `installers/link.sh`
4. Fix unquoted variables in `bin/rdotfiles`
5. Add re-entrancy guard to `config/shell/core.sh`
6. Add `set -euo pipefail` to executables

**Exit Criteria**:
- [ ] All shell files pass `sh -n` syntax check
- [ ] Validation script passes
- [ ] Shellcheck passes (if available)
- [ ] Startup time unchanged (±10ms)

---

### Phase 2: Performance Optimization (Soft Targets)

**Goal**: Implement lazy loading for significant startup improvement

**Tasks** (sequential):
1. **Mise lazy loading** (high impact: 40-45ms savings)
   - Remove immediate activation
   - Implement deferred loading with precmd hook
   - **Priority**: HIGH (biggest win)

2. **Remove zim-mise module** from `.zimrc`
   - Prevents double-loading
   - **Priority**: HIGH (required for #1)

3. **FZF deferred loading** (medium: 3-5ms savings)
   - Implement precmd hook
   - **Priority**: MEDIUM (nice to have)

4. **Zoxide lazy loading** (low: 3ms savings)
   - Wrap in function
   - **Priority**: LOW (optional)

5. **Create benchmark script** (`scripts/benchmark.sh`)
   - Measure startup time
   - Profile with zprof

**Exit Criteria**:
- [ ] Startup time <80ms (acceptable target)
- [ ] <50ms achieved (aspirational) or documented why not
- [ ] All tools functional after lazy loading
- [ ] Validation script passes

**Note**: If lazy loading adds significant complexity, document and skip. The goal is maintainable code.

---

### Phase 3: Platform Support

**Goal**: Add WSL detection and better Linux distro handling

**Tasks** (parallel):
1. Add WSL detection to `lib/utils.sh`
2. Update `install` script for distro detection
3. Create OS-specific helpers:
   - `os/wsl.sh` - WSL detection and Windows interop
   - `os/linux.sh` - Linux base with distro detection (Arch/Ubuntu/Debian)
4. Update Arch plugin with better guards

**Exit Criteria**:
- [ ] `is_wsl` function works
- [ ] Install script shows correct distro
- [ ] Non-Arch Linux shows helpful message
- [ ] Validation script passes

---

### Phase 4: Directory Structure Migration

**Goal**: Create new directory structure and migrate files

**Tasks** (sequential with parallel sub-tasks):
1. Create new directory structure
2. Migrate `before/` files (env, paths)
3. Migrate `lib/` files (core, loader, utils, health)
4. Migrate `modules/` files (all 6 plugins)
5. Migrate `os/` files (platform-specific)
6. Migrate `lib/install/` helpers
7. Migrate `after/` files (aliases)
8. Remove old empty directories

**Exit Criteria**:
- [ ] All files in new locations
- [ ] Old directories removed
- [ ] Only app configs remain in `config/`
- [ ] Validation script passes

---

### Phase 5: Path Updates

**Goal**: Update all internal path references

**Tasks** (parallel):
1. Update `init.sh` paths
2. Update `lib/loader.sh` paths
3. Update `before/paths.sh`
4. Update `bin/rdotfiles` paths
5. Update `lib/install/link.sh` paths
6. Update all module source paths
7. Update `install` script paths

**Exit Criteria**:
- [ ] All path references updated
- [ ] No references to old paths (except docs)
- [ ] Validation script passes
- [ ] Startup time still <80ms

---

### Phase 6: Documentation Consolidation

**Goal**: Move and update documentation

**Tasks** (parallel):
1. Create docs structure
2. Migrate `AGENTS.md` to `docs/development/`
3. Create `docs/TROUBLESHOOTING.md`
4. Create `docs/ARCHITECTURE.md`
5. Create `docs/PLATFORMS.md`
6. Update root `README.md`

**Exit Criteria**:
- [ ] All docs in `docs/` directory
- [ ] README.md updated
- [ ] No broken links

---

### Phase 7: Final Verification

**Goal**: Complete system validation

**Tasks** (sequential):
1. Full syntax check on all files
2. Full validation run
3. Startup time benchmark
4. Link/unlink test
5. Health check
6. Cross-platform dry run
7. Git status check
8. Create migration summary

**Exit Criteria**:
- [ ] All syntax checks pass
- [ ] Validation script passes
- [ ] Startup time improved (target: <80ms)
- [ ] `rdotfiles health` passes
- [ ] All symlinks working
- [ ] Git status clean
- [ ] Migration documented

---

## Parallel Execution Strategy

**Can run in parallel**:
- Phase 1: All 6 safety fix tasks
- Phase 3: All 4 platform tasks
- Phase 5: All 7 path update tasks
- Phase 6: All 6 documentation tasks

**Must run sequentially**:
- Phase 0 → Phase 1 → Phase 2 → Phase 4 → Phase 5 → Phase 7
- Phase 4 sub-tasks have internal ordering

**Subagent allocation**:
- Phase 1: 6 parallel subagents
- Phase 2: 1 subagent (sequential)
- Phase 3: 4 parallel subagents
- Phase 4: 1 subagent with parallel sub-tasks
- Phase 5: 7 parallel subagents
- Phase 6: 6 parallel subagents
- Phase 7: 1 subagent

---

## Verification Template

Each task must produce:

```markdown
## Task X.Y: <Name>

### Changes Made
- <specific changes>

### Verification Results
- [ ] Syntax check: `sh -n <file>` passes
- [ ] Functional test: <specific test>
- [ ] Regression test: <baseline comparison>
- [ ] Documentation updated: Y/N

### Evidence
<command output>

### Sign-off
- Verified by: <name>
- Date: <timestamp>
- Status: PASS / FAIL
```

---

## Rollback Strategy

Each phase has rollback procedures:
- **Git rollback**: `git checkout <file>` or `git reset --hard`
- **Backup restoration**: Restore from `.baseline/` or backup branch
- **Symlink repair**: `rdotfiles fix --link`

**Emergency rollback**:
```bash
git checkout migration-backup-$(date +%Y%m%d)
./installers/link.sh  # or lib/install/link.sh after migration
```

---

## Success Criteria

### Must Have (Hard Requirements)
- [ ] All safety issues fixed (unquoted variables)
- [ ] Startup time <80ms (soft target achieved)
- [ ] All functionality preserved
- [ ] No breaking changes to user configs
- [ ] Documentation complete

### Nice to Have (Soft Targets)
- [ ] Startup time <50ms (aspirational target)
- [ ] All lazy loading implemented
- [ ] Full platform support (Linux, macOS, Windows, WSL)

### Won't Do (Out of Scope)
- [ ] New features beyond restructuring
- [ ] Changes to app configs (nvim, tmux, etc.)
- [ ] Complex optimizations that hurt maintainability

---

## Timeline Estimate

| Phase | Tasks | Estimated Time | Parallel Speedup |
|-------|-------|----------------|------------------|
| 0 | 4 | 30 min | N/A |
| 1 | 6 | 1 hour | 10 min |
| 2 | 5 | 1.5 hours | N/A |
| 3 | 4 | 1 hour | 20 min |
| 4 | 8 | 2 hours | 30 min |
| 5 | 7 | 1.5 hours | 15 min |
| 6 | 6 | 2 hours | 30 min |
| 7 | 8 | 1 hour | N/A |
| **Total** | **48** | **~10 hours** | **~3 hours** |

**With parallel execution**: ~3-4 hours of wall-clock time

---

## Notes

- This is a living document - update as needed during implementation
- Soft targets mean we prioritize maintainability over hitting exact numbers
- When in doubt, choose the simpler solution
- Each phase must be fully verified before proceeding
- Document any deviations from this plan
