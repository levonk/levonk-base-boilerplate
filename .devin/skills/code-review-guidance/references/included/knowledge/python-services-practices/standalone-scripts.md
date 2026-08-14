---
type: Practice
title: Standalone Python Scripts (PEP 723)
description: Use PEP 723 inline script metadata with `uv run --script` for small Python scripts that don't warrant a full service or package. Discover `uv` via cli-tool-discovery, fall back to pip if unavailable, and add `uv` to devbox.json when a devbox environment is present.
tags: [python, pep723, uv, scripts, standalone, cli-tool-discovery, devbox]
date:
  created: "2026-07-20"
  knowledge-basis: "2026-07-19"
  last-used: "2026-07-19"
sources:
  - id: pep-723-inline-script-metadata
    resource: https://peps.python.org/pep-0723/
    title: PEP 723 — Inline script metadata
  - id: uv-script-guide
    resource: https://docs.astral.sh/uv/guides/scripts/
    title: uv script guide
  - id: validate-diagram-py
    resource: src/current/skills/content/diagram-upsert/scripts/validate-diagram.py.tmpl
    title: a real PEP 723 script in this repo
  - id: cli-tool-discovery-sh
    resource: src/current/includes/cli-tool-discovery.sh.tmpl
    title: the shared tool discovery logic referenced in Toolchain Discovery
  - id: cli-tool-discovery-py
    resource: src/current/includes/cli-tool-discovery.py.tmpl
    title: the shared tool discovery logic referenced in Toolchain Discovery
---

# Standalone Python Scripts (PEP 723)

## Failure Mode

When the bundle only documents services ([FastAPI Service Layout](fastapi-service-layout.md))
and packages ([Python Package Layout](python-package-layout.md)), authors of small
scripts have no guidance and default to one of two anti-patterns:

- **Over-engineering**: a 50-line script gets a full `pyproject.toml`, `src/`
  layout, `tests/`, and a Dockerfile — boilerplate dwarfs logic and the cost of
  changes is disproportionate to the value.
- **Under-engineering**: a script has no metadata, no declared dependencies, and
  a README that says "pip install requests pyyaml" — it works on the author's
  machine and breaks for the next contributor because the dependency set is
  implicit and the runner is unspecified.

The first wastes time; the second silently breaks consumers. PEP 723 eliminates
both by letting a single `.py` file declare its own metadata.

## Practice

Use **PEP 723 inline script metadata** with **`uv run --script`** as the runner
for any Python script that is not a service or a package. The script is a
single self-contained `.py` file: shebang, metadata block, docstring, imports,
logic. No `pyproject.toml`, no `src/` layout, no virtualenv activation.

### Decision Tree: Standalone Script vs. Package vs. Service

```text
Is it a long-running process (HTTP server, worker, scheduler)?
├── yes → FastAPI service — see FastAPI Service Layout
└── no  → Is it imported by other code, or do you need entry points / tests / version metadata?
         ├── yes → Python package — see Python Package Layout
         └── no  → Standalone script (PEP 723) — this page
```

Concrete criteria for choosing **standalone script**:

- ≤ ~200 lines of logic
- ≤ ~5 third-party dependencies
- Invoked directly (`./script.py` or `uv run --script script.py`), not imported
- No need for entry points, no need for a test suite beyond ad-hoc runs
- No need for Docker (if it grows into a containerized tool, graduate to a package)

