# Prompt: Update readme-upsert Skill for First-Class Greenfield Support

Paste the prompt below into a fresh session targeting the `readme-upsert` skill
at `/Users/micro/p/gh/levonk/skills-src/src/current/skills/ai/readme-upsert/`.

---

## Prompt

Update the `readme-upsert` skill at
`/Users/micro/p/gh/levonk/skills-src/src/current/skills/ai/readme-upsert/` so
that **greenfield** projects (empty or just-scaffolded directories with no git
history, no existing README, and minimal source files) are a first-class
supported case, fully peer to the existing **brownfield** case. The skill
already claims greenfield support in its description and Phase 3 ("No existing
README: Create from the template"), but the framing, tags, and Phase 1
workflow are heavily brownfield-biased. Make the greenfield path explicit and
verifiable.

### Why

The `project-adopter` skill now delegates README creation/update to
`readme-upsert` (see
`/Users/micro/p/gh/levonk/skills-src/src/current/skills/software-dev/project-adopter/SKILL.md.tmpl`
Quick Start step 13 and "Repository & Ignore File Management" section). For
`project-adopter`'s Example 1 (new Next.js app from `create-next-app`), the
target directory has no git history, no existing README, no `internal-docs/`,
and only the scaffold files `create-next-app` produced. `readme-upsert` must
handle that cleanly without forcing the agent to pretend it's analyzing a
mature codebase.

### Required Changes

1. **Frontmatter** (`SKILL.md.tmpl`)
   - Add `greenfield` to `tags` alongside `brownfield`
   - Update `description` to explicitly name both cases: "Generate a project's
     README.md from scratch (greenfield) or update an existing one (brownfield).
     Use when creating a new project's README, onboarding a human to an
     existing codebase, or refreshing a stale README."
   - Bump `version` (1.1.0 → 1.2.0) and update `date.knowledge-basis` /
     `date.last-used` to today (2026-07-19)
   - In `see-also`, add `project-adopter` with relationship `caller` and a
     description noting that project-adopter delegates README generation to
     this skill for both greenfield and brownfield adoptions

2. **Scope section** — add an explicit two-case framing:

   > This skill handles two cases with equal first-class support:
   >
   > - **Greenfield**: No existing README, minimal or no source files, no git
   >   history. Create a README from
   >   `references/README-project-root-template.md.tmpl` adapted to whatever
   >   the scaffold / detection step found (language, package manager, build
   >   tool). Do NOT fail Phase 1 just because there is little to analyze.
   > - **Brownfield**: Existing codebase, possibly an existing README. Preserve
   >   accurate sections, update stale ones, run the full consistency check.

3. **Phase 1: Repository Analysis** — add a "Greenfield short-circuit" branch
   at the top:

   > If no `README.md` exists AND the directory has fewer than ~10 tracked
   > files (or no `.git/`), treat this as a **greenfield** case: skip the
   > "Review Documentation" and "Analyze Structure" deep dives; instead,
   > detect only the essentials (language, package manager, build tool, entry
   > point) from whatever scaffold files exist (`package.json`, `Cargo.toml`,
   > `pyproject.toml`, `go.mod`, `devbox.json`, `justfile`, etc.). Proceed
   > directly to Phase 2 with that minimal context.

4. **Phase 2: Generate README.md** — add a greenfield note:

   > For greenfield projects, lean on the template more heavily. Required
   > sections (Project name + overview, Quick Start, Build/Test Commands,
   > Project Structure, AI Agent Documentation) are non-negotiable, but
   > optional sections (Development Workflow, Testing, Package Management,
   > Troubleshooting, Contributing, License) should be included only when the
   > scaffold already implies them (e.g., include "Package Management" only
   > if a package manager was detected).

5. **Phase 3: Upsert** — the existing three bullets are fine; just make sure
   the "No existing README" bullet explicitly says "greenfield: create from
   the template, adapted to the detected stack (language, package manager,
   build tool)".

6. **Phase 4: Cross-Reference Check** — add a greenfield guard:

   > For greenfield projects, `internal-docs/oos/` and `internal-docs/adr/`
   > typically do not exist yet — skip those link checks. Still verify the
   > README links to `AGENTS.md` if (and only if) `AGENTS.md` was created by
   > the caller (e.g., `project-adopter` step 10) before readme-upsert runs.

7. **Phase 5: Consistency Verification** — add a greenfield guard for
   `scripts/verify_consistency.py`:

   > For greenfield projects, `verify_consistency.py` may report missing
   > `internal-docs/oos/` and `internal-docs/adr/` references — those are
   > expected and should not fail the check. If `AGENTS.md` does not yet
   > exist, the cross-checks against AGENTS.md should be skipped (with a
   > logged warning) rather than failing. Consider adding a `--greenfield`
   > flag to `scripts/verify_consistency.py.tmpl` that relaxes these
   > checks; document it in the script's `--help`.

8. **`references/README-project-root-template.md.tmpl`** — review the template
   and confirm it works for a greenfield project with minimal context. If any
   required section assumes an existing codebase (e.g., "Project Structure"
   listing directories that may not exist yet), add a note that the agent
   should adapt the structure listing to what was actually detected, and omit
   directories that do not exist.

9. **`scripts/verify_consistency.py.tmpl`** — add a `--greenfield` flag (or
   auto-detect via "no README + <10 files") that:
   - Skips `internal-docs/oos/` and `internal-docs/adr/` link checks
   - Skips AGENTS.md cross-checks if `AGENTS.md` does not exist
   - Still enforces required README sections and internal link integrity
   - Prints a clear "greenfield mode" banner so the agent knows which checks
     were relaxed

10. **EXAMPLES.md or a new `references/greenfield-example.md`** — add a worked
    greenfield example showing:
    - Input: empty directory after `pnpm dlx create-next-app@latest my-app`
    - Detected essentials: TypeScript, pnpm, Next.js, `src/app/` entry point
    - Generated README (excerpt of the key sections)
    - `verify_consistency.py --greenfield` output

11. **Cross-link from `project-adopter`** — after this update lands, the
    `project-adopter` skill's `see-also` entry for `readme-upsert` (already
    added in the project-adopter v2.2.0 update) remains accurate. No
    back-reference change needed in `project-adopter`.

