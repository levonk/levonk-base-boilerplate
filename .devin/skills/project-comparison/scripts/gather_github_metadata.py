#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Gather GitHub metadata for a list of repositories via the GitHub REST API
(through `gh api` for authenticated access).

Usage:
    uv run --script gather_github_metadata.py owner1/repo1 owner2/repo2 ...
    ./gather_github_metadata.py owner1/repo1 owner2/repo2 --verbose
    python gather_github_metadata.py owner1/repo1 --dry-run

Output (stdout): JSON array of per-repo metadata objects.

Each object contains:
    - repo: "owner/repo"
    - url: full GitHub URL
    - description: repo description
    - stars: stargazers_count
    - forks: forks_count
    - watchers: watchers_count
    - open_issues: open_issues_count
    - license: license key (e.g., "mit", "apache-2.0") or null
    - language: primary language
    - topics: list of topics
    - created_at: ISO date
    - pushed_at: ISO date (last push)
    - updated_at: ISO date (last repo metadata update)
    - archived: bool
    - fork: bool (is this a fork)
    - homepage: homepage URL or null
    - error: error message if lookup failed (object only has this + repo fields)

Quiet by default; --verbose prints full API responses; --dry-run prints what
would be fetched without making API calls.
"""

import argparse
import json
import os
import shutil
import subprocess
import sys

# ---------------------------------------------------------------------------
# Devbox detection — use `devbox run --` to execute commands when devbox
# is available and a devbox.json exists, unless already inside a devbox shell.
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
# RTK (Rust Token Killer) detection — use rtk as a proxy for git and other
# supported commands when available to reduce LLM token consumption.
# See: https://github.com/rtk-ai/rtk
# ---------------------------------------------------------------------------
def is_rtk_available() -> bool:
    return shutil.which("rtk") is not None


def rtk_wrap(tool: str, *args: str, **kwargs) -> subprocess.CompletedProcess:
    if is_rtk_available():
        return devbox_run(["rtk", tool, *args], **kwargs)
    return devbox_run([tool, *args], **kwargs)


def check_gh() -> bool:
    """Check that gh CLI is available."""
    return shutil.which("gh") is not None


def fetch_repo_metadata(repo: str, verbose: bool = False) -> dict:
    """Fetch metadata for a single repo via gh api."""
    result: dict = {"repo": repo, "url": f"https://github.com/{repo}"}

    try:
        proc = rtk_wrap(
            "gh", "api", f"repos/{repo}",
            "--jq",
            "{"
            "stars: .stargazers_count, "
            "forks: .forks_count, "
            "watchers: .watchers_count, "
            "open_issues: .open_issues_count, "
            "license: (.license.spdx_id // null), "
            "language: .language, "
            "topics: .topics, "
            "description: .description, "
            "created_at: .created_at, "
            "pushed_at: .pushed_at, "
            "updated_at: .updated_at, "
            "archived: .archived, "
            "fork: .fork, "
            "homepage: .homepage"
            "}",
            capture_output=True, text=True,
        )
        if proc.returncode != 0:
            result["error"] = proc.stderr.strip() or f"gh api failed with exit code {proc.returncode}"
            if verbose:
                result["raw_stderr"] = proc.stderr
            return result

        data = json.loads(proc.stdout)
        result.update(data)
        if verbose:
            result["_raw_jq_output"] = proc.stdout
        return result

    except json.JSONDecodeError as e:
        result["error"] = f"Failed to parse gh api output: {e}"
        if verbose:
            result["_raw_stdout"] = proc.stdout
        return result
    except Exception as e:
        result["error"] = str(e)
        return result


def main():
    parser = argparse.ArgumentParser(
        description="Gather GitHub metadata for a list of repositories."
    )
    parser.add_argument(
        "repos", nargs="+",
        help="Repositories in owner/repo format (or full GitHub URLs)",
    )
    parser.add_argument("--verbose", action="store_true", help="Print full API responses")
    parser.add_argument("--dry-run", action="store_true", help="Print what would be fetched without making API calls")

    args = parser.parse_args()

    if not check_gh():
        print(json.dumps({"error": "gh CLI not found. Install from https://cli.github.com/"}))
        sys.exit(1)

    # Normalize repo identifiers: strip URLs to owner/repo
    repos = []
    for r in args.repos:
        r = r.strip()
        if r.startswith("https://github.com/"):
            r = r[len("https://github.com/"):]
            if r.endswith(".git"):
                r = r[:-4]
        if r.startswith("git@github.com:"):
            r = r[len("git@github.com:"):]
            if r.endswith(".git"):
                r = r[:-4]
        repos.append(r)

    if args.dry_run:
        print(json.dumps({
            "dry_run": True,
            "would_fetch": repos,
            "api_calls": [f"gh api repos/{r}" for r in repos],
        }, indent=2))
        return

    results = []
    for repo in repos:
        if args.verbose:
            print(f"Fetching metadata for {repo}...", file=sys.stderr)
        data = fetch_repo_metadata(repo, verbose=args.verbose)
        results.append(data)

    print(json.dumps(results, indent=2))


if __name__ == "__main__":
    main()
