# Pipeline Pattern For Scripts

Use this when a script has enough stages that inline procedural code becomes hard to review.

## Default Script Pipeline

```text
parse_args
validate_args
load_config
discover_inputs
plan_changes
preview_changes
execute_changes
verify_result
render_output
cleanup
```

## Rules

- Validate empty paths, root paths, missing config, unsupported modes, and permissions before work.
- Dry-run before broad writes.
- Keep destructive steps isolated.
- Keep stdout for data and stderr for diagnostics.
- Return structured result objects when the language supports it.
- Do not use global mutable state as the pipe.

## Bash Shape

Use named functions and explicit variables when Bash types are weak:

```bash
main() {
  parse_args "$@"
  validate_args
  load_config
  plan_changes
  preview_or_execute
  render_summary
}
```

Use arrays and explicit paths rather than implicit string passing.

## PowerShell Shape

Prefer object pipeline stages:

```powershell
Get-Input |
  Test-Input |
  New-Plan |
  Invoke-Plan |
  Write-Result
```

PowerShell stages should emit objects, not formatted strings, until the final rendering step.

## Typed Language Shape

```text
const result = await pipeline(
  parseInput,
  validateCheap,
  loadContext,
  buildPlan,
  executePlan,
  renderResult
).run(rawInput, context)
```

## Smells

- Pipeline abstraction is longer than the actual logic.
- Every stage mutates the same shared object.
- Errors are untyped strings.
- Stage order is surprising.
- Validation happens after writes.
- Rendering happens before business logic is complete.
- The pipeline cannot be tested except by running everything.
