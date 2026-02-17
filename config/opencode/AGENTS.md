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

## Commits
- Small, single-concern, Conventional Commits

## Commands
- `/architect`, `/plan`, `/review`, `/commit`, `/docs`, `/orchestrate`

*Last updated: 2026-02-17*
