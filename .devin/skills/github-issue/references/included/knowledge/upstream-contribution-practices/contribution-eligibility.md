---
type: Practice
title: Contribution Eligibility
description: Verify the project accepts external contributions, read their CONTRIBUTING.md, and check for CLA/DCO requirements before starting work. Prevents wasted effort on projects that reject external PRs or have risky contributor agreements.
tags: [contributing, cla, dco, contribution-guidelines, eligibility, pre-flight]
date:
  created: "2026-07-15"
  knowledge-basis: "2026-07-14"
  last-used: "2026-07-14"
sources:
  - id: nixify-search-existing-work-sh
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/scripts/search-existing-work.sh
    title: "nixify search-existing-work.sh"
  - id: contributing-to-open-source
    resource: https://docs.github.com/en/get-started/exploring-projects-on-github/finding-ways-to-contribute-to-open-source-on-github
    title: "GitHub: Contributing to Open Source"
---

# Contribution Eligibility

## Rule

Before investing time in a contribution, verify three things:

1. **The project accepts external contributions** — not all repos do.
   Some are mirrors of internal repos, read-only showcases, or
   archived projects that look active.
2. **Read and follow their contribution guidelines** — find
   `CONTRIBUTING.md`, `.github/CONTRIBUTING.md`, `docs/CONTRIBUTING.md`,
   or the contributing section in the README.
3. **Check for CLA/DCO requirements** — some projects require a
   Contributor License Agreement or Developer Certificate of Origin
   sign-off. Assess whether the terms are acceptable before proceeding.

## Why

Contributing to a project that doesn't accept external PRs wastes the
entire work cycle — the PR is closed without review. Contributing
without following their process (e.g., they require an issue before a
PR, or they use a specific PR template) creates friction in the first
review and signals you didn't read their guidelines.

CLA/DCO requirements carry legal implications. A CLA may grant the
project owner broad rights to your contribution (relicensing,
sublicensing, commercial use). A DCO is lighter — it's a sign-off
attesting you have the right to contribute. If a CLA's terms are
unacceptable to you, discovering this after writing the code is too
late.

## How to Check

```bash
# Check for contribution guidelines
for path in CONTRIBUTING.md .github/CONTRIBUTING.md docs/CONTRIBUTING.md; do
  curl -sL "https://api.github.com/repos/$OWNER/$REPO/contents/$path" \
    | jq -r '.content' 2>/dev/null | base64 -d 2>/dev/null
done

# Check if repo is archived
gh api "repos/$OWNER/$REPO" --jq '.archived'

# Check for CLA bot enforcement (look for .github/cla.yml or CLA-bot in checks)
gh api "repos/$OWNER/$REPO/contents/.github" --jq '.[].name'
```

## CLA vs DCO

| Requirement | What it does | Risk to assess |
|-------------|-------------|----------------|
| CLA (Contributor License Agreement) | Grants project owner rights to your contribution | May allow relicensing, sublicensing, or commercial use without further consent |
| DCO (Developer Certificate of Origin) | You attest you have rights to contribute | Minimal risk — it's a sign-off (`Signed-off-by:`), not a rights grant |
| None | No formal agreement | Lowest friction, but check contributing guidelines for informal rules |

If a CLA is required and you're uncomfortable with the terms, stop and
escalate. Don't sign legal agreements you haven't read.

## Related

* [Search Before Opening](search-before-opening.md) — check for existing
  issues/PRs as part of the pre-flight
* [Follow Project Conventions](follow-project-conventions.md) — reading
  CONTRIBUTING.md is the first step; matching their conventions is the
  second
