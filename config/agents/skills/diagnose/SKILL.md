---
name: diagnose
description: "Use when the user reports broken, failing, throwing, flaky, or slow behavior, or asks to debug/diagnose. Build a tight repro before hypothesizing, then minimize, instrument, fix when in scope, and regression-test."
---

# Diagnose

## Job

Find the cause of broken behavior using a tight feedback loop before guessing at fixes.

Inspired by Matt Pocock's `diagnosing-bugs`; adapted for this team's Goldilocks-lean defaults.

## Steps

1. Build a feedback loop first:
   - failing test;
   - curl/HTTP script;
   - CLI fixture;
   - headless browser script;
   - trace replay;
   - throwaway harness;
   - property/fuzz loop;
   - bisect or differential loop;
   - structured human-in-the-loop script only as last resort.
2. Tighten the loop until it is red-capable, deterministic or high-repro, fast, and agent-runnable.
3. Reproduce the user's exact symptom.
4. Minimize inputs, callers, config, data, and steps until every remaining part is load-bearing.
5. Generate 3-5 ranked falsifiable hypotheses with predictions.
6. Instrument one prediction at a time using debugger/REPL, targeted logs, or measurements.
7. For performance, measure baseline before optimizing.
8. If fixing is in scope, convert the minimized repro into a regression test at the correct seam when one exists.
9. Apply the smallest fix, rerun original loop and regression test, then remove temporary probes.
10. Capture the cause in the PR/commit message or handoff.

## Output

- Feedback loop command and result.
- Repro determinism or reproduction rate.
- Minimized scenario.
- Ranked hypotheses and tested predictions.
- Root cause with evidence.
- Fix summary when in scope.
- Regression proof or missing-seam finding.
- Cleanup performed.

## Guardrails

- Do not hypothesize before a red-capable loop exists unless you explicitly state why no loop can be built.
- Do not fix a nearby failure that does not match the user's symptom.
- Do not add broad logging; tag temporary instrumentation and remove it.
- Do not refactor while debugging unless it is the smallest safe path to expose the bug.
- Do not claim fixed until the original repro is green.
- If no correct regression seam exists, report that as an architecture finding and consider `$improve-codebase-architecture` after the fix.
