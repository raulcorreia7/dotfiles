# Testing Standards

## Language Overlays
- Use this file for test strategy and quality gates
- Use language/framework defaults and toolchain specifics defined by the project
- Rules here are framework-agnostic; map them to idiomatic test primitives in each language

## Test Pyramid
Use a test pyramid: many unit tests, some integration tests, few e2e tests

## Unit Testing
- Test domain/business logic in isolation; keep tests fast and deterministic
- Keep tests highly relevant to the changed behavior; avoid unrelated test churn
- Use Arrange -> Act -> Assert; each test should assert one behavior
- Name tests by behavior and expected outcome
- Control time/randomness and test data; avoid sleeps and flaky timing
- Prefer clear, explicit assertions over broad snapshot/golden assertions for logic-heavy code
- Heavy mocking is a design smell; simplify boundaries when tests get brittle

## Test Structure and Readability
- Keep tests small and focused; avoid multi-behavior assertions unless the scenario requires full-flow validation
- Define test inputs/variables at the beginning of the test (Arrange) instead of hiding values inline
- Use descriptive names for fixtures and inputs; avoid cryptic shorthand in test code
- Keep helper abstractions lightweight; prefer readability over indirection

## Parameterized Scenarios
- Use parameterized/table-driven tests for repeated scenario coverage (language-idiomatic equivalent)
- Keep scenario tables explicit and domain-readable (input, expected output, notable edge case)
- Use parameterization to increase coverage without increasing test complexity

## Integration Testing
- Test module/adaptor interactions and boundary contracts (DB/HTTP/queue/files)
- Prefer real collaborators in integration tests; mock only true externals
- For hybrid ownership systems, test source/owner transitions (local/cache, manager-installed, remote fallback, startup restore)
- Include contract tests at external boundaries to detect schema/protocol drift early

## E2E Testing
- Test highest-value user/business flows and critical failure paths
- Keep e2e suites small and stable; optimize for release-risk coverage

## Determinism and Flake Control
- Tests must be order-independent and runnable in isolation
- No network calls to third-party services in standard CI test runs unless explicitly marked
- Quarantine flaky tests with owner + issue, and prioritize fixing over retries
- If retries are used, track and surface retry counts; do not hide instability

## Test Data and Fixtures
- Keep fixtures minimal and domain-revealing; avoid giant opaque fixtures
- Build test data with helpers/factories only when they improve clarity
- Prefer per-test setup over shared mutable global fixtures

## Lifecycle and Cleanup
- Use setup/teardown lifecycle primitives (language/framework equivalent) to make shared lifecycle explicit
- Cleanup must be deterministic: tests should leave no persisted state, timers, files, or global mutations behind
- Reusable setup helpers should model domain concepts, not generic plumbing

## Test Command Surface
- Provide focused commands when the ecosystem supports it: unit, integration, e2e, and coverage
- Keep one default `test` command for CI/local baseline verification
- Ensure test commands are non-interactive in CI

## Feature Testing Requirements
- Test happy paths and validation/failure paths
- Feature changes include happy-path and validation/failure-path tests
- Prioritize high-impact domain behavior in feature tests before low-value edge permutations

## Bug Fix Testing
- Bug fixes must include a regression test in the same change
- Regression tests should reproduce the real bug path with minimal scaffolding

## Quality Gates (Testing-Specific)
- Ensure change works end-to-end, tests/lint/build pass, and no new warnings are introduced
- Ensure behavior changes include tests at the appropriate level (unit/integration/e2e)
- Critical bug fixes include regression tests that fail before and pass after the fix
- New/changed external contracts include integration or contract tests
