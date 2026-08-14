---
name: shopping-needs-discovery
description: >
  Discover and refine purchasing requirements through structured interviewing.
  Use when a user needs help figuring out what product or service to buy, needs
  to hire a service provider (plumber, electrician, contractor, tutor, etc.),
  has a problem that requires a purchase to solve, or has a vague idea of what
  they want but needs help narrowing it down. Covers: (1) timeline elicitation
  (nice-to-have vs essential deadlines), (2) product-vs-service classification,
  (3) intelligent numbered questions with lettered answer choices and pre-filled
  best-guess defaults, (4) problem-to-product/service mapping when the user
  describes a problem rather than a product, (5) alternative discovery when the
  user names a specific product, (6) product/service recommendation with
  comparative rationale, (7) constraint identification including known defects,
  version pitfalls, reliability issues, seller reputation, licensing/insurance
  requirements for services, and environmental hazards, (8) replacement part
  identification — when the user has a broken item, determines whether a
  specific replacement part is viable and researches the exact manufacturer
  part number for cheaper sourcing than model-name searches, including a
  repairability check that warns when components are soldered, glued, or
  cryptographically paired and cannot be user-replaced, including repair cost
  vs replacement cost analysis. (9) comprehensive constraint identification
  covering obsolescence risks (OS update horizon, company viability, cloud
  dependency death, ecosystem lock-in), used-specific risks (hidden damage,
  counterfeit, battery degradation, non-transferable warranty, recall
  non-compliance), total cost of ownership (subscription lock-in,
  cheap-to-buy-expensive-to-own, maintenance burden, disposal cost),
  environmental and situational mismatches, financial traps, safety/legal
  issues, and real estate constraints (zoning, terrain, access, utilities,
  title, toxicity, market risks). Uses progressive disclosure — an attribute
  index with applicability matrix so only relevant constraint files are
  loaded (e.g., a watch purchase loads repairability and TCO but not real
  estate or consumables; a property purchase loads real estate but not
  obsolescence). Includes service vendor tier differentiation (CPA vs
  bookkeeper, licensed electrician vs handyman) and consumables-specific
  constraints (shelf life, bulk economics, storage). Real estate is split
  into generic constraints plus sub-domains: residential (owner-occupied),
  investment (flip/hold/develop), rental (landlord), commercial (retail/
  office/industrial), and leasee (tenant-side leasing). Product-specific
  domain files cover automobiles (EV/PHEV, hybrid, exotic, truck, RV),
  major appliances (HVAC, water heater, laundry, kitchen, refrigeration,
  spa, commercial vs consumer), small appliances, cameras, mobile phones,
  computers (laptops, desktops, Macs — including Activation Lock, MDM/ABM,
  firmware locks, and receipt retention for lock removal), collectibles,
  yard tools, computer parts (CPU/motherboard, GPU, RAM/storage, PSU/case/
  cooling, monitor/peripherals), and tools (woodworking, metalworking,
  welding, gardening, pottery). Used-device lock verification (Activation
  Lock, iCloud, Find My, MDM/Remote Management, firmware/EFI, BitLocker,
  carrier IMEI blacklist) is covered with do-with-seller vs do-later
  in-person handoff steps. Leasee (tenant) is split into
  generic tenant constraints plus home rental, apartment rental, and
  commercial lease sub-domains. Section 5 documents the 3-level progressive
  disclosure chain (attribute index → attribute files → domain files) with
  worked examples.
version: 1.9.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2026-03-24"
  knowledge-basis: "2026-07-30"
  last-used: "2026-07-30"
tags: ["ai/skill", "commerce", "shopping", "needs-assessment", "product-research"]
see-also:
  - skill: "shopping-deal-intelligence"
    relationship: "dependent"
    description: "Consumes the Needs Discovery Brief to research pricing, sourcing, and timing"
  - skill: "shopping-acquisition"
    relationship: "dependent"
    description: "Final execution layer — completes purchases or service bookings identified by needs-discovery"
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
dependencies:
  - type: skill
    name: shopping-deal-intelligence
  - type: skill
    name: shopping-acquisition
  - type: url
    name: Consumer Reports
    url: https://www.consumerreports.org/
  - type: url
    name: Wirecutter
    url: https://www.nytimes.com/wirecutter/
  - type: url
    name: NHTSA Recalls
    url: https://www.nhtsa.gov/recalls
  - type: url
    name: CPSC Recalls
    url: https://www.cpsc.gov/Recalls
  - type: url
    name: Thumbtack
    url: https://www.thumbtack.com/
  - type: url
    name: Angi
    url: https://www.angi.com/
  - type: url
    name: Google Local Services
    url: https://ads.google.com/local-services-ads/
  - type: url
    name: Yelp
    url: https://www.yelp.com/

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



# Shopping Needs Discovery

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

