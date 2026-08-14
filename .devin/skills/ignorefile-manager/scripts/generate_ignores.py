#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Generate ignore files from modular concern sources.

Reads concern files from assets/concerns/ and a composition config from
assets/outputs.yaml, then generates output ignore files (.gitignore,
.codeiumignore, .dockerignore, VS Code settings, etc.) by combining,
deduplicating, sorting, and transforming patterns.

Supports three modes:
  generate    — compose outputs from concerns (default)
  reconcile   — scan deployed files for patterns missing from concerns
  audit       — list which outputs are missing or stale in a project

Usage:
  # Generate all outputs to current directory (dry-run)
  uv run --script generate_ignores.py generate --dry-run

  # Generate and write to current directory
  uv run --script generate_ignores.py generate

  # Generate a single output
  uv run --script generate_ignores.py generate --output .gitignore

  # Reconcile: find patterns in deployed files not in any concern
  uv run --script generate_ignores.py reconcile

  # Reconcile with auto-assign (no prompts, accept suggestions)
  uv run --script generate_ignores.py reconcile --auto-assign

  # Audit: check which outputs are missing or stale
  uv run --script generate_ignores.py audit

  # Workspace: find and update all *.code-workspace files with exclude settings
  uv run --script generate_ignores.py workspace --target /path/to/search-root
  uv run --script generate_ignores.py workspace --target /path/to/search-root --dry-run

  # Ripgrep: update ~/.config/ripgrep/config and ripgrepignore deterministically
  uv run --script generate_ignores.py ripgrep
  uv run --script generate_ignores.py ripgrep --dry-run
  uv run --script generate_ignores.py ripgrep --config-dir ~/.config/ripgrep

  # Specify a different target directory
  uv run --script generate_ignores.py generate --target /path/to/project

  # Specify a custom concerns directory (overrides bundled assets)
  uv run --script generate_ignores.py generate --concerns-dir ~/.config/filelists/concerns
