# Build Systems

## Philosophy
- Build systems are orchestrators, not implementations
- Keep build files declarative and readable
- Promote complexity to scripts; keep build layer thin
- Be idiomatic: follow conventions of the language/ecosystem

## Standard Targets

Every project with a build system MUST provide these targets (or equivalents idiomatic to the ecosystem):

| Target | Purpose |
|--------|---------|
| `lint` | Static analysis and code quality checks |
| `format` | Auto-format code (or `format:check` for CI) |
| `test` | Run all tests |
| `build` | Compile/build artifacts |
| `clean` | Remove generated files and artifacts |
| `all` | Full pipeline (typically: lint + test + build) |

Ecosystem-specific equivalents:
- **Node/npm**: `lint`, `format`, `test`, `build`, `clean` (use `npm-run-all` for `all`)
- **Rust/Cargo**: `check`, `fmt`, `test`, `build`, `clippy` (Cargo has built-in `clean`)
- **Go**: Use Makefile with `lint`, `fmt`, `test`, `build`, `clean`
- **Python**: Use Makefile or `pyproject.toml` scripts with `lint` (ruff), `format` (ruff format), `test`, `clean`

## Linting & Formatting Configuration

Every project MUST include linting and formatting configuration files appropriate to the language:

| Language | Linter | Formatter | Config Files |
|----------|--------|-----------|--------------|
| TypeScript/JS | ESLint | Prettier | `.eslintrc.*`, `.prettierrc` |
| Python | Ruff | Ruff format | `pyproject.toml` or `ruff.toml` |
| Go | golangci-lint | gofmt | `.golangci.yml` |
| Rust | Clippy | rustfmt | `clippy.toml`, `rustfmt.toml` |
| Shell | ShellCheck | shfmt | `.shellcheckrc`, `.shfmt` |

### Configuration Requirements
- Commit config files to version control (never rely on global settings)
- Extend shared configs where available (e.g., `@typescript-eslint/recommended`)
- Document any deviations from defaults with rationale
- Run formatter before linter in CI (`format:check` then `lint`)

### Preferred Style Defaults
- **TypeScript/JavaScript**: double quotes, semicolons, trailing commas
- **Python**: Ruff defaults (88 char line length)
- **Go**: gofmt defaults
- **Rust**: rustfmt defaults
- **Shell**: 2-space indent, POSIX-compatible where possible

## When to Inline

Inline in `package.json`, `Makefile`, `Cargo.toml`, etc. when:
- Single, simple command (e.g., `eslint .`, `tsc`, `pytest`)
- Standard tool invocation with minimal flags
- One-liners without conditionals or logic
- Commands that don't need error handling beyond default behavior

```json
// Good: simple, standard
"scripts": {
  "lint": "eslint src/",
  "test": "vitest run",
  "build": "tsc"
}
```

## When to Promote to Scripts

Extract to external script when:
- Multiple steps or conditional logic required
- Error handling beyond default exit codes needed
- Environment validation or setup required
- Logic is non-trivial or likely to change
- Command exceeds ~80 characters or becomes hard to read
- Same logic duplicated across multiple targets

```json
// Better: complex logic promoted to script
"scripts": {
  "deploy": "./scripts/deploy.sh",
  "release": "./scripts/release.sh"
}
```

## Build System Patterns

### package.json
- Use `npm-run-all` or `concurrently` for parallel/sequential task composition
- Prefix lifecycle scripts (`prebuild`, `postinstall`) only for true hooks
- Group related scripts with colons: `test:unit`, `test:e2e`, `test:coverage`

### Makefile
- Targets should call scripts, not embed logic
- Use `.PHONY` for non-file targets
- Variables for paths and flags; avoid hardcoding
- Keep targets readable; extract complexity to `scripts/`

```makefile
# Good: thin Makefile
.PHONY: test build deploy

test:
	./scripts/run-tests.sh

build:
	./scripts/build.sh

deploy:
	./scripts/deploy.sh $(ENV)
```

### Task Runners (just, task, etc.)
- Same principle: orchestrate, don't implement
- Use for task discovery and documentation
- Delegate complex work to scripts

## Script Location
- `scripts/` directory at project root for build/deploy scripts
- Follow scripting.md conventions for all extracted scripts
- Name scripts by action: `build.sh`, `deploy.sh`, `seed-db.sh`

## Decision Heuristic

| Complexity | Location |
|------------|----------|
| Single command, no logic | Inline |
| 2-3 commands, no conditionals | Inline (if readable) |
| Any conditionals | Script |
| Error handling needed | Script |
| >80 chars or hard to read | Script |
| Reused across targets | Script |

## Anti-Patterns
- Embedding complex shell logic in JSON (escaping hell)
- Long one-liners with pipes, redirects, and conditionals
- Duplicating logic across multiple build targets
- Build files that require careful reading to understand
- Missing `.PHONY` declarations in Makefiles
