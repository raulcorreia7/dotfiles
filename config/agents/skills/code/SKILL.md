---
name: code
description: "Use for normal application-code implementation, edits, and explanations. Applies team coding discipline while preserving scope, local conventions, readability, contracts, validation, modularity, and verification. Do not use for scripts, docs, commits, reviews, strict TDD, diagnosis, behavior-preserving refactors, or comment-primary work when those skills fit better."
---

# Code

## Job

Implement or edit application code with the smallest correct, readable change.

## Shape

Prefer code with:

- guards first;
- cheap validation early;
- clear happy path;
- explicit failure paths;
- small composable pieces;
- stable module boundaries;
- names from the project/domain;
- tests or checks that match the risk.

## Rules

- Preserve scope.
- Follow existing project conventions before generic preferences.
- Read nearby code, tests, types, config, and call sites before changing behavior.
- For non-trivial edits, define success criteria before implementation and verify against them before claiming done.
- Every changed line should trace to the requested behavior or required verification.
- Validate boundary inputs, config, preconditions, permissions, and external data before core logic.
- Run cheap validations before expensive work, IO, network calls, database writes, or irreversible side effects.
- Use guard clauses for invalid, exceptional, unauthorized, unsupported, or no-op cases when they make the happy path clearer.
- Keep the main path flat and readable.
- Make inputs, outputs, contracts, side effects, and failure modes explicit.
- Keep domain logic composable and easy to test without unnecessary infrastructure.
- Keep framework, IO, provider, persistence, and transport details near the edge when practical.
- Prefer existing project patterns, standard library, native framework features, and existing dependencies.
- Add new dependencies only when they clearly reduce risk or complexity.
- Comments are required when intent, constraints, trade-offs, invariants, policy boundaries, or risk would otherwise be hidden.
- Use `$code-comments` instead when the requested deliverable is source comments, docstrings, public API docs, or marker cleanup. For behavior changes with incidental comments, stay in `$code` and read the shared comments reference when needed.
- Do not comment obvious mechanics.
- Do not add speculative abstractions.
- Do not do incidental cleanup.
- Do not delete pre-existing dead code or rewrite unrelated comments; mention them as follow-up instead.
- Do not mix unrelated responsibilities in one change.
- Do not swallow errors or hide failure states.
- Do not log secrets or sensitive values.

## Validation Order

Use this order when it fits:

1. Shape checks: null, empty, missing, malformed, unsupported.
2. Permission and ownership checks.
3. Cheap domain preconditions.
4. Existing-state checks.
5. Expensive computation.
6. IO, network, database writes, queues, emails, or irreversible side effects.

Do not duplicate validation at every layer. Validate at the authoritative boundary, then keep internal contracts clear.

## Modularity

Prefer small composable units when they create clarity.

Good module boundaries:

- hide details likely to change;
- expose a small stable interface;
- own one clear responsibility;
- are testable through behavior;
- reduce caller knowledge.

Bad module boundaries:

- pass data through without value;
- split code by technical fashion only;
- create interfaces for every class/function;
- hide simple logic behind generic helpers;
- force readers to jump across files for one small behavior.

## Abstraction Bar

Add or extract an abstraction only when it has real pressure.

Real pressure means at least one of:

- repeated change;
- stable boundary;
- test seam;
- ownership split;
- public contract;
- compatibility requirement;
- meaningful duplicate knowledge.

Duplication is acceptable when the shared shape is still unclear.

Do not extract only because something appeared three times. Extract when the abstraction has a name, contract, and reason to exist.

## Workflow

1. Identify requested behavior or edit.
2. Inspect local conventions and relevant call sites.
3. Define success criteria for non-trivial work.
4. Pick the smallest readable implementation path.
5. Add guards and cheap validation before expensive or unsafe work.
6. Make the change.
7. Update tests, types, docs, or config only when required by the behavior.
8. Run the narrowest useful check.
9. Report changed behavior, files, checks, assumptions, and skipped checks.

## Output

- Changed behavior.
- Files changed.
- Checks run.
- Skipped checks.
- Assumptions.
- Risks or follow-up when relevant.

## Reference Map

- Read `../../references/comments/comments.md` when comments need calibration.
- Read `../../references/languages/languages.md` when choosing a language-specific reference.
- Read `../../references/languages/typescript.md` for TypeScript or JavaScript application code.
- Read `../../references/languages/csharp.md` for C# or .NET application code.
- Read `../../references/languages/python.md` for Python application code.
- Read `../../references/languages/go.md` for Go application code.
- Read `../../references/languages/java.md` for Java application code.
- Read `../../references/languages/rust.md` for Rust application code.