"""

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from dataclasses import dataclass, field
from datetime import datetime
from pathlib import Path


import json
import os
import shutil
import subprocess
from pathlib import Path

# Timeout configuration (seconds). Override via environment.
# Probes: lookups (brew list, mise which, rtk rewrite) — short.
# Installs: network fetches (not currently used in Python include, but
# available for callers that need it).
_PROBE_TIMEOUT = float(os.environ.get("CLTOOL_PROBE_TIMEOUT_SECS", "160"))
_INSTALL_TIMEOUT = float(os.environ.get("CLTOOL_INSTALL_TIMEOUT_SECS", "160"))


def _walk_up_find(*patterns: str) -> Path | None:
    """Walk up from cwd looking for any of the given filenames. Return the dir containing the first match."""
    cwd = Path.cwd()
    for d in [cwd, *cwd.parents]:
        for p in patterns:
            if (d / p).is_file():
                return d
    return None


def _detect_wrapper() -> str | None:
    """Detect an environment wrapper for the current directory. Returns the wrapper prefix or None."""
    # Already inside a wrapper shell — skip (single source of truth for env vars)
    if os.environ.get("DEVBOX_SHELL") or os.environ.get("IN_DEVBOX_SHELL"):
        return None
    if os.environ.get("MISE_SHELL"):
        return None
    if os.environ.get("FLOX_ACTIVE"):
        return None
    if os.environ.get("DIRENV_DIR"):
        return None
    if os.environ.get("IN_NIX_SHELL"):
        return None

    # devbox
    if shutil.which("devbox") and _walk_up_find("devbox.json"):
        return "devbox run --"

    # mise
    if shutil.which("mise") and _walk_up_find(".mise.toml", ".mise/config.toml", "mise.toml"):
        return "mise exec --"

    # flox
    if shutil.which("flox") and _walk_up_find("flox.nix"):
        return "flox activate --"

    # direnv
    if shutil.which("direnv") and _walk_up_find(".envrc"):
        return "direnv export &&"

    # nix
    if shutil.which("nix"):
        nix_root = _walk_up_find("flake.nix", "shell.nix")
        if nix_root:
            if (nix_root / "flake.nix").is_file():
                return "nix develop --command"
            return "nix-shell --run"

    return None


def _get_repo_root() -> Path | None:
    """Get git repo root if available."""
    try:
        result = subprocess.run(
            ["git", "rev-parse", "--show-toplevel"],
            capture_output=True, text=True, check=True,
        )
        return Path(result.stdout.strip())
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


def _search_dirs() -> list[Path]:
    """Build the list of directories to search, tech-stack-aware."""
    home = Path.home()
    dirs: list[Path] = []

    # Universal user-local and system dirs
    xdg_bin = os.environ.get("XDG_BIN_HOME")
    if xdg_bin:
        dirs.append(Path(xdg_bin))
    dirs.extend([
        home / ".local/bin",
        home / ".nix-profile/bin",
        Path("/nix/var/nix/profiles/default/bin"),
        home / "bin",
        Path("/usr/local/bin"),
        Path("/usr/local/sbin"),
        Path("/usr/sbin"),
        Path("/usr/bin"),
        Path("/sbin"),
        Path("/bin"),
    ])
    # Homebrew: only check the prefix for the current arch.
    # A Time Machine restore across arches can leave a stale directory
    # with non-universal binaries that won't run.
    import platform
    arch = platform.machine()
    if arch == "arm64":
        dirs.extend([Path("/opt/homebrew/bin"), Path("/opt/homebrew/sbin")])
    elif arch in ("x86_64", "i386"):
        dirs.extend([Path("/usr/local/bin"), Path("/usr/local/sbin")])
    # MacPorts (both arches use /opt/local)
    dirs.append(Path("/opt/local/bin"))
    dirs.extend([Path("/snap/bin"), Path("/run/current-system/sw/bin")])

    # Language/runtime-specific dirs
    dirs.extend([
        home / ".cargo/bin",
        home / ".bun/bin",
        home / ".deno/bin",
        home / ".volta/bin",
        home / "go/bin",
        home / ".rbenv/shims",
        home / ".pyenv/shims",
        home / ".pixi/bin",
        home / ".krew/bin",
        home / ".foundry/bin",
    ])

    # nvm: all installed versions
    nvm_node = home / ".nvm/versions/node"
    if nvm_node.is_dir():
        for v in nvm_node.iterdir():
            b = v / "bin"
            if b.is_dir():
                dirs.append(b)

    # mise/rtx managed tool installs
    for base in [home / ".local/share/mise/installs", home / ".local/share/rtx/installs"]:
        if base.is_dir():
            for inst in base.iterdir():
                b = inst / "bin"
                if b.is_dir():
                    dirs.append(b)

    # Tech-stack-specific repo-local dirs
    repo = _get_repo_root()
    if repo:
        if (repo / "package.json").is_file():
            dirs.extend([repo / "node_modules/.bin", repo / ".bin"])
        if (repo / "Cargo.toml").is_file():
            dirs.extend([repo / "target/release", repo / "target/debug"])
        if (repo / "go.mod").is_file():
            dirs.extend([repo / "bin", repo / ".bin"])
        if (repo / "pyproject.toml").is_file() or (repo / "requirements.txt").is_file():
            dirs.extend([repo / ".venv/bin", repo / ".local/bin"])
        if (repo / "Gemfile").is_file():
            dirs.extend([repo / "bin", repo / ".bundle/bin"])
        if (repo / "composer.json").is_file():
            dirs.append(repo / "vendor/bin")
        # NOTE: Unconditional repo / "bin" is searched LAST (after package
        # managers in resolve_tool) because a cloned repo could contain
        # malicious executables in bin/. Tech-stack-specific dirs above
        # (node_modules/.bin, target/release, .venv/bin, vendor/bin, etc.)
        # are build-system-managed and stay here. Covers Hermit's bin/ shims
        # and similar project-local tool layouts — but only as a last resort.

    return dirs


def ensure_devbox_package(pkg: str) -> bool:
    """Ensure a package is listed in the nearest devbox.json."""
    devbox_dir = _walk_up_find("devbox.json")
    if not devbox_dir:
        return False
    devbox_json = devbox_dir / "devbox.json"
    try:
        with open(devbox_json, "r") as f:
            data = json.load(f)
    except (json.JSONDecodeError, FileNotFoundError):
        return False
    packages = data.get("packages", {})
    if isinstance(packages, dict):
        if pkg not in packages:
            packages[pkg] = ""
            data["packages"] = packages
        else:
            return True
    elif isinstance(packages, list):
        if pkg not in packages:
            packages.append(pkg)
            data["packages"] = packages
        else:
            return True
    else:
        return False
    try:
        with open(devbox_json, "w") as f:
            json.dump(data, f, indent=2)
            f.write("\n")
    except OSError:
        return False
    return True


def resolve_tool(tool: str) -> dict:
    """Resolve a CLI tool. Returns a dict with 'status' and 'path' or 'wrapper'.

    Return values:
        {"status": "found", "path": "/usr/local/bin/go"}
        {"status": "wrapper", "wrapper": "devbox run --"}
        {"status": "fallback", "fallback": "pip", "runner": "..."}
        {"status": "not_found"}
    """
    # 1. Already on PATH?
    path = shutil.which(tool)
    if path:
        return {"status": "found", "path": path}

    # 2. Environment wrapper
    wrapper = _detect_wrapper()
    if wrapper:
        return {"status": "wrapper", "wrapper": wrapper}

    # 3. Standard PATH locations
    for d in _search_dirs():
        candidate = d / tool
        if candidate.is_file() and os.access(candidate, os.X_OK):
            return {"status": "found", "path": str(candidate)}

    # 4. Package manager lookup
    if shutil.which("brew"):
        try:
            subprocess.run(["brew", "list", tool], capture_output=True, check=True,
                           timeout=_PROBE_TIMEOUT)
            prefix = subprocess.run(
                ["brew", "--prefix", tool], capture_output=True, text=True,
                timeout=_PROBE_TIMEOUT
            ).stdout.strip()
            if prefix:
                p = Path(prefix) / "bin" / tool
                if p.is_file() and os.access(p, os.X_OK):
                    return {"status": "found", "path": str(p)}
            brew_prefix = subprocess.run(
                ["brew", "--prefix"], capture_output=True, text=True,
                timeout=_PROBE_TIMEOUT
            ).stdout.strip()
            p = Path(brew_prefix) / "bin" / tool
            if p.is_file() and os.access(p, os.X_OK):
                return {"status": "found", "path": str(p)}
        except (subprocess.CalledProcessError, FileNotFoundError, subprocess.TimeoutExpired):
            pass

    if shutil.which("mise"):
        try:
            result = subprocess.run(
                ["mise", "which", tool], capture_output=True, text=True,
                timeout=_PROBE_TIMEOUT
            )
            if result.returncode == 0 and result.stdout.strip():
                return {"status": "found", "path": result.stdout.strip()}
        except (FileNotFoundError, subprocess.TimeoutExpired):
            pass

    if shutil.which("asdf"):
        try:
            result = subprocess.run(
                ["asdf", "which", tool], capture_output=True, text=True,
                timeout=_PROBE_TIMEOUT
            )
            if result.returncode == 0 and result.stdout.strip():
                return {"status": "found", "path": result.stdout.strip()}
        except (FileNotFoundError, subprocess.TimeoutExpired):
            pass

    # 5. Repo-root fallback dirs — searched LAST (least secure: a cloned repo
    # could contain malicious executables in bin/). Covers Hermit's bin/ shims
    # and similar project-local tool layouts that aren't caught by the
    # tech-stack-specific dirs in _search_dirs().
    repo = _get_repo_root()
    if repo:
        for d in [repo / "bin", repo / "scripts", repo / ".local/bin"]:
            candidate = d / tool
            if candidate.is_file() and os.access(candidate, os.X_OK):
                return {"status": "found", "path": str(candidate)}

    # 6. uv fallback: ensure uv is recorded in devbox.json, then fall back to pip.
    if tool == "uv":
        ensure_devbox_package("uv")
        pip_cmd = None
        if shutil.which("pip3"):
            pip_cmd = "pip3"
        elif shutil.which("pip"):
            pip_cmd = "pip"
        elif shutil.which("python3"):
            pip_cmd = "python3 -m pip"
        if pip_cmd:
            return {
                "status": "fallback",
                "fallback": "pip",
                "runner": pip_cmd,
                "message": (
                    "uv not found; pip is available as a fallback for Python "
                    f"package operations. Consider installing uv with '{pip_cmd} install --user uv'."
                ),
            }

    return {"status": "not_found"}


def run_tool(tool: str, args: list[str], **kwargs) -> subprocess.CompletedProcess:
    """Resolve a tool and run it. If a wrapper is detected, runs through the wrapper.

    Uses subprocess.run (captures output only if kwargs request it).
    For exec (replace process), use run_tool_exec instead.
    """
    result = resolve_tool(tool)
    status = result["status"]

    if status == "found":
        return subprocess.run([result["path"], *args], **kwargs)
    elif status == "fallback":
        if tool == "uv" and result.get("fallback") == "pip":
            runner = result.get("runner", "pip3")
            print(f"[cli-tool-discovery] uv not found; installing uv via {runner}", file=sys.stderr)
            subprocess.run([*runner.split(), "install", "--user", "uv"], check=False)
            if shutil.which("uv"):
                return subprocess.run(["uv", *args], **kwargs)
            raise FileNotFoundError(f"uv could not be installed; {runner} is available as fallback")
        raise FileNotFoundError(f"Tool not found: {tool}")
    elif status == "wrapper":
        wrapper = result["wrapper"]
        if wrapper == "devbox run --":
            return subprocess.run(["devbox", "run", "--", tool, *args], **kwargs)
        elif wrapper == "mise exec --":
            return subprocess.run(["mise", "exec", "--", tool, *args], **kwargs)
        elif wrapper == "flox activate --":
            return subprocess.run(["flox", "activate", "--", tool, *args], **kwargs)
        elif wrapper == "direnv export &&":
            # direnv needs eval — fall back to running direnv export then the tool
            export = subprocess.run(
                ["direnv", "export", "bash"], capture_output=True, text=True
            )
            # Can't easily eval in Python; just run the tool and hope PATH is set
            return subprocess.run([tool, *args], **kwargs)
        elif wrapper == "nix develop --command":
            return subprocess.run(["nix", "develop", "--command", tool, *args], **kwargs)
        elif wrapper == "nix-shell --run":
            return subprocess.run(
                ["nix-shell", "--run", " ".join([tool, *args])], **kwargs
            )
        else:
            raise RuntimeError(f"Unknown wrapper: {wrapper}")
    else:
        raise FileNotFoundError(f"Tool not found: {tool}")


def run_tool_exec(tool: str, args: list[str]) -> None:
    """Resolve a tool and exec it (replaces the current process). Never returns."""
    result = resolve_tool(tool)
    status = result["status"]

    if status == "found":
        os.execv(result["path"], [tool, *args])
    elif status == "fallback":
        if tool == "uv" and result.get("fallback") == "pip":
            runner = result.get("runner", "pip3")
            print(f"[cli-tool-discovery] uv not found; installing uv via {runner}", file=sys.stderr)
            subprocess.run([*runner.split(), "install", "--user", "uv"], check=False)
            if shutil.which("uv"):
                os.execvp("uv", ["uv", *args])
            raise FileNotFoundError(f"uv could not be installed; {runner} is available as fallback")
        raise FileNotFoundError(f"Tool not found: {tool}")
    elif status == "wrapper":
        wrapper = result["wrapper"]
        if wrapper == "devbox run --":
            os.execvp("devbox", ["devbox", "run", "--", tool, *args])
        elif wrapper == "mise exec --":
            os.execvp("mise", ["mise", "exec", "--", tool, *args])
        elif wrapper == "flox activate --":
            os.execvp("flox", ["flox", "activate", "--", tool, *args])
        elif wrapper == "direnv export &&":
            os.execvp(tool, [tool, *args])
        elif wrapper == "nix develop --command":
            os.execvp("nix", ["nix", "develop", "--command", tool, *args])
        elif wrapper == "nix-shell --run":
            os.execvp("nix-shell", ["nix-shell", "--run", " ".join([tool, *args])])
        else:
            raise RuntimeError(f"Unknown wrapper: {wrapper}")
    else:
        raise FileNotFoundError(f"Tool not found: {tool}")


# --- Convenience wrappers (backward-compatible with old devbox_run/rtk_wrap) ---

def is_devbox_available() -> bool:
    """Backward compat: check if devbox wrapper would be used."""
    return _detect_wrapper() == "devbox run --"


def devbox_run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    """Backward compat: run a command through devbox if available, otherwise directly."""
    if is_devbox_available():
        return subprocess.run(["devbox", "run", "--", *cmd], **kwargs)
    return subprocess.run(cmd, **kwargs)


def is_rtk_available() -> bool:
    """Check if rtk is available (resolved via cli-tool-discovery, not just PATH)."""
    r = resolve_tool("rtk")
    return r["status"] in ("found", "wrapper")


def _rtk_supports(tool: str, args: list[str]) -> bool:
    """Check if rtk supports a command by probing `rtk rewrite`.
    Exit codes: 0=allow, 1=not supported, 2=deny, 3=ask. 0 and 3 mean supported."""
    if not is_rtk_available():
        return False
    try:
        result = subprocess.run(
            ["rtk", "rewrite", "--", tool, *args],
            capture_output=True, text=True,
            timeout=_PROBE_TIMEOUT,
        )
        return result.returncode in (0, 3)
    except (subprocess.SubprocessError, FileNotFoundError, subprocess.TimeoutExpired):
        return False


def rtk_wrap(tool: str, *args: str, **kwargs) -> subprocess.CompletedProcess:
    """Run a command through rtk if supported, otherwise through devbox/direct.
    Uses `rtk rewrite` to check coverage — no hardcoded list of supported commands."""
    if _rtk_supports(tool, list(args)):
        return devbox_run(["rtk", tool, *args], **kwargs)
    return devbox_run([tool, *args], **kwargs)


# --- Runner mode: resolve the ad-hoc runner for an ecosystem ---
# Mirrors `cli-tool-discovery.sh --runner <ecosystem>`. Returns a dict with
# the binary, the script runner (for PEP 723-style inline-metadata files),
# the package runner (for ad-hoc package execution), the fallback, and a
# recommendation when the binary is not found.
#
# Supported ecosystems: python, node, rust, go.
# The mapping is the single source of truth for "how do I invoke an ad-hoc
# command in ecosystem X?" — detect-package-manager.py (future) and the
# python-services-practices/standalone-scripts.md knowledge page both
# delegate to this.

def _in_container() -> bool:
    """Detect whether we are inside a container. Used by runner mode to pick
    bunx (container) vs pnpm dlx (host) for node."""
    if Path("/.dockerenv").exists():
        return True
    if os.environ.get("DOCKER_CONTAINER"):
        return True
    cgroup = Path("/proc/1/cgroup")
    if cgroup.is_file():
        try:
            text = cgroup.read_text()
            if any(marker in text for marker in ("docker", "containerd", "lxc", "kubepods")):
                return True
        except OSError:
            pass
    return False


_RUNNER_MAP = {
    "python": {
        "binary": "uv",
        "script": "uv run --script",
        "package": "uvx",
        "fallback": "pip install + python3",
        "fallback_runner": "python3",
    },
    "node": {
        # node is special: the binary and package runner depend on container vs host.
        # _resolve_node_runner below handles the split; this entry is a placeholder.
        "binary": "",
        "script": "",
        "package": "",
        "fallback": "",
        "fallback_runner": "",
    },
    "rust": {
        "binary": "cargo",
        "script": "",
        "package": "cargo binstall -y",
        "fallback": "cargo install",
        "fallback_runner": "cargo",
    },
    "go": {
        "binary": "go",
        "script": "",
        "package": "go install",
        "fallback": "",
        "fallback_runner": "",
    },
}


def resolve_runner(ecosystem: str) -> dict:
    """Resolve the ad-hoc runner for an ecosystem. Returns a dict with:
        ecosystem, binary, binary_status, binary_path, wrapper,
        script, package, fallback, fallback_runner, recommendation.

    binary_status is one of: found, wrapper, not_found.
    When not_found, recommendation tells the caller what to do (add to
    devbox.json, use fallback, or install manually).
    """
    eco = ecosystem.lower()
    if eco not in _RUNNER_MAP:
        raise ValueError(
            f"Unknown ecosystem: {ecosystem} (supported: {', '.join(_RUNNER_MAP)})"
        )

    # node: container vs host split
    if eco == "node":
        if _in_container():
            spec = {"binary": "bun", "script": "", "package": "bunx",
                    "fallback": "", "fallback_runner": ""}
        else:
            spec = {"binary": "pnpm", "script": "", "package": "pnpm dlx",
                    "fallback": "", "fallback_runner": ""}
    else:
        spec = _RUNNER_MAP[eco]

    binary = spec["binary"]
    result = resolve_tool(binary)
    binary_status = result["status"]
    # The bash version treats FALLBACK (uv→pip) as not_found for runner purposes;
    # the caller uses fallback/fallback_runner instead of the binary.
    if binary_status == "fallback":
        binary_status = "not_found"

    binary_path = result.get("path", "") if binary_status == "found" else ""
    wrapper = result.get("wrapper", "") if binary_status == "wrapper" else ""

    recommendation = ""
    if binary_status == "not_found":
        if _walk_up_find("devbox.json"):
            recommendation = f"add {binary} to devbox.json (run: devbox add {binary})"
        elif spec.get("fallback_runner"):
            recommendation = f"use {spec['fallback_runner']} as fallback"
        else:
            recommendation = (
                f"{binary} not found; install before running {eco} ad-hoc commands"
            )

    return {
        "ecosystem": eco,
        "binary": binary,
        "binary_status": binary_status,
        "binary_path": binary_path,
        "wrapper": wrapper,
        "script": spec["script"],
        "package": spec["package"],
        "fallback": spec["fallback"],
        "fallback_runner": spec["fallback_runner"],
        "recommendation": recommendation,
    }



# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

BEGIN_MARKER = "# ===== BEGIN GENERATED CONTENT ====="
END_MARKER = "# ===== END GENERATED CONTENT ====="

# Heuristic mapping for reconcile suggestions: pattern substring -> concern
RECONCILE_HEURISTICS: dict[str, str] = {
    ".env": "secrets",
    ".aws": "secrets",
    ".ssh": "secrets",
    "*.key": "secrets",
    "*.pem": "secrets",
    "credential": "secrets",
    "secret": "secrets",
    ".kube": "secrets",
    "target/": "build-artifacts",
    "dist/": "build-artifacts",
    "build/": "build-artifacts",
    ".next/": "build-artifacts",
    "__pycache__": "build-artifacts",
    "coverage/": "build-artifacts",
    "result": "build-artifacts",
    "*.class": "build-artifacts",
    ".DS_Store": "os-files",
    "Thumbs.db": "os-files",
    "._*": "os-files",
    ".idea/": "editor-files",
    "*.swp": "editor-files",
    ".vscode": "editor-files",
    "*.iml": "editor-files",
    "node_modules/": "dependencies",
    ".venv": "dependencies",
    "venv/": "dependencies",
    ".gradle": "dependencies",
    ".claude": "ai-generated",
    ".cursor": "ai-generated",
    ".codeiumignore": "ai-generated",
    ".windsurf": "ai-generated",
    ".codegraph": "ai-generated",
    ".archon": "ai-generated",
    "generated-code": "ai-generated",
    "*.local.": "dev-local",
    ".devbox": "dev-local",
    ".direnv": "dev-local",
    ".cache": "dev-local",
    ".git/": "vcs-meta",
    ".svn": "vcs-meta",
    ".hg/": "vcs-meta",
    "*.log": "logs",
    "logs/": "logs",
    "*.exe": "binaries",
    "*.dll": "binaries",
    "*.zip": "binaries",
    "*.png": "binaries",
    "*.lock": "lockfiles",
    "package-lock": "lockfiles",
    "pnpm-lock": "lockfiles",
    "yarn.lock": "lockfiles",
    "Cargo.lock": "lockfiles",
    "tags": "build-artifacts",
    ".ctags": "build-artifacts",
    ".cflare": "dev-local",
    ".wrangler": "dev-local",
    ".obsidian": "dev-local",
}


# ---------------------------------------------------------------------------
# Data structures
# ---------------------------------------------------------------------------


@dataclass
class Concern:
    """A single concern source file with its parsed patterns."""

    name: str
    path: Path
    sections: list[tuple[str, list[str]]] = field(default_factory=list)
    all_patterns: set[str] = field(default_factory=set)

    def load(self) -> None:
        """Parse the concern file into sections and patterns."""
        if not self.path.exists():
            return
        text = self.path.read_text()
        current_section = ""
        current_patterns: list[str] = []
        for line in text.splitlines():
            stripped = line.strip()
            if not stripped:
                continue
            if stripped.startswith("#"):
                # Section header (## Title) or comment
                if stripped.startswith("## "):
                    if current_section or current_patterns:
                        self.sections.append((current_section, current_patterns))
                    current_section = stripped[3:].strip()
                    current_patterns = []
                continue
            # Pattern line (may have trailing comment)
            pattern = stripped.split("#")[0].strip()
            if pattern:
                current_patterns.append(pattern)
                self.all_patterns.add(pattern)
        if current_section or current_patterns:
            self.sections.append((current_section, current_patterns))


@dataclass
class OutputConfig:
    """Configuration for a single output file from outputs.yaml."""

    name: str
    syntax: str
    concerns: list[str]
    excludes: list[str] = field(default_factory=list)
    keys: list[str] = field(default_factory=list)
    extra_patterns: str = ""


# ---------------------------------------------------------------------------
# Parsing
# ---------------------------------------------------------------------------


def _parse_bracket_list(val: str) -> list[str]:
    """Parse a YAML inline bracket list like '[a, b, c]' into a Python list."""
    val = val.strip()
    if val.startswith("["):
        val = val[1:]
    if val.endswith("]"):
        val = val[:-1]
    return [c.strip() for c in val.split(",") if c.strip()]


def parse_outputs_yaml(yaml_path: Path) -> list[OutputConfig]:
    """Parse outputs.yaml into OutputConfig objects.

    Uses a minimal YAML parser (no PyYAML dependency) since the file
    structure is simple and known. The file has this shape:

        outputs:
          .gitignore:
            syntax: gitignore
            concerns: [secrets, build-artifacts]
            excludes: [ai-generated]
          .codeiumignore:
            syntax: gitignore
            concerns: [secrets, build-artifacts, ai-generated]
            extra:
              patterns: |
                # extra patterns here
                src/
    """
    if not yaml_path.exists():
        print(f"Error: outputs.yaml not found: {yaml_path}", file=sys.stderr)
        sys.exit(1)

    text = yaml_path.read_text()
    configs: list[OutputConfig] = []

    current_output: dict | None = None
    in_extra = False
    in_patterns_block = False
    in_multiline_list: str | None = None
    multiline_accum = ""
    patterns_lines: list[str] = []

    for line in text.splitlines():
        stripped = line.strip()

        # Skip comments and empty lines (but not if we're accumulating a multiline list)
        if in_multiline_list:
            multiline_accum += " " + stripped
            if multiline_accum.rstrip().endswith("]"):
                items = _parse_bracket_list(multiline_accum.strip())
                current_output[in_multiline_list] = items
                in_multiline_list = None
                multiline_accum = ""
            continue

        if not stripped or stripped.startswith("#"):
            continue

        # Top-level key: "outputs:" — skip it, it's just the wrapper
        if stripped == "outputs:" and not line.startswith(" "):
            continue

        # Output entry: indented key ending with ":" (e.g. "  .gitignore:")
        # Must be indented (starts with space) and end with ":"
        if (
            line.startswith("  ")
            and not line.startswith("    ")
            and stripped.endswith(":")
            and not stripped.startswith("-")
            and ":" not in stripped[:-1]
        ):
            # Flush previous output
            if current_output:
                if patterns_lines:
                    current_output["extra_patterns"] = "\n".join(patterns_lines)
                configs.append(_make_output_config(current_output))
            current_output = {"name": stripped[:-1], "concerns": [], "excludes": [], "keys": []}
            in_extra = False
            in_patterns_block = False
            patterns_lines = []
            continue

        if current_output is None:
            continue

        # Nested keys (4+ spaces indent)
        if stripped.startswith("syntax:"):
            current_output["syntax"] = stripped.split(":", 1)[1].strip()
            in_extra = False
            in_patterns_block = False
        elif stripped.startswith("concerns:"):
            val = stripped.split(":", 1)[1].strip()
            if val.startswith("[") and not val.endswith("]"):
                in_multiline_list = "concerns"
                multiline_accum = val
                continue
            current_output["concerns"] = _parse_bracket_list(val)
            in_extra = False
            in_patterns_block = False
        elif stripped.startswith("excludes:"):
            val = stripped.split(":", 1)[1].strip()
            if val.startswith("[") and not val.endswith("]"):
                in_multiline_list = "excludes"
                multiline_accum = val
                continue
            current_output["excludes"] = _parse_bracket_list(val)
            in_extra = False
            in_patterns_block = False
        elif stripped.startswith("keys:"):
            val = stripped.split(":", 1)[1].strip()
            if val.startswith("[") and not val.endswith("]"):
                in_multiline_list = "keys"
                multiline_accum = val
                continue
            current_output["keys"] = _parse_bracket_list(val)
            in_extra = False
            in_patterns_block = False
        elif stripped == "extra:":
            in_extra = True
            in_patterns_block = False
        elif in_extra and stripped.startswith("patterns:"):
            val = stripped.split(":", 1)[1].strip()
            if val == "|":
                in_patterns_block = True
                patterns_lines = []
            else:
                current_output["extra_patterns"] = val
            in_extra = False
        elif in_patterns_block and line.startswith("        "):
            patterns_lines.append(line.strip())

    # Flush last output
    if current_output:
        if patterns_lines:
            current_output["extra_patterns"] = "\n".join(patterns_lines)
        configs.append(_make_output_config(current_output))

    return configs


def _make_output_config(d: dict) -> OutputConfig:
    return OutputConfig(
        name=d["name"],
        syntax=d.get("syntax", "gitignore"),
        concerns=d.get("concerns", []),
        excludes=d.get("excludes", []),
        keys=d.get("keys", []),
        extra_patterns=d.get("extra_patterns", ""),
    )


def load_concerns(concerns_dir: Path) -> dict[str, Concern]:
    """Load all concern files from the given directory."""
    concerns: dict[str, Concern] = {}
    if not concerns_dir.exists():
        return concerns
    for path in sorted(concerns_dir.glob("*.ignorefile")):
        name = path.stem
        concern = Concern(name=name, path=path)
        concern.load()
        concerns[name] = concern
    return concerns


# ---------------------------------------------------------------------------
# Composition
# ---------------------------------------------------------------------------


def compose_output(
    config: OutputConfig,
    concerns: dict[str, Concern],
) -> str:
    """Compose the generated content for a single output."""
    timestamp = datetime.now().isoformat(timespec="seconds")
    concern_names = [c for c in config.concerns if c not in config.excludes]

    if config.syntax == "json-glob":
        return _compose_json_glob(config, concerns, concern_names, timestamp)
    return _compose_gitignore(config, concerns, concern_names, timestamp)


def _compose_gitignore(
    config: OutputConfig,
    concerns: dict[str, Concern],
    concern_names: list[str],
    timestamp: str,
) -> str:
    """Compose a gitignore-syntax output."""
    lines: list[str] = [
        f"# Generated: {timestamp}",
        f"# Source concerns: {', '.join(concern_names)}",
        f"# Syntax: {config.syntax}",
        "# To modify: edit concern files in the ignorefile-manager skill, then re-run.",
        "",
    ]

    seen: set[str] = set()
    has_negation = False

    for concern_name in concern_names:
        concern = concerns.get(concern_name)
        if not concern:
            print(f"Warning: concern '{concern_name}' not found", file=sys.stderr)
            continue
        for section_title, patterns in concern.sections:
            if section_title:
                lines.append(f"## {concern_name} > {section_title}")
            for p in sorted(patterns, key=str.lower):
                if p in seen:
                    continue
                seen.add(p)
                if p.startswith("!"):
                    has_negation = True
                lines.append(p)
            lines.append("")

    # Extra patterns from outputs.yaml
    if config.extra_patterns:
        lines.append("## Extra (output-specific)")
        for p in config.extra_patterns.strip().splitlines():
            p = p.strip()
            if p and not p.startswith("#"):
                if p not in seen:
                    seen.add(p)
                    if p.startswith("!"):
                        has_negation = True
                    lines.append(p)
            elif p:
                lines.append(p)
        lines.append("")

    # Handle no-negation syntax: strip ! patterns with a warning
    if config.syntax == "gitignore-no-neg" and has_negation:
        filtered: list[str] = []
        negation_lines: list[str] = []
        for line in lines:
            if line.startswith("!"):
                negation_lines.append(line)
            else:
                filtered.append(line)
        if negation_lines:
            filtered.insert(
                0,
                f"# WARNING: {len(negation_lines)} negation patterns stripped "
                f"(unsupported in {config.name}):",
            )
            for n in negation_lines:
                filtered.insert(1, f"#   {n}")
            filtered.insert(2, "")
        lines = filtered

    return "\n".join(lines)


def _compose_json_glob(
    config: OutputConfig,
    concerns: dict[str, Concern],
    concern_names: list[str],
    timestamp: str,
) -> str:
    """Compose a JSON glob output for VS Code settings."""
    # Collect all patterns
    seen: set[str] = set()
    patterns: list[str] = []

    for concern_name in concern_names:
        concern = concerns.get(concern_name)
        if not concern:
            continue
        for _, section_patterns in concern.sections:
            for p in section_patterns:
                if p not in seen and not p.startswith("!"):
                    seen.add(p)
                    patterns.append(p)

    # Extra patterns
    if config.extra_patterns:
        for p in config.extra_patterns.strip().splitlines():
            p = p.strip()
            if p and not p.startswith("#") and not p.startswith("!") and p not in seen:
                seen.add(p)
                patterns.append(p)

    # Sort and transform to JSON glob — watcher needs **/pattern/** for dirs
    patterns.sort(key=str.lower)

    # Build JSON block for each key (watcher uses different glob form)
    blocks: list[str] = []
    for key in config.keys:
        is_watcher = key == "files.watcherExclude"
        entries: list[str] = []
        for p in patterns:
            glob = _gitignore_to_vscode_glob(p, watcher=is_watcher)
            if glob:
                entries.append(f'    "{glob}": true')
        block = f'  "{key}": {{\n'
        block += ",\n".join(entries)
        block += "\n  }"
        blocks.append(block)

    header = (
        f"// Generated: {timestamp}\n"
        f"// Source concerns: {', '.join(concern_names)}\n"
        f"// Syntax: json-glob\n"
        "// To modify: edit concern files in the ignorefile-manager skill, then re-run.\n"
        "// Paste this into your settings.json or .code-workspace \"settings\" block.\n"
    )
    body = "{\n" + ",\n".join(blocks) + "\n}"
    return header + body


def _gitignore_to_vscode_glob(pattern: str, watcher: bool = False) -> str | None:
    """Transform a gitignore pattern to a VS Code glob.

    node_modules/  ->  **/node_modules        (files.exclude / search.exclude)
    node_modules/  ->  **/node_modules/**     (files.watcherExclude — watcher needs /** to skip dir contents)
    *.log          ->  **/*.log
    .git/          ->  **/.git
    /specific      ->  specific (root-anchored)
    """
    if not pattern or pattern.startswith("#"):
        return None
    if pattern.startswith("!"):
        return None  # Negation doesn't map to exclude settings

    is_dir = pattern.endswith("/")

    # Strip trailing slash (VS Code globs don't use trailing /)
    p = pattern.rstrip("/")

    # Root-anchored patterns (starting with /) stay as-is
    if p.startswith("/"):
        result = p[1:]
        return f"{result}/**" if watcher and is_dir else result

    # Patterns with ** already are glob-aware
    if "**" in p:
        return f"{p}/**" if watcher and is_dir else p

    # Everything else gets **/ prefix to match at any depth
    result = f"**/{p}"
    return f"{result}/**" if watcher and is_dir else result


# ---------------------------------------------------------------------------
# Deployed file handling
# ---------------------------------------------------------------------------


def read_deployed_file(path: Path) -> tuple[str, str]:
    """Read a deployed output file, splitting at the BEGIN_MARKER.

    Returns (project_content, generated_content).
    Project content is everything OUTSIDE the marker block (both before
    BEGIN and after END). If no marker found, returns (entire_file, "").
    """
    if not path.exists():
        return "", ""
    text = path.read_text()

    # Try gitignore-style marker
    idx = text.find(BEGIN_MARKER)
    if idx >= 0:
        before = text[:idx].rstrip()
        end_idx = text.find(END_MARKER)
        if end_idx >= 0:
            after = text[end_idx + len(END_MARKER) :].strip()
            generated = text[idx : end_idx + len(END_MARKER)]
        else:
            after = ""
            generated = text[idx:]
        # Combine before + after as project content
        project = before
        if after:
            project = f"{before}\n\n{after}" if before else after
        return project, generated

    # Try JSON-style marker (// ===== BEGIN GENERATED CONTENT =====)
    json_marker = BEGIN_MARKER.replace("# ", "// ")
    json_end = END_MARKER.replace("# ", "// ")
    idx = text.find(json_marker)
    if idx >= 0:
        before = text[:idx].rstrip()
        end_idx = text.find(json_end)
        if end_idx >= 0:
            after = text[end_idx + len(json_end) :].strip()
            generated = text[idx : end_idx + len(json_end)]
        else:
            after = ""
            generated = text[idx:]
        project = before
        if after:
            project = f"{before}\n\n{after}" if before else after
        return project, generated

    # No marker — entire file is "project content"
    return text, ""


def write_output_file(path: Path, project_content: str, generated_content: str, syntax: str) -> None:
    """Write an output file with project content on top, generated on bottom."""
    marker = BEGIN_MARKER if syntax != "json-glob" else BEGIN_MARKER.replace("# ", "// ")
    end_marker = END_MARKER if syntax != "json-glob" else END_MARKER.replace("# ", "// ")

    parts: list[str] = []
    if project_content.strip():
        parts.append(project_content.rstrip())
        parts.append("")
    parts.append(marker)
    parts.append(generated_content.rstrip())
    parts.append(end_marker)

    path.write_text("\n".join(parts) + "\n")


# ---------------------------------------------------------------------------
# Reconcile
# ---------------------------------------------------------------------------


def extract_patterns_from_file(path: Path) -> list[str]:
    """Extract ignore patterns from a deployed file.

    Handles both gitignore-syntax and JSON glob syntax.
    """
    if not path.exists():
        return []

    text = path.read_text()
    patterns: list[str] = []

    # Check if it's JSON (VS Code settings)
    if text.strip().startswith("{"):
        # Parse JSON glob patterns from files.exclude / search.exclude / watcherExclude
        for match in re.finditer(r'"(\*\*/[^"]+|[^"]+/)"\s*:\s*(true|false)', text):
            glob, val = match.group(1), match.group(2)
            if val == "true":
                # Reverse-transform: **/node_modules -> node_modules/
                p = _vscode_glob_to_gitignore(glob)
                if p:
                    patterns.append(p)
        return patterns

    # Gitignore syntax — skip comments, empty lines, and the generated block
    in_generated = False
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped:
            continue
        if stripped.startswith(BEGIN_MARKER) or stripped.startswith(
            BEGIN_MARKER.replace("# ", "// ")
        ):
            in_generated = True
            continue
        if stripped.startswith(END_MARKER) or stripped.startswith(
            END_MARKER.replace("# ", "// ")
        ):
            in_generated = False
            continue
        if in_generated:
            continue
        if stripped.startswith("#") or stripped.startswith("//"):
            continue
        # Extract pattern (strip trailing comments)
        pattern = stripped.split("#")[0].strip()
        if pattern:
            patterns.append(pattern)

    return patterns


def _vscode_glob_to_gitignore(glob: str) -> str | None:
    """Reverse-transform a VS Code glob back to a gitignore pattern."""
    if glob.startswith("**/"):
        return glob[3:] + "/"
    return glob


def suggest_concern(pattern: str) -> str:
    """Suggest a concern for a pattern using heuristics."""
    p_lower = pattern.lower()
    for substring, concern in RECONCILE_HEURISTICS.items():
        if substring in p_lower:
            return concern
    return "dev-local"  # Default fallback


def reconcile(
    concerns: dict[str, Concern],
    target_dir: Path,
    auto_assign: bool = False,
) -> None:
    """Scan deployed files for patterns not in any concern."""
    # Collect all known patterns across all concerns
    all_known: set[str] = set()
    for concern in concerns.values():
        all_known.update(concern.all_patterns)

    # Scan deployed output files
    output_filenames = [
        ".gitignore",
        ".codeiumignore",
        ".cursorignore",
        ".aiexclude",
        ".npmignore",
        ".dockerignore",
        ".chezmoiignore",
        ".vscode/settings.json",
        ".code-workspace",
    ]

    orphans: dict[str, list[str]] = {}  # pattern -> list of files found in

    for filename in output_filenames:
        # Handle .code-workspace specially (JSON with settings block)
        candidates = list(target_dir.glob(filename))
        if filename == ".code-workspace":
            candidates = list(target_dir.glob("*.code-workspace"))

        for filepath in candidates:
            patterns = extract_patterns_from_file(filepath)
            for p in patterns:
                if p not in all_known:
                    orphans.setdefault(p, []).append(filepath.name)

    if not orphans:
        print("No orphan patterns found. All deployed patterns are in concerns.")
        return

    print(f"\nFound {len(orphans)} pattern(s) in deployed files not in any concern:\n")
    suggestions: dict[str, str] = {}
    for pattern in sorted(orphans.keys(), key=str.lower):
        files = ", ".join(sorted(set(orphans[pattern])))
        suggested = suggest_concern(pattern)
        suggestions[pattern] = suggested
        print(f"  {pattern}")
        print(f"    Found in: {files}")
        print(f"    Suggested concern: {suggested}")
        print()

    if auto_assign:
        _apply_reconcile(suggestions, concerns)
    else:
        print("To add these to concerns, re-run with --auto-assign,")
        print("or manually add them to the suggested concern files.")
        print()
        print("To review and reassign, answer each prompt:")
        for pattern in sorted(suggestions.keys(), key=str.lower):
            suggested = suggestions[pattern]
            answer = input(f"  {pattern} -> {suggested}? [Enter=accept / concern-name / skip] ").strip()
            if not answer:
                pass  # Keep suggestion
            elif answer.lower() == "skip":
                del suggestions[pattern]
            else:
                suggestions[pattern] = answer
        if suggestions:
            _apply_reconcile(suggestions, concerns)


def _apply_reconcile(suggestions: dict[str, str], concerns: dict[str, Concern]) -> None:
    """Append reconciled patterns to their suggested concern files."""
    by_concern: dict[str, list[str]] = {}
    for pattern, concern_name in suggestions.items():
        by_concern.setdefault(concern_name, []).append(pattern)

    for concern_name, patterns in sorted(by_concern.items()):
        concern = concerns.get(concern_name)
        if not concern:
            print(f"Warning: concern '{concern_name}' not found, skipping {len(patterns)} patterns")
            continue
        # Append to the concern file
        existing = concern.path.read_text()
        addition = "\n## Reconciled from deployed files\n"
        addition += "\n".join(sorted(patterns, key=str.lower)) + "\n"
        concern.path.write_text(existing.rstrip() + "\n" + addition)
        print(f"Added {len(patterns)} pattern(s) to {concern_name}.ignorefile")


# ---------------------------------------------------------------------------
# Generate
# ---------------------------------------------------------------------------


def generate(
    configs: list[OutputConfig],
    concerns: dict[str, Concern],
    target_dir: Path,
    output_name: str | None = None,
    dry_run: bool = False,
) -> None:
    """Generate output files from concerns."""
    for config in configs:
        if output_name and config.name != output_name:
            continue

        content = compose_output(config, concerns)
        output_path = target_dir / config.name

        # For VS Code settings, the output is a JSON snippet to paste
        if config.syntax == "json-glob":
            if dry_run:
                print(f"\n--- {config.name} (dry-run, would write to {output_path}) ---")
                print(content[:500] + ("..." if len(content) > 500 else ""))
                continue

            # For VS Code, we print the snippet — the user pastes it into
            # settings.json or .code-workspace. We don't auto-merge JSON.
            print(f"\n--- {config.name} (paste into settings.json or .code-workspace) ---")
            print(content)
            continue

        # For gitignore-syntax files, preserve project content and write
        project_content, _ = read_deployed_file(output_path)

        if dry_run:
            existing = output_path.read_text() if output_path.exists() else ""
            if existing:
                print(f"\n--- {config.name} (dry-run, would update {output_path}) ---")
                print(f"  Project content preserved: {len(project_content.splitlines())} lines")
                print(f"  Generated content: {len(content.splitlines())} lines")
            else:
                print(f"\n--- {config.name} (dry-run, would create {output_path}) ---")
                print(f"  Generated content: {len(content.splitlines())} lines")
            continue

        write_output_file(output_path, project_content, content, config.syntax)
        print(f"Written: {output_path}")


# ---------------------------------------------------------------------------
# Audit
# ---------------------------------------------------------------------------


def audit(configs: list[OutputConfig], target_dir: Path) -> None:
    """Check which outputs are missing or stale in the target directory."""
    print(f"\nAuditing ignore files in: {target_dir}\n")
    found = 0
    missing = 0
    stale = 0

    for config in configs:
        path = target_dir / config.name
        if config.syntax == "json-glob":
            # Check for .code-workspace or settings.json
            ws_files = list(target_dir.glob("*.code-workspace"))
            settings = target_dir / ".vscode" / "settings.json"
            if ws_files or settings.exists():
                found += 1
                print(f"  [FOUND]    {config.name} (via workspace/settings)")
            else:
                missing += 1
                print(f"  [MISSING]  {config.name}")
            continue

        if not path.exists():
            missing += 1
            print(f"  [MISSING]  {config.name}")
        else:
            _, generated = read_deployed_file(path)
            if not generated:
                stale += 1
                print(f"  [STALE]    {config.name} (no generated marker — needs initial generation)")
            else:
                found += 1
                print(f"  [FOUND]    {config.name}")

    print(f"\nSummary: {found} found, {missing} missing, {stale} stale")


# ---------------------------------------------------------------------------
# Workspace mode — update *.code-workspace files with exclude settings
# ---------------------------------------------------------------------------


def workspace(
    configs: list[OutputConfig],
    concerns: dict[str, Concern],
    target_dir: Path,
    dry_run: bool = False,
) -> None:
    """Find all *.code-workspace files under target_dir and merge exclude settings.

    Unlike `generate` (which prints JSON snippets for manual paste), this mode
    auto-merges the generated files.exclude, search.exclude, and
    files.watcherExclude into each .code-workspace file's settings block.
    Uses marker-based preservation for the generated entries within each
    exclude object.
    """
    ws_files = sorted(target_dir.rglob("*.code-workspace"))
    if not ws_files:
        print(f"No *.code-workspace files found under {target_dir}")
        return

    # Build the exclude dicts from json-glob configs (watcher needs **/dir/**)
    exclude_dicts: dict[str, dict[str, bool]] = {}
    for config in configs:
        if config.syntax != "json-glob":
            continue
        patterns = _collect_json_glob_patterns(config, concerns)
        for key in config.keys:
            is_watcher = key == "files.watcherExclude"
            glob_map: dict[str, bool] = {}
            for p in patterns:
                glob = _gitignore_to_vscode_glob(p, watcher=is_watcher)
                if glob:
                    glob_map[glob] = True
            exclude_dicts[key] = glob_map

    if not exclude_dicts:
        print("No json-glob outputs configured in outputs.yaml")
        return

    print(f"Found {len(ws_files)} workspace file(s) under {target_dir}\n")
    updated = 0
    for ws_path in ws_files:
        rel = ws_path.relative_to(target_dir) if ws_path.is_relative_to(target_dir) else ws_path
        changed = _merge_workspace_settings(ws_path, exclude_dicts, dry_run)
        if changed:
            updated += 1
            status = "would update" if dry_run else "updated"
        else:
            status = "up to date"
        print(f"  {status}: {rel}")
    print(f"\n{updated} file(s) {'would be ' if dry_run else ''}updated")


def _collect_json_glob_patterns(config: OutputConfig, concerns: dict[str, Concern]) -> list[str]:
    """Collect sorted, deduped patterns from a json-glob config's concerns."""
    seen: set[str] = set()
    patterns: list[str] = []
    concern_names = [c for c in config.concerns if c not in config.excludes]
    for concern_name in concern_names:
        concern = concerns.get(concern_name)
        if not concern:
            continue
        for _, section_patterns in concern.sections:
            for p in section_patterns:
                if p not in seen and not p.startswith("!"):
                    seen.add(p)
                    patterns.append(p)
    if config.extra_patterns:
        for p in config.extra_patterns.strip().splitlines():
            p = p.strip()
            if p and not p.startswith("#") and not p.startswith("!") and p not in seen:
                seen.add(p)
                patterns.append(p)
    patterns.sort(key=str.lower)
    return patterns


