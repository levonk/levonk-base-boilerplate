---
type: Practice
title: Test Baseline
description: Run the project's test suite before starting work to establish a baseline. Document pre-existing failures. Don't fix unrelated bugs in a scoped PR.
tags: [testing, baseline, pre-existing-failures, scope, validation]
date:
  created: "2026-07-15"
  knowledge-basis: "2026-07-14"
  last-used: "2026-07-14"
sources:
  - id: nixify-skill-md-step-8
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/SKILL.md.tmpl
    title: "nixify SKILL.md Step 8"
---

# Test Baseline

## Rule

Before making any changes, run the project's test suite and record the
results. This establishes a baseline: which tests pass and which fail
before your work. After your changes, compare against the baseline —
your PR should not introduce new failures, and should not fix
pre-existing failures unless that's the PR's purpose.

## Why

Without a baseline:

- **You can't distinguish your breakage from pre-existing breakage.** If
  tests fail after your change, you don't know if you broke something or
  it was already broken. You either waste time debugging a pre-existing
  failure, or worse, assume your change is fine and ship a regression.
- **Fixing pre-existing failures expands PR scope.** A "add Nix flake"
  PR that also fixes a flaky test is now a two-purpose PR. The maintainer
  must review both changes, and if the test fix is controversial, the
  flake PR is blocked.
- **You lose credibility.** If you claim "all tests pass" but the
  maintainer finds pre-existing failures, they can't trust your testing
  claims about the actual change.

## How

```bash
# Before making any changes:
cd <project>
<run the project's test command>  # cargo test, npm test, bun test, etc.

# Record the baseline:
# - Which tests pass
# - Which tests fail (and why — flaky, missing dependency, known bug)
# - Any environmental issues (missing services, platform-specific failures)
```

Document the baseline in your notes. If the project has known failures,
mention them in the PR description under a "Pre-existing" note so the
maintainer knows you're aware.

## Don't Fix Unrelated Bugs

If you discover a bug during your work that's unrelated to the PR's
purpose:

- **Don't fix it in this PR.** File a separate issue or open a separate
  PR.
- **Don't comment on it in the PR.** It creates noise in the review.
- **Do note it privately** for follow-up.

The exception is if the bug blocks your change from working (e.g., the
test harness is broken and you can't validate your change without
fixing it). In that case, fix the minimal amount needed, clearly
document it in the PR, and ask the maintainer if they prefer it split
out.

## Related

* [Minimal Scope](minimal-scope.md) — fixing unrelated bugs is a scope
  expansion
* [Format Artifacts](format-artifacts.md) — run the project's formatter
  on your files, but don't reformat unrelated files (same scope
  principle)
