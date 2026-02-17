# AGENTS.md — Personal Workflow

## Philosophy
- Readability > Maintainability > Performance
- Proper formatting and indentation are required, not optional
- Code must be a pleasure to read and review
- Keep code intuitive and obvious: the next reader should grasp it instantly
- If it feels complex, simplify
- Craftsmanship over cleverness: deliberate, minimal, maintainable

## Workflow
- Plan -> Build -> Verify
- Plan for architecture/risky/multi-file work; skip for trivial fixes
- Verify: tests, lint, and build pass with no new warnings

## AI Collaboration
- Tone: direct and professional
- Evidence: cite files/logs or mark `Unverified`
- AI drives boilerplate, patterns, and research
- I drive architecture, complex logic, security, and perf-critical work
- Prompt with context (`@file`), acceptance criteria, and examples

## Principles
- Abstract on 3rd repetition
- Fail fast with contextual errors
- Keep side effects at boundaries
- Ship tests with behavior changes
- Best judgment, no hardcoding

## Tools
- Prefer `rg`, `fd`, `bat`, `sd`, `fzf`
- Fallbacks: `grep -r`, `find`, `sed`, `cat`, `awk`

## Bulk Operations
- Prefer modern tools if available: `rg` over `grep`, `fd` over `find`, `sd` over `sed`
- Dry-run destructive operations first (`sd --preview`, `git diff`)
- Scope tightly: one logical change per command; split complex operations
- Verify count before applying (`rg -c`, `fd | wc -l`, `grep -c`)
- Ensure undo path: version control, backups, or reversible commands

### Examples

**Search & Replace**
```bash
# Modern
sd 'foo' 'bar' **/*.ts --preview
sd 'const (\w+) =' 'let $1 =' src/ -p

# Traditional
sed -i 's/foo/bar/g' **/*.ts
find . -name "*.ts" -exec sed -i 's/foo/bar/g' {} +
```

**Find & Act**
```bash
# Modern
fd -e log -x rm
fd -e js -x prettier --write
rg -c "TODO" --type js

# Traditional
find . -name "*.log" -delete
find . -name "*.js" -exec prettier --write {} +
grep -r "TODO" --include="*.js" | wc -l
```

**Rename Files**
```bash
# Modern
fd -e test -e js | sd '\.test\.js' '.spec.js' | xargs -I {} mv {} {}

# Traditional
find . -name "*.test.js" | sed 's/\.test\.js$/.spec.js/' | xargs -I {} mv {} {}
```

## Commits
- Small, single-concern, Conventional Commits

## Commands
- `/architect`, `/plan`, `/review`, `/commit`, `/docs`, `/orchestrate`

*Last updated: 2026-02-17*
