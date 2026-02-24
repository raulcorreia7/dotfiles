# Testing Standards

## Test Pyramid
Use a test pyramid: many unit tests, some integration tests, few e2e tests

## Unit Testing
- Test domain/business logic in isolation; keep tests fast and deterministic
- Keep tests highly relevant to the changed behavior; avoid unrelated test churn
- Use Arrange -> Act -> Assert; each test should assert one behavior
- Name tests by behavior and expected outcome
- Control time/randomness and test data; avoid sleeps and flaky timing
- Heavy mocking is a design smell; simplify boundaries when tests get brittle

## Integration Testing
- Test module/adaptor interactions and boundary contracts (DB/HTTP/queue/files)
- Prefer real collaborators in integration tests; mock only true externals

## E2E Testing
- Test highest-value user/business flows and critical failure paths
- Keep e2e suites small and stable; optimize for release-risk coverage

## Feature Testing Requirements
- Test happy paths and validation/failure paths
- Feature changes include happy-path and validation/failure-path tests

## Bug Fix Testing
- Bug fixes must include a regression test in the same change

## Quality Gates
- Change works end-to-end
- Tests, lint, and build pass
- No new warnings in changed files
- Behavior changes include tests
- Test level matches change scope (unit/integration/e2e)
