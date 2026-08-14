# References

Templates and terminology for the `agent-file-upsert` skill.

## Templates

| File | Output path | Audience |
|---|---|---|
| `AGENT-project-root-template.md.tmpl` | `AGENTS.md` | Users (people deploying/using the project) |
| `AGENT-project-developer-template.md.tmpl` | `.agents/knowledge/developer.md` | Developers (people working on the code) |
| `AGENT-project-subfolder-template.md.tmpl` | `{package}/AGENTS.md` | Agents working in a specific package/subtree |
| `convention-detection.md.tmpl` | (reference only) | The skill itself — Phase 0 convention detection workflow |
| `delta-analysis.md.tmpl` | (reference only) | The skill itself — Phase 1b delta analysis workflow |
| `improvements-template.md.tmpl` | `internal-docs/improvements/INDEX.md` + `YYYY/MM/improvements-*.md` | Both humans and agents — potential improvements to consider |
| `anti-patterns-template.md.tmpl` | `internal-docs/anti-patterns/INDEX.md` + `YYYY/MM/anti-patterns-*.md` | Both humans and agents — things explicitly NOT to do |

## Jargon

Terms used throughout the skill and templates, with the reasoning behind each name.

### Audience Separation

Splitting documentation by who reads it: **users** (deploying/using the project) vs **developers** (working on the code). Implemented as separate files, not sections in one file, so developer content is only loaded when an agent is editing code. This is progressive disclosure applied to audience — a user setting up the project never pays the token cost of reading branching strategy or PR checklists.

**Why "audience" not "persona":** Persona implies marketing fiction. Audience is literal — these are two real groups with different needs reading different files.

### Brownfield

An existing codebase that already has code, history, and conventions — as opposed to a greenfield project starting from scratch. The skill is designed for brownfield onboarding: it analyzes what's there and documents it, rather than prescribing what should be there.

### Definition of Done

A checklist that must be satisfied before a PR is mergeable. Lives in the developer file because only developers complete PRs. Includes test/lint/typecheck gates, commit message format, rebase status, and the documentation maintenance pass.

**Why not "PR checklist":** "Definition of Done" is a contract — it defines when work is *finished*, not just what to check. "PR checklist" sounds optional; "Definition of Done" sounds binding.

### DOX

