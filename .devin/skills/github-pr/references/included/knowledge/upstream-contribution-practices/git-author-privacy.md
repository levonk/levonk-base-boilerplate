---
type: Practice
title: Git Author Privacy
description: Verify git author identity is public, not leaking hostname or system username. Use GitHub noreply email. Prevents private identity info in commit metadata.
tags: [git, privacy, author, identity, noreply, commit]
date:
  created: "2026-07-15"
  knowledge-basis: "2026-07-14"
  last-used: "2026-07-14"
sources:
  - id: nixify-setup-branch-sh
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify/scripts/setup-branch.sh
    title: "nixify setup-branch.sh"
  - id: setting-your-commit-email-address
    resource: https://docs.github.com/en/account-and-profile/setting-up-and-managing-your-personal-account-on-github/managing-email-preferences/setting-your-commit-email-address
    title: "GitHub: Setting your commit email address"
---

# Git Author Privacy

## Rule

Before committing, verify that `git config user.name` and
`git config user.email` are set to a public identity — not your system
hostname or local username. Use your GitHub username and the GitHub
noreply email.

```bash
git config user.name "your-github-username"
git config user.email "12345+your-github-username@users.noreply.github.com"
```

## Why

Git embeds the author name and email in every commit. If these contain
private information:

- **Hostname leakage** — `user.name` might be set to your machine's
  hostname (e.g., `micros-macbook-pro.local`). This reveals your
  hardware and network naming to anyone who reads the commit.
- **Username leakage** — `user.name` might be your OS username
  (e.g., `micro`). This is a partial identity leak.
- **Personal email exposure** — `user.email` might be a personal email
  that you don't want public in every commit on every repo you
  contribute to.

Once a commit is pushed to a public repo, the author metadata is
permanent. Even if you force-push to remove it, the original commit may
be cached by GitHub, forks, or CI logs.

## Detection

Check for private patterns in the author info:

```bash
NAME=$(git config user.name)
EMAIL=$(git config user.email)

# Flag if name matches hostname or OS username
echo "$NAME" | grep -qiE "$(hostname | sed 's/\..*//')|$(whoami)"
```

If the check matches, replace with a public identity before committing.

## GitHub Noreply Email

GitHub provides a noreply email that doesn't expose your real address:

```
<id>+<username>@users.noreply.github.com
```

Find your ID at [github.com/settings/emails](https://github.com/settings/emails).
Commits with this email are linked to your GitHub account without
exposing your personal address.

## Related

* [Feature Branch Only](feature-branch-only.md) — set the author before
  creating the branch and committing
* [Upstream Identity](upstream-identity.md) — the commit author is part
  of the identity surface; use a public identity, not a private one
