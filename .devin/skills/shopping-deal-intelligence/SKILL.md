---
name: shopping-deal-intelligence
description: >
  Research pricing, sourcing channels, and optimal purchase timing for products
  and services. Use after needs-discovery has identified candidate products, or
  when the user already knows what they want and needs help finding the best
  deal. Covers: (1) historical price research via CamelCamelCamel, Wayback
  Machine, closed auctions, and deal sites, (2) sourcing across retail,
  auctions, government surplus, neighborhood giveaways, and secondhand shops,
  (3) market timing based on seasonality, weather, economic indicators, search
  traffic, and regulatory changes, (4) purchase optimization via credit card
  benefits, affiliate cashback programs, gift card discounts, and extended
  warranty stacking, (5) part-number sourcing — when the Needs Discovery Brief
  includes a replacement part number, searches by the specific OEM part number
  across suppliers and cross-brand equivalents to avoid the convenience tax of
  model-name searches, (6) warranty comparison across suppliers, brands, and
  conditions with risk-adjusted cost analysis before the final recommendation,
  (7) cross-brand identical product identification — detects when
  differently-branded products are the same OEM product (Kenmore = Whirlpool,
  Acer GB10 = NVIDIA DGX Spark) via model prefix decoding, reference design
  matching, and FCC ID lookup, and compares them so the user can buy the
  cheaper rebrand when differences don't matter, including brand premium
  assessment for luxury and status goods (Rolex vs Grand Seiko, Le Creuset
  vs Lodge) to advise the user when similar quality is available for
  significantly less, (8) auction-specific constraints and participation —
  when sourcing through auction channels (Copart, IAAI, GSA Auctions, GovDeals,
  GovPlanet, US Marshals, Treasury/IRS, county tax deed, state surplus, and
  40+ other platforms), loads vehicle auction constraints (smog/CARB
  compliance for California and strict-emissions states, export-only
  restrictions, salvage/rebuilt title brands, damage level opt-in, dealer
  license requirements), property auction constraints (buildability checklist:
  ingress, topography, zoning, lot dimensions, airspace/underground easements,
  water, electricity, sewage, trash, roads; title risks at auction; risk
  levels by auction type), universal auction constraints (locale/travel,
  registration gating, total acquisition cost calculation), and detailed
  step-by-step participation instructions for each platform. For services,
  includes vendor tier verification (comparing quotes across CPA vs
  bookkeeper, licensed electrician vs handyman) before quote gathering.
version: 1.6.0
owner: "https://github.com/levonk"
status: "ready"
date:
  created: "2026-03-24"
  knowledge-basis: "2026-08-07"
  last-used: "2026-08-07"
tags: ["ai/skill", "commerce", "pricing", "deal-hunting", "market-timing", "cashback", "auctions", "government-surplus"]
see-also:
  - skill: "shopping-needs-discovery"
    relationship: "dependency"
    description: "Discovers and refines purchasing requirements — feeds deal-intelligence with candidate products/services"
  - skill: "shopping-acquisition"
    relationship: "dependent"
    description: "Final execution layer — consumes the Deal Intelligence Report to negotiate, monitor, and complete purchases"
  - template: "base-ai-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
dependencies:
  - type: skill
    name: shopping-needs-discovery
  - type: skill
    name: shopping-acquisition
  - type: url
    name: CamelCamelCamel
    url: https://camelcamelcamel.com/
  - type: url
    name: Slickdeals
    url: https://slickdeals.net/
  - type: url
    name: Wayback Machine
    url: https://web.archive.org/
  - type: url
    name: Google Shopping
    url: https://shopping.google.com/
  - type: url
    name: Rakuten
    url: https://www.rakuten.com/
  - type: url
    name: USA.gov Auctions Portal
    url: https://www.usa.gov/auctions-and-sales
  - type: url
    name: GovAuctions (aggregator)
    url: https://govauctions.app/
  - type: url
    name: GovDeals
    url: https://www.govdeals.com/
  - type: url
    name: GSA Auctions
    url: https://gsaauctions.gov/
  - type: url
    name: GSA Fleet Vehicle Sales
    url: https://www.gsafleet.gov/
  - type: url
    name: IRS Auctions
    url: https://www.irsauctions.gov/
  - type: url
    name: GovLiquidation (DOD surplus)
    url: https://www.govliquidation.com/
  - type: url
    name: CWS Marketing (Treasury/USMS auctioneer)
    url: https://cwsmarketing.com/
  - type: url
    name: Apple Towing / RBEX (USMS vehicle auctions)
    url: https://www.appletowing.com/auctions
  - type: url
    name: PropertyRoom (police auctions)
    url: https://www.propertyroom.com/
  - type: url
    name: GovDeals Canada
    url: https://www.govdeals.ca/
  - type: url
    name: Michigan DTMB Surplus
    url: https://www.michigan.gov/dtmb/services/surplusprogram
  - type: url
    name: Utah State Surplus
    url: https://purchasing.utah.gov/general-services/state-surplus-property/
  - type: url
    name: New York State Store (OGS)
    url: https://ogs.ny.gov/nysstore
  - type: url
    name: Sierra Auction (AZ government surplus)
    url: https://www.sierraauction.com/pages/seller/government-surplus/
  - type: url
    name: AutoBidMaster (Copart broker, public)
    url: https://www.autobidmaster.com/
  - type: url
    name: SCA Auction (IAAI broker, public)
    url: https://sca.auction/
  - type: url
    name: ACV Auctions (dealer-only wholesale)
    url: https://www.acvauctions.com/
  - type: url
    name: CarMax Auctions (dealer-only wholesale)
    url: https://www.carmaxauctions.com/
  - type: url
    name: Hertz Car Sales (rental fleet, fixed-price)
    url: https://www.hertzcarsales.com/
  - type: url
    name: Local Liquidators (commercial liquidation)
    url: https://localliquidators.com/

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



# Shopping Deal Intelligence

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

