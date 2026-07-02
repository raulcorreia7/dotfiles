# zx Script Reference

Use this reference when a TypeScript/Node automation task uses `zx`, or when deciding whether `zx` is the right runner.
Apply it together with the shared TypeScript, comments, CLI, and pipeline references; this page adds `zx`-specific policy instead of replacing those standards.

## Contents

- [Decision](#decision)
- [Setup](#setup)
- [Package Channel](#package-channel)
- [Dependency Policy](#dependency-policy)
- [Strict Shape](#strict-shape)
- [Required References](#required-references)
- [Command Safety](#command-safety)
- [Runtime Behavior](#runtime-behavior)
- [Comments](#comments)
- [Examples](#examples)
- [Sources](#sources)

## Decision

Use `zx` when the script mostly orchestrates shell commands, local tools, package-manager tasks, files, temp paths, or cross-platform shell selection.

Keep plain Node/TypeScript when the script is mostly application logic, data transformation, API integration, or library code with only minor process execution.

Use Bash or PowerShell instead when the script is small, platform-local, already conventional in the repo, and does not benefit from TypeScript contracts.

## Setup

- Install through the repo package manager. Do not rely on a global `zx`.
- Choose and record the package channel: complete `zx` from the stable `latest` channel, or `zx@lite` when the script intentionally wants the minimal core.
- Install `@types/node` and `@types/fs-extra` when TypeScript needs `zx` libdefs and the repo does not already provide them.
- Use the existing TypeScript runner if the repo already has one. If none exists, prefer a normal project choice such as compile with `tsc`, run with `tsx`, or use `.mjs` for a small script.
- Expose the script through `package.json` or the repo's existing task entrypoint.
- Prefer explicit imports from `zx`; use `zx/globals` only when it is already the repo convention.
- Default to complete `zx` for repo automation unless the dependency policy explicitly chooses `zx@lite`.

Recommended package shape for a new Node/TypeScript automation script:

```json
{
  "scripts": {
    "docs:check": "tsx scripts/check_docs.ts",
    "docs:check:verbose": "tsx scripts/check_docs.ts --verbose"
  },
  "devDependencies": {
    "@types/fs-extra": "<repo-selected-version>",
    "@types/node": "<repo-selected-version>",
    "tsx": "<repo-selected-version>",
    "zx": "<repo-selected-version>"
  }
}
```

## Package Channel

Choose one channel before adding or changing dependencies:

| Channel | Use when | Avoid when |
|---|---|---|
| Complete `zx` (`latest`) | Default for repo automation, CLI scripts, Markdown scripts, `zx/cli`, `zx/globals`, `glob`, `fs`, `dotenv`, prompts, retries, YAML helpers, temp helpers, or bundled convenience APIs. | The script is a custom library/toolkit that only needs the core process API and should keep bundled helpers out. |
| `zx@lite` | Custom toolkits, embedded process runners, or very small scripts that only need core exports such as `$`, `ProcessPromise`, quoting, `cd`, shell switching, and a few process helpers. | The script needs `zx/cli`, globals, `glob`, `fs`, dotenv, prompts, retries, YAML helpers, temp helpers, or examples from the complete package. |

Do not use `zx@dev` for team automation unless the task is explicitly testing upcoming zx behavior. Use legacy pinned versions only to maintain old scripts that cannot migrate yet.

When selecting `zx@lite`, state the missing complete-package helper that was intentionally avoided or replaced by an existing dependency or Node standard-library API.

## Dependency Policy

Before writing a `zx` script:

1. Inspect `package.json`, lockfiles, existing scripts, `tsconfig`, lint config, and local tooling wrappers.
2. Prefer repo-installed libraries and Node standard-library APIs over new dependencies.
3. Add a dev dependency when it removes meaningful custom parsing, globbing, validation, CLI, table rendering, prompt, archive, YAML/JSONC, or process-management code.
4. Avoid runtime dependencies for repo automation unless the script is packaged and shipped with production code.
5. Keep dependency additions narrow, documented in the package manager lockfile, and consistent with existing package-manager policy.

Common useful dev dependencies for strict `zx` scripts:

| Need | Prefer |
|---|---|
| CLI args | Node `parseArgs`; existing `commander`, `yargs`, or `cac` if already installed |
| Runtime validation | Existing `zod`, `valibot`, `arktype`, or a small hand-written guard for tiny shapes |
| Globs | `zx` `glob()` or existing `fast-glob` |
| File IO | Node `fs/promises`; `zx` helpers when already using them |
| YAML/JSONC/TOML | Existing parser package; do not hand-roll config parsing |
| Tables/output | Existing table/formatting library, or plain JSON for machine output |
| Prompts | Existing prompt package; avoid prompts for CI-oriented scripts unless interactive mode is explicit |

When adding dependencies for a `zx` script, update the script example and invocation contract so future maintainers know why the dependency exists and how it is used.

## Strict Shape

- Follow `../../../references/languages/typescript.md` for compiler strictness, type boundaries, imports, naming, and comments.
- Type parsed options and config before running commands.
- Treat `process.argv`, environment values, parsed JSON, filesystem input, and command output as external boundaries.
- Keep command execution at the edge; put planning, filtering, validation, and output shaping in typed helpers.
- Prefer `unknown` plus narrowing for command JSON or untrusted file content.
- Use `import type` for type-only `zx` imports when local tooling expects explicit type imports.
- Do not relax TypeScript strictness, use `any`, add broad casts, or add type suppressions to make a script pass locally unless a compatibility boundary requires it and the reason is documented.

Default script pipeline:

```text
parse args -> validate -> discover inputs -> plan -> preview or execute -> verify -> render output
```

## Required References

Before writing or materially changing a `zx` script, read:

- `../../../references/languages/typescript.md` for strict TypeScript, runtime boundaries, imports, and type style.
- `../../../references/comments/comments.md`, then [comments.md](comments.md), for comment quality and script-specific comment placement.
- [cli.md](cli.md) for CLI shape, streams, help, options, and safety gates.
- [pipeline.md](pipeline.md) for staged scripts, generators, migrations, codemods, or broad automation.

## Command Safety

- Do not build raw command strings and pass them as a single interpolation.
- Pass dynamic arguments through `${...}` and arrays so `zx` quotes each value.
- Do not add shell quotes around `${...}`. `zx` already quotes substitutions.
- Use `glob()` for glob expansion when the pattern is dynamic.
- Use `os.homedir()` for dynamic home-directory paths. Do not expect `~` inside `${...}` to expand.
- Use `preferLocal: true` when invoking project-local binaries.
- Pin or route the shell explicitly when behavior depends on Bash, Windows PowerShell, or `pwsh`.

Prefer:

```ts
const files = await glob(["wiki/**/*.md", "docs/**/*.md"])
const flags = ["--config", ".markdownlint.json"]

await $({ preferLocal: true })`markdownlint ${flags} ${files}`
```

Avoid:

```ts
const command = `markdownlint --config .markdownlint.json ${files.join(" ")}`
await $`${command}`
```

## Runtime Behavior

- Keep stdout for machine-readable script results. Write diagnostics to stderr.
- Use `--verbose` to expose command logs; avoid noisy output by default.
- Use `--dry-run` or `--check` for broad writes, deletes, generated files, or formatters.
- Use `timeout` or `AbortController` for commands that can hang.
- Use `nothrow` only when non-zero exit codes are part of the contract and are handled explicitly.
- Use `.exitCode` when only the exit status matters.
- Use `.json<T>()`, `.lines()`, `.text()`, or `.buffer()` to make output consumption explicit.
- Avoid `process.exit()` after async writes; set `process.exitCode` and let output flush.

## Comments

- Follow `../../../references/comments/comments.md`, then [comments.md](comments.md).
- Prefer clear names, typed options, help text, and validation over comments.
- Comment shell-sensitive constraints: quoting, globbing, PowerShell/Bash choice, stream routing, timeout, cleanup, dry-run gates, and destructive behavior.
- Do not comment each command; comment the reason for non-obvious command order or safety gates.

## Examples

Minimal strict TypeScript `zx` script:

```ts
#!/usr/bin/env node
import process from "node:process"
import { parseArgs } from "node:util"
import { $, glob, usePwsh } from "zx"

type Shell = "bash" | "pwsh"

type Options = {
  dryRun: boolean
  verbose: boolean
  shell: Shell
}

function parseOptions(rawArgs: readonly string[]): Options {
  const { values } = parseArgs({
    args: [...rawArgs],
    allowPositionals: false,
    options: {
      "dry-run": { type: "boolean", default: false },
      shell: { type: "string", default: "bash" },
      verbose: { type: "boolean", default: false }
    }
  })

  if (values.shell !== "bash" && values.shell !== "pwsh") {
    throw new Error("shell must be 'bash' or 'pwsh'")
  }

  return {
    dryRun: values["dry-run"] ?? false,
    shell: values.shell,
    verbose: values.verbose ?? false
  }
}

function info(message: string): void {
  process.stderr.write(`${message}\n`)
}

async function runOrPreview(
  options: Pick<Options, "dryRun">,
  description: string,
  command: () => Promise<unknown>
): Promise<void> {
  if (options.dryRun) {
    info(`[dry-run] ${description}`)
    return
  }

  await command()
}

const options = parseOptions(process.argv.slice(2))

if (options.shell === "pwsh") {
  usePwsh()
}

const run = $({
  preferLocal: true,
  timeout: "2m",
  verbose: options.verbose
})

const files = await glob(["wiki/**/*.md", "docs/**/*.md"])

await runOrPreview(
  options,
  `check ${files.length} markdown files`,
  () => run`markdownlint ${files}`
)

process.stdout.write(`${JSON.stringify({ checked: files.length, dryRun: options.dryRun })}\n`)
```

PowerShell-specific shell selection:

```ts
import { $, usePwsh } from "zx"

usePwsh()

await $`Get-ChildItem -Path ${"wiki"} -Recurse`
```

Handling an expected non-zero exit code:

```ts
const output = await $`git diff --quiet -- wiki`.nothrow()

if (output.exitCode === 1) {
  process.stderr.write("wiki has uncommitted changes\n")
  process.exitCode = 1
} else if (output.exitCode !== 0) {
  throw output
}
```

## Sources

- `zx` getting started: https://google.github.io/zx/getting-started
- `zx` setup, runtimes, package channels, Bash, PowerShell, and TypeScript libdefs: https://google.github.io/zx/setup
- `zx` CLI usage and options: https://google.github.io/zx/cli
- `zx` API reference: https://google.github.io/zx/api
- `zx` configuration: https://google.github.io/zx/configuration
- `zx` process promise: https://google.github.io/zx/process-promise
- `zx` process output: https://google.github.io/zx/process-output
- `zx` quotes and dynamic arguments: https://google.github.io/zx/quotes
- `zx` shell selection: https://google.github.io/zx/shell
- `zx` TypeScript setup: https://google.github.io/zx/typescript
- `zx` Markdown scripts: https://google.github.io/zx/markdown
- `zx` known issues: https://google.github.io/zx/known-issues
- `zx` versions and lite channel: https://google.github.io/zx/versions
