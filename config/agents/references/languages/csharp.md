# C# / .NET

## Defaults

- Follow existing `.editorconfig`, analyzers, nullable settings, and project conventions.
- Prefer clear domain names and small methods.
- Use nullable reference types correctly when enabled.
- Prefer async all the way for async IO.
- Do not block on async with `.Result` or `.Wait()` unless the repo has a justified pattern.
- Validate inputs at API, command, message, or persistence boundaries.
- Keep business rules testable without unnecessary infrastructure.
- Prefer dependency injection only where the project already uses it or a seam is needed.
- Do not add interfaces for every class.
- Do not catch broad exceptions unless adding useful handling, translation, cleanup, or context.

## Comments

- Use `//` for implementation intent.
- Use XML documentation comments, `///`, for public APIs when required by analyzers, packages, or generated docs.
- Avoid block comments except for durable file-level or generated-code context.
- Prefer clear names and nullable annotations over comments that restate types.
- Follow `../comments/comments.md` for shared comment quality, freshness, markers, TODOs, links, placement, and tone.

## Types

- Use records for immutable data when local style supports them.
- Use enums only for stable closed sets.
- Prefer result/domain types when exceptions are not the right contract.
- Keep DTOs separate from domain concepts when they change for different reasons.

## Errors

- Preserve exception and result contracts.
- Add actionable context.
- Do not log secrets, tokens, connection strings, or PII.

## Checks

Use local commands first:

```bash
dotnet test
dotnet build
dotnet format --verify-no-changes
```

## Sources

- Microsoft C# coding conventions.
- Repo `.editorconfig`, analyzers, and local architecture.
