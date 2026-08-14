# Refactor Checklist

Pre-refactor, during-refactor, and post-refactor checklists plus the
business-impact prioritization procedure for ordering refactor tasks.

## Pre-Refactor Checklist

Before touching any code:

- [ ] **Typecheck passes** — `tsc --noEmit` (or language equivalent)
- [ ] **Build passes** — full production build succeeds
- [ ] **Lint passes** — `eslint` / `ruff` / `clippy` / etc. with no new warnings
- [ ] **Unit tests pass** — full suite green
- [ ] **Run passes** — the application/service starts and serves a smoke request
- [ ] **Repository is clean** — `git status` shows no untracked, unadded, changed, or staged files
- [ ] **Branch is independent** — on a feature branch, not `main` / `master` / `env/dev` / `env/prod`
- [ ] **Feature branch is up to date** with the base branch (rebase or merge first)

If any gate fails, **stop and fix the baseline first**. A dirty starting state
makes it impossible to tell whether a later failure was caused by your refactor
or pre-existing debt.

## During-Refactor Checklist (per task)

For each task in the prioritized plan:

- [ ] **Smallest viable increment** — make the change as small as possible while still being a complete, verifiable step
- [ ] **Verify typecheck** passes
- [ ] **Verify build** passes
- [ ] **Verify lint** passes with no new warnings
- [ ] **Verify unit tests** pass
- [ ] **Verify run** — service starts and serves a smoke request
- [ ] **Confirm clean repo** — only the intended change is in the working tree
- [ ] **Commit** the verified change (use `git-repository-management` skill for rollback-safe commits with pre/post tags)

If verification fails: **revert the change and re-plan**. Do not accumulate
unverified modifications — that defeats the evolutionary safety net.

## Post-Refactor Checklist

After all tasks are complete:

- [ ] **Typecheck passes**
- [ ] **Build passes**
- [ ] **Lint passes** with no new warnings
- [ ] **Unit tests pass**
- [ ] **Run passes** — service starts and serves a smoke request
- [ ] **Repository is clean** — all changes committed, no leftover files
- [ ] **Summary written** — what was refactored, what was deferred, any new tech debt discovered
- [ ] **Follow-up tasks filed** — deferred items tracked as issues/tickets, not lost

## Task Prioritization Procedure

When creating the task plan in Phase 3, order tasks using this
business-impact ranking (highest priority first):

1. **Security**
   a. Incidents
   b. Immediate high risks
2. **Unplanned outage / reduction in service** (urgent & important tech debt)
3. **Current clients: keep** (work that retains existing clients)
4. **Guaranteed profit opportunities**
5. **Unblock internal teams**
6. **Current clients: upsell**
7. **Acquire clients**
   a. Recurring revenue
   b. Flat revenue
8. **High EBITDA tech debt**
9. **Planned R&D**
10. **Non-outage tech debt: urgent & important**
11. **Speculative R&D**
12. **Tech debt: not urgent & important**
13. **Tech debt: urgent & not important**
14. **Tech debt: not urgent & not important**

### Mapping to the Four-Bucket Model

The SKILL.md body collapses this 14-step ranking into four buckets:

| Bucket | Steps | Why |
|--------|-------|-----|
| **Urgent** | 1-2 | Security incidents and active outages — stop the bleed first |
| **Foundational** | 3-7 | Changes that unblock other tasks or protect existing revenue |
| **Dependent** | 8-11 | Tasks that depend on foundational work being complete |
| **Low priority** | 12-14 | Speculative improvements and nice-to-have cleanups |

## Incident Handling (If a Refactor Surfaces an Incident)

1. **Mitigation** — stop the bleed, reference playbooks, inform stakeholders, update public & private status dashboards
2. **Remediation** — short-term workaround
3. **Analysis** — understand what happened
4. **Post mortem** — file tickets for short-term and long-term fixes, write report, present to stakeholders, communicate to users
5. **Fix prioritization** — short-term fixes first, then long-term fixes

## See Also

- [Code Smell Catalog](code-smell-catalog.md) — what to look for in Phase 2.
- [Legacy Code Techniques](legacy-code-techniques.md) — how to refactor code without tests.

## Sources

- Migrated from `src/current/rules/software-dev/general/code-plan-refactor.md` (Prioritization procedure and workflow sections)
