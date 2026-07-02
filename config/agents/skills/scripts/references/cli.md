# CLI Script Reference

## Shape

- One job.
- Predictable streams.
- Clear exit codes.
- Safe defaults.
- Helpful `--help`.
- Machine-readable output separated from human diagnostics.

## Bash Defaults

- Use Bash when arrays, `[[ ]]`, or `pipefail` help.
- Structure: shebang/strict mode, constants, helpers, usage, parse args, validation, work functions, `main "$@"`.
- Use arrays for commands and quote expansions.
- Validate with `bash -n`; run ShellCheck when available.
- If using logging: use obvious log functions (log -> debug -> info -> warn -> error -> fatal)

## PowerShell Defaults

- Use comment-based help, `[CmdletBinding()]`, typed params, validation attributes, and native streams.
- Use `SupportsShouldProcess` for state changes.
- Prefer objects on the success stream; diagnostics on information/verbose/warning/error streams.
- Run parser/help checks; run PSScriptAnalyzer when available.

## TypeScript/Node Defaults

- Use the repo package manager and existing script location before adding a new convention.
- Inspect existing dependencies and script helpers before introducing a new parser, globber, prompt library, schema library, or process wrapper.
- Prefer plain Node/TypeScript for logic-heavy automation with limited shell orchestration.
- Consider `zx` for TypeScript/Node automation that mostly coordinates shell commands, package-manager tasks, filesystem operations, or cross-platform command flow.
- Read [zx.md](zx.md) before writing or changing a substantial `zx` script.
- Add `zx` and supporting script-only libraries as dev dependencies through the repo package manager rather than relying on global installs.
- Check runtime, lockfile, TypeScript config, and shell target before writing the script. `zx` supports Bash by default and can switch to PowerShell or `pwsh` when that is the intended shell.

## Common Options

| Option | Use |
|---|---|
| `-h`, `--help` | Show help and exit 0 |
| `-n`, `--dry-run` / `-WhatIf` | Preview writes |
| `--check` | Verify without rewriting |
| `--force` | Allow explicit overwrite |
| `--yes` | Bypass confirmation when safe |
| `--verbose` | Extra diagnostics |
| `--quiet` | Suppress non-error diagnostics |
| `--config FILE` | Read config |
| `--output PATH` | Write target |

## Safety

- Refuse empty paths, root paths, broad globs, and unset variables before deletion/overwrite.
- Scope writes to explicit paths.
- Use temp files plus atomic replace for generated files.
- Make destructive behavior opt-in.
- Never print secrets.
- Avoid hardcoding values, use constants.

## Help Target

```text
Usage:
  command [OPTIONS] INPUT OUTPUT

One to two sentences explaining the script.

Options:
  -n, --dry-run     Show what would change.
  -h, --help        Show help and exit.
```

## Sources

- GNU command-line interface standards: <https://www.gnu.org/prep/standards/html_node/Command_002dLine-Interfaces.html>
- Google Shell Style Guide: <https://google.github.io/styleguide/shellguide.html>
- Google zx setup: <https://google.github.io/zx/setup>
- PowerShell comment-based help: <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help>
- GitHub Scripts to Rule Them All: <https://github.blog/engineering/scripts-to-rule-them-all/>