### Validation

After the changes, run:

```bash
cd /Users/micro/p/gh/levonk/skills-src
just validate
just build current
```

Both must pass. Then verify the greenfield path manually:

```bash
mkdir -p /tmp/greenfield-test && cd /tmp/greenfield-test
pnpm dlx create-next-app@latest my-app --typescript --tailwind --eslint
cd my-app
# Simulate project-adopter having created AGENTS.md:
echo "# AGENTS.md" > AGENTS.md
# Invoke readme-upsert workflow per the updated SKILL.md (greenfield branch)
# Confirm: README.md created, required sections present, verify_consistency.py
# passes in greenfield mode
```

### Out of Scope

- Do NOT change the brownfield workflow — it already works.
- Do NOT add new dependencies.
- Do NOT change the template's required-sections list (only document
  adaptation guidance for greenfield).
- Do NOT touch other skills in the `ai/` upsert family.

### Reference Context

- `readme-upsert` SKILL.md.tmpl:
  `/Users/micro/p/gh/levonk/skills-src/src/current/skills/ai/readme-upsert/SKILL.md.tmpl`
- `readme-upsert` consistency checker:
  `/Users/micro/p/gh/levonk/skills-src/src/current/skills/ai/readme-upsert/scripts/verify_consistency.py.tmpl`
- `readme-upsert` README template:
  `/Users/micro/p/gh/levonk/skills-src/src/current/skills/ai/readme-upsert/references/README-project-root-template.md.tmpl`
- Caller skill (project-adopter) delegation contract:
  `/Users/micro/p/gh/levonk/skills-src/src/current/skills/software-dev/project-adopter/SKILL.md.tmpl`
  (see "Repository & Ignore File Management" section, readme-upsert row)
- Skills-src AGENTS.md:
  `/Users/micro/p/gh/levonk/skills-src/src/current/skills/AGENTS.md`