def _merge_workspace_settings(
    ws_path: Path,
    exclude_dicts: dict[str, dict[str, bool]],
    dry_run: bool,
) -> bool:
    """Merge exclude dicts into a .code-workspace file's settings block.

    Returns True if the file was (or would be) changed.
    Uses marker comments within each exclude object to preserve user entries
    while replacing generated entries.
    """
    try:
        data = json.loads(ws_path.read_text())
    except (json.JSONDecodeError, OSError) as e:
        print(f"  Warning: could not parse {ws_path.name}: {e}", file=sys.stderr)
        return False

    settings = data.setdefault("settings", {})
    changed = False

    for key, generated_entries in exclude_dicts.items():
        exclude_obj = settings.setdefault(key, {})

        # Separate user entries from generated entries using markers.
        # Entries between BEGIN and END markers are generated (replaced each run).
        # Entries outside the markers are user entries (preserved).
        marker_key = "// ===== BEGIN GENERATED CONTENT ====="
        end_marker_key = "// ===== END GENERATED CONTENT ====="
        user_entries: dict[str, bool] = {}
        in_generated = False
        for glob, val in exclude_obj.items():
            if glob == marker_key:
                in_generated = True
                continue
            if glob == end_marker_key:
                in_generated = False
                continue
            if not in_generated:
                user_entries[glob] = val

        # Build new exclude object: user entries first, then generated block
        new_obj: dict[str, bool] = {}
        for glob in sorted(user_entries.keys(), key=str.lower):
            new_obj[glob] = user_entries[glob]

        # ponytail: VS Code .code-workspace files support JSONC (comments), but
        # json.loads can't parse JSONC. We write with json.dumps which strips
        # comments. The marker is a no-op key that VS Code ignores.
        new_obj[marker_key] = True
        for glob in sorted(generated_entries.keys(), key=str.lower):
            if glob not in user_entries:
                new_obj[glob] = True
        new_obj[end_marker_key] = True

        # Check if anything changed
        if list(new_obj.keys()) != list(exclude_obj.keys()):
            changed = True
            exclude_obj.clear()
            exclude_obj.update(new_obj)
        else:
            # Check values
            for k, v in new_obj.items():
                if exclude_obj.get(k) != v:
                    changed = True
                    exclude_obj.clear()
                    exclude_obj.update(new_obj)
                    break

    if changed and not dry_run:
        # Write with 2-space indent, preserving key order
        ws_path.write_text(json.dumps(data, indent="\t") + "\n")

    return changed