If any of those flip — the script grows past ~200 lines, you need tests, you need
to be importable, you need version metadata — graduate to a package (see
[When to Graduate](#when-to-graduate-to-a-package) below).

### PEP 723 Syntax

The `# /// script` block is the metadata. `uv` parses it to provision an
ephemeral environment; Python ignores it (it's a comment). Full spec at
<https://peps.python.org/pep-0723/>.

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests>=2.31.0",
#     "pyyaml>=6.0",
# ]
# ///
```

- **`requires-python`**: pin to `>=3.11` unless the script uses newer syntax.
- **`dependencies`**: list third-party packages with version specifiers. Omit
  the array entirely for stdlib-only scripts (faster cold start, smaller
  supply-chain surface).
- **Placement**: shebang first, then the PEP 723 block, then the module
  docstring, then imports. Never reorder — the metadata block must appear
  before the first non-comment, non-shebang line.

### Shebang

```python
#!/usr/bin/env -S uv run --script
```

The `-S` flag tells `env` to split the rest of the line into separate argv
entries (without it, `env` would treat `uv run --script` as a single
argument). With this shebang and `uv` on PATH, the script is directly
executable: `./script.py`. Without execute permission or without `uv`,
fall back to `uv run --script script.py` or `python3 script.py` (see
[Toolchain Discovery](#toolchain-discovery) below).

### Plain `python3` Compatibility

Python ignores the `# /// script` block — it's a comment. So a PEP 723
script also runs under plain `python3` **if the declared dependencies are
already installed** in the active environment:

```bash
uv run --script script.py    # provisions deps automatically (preferred)
python3 script.py            # works only if deps are already installed
```

This matters for environments without `uv` (locked-down CI, minimal
containers, host Python). The script is not broken in those environments —
it just doesn't auto-provision.

### Concrete Example

A minimal PEP 723 script with one third-party dependency:

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["requests>=2.31.0"]
# ///
"""Fetch and print the public IP address. Standalone PEP 723 script."""

import sys
import requests


def main() -> int:
    try:
        resp = requests.get("https://api.ipify.org", timeout=5)
        resp.raise_for_status()
        print(resp.text)
        return 0
    except requests.RequestException as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
```

For a real example in this repo, see
`src/current/skills/content/diagram-upsert/scripts/validate-diagram.py.tmpl`
— a PEP 723 script that validates Mermaid/PlantUML/Excalidraw diagrams. It
uses the shebang + metadata block at the top, then a normal module docstring
and imports. (It is a `.py.tmpl` because the templater inlines shared content
at build time; the rendered `.py` is a plain PEP 723 script.)

## Toolchain Discovery

Before invoking `uv run --script`, discover the toolchain. Do not assume `uv`
is on PATH — it may be inside a devbox/mise/flox/nix wrapper, in
`~/.local/bin`, or absent. Use the shared `cli-tool-discovery` script in
**runner mode** to resolve both the binary and the canonical invocation in
one call, then follow the decision flow below.

### Decision Flow

```text
1. cli-tool-discovery --runner python
   ├── binary_status: found   → run `<script> script.py` (or `./script.py`)
   ├── binary_status: wrapper → run through wrapper (e.g. `devbox run -- uv run --script script.py`)
   └── binary_status: not_found
       │
       2. recommendation says "add to devbox.json"?
          ├── yes → add "uv" to devbox.json, devbox install, re-run step 1
          └── no
              │
              3. Fall back to pip + python3
                 → pip install <declared deps>, then `python3 script.py`
```

The order matters: **add `uv` to `devbox.json` before resorting to `pip`.**
Devbox is the canonical reproducible environment for this monorepo; a global
`pip install --user` pollutes the host site-packages and bypasses the
lockfile. Only fall back to `pip` when there is no `devbox.json` to extend.

### Resolve the Python runner via cli-tool-discovery

`cli-tool-discovery --runner python` is the single source of truth for the
Python ad-hoc runner. It pairs the binary resolution with the canonical
invocation (`uv run --script` for PEP 723 scripts, `uvx` for ad-hoc packages)
and emits a `recommendation` when the binary is not found.

```bash
# Skills: the script is materialized into scripts/cli-tool-discovery.sh at build time
bash scripts/cli-tool-discovery.sh --runner python

# Workflows, agents, rules (no scripts/ dir): fetch from the public releases repo
curl -fsSL https://raw.githubusercontent.com/levonk/skills-releases/main/includes/cli-tool-discovery.sh \
  -o /tmp/cli-tool-discovery.sh
bash /tmp/cli-tool-discovery.sh --runner python
```

Output (JSON only):

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

- `binary_status: found` → run `<script> script.py` (i.e. `uv run --script script.py`), or `./script.py` if executable.
- `binary_status: wrapper` → run through the wrapper, e.g. `devbox run -- uv run --script script.py`.
- `binary_status: not_found` → check `recommendation`:
  - `"add uv to devbox.json (run: devbox add uv)"` → see [Add `uv` to devbox.json](#add-uv-to-devboxjson-when-a-devbox-environment-is-present) below, then re-run discovery.
  - `"use python3 as fallback"` → see [Fallback to pip](#fallback-to-pip) below.

The `script` field (`uv run --script`) is the runner for PEP 723 inline-metadata scripts. The `package` field (`uvx`) is the runner for ad-hoc package execution (e.g. `uvx ruff check`). Both are sourced from the canonical tech-stack table via the runner mode — see the `cli-tool-discovery` include documentation for the full ecosystem mapping (python/node/rust/go).

The Python equivalent (`cli-tool-discovery.py` include) provides
`resolve_runner("python")` returning the same dict shape, for use inside
Python scripts that need to discover the runner programmatically. It is
inlined into upsert scripts at build time via the templater's `include`
function (the `.tmpl` files contain an `include "includes/cli-tool-discovery.py" .`
directive using the project's custom three-brace delimiters) — see the
`cli-tool-discovery.py` include in `src/current/includes/`.

### Add `uv` to devbox.json When a Devbox Environment is Present

If `cli-tool-discovery --runner python` reports `binary_status: not_found`
**and** the `recommendation` says to add `uv` to `devbox.json`, the right fix
is to add `uv` to that `devbox.json` rather than installing `uv` globally.
Devbox is the canonical environment manager for this monorepo (see the
`dev-environment-practices` knowledge bundle). The `cli-tool-discovery`
script can do this for you — its `ensure_devbox_package` function walks up
from cwd to find the nearest `devbox.json` and adds the package idempotently
(via `devbox add` if devbox is on PATH, else an in-place JSON edit).

Manual walk-up check (bash):

```bash
walk_up() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -f "$dir/devbox.json" ]]; then echo "$dir/devbox.json"; return 0; fi
        dir="$(dirname "$dir")"
    done
    return 1
}
devbox_file="$(walk_up)"
```

If a `devbox.json` is found, add `"uv"` to its `packages`:

- **Array form** (`"packages": ["go", "just"]`): append `"uv"` to the array.
- **Object form** (`"packages": {"go": "latest", "just": ""}`): add `"uv": "latest"`.

Then run `devbox install` (or `direnv reload` if direnv is active) to
provision `uv` into the devbox environment. Re-run `cli-tool-discovery --runner python`
to confirm `binary_status` is now `found` or `wrapper`, then run the script
with `uv run --script`.

Do **not** install `uv` globally (`curl | sh`, `brew install uv`, etc.)
without asking the user first — global installs pollute the host and bypass
the reproducible-environment contract that devbox provides.

### Fallback to pip

If `cli-tool-discovery --runner python` reports `binary_status: not_found`
**and** the `recommendation` says to use the fallback (no `devbox.json`
exists up the tree), fall back to `pip` + `python3` using the
`fallback_runner` field from the runner output:

```bash
# Install the script's declared dependencies into the active environment
python3 -m pip install --user "requests>=2.31.0" "pyyaml>=6.0"

