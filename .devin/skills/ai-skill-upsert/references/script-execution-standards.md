# Script Execution Standards

All scripts created by or bundled with a skill must follow these execution standards. These patterns ensure scripts run in the correct environment (devbox), optimize token usage automatically (rtk), and are self-contained runnable via `uv` with no build step (PEP 723).

## Table of Contents

1. [PEP 723 Inline Script Metadata (uv)](#pep-723-inline-script-metadata-uv)
2. [Devbox Environment Detection](#devbox-environment-detection)
3. [RTK (Rust Token Killer) Usage](#rtk-rust-token-killer-usage)
4. [Combined Python Template](#combined-python-template)
5. [Applying These Standards](#applying-these-standards)

## PEP 723 Inline Script Metadata (uv)

Every Python script bundled with a skill MUST include a [PEP 723](https://peps.python.org/pep-0723/) inline script metadata header. This lets `uv run --script <file>.py` provision an ephemeral environment with the declared dependencies automatically — no virtualenv activation, no `pip install`, no build step. The script becomes self-contained and portable.

**Placement:** Shebang first, then the PEP 723 block, then the module docstring, then imports.

**Minimal header (stdlib-only scripts):**

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
```

**Header with dependencies:**

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "requests>=2.31.0",
#     "rich>=13.0.0",
# ]
# ///
```

The `#!/usr/bin/env -S uv run --script` shebang makes the script directly executable (`./script.py`) when `uv` is on PATH. `uv run --script script.py` works regardless of the shebang. The `# /// script` block is the PEP 723 metadata that `uv` parses to provision the environment.

**Rules:**

- Pin `requires-python` to `>=3.11` unless the script uses newer syntax.
- Declare all third-party dependencies in the `dependencies` array — never `pip install` at runtime.
- Prefer the stdlib; omit the `dependencies` array when no third-party packages are needed (faster cold start, fewer supply-chain risks).
- When `uv` is unavailable, `python script.py` still works for stdlib-only scripts (the PEP 723 block is a comment Python ignores). Scripts with declared dependencies require `uv run` or a pre-provisioned venv matching the declared deps.
- Do NOT inline `pip install` or mutate the environment from within the script — `uv run` handles provisioning.

## Devbox Environment Detection

Before executing any bundled script, check whether `devbox` is available and a `devbox.json` exists in the project root. If so, execute scripts via `devbox run --` unless already inside a `devbox shell`.

**Detection pattern (bash):**
```bash
if command -v devbox >/dev/null 2>&1 && [[ -f "devbox.json" ]]; then
    DEVBOX_AVAILABLE=1
else
    DEVBOX_AVAILABLE=0
fi

# Check if already inside a devbox shell
if [[ -n "${DEVBOX_SHELL:-}" ]] || [[ -n "${IN_DEVBOX_SHELL:-}" ]]; then
    DEVBOX_AVAILABLE=0
fi

devbox_run() {
    if [[ "$DEVBOX_AVAILABLE" -eq 1 ]]; then
        devbox run -- "$@"
    else
        "$@"
    fi
}
```

**Detection pattern (python):**
```python
import os
import shutil
import subprocess

def is_devbox_available() -> bool:
    """Check if devbox is available and not already in a devbox shell."""
    if os.environ.get("DEVBOX_SHELL") or os.environ.get("IN_DEVBOX_SHELL"):
        return False
    if not shutil.which("devbox"):
        return False
    return os.path.isfile("devbox.json")

def devbox_run(cmd: list[str]) -> subprocess.CompletedProcess:
    """Run a command through devbox if available, otherwise directly."""
    if is_devbox_available():
        return subprocess.run(["devbox", "run", "--", *cmd], check=True)
    return subprocess.run(cmd, check=True)
```

## RTK (Rust Token Killer) Usage

Within scripts, use `rtk` as a proxy for `git` and other supported commands when available. RTK reduces LLM token consumption by 60-90% by filtering and compressing command outputs.

- **Detection**: Check with `command -v rtk` (bash) or `shutil.which("rtk")` (python)
- **Git commands**: Use `rtk git <args>` instead of `git <args>`
- **Quality checks**: Use `rtk <tool> <args>` for supported tools (eslint, prettier, npm, cargo, pytest, etc.)
- **Fallback**: If `rtk` is not available, use the raw command directly
- **No user permission needed**: This is automatic — do not ask the user whether to use rtk

**Bash wrapper pattern:**
```bash
if command -v rtk >/dev/null 2>&1; then
    RTK_AVAILABLE=1
else
    RTK_AVAILABLE=0
fi

rtk_wrap() {
    local tool="$1"
    shift
    if [[ "$RTK_AVAILABLE" -eq 1 ]]; then
        devbox_run rtk "$tool" "$@"
    else
        devbox_run "$tool" "$@"
    fi
}
```

**Python wrapper pattern:**
```python
def is_rtk_available() -> bool:
    return shutil.which("rtk") is not None

def rtk_wrap(tool: str, *args: str) -> subprocess.CompletedProcess:
    """Run a command through rtk if available, otherwise directly."""
    if is_rtk_available():
        return devbox_run(["rtk", tool, *args])
    return devbox_run([tool, *args])
```

See: <https://github.com/rtk-ai/rtk> for full command coverage.

## Combined Python Template

The canonical Python script template combines the PEP 723 header with devbox and rtk detection. This is what `templates/example-script.py.template` emits and what every bundled Python script should start with:

```python
#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     # "requests>=2.31.0",  # uncomment and list third-party deps here
# ]
# ///
"""
<one-line description>

Usage:
    uv run --script <name>.py <args>
    ./<name>.py <args>          # if uv is on PATH

Quiet by default; --verbose prints full detail; --dry-run prints what would
happen without making changes.
"""

import os
import shutil
import subprocess
import sys


# ---------------------------------------------------------------------------
# Devbox detection
# ---------------------------------------------------------------------------
def is_devbox_available() -> bool:
    if os.environ.get("DEVBOX_SHELL") or os.environ.get("IN_DEVBOX_SHELL"):
        return False
    if not shutil.which("devbox"):
        return False
    return os.path.isfile("devbox.json")


def devbox_run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    if is_devbox_available():
        return subprocess.run(["devbox", "run", "--", *cmd], **kwargs)
    return subprocess.run(cmd, **kwargs)


# ---------------------------------------------------------------------------
# RTK detection
# ---------------------------------------------------------------------------
def is_rtk_available() -> bool:
    return shutil.which("rtk") is not None


def rtk_wrap(tool: str, *args: str, **kwargs) -> subprocess.CompletedProcess:
    if is_rtk_available():
        return devbox_run(["rtk", tool, *args], **kwargs)
    return devbox_run([tool, *args], **kwargs)


def main():
    # TODO: Implement script logic
    pass


if __name__ == "__main__":
    main()
```

## Applying These Standards

- When the AI agent runs bundled scripts directly (outside of scripts), it should also prefer `uv run --script`, `devbox run --`, and `rtk` when available
- The `init_skill.py` and `package_skill.py` scripts in this skill already include these detection patterns and the PEP 723 header
- The `example-script.py.template` template includes the PEP 723 header and detection patterns so new skills inherit them automatically
- When converting workflows to skills, extract deterministic phases into scripts that include the PEP 723 header and detection patterns at the top
- When updating an existing skill (Mode C upsert), audit bundled Python scripts for the PEP 723 header and add it where missing — propose the change, do not silently apply
