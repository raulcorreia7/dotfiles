---
name: pipeline
description: "Use for designing or implementing typed task pipelines, staged processing, complex script flows, validation pipelines, import/export flows, codemod pipelines, generators, or refactoring nested logic into composable stages. Do not use for CI/CD pipelines, Azure DevOps or GitHub Actions workflows, simple shell pipes, or small linear code."
---

# Pipeline

## Job

Design or implement a clear typed pipeline made of small composable stages.

## Rules

- Use only when staged logic improves clarity, safety, testing, or reuse.
- Prefer simple linear code for small flows.
- Each stage has a clear input type, output type, error contract, and side-effect boundary.
- Put guards and cheap validation early.
- Put expensive work, IO, writes, network calls, queueing, emails, and irreversible side effects late.
- Keep the happy path visible.
- Keep shared context small and explicit.
- Keep stage interfaces smaller than the behavior they unlock.
- Do not hide important branching inside generic pipeline machinery.
- Do not make a framework when named functions are enough.

## Good Fit

Use a pipeline for:

- complex scripts;
- repo automation;
- import/export jobs;
- generators;
- codemods;
- data cleanup;
- validation and normalization;
- staged API or command handlers;
- multi-step migrations with preview;
- workflows needing dry-run, check, or execute phases.

## Poor Fit

Avoid a pipeline for:

- simple code with a few obvious steps;
- highly interactive flows;
- deeply branching state machines;
- transactional logic where all steps must be atomic;
- code where stages share lots of mutable state;
- performance-critical hot paths unless measured;
- cases where types become harder to read than the logic.

## Default Shape

Use this order when it fits:

1. Parse.
2. Cheap shape validation.
3. Permission, ownership, and config validation.
4. Load existing state.
5. Domain validation.
6. Transform or plan.
7. Preview or dry-run.
8. Execute side effects.
9. Verify.
10. Render result.
11. Cleanup.

## Stage Contract

Each stage should answer:

- Input:
- Output:
- Errors:
- Side effects:
- Dependencies:
- Invariants:
- Tests:

## Type Shape

Prefer a stage shape like:

```text
Task<Input, Output, Context>
```

or:

```text
(input, context) -> Result<output, error>
```

Async stages are fine when IO is real:

```text
(input, context) -> Promise<Result<output, error>>
```

## Error Handling

- Use typed or domain errors when the caller needs to handle them.
- Fail fast for invalid input.
- Aggregate validation errors only when the user benefits from seeing all issues at once.
- Preserve original error context.
- Do not swallow errors.
- Do not log secrets.

## Testing

Test at two levels:

- stage tests for tricky validation, transformation, branching, or errors;
- one end-to-end pipeline test for stage order and integration.

Prefer table tests only when rows cover one behavior across named cases.

## Workflow

1. Identify the pipeline goal and final output.
2. List stages in plain language.
3. Mark each stage as pure, IO, write, irreversible, or render.
4. Move cheap validation before expensive or irreversible work.
5. Define typed input/output contracts.
6. Decide error strategy.
7. Implement with the smallest readable abstraction.
8. Add focused tests for risky stages.
9. Add one end-to-end check.
10. Report stage order, contracts, checks, and skipped checks.

## Output

- Pipeline goal.
- Stage list.
- Stage contracts.
- Error strategy.
- Side-effect boundaries.
- Tests or checks.
- Simplifications rejected.
- Risks.
