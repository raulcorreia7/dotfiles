# Language Rules (LLM Optimized)

## Purpose
- Single source of language-specific conventions
- Used as an overlay on top of global project rules
- If a rule conflicts, this file wins for language/toolchain details

## Structure
- Keep this file concise and explicit
- Prefer deterministic defaults over optional guidance
- Document exceptions with runtime reason

## TypeScript / JavaScript

### Version and Dependency Policy
- Use latest LTS runtime/tooling for TS projects (Node LTS, current stable TypeScript, maintained ESLint/Prettier stack)
- Prefer latest stable library releases when migration cost is acceptable
- Prefer battle-tested, well-maintained libraries with strong adoption and active security/bug-fix history
- Avoid unmaintained or niche dependencies unless there is a clear, documented reason

### Runtime Model
- Import specifiers are runtime contracts, not just type-checking syntax
- Pick one runtime model per package and keep it consistent: `bundler` or `node-esm`

### Imports
- Default: use extensionless relative imports (`./x`, `../lib/y`)
- Keep package imports extensionless (`react`, `zod`)
- Do not use `.ts` in runtime imports
- Allow `.js` in TS source only when strict Node ESM runtime requires explicit extension for emitted JS
- Do not mix extensionless and `.js` styles in the same package without a documented reason

### TSConfig Baseline
- Enable strict mode (`"strict": true`)
- Keep `module` and `moduleResolution` aligned with runtime model
- Turn on explicit/issue-finding compiler checks for production code:
  - `"noImplicitAny": true`
  - `"noImplicitOverride": true`
  - `"noImplicitReturns": true`
  - `"noFallthroughCasesInSwitch": true`
  - `"noUncheckedIndexedAccess": true`
  - `"exactOptionalPropertyTypes": true`
  - `"noPropertyAccessFromIndexSignature": true`
  - `"useUnknownInCatchVariables": true`
  - `"noUnusedLocals": true`
  - `"noUnusedParameters": true`
- Keep path aliases minimal and boundary-safe
- Prefer modern module semantics (`"verbatimModuleSyntax": true` when compatible)

### Style
- Use double quotes; do not introduce single-quote style
- Keep semicolons and trailing commas enabled
- Prefer explicit, readable types and APIs over clever inference in shared/public code
- Prefer named, typed handlers over inline anonymous callbacks for non-trivial logic (middleware, hooks, pipelines)
- If an inline callback is necessary, annotate parameters/return types explicitly

### Validation and Reusable Types
- Prefer schema-first validation for external/untrusted inputs (API, CLI, env, files)
- Default to `zod` for parser/validation ergonomics and ecosystem maturity
- Allow faster alternatives (for example `valibot`) when profiling or scale justifies the switch
- Keep one primary validation library per package; avoid mixing parser libraries without a clear reason
- Prefer schema validation entrypoints (`parse`/`validate`/`safeParse` or equivalent) over manual runtime checks in app/runtime code
- Manual runtime checks are acceptable for scripts, tiny local checks, or measured hot paths with a brief rationale
- Derive TypeScript types from validation schemas when practical to avoid duplicate type definitions
- Keep types small, composable, and domain-oriented; extract shared types only after repeated use
- Be pragmatic: optimize for readability and changeability first, then raw performance when measured

### Tooling
- Lint: ESLint with TypeScript-aware config
- Format: Prettier (or project standard)
- Tests: include regression tests for bug fixes and behavior changes

## Python

### Code and Imports
- Prefer explicit, readable code over metaprogramming
- Add type hints for public functions and non-trivial internal APIs
- Group imports: standard library, third-party, local
- Avoid wildcard imports
- Prefer absolute imports for package modules

### Tooling
- Lint and format with Ruff
- Test with `pytest`
- Keep dependency versions pinned/locked for reproducible CI

## Go

### Code and Packages
- Follow idiomatic Go with small explicit APIs
- Prefer composition over inheritance-like patterns
- Return errors with actionable context; never silently ignore errors
- Avoid package-level mutable state unless lifecycle/synchronization is explicit

### Tooling
- Format with `gofmt`
- Lint with `golangci-lint`
- Test with `go test ./...`

## Rust

### Code and Modules
- Model domain invariants with enums/structs
- Keep unsafe blocks minimal, isolated, and documented with safety invariants
- Keep module trees shallow and domain-oriented
- Avoid wildcard imports in production code

### Tooling
- Format with `rustfmt`
- Lint with `clippy`
- Test with `cargo test` including integration tests for boundaries

## Shell and Scripts

### Safety
- Prefer POSIX shell for portability; use Bash when required
- Start Bash scripts with `set -euo pipefail`
- Quote expansions unless intentional word splitting is required

### Naming
- Follow repository script naming conventions from established script examples
- Prefer explicit language/runtime extensions in script names when used by the project (`.sh`, `.py`, `.mjs`)
- Use shebangs for direct execution regardless of extension

### Tooling
- Lint with ShellCheck
- Format with shfmt

## Quick Decision Rules
- If TypeScript code is bundler-run: extensionless relative imports
- If TypeScript emitted JS is run directly by strict Node ESM: allow `.js` import specifiers
- If script language is not obvious in context: include file extension in script name
