# Language Map

Shared language references for implementation, review, refactor, and test workflows.

Use the matching language reference only when the selected skill needs language-specific guidance. This keeps normal skill instructions small and follows Codex progressive disclosure: load shared references only when needed.

## Routing

| Language | Reference | Notes |
|---|---|---|
| TypeScript / JavaScript | `typescript.md` | App/frontend/backend TS and JS. |
| C# / .NET | `csharp.md` | C#, ASP.NET, libraries, services, tests. |
| Python | `python.md` | Application code, libraries, tools that are not shell-style scripts. |
| Go | `go.md` | Go services, CLIs, libraries. |
| Java | `java.md` | Java services, libraries, Android only if repo conventions agree. |
| Rust | `rust.md` | Rust crates, services, CLIs, libraries. |

## Rules

- Repo conventions win over this reference.
- Formatter and linter config win over prose.
- Use the local package manager and test runner.
- Do not rewrite code into another language's style.
- Do not apply object-oriented patterns where the language idiom is simpler.
- Do not add language-specific ceremony unless it improves clarity, safety, or local consistency.
