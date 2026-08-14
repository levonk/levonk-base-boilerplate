---
type: Synthesis
title: Upstream Contribution Practices Overview
description: Synthesis of fork-PR best practices extracted from real upstream contribution work.
tags: [upstream-contribution, fork, pull-request, github, overview, synthesis]
date:
  created: "2026-07-14"
  knowledge-basis: "2026-07-14"
  last-used: "2026-07-14"
sources:
  - id: nixify-skill
    resource: https://github.com/levonk/skills-src/tree/main/src/current/skills/software-dev/nixify
    title: "nixify skill"
  - id: yusukebe-ax-pr-27
    resource: https://github.com/yusukebe/ax/pull/27
    title: "yusukebe/ax PR #27"
---

---
description: STE100-inspired Simplified Technical English guidelines for technical prose output — active voice, short sentences, one-word-one-meaning, imperative for instructions
---

### Simplified Technical English (STE100-Inspired)

This artifact produces technical English (instructions, procedures, descriptions,
reference documentation). Apply these STE100-inspired guidelines to all technical
prose output so the result is unambiguous, translatable, and easy to read for
non-native speakers and for AI agents that must execute the steps precisely.

These are **STE-inspired guidelines**, not the full ASD-STE100 vocabulary
restriction. Domain terms (Dockerfile, pnpm, devbox, Nx, etc.) are permitted
when they are the correct technical term — STE100's 1000-word approved
vocabulary is too narrow for this domain. The goal is the *clarity discipline*
of STE100, not its word list.

