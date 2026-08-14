# Commit Classification

The decision tree for classifying a mined bug-fix commit. Run this for each
commit emitted by `scripts/mine-bug-fixes.sh`.

## The Decision Tree

```
For each mined commit <sha>:
1. Get the fix diff:  git show <sha>
2. Get the files touched:  git show --stat --name-only <sha>
3. For each file touched:
   a. Identify the function(s)/class(es) modified by the fix
   b. Search for existing tests that exercise that function/class
4. Decide:
   ┌─ Does a test exist that exercises the fixed behavior?
   │  ├─ YES → Does the test assert the post-fix behavior?
   │  │  ├─ YES → COVERED (skip)
   │  │  └─ NO  → GAP (the test exercises the code but does not assert
   │  │            the fixed behavior — add an assertion or a new test)
   │  └─ NO  → Can the bug be reproduced in a unit test?
   │     ├─ YES → GAP (add a test)
   │     └─ NO  → Is the fix behavioral?
   │        ├─ YES → UNREPRODUCIBLE (defer — see below)
   │        └─ NO  → COSMETIC (skip — typo, formatting, docs)
```

## The Four Outcomes

### COVERED

A test exists that exercises the fixed behavior and asserts the post-fix
outcome. No action needed.

**Verification:** check out `<sha>~1` (the buggy parent) and run the test —
it should fail. If it passes against the buggy code, the test does not
actually cover the fix; reclassify as `GAP`.

### GAP

No test exists, or a test exercises the code but does not assert the fixed
behavior. This is the target for `unit-test-writing` dispatch.

**Required fields for the gap list:**
- Fix commit SHA
- File(s) and function(s) touched
- One-line bug description (from the commit message or the diff)
- Detected test framework (from `project-detection`)
- Proposed test name (`MethodUnderTest_Scenario_ExpectedOutcome`)

### UNREPRODUCIBLE

The fix is behavioral but the bug depends on environment state that cannot be
reconstructed in a unit test — network, filesystem, time, concurrency,
hardware, external service.

**Action:** defer with a rationale. Do not skip silently. Record:
- Why the bug is not unit-testable
- Whether an integration test could cover it (and where it would live)
- Whether a contract test or property test could approximate coverage

**Common unreproducible causes:**
- Race conditions requiring specific timing
- Network failures requiring a real or simulated peer
- Filesystem state requiring specific permissions or disk conditions
- Time-dependent logic requiring a specific clock value
- Hardware-specific behavior (GPU, architecture, peripheral)

### COSMETIC

The fix is non-behavioral — a typo, formatting change, comment edit, docs
update, or import reorder. No test is possible or warranted.

**Verification:** confirm the diff contains no logic changes. If the diff
touches any executable statement (not just whitespace/comments/strings),
reclassify as `GAP` or `UNREPRODUCIBLE`.

## Searching for Existing Tests

The search for an existing test is the most error-prone step. A test may
exist but not cover the fixed behavior. Check in this order:

1. **By file name convention** — most projects colocate tests with source
   (`foo.test.ts`, `test_foo.py`, `foo_test.go`). See
   [Framework Detection](framework-detection.md) for per-framework conventions.
2. **By function name** — grep for the function/class modified by the fix
   across the test directory.
3. **By behavior** — grep for keywords from the bug description (not just
   the function name). A test may exercise the function under a different
   name (e.g., a helper or a wrapper).
4. **By the fix's added lines** — grep for the post-fix assertion values
   or the new branch conditions. A test that already asserts those values
   is `COVERED`.

## Edge Cases

- **Multi-file fixes** — classify per file. A fix touching 3 files may be
  `COVERED` for one, `GAP` for another, and `UNREPRODUCIBLE` for the third.
- **Fixes that add tests** — some `fix:` commits include the regression
  test in the same commit. These are `COVERED` (the test is in the diff).
  Verify the test actually fails against `<sha>~1`.
- **Revert commits** — a revert of a feature (not a bug fix) is not a
  bug-fix commit. Classify reverts of bug fixes as `GAP` (the original
  fix's test, if any, was removed with the feature; the revert restores
  the buggy state and needs a test for the restored-correct behavior).
- **Chore commits with `fix:` prefix** — some teams use `fix:` for
  non-bug changes (e.g., `fix: lint errors`). Classify by the diff, not
  the prefix. If the diff is non-behavioral, mark `COSMETIC`.
