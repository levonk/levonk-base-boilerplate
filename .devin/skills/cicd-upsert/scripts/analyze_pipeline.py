#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Analyze a project's CI/CD pipeline and output a structured assessment.

Detects:
  - CI system (GitHub Actions, GitLab CI, Jenkins, CircleCI, etc.)
  - Build system (Go, Rust, Node, Python, etc.)
  - Test framework
  - Package manager
  - Deployment target (if detectable)
  - Existing tooling files (devbox.json, Justfile, Makefile, Dockerfile)
  - Recommended CI provider

Usage:
    uv run --script analyze_pipeline.py --path /path/to/repo
    python analyze_pipeline.py --path /path/to/repo --json
    python analyze_pipeline.py --path . --verbose

Output:
    Human-readable assessment (default) or JSON (--json flag).
"""

import argparse
import json
import os
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



# CI system detection patterns: (system_name, file_or_dir_pattern)
CI_SYSTEMS = [
    ("github-actions", [".github/workflows"]),
    ("gitlab-ci", [".gitlab-ci.yml", ".gitlab-ci/"]),
    ("jenkins", ["Jenkinsfile"]),
    ("circleci", [".circleci/config.yml", ".circleci"]),
    ("azure-pipelines", ["azure-pipelines.yml", ".azure"]),
    ("aws-codebuild", ["buildspec.yml"]),
    ("google-cloud-build", ["cloudbuild.yaml", "cloudbuild.yml"]),
    ("bitbucket-pipelines", ["bitbucket-pipelines.yml"]),
    ("buildkite", [".buildkite/pipeline.yml", ".buildkite"]),
    ("drone-ci", [".drone.yml", ".drone.star"]),
    ("semaphore", [".semaphore/semaphore.yml", ".semaphore"]),
    ("travis-ci", [".travis.yml"]),
    ("appveyor", ["appveyor.yml"]),
]

# Build system detection: (system_name, marker_files)
BUILD_SYSTEMS = [
    ("go", ["go.mod", "go.sum", "Gopkg.toml", "glide.yaml"]),
    ("rust", ["Cargo.toml", "Cargo.lock"]),
    ("node", ["package.json", "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb"]),
    ("python", ["pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "poetry.lock", "uv.lock"]),
    ("java-maven", ["pom.xml"]),
    ("java-gradle", ["build.gradle", "build.gradle.kts", "settings.gradle", "settings.gradle.kts"]),
    ("ruby", ["Gemfile", "Gemfile.lock", "Rakefile"]),
    ("php", ["composer.json"]),
    ("dotnet", [".csproj", ".fsproj", ".sln", "Directory.Packages.props"]),
    ("elixir", ["mix.exs"]),
    ("haskell", ["package.yaml", "*.cabal", "stack.yaml"]),
    ("clojure", ["project.clj", "deps.edn"]),
    ("c-cpp", ["CMakeLists.txt", "Makefile", "meson.build", "BUILDCONFIG.gn"]),
    ("swift", ["Package.swift"]),
    ("dart", ["pubspec.yaml"]),
    ("flutter", ["pubspec.yaml"]),
]

# Test framework detection: (framework, marker_files_or_dirs)
TEST_FRAMEWORKS = [
    ("pytest", ["pytest.ini", "conftest.py", "pyproject.toml"]),
    ("unittest", ["unittest.cfg"]),
    ("jest", ["jest.config.js", "jest.config.ts", "jest.config.json"]),
    ("vitest", ["vitest.config.ts", "vitest.config.js"]),
    ("mocha", [".mocharc.yml", ".mocharc.js", "mocha.opts"]),
    ("cargo-test", ["Cargo.toml"]),
    ("go-test", ["go.mod"]),
    ("rspec", [".rspec", "spec/"]),
    ("minitest", ["test/"]),
    ("phpunit", ["phpunit.xml", "phpunit.xml.dist"]),
    ("xunit-nunit", [".runsettings"]),
    ("bun-test", ["bunfig.toml"]),
    ("deno-test", ["deno.json"]),
]

# Deployment target detection: (target, marker_files)
DEPLOYMENT_TARGETS = [
    ("kubernetes", ["k8s/", "kubernetes/", "deploy/", "helm/", "Chart.yaml", "values.yaml", "kustomization.yaml"]),
    ("docker-compose", ["docker-compose.yml", "docker-compose.yaml", "compose.yml"]),
    ("serverless", ["serverless.yml", "serverless.ts", "sam.yaml", "template.yaml"]),
    ("terraform", ["main.tf", "terraform.tf", "*.tfvars"]),
    ("pulumi", ["Pulumi.yaml", "Pulumi.yml"]),
    ("ansible", ["ansible.cfg", "inventory.yml", "playbook.yml", "site.yml"]),
    ("helm", ["Chart.yaml"]),
    ("fly-io", ["fly.toml"]),
    ("railway", ["railway.json", "railway.toml"]),
    ("vercel", ["vercel.json"]),
    ("netlify", ["netlify.toml"]),
    ("heroku", ["Procfile", "app.json"]),
    ("aws-lambda", ["template.yaml", "sam.yaml"]),
    ("google-cloud-run", ["cloudbuild.yaml", "app.yaml"]),
    ("azure-functions", ["host.json", "function.json"]),
]

# Tooling files to detect
TOOLING_FILES = [
    "devbox.json",
    "Justfile",
    "justfile",
    "Makefile",
    "Dockerfile",
    "Dockerfile.ci",
    "Dockerfile.act",
    ".tool-versions",
    ".nvmrc",
    ".python-version",
    "rust-toolchain.toml",
    "flake.nix",
    "shell.nix",
    "mise.toml",
    ".mise.toml",
]


def detect_patterns(repo_path: Path, patterns: list[tuple[str, list[str]]]) -> list[str]:
    """Detect which patterns match in the repo. Returns list of matched names."""
    detected = []
    for name, markers in patterns:
        for marker in markers:
            # Handle glob patterns (e.g., "*.tfvars")
            if "*" in marker:
                if list(repo_path.glob(marker)):
                    detected.append(name)
                    break
            else:
                if (repo_path / marker).exists() or (repo_path / marker).is_dir():
                    detected.append(name)
                    break
    return detected


def detect_tooling_files(repo_path: Path) -> dict[str, bool]:
    """Detect which tooling files exist."""
    result = {}
    for f in TOOLING_FILES:
        result[f] = (repo_path / f).exists()
    return result


def detect_ci_workflows(repo_path: Path) -> list[dict]:
    """Detect and catalog GitHub Actions workflow files."""
    workflows_dir = repo_path / ".github" / "workflows"
    if not workflows_dir.exists():
        return []
    workflows = []
    for wf_file in workflows_dir.glob("*.yml"):
        workflows.append({"name": wf_file.name, "path": str(wf_file.relative_to(repo_path))})
    for wf_file in workflows_dir.glob("*.yaml"):
        workflows.append({"name": wf_file.name, "path": str(wf_file.relative_to(repo_path))})
    return workflows


def detect_composite_actions(repo_path: Path) -> list[dict]:
    """Detect GitHub Actions composite actions."""
    actions_dir = repo_path / ".github" / "actions"
    if not actions_dir.exists():
        return []
    actions = []
    for action_dir in actions_dir.iterdir():
        if action_dir.is_dir() and (action_dir / "action.yml").exists():
            actions.append({"name": action_dir.name, "path": str(action_dir.relative_to(repo_path))})
    return actions


def detect_hosting_platform(repo_path: Path) -> str | None:
    """Detect the hosting platform from git remote."""
    try:
        result = subprocess.run(
            ["git", "remote", "get-url", "origin"],
            cwd=str(repo_path),
            capture_output=True,
            text=True,
            timeout=5,
        )
        if result.returncode == 0:
            url = result.stdout.strip()
            if "github.com" in url:
                return "github"
            if "gitlab.com" in url:
                return "gitlab"
            if "bitbucket.org" in url:
                return "bitbucket"
            if "dev.azure.com" in url or "visualstudio.com" in url:
                return "azure-devops"
    except (subprocess.TimeoutExpired, FileNotFoundError):
        pass
    return None


def recommend_ci_provider(
    detected_ci: list[str],
    hosting_platform: str | None,
) -> str:
    """Recommend a CI provider based on detected systems and hosting platform."""
    if detected_ci:
        return detected_ci[0]
    if hosting_platform == "github":
        return "github-actions"
    if hosting_platform == "gitlab":
        return "gitlab-ci"
    if hosting_platform == "bitbucket":
        return "bitbucket-pipelines"
    if hosting_platform == "azure-devops":
        return "azure-pipelines"
    return "github-actions"  # default


def assess_pipeline_maturity(
    detected_ci: list[str],
    tooling: dict[str, bool],
    ci_workflows: list[dict],
    composite_actions: list[dict],
    repo_path: Path,
) -> dict:
    """Assess pipeline maturity based on detected features."""
    has_ci = bool(detected_ci)
    has_workflows = bool(ci_workflows)
    has_composite = bool(composite_actions)
    has_devbox = tooling.get("devbox.json", False)
    has_justfile = tooling.get("Justfile", False) or tooling.get("justfile", False)
    has_dockerfile_ci = tooling.get("Dockerfile.ci", False) or tooling.get("Dockerfile.act", False)
    has_dockerfile = tooling.get("Dockerfile", False)
    has_dockerignore = (repo_path / ".dockerignore").exists()

    # Scan workflow file contents for feature detection
    has_incremental = False
    has_security_scans = False
    has_provenance = False
    has_concurrency = False
    has_timeout = False
    has_permissions_scoped = False
    has_container_image = False
    has_login_shell = False
    all_workflow_contents = []
    for wf in ci_workflows:
        wf_path = Path(wf["path"])
        if not wf_path.is_absolute():
            wf_path = repo_path / wf_path
        if wf_path.exists():
            try:
                content = wf_path.read_text()
                all_workflow_contents.append(content)
                if "paths-filter" in content or "git diff" in content:
                    has_incremental = True
                if any(t in content.lower() for t in ["trivy", "gitleaks", "codeql", "semgrep", "snyk"]):
                    has_security_scans = True
                if any(t in content.lower() for t in ["cosign", "syft", "sbom", "provenance", "slsa"]):
                    has_provenance = True
                if "concurrency:" in content:
                    has_concurrency = True
                if "timeout-minutes" in content:
                    has_timeout = True
                if "permissions:" in content:
                    has_permissions_scoped = True
                if "container:" in content:
                    has_container_image = True
                if "bash -l" in content or "bash --login" in content:
                    has_login_shell = True
            except Exception:
                pass

    # Check for over-broad permissions (write-all or no permissions block with secrets)
    has_permissions_overbroad = False
    for content in all_workflow_contents:
        if "write-all" in content:
            has_permissions_overbroad = True

    return {
        "has_ci": has_ci,
        "has_workflows": has_workflows,
        "has_composite_actions": has_composite,
        "has_incremental_builds": has_incremental,
        "has_security_scans": has_security_scans,
        "has_provenance": has_provenance,
        "has_devbox": has_devbox,
        "has_justfile": has_justfile,
        "has_ci_image": has_dockerfile_ci,
        "has_dockerfile": has_dockerfile,
        "has_dockerignore": has_dockerignore,
        "has_concurrency": has_concurrency,
        "has_timeout": has_timeout,
        "has_permissions_scoped": has_permissions_scoped,
        "has_permissions_overbroad": has_permissions_overbroad,
        "has_container_image": has_container_image,
        "has_login_shell": has_login_shell,
        "maturity_score": sum([
            has_ci, has_workflows, has_composite, has_incremental,
            has_security_scans, has_provenance, has_devbox, has_justfile,
        ]),
        "maturity_level": (
            "none" if not has_ci else
            "basic" if has_ci and not has_workflows else
            "intermediate" if has_workflows and not (has_incremental or has_security_scans) else
            "advanced" if has_incremental and has_security_scans else
            "full" if has_incremental and has_security_scans and has_provenance else
            "intermediate"
        ),
    }


def analyze(repo_path: Path) -> dict:
    """Run full analysis and return structured assessment."""
    detected_ci = detect_patterns(repo_path, CI_SYSTEMS)
    build_systems = detect_patterns(repo_path, BUILD_SYSTEMS)
    test_frameworks = detect_patterns(repo_path, TEST_FRAMEWORKS)
    deployment_targets = detect_patterns(repo_path, DEPLOYMENT_TARGETS)
    tooling = detect_tooling_files(repo_path)
    ci_workflows = detect_ci_workflows(repo_path)
    composite_actions = detect_composite_actions(repo_path)
    hosting_platform = detect_hosting_platform(repo_path)
    recommended_ci = recommend_ci_provider(detected_ci, hosting_platform)
    maturity = assess_pipeline_maturity(detected_ci, tooling, ci_workflows, composite_actions, repo_path)

    return {
        "repo_path": str(repo_path),
        "hosting_platform": hosting_platform,
        "detected_ci_systems": detected_ci,
        "recommended_ci_provider": recommended_ci,
        "build_systems": build_systems,
        "test_frameworks": test_frameworks,
        "deployment_targets": deployment_targets,
        "tooling_files": {k: v for k, v in tooling.items() if v},
        "ci_workflows": ci_workflows,
        "composite_actions": composite_actions,
        "pipeline_maturity": maturity,
    }


def print_human_readable(assessment: dict, verbose: bool = False) -> None:
    """Print human-readable assessment."""
    print("=" * 60)
    print("CI/CD Pipeline Assessment")
    print("=" * 60)
    print(f"Repository: {assessment['repo_path']}")
    print(f"Hosting:    {assessment['hosting_platform'] or 'unknown'}")
    print()

    print(f"CI Systems:        {', '.join(assessment['detected_ci_systems']) or 'none detected'}")
    print(f"Recommended CI:    {assessment['recommended_ci_provider']}")
    print(f"Build Systems:     {', '.join(assessment['build_systems']) or 'none detected'}")
    print(f"Test Frameworks:   {', '.join(assessment['test_frameworks']) or 'none detected'}")
    print(f"Deployment Targets:{', '.join(assessment['deployment_targets']) or 'none detected'}")
    print()

    print("Tooling Files:")
    for f, exists in assessment["tooling_files"].items():
        print(f"  {'+' if exists else '-'} {f}")
    print()

    if assessment["ci_workflows"]:
        print(f"CI Workflows ({len(assessment['ci_workflows'])}):")
        for wf in assessment["ci_workflows"]:
            print(f"  - {wf['name']}")
        print()

    if assessment["composite_actions"]:
        print(f"Composite Actions ({len(assessment['composite_actions'])}):")
        for a in assessment["composite_actions"]:
            print(f"  - {a['name']}")
        print()

    m = assessment["pipeline_maturity"]
    print(f"Pipeline Maturity: {m['maturity_level']} (score: {m['maturity_score']}/8)")
    print(f"  CI exists:           {'yes' if m['has_ci'] else 'no'}")
    print(f"  Workflows:           {'yes' if m['has_workflows'] else 'no'}")
    print(f"  Composite actions:   {'yes' if m['has_composite_actions'] else 'no'}")
    print(f"  Incremental builds:  {'yes' if m['has_incremental_builds'] else 'no'}")
    print(f"  Security scans:      {'yes' if m['has_security_scans'] else 'no'}")
    print(f"  Provenance/SBOM:     {'yes' if m['has_provenance'] else 'no'}")
    print(f"  Devbox:              {'yes' if m['has_devbox'] else 'no'}")
    print(f"  Justfile:            {'yes' if m['has_justfile'] else 'no'}")
    print(f"  CI image:            {'yes' if m['has_ci_image'] else 'no'}")
    print(f"  Dockerfile:          {'yes' if m['has_dockerfile'] else 'no'}")
    print()
    print("CI Hygiene:")
    print(f"  .dockerignore:       {'yes' if m['has_dockerignore'] else 'no'}")
    print(f"  Concurrency control: {'yes' if m['has_concurrency'] else 'no'}")
    print(f"  Timeout-minutes:     {'yes' if m['has_timeout'] else 'no'}")
    print(f"  Permissions scoped:  {'yes' if m['has_permissions_scoped'] else 'no'}")
    if m["has_permissions_overbroad"]:
        print(f"  Over-broad perms:    WARNING — write-all detected")
    print(f"  Container image:     {'yes' if m['has_container_image'] else 'no'}")
    print(f"  Login shell:         {'yes' if m['has_login_shell'] else 'no'}")

    if verbose:
        print()
        print("Full JSON assessment:")
        print(json.dumps(assessment, indent=2))


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Analyze a project's CI/CD pipeline and output a structured assessment."
    )
    parser.add_argument("--path", "-p", default=".", help="Repository path (default: current directory)")
    parser.add_argument("--json", action="store_true", help="Output JSON instead of human-readable")
    parser.add_argument("--verbose", "-v", action="store_true", help="Show full JSON in addition to human-readable")
    args = parser.parse_args()

    repo_path = Path(args.path).resolve()
    if not repo_path.exists():
        print(f"Error: Path does not exist: {repo_path}", file=sys.stderr)
        sys.exit(1)

    assessment = analyze(repo_path)

    if args.json:
        print(json.dumps(assessment, indent=2))
    else:
        print_human_readable(assessment, verbose=args.verbose)


if __name__ == "__main__":
    main()
