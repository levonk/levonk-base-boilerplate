#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Install knowledge bundles from a distribution repo into a consumer project.

Knowledge bundles are canonical, compounding best-practices documents published
to levonk/skills-releases (public) and levonk/skills-private (private). This
script shallow-clones the distribution repo, copies the requested bundles into
the project's .agents/knowledge/bundles/ directory, and leaves the project with
self-contained, offline access to those practices.

Bundle tiers:
  - Universal: installed by default for every project (architecture,
    dev-environment, security, CI-CD, build-system).
  - Stack-matched: added by the caller based on project-detection output
    (typescript, rust, python, java, frontend, nix, container, data).
  - Domain-specific: NOT installed by this script. They are URL-referenced in
    AGENTS.md by agent-file-upsert (bundled skill) so agents fetch them on demand
    only when a task touches that domain.

Usage:
    uv run --script install-knowledge-bundles.py <project-root> [options]
    uv run --script install-knowledge-bundles.py . --verbose
    uv run --script install-knowledge-bundles.py . --bundles typescript-monorepo-best-practices,container-best-practices

Examples:
    # Universal bundles only (default)
    uv run --script install-knowledge-bundles.py .

    # Stack-matched (TypeScript + containers detected)
    uv run --script install-knowledge-bundles.py . --bundles typescript-monorepo-best-practices,container-best-practices

    # Private distribution repo
    uv run --script install-knowledge-bundles.py . --private --bundles secrets-egress-security

    # Dry run — show what would be installed
    uv run --script install-knowledge-bundles.py . --dry-run --verbose
