---
name: ui-ux-test-upsert
description: "Create or update UI/UX tests for web and mobile applications using a two-tier testing model: deterministic requirements coverage (agent-browser for web, agent-device for mobile — no API keys needed) and AI-driven usability testing (Stagehand for web, finalrun-agent for mobile — BYOK). Generates coverage test specs from requirements documents, usability test specs from natural-language user tasks, wires them into CI with graceful missing-key handling, and ensures the quality gate degrades gracefully when LLM keys are absent. Use when setting up UI/UX testing for a project, creating UI requirements coverage tests, creating UX usability tests, adding agent-browser or agent-device to CI, integrating Stagehand or finalrun-agent, or enforcing UI/UX quality standards. Triggers on 'set up UI testing', 'create UX tests', 'UI requirements coverage', 'UX usability testing', 'agent-browser tests', 'agent-device tests', 'Stagehand tests', 'finalrun tests', 'UI/UX quality gate', or 'ui-ux test upsert'. Make sure to use this skill whenever the user mentions UI/UX testing setup, requirements coverage testing, usability test creation, or wants to enforce that all UI requirements are represented and users can accomplish tasks without documentation, even if they don't explicitly ask for 'ui-ux-test-upsert'. Do NOT trigger on writing unit tests (use unit-test-writing), running existing test suites (use code-quality-validation), planning refactors (use refactor-planning), setting up CI/CD pipelines (use cicd-upsert), or general testing questions — this skill creates and wires UI/UX tests, it does not run them or manage the pipeline."
version: 1.0.0
owner: "https://github.com/levonk"
status: "ready"
user-invocable: true
disable-model-invocation: true
skill-type: hybrid
audience: ["developer", "qa-engineer", "agent-author"]
freedom: medium
date:
  created: "2026-08-08"
  knowledge-basis: "2026-08-08"
  last-used: "2026-08-08"
tags:
  - "ai/skill"
  - "ui-testing"
  - "ux-testing"
  - "requirements-coverage"
  - "usability"
  - "agent-browser"
  - "agent-device"
  - "stagehand"
  - "finalrun-agent"
  - "web"
  - "mobile"
  - "ios"
  - "android"
  - "quality-gate"
see-also:
  - skill: unit-test-writing
    relationship: "sibling"
    description: "Peer test-writing skill for unit tests (Osherove style). This skill is the UI/UX equivalent — it creates UI requirements coverage tests and UX usability tests. Both are foundational test-writing skills that other skills dispatch to"
  - skill: project-adopter
    relationship: "dependent"
    description: "Project-adopter sets up project infrastructure and can dispatch this skill to wire UI/UX testing into the project's quality gate during adoption"
  - skill: code-quality-validation
    relationship: "complement"
    description: "Runs the test suite including UI/UX tests created by this skill. This skill creates the tests; code-quality-validation executes them"
  - skill: cicd-upsert
    relationship: "complement"
    description: "Builds the CI/CD pipeline. This skill provides the UI/UX test steps that cicd-upsert wires into the pipeline"
  - skill: project-detection
    relationship: "dependency"
    description: "Detects the project's platform (web, iOS, Android, React Native) and test framework so generated tests use the project's existing tooling"
  - skill: regression-test-mining
    relationship: "related"
    description: "Mines git history for bug-fix commits and dispatches unit-test-writing. This skill is the UI/UX counterpart — it creates tests from requirements and user tasks rather than from git history"
  - knowledge: cicd-testing-practices
    relationship: "reference"
    description: "Knowledge bundle containing the UI requirements coverage and UX usability testing practices this skill implements"
dependencies:
  - type: skill
    name: project-detection
    reason: "Required for detecting the project's platform (web, iOS, Android) and existing test framework"
  - type: url
    name: agent-browser
    url: https://github.com/vercel-labs/agent-browser
    reason: "Web requirements coverage tool — deterministic accessibility-tree inspection CLI"
  - type: url
    name: agent-device
    url: https://github.com/callstack/agent-device
    reason: "Mobile requirements coverage tool — deterministic accessibility-tree inspection CLI for iOS/Android"
  - type: url
    name: Stagehand
    url: https://github.com/browserbase/stagehand
    reason: "Web usability testing tool — AI-driven natural-language browser automation"
  - type: url
    name: finalrun-agent
    url: https://github.com/final-run/finalrun-agent
    reason: "Mobile usability testing tool — AI-driven natural-language mobile app testing CLI"
  - type: knowledge
    name: cicd-testing-practices
    reason: "Knowledge bundle with the UI requirements coverage and UX usability testing practices"

---

---
description: Wrapper-level hub include for skill SKILL.md files — bundles self-update requirement and CLI tool discovery. Used by the wrapper pattern (SKILL.md is a thin wrapper that runs refresh.sh then reads INSTRUCTIONS.md).
---

---
description: Self-update requirement template for AI guidance files to track usage for maintenance and cleanup
---

