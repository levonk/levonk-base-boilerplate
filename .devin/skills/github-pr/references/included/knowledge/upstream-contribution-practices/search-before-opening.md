---
type: Practice
title: Search Before Opening
description: Search for existing issues and PRs before opening new ones. Prevents duplicate work and signals respect for the maintainers' time.
tags: [search, duplicate, issues, prs, pre-flight, github]
date:
  created: "2026-07-15"
  knowledge-basis: "2026-07-14"
  last-used: "2026-07-14"
sources:
  - id: nixify-search-existing-work-sh
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/scripts/search-existing-work.sh
    title: "nixify search-existing-work.sh"
---

# Search Before Opening

## Rule

Before opening an issue or PR, search the project's existing issues and
PRs (open and closed) for related work. If someone has already proposed
or implemented the same thing, link to it instead of duplicating.

## Why

Duplicate issues and PRs:

- **Waste maintainer time** — they must triage, link, and close the
  duplicate, which is pure overhead.
- **Signal you didn't look** — opening a duplicate says "I didn't
  bother checking if this was already discussed."
- **Fragment discussion** — if the same topic has two issues, the
  conversation splits across both, and neither gets a coherent
  resolution.
- **May miss prior rejection** — the maintainer may have already
  rejected this exact proposal in a closed issue. Opening it again
  re-litigates a settled decision.

## How to Search

Search both open and closed issues/PRs using multiple terms:

```bash
# Search issues (all states)
gh issue list --repo "$OWNER/$REPO" --search "nix flake" --state all --limit 10

# Search PRs (all states)
gh pr list --repo "$OWNER/$REPO" --search "nix flake" --state all --limit 10
```

Use multiple search terms — the existing issue may use different
vocabulary than you would. For Nix-related work, search for: `flake`,
`nix`, `devbox`, `nixos`, `nixpkgs`, `home-manager`.

## What to Do If You Find Existing Work

| State of existing work | Action |
|------------------------|--------|
| Open issue, no PR | Comment on the issue offering to implement it. Link your PR when ready. |
| Open PR, stale | Ask if the author is still working on it. If not, offer to take over. |
| Closed issue, rejected | Read the rejection reason. If circumstances changed, reference it in a new issue. If not, don't re-open. |
| Closed PR, merged | The feature exists. Don't duplicate. |
| Closed PR, abandoned | Reference it in your new PR. Build on their work if possible. |

## Related

* [Contribution Eligibility](contribution-eligibility.md) — searching is
  part of the pre-flight check before starting work
* [Human Review Gate](human-review-gate.md) — present search results to
  the user before deciding to proceed
