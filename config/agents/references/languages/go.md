# Go

## Defaults

- Write Go in Go's idioms, not translated Java, C#, or TypeScript.
- Keep code simple, explicit, and boring.
- Use `gofmt`.
- Prefer small interfaces defined by consumers.
- Return errors explicitly.
- Add context to errors without hiding the original cause.
- Avoid package-level mutable state.
- Avoid unnecessary frameworks.
- Prefer standard library first.
- Keep goroutine ownership and cancellation clear.

## Comments

- Use `//` comments.
- Document exported packages, types, functions, methods, and constants when required by linting or API clarity.
- Start exported symbol comments with the symbol name.
- Keep implementation comments focused on invariants, concurrency, ownership, cancellation, and compatibility constraints.
- Follow `../comments/comments.md` for shared comment quality, freshness, markers, TODOs, links, placement, and tone.

## Packages

- Package names should be short, clear, and meaningful.
- Avoid utility dumping grounds.
- Keep exported API small.
- Document exported names when required by local linting.

## Errors and Concurrency

- Check errors.
- Do not ignore cancellation.
- Pass `context.Context` where request lifetime matters.
- Avoid sleeps for synchronization in tests.

## Checks

Use local commands first:

```bash
go test ./...
go test -race ./...
go vet ./...
gofmt -w .
```

## Sources

- Effective Go.
- Google Go Style Guide when local convention needs more detail.