### Self-Update Requirement

**CRITICAL**: When this guidance file is called, you MUST update the `last-used`
field in this file's front-matter to the current date (YYYY-MM-DD format) before
proceeding with any other work. This tracks usage for maintenance and cleanup
purposes.

After updating `last-used`, the `freshness-check` include (which follows this
one in `base-ai-guidance`) checks whether the artifact's 3rd-party technology
references are stale (>90 days since `date.knowledge-basis`). If stale, it
prompts a subagent validation pass and user-approved source update. See
`freshness-check.md` for the full protocol.


---
description: Shared CLI tool discovery — run cli-tool-discovery.sh to find and run tools through environment wrappers and standard PATH locations before giving up. Also resolves the canonical ad-hoc runner for an ecosystem (python/node/rust/go) via --runner.
---

### CLI Tool Discovery

Before concluding a CLI tool is unavailable, run `cli-tool-discovery.sh`. It
detects environment wrappers (devbox, mise, flox, direnv, nix), searches 30+
standard PATH locations, checks package managers (brew, mise, asdf), and
accounts for the project's tech stack — all in one pass. **Never give up on
the first `command -v` failure.**

For ad-hoc package execution (e.g. `uvx`, `pnpm dlx`, `cargo binstall`, `go
install`), use `--runner <ecosystem>` instead of resolving the binary and
hardcoding the invocation. The runner mode is the single source of truth for
"how do I invoke an ad-hoc command in ecosystem X?" — it pairs the binary
resolution with the canonical invocation pattern from the tech-stack table.

#### Get the script

```bash
# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time
bash scripts/cli-tool-discovery.sh <tool-name>

# Workflows, agents, and rules (no scripts/ directory): fetch from the public releases repo
curl -fsSL https://raw.githubusercontent.com/levonk/skills-releases/main/includes/cli-tool-discovery.sh -o /tmp/cli-tool-discovery.sh
bash /tmp/cli-tool-discovery.sh <tool-name>
```

#### Usage

```bash
# Resolve only — print where the tool is or how to run it
cli-tool-discovery.sh <tool-name>          # text output
cli-tool-discovery.sh <tool-name> --json   # JSON output (for scripts)

# Resolve and exec — runs the tool through the right wrapper/path, never returns
cli-tool-discovery.sh -- <tool-name> [args...]

# Resolve the ad-hoc runner for an ecosystem (JSON only)
cli-tool-discovery.sh --runner <python|node|rust|go>
```

#### Output (resolve mode)

| Output | Meaning | Action |
|--------|---------|--------|
| `FOUND: <path>` | Tool found at a specific path | Use that path directly |
| `WRAPPER: <wrapper-cmd>` | Tool is inside an environment wrapper | Run via the wrapper (e.g. `devbox run -- <tool>`) |
| `NOT_FOUND: <tool>` | Tool not found anywhere | Install it (ask user first) |

In exec mode (`--`), the script resolves the tool and replaces itself with
the tool process — stdout/stderr/exit code pass through directly. If the tool
is inside a wrapper, it execs through the wrapper. If not found, exits 127.

#### Output (runner mode)

`--runner <ecosystem>` emits JSON only:

```json
{
  "ecosystem": "python",
  "binary": "uv",
  "binary_status": "found",
  "binary_path": "/usr/local/bin/uv",
  "wrapper": "",
  "script": "uv run --script",
  "package": "uvx",
  "fallback": "pip install + python3",
  "fallback_runner": "python3",
  "recommendation": ""
}
```

| Field | Meaning |
|-------|---------|
| `binary` | The canonical binary for the ecosystem (`uv`, `pnpm`/`bun`, `cargo`, `go`) |
| `binary_status` | `found` (use `binary_path`), `wrapper` (use `wrapper`), `not_found` (use `fallback`/`recommendation`) |
| `script` | The runner for inline-metadata scripts (PEP 723). Empty for ecosystems without an equivalent. |
| `package` | The runner for ad-hoc package execution (`uvx`, `pnpm dlx`, `bunx`, `cargo binstall -y`, `go install`) |
| `fallback` | The fallback approach when the binary is not found (e.g. `pip install + python3`). Empty if no fallback exists. |
| `fallback_runner` | The command to use for the fallback. Empty if no fallback exists. |
| `recommendation` | When `binary_status` is `not_found`: either "add to devbox.json", "use fallback", or "install manually". Empty otherwise. |

Ecosystem mapping:

| Ecosystem | Binary | Script runner | Package runner | Fallback |
|-----------|--------|---------------|----------------|----------|
| `python` | `uv` | `uv run --script` | `uvx` | `pip install + python3` |
| `node` (host) | `pnpm` | — | `pnpm dlx` | none (install pnpm) |
| `node` (container) | `bun` | — | `bunx` | none |
| `rust` | `cargo` | — | `cargo binstall -y` | `cargo install` |
| `go` | `go` | — | `go install` | none |