For the full writing rules, before/after examples, and the approved-words
reference, see the
[Simplified Technical English](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/simplified-technical-english.md)
and
[Detailed Guide](https://github.com/levonk/skills-releases/blob/main/knowledge/simplified-technical-english/detailed-guide.md)
concept pages in the `simplified-technical-english` knowledge bundle. The
bundle is the canonical, publicly-reachable home for these guidelines; this
include is the build-time gist that gets inlined into skills and other
bundles.

#### Core Principles

1. **One word, one meaning.** Pick one term for each concept and use it
   everywhere. Do not alternate between "image" and "container image" and
   "docker image" for the same thing. Pick one, define it once, reuse it.

2. **Short sentences.** Keep procedural sentences under 20 words. Keep
   descriptive sentences under 25 words. Split long sentences into two.

3. **Active voice.** Write "The build copies the file" not "The file is copied
   by the build." The actor does the action. Passive voice hides who does what
   and is the single largest source of ambiguity in technical prose.

4. **Imperative mood for instructions.** Write "Run the tests" not "You should
   run the tests" or "The tests should be run." Instructions tell the reader
   (or agent) what to do, directly.

5. **One topic per sentence.** One idea per sentence. Do not chain unrelated
   clauses with "and" or "while." If a sentence has two ideas, split it.

6. **Consistent verb forms.** Use the same verb for the same action across the
   document. If you "run" a script in section 1, do not "execute" it in
   section 2. Pick one verb per action and keep it.

7. **Approved modifiers only.** Avoid decorative adjectives and adverbs
   ("very", "extremely", "simply", "just"). Keep modifiers that carry
   information ("non-root", "read-only", "idempotent"). Drop modifiers that
   carry only emphasis.

8. **Define every acronym on first use.** Write "Continuous Integration (CI)"
   on first use, then "CI" thereafter. Never assume the reader knows the
   acronym.

#### What Counts as Technical English

Apply these guidelines to:

- Procedural instructions ("Run `just build`", "Add the user to the group")
- Descriptions of failure modes, symptoms, and practices
- Reference documentation and concept pages
- Checklists and review guidance
- Synthesis and overview prose in knowledge bundles

Do **not** apply these guidelines to:

- Code, commands, and file paths (those have their own syntax)
- Frontmatter and structured data (YAML, JSON)
- Diagrams and their source syntax (Mermaid, PlantUML)
- Business communication, marketing copy, or creative content
- Log entries and change logs (those are append-only records)

#### Quick Self-Check

Before finishing a piece of technical prose, run this checklist:

- [ ] Is every sentence under 25 words? (Procedural: under 20.)
- [ ] Is every sentence active voice? (Or is the passive voice intentional and
      necessary?)
- [ ] Are instructions in imperative mood?
- [ ] Does each technical term have one and only one form in this document?
- [ ] Is every acronym defined on first use?
- [ ] Are decorative modifiers removed?
- [ ] Does each sentence carry one topic?

If any answer is "no," revise before publishing.


# Upstream Contribution Practices Overview

This bundle documents practices for contributing to upstream open-source
projects via the fork → branch → PR workflow. Each concept was extracted
from a real failure mode — a PR that was rejected, corrupted, or delayed
because the practice wasn't followed.

## The Contribution Lifecycle

```
pre-flight → fork → clone → rebase → branch → baseline tests → work → sync → rebase → commit feature → format → lint → commit style → scan → build → test → push → review → post → validate
```

Each phase has practices that prevent specific failure modes:

| Phase | Practice | Prevents |
|-------|----------|----------|
| Pre-flight | [Contribution Eligibility](contribution-eligibility.md) | Wasted work on projects that reject external PRs or have risky CLAs |
| Pre-flight | [Search Before Opening](search-before-opening.md) | Duplicate issues/PRs, re-litigating settled rejections |
| Pre-flight | [Forge Template Discovery](forge-template-discovery.md) | Drafting for the wrong forge or missing a `blank_issues_enabled: false` constraint |
| Pre-flight | [Follow Project Conventions](follow-project-conventions.md) | Review feedback asking to match changelog/template/doc style |
| Branch creation | [Feature Branch Only](feature-branch-only.md) | Cannot create PR, polluted default branch, broken sync |
| Branch creation | [Sync Before Push](sync-before-push.md) | Stale base, conflicts at PR time |
| Branch creation | [Git Author Privacy](git-author-privacy.md) | Private hostname/username leaked in commit metadata |
| Pre-work | [Test Baseline](test-baseline.md) | Can't distinguish your breakage from pre-existing failures |
| Development | [Minimal Scope](minimal-scope.md) | PR rejected for being too broad, mixing unrelated changes |
| Development | [Upstream Identity](upstream-identity.md) | PR references fork instead of upstream |
| Development | [No User Identity Leak](no-user-identity-leak.md) | Local paths, usernames, or fork-specific config leaked in file content |
| Pre-commit | [Format Artifacts](format-artifacts.md) | Review feedback asking to run project formatter |
| Pre-commit | [Lint Artifacts](lint-artifacts.md) | Upstream lint CI failing on a PR that builds but has style/pattern issues |
| Pre-commit | [Verify Command Currency](verify-command-currency.md) | Shipping deprecated tool syntax that breaks for users on current versions |
| Commit | [Separate Style Commit](separate-style-commit.md) | Format and lint changes hidden inside feature diff, causing review friction |
| Commit | [Massive-Change Guard](massive-change-guard.md) | Formatter or linter auto-fix reformatting entire modified files, expanding PR scope |
| Pre-push | [Rebase, Never Merge](rebase-never-merge.md) | Merge commits polluting upstream history |
| Pre-push | [Linear History](linear-history.md) | Iterative commits cluttering the PR |
| Issue/PR posting | [Human Review Gate](human-review-gate.md) | Wrong content published to public upstream repo |
| Issue/PR posting | [gh --body-file](gh-body-file.md) | Corrupted body (literal `\n`, stripped backticks) |

## Source

These practices were extracted from the nixify skill
(`src/current/skills/software-dev/nixify/`), which has run against
multiple upstream projects. The skill encodes them as procedural steps;
this bundle extracts the generalizable knowledge so it applies to any
fork-PR work, not just Nix flake additions.

## Compounding

New lessons from future fork-PR work should be filed as new concept
pages. The trigger for adding a concept is: a review comment, rejected
PR, or debugging session that revealed a practice the bundle doesn't
yet cover. Append to `log.md` when adding.

## Related Knowledge Bundles

These contribution practices apply whenever filing new concepts into any of the
domain bundles produced by the upsert skills:

- [container-best-practices](../container-best-practices/overview.md)
- [java-best-practices](../java-best-practices/overview.md)
- [data-engineering-best-practices](../data-engineering-best-practices/overview.md)
- [typescript-monorepo-best-practices](../typescript-monorepo-best-practices/overview.md)
- [devsecops-codeguard](../devsecops-codeguard/overview.md)
