---
description: Show subscription usage status from local plugin
agent: build
subtask: false
---

Use the `subscription-status` tool to show quota usage.

Command arguments are optional and support these flags:

- `--provider <chatgpt-codex|zai-coding-plan|kimi>`
- `--model <model-id>`
- `--verbose` (maps to `detailed: true`)

When flags are present, pass them through to the tool arguments.
When no flags are provided, call the tool with no arguments.

Return concise human-readable output.
