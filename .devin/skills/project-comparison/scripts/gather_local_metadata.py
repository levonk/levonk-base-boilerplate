#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Gather local project metadata by invoking the project-detection skill's
detection scripts. Extracts build systems, package managers, CI/CD platforms,
tech stack, and basic repository info (last commit, file count) from local
paths.

Usage:
    uv run --script gather_local_metadata.py /path/to/project-a /path/to/project-b
    ./gather_local_metadata.py /path/to/project-a --verbose
    python gather_local_metadata.py /path/to/project-a --dry-run

Output (stdout): JSON array of per-project metadata objects.

Each object contains:
    - path: absolute path to the project
    - name: directory name
    - build_systems: list of detected build systems
    - package_managers: list of detected package managers
    - ci_cd: list of detected CI/CD platforms
    - languages: list of detected primary languages
    - last_commit_date: ISO date of last git commit (or null)
    - is_git_repo: bool
    - file_count: approximate number of tracked files (or null)
    - error: error message if analysis failed

Quiet by default; --verbose prints full detection output; --dry-run prints
what would be analyzed without running detection scripts.
"""

import argparse
import json
import os
import shutil
import subprocess
import sys
from pathlib import Path

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


def find_detection_script(script_name: str) -> str | None:
    """Find a project-detection script by searching common locations."""
    candidates = [
        # Relative to this skill's location in skills-src
        Path(__file__).parent.parent.parent / "project-detection" / "scripts" / script_name,
        # Relative to skills-src root
        Path(__file__).parent.parent.parent.parent.parent.parent / "src" / "current" / "skills" / "software-dev" / "project-detection" / "scripts" / script_name,
    ]
    for c in candidates:
        if c.exists():
            return str(c)
    return None


def detect_build_systems(project_path: str, verbose: bool = False) -> list[str]:
    """Detect build systems using project-detection scripts or fallback heuristics."""
    script = find_detection_script("detect-build-systems.sh")
    if script:
        try:
            proc = devbox_run(["bash", script, project_path], capture_output=True, text=True)
            if proc.returncode == 0:
                return [s.strip() for s in proc.stdout.strip().split() if s.strip()]
        except Exception:
            pass

    # Fallback: heuristic detection by marker files
    markers = {
        "package.json": "node",
        "Cargo.toml": "cargo",
        "pyproject.toml": "python",
        "setup.py": "python",
        "go.mod": "go",
        "pom.xml": "maven",
        "build.gradle": "gradle",
        "build.gradle.kts": "gradle",
        "Gemfile": "ruby",
        "composer.json": "php",
        "mix.exs": "elixir",
        "CMakeLists.txt": "cmake",
        "Makefile": "make",
    }
    found = []
    p = Path(project_path)
    for marker, system in markers.items():
        if (p / marker).exists():
            found.append(system)
    return found


def detect_ci_cd(project_path: str, verbose: bool = False) -> list[str]:
    """Detect CI/CD platforms by marker files."""
    p = Path(project_path)
    found = []
    ci_markers = [
        (".github/workflows", "github-actions"),
        (".gitlab-ci.yml", "gitlab-ci"),
        (".circleci/config.yml", "circleci"),
        ("Jenkinsfile", "jenkins"),
        (".azure-pipelines.yml", "azure-pipelines"),
        (".travis.yml", "travis-ci"),
        ("azure-pipelines.yml", "azure-pipelines"),
    ]
    for marker, platform in ci_markers:
        if (p / marker).exists():
            found.append(platform)
    return found


def detect_languages(project_path: str) -> list[str]:
    """Detect primary languages by file extension frequency."""
    p = Path(project_path)
    ext_map = {
        ".ts": "TypeScript", ".tsx": "TypeScript",
        ".js": "JavaScript", ".jsx": "JavaScript",
        ".py": "Python",
        ".rs": "Rust",
        ".go": "Go",
        ".java": "Java",
        ".kt": "Kotlin",
        ".rb": "Ruby",
        ".php": "PHP",
        ".ex": "Elixir", ".exs": "Elixir",
        ".c": "C", ".h": "C",
        ".cpp": "C++", ".hpp": "C++",
        ".cs": "C#",
        ".swift": "Swift",
        ".scala": "Scala",
    }
    counts: dict[str, int] = {}
    try:
        for item in p.rglob("*"):
            if ".git" in item.parts or "node_modules" in item.parts or "target" in item.parts:
                continue
            if item.is_file():
                lang = ext_map.get(item.suffix)
                if lang:
                    counts[lang] = counts.get(lang, 0) + 1
    except (PermissionError, OSError):
        pass
    # Return top 3 by count
    return [lang for lang, _ in sorted(counts.items(), key=lambda x: -x[1])[:3]]


def get_git_info(project_path: str) -> dict:
    """Get last commit date and file count from git."""
    info: dict = {"is_git_repo": False, "last_commit_date": None, "file_count": None}
    git_dir = Path(project_path) / ".git"
    if not git_dir.exists():
        return info
    info["is_git_repo"] = True

    try:
        proc = rtk_wrap("git", "-C", project_path, "log", "-1", "--format=%cI",
                        capture_output=True, text=True)
        if proc.returncode == 0 and proc.stdout.strip():
            info["last_commit_date"] = proc.stdout.strip()
    except Exception:
        pass

    try:
        proc = rtk_wrap("git", "-C", project_path, "rev-list", "--count", "HEAD",
                        capture_output=True, text=True)
        if proc.returncode == 0 and proc.stdout.strip().isdigit():
            info["commit_count"] = int(proc.stdout.strip())
    except Exception:
        pass

    try:
        proc = rtk_wrap("git", "-C", project_path, "ls-files",
                        capture_output=True, text=True)
        if proc.returncode == 0:
            info["file_count"] = len(proc.stdout.strip().splitlines())
    except Exception:
        pass

    return info


def analyze_project(project_path: str, verbose: bool = False) -> dict:
    """Analyze a single local project."""
    p = Path(project_path).resolve()
    result: dict = {
        "path": str(p),
        "name": p.name,
    }

    if not p.exists():
        result["error"] = f"Path does not exist: {p}"
        return result

    if not p.is_dir():
        result["error"] = f"Path is not a directory: {p}"
        return result

    try:
        result["build_systems"] = detect_build_systems(str(p), verbose)
        result["ci_cd"] = detect_ci_cd(str(p), verbose)
        result["languages"] = detect_languages(str(p))
        result.update(get_git_info(str(p)))
    except Exception as e:
        result["error"] = str(e)

    return result


def main():
    parser = argparse.ArgumentParser(
        description="Gather local project metadata via project-detection."
    )
    parser.add_argument(
        "paths", nargs="+",
        help="Paths to local project directories",
    )
    parser.add_argument("--verbose", action="store_true", help="Print full detection output")
    parser.add_argument("--dry-run", action="store_true", help="Print what would be analyzed without running detection")

    args = parser.parse_args()

    if args.dry_run:
        print(json.dumps({
            "dry_run": True,
            "would_analyze": [str(Path(p).resolve()) for p in args.paths],
        }, indent=2))
        return

    results = []
    for path in args.paths:
        if args.verbose:
            print(f"Analyzing {path}...", file=sys.stderr)
        results.append(analyze_project(path, verbose=args.verbose))

    print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()
