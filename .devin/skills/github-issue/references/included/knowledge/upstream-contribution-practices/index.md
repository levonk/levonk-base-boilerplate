---
okf_version: "0.2"
---

# Upstream Contribution Practices

A compounding knowledge base documenting hard-won lessons from
contributing to upstream open-source projects via fork → branch → PR.
Each concept captures a specific failure mode that has occurred in real
PRs and the practice that prevents it.

## Concepts

* [Overview](overview.md) - Synthesis of the full practice set and how the pieces fit together
* [Contribution Eligibility](contribution-eligibility.md) - Verify the project accepts contributions, read CONTRIBUTING.md, check CLA/DCO risk before starting
* [Search Before Opening](search-before-opening.md) - Search existing issues/PRs before opening new ones; don't duplicate work
* [Forge Template Discovery](forge-template-discovery.md) - Discover the correct issue/PR templates and contribution directories for GitHub, GitLab, Forgejo, Gitea, and Bitbucket
* [Feature Branch Only](feature-branch-only.md) - Always develop on a feature branch, never commit to main/master
* [Test Baseline](test-baseline.md) - Run the project's tests before starting; document pre-existing failures; don't fix unrelated bugs
* [Minimal Scope](minimal-scope.md) - One completely working change per PR; don't combine unrelated features
* [Follow Project Conventions](follow-project-conventions.md) - Match existing changelog, template, documentation, and commit message style
* [Git Author Privacy](git-author-privacy.md) - Verify git author doesn't leak hostname/username; use GitHub noreply email
* [No User Identity Leak](no-user-identity-leak.md) - Never include local user directories, usernames, or fork-specific paths in upstream-bound files
* [Upstream Identity](upstream-identity.md) - All code, docs, issues, and PRs reference the upstream owner/repo, not the fork
* [Format Artifacts](format-artifacts.md) - Run the project's own formatter on files you create before committing
* [Lint Artifacts](lint-artifacts.md) - Run linters (yamllint, markdownlint, statix, deadnix) on files you create/modify before the build/test phase; auto-discover project lint configs
* [Separate Style Commit](separate-style-commit.md) - Keep format and lint fixes in one combined style commit, separate from the feature commit so reviewers can see what the tools changed
* [Massive-Change Guard](massive-change-guard.md) - Revert format+lint auto-fix changes that exceed a threshold on files you modified (not created); pre-existing style issues belong to the project
* [Verify Command Currency](verify-command-currency.md) - Tool commands get deprecated; verify every command against current tool documentation before including it in a PR
* [Sync Before Push](sync-before-push.md) - Fetch and rebase onto latest upstream tip before pushing; catch upstream movement during the work phase
* [Rebase, Never Merge](rebase-never-merge.md) - Always rebase from upstream; never merge upstream into a feature branch
* [Linear History](linear-history.md) - Squash iterative commits, no merge commits, clean linear history from upstream to HEAD
* [Human Review Gate](human-review-gate.md) - Present issue/PR content to user before posting; never auto-open
* [gh --body-file](gh-body-file.md) - Never use `gh --body` with inline strings; the two corruption modes that have shipped broken PRs
