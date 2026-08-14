#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Discover existing AI agent skills matching a query across local skills-src,
skills.sh, and GitHub. Used by the ai-skill-upsert research phase to find
existing skills before creating a new one.

Usage:
    uv run --script discover_skills.py "pdf rotation tool"
    ./scripts/discover_skills.py "skill comparison" --verbose
    python scripts/discover_skills.py "code review" --sources local,skills.sh

Output (stdout): JSON object with arrays of found skills per source.

    {
      "query": "pdf rotation tool",
      "local": [{"name": "...", "path": "...", "description": "...", "tags": [...]}],
      "skills_sh": [{"name": "...", "url": "...", "description": "...", "installs": 1234}],
      "github": [{"name": "...", "repo": "owner/repo", "url": "...", "description": "...", "stars": 42}]
    }

Quiet by default; --verbose prints progress to stderr; --dry-run prints what
would be searched without making API calls.
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
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
# Frontmatter parsing
# ---------------------------------------------------------------------------
def parse_frontmatter(content: str) -> dict:
    """Parse YAML frontmatter from a SKILL.md file content. Returns a dict.

    Handles simple key-value pairs and list items. Does not handle nested
    objects or multi-line block scalars (use extract_description for those).
    Keys with hyphens (e.g., see-also, last-used) are matched correctly.
    """
    if not content.startswith("---"):
        return {}
    parts = content.split("---", 2)
    if len(parts) < 3:
        return {}
    fm_text = parts[1].strip()
    result: dict = {}
    for line in fm_text.splitlines():
        line = line.rstrip()
        if not line or line.startswith("#"):
            continue
        # Match top-level keys (including hyphenated keys like see-also)
        m = re.match(r"^([\w-]+):\s*(.*)$", line)
        if m:
            key, val = m.group(1), m.group(2).strip()
            if val and not val.startswith("|") and not val.startswith(">"):
                val = val.strip('"').strip("'")
                result[key] = val
            else:
                # Empty value or block scalar marker — initialize key so
                # subsequent list items attach to the correct key
                result[key] = [] if not val else val
        elif line.startswith("  - ") and result:
            last_key = list(result.keys())[-1]
            if not isinstance(result.get(last_key), list):
                result[last_key] = [result[last_key]] if last_key in result else []
            result[last_key].append(line.strip("- ").strip('"').strip("'"))
    return result


def extract_description(content: str) -> str:
    """Extract the description from frontmatter, handling multi-line YAML."""
    if not content.startswith("---"):
        return ""
    parts = content.split("---", 2)
    if len(parts) < 3:
        return ""
    fm_text = parts[1]
    # Handle block scalars (>- or |)
    m = re.search(r"^description:\s*>-?\s*\n((?:  .+\n?)+)", fm_text, re.MULTILINE)
    if m:
        lines = [l.strip() for l in m.group(1).strip().splitlines()]
        return " ".join(lines)
    m = re.search(r"^description:\s*(.+)$", fm_text, re.MULTILINE)
    if m:
        return m.group(1).strip().strip('"').strip("'")
    return ""


# ---------------------------------------------------------------------------
# Local skill discovery
# ---------------------------------------------------------------------------
def discover_local(query: str, skills_src_path: str | None = None, verbose: bool = False) -> list[dict]:
    """Scan local skills-src repository for SKILL.md files matching the query."""
    candidates: list[str] = []
    if skills_src_path:
        candidates.append(skills_src_path)
    else:
        default = Path.home() / "p" / "gh" / "levonk" / "skills-src"
        if default.exists():
            candidates.append(str(default))

    # Also check common project-level and user-level skill directories
    for env_path in [
        os.environ.get("CLAUDE_PROJECT_SKILLS", ""),
        str(Path.home() / ".agents" / "skills"),
        str(Path.cwd() / ".agents" / "skills"),
    ]:
        if env_path and Path(env_path).exists():
            candidates.append(env_path)

    results: list[dict] = []
    query_lower = query.lower()
    query_words = set(re.findall(r"\w+", query_lower))

    for base in candidates:
        base_path = Path(base)
        if verbose:
            print(f"  Scanning local: {base_path}", file=sys.stderr)
        for skill_md in base_path.rglob("SKILL.md"):
            try:
                content = skill_md.read_text(errors="replace")
            except OSError:
                continue
            fm = parse_frontmatter(content)
            desc = extract_description(content)
            name = fm.get("name", skill_md.parent.name)
            tags = fm.get("tags", [])
            if isinstance(tags, str):
                tags = [tags]

            # Score by keyword overlap
            searchable = f"{name} {desc} {' '.join(tags)}".lower()
            searchable_words = set(re.findall(r"\w+", searchable))
            overlap = len(query_words & searchable_words)
            if overlap == 0:
                # Check substring match as fallback
                if query_lower not in searchable:
                    continue
                overlap = 1

            results.append({
                "name": name,
                "path": str(skill_md),
                "description": desc[:200] if desc else "",
                "tags": tags if isinstance(tags, list) else [],
                "match_score": overlap,
                "source": "local",
            })

    results.sort(key=lambda x: x["match_score"], reverse=True)
    return results[:20]


