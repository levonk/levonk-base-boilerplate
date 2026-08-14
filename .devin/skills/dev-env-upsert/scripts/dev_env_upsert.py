#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
dev_env_upsert.py — Manage devbox.json + .envrc + justfile as a coupled trio.

Operations:
    setup          Primary: add-packages + add-prime-steps + update-envrc in one call.
    add-packages   Loop over `devbox add` per package.
    remove-packages Loop over `devbox remove` per package.
    add-prime-steps Fold indexer invocations into prime_impl (file-type-aware, idempotent).
    update-envrc   Regenerate direnv block + append async prime_impl trigger (idempotent).
    reconcile      Detect project stack, suggest packages.
    validate       Check devbox.json + .envrc + justfile prime_impl integrity.

Usage:
    uv run --script dev_env_upsert.py setup \
        --packages codegraph,direnv,just \
        --prime-steps "codegraph index .:codegraph" \
        --envrc-async-prime --target .
    uv run --script dev_env_upsert.py add-packages --packages a,b,c --target .
    uv run --script dev_env_upsert.py remove-packages --packages a,b,c --target .
    uv run --script dev_env_upsert.py add-prime-steps \
        --prime-steps "codegraph index .:codegraph" --target .
    uv run --script dev_env_upsert.py update-envrc --async-prime --target .
    uv run --script dev_env_upsert.py reconcile --target .
    uv run --script dev_env_upsert.py validate --target .

Quiet by default; --verbose prints full detail; --dry-run prints what would
happen without making changes.
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
from pathlib import Path


# ---------------------------------------------------------------------------
# Indexer file-type registry (single source of truth for detection)
# ---------------------------------------------------------------------------

INDEXER_FILE_TYPES = {
    "codegraph": {
        "extensions": [
            ".rs", ".ts", ".tsx", ".js", ".jsx", ".py", ".go",
            ".java", ".kt", ".swift", ".c", ".cpp", ".h", ".hpp",
        ],
        "db_path": ".codegraph/codegraph.db",
        "requires_multi_repo": False,
    },
    "gitnexus": {
        "extensions": [
            ".rs", ".ts", ".tsx", ".js", ".jsx", ".py", ".go",
            ".java", ".kt", ".swift", ".c", ".cpp", ".h", ".hpp",
        ],
        "db_path": ".gitnexus/gitnexus.db",
        "requires_multi_repo": True,
    },
    "graphify": {
        "extensions": [
            ".pdf", ".md", ".docx", ".pptx", ".mp4", ".mov",
            ".png", ".jpg", ".svg",
        ],
        "db_path": ".graphify/graphify.db",
        "requires_multi_repo": False,
    },
}


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

def run(cmd, *, capture=True, check=False, cwd=None):
    """Run a command, returning CompletedProcess. Prints on verbose."""
    if os.environ.get("DEV_ENV_UPSERT_VERBOSE") == "1":
        print(f"  $ {' '.join(cmd)}", file=sys.stderr)
    return subprocess.run(
        cmd,
        capture_output=capture,
        text=True,
        check=check,
        cwd=cwd,
    )


def parse_csv(value):
    """Parse a comma-separated string into a list of stripped non-empty items."""
    if not value:
        return []
    return [v.strip() for v in value.split(",") if v.strip()]


def parse_prime_steps(value):
    """Parse 'cmd:idx,cmd:idx' into [(cmd, idx), ...]."""
    steps = []
    for item in parse_csv(value):
        if ":" not in item:
            print(f"  ! malformed prime-step (expected 'cmd:indexer'): {item!r}",
                  file=sys.stderr)
            continue
        cmd, idx = item.rsplit(":", 1)
        steps.append((cmd.strip(), idx.strip().lower()))
    return steps


def find_files_by_extension(root, extensions):
    """Return True if any file under root (non-hidden dirs) matches an extension."""
    ext_set = {e.lower() for e in extensions}
    for dirpath, dirnames, filenames in os.walk(root):
        # skip hidden dirs (.git, .codegraph, node_modules, etc.)
        dirnames[:] = [d for d in dirnames if not d.startswith(".") and d != "node_modules"]
        for fname in filenames:
            if Path(fname).suffix.lower() in ext_set:
                return True
    return False


def is_multi_repo_workspace(root):
    """Detect multi-repo workspace: multiple .git dirs in parent of root."""
    parent = Path(root).resolve().parent
    git_count = 0
    try:
        for entry in parent.iterdir():
            if entry.is_dir() and (entry / ".git").exists():
                git_count += 1
    except (PermissionError, FileNotFoundError):
        return False
    return git_count >= 2