Container detection for `node`: checks `/.dockerenv`, `$DOCKER_CONTAINER`, or
container markers in `/proc/1/cgroup`. This matches the tech-stack table's
"inside a container → bunx" rule.

The Python include (`cli-tool-discovery.py.tmpl`) provides `resolve_runner(ecosystem)`
returning the same dict shape, for use inside Python scripts that need to
discover the runner programmatically.

#### When to Use

- **Always**, before reporting a tool as "not found" or "not installed"
- When a build/test/lint command fails with "command not found"
- When a skill or workflow script needs a tool that isn't on PATH
- When the user reports a tool "should be installed" but `command -v` fails
- **For ad-hoc package execution**, use `--runner <ecosystem>` instead of
  hardcoding `uvx` / `pnpm dlx` / `cargo binstall` / `go install` — the
  runner mode keeps the binary resolution and the invocation pattern paired
  and consistent with the tech-stack table

#### Anti-Patterns

- **Giving up on first `command -v` failure** — run the script instead
- **Installing a tool without asking** — always confirm before adding packages
- **Ignoring environment wrappers** — if a `devbox.json` exists, the tool is
  likely inside devbox, not on the bare shell
- **Hardcoding `uvx` / `pnpm dlx` / `cargo binstall` / `go install`** — use
  `--runner <ecosystem>` instead so the binary and invocation stay paired
  and the policy lives in one place (the tech-stack table, mirrored by the
  runner mode)



---
description: Reusable trigger guard — when a skill is triggered but the question is a poor fit, answer without the skill, explain why, and offer a rerun on a one-word affirmative
---

### Trigger Guard

If this skill is triggered but the question is a poor fit for it — for example, the question matches one of the "Do NOT trigger on..." cases in this skill's description — follow this protocol:

1. **Answer the question directly.** Do not invoke this skill's process, scripts, or multi-step workflow. Provide the best answer you can without the skill.

2. **Explain briefly that the answer was provided without the skill and why.** One or two sentences. Reference the specific reason from the description's negative-trigger clause. Examples:
   - "Answered without the council because this is a factual question with one right answer — the multi-perspective process wouldn't add value."
   - "Answered without peer-review because there's only one response to review — anonymization and comparison need multiple inputs."
   - "Answered without briefingmemo because this is a fast pressure-test, not a high-stakes strategic decision needing research and governance — use think-assist instead."

3. **Offer a rerun.** Tell the user: "If you'd like to run this through the full skill process anyway, respond with `go`." Use `go` as the suggested affirmative — one word, unambiguous, fast to type.

4. **On `go`, run the skill.** If the user responds with `go` (or any clear affirmative), execute the full skill process regardless of the initial guard assessment. The user's explicit request overrides the guard.

**Why this guard exists:** Skills with "pushy" descriptions over-trigger on questions they can't add value to. The guard prevents wasted effort (running a 5-advisor council on "what's the capital of France") while respecting explicit user intent — if the user wants the heavy process run anyway, one word gets it done.


# UI/UX Test Upsert

## Refresh

Before doing anything else, ensure this skill is current:

1. Run `scripts/refresh.sh`. Its stdout is this skill's current body
   (`INSTRUCTIONS.md`). The script handles: finding pnpm via
   cli-tool-discovery, checking the daily-refresh cache, running
   `pnpm dlx skills update <skill-name>` (sandboxed via nono if available),
   and printing `INSTRUCTIONS.md`.

2. Read the script output. That file contains the actual outcome,
   guardrails, calibration, and current process. Do not proceed until
   you have read it.

If the update fails (no network, pnpm unavailable), the script prints
the on-disk version of `INSTRUCTIONS.md` — stale content is better
than no content.

---

## Content Ordering

This artifact is optimized for machine consumption. Generic framework content
(shared includes, knowledge bundles) appears before the skill-specific body.
This ordering maximizes cross-skill prefix caching: skills that share the same
includes produce identical byte prefixes, so an LLM context cache warmed by one
skill serves all skills that share the same preamble.

This is sub-optimal for human reading — the skill-specific content starts deep
in the file, after the generic preamble. Human readers can jump to the
skill-specific body by searching for the first `# ` heading that follows the
generic sections. Each section is self-contained and documented with its own
heading hierarchy.

---

## Content Ordering

This artifact is optimized for machine consumption. Generic framework content
(shared includes, knowledge bundles) appears before the skill-specific body.
This ordering maximizes cross-skill prefix caching: skills that share the same
includes produce identical byte prefixes, so an LLM context cache warmed by one
skill serves all skills that share the same preamble.

This is sub-optimal for human reading — the skill-specific content starts deep
in the file, after the generic preamble. Human readers can jump to the
skill-specific body by searching for the first `# ` heading that follows the
generic sections. Each section is self-contained and documented with its own
heading hierarchy.