# ---------------------------------------------------------------------------
# skills.sh discovery
# ---------------------------------------------------------------------------
def discover_skills_sh(query: str, verbose: bool = False, dry_run: bool = False) -> list[dict]:
    """Search skills.sh for skills matching the query."""
    if dry_run:
        if verbose:
            print("  [dry-run] Would search skills.sh API", file=sys.stderr)
        return []

    # skills.sh has a search API: https://www.skills.sh/docs/api
    # Use curl to fetch search results
    import urllib.request
    import urllib.parse

    encoded = urllib.parse.quote(query)
    url = f"https://www.skills.sh/api/search?q={encoded}"

    if verbose:
        print(f"  Fetching: {url}", file=sys.stderr)

    try:
        req = urllib.request.Request(url, headers={"Accept": "application/json", "User-Agent": "discover_skills.py/1.0"})
        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read().decode())
    except Exception as e:
        if verbose:
            print(f"  skills.sh API error: {e}", file=sys.stderr)
        # Fallback: try the CLI if available
        return discover_skills_sh_cli(query, verbose)

    skills = data if isinstance(data, list) else data.get("skills", data.get("results", []))
    results: list[dict] = []
    for skill in skills[:20]:
        results.append({
            "name": skill.get("name", skill.get("title", "unknown")),
            "url": skill.get("url", skill.get("link", "")),
            "description": (skill.get("description", "") or "")[:200],
            "installs": skill.get("installs", skill.get("installCount", 0)),
            "source": "skills.sh",
        })
    return results


def discover_skills_sh_cli(query: str, verbose: bool = False) -> list[dict]:
    """Fallback: use `pnpm dlx skills find` CLI if available."""
    pnpm = shutil.which("pnpm")
    if not pnpm:
        return []
    if verbose:
        print(f"  Falling back to: pnpm dlx skills find", file=sys.stderr)
    try:
        proc = devbox_run(
            [pnpm, "dlx", "skills", "find", query, "--json"],
            capture_output=True, text=True, timeout=30,
        )
        if proc.returncode != 0:
            return []
        data = json.loads(proc.stdout)
        skills = data if isinstance(data, list) else data.get("skills", [])
        return [{
            "name": s.get("name", "unknown"),
            "url": s.get("url", ""),
            "description": (s.get("description", "") or "")[:200],
            "installs": s.get("installs", 0),
            "source": "skills.sh",
        } for s in skills[:20]]
    except Exception:
        return []


# ---------------------------------------------------------------------------
# GitHub discovery
# ---------------------------------------------------------------------------
def discover_github(query: str, verbose: bool = False, dry_run: bool = False) -> list[dict]:
    """Search GitHub for repositories containing SKILL.md files matching the query."""
    if dry_run:
        if verbose:
            print("  [dry-run] Would search GitHub for SKILL.md files", file=sys.stderr)
        return []

    gh = shutil.which("gh")
    if not gh:
        if verbose:
            print("  gh CLI not found, skipping GitHub search", file=sys.stderr)
        return []

    # Search for SKILL.md files with the query keywords
    search_query = f'"{query}" filename:SKILL.md'
    if verbose:
        print(f"  GitHub code search: {search_query}", file=sys.stderr)

    try:
        proc = rtk_wrap(
            "gh", "api", "search/code",
            "-f", f"q={search_query}",
            "-f", "per_page=20",
            "--jq", ".items[] | {repo: .repository.full_name, path: .path, url: .html_url}",
            capture_output=True, text=True, timeout=30,
        )
        if proc.returncode != 0:
            if verbose:
                print(f"  GitHub code search failed: {proc.stderr[:200]}", file=sys.stderr)
            return discover_github_repos(query, verbose)
        # Parse JSON lines output
        results: list[dict] = []
        for line in proc.stdout.strip().splitlines():
            if not line.strip():
                continue
            try:
                item = json.loads(line)
            except json.JSONDecodeError:
                continue
            repo = item.get("repo", "")
            results.append({
                "name": repo.split("/")[-1] if repo else "unknown",
                "repo": repo,
                "url": item.get("url", f"https://github.com/{repo}" if repo else ""),
                "description": "",
                "source": "github",
            })
        # Enrich with repo metadata
        for r in results[:10]:
            r.update(fetch_github_repo_meta(r["repo"], verbose))
        return results[:20]
    except Exception as e:
        if verbose:
            print(f"  GitHub search error: {e}", file=sys.stderr)
        return discover_github_repos(query, verbose)


