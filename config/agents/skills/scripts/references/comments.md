# Script Comments

Use `../../../references/comments/comments.md` for shared comment guidance, then apply this script-specific overlay.

Use comments to preserve automation intent that is not obvious from names, help text, parameters, stream use, or the command sequence.

## Principles

- Prefer help text, parameter descriptions, validation, and typed contracts for user-facing behavior.
- Use implementation comments for automation constraints that are easy to break while editing.
- Keep comments close to the command, stream, trap, cleanup, or gate they constrain.
- Comment the reason for non-obvious ordering, quoting, globbing, path handling, stream routing, or shell/provider behavior.
- Keep broad operational history in runbooks, issues, or ADRs instead of script comments.

## Avoid

- Restating each command.
- Duplicating `--help` text in implementation comments.
- Explaining obvious shell or language syntax.
- Hiding unclear script structure behind large comment blocks.

## Automation Comments

Comment automation constraints when they preserve:

- command order that prevents data loss, stale output, partial writes, or misleading validation;
- dry-run, check, confirmation, `-WhatIf`, or force gates for destructive or broad changes;
- environment variables, working directory, shell options, external tools, provider behavior, or CI assumptions;
- cleanup, traps, temp files, locks, retries, or atomic writes;
- stdout, stderr, success stream, error stream, or machine-readable output shape;
- quoting, globbing, path handling, subshell, pipeline, or native-command behavior that is intentionally written a certain way.

## Bash

- Use `#` line comments.
- Prefer a short header for executable scripts: purpose, usage, dependencies, side effects, and output contract.
- Add function comments for non-obvious functions and shared script libraries; include globals, arguments, outputs, returns, and side effects when relevant.
- Comment strict-mode exceptions, traps, broad file operations, `eval`-like behavior, arrays used for safe quoting, and non-obvious parameter expansion.

## PowerShell

- Use comment-based help for public scripts and advanced functions.
- Prefer standard help fields such as `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`, `.INPUTS`, `.OUTPUTS`, and `.NOTES` when they help callers.
- Use `#` line comments for implementation intent.
- Comment `ShouldProcess`, `-WhatIf`/`-Confirm`, stream choices, native-command boundaries, provider behavior, and compatibility constraints.

## Python And .NET CLI Scripts

- Use the language reference for normal code-comment style.
- Prefer CLI help, argument descriptions, and typed contracts over implementation comments.
- Comment automation-specific risks: filesystem writes, generated output, retries, locks, and external process behavior.

## TypeScript, Node, And zx

- Follow `../../../references/languages/typescript.md` for normal TypeScript and JavaScript comment style.
- Prefer typed options, parse guards, and small helpers over comments that explain ordinary script flow.
- Comment shell-sensitive choices when future edits could break quoting, globbing, PowerShell/Bash behavior, stream routing, timeout handling, or dry-run gates.
- Keep `zx` command examples in help text minimal; do not duplicate long command examples in implementation comments.

## Sources

- Google Shell Style Guide comments: https://google.github.io/styleguide/shellguide.html#s5-comments
- Google Shell Style Guide function comments: https://google.github.io/styleguide/shellguide.html#s5.2-function-comments
- PowerShell comment-based help: https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_comment_based_help
