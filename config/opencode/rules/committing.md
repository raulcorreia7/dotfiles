# Commit Rules

## Format
`type(scope): imperative description`

Scope is preferred but optional for trivial/single-file changes.

## Types
`feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`

## Scopes (Preferred)
Use scope to indicate where the change applies.

Examples:
- Module, component, or feature name (e.g., `auth`, `api`, `ui`)
- Layer or directory (e.g., `core`, `cli`, `config`)
- File or area for small changes (e.g., `readme`, `deps`)

## Message Guidelines
- Imperative mood
- No trailing period in subject
- Subject <= 50 chars
- Body lines <= 72 chars
- Body explains why, not what

## Granularity
- One logical change per commit
- Include tests with code changes
- Keep refactors separate from features
- Keep config changes separate from logic

## Context & History
- Respect existing commit style if healthy and consistent
- Match scope naming and type usage from project history
- Group related commits by feature in logical sequence

## Amend vs New Commit
- Amend only for immediate fixups of the last commit
- Use a new commit for any new logical unit of work

## Breaking Changes
- Use `BREAKING CHANGE:` footer
- Include migration notes