def _is_generated_marker_key(key: str) -> bool:
    """Check if a key is a generated-content marker."""
    return key.startswith("// ===== BEGIN GENERATED") or key.startswith("// ===== END GENERATED")


# ---------------------------------------------------------------------------
# Ripgrep mode — update ripgrep config and ripgrepignore deterministically
# ---------------------------------------------------------------------------


def ripgrep(
    configs: list[OutputConfig],
    concerns: dict[str, Concern],
    config_dir: Path,
    dry_run: bool = False,
) -> None:
    """Deterministically check and update ripgrep config and ignore file.

    Ensures:
    1. ~/.config/ripgrep/config exists with --ignore-file= pointing to ripgrepignore
    2. ~/.config/ripgrep/ripgrepignore has generated patterns from the ripgrep-ignore output
    3. Key CLI flags (--hidden, --smart-case, --sort=path) are present
    """
    config_path = config_dir / "config"
    ignore_path = config_dir / "ripgrepignore"

    print(f"Ripgrep config dir: {config_dir}\n")

    # --- Step 1: Ensure config file exists with key settings ---
    required_args = {
        "--hidden": "--hidden",
        "--smart-case": "--smart-case",
        "--sort=path": "--sort=path",
        f"--ignore-file={ignore_path}": f"--ignore-file={ignore_path}",
    }

    config_changed = False
    if config_path.exists():
        existing = config_path.read_text()
        existing_args = {line.strip() for line in existing.splitlines() if line.strip() and not line.strip().startswith("#")}
    else:
        existing = ""
        existing_args = set()

    missing_args = []
    for arg in required_args:
        # For --ignore-file, check if any line references the ignore file
        if arg.startswith("--ignore-file="):
            if not any("--ignore-file=" in line and ignore_path.name in line for line in existing_args):
                missing_args.append(arg)
        elif arg not in existing_args:
            missing_args.append(arg)

    if missing_args:
        config_changed = True
        print(f"  config: missing {len(missing_args)} arg(s): {', '.join(missing_args)}")
        if not dry_run:
            config_dir.mkdir(parents=True, exist_ok=True)
            lines = existing.splitlines()
            # Remove any existing --ignore-file lines to avoid duplicates
            lines = [l for l in lines if "--ignore-file=" not in l]
            lines.append("")
            lines.append("# --- Managed by ignorefile-manager ---")
            for arg in missing_args:
                lines.append(arg)
            config_path.write_text("\n".join(lines).strip() + "\n")
    else:
        print("  config: up to date")

    # --- Step 2: Generate ripgrepignore from the ripgrep-ignore output ---
    rg_config = None
    for c in configs:
        if c.name == "ripgrep-ignore":
            rg_config = c
            break

    if not rg_config:
        print("  ripgrepignore: no 'ripgrep-ignore' output in outputs.yaml, skipping")
        if config_changed:
            print(f"\n{'Would update' if dry_run else 'Updated'} config (no ripgrepignore changes)")
        else:
            print("\nEverything up to date")
        return

    generated_content = compose_output(rg_config, concerns)
    ignore_changed = False

    if ignore_path.exists():
        _, existing_generated = read_deployed_file(ignore_path)
        if existing_generated.strip() != generated_content.strip():
            ignore_changed = True
    else:
        ignore_changed = True

    if ignore_changed:
        print(f"  ripgrepignore: {'would write' if dry_run else 'writing'} {len(generated_content.splitlines())} lines")
        if not dry_run:
            config_dir.mkdir(parents=True, exist_ok=True)
            # Preserve any project-specific content above the marker
            project_content, _ = read_deployed_file(ignore_path)
            write_output_file(ignore_path, project_content, generated_content, "gitignore")
    else:
        print("  ripgrepignore: up to date")

    if config_changed or ignore_changed:
        print(f"\n{'Would update' if dry_run else 'Updated'} ripgrep configuration")
    else:
        print("\nEverything up to date")


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def get_assets_dir() -> Path:
    """Get the assets directory relative to this script."""
    return Path(__file__).parent.parent / "assets"


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Generate ignore files from modular concern sources."
    )
    subparsers = parser.add_subparsers(dest="command", help="Command to run")

    # Generate
    gen_parser = subparsers.add_parser("generate", help="Compose outputs from concerns")
    gen_parser.add_argument("--dry-run", action="store_true", help="Show what would change without writing")
    gen_parser.add_argument("--output", "-o", help="Generate only this output (e.g. .gitignore)")
    gen_parser.add_argument("--target", "-t", default=".", help="Target directory (default: cwd)")
    gen_parser.add_argument("--concerns-dir", help="Override concerns directory (default: bundled assets)")

    # Reconcile
    rec_parser = subparsers.add_parser("reconcile", help="Find patterns in deployed files not in any concern")
    rec_parser.add_argument("--auto-assign", action="store_true", help="Accept all suggestions without prompting")
    rec_parser.add_argument("--target", "-t", default=".", help="Target directory to scan (default: cwd)")
    rec_parser.add_argument("--concerns-dir", help="Override concerns directory")

    # Audit
    aud_parser = subparsers.add_parser("audit", help="Check which outputs are missing or stale")
    aud_parser.add_argument("--target", "-t", default=".", help="Target directory (default: cwd)")

    # Workspace
    ws_parser = subparsers.add_parser("workspace", help="Find and update all *.code-workspace files with exclude settings")
    ws_parser.add_argument("--dry-run", action="store_true", help="Show what would change without writing")
    ws_parser.add_argument("--target", "-t", default=".", help="Root directory to search for workspace files (default: cwd)")
    ws_parser.add_argument("--concerns-dir", help="Override concerns directory (default: bundled assets)")

    # Ripgrep
    rg_parser = subparsers.add_parser("ripgrep", help="Update ripgrep config and ripgrepignore deterministically")
    rg_parser.add_argument("--dry-run", action="store_true", help="Show what would change without writing")
    rg_parser.add_argument("--config-dir", default=str(Path(os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))) / "ripgrep"),
                           help="Ripgrep config directory (default: $XDG_CONFIG_HOME/ripgrep or ~/.config/ripgrep)")
    rg_parser.add_argument("--concerns-dir", help="Override concerns directory (default: bundled assets)")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(1)

    assets_dir = get_assets_dir()
    concerns_dir = Path(args.concerns_dir) if hasattr(args, "concerns_dir") and args.concerns_dir else assets_dir / "concerns"
    outputs_yaml = assets_dir / "outputs.yaml"

    # For reconcile, concerns_dir may be overridden but outputs.yaml stays bundled
    concerns = load_concerns(concerns_dir)

    if args.command == "reconcile":
        target = Path(args.target).resolve()
        reconcile(concerns, target, auto_assign=args.auto_assign)
        return

    if args.command == "audit":
        configs = parse_outputs_yaml(outputs_yaml)
        target = Path(args.target).resolve()
        audit(configs, target)
        return

    if args.command == "generate":
        configs = parse_outputs_yaml(outputs_yaml)
        target = Path(args.target).resolve()
        generate(
            configs,
            concerns,
            target,
            output_name=args.output,
            dry_run=args.dry_run,
        )
        return

    if args.command == "workspace":
        configs = parse_outputs_yaml(outputs_yaml)
        target = Path(args.target).resolve()
        workspace(configs, concerns, target, dry_run=args.dry_run)
        return

    if args.command == "ripgrep":
        configs = parse_outputs_yaml(outputs_yaml)
        config_dir = Path(args.config_dir).resolve()
        ripgrep(configs, concerns, config_dir, dry_run=args.dry_run)
        return


if __name__ == "__main__":
    main()