A documentation framework (https://github.com/agent0ai/dox) that treats docs as binding work contracts for subtrees. Several section names in the sub-folder template (Purpose, Ownership, Local Contracts, Verification, JIT Index) are DOX-influenced. The usage and maintenance protocols in the skill (Phase 6, Phase 7) are also DOX-inspired.

**Why we reference but don't rename to DOX terms everywhere:** DOX is external jargon. We adopted the ideas (contracts, traversal, staleness detection) but use self-explaining names where possible (JIT Index instead of Child DOX Index, Universal Contracts instead of just "Contract").

### JIT Index

A directory of pointers to child documentation files, loaded just-in-time when an agent needs context about a specific subtree. Appears in both the root template (pointing to sub-folder AGENTS.md files and the developer guide) and the sub-folder template (pointing to deeper sub-packages).

**Why "JIT" not "Index" or "TOC":** "JIT" (just-in-time) communicates the *loading strategy* — these pointers are followed only when needed, not eagerly. A plain "Index" sounds like a reference list you read up front. The loading behavior is the whole point.

### Local Contracts

Stable rules a specific package enforces within its subtree: API shapes, data formats, invariants. Lives in the sub-folder template. Distinct from Universal Contracts because local contracts must not pollute other packages — a contract in `apps/web/` shouldn't bind `apps/api/`.

**Why "Contracts" not "Rules":** "Contract" implies something binding and stable — you can rely on it not changing silently. "Rules" sounds like guidelines that could be bent. The DOX principle is that these are agreements, not suggestions.

**Why "Local" not "Package":** "Local" emphasizes the scope boundary — these bind only within this subtree. "Package" is a code-organization term; "Local" is a scope term, which is what matters for the hierarchy.

### Nearest-wins Hierarchy

When two AGENTS.md files cover the same path, the closer (more deeply nested) one controls local work details, but no child doc may weaken the hierarchy. An agent reads the chain from root to target, and the nearest doc is the local contract.

**Why "nearest-wins" not "cascading" or "inheritance":** "Nearest-wins" is unambiguous about conflict resolution — the closest doc wins. "Cascading" implies top-down override; "inheritance" implies accumulation. The actual rule is simpler: closest controls local details, parents control repo-wide rules.

### Out of Scope (oos)

Documentation of what the repository explicitly does NOT do, stored in `internal-docs/oos/`. Prevents scope creep and gives other AI prompts context for why features are excluded. Files use the naming convention `oos-YYYYMMDDHHmm-{slug}.md` under `internal-docs/oos/YYYY/MM/`.

**Why a whole directory not a section:** Out-of-scope decisions accumulate over time. A single section would grow unbounded; a directory with date-stamped files keeps institutional memory chronologically organized and individually citable.

### Patterns

Code conventions with concrete ✅ DO / ❌ DON'T examples. Appears in both the developer template (as `<patterns>`) and the sub-folder template (as `Patterns`). More actionable than a style guide — it shows what to do and what to avoid.

**Why "Patterns" not "Code Style":** "Code Style" implies formatting (tabs vs spaces). "Patterns" covers organization, naming, file structure, and idioms — the things that actually trip up agents. Style is a subset; patterns are the whole useful surface.

### Progressive Disclosure

A three-level loading system: (1) metadata always in context, (2) body loaded when triggered, (3) resources loaded as needed. The audience split (root vs developer file) is progressive disclosure applied to who reads what.

**Why not "layered docs":** "Progressive disclosure" is the established UX term for revealing detail on demand. "Layered" implies you read all layers; "progressive" implies you go deeper only when needed.

### Purpose

2-3 sentences on what the project/package does and who it's for. Appears in the root template (as `<purpose>`) and the sub-folder template (as `Purpose`). The DOX term for the same concept.

**Why "Purpose" not "Overview" or "Description":** "Purpose" asks for the *why* — what problem does this solve, for whom. "Overview" invites a rambling description. "Description" is too generic. "Purpose" constrains the writer to the essential.

### Search Hints

Concrete `rg`/`find` commands for locating things within a package. Lives in the sub-folder template. Distinct from JIT Index (which points to *documents*) — Search Hints point to *code*.

**Why "Search Hints" not "JIT Hints":** The old name "JIT Hints" collided with "JIT Index" and conflated two different things. Search Hints are about finding code; JIT Index is about finding docs. The rename separates the concerns.

### Token Efficiency

The principle that the context window is a shared, finite resource. Every line in an AGENTS.md file costs tokens every time it's loaded. This drives the lightweight root (~60-80 lines), the audience split, and the preference for pointers over duplication.

**Why "token" not "space" or "size":** The constraint is literally context-window tokens, not file size on disk. Naming the actual constraint keeps the trade-off honest.

### Universal Contracts

Repo-wide rules that bind all work in the repository: tooling choices, environment activation, package managers. Lives in the root template. Distinct from Local Contracts (sub-folder scoped) and `<boundaries>` (developer-structured).

**Why "Universal" not "Global":** "Global" implies it applies everywhere including outside the repo. "Universal" means it applies to everyone *within this repo* — which is the correct scope.

### Verification

An existing check (test command, lint rule, type check) that validates work in a specific area. Lives in the sub-folder template. If no check exists yet, the section is left empty — making the gap visible rather than hiding it.

**Why "Verification" not "Testing":** Testing is one form of verification. The section may also reference lint rules, type checks, or build gates. "Verification" covers all of them; "Testing" would narrow it.

## Boundaries (always / ask-first / never)

A structured rules format in the developer template:
- **`<always>`** — mandatory practices (run tests, use pnpm, TDD)
- **`<ask-first>`** — changes that require human confirmation (modifying public APIs, changing architecture)
- **`<never>`** — forbidden actions (commit secrets, delete tests, use npm)

**Why three buckets not one list:** A single list of "rules" doesn't communicate severity. "Always" is a habit; "ask-first" is a gate; "never" is a hard stop. The structure tells an agent not just *what* to do but *how binding* each rule is.

### Convention Detection

Phase 0 of the skill — detecting which agent-file convention a project uses
(`AGENTS.md`, `CLAUDE.md`, `AGENT.md`, or combinations) and how they relate
(symlink, referral, independent). The skill always creates `AGENTS.md` as the
primary file; `CLAUDE.md` and `AGENT.md` are maintained as referrals or
symlinks to it.

**Why "convention" not "format":** "Format" implies file structure (YAML,
JSON). "Convention" is about which filename the project uses and how multiple
agent files relate — the social/organizational agreement, not the file
structure.

### Delta Analysis

Phase 1b of the skill — analyzing repository changes (git history) since the
AGENTS.md was last updated to extract positive findings (to add to AGENTS.md),
negative findings (anti-patterns), and improvement candidates. Two-stage:
script generates a structured report, subagent interprets it.

**Why "delta" not "diff" or "changes":** "Delta" is the mathematical term for
the difference between two states — it implies a structured comparison, not
just a raw diff. The analysis produces categorized findings (positive,
negative, improvements), not a line-by-line diff.

### Improvements

Potential improvements to architecture, standards, and processes —
suggestions to consider, not decisions yet. Stored in
`internal-docs/improvements/` with an `INDEX.md` (progressive disclosure:
one-line summaries) and date-stamped detailed files (full rationale, current
state, proposed change, origin). Populated from delta analysis and research
phase findings.

**Why "improvements" not "suggestions" or "ideas":** "Improvement" is
directional — it makes something better. "Suggestion" is passive; "idea" is
unformed. "Improvement" communicates that this is a concrete proposal with
rationale, not a vague notion.

### Anti-Patterns

Things explicitly NOT to do — practices that were tried and found harmful or
inferior. Stored in `internal-docs/anti-patterns/` with an `INDEX.md` (every
entry marked with 🛑) and date-stamped detailed files (`🛑 Anti-Pattern:`
title, `DO NOT DO THIS` preamble). Populated from delta analysis
(revert/removal commits) and research phase anti-pattern discovery.

**Triple marking:** Anti-patterns are marked as negative in three places —
the AGENTS.md reference ("things NOT to do", "do NOT implement"), the
INDEX.md preamble ("Do NOT implement any of these approaches", 🛑 prefixing
every entry summary), and the detailed file (`🛑 Anti-Pattern:` title,
`DO NOT DO THIS` preamble). This prevents any reader from mistaking an
anti-pattern for a recommendation.

**Why "anti-patterns" not "mistakes" or "bad practices":** "Anti-pattern" is
the established software engineering term for a practice that seems good but
is actually harmful. "Mistake" implies a one-off error; "bad practice" is
vague. "Anti-pattern" carries the specific meaning of a repeatable approach
that is known to be inferior.

### Referral

A convention file (`CLAUDE.md`, `AGENT.md`) that contains a single line
pointing to `AGENTS.md` rather than independent content. Either `@AGENTS.md`
(Claude Code native import syntax) or `Refer to [AGENTS.md](AGENTS.md)`.

**Why "referral" not "redirect" or "alias":** "Referral" communicates that
the file points to another for content — like a medical referral. "Redirect"
implies HTTP-style automatic forwarding; "alias" implies the file is the same
file. A referral is a pointer, not a copy and not an alias.

### Symlink (convention)

A filesystem symbolic link from `CLAUDE.md` to `AGENTS.md` — zero
maintenance, changes to `AGENTS.md` automatically reflected. Preferred on
Unix; on Windows, use a referral instead (symlink support is unreliable).

**Why symlink over referral when possible:** A symlink is transparent —
tools that read `CLAUDE.md` automatically get `AGENTS.md` content with no
parsing step. A referral requires the tool to understand the `@AGENTS.md`
import syntax. Symlinks are the Unix-native solution; referrals are the
portable fallback.