def indexer_applies(indexer, target):
    """File-type-aware detection: does this indexer handle the project's files?"""
    spec = INDEXER_FILE_TYPES.get(indexer)
    if spec is None:
        return False, f"unknown indexer {indexer!r}"
    if not find_files_by_extension(target, spec["extensions"]):
        return False, f"no matching file types for {indexer}"
    if spec.get("requires_multi_repo") and not is_multi_repo_workspace(target):
        return False, f"{indexer} requires a multi-repo workspace (multiple .git in parent)"
    return True, "ok"


# ---------------------------------------------------------------------------
# devbox.json helpers (read-only via jq)
# ---------------------------------------------------------------------------

def read_devbox_packages(target):
    """Read the packages array from devbox.json via jq. Returns list or []."""
    devbox_json = Path(target) / "devbox.json"
    if not devbox_json.exists():
        return []
    result = run(
        ["jq", "-r", ".packages // [] | .[]', str(devbox_json)],
        capture=True,
    )
    if result.returncode != 0:
        # jq may output with quotes; try keys
        result = run(
            ["jq", "-r", '(.packages // []) | if type=="array" then .[] else keys[] end',
             str(devbox_json)],
            capture=True,
        )
    if result.returncode != 0:
        return []
    return [line.strip() for line in result.stdout.splitlines() if line.strip()]


# ---------------------------------------------------------------------------
# Operations: add-packages / remove-packages
# ---------------------------------------------------------------------------

def op_add_packages(args):
    packages = parse_csv(args.packages)
    if not packages:
        print("  ! no packages specified", file=sys.stderr)
        return 1
    rc = 0
    for pkg in packages:
        print(f"  + devbox add {pkg}")
        if args.dry_run:
            continue
        result = run(["devbox", "add", pkg], cwd=str(args.target))
        if result.returncode != 0:
            print(f"  ! devbox add {pkg} failed: {result.stderr.strip()}", file=sys.stderr)
            rc = result.returncode
    return rc


def op_remove_packages(args):
    packages = parse_csv(args.packages)
    if not packages:
        print("  ! no packages specified", file=sys.stderr)
        return 1
    rc = 0
    for pkg in packages:
        print(f"  - devbox remove {pkg}")
        if args.dry_run:
            continue
        result = run(["devbox", "remove", pkg], cwd=str(args.target))
        if result.returncode != 0:
            print(f"  ! devbox remove {pkg} failed: {result.stderr.strip()}", file=sys.stderr)
            rc = result.returncode
    return rc


# ---------------------------------------------------------------------------
# Operation: add-prime-steps (fold indexer into prime_impl)
# ---------------------------------------------------------------------------

PRIME_IMPL_RE = re.compile(r'(^prime_impl\s*:\s*\n)', re.MULTILINE)


def staleness_block(indexer):
    """Build the staleness-check block for an indexer."""
    spec = INDEXER_FILE_TYPES.get(indexer)
    db_path = spec["db_path"] if spec else f".{indexer}/{indexer}.db"
    # derive the index command from the indexer name
    return (
        f'    INDEX_DB="{db_path}"\n'
        f'    if [ ! -f "$INDEX_DB" ] || '
        f'[ $(find "$INDEX_DB" -mmin +60 2>/dev/null | wc -l) -gt 0 ]; then\n'
        f'        {indexer} index .\n'
        f'    fi\n'
    )


def ensure_prime_impl(justfile_path):
    """Ensure prime_impl target exists in justfile. Returns the target header line text or None."""
    text = justfile_path.read_text() if justfile_path.exists() else ""
    m = PRIME_IMPL_RE.search(text)
    if m:
        return m.group(1)
    return None


def op_add_prime_steps(args):
    steps = parse_prime_steps(args.prime_steps)
    if not steps:
        print("  ! no prime-steps specified", file=sys.stderr)
        return 1
    justfile_path = Path(args.target) / "justfile"
    text = justfile_path.read_text() if justfile_path.exists() else ""
    header = ensure_prime_impl(justfile_path)
    if header is None:
        print("  ! no prime_impl target found in justfile — create it first "
              "(use project-adopter for new targets)", file=sys.stderr)
        return 1

    changed = False
    for cmd, indexer in steps:
        applies, reason = indexer_applies(indexer, args.target)
        if not applies:
            print(f"  ~ skip {indexer}: {reason}")
            continue
        block = staleness_block(indexer)
        marker = f"# --- {indexer} staleness check (dev-env-upsert) ---"
        if marker in text:
            print(f"  = {indexer} staleness block already present (idempotent)")
            continue
        # Insert the block right after the prime_impl header line
        idx = text.index(header) + len(header)
        insertion = marker + "\n" + block
        text = text[:idx] + insertion + text[idx:]
        print(f"  + fold {indexer} staleness check into prime_impl")
        changed = True

    if changed and not args.dry_run:
        justfile_path.write_text(text)
    return 0


# ---------------------------------------------------------------------------
# Operation: update-envrc
# ---------------------------------------------------------------------------

ASYNC_PRIME_BLOCK = (
    "# Async prime_impl trigger (per dev-environment-practices/async-prime-internal.md)\n"
    "if [ -f devbox.json ] && command -v just >/dev/null 2>&1; then\n"
    "  if [ \"$DEVBOX_SHELL_ENABLED\" != \"1\" ]; then\n"
    "    nohup devbox run -- just prime_impl > /dev/null 2>&1 &\n"
    "  fi\n"
    "fi\n"
)

USE_DEVBOX_MARKER = "use devbox"


def op_update_envrc(args):
    envrc_path = Path(args.target) / ".envrc"
    # 1. Generate the direnv block from devbox
    result = run(
        ["devbox", "generate", "direnv", "--print-envrc"],
        cwd=str(args.target),
        capture=True,
    )
    generated = result.stdout if result.returncode == 0 else ""

    # 2. Preserve existing use_devbox block if present
    existing = envrc_path.read_text() if envrc_path.exists() else ""
    preserved_use_devbox = ""
    if USE_DEVBOX_MARKER in existing:
        # extract from the use_devbox function def or `use devbox` line to end of that section
        # keep it simple: keep everything up to the async block marker if any
        preserved_use_devbox = existing.split(
            "# Async prime_impl trigger"
        )[0].rstrip() + "\n"

    # 3. Compose new .envrc
    new_text = ""
    if generated.strip():
        new_text = generated.rstrip() + "\n\n"
    elif preserved_use_devbox:
        new_text = preserved_use_devbox
    else:
        # fallback: minimal use_devbox
        new_text = (
            "use_devbox() {\n"
            "    watch_file devbox.json\n"
            "    eval \"$(devbox shellenv)\"\n"
            "}\n\n"
            "use devbox\n\n"
        )

    # 4. Append async prime_impl trigger (idempotent)
    if "# Async prime_impl trigger" in new_text:
        print("  = async prime_impl trigger already present (idempotent)")
    else:
        if args.async_prime:
            new_text = new_text.rstrip() + "\n\n" + ASYNC_PRIME_BLOCK
            print("  + append async prime_impl trigger to .envrc")
        else:
            print("  ~ --async-prime not set; skipping trigger block")

    if args.dry_run:
        print("  (dry-run) .envrc would be written")
    else:
        envrc_path.write_text(new_text)
        print(f"  ✓ wrote {envrc_path}")
    return 0


# ---------------------------------------------------------------------------
# Operation: reconcile
# ---------------------------------------------------------------------------

STACK_PACKAGES = {
    "nx-monorepo": ["nodejs", "pnpm", "just"],
    "python": ["python3", "uv", "just"],
    "rust": ["rust-toolchain", "just"],
    "go": ["go", "just"],
    "java": ["jdk", "maven", "just"],
}


def detect_stack(target):
    """Detect project stack. Returns a stack key string."""
    root = Path(target)
    if (root / "nx.json").exists() or (root / "pnpm-workspace.yaml").exists():
        return "nx-monorepo"
    if (root / "pyproject.toml").exists() or (root / "setup.py").exists():
        return "python"
    if (root / "Cargo.toml").exists():
        return "rust"
    if (root / "go.mod").exists():
        return "go"
    if (root / "pom.xml").exists() or (root / "build.gradle").exists() or (root / "build.gradle.kts").exists():
        return "java"
    return "unknown"


def op_reconcile(args):
    stack = detect_stack(args.target)
    print(f"  detected stack: {stack}")
    suggested = STACK_PACKAGES.get(stack, [])
    current = set(read_devbox_packages(args.target))
    if not suggested:
        print("  ~ could not detect a known stack; no package suggestions")
        return 0
    missing = [p for p in suggested if p not in current]
    extra = [p for p in current if p not in suggested]
    if missing:
        print(f"  suggested packages to add: {', '.join(missing)}")
    else:
        print("  all suggested packages already present")
    if extra:
        print(f"  packages not in baseline (review): {', '.join(extra)}")
    return 0


# ---------------------------------------------------------------------------
# Operation: validate
# ---------------------------------------------------------------------------

def op_validate(args):
    root = Path(args.target)
    rc = 0

    devbox_json = root / "devbox.json"
    if not devbox_json.exists():
        print("  ! devbox.json missing", file=sys.stderr)
        rc = 1
    else:
        result = run(["jq", ".", str(devbox_json)], capture=True)
        if result.returncode != 0:
            print("  ! devbox.json is not valid JSON", file=sys.stderr)
            rc = 1
        else:
            print("  ✓ devbox.json valid")

    envrc = root / ".envrc"
    if not envrc.exists():
        print("  ! .envrc missing", file=sys.stderr)
        rc = 1
    else:
        text = envrc.read_text()
        if "use devbox" not in text and "use_devbox" not in text:
            print("  ! .envrc missing use_devbox block", file=sys.stderr)
            rc = 1
        else:
            print("  ✓ .envrc has use_devbox")
        if "# Async prime_impl trigger" in text:
            print("  ✓ .envrc has async prime_impl trigger")
        else:
            print("  ~ .envrc missing async prime_impl trigger (optional)")

    justfile = root / "justfile"
    if not justfile.exists():
        print("  ! justfile missing", file=sys.stderr)
        rc = 1
    else:
        text = justfile.read_text()
        if "prime_impl" not in text:
            print("  ! justfile missing prime_impl target", file=sys.stderr)
            rc = 1
        else:
            print("  ✓ justfile has prime_impl")
        if "staleness check" in text or "INDEX_DB" in text:
            print("  ✓ justfile prime_impl has staleness check")
        else:
            print("  ~ justfile prime_impl has no staleness check (optional)")

    return rc


# ---------------------------------------------------------------------------
# Operation: setup (primary — does everything)
# ---------------------------------------------------------------------------

def op_setup(args):
    print("== setup: add-packages ==")
    if args.packages:
        op_add_packages(args)
    else:
        print("  ~ no --packages; skipping add-packages")

    print("== setup: add-prime-steps ==")
    if args.prime_steps:
        op_add_prime_steps(args)
    else:
        print("  ~ no --prime-steps; skipping add-prime-steps")

    print("== setup: update-envrc ==")
    op_update_envrc(args)

    print("== setup: done ==")
    return 0


# ---------------------------------------------------------------------------
# Argument parser
# ---------------------------------------------------------------------------

def build_parser():
    parser = argparse.ArgumentParser(
        description="Manage devbox.json + .envrc + justfile as a coupled trio.",
    )
    parser.add_argument("--verbose", action="store_true",
                        help="print full detail")
    parser.add_argument("--dry-run", action="store_true",
                        help="print what would happen without making changes")
    sub = parser.add_subparsers(dest="command", required=True)

    def add_target(p):
        p.add_argument("--target", default=".", help="project root (default: .)")

    # setup
    p = sub.add_parser("setup", help="primary: add-packages + add-prime-steps + update-envrc")
    add_target(p)
    p.add_argument("--packages", default="", help="comma-separated devbox packages")
    p.add_argument("--prime-steps", default="",
                   help='comma-separated "cmd:indexer" steps to fold into prime_impl')
    p.add_argument("--envrc-async-prime", action="store_true",
                   help="append async prime_impl trigger to .envrc")
    p.set_defaults(func=op_setup)

    # add-packages
    p = sub.add_parser("add-packages", help="loop over devbox add per package")
    add_target(p)
    p.add_argument("--packages", required=True, help="comma-separated devbox packages")
    p.set_defaults(func=op_add_packages)

    # remove-packages
    p = sub.add_parser("remove-packages", help="loop over devbox remove per package")
    add_target(p)
    p.add_argument("--packages", required=True, help="comma-separated devbox packages")
    p.set_defaults(func=op_remove_packages)

    # add-prime-steps
    p = sub.add_parser("add-prime-steps",
                       help="fold indexer invocations into prime_impl (file-type-aware)")
    add_target(p)
    p.add_argument("--prime-steps", required=True,
                   help='comma-separated "cmd:indexer" steps')
    p.set_defaults(func=op_add_prime_steps)

    # update-envrc
    p = sub.add_parser("update-envrc",
                       help="regenerate direnv block + append async prime_impl trigger")
    add_target(p)
    p.add_argument("--async-prime", action="store_true",
                   help="append async prime_impl trigger block")
    p.set_defaults(func=op_update_envrc)

    # reconcile
    p = sub.add_parser("reconcile", help="detect stack, suggest packages")
    add_target(p)
    p.set_defaults(func=op_reconcile)

    # validate
    p = sub.add_parser("validate", help="check devbox.json + .envrc + justfile integrity")
    add_target(p)
    p.set_defaults(func=op_validate)

    return parser


def main(argv=None):
    parser = build_parser()
    args = parser.parse_args(argv)
    if args.verbose:
        os.environ["DEV_ENV_UPSERT_VERBOSE"] = "1"
    return args.func(args)


if __name__ == "__main__":
    sys.exit(main())
