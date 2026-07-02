# Test Quality Patterns

Use for TDD tasks where test level, data-driven cases, fixtures, shared resources, race safety, or clean test design matters. The top-level skill controls the red-green-refactor loop and one-behavior scope.

## Contents

- [TDD Loop](#tdd-loop)
- [Test Levels And Live Resources](#test-levels-and-live-resources)
- [Clean Test Shape](#clean-test-shape)
- [Parameterized And Table Tests](#parameterized-and-table-tests)
- [Resource Isolation](#resource-isolation)
- [Fixtures And Cleanup](#fixtures-and-cleanup)
- [Race And Parallel Safety](#race-and-parallel-safety)
- [Smell Checklist](#smell-checklist)
- [Sources](#sources)

## TDD Loop

- Keep a short behavior list; implement one externally observable slice at a time.
- Red must fail for the expected reason; investigate surprising failures before coding.
- Green means minimal code for the current behavior.
- Refactor only while green and without expanding behavior.
- Stop and call out the seam when tests require private implementation assertions.

## Test Levels And Live Resources

- Unit: pure logic, parsing, transformations, edge cases, domain rules.
- Isolated integration: real internal boundaries without live data/networks/production/shared externals.
- E2e: real boundaries or user journeys; keep separate from fast TDD unless requested.
- Live-resource checks: explicit opt-in via command, flag, env var, profile, or documented target.
- Prefer fake, stubbed, local, ephemeral, or containerized dependencies.
- Report skipped live validation and the required command/toggle when known.

## Clean Test Shape

- Use Arrange/Act/Assert, Given/When/Then, or local equivalent.
- Keep one primary Act per test.
- Assert observable behavior: return values, events, persisted state, rendered output, command output, error contracts, side effects.
- Use the narrowest assertion that proves the contract.
- Multiple assertions are fine for one outcome; split separate behaviors.
- Avoid broad snapshots, huge object equality, and loose containment unless they are the project contract.
- Prefer DAMP clarity over aggressive DRY.
- Extract helpers only for domain intent, valid data, or lifecycle ownership.
- Name tests in product/domain/contract language.

## Parameterized And Table Tests

Use data-driven tests when one behavior must be proven across named inputs, boundaries, or edge cases.

- Keep rows about the same behavior and visible in failure output.
- Keep tables small; split when reasons, modes, or outcomes differ.
- Put expected output in the row when it improves readability.
- Do not use a table as permission to write all future tests before implementation.

TypeScript-style example:

```ts
it.each([
  ["empty name", "", "Name is required"],
  ["spaces only", "   ", "Name is required"],
])("rejects invalid display name: %s", (_caseName, input, expectedError) => {
  const result = validateDisplayName(input);

  expect(result.error).toBe(expectedError);
});
```

Equivalent patterns exist as pytest `parametrize`, .NET `DataRow`/`DynamicData`, JUnit parameterized tests, and Go table-driven tests. Prefer the local framework's idiom.

## Resource Isolation

Identify resources before the first test:

- filesystem paths/temp dirs;
- databases, schemas, transactions, records, indexes, migrations;
- network calls, sockets, ports, emulators, credentials;
- clocks, timers, random seeds, locale, timezone, env vars;
- global state, singletons, caches, registries, feature flags, process state;
- workers, threads, queues, async tasks, child processes, browser contexts, sessions.

Prefer per-test isolated resources: temp dirs, unique names, transactions, fresh records, fake clocks, restored env, stubbed network, unique ports, fresh browser/session contexts.

Use shared resources only when they reduce cost and are immutable, reset between tests, or fixture-owned.

## Fixtures And Cleanup

- Keep setup local unless repeated lifecycle justifies a fixture.
- Cleanup must run on failure: framework cleanup hooks, `try/finally`, disposables, context managers, or equivalents.
- Restore mutated process state: env, cwd, locale, timezone, config, monkeypatches, fake timers, logging.
- Close handles, servers, browser contexts, workers, and processes.
- Avoid fixture chains that force cross-file reading.
- Do not put assertions in setup unless setup is the behavior under test.

## Race And Parallel Safety

- Assume random order/parallel execution unless the project serializes tests.
- Use unique names and isolated temp paths; avoid shared filenames, ports, users, records, queues.
- Prefer deterministic sync over sleeps: fake timers, events, latches, promises, barriers, polling with explicit timeout, framework waits.
- Run race/parallel/flake checks when behavior touches concurrency, async work, shared mutable resources, or isolation.
- Keep slow stress tests separate from the fast TDD loop unless concurrency is the behavior.

## Maintainable Test Modules

- Group by behavior surface, public API, command, route, component, or domain capability.
- Keep helpers near tests until several modules need them.
- Prefer small builders/factories with case-specific values visible.
- Avoid utility modules that become a second app framework.
- Preserve behavior-focused names when moving tests.

## Smell Checklist

- Multiple unrelated Acts.
- Test passes when behavior is broken.
- Depends on order, time, random data, host state, or another test cleanup.
- Setup hides the reason for the test.
- Shared mutable fixtures are changed by tests.
- Mocks mirror implementation instead of protecting a boundary.
- Sleeps/retries hide sync problems.
- Parameterized table mixes behaviors.
- Helper names describe mechanics, not intent.
- Assertions are absent, broad, or mostly snapshots.

## Sources

- Kent Beck, Canon TDD: <https://newsletter.kentbeck.com/p/canon-tdd>
- Microsoft unit testing best practices: <https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-best-practices>
- Microsoft MSTest data-driven tests: <https://learn.microsoft.com/en-us/dotnet/core/testing/unit-testing-mstest-writing-tests-data-driven>
- pytest fixtures: <https://docs.pytest.org/en/stable/how-to/fixtures.html>
- pytest temporary directories: <https://docs.pytest.org/en/stable/how-to/tmp_path.html>
- pytest monkeypatch: <https://docs.pytest.org/en/stable/how-to/monkeypatch.html>
- pytest parametrize: <https://docs.pytest.org/en/stable/how-to/parametrize.html>
- Jest test API: <https://jestjs.io/docs/api>
- Vitest test API: <https://vitest.dev/api/test>
- JUnit test instance lifecycle: <https://docs.junit.org/6.1.0/writing-tests/test-instance-lifecycle.html>
- JUnit parallel execution: <https://docs.junit.org/6.1.0/writing-tests/parallel-execution.html>
- JUnit parameterized tests: <https://docs.junit.org/6.1.0/writing-tests/parameterized-classes-and-tests.html>
- Go table-driven tests: <https://go.dev/wiki/TableDrivenTests>
- Go race detector: <https://go.dev/doc/articles/race_detector>
- Testing Library guiding principles: <https://testing-library.com/docs/guiding-principles/>
- Playwright best practices: <https://playwright.dev/docs/best-practices>
- Playwright fixtures: <https://playwright.dev/docs/test-fixtures>
- Playwright parallelism: <https://playwright.dev/docs/test-parallel>
- Google Testing Blog, DAMP vs DRY: <https://testing.googleblog.com/2019/12/testing-on-toilet-tests-too-dry-make.html>