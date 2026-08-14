#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Analyze repository changes since an AGENTS.md file was last updated.

Produces a structured JSON report of commits, new/deleted files, new
directories, revert/removal commits (anti-pattern candidates), and dependency
changes. The report is consumed by a subagent that interprets it to extract
positive findings (to add to AGENTS.md), negative findings (anti-patterns),
and improvement candidates.

Determines the "last updated" cutoff from:
  1. The date.knowledge-basis field in the AGENTS.md frontmatter (if present)
  2. The last git commit that modified the AGENTS.md file (fallback)

Usage:
    uv run --script analyze_git_delta.py /path/to/project --agents-file AGENTS.md
    uv run --script analyze_git_delta.py /path/to/project --agents-file AGENTS.md --verbose
    uv run --script analyze_git_delta.py /path/to/project --agents-file AGENTS.md --path src/auth/
    uv run --script analyze_git_delta.py /path/to/project --agents-file AGENTS.md --json
"""

import argparse
import json
import re
import subprocess
import sys
from dataclasses import asdict, dataclass, field
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



@dataclass
class CommitInfo:
    """Summary of a single commit."""
    hash: str
    date: str
    author: str
    subject: str


@dataclass
class DeltaReport:
    """Structured report of repository changes since a cutoff date."""
    repo_root: str
    agents_file: str
    cutoff_date: str
    cutoff_source: str  # "frontmatter" or "git-history"
    commit_count: int = 0
    date_range: str = ""
    top_contributors: list[str] = field(default_factory=list)
    new_files: list[str] = field(default_factory=list)
    deleted_files: list[str] = field(default_factory=list)
    new_directories: list[str] = field(default_factory=list)
    new_test_files: list[str] = field(default_factory=list)
    new_config_files: list[str] = field(default_factory=list)
    revert_removal_commits: list[CommitInfo] = field(default_factory=list)
    new_dependencies: list[str] = field(default_factory=list)
    removed_dependencies: list[str] = field(default_factory=list)


def run_git(repo: Path, args: list[str]) -> str:
    """Run a git command and return stdout. Raises on non-zero exit."""
    result = run_tool("git", ["-C", str(repo), *args], capture_output=True, text=True, check=True)
    return result.stdout


def extract_frontmatter_date(agents_path: Path) -> str | None:
    """Extract date.knowledge-basis from AGENTS.md YAML frontmatter.

    Looks for a frontmatter block delimited by --- lines, then parses the
    date.knowledge-basis field. Returns YYYY-MM-DD or None.
    """
    if not agents_path.exists():
        return None
    text = agents_path.read_text(encoding="utf-8")
    lines = text.splitlines()
    if not lines or lines[0].strip() != "---":
        return None
    in_fm = False
    for line in lines[1:]:
        if line.strip() == "---":
            break
        in_fm = True
        # Match: updated: "YYYY-MM-DD" or updated: YYYY-MM-DD
        m = re.match(r'^updated:\s*["\']?(\d{4}-\d{2}-\d{2})["\']?', line.strip())
        if m:
            return m.group(1)
    return None


def get_last_commit_date_for_file(repo: Path, file_path: str) -> str | None:
    """Get the date of the last commit that modified a file."""
    try:
        # %cI = committer date, ISO 8601
        out = run_git(repo, ["log", "-1", "--format=%cI", "--", file_path])
        date_str = out.strip()
        if not date_str:
            return None
        # Trim to YYYY-MM-DD
        return date_str[:10]
    except subprocess.CalledProcessError:
        return None


def determine_cutoff(repo: Path, agents_file: str) -> tuple[str, str]:
    """Determine the cutoff date and its source.

    Returns (cutoff_date, source) where source is "frontmatter" or
    "git-history".
    """
    agents_path = repo / agents_file
    fm_date = extract_frontmatter_date(agents_path)
    if fm_date:
        return fm_date, "frontmatter"
    git_date = get_last_commit_date_for_file(repo, agents_file)
    if git_date:
        return git_date, "git-history"
    # No cutoff determinable — use epoch (all history)
    return "1970-01-01", "no-history"


def get_commits_since(repo: Path, cutoff: str, path: str | None) -> list[CommitInfo]:
    """Get commits since the cutoff date, optionally scoped to a path."""
    args = ["log", f"--since={cutoff}", "--format=%H|%cI|%an|%s"]
    if path:
        args.extend(["--", path])
    try:
        out = run_git(repo, args)
    except subprocess.CalledProcessError:
        return []
    commits: list[CommitInfo] = []
    for line in out.strip().splitlines():
        parts = line.split("|", 3)
        if len(parts) == 4:
            commits.append(CommitInfo(
                hash=parts[0],
                date=parts[1],
                author=parts[2],
                subject=parts[3],
            ))
    return commits


def get_changed_files_since(repo: Path, cutoff: str, path: str | None) -> tuple[list[str], list[str]]:
    """Get files added and deleted since the cutoff.

    Returns (added, deleted) lists of relative paths.
    """
    args = ["log", f"--since={cutoff}", "--name-status", "--format="]
    if path:
        args.extend(["--", path])
    try:
        out = run_git(repo, args)
    except subprocess.CalledProcessError:
        return [], []
    added: list[str] = []
    deleted: list[str] = []
    for line in out.strip().splitlines():
        line = line.strip()
        if not line:
            continue
        parts = line.split("\t")
        if len(parts) < 2:
            continue
        status, filepath = parts[0], parts[1]
        # A = added, D = deleted, R = renamed (treat old as deleted, new as added)
        if status.startswith("A"):
            added.append(filepath)
        elif status.startswith("D"):
            deleted.append(filepath)
        elif status.startswith("R") and len(parts) >= 3:
            deleted.append(parts[1])
            added.append(parts[2])
    return added, deleted


def extract_new_directories(added_files: list[str]) -> list[str]:
    """Extract new top-level directories from added file paths."""
    seen: set[str] = set()
    dirs: list[str] = []
    for f in added_files:
        parts = f.split("/")
        if len(parts) > 1:
            top = parts[0]
            if top not in seen and not top.startswith("."):
                seen.add(top)
                dirs.append(top)
    return sorted(dirs)


def filter_test_files(files: list[str]) -> list[str]:
    """Filter for test files (test_*, *_test.*, *.spec.*, *.test.*)."""
    test_patterns = [
        r"test_.+\.\w+$",
        r".+_test\.\w+$",
        r".+\.test\.\w+$",
        r".+\.spec\.\w+$",
        r".+\.test\.\w+$",
    ]
    return sorted(
        f for f in files
        if any(re.search(p, f) for p in test_patterns)
    )


def filter_config_files(files: list[str]) -> list[str]:
    """Filter for config files."""
    config_names = {
        "package.json", "tsconfig.json", "Cargo.toml", "pyproject.toml",
        "devbox.json", "Justfile", "justfile", "Makefile", ".envrc",
        "nx.json", "pnpm-workspace.yaml", "go.mod", "go.sum",
        "docker-compose.yml", "Dockerfile", ".eslintrc.json",
    }
    return sorted(
        f for f in files
        if Path(f).name in config_names or f.endswith(".config.ts")
        or f.endswith(".config.js") or f.endswith(".config.json")
    )


def filter_revert_removal_commits(commits: list[CommitInfo]) -> list[CommitInfo]:
    """Filter commits that indicate reverts, removals, or replacements.

    These are anti-pattern candidates — practices that were abandoned.
    """
    keywords = [
        "revert", "remove", "delete", "switch from", "replace",
        "deprecate", "rollback", "undo", "stop using", "drop",
        "get rid of", "no longer",
    ]
    result: list[CommitInfo] = []
    for c in commits:
        subject_lower = c.subject.lower()
        if any(kw in subject_lower for kw in keywords):
            result.append(c)
    return result


def extract_dependency_changes(
    repo: Path, cutoff: str, path: str | None,
) -> tuple[list[str], list[str]]:
    """Extract dependency changes from package.json / Cargo.toml / pyproject.toml.

    Compares the current version of the file against the version at the cutoff
    date. Returns (new_deps, removed_deps) as a list of strings.
    """
    new_deps: list[str] = []
    removed_deps: list[str] = []

    dep_files = ["package.json", "Cargo.toml", "pyproject.toml", "go.mod"]
    search_paths = [path] if path else [""]
    for dep_file in dep_files:
        for sp in search_paths:
            fpath = f"{sp}/{dep_file}" if sp else dep_file
            try:
                old_content = run_git(repo, ["show", f"{cutoff}:{fpath}"])
            except subprocess.CalledProcessError:
                old_content = ""  # file didn't exist at cutoff
            curr_path = repo / fpath
            if not curr_path.exists():
                continue
            new_content = curr_path.read_text(encoding="utf-8")
            old_deps = extract_deps(dep_file, old_content)
            new_deps_set = extract_deps(dep_file, new_content)
            for dep in sorted(new_deps_set - old_deps):
                new_deps.append(f"{fpath}: +{dep}")
            for dep in sorted(old_deps - new_deps_set):
                removed_deps.append(f"{fpath}: -{dep}")
    return new_deps, removed_deps


def extract_deps(dep_file: str, content: str) -> set[str]:
    """Extract dependency names from a package manifest file."""
    deps: set[str] = set()
    if dep_file == "package.json":
        try:
            data = json.loads(content)
            for section in ("dependencies", "devDependencies", "peerDependencies"):
                deps.update((data.get(section) or {}).keys())
        except (json.JSONDecodeError, KeyError):
            pass
    elif dep_file == "Cargo.toml":
        in_deps = False
        for line in content.splitlines():
            if line.strip().startswith("[dependencies]") or line.strip().startswith("[dev-dependencies]"):
                in_deps = True
                continue
            if line.strip().startswith("["):
                in_deps = False
                continue
            if in_deps:
                m = re.match(r"^([a-zA-Z_][\w-]*)\s*=", line.strip())
                if m:
                    deps.add(m.group(1))
    elif dep_file == "pyproject.toml":
        in_deps = False
        for line in content.splitlines():
            if "dependencies" in line and "=" in line and "[" in line:
                in_deps = True
                continue
            if in_deps and line.strip() == "]":
                in_deps = False
                continue
            if in_deps:
                m = re.match(r'^["\']([^"\']+)["\']', line.strip())
                if m:
                    deps.add(m.group(1))
    elif dep_file == "go.mod":
        in_deps = False
        for line in content.splitlines():
            if line.strip() == "require (":
                in_deps = True
                continue
            if in_deps and line.strip() == ")":
                in_deps = False
                continue
            if in_deps:
                parts = line.strip().split()
                if len(parts) >= 2:
                    deps.add(parts[0])
    return deps


def analyze(repo: Path, agents_file: str, path: str | None, verbose: bool) -> DeltaReport:
    """Run the full delta analysis and return a structured report."""
    cutoff, cutoff_source = determine_cutoff(repo, agents_file)
    if verbose:
        print(f"  Cutoff date: {cutoff} (source: {cutoff_source})")

    commits = get_commits_since(repo, cutoff, path)
    added, deleted = get_changed_files_since(repo, cutoff, path)
    new_deps, removed_deps = extract_dependency_changes(repo, cutoff, path)

    # Top contributors (by commit count)
    contributor_counts: dict[str, int] = {}
    for c in commits:
        contributor_counts[c.author] = contributor_counts.get(c.author, 0) + 1
    top_contribs = sorted(contributor_counts, key=lambda a: -contributor_counts[a])[:5]

    # Date range
    date_range = ""
    if commits:
        dates = [c.date[:10] for c in commits]
        date_range = f"{dates[-1]} to {dates[0]}"

    report = DeltaReport(
        repo_root=str(repo),
        agents_file=agents_file,
        cutoff_date=cutoff,
        cutoff_source=cutoff_source,
        commit_count=len(commits),
        date_range=date_range,
        top_contributors=top_contribs,
        new_files=sorted(added),
        deleted_files=sorted(deleted),
        new_directories=extract_new_directories(added),
        new_test_files=filter_test_files(added),
        new_config_files=filter_config_files(added),
        revert_removal_commits=filter_revert_removal_commits(commits),
        new_dependencies=new_deps,
        removed_dependencies=removed_deps,
    )
    return report


def print_verbose(report: DeltaReport) -> None:
    """Print a human-readable summary of the report."""
    print(f"\nRepository: {report.repo_root}")
    print(f"AGENTS file: {report.agents_file}")
    print(f"Cutoff: {report.cutoff_date} (source: {report.cutoff_source})")
    print(f"Commits since cutoff: {report.commit_count}")
    if report.date_range:
        print(f"Date range: {report.date_range}")
    if report.top_contributors:
        print(f"Top contributors: {', '.join(report.top_contributors)}")
    print(f"\nNew files: {len(report.new_files)}")
    for f in report.new_files[:20]:
        print(f"  + {f}")
    if len(report.new_files) > 20:
        print(f"  ... and {len(report.new_files) - 20} more")
    print(f"\nDeleted files: {len(report.deleted_files)}")
    for f in report.deleted_files[:20]:
        print(f"  - {f}")
    if len(report.deleted_files) > 20:
        print(f"  ... and {len(report.deleted_files) - 20} more")
    print(f"\nNew directories: {report.new_directories}")
    print(f"New test files: {len(report.new_test_files)}")
    print(f"New config files: {len(report.new_config_files)}")
    print(f"\nRevert/removal commits (anti-pattern candidates): {len(report.revert_removal_commits)}")
    for c in report.revert_removal_commits[:20]:
        print(f"  {c.hash[:8]} {c.date[:10]} {c.subject}")
    if len(report.revert_removal_commits) > 20:
        print(f"  ... and {len(report.revert_removal_commits) - 20} more")
    print(f"\nNew dependencies: {len(report.new_dependencies)}")
    for d in report.new_dependencies:
        print(f"  {d}")
    print(f"\nRemoved dependencies: {len(report.removed_dependencies)}")
    for d in report.removed_dependencies:
        print(f"  {d}")


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Analyze repository changes since an AGENTS.md was last updated",
    )
    parser.add_argument("project_root", type=Path, help="Path to the project root")
    parser.add_argument("--agents-file", default="AGENTS.md", help="Agent file to analyze (default: AGENTS.md)")
    parser.add_argument("--path", default=None, help="Scope to a specific path (e.g., src/auth/)")
    parser.add_argument("--verbose", "-v", action="store_true", help="Print human-readable summary")
    parser.add_argument("--json", action="store_true", help="Output JSON only (no human-readable output)")
    args = parser.parse_args()

    project_root = args.project_root.resolve()
    if not project_root.is_dir():
        print(f"ERROR: {project_root} is not a directory", file=sys.stderr)
        return 2

    # Verify it's a git repo
    try:
        run_git(project_root, ["rev-parse", "--is-inside-work-tree"])
    except subprocess.CalledProcessError:
        print(f"ERROR: {project_root} is not a git repository", file=sys.stderr)
        return 2

    report = analyze(project_root, args.agents_file, args.path, args.verbose)

    if args.json:
        print(json.dumps(asdict(report), indent=2))
    else:
        print_verbose(report)
        if args.verbose:
            print("\n--- JSON ---")
            print(json.dumps(asdict(report), indent=2))

    return 0


if __name__ == "__main__":
    sys.exit(main())
