# Java

## Defaults

- Follow local formatter, checkstyle, build, and framework conventions.
- Keep classes cohesive and responsibilities clear.
- Prefer explicit domain names.
- Avoid inheritance unless the hierarchy is stable and useful.
- Prefer composition for varying behavior.
- Validate external data at boundaries.
- Keep null handling explicit.
- Do not introduce frameworks or patterns without local precedent or real pressure.

## Comments

- Use `//` for implementation intent.
- Use Javadoc, `/** ... */`, for public and protected APIs where contracts matter.
- Avoid block comments for ordinary implementation notes.
- Prefer clear names and types over comments that explain simple control flow.
- Follow `../comments/comments.md` for shared comment quality, freshness, markers, TODOs, links, placement, and tone.

## APIs

- Keep public APIs small.
- Preserve compatibility unless a breaking change is approved.
- Use immutable values where practical.
- Avoid global mutable state.

## Errors

- Use checked or unchecked exceptions according to local convention.
- Do not catch broad exceptions without useful handling.
- Add context without leaking sensitive data.

## Checks

Use local commands first:

```bash
mvn test
mvn verify
gradle test
./gradlew test
```

## Sources

- Google Java Style Guide when the repo has no stronger convention.
- Repo formatter and build config.
