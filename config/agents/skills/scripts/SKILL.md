---
name: scripts
description: "Use when creating, editing, debugging, or explaining repository scripts and developer automation: Bash, PowerShell, Python, TypeScript/Node, zx, .NET, CLI helpers, maintenance tasks, and repeatable commands. Do not use for application feature code unless automation is the entrypoint."
---

# Scripts

## Job

Create repeatable, predictable, safe, maintainable developer automation.

## Steps

1. Clarify the automation job when the requested operation, scope, inputs, or write behavior is not concrete enough to choose a runner safely.
2. Identify runner, contract, dependencies, inputs, outputs, side effects, exit codes, environment, and failure modes.
3. Inspect existing scripts, package manifests, lockfiles, tooling config, and dependencies before adding new code or packages.
4. Reuse mature existing dependencies and standard-library capabilities when they remove real parsing, CLI, filesystem, globbing, schema, or process-management complexity.
5. Follow repo conventions for language, path, naming, logging, args, package manager, and script location.
6. Keep defaults deterministic and safe.
7. Add dry-run/check/preview for destructive or broad changes when practical.
8. Route data to stdout/success stream and diagnostics to stderr/diagnostic streams.
9. Validate help, invalid args, harmless mode, and one representative success path when practical.
10. Comment hidden automation intent: side-effect boundaries, ordering constraints, environment assumptions, destructive gates, cleanup, idempotency, and non-obvious stream behavior.

## Runner Selection

- Prefer the repo's existing language and script conventions.
- For TypeScript/Node projects, consider `zx` when the script mainly orchestrates shell commands, package-manager tasks, filesystem operations, or cross-platform command flow and typed JS/TS improves maintainability.
- Keep plain Node/TypeScript when application logic dominates, shell interpolation is minor, or adding a dependency is not justified.
- Keep Bash or PowerShell for small platform-local glue that already matches repo conventions.
- Before adding `zx`, check package manager, dependency policy, runtime target, lockfile expectations, TypeScript setup, and whether scripts run on Linux, macOS, Windows, CI, or all of them.
- When using `zx`, add it through the repo package manager, add supporting dev dependencies only when justified, expose invocation through `package.json` or the existing CLI convention, keep stdout/stderr semantics explicit, and document shell assumptions such as Bash versus PowerShell.

## Pipeline Preference

For complex scripts, prefer a typed task pipeline:

1. Parse input.
2. Run cheap validation.
3. Load context.
4. Plan changes.
5. Preview or dry-run.
6. Execute.
7. Verify.
8. Render output.
9. Cleanup.

Each stage should have a clear input, output, error contract, and side-effect boundary.

## Output

- Path and invocation
- Inputs/outputs
- Exit behavior
- Verification
- Destructive behavior gates
- Environment/config assumptions
- Skipped checks

## Guardrails

- Never print secrets or write credentials to logs, generated files, or shell history.
- Avoid hidden global state, hardcoded paths, broad overwrite/delete, and unnecessary dependencies.
- Keep output, comments, function names, and control flow clear enough for a teammate to maintain.
- Prefer battle-tested core utilities and tools over custom implementations.

## References

- Read `../../references/comments/comments.md`, then `references/comments.md`, when script comments need calibration.
- Read `../../references/languages/typescript.md` for TypeScript, JavaScript, Node, or `zx` scripts where type/runtime guidance matters.
- Read `references/zx.md` for TypeScript/Node automation that uses or evaluates `zx`.
- Read `references/cli.md` for substantial scripts or public CLI helpers.
- Read `references/pipeline.md` for complex multi-stage scripts, generators, migrations, codemods, or broad automation.
- For `zx` setup, runtime, TypeScript, and shell details, use <https://google.github.io/zx/setup>.
