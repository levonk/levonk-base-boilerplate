# Maintainability Scoring

## Table of Contents

1. [Overview](#overview)
2. [Activity Signals](#activity-signals)
3. [Health Signals](#health-signals)
4. [Maturity Signals](#maturity-signals)
5. [Combined Rating](#combined-rating)
6. [Quick Assessment (GitHub-only)](#quick-assessment-github-only)

## Overview

Maintainability scoring combines three signal types into a single rating per
project:

| Signal type | Source | When available |
|---|---|---|
| **Activity** | GitHub metadata (last push, commit frequency, archived status) | Always (for GitHub repos) |
| **Health** | `repository-health-review` skill | When local paths are available |
| **Maturity** | `tech-maturity` skill (42 capabilities, 6 dimensions) | Optional deep dive |

## Activity Signals

From the GitHub metadata gathered in Step 2:

| Signal | What it tells you | Concerning | Good |
|---|---|---|---|
| `archived` | Repo is read-only | True = ❌ | False |
| `pushed_at` | Last push to any branch | > 1 year ago | < 3 months ago |
| `open_issues` | Open issue count | High + growing | Low or stable |
| `stars` | Community interest | < 100 (small category) | > 1000 |
| `forks` | Contribution activity | < 10 | > 100 |
| `created_at` → `pushed_at` | Project lifespan | < 6 months old (new) | 2+ years active |

### Activity scoring

| Rating | Criteria |
|---|---|
| 🏆 Excellent | Active (< 1 month since last push), 1000+ stars, 100+ forks, not archived |
| ✅ Good | Active (< 6 months since last push), 100+ stars, 10+ forks, not archived |
| ➖ Neutral | Moderate activity (6-12 months since last push), or new project (< 6 months) |
| ⚠️ Concerning | Low activity (> 1 year since last push), or declining issue backlog |
| ❌ Abandoned | Archived, or > 2 years since last push with open issues |

## Health Signals

When local paths are available, run `repository-health-review` per project.
The skill produces a health score (0-100) across six categories:

1. Outdated Information Detection
2. Conflicting Rules Analysis
3. Undocumented Standards Detection
4. Lessons from Failures Analysis
5. Missing Tool Documentation
6. Security and Access Patterns

### Health scoring

| Rating | Health score | Meaning |
|---|---|---|
| 🏆 Excellent | 90-100 | Minimal issues, well-maintained |
| ✅ Good | 75-89 | Few issues, manageable |
| ➖ Neutral | 60-74 | Some issues, typical for active projects |
| ⚠️ Concerning | 40-59 | Notable issues in security, documentation, or standards |
| ❌ Critical | < 40 | Serious issues, security vulnerabilities, or broken standards |

## Maturity Signals

For a deep maintainability comparison, run `tech-maturity` per project. The
skill scores 42 capabilities across 6 dimensions (Code, Build & Test, Release,
Operations, Security, Architecture) on a 1-4 scale.

### Maturity scoring

| Rating | Overall score | Meaning |
|---|---|---|
| 🏆 Excellent | 3.5-4.0 | Optimized, continuously improving practices |
| ✅ Good | 2.5-3.4 | Established, standardized practices |
| ➖ Neutral | 1.8-2.4 | Defined, documented but not standardized |
| ⚠️ Concerning | 1.0-1.7 | Initial, ad-hoc practices |
| ❌ Critical | < 1.0 | Missing fundamental practices |

## Combined Rating

Combine the three signal ratings into a single maintainability rating:

| Priority | Rule |
|---|---|
| 1 | If any signal is ❌, the combined rating is at best ⚠️ (a critical issue in any dimension is disqualifying) |
| 2 | If all signals are 🏆, combined is 🏆 |
| 3 | If all signals are ✅ or better, combined is ✅ |
| 4 | If any signal is ⚠️, combined is at best ⚠️ |
| 5 | Otherwise, combined is ➖ |

### Example

| Project | Activity | Health | Maturity | Combined |
|---|---|---|---|---|
| Project A | ✅ Good | ✅ Good | ✅ Good | ✅ Good |
| Project B | 🏆 Excellent | ⚠️ Concerning | ➖ Neutral | ⚠️ Concerning |
| Project C | ❌ Abandoned | N/A | N/A | ❌ Abandoned |

## Quick Assessment (GitHub-only)

When only GitHub metadata is available (no local paths), skip health and
maturity scoring. Use activity signals alone:

1. Check `archived` — if true, rating is ❌
2. Check `pushed_at` — calculate days since last push
3. Check `open_issues` relative to `stars` — high ratio is concerning
4. Check `stars` and `forks` for community engagement
5. Assign rating from the Activity scoring table above

Note in the matrix that this is an activity-only assessment, not a full
maintainability assessment. Recommend running `repository-health-review` and
`tech-maturity` on local clones for a complete picture.