# Run the script — PEP 723 block is a comment to python3
python3 script.py
```

The dependencies to install are exactly the entries in the script's
`# /// script` `dependencies` array. Parse them out of the script (or
re-declare them in a `requirements.txt` if the script is going to be shared
with non-`uv` users long-term — but at that point, graduating to a package is
usually the right move).

Fallback caveats:

- `pip install --user` pollutes the user site-packages; prefer a virtualenv
  (`python3 -m venv .venv && . .venv/bin/activate && pip install ...`) if the
  script will be run more than once.
- `python3 script.py` does **not** verify `requires-python`; check it
  manually (`python3 --version`) before running.
- If the script has no declared dependencies (stdlib-only), skip `pip`
  entirely and just run `python3 script.py`.

## When to Graduate to a Package

A standalone script is the right shape until it isn't. Graduate to a package
(see [Python Package Layout](python-package-layout.md) and
[pyproject.toml Manifest](pyproject-toml-manifest.md)) when **any** of these
become true:

- The script grows past ~200 lines or splits into multiple modules
- You need entry points (`[project.scripts]`) beyond the single file
- You need a test suite (pytest) — tests need to import the code under test
- Other code needs to import the script's functions
- You need version metadata, changelog, or published releases
- The dependency set grows past ~5 packages and you want reproducible locks

The graduation path is mechanical: move the script's `dependencies` array
into `pyproject.toml`'s `[project] dependencies`, move the logic into
`src/<package>/`, add `tests/`, drop the PEP 723 block (it's now
redundant with `pyproject.toml`), and keep the shebang as
`#!/usr/bin/env python3` (or add a `[project.scripts]` entry point and drop
the shebang entirely).

## When Writing a Script as Part of a Skill

If the standalone script is being authored as part of an AI skill (i.e. it
will live in a skill's `scripts/` directory and be materialized at build
time), there is additional guidance about *materializing* shared scripts
into the skill's `scripts/` dir so the installed skill is self-contained.
That guidance is in the `script-materialization` include in
`src/current/includes/` (file `script-materialization.md.tmpl`), wired into
the `ai-upsert` skill. The PEP 723 metadata on this page still applies
— the script is a normal PEP 723 script; the materialization layer just
ensures it ships with the skill instead of being fetched at runtime.

See also the published version at
<https://github.com/levonk/skills-releases/blob/main/includes/script-materialization.md>.

## Related Concepts

- [pyproject.toml Manifest](pyproject-toml-manifest.md) — The canonical
  manifest for packages; PEP 723 is the equivalent for standalone scripts.
- [Python Package Layout](python-package-layout.md) — Graduate here when the
  script outgrows PEP 723.
- [FastAPI Service Layout](fastapi-service-layout.md) — The other branch of
  the decision tree (long-running services).
- [nox Orchestration](nox-orchestration.md) — nox orchestrates test/lint
  pipelines for packages; standalone scripts typically don't need nox.


