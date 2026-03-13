# Scripting

## Philosophy
- Self-contained: scripts run independently with minimal external setup
- Clean and intuitive: purpose and usage obvious from the file alone
- Modular: one concern per script; compose when needed
- Organized: consistent structure, naming, and exit behavior

## Language Selection
- Use system languages (shell/bash) for simple orchestration and glue
- Use non-system languages (Python, Node, Go) when:
  - Complex logic or data manipulation is required
  - Better libraries exist for the task
  - Error handling, testing, or maintainability benefit significantly
- For TypeScript/JavaScript projects, consider [zx](https://github.com/google/zx) for shell scripting
- Prefer the language already used in similar scripts in the codebase

## Dependencies
- Prefer battle-tested, well-maintained tools and libraries
- Check for existing project dependencies before adding new ones
- Document dependencies in the script header or a requirements file
- Use standard library first; add external deps only for clear value
- Pin versions in requirements files; avoid floating versions

## Structure
- Header: purpose, usage, dependencies, author/date if relevant
- Configuration: constants and env vars at the top
- Functions: small, single-responsibility, named by action
- Main: clear entry point; guard clauses for early exits
- Exit codes: 0 for success, non-zero for specific failures

## Script Naming
- Prefer explicit language extensions for scripts when it improves clarity and matches repo conventions
- Use script names that make runtime obvious (`.sh`, `.py`, `.mjs`) using the repository's established examples
- Use shebangs so scripts are still directly executable
- Keep naming consistent inside each project; avoid mixed conventions without a reason

## Arguments
- Use POSIX-style flags: short (`-f`) and long (`--file`) forms
- Prefer generic, conventional names: `-c`/`--config`, `-o`/`--output`, `-v`/`--verbose`, `-h`/`--help`, `-q`/`--quiet`
- Required arguments: fail with clear error if missing; show usage
- Optional arguments: provide sensible defaults; document in help
- Positional args for primary input (e.g., file paths); flags for options
- Group short flags: `-av` equivalent to `-a -v`

## Help (Required for User-Facing Scripts)
- All user-facing scripts MUST provide help via `-h`/`--help`
- Help must include: brief description, usage syntax, options/flags, examples
- Non-trivial scripts should also list requirements and environment variables
- Internal/automation-only scripts may omit help but should still have a clear header

## Independence
- Scripts are independent modules by default
- Explicitly declare inputs (args, env vars, config files)
- Explicitly declare outputs (stdout, files, exit codes)
- Avoid implicit dependencies on global state or external services
- When integrating with a larger system:
  - Follow existing architecture patterns
  - Use shared config/contracts where appropriate
  - Document integration points clearly

## Error Handling
- Fail fast with actionable error messages
- Validate inputs early
- Use appropriate exit codes
- Log or print errors to stderr
- Handle missing dependencies gracefully with install hints

## Logging Output
- Design script/application logging for shell composability: stdout/stderr must be pipe and redirect friendly
- Keep primary data output on stdout and diagnostics/logging on stderr
- Support easy file logging through shell redirection/pipes (for example with `tee`)
- For long-running or operational scripts, optional explicit log-file output is acceptable in addition to stderr
- Keep log format stable and parseable when logs are expected to feed downstream tools

## Portability
- Prefer POSIX-compatible constructs for shell scripts
- Avoid hardcoded paths; use variables or `dirname`/`realpath`
- Handle missing optional dependencies gracefully
- Test on target environments before committing

## Testing
- Non-trivial logic deserves tests
- Prefer integration-style tests for shell scripts
- Unit tests for complex logic in non-system languages
- Include example invocations in comments or help text

## Documentation
- Script header explains: what, why, how to run
- Inline comments for non-obvious logic only
- Keep help text and docs in sync with implementation