def discover_github_repos(query: str, verbose: bool = False) -> list[dict]:
    """Fallback: search GitHub repositories (not code search) for skill repos."""
    search_query = f"{query} agent skill SKILL.md"
    if verbose:
        print(f"  GitHub repo search: {search_query}", file=sys.stderr)
    try:
        proc = rtk_wrap(
            "gh", "api", "search/repositories",
            "-f", f"q={search_query}",
            "-f", "sort=stars",
            "-f", "per_page=20",
            "--jq", ".items[] | {name: .name, repo: .full_name, url: .html_url, description: .description, stars: .stargazers_count}",
            capture_output=True, text=True, timeout=30,
        )
        if proc.returncode != 0:
            return []
        results: list[dict] = []
        for line in proc.stdout.strip().splitlines():
            if not line.strip():
                continue
            try:
                item = json.loads(line)
            except json.JSONDecodeError:
                continue
            results.append({
                "name": item.get("name", "unknown"),
                "repo": item.get("repo", ""),
                "url": item.get("url", ""),
                "description": (item.get("description", "") or "")[:200],
                "stars": item.get("stars", 0),
                "source": "github",
            })
        return results[:20]
    except Exception:
        return []


def fetch_github_repo_meta(repo: str, verbose: bool = False) -> dict:
    """Fetch stars and description for a GitHub repo."""
    if not repo:
        return {}
    try:
        proc = rtk_wrap(
            "gh", "api", f"repos/{repo}",
            "--jq", "{description: .description, stars: .stargazers_count, language: .language, topics: .topics, pushed_at: .pushed_at, license: .license.key}",
            capture_output=True, text=True, timeout=10,
        )
        if proc.returncode != 0:
            return {}
        return json.loads(proc.stdout.strip())
    except Exception:
        return {}


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> int:
    parser = argparse.ArgumentParser(
        description="Discover existing AI agent skills matching a query."
    )
    parser.add_argument("query", help="Search query (skill description or keywords)")
    parser.add_argument("--sources", default="local,skills.sh,github",
                        help="Comma-separated list of sources to search (default: local,skills.sh,github)")
    parser.add_argument("--skills-src-path", default=None,
                        help="Path to local skills-src repository (default: ~/p/gh/levonk/skills-src)")
    parser.add_argument("--verbose", action="store_true", help="Print progress to stderr")
    parser.add_argument("--dry-run", action="store_true", help="Show what would be searched without API calls")
    args = parser.parse_args()

    sources = [s.strip() for s in args.sources.split(",")]
    result: dict = {"query": args.query}

    if "local" in sources:
        if args.verbose:
            print("Searching local skills...", file=sys.stderr)
        result["local"] = discover_local(args.query, args.skills_src_path, args.verbose)

    if "skills.sh" in sources:
        if args.verbose:
            print("Searching skills.sh...", file=sys.stderr)
        result["skills_sh"] = discover_skills_sh(args.query, args.verbose, args.dry_run)

    if "github" in sources:
        if args.verbose:
            print("Searching GitHub...", file=sys.stderr)
        result["github"] = discover_github(args.query, args.verbose, args.dry_run)

    # Summary counts
    total = sum(len(v) for k, v in result.items() if k != "query")
    if args.verbose:
        print(f"\nFound {total} skills across {len([k for k in result if k != 'query'])} sources", file=sys.stderr)

    print(json.dumps(result, indent=2))
    return 0


if __name__ == "__main__":
    sys.exit(main())
