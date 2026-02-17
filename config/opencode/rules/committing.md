# Commit Rules

## Format
`type(scope): imperative description`

Optional body/footer.

## Types
`feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`

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

## Amend vs New Commit
- Amend only for immediate fixups of the last commit
- Use a new commit for any new logical unit of work

## Breaking Changes
- Use `BREAKING CHANGE:` footer
- Include migration notes