"""

import argparse
import shutil
import subprocess
import sys
import tempfile
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



# Default distribution repos
PUBLIC_SOURCE = "git@github.com:levonk/skills-releases.git"
PRIVATE_SOURCE = "git@github.com:levonk/skills-private.git"

# Bundles installed when --bundles is not specified
UNIVERSAL_DEFAULT = [
    "software-architecture-essentials",
    "dev-environment-practices",
    "devsecops-codeguard",
    "cicd-testing-practices",
    "build-system-essentials",
]

# Stack-matched bundles (caller passes via --bundles when stack detected)
STACK_MATCHED = {
    "typescript-monorepo-best-practices": "TypeScript/Node.js",
    "rust-development-practices": "Rust",
    "python-services-practices": "Python",
    "java-best-practices": "Java",
    "frontend-stack-practices": "Frontend web",
    "nix-build-practices": "Nix-heavy",
    "container-best-practices": "Docker/K8s",
    "data-engineering-best-practices": "Data pipelines",
}


def log_info(msg: str, verbose: bool = False) -> None:
    """Print an [INFO] line (always shown)."""
    print("[INFO] " + msg)


def log_debug(msg: str, verbose: bool) -> None:
    """Print a [DEBUG] line only in verbose mode."""
    if verbose:
        print("[DEBUG] " + msg)


def log_skip(msg: str) -> None:
    """Print a [SKIP] line."""
    print("[SKIP] " + msg)


def log_warn(msg: str) -> None:
    """Print a [WARN] line."""
    print("[WARN] " + msg)


def log_error(msg: str) -> None:
    """Print an [ERROR] line."""
    print("[ERROR] " + msg)


def log_ok(msg: str) -> None:
    """Print an [OK] line."""
    print("[OK] " + msg)


def clone_distribution_repo(source: str, target: Path, verbose: bool) -> bool:
    """Shallow-clone the distribution repo to target dir. Returns True on success."""
    log_debug("Cloning " + source + " to " + str(target), verbose)
    try:
        result = subprocess.run(
            ["git", "clone", "--depth", "1", source, str(target)],
            capture_output=True,
            text=True,
        )
    except FileNotFoundError:
        log_error("git not found — cannot clone distribution repo")
        return False
    if result.returncode != 0:
        log_error("git clone failed: " + result.stderr.strip())
        return False
    log_debug("Clone complete", verbose)
    return True


def install_bundles(
    bundles: list[str],
    source_dir: Path,
    target_dir: Path,
    dry_run: bool,
    force: bool,
    verbose: bool,
) -> tuple[int, int, int]:
    """Install bundles from source_dir/knowledge/ into target_dir.

    Returns (installed, skipped, missing) counts.
    """
    knowledge_root = source_dir / "knowledge"
    installed = 0
    skipped = 0
    missing = 0

    for bundle in bundles:
        src = knowledge_root / bundle
        if not src.is_dir():
            log_warn("Bundle not found in distribution repo: " + bundle)
            missing += 1
            continue

        dst = target_dir / bundle

        if dry_run:
            if dst.exists() and not force:
                log_skip("[dry-run] " + bundle + " (already exists, use --force to overwrite)")
                skipped += 1
            else:
                log_info("[dry-run] would install " + bundle + " -> " + str(dst))
                installed += 1
            continue

        if dst.exists() and not force:
            log_skip(bundle + " (already exists, use --force to overwrite)")
            skipped += 1
            continue

        if dst.exists() and force:
            log_debug("Removing existing " + str(dst), verbose)
            shutil.rmtree(dst)

        log_debug("Copying " + str(src) + " -> " + str(dst), verbose)
        shutil.copytree(src, dst, dirs_exist_ok=force)
        log_ok(bundle)
        installed += 1

    return installed, skipped, missing


def main():
    parser = argparse.ArgumentParser(
        description="Install knowledge bundles from a distribution repo into a project"
    )
    parser.add_argument(
        "project_root",
        help="Path to the project root directory",
    )
    parser.add_argument(
        "--bundles",
        help="Comma-separated list of bundle names to install (default: UNIVERSAL_DEFAULT set)",
        default=None,
    )
    parser.add_argument(
        "--target-dir",
        help="Target directory for bundles (default: <project-root>/.agents/knowledge/bundles/)",
        default=None,
    )
    parser.add_argument(
        "--source",
        help="Git URL of the distribution repo (default: levonk/skills-releases)",
        default=None,
    )
    parser.add_argument(
        "--private",
        action="store_true",
        help="Use the private distribution repo (levonk/skills-private). Overrides --source.",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be installed without copying files",
    )
    parser.add_argument(
        "--force",
        action="store_true",
        help="Overwrite existing bundles (default: skip existing)",
    )
    parser.add_argument(
        "--verbose", "-v",
        action="store_true",
        help="Show detailed progress",
    )

    args = parser.parse_args()

    project_root = Path(args.project_root).expanduser().resolve()
    if not project_root.is_dir():
        log_error("Project root does not exist or is not a directory: " + str(project_root))
        sys.exit(1)

    # Resolve bundles list
    if args.bundles:
        bundles = [b.strip() for b in args.bundles.split(",") if b.strip()]
    else:
        bundles = list(UNIVERSAL_DEFAULT)

    # Resolve target dir
    if args.target_dir:
        target_dir = Path(args.target_dir).expanduser().resolve()
    else:
        target_dir = project_root / ".agents" / "knowledge" / "bundles"

    # Resolve source repo
    if args.private:
        source = PRIVATE_SOURCE
    elif args.source:
        source = args.source
    else:
        source = PUBLIC_SOURCE

    log_info("Project root: " + str(project_root), args.verbose)
    log_info("Target dir: " + str(target_dir), args.verbose)
    log_info("Source repo: " + source, args.verbose)
    log_info("Bundles: " + ", ".join(bundles), args.verbose)
    if args.dry_run:
        log_info("DRY RUN — no files will be written", args.verbose)

    # Shallow-clone the distribution repo to a temp dir
    with tempfile.TemporaryDirectory(prefix="knowledge-bundles-") as tmp:
        tmp_path = Path(tmp)
        if not clone_distribution_repo(source, tmp_path, args.verbose):
            sys.exit(1)

        # Create target dir if not dry run
        if not args.dry_run:
            target_dir.mkdir(parents=True, exist_ok=True)

        installed, skipped, missing = install_bundles(
            bundles=bundles,
            source_dir=tmp_path,
            target_dir=target_dir,
            dry_run=args.dry_run,
            force=args.force,
            verbose=args.verbose,
        )

    # Summary
    print("")
    print("Summary:")
    print("  Installed: " + str(installed))
    print("  Skipped:   " + str(skipped))
    print("  Missing:   " + str(missing))
    if missing > 0:
        log_warn(str(missing) + " bundle(s) not found in distribution repo — see [WARN] lines above")

    # Exit 0 on success (including partial installs with warnings)
    sys.exit(0)


if __name__ == "__main__":
    main()
