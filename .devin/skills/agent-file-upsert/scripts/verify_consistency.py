#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Verify AGENTS.md hierarchy consistency and cross-check against README.md and code.

Run after agent-file-upsert has generated or updated AGENTS.md files.
Exit code 0 = all checks passed; non-zero = issues found (printed to stderr).

Checks:
  Internal (AGENTS.md hierarchy):
    1. Root AGENTS.md exists
    2. .agents/knowledge/developer.md exists if referenced from root AGENTS.md
    3. All markdown links in AGENTS.md files point to existing files
    4. internal-docs/oos/ exists if referenced
    5. internal-docs/improvements/INDEX.md exists if improvements referenced
    6. internal-docs/anti-patterns/INDEX.md exists if anti-patterns referenced
    7. Root AGENTS.md is under 250 lines (token efficiency)

  Convention (CLAUDE.md / AGENT.md):
    8. If CLAUDE.md exists, verify it is a valid referral or symlink to AGENTS.md
    9. If AGENT.md exists, verify it is a valid referral or symlink to AGENTS.md
   10. Symlink targets exist; referral targets (AGENTS.md) exist

  Cross-check (against README.md if it exists):
   11. README.md links to AGENTS.md
   12. Project name (first H1) matches between README.md and root AGENTS.md
   13. No content duplication (identical paragraph blocks >100 chars)
   14. README.md doesn't contain AGENTS.md-style sections (JIT Index,
       Universal Contracts, Definition of Done, Boundaries, Known Gotchas)

  Code-vs-docs (automated semantic checks):
   15. Commands referenced in AGENTS.md files exist in Justfile/Makefile/package.json
   16. Directories named in AGENTS.md files exist on disk

Usage:
    uv run --script verify_consistency.py /path/to/project
    uv run --script verify_consistency.py /path/to/project --verbose
    python verify_consistency.py /path/to/project
"""

import argparse
import json
import re
import sys
from pathlib import Path


# Sections that belong in AGENTS.md, not README.md
AGENTS_ONLY_SECTIONS = {
    "jit index",
    "universal contracts",
    "definition of done",
    "boundaries",
    "known gotchas",
    "usage protocol",
    "maintenance protocol",
    "local contracts",
    "search hints",
}


def extract_h1(text: str) -> str | None:
    """Return the first H1 heading text, stripping 'AGENTS.md — ' prefix if present."""
    for line in text.splitlines():
        if line.startswith("# ") and not line.startswith("##"):
            h1 = line[2:].strip()
            # AGENTS.md convention: "AGENTS.md — {project name}" — extract the project name
            if h1.startswith("AGENTS.md — "):
                return h1[len("AGENTS.md — "):].strip()
            return h1
    return None


def extract_links(text: str) -> list[str]:
    """Extract markdown link targets (relative paths from [text](path))."""
    return re.findall(r"\]\(([^)]+)\)", text)


def extract_paragraph_blocks(text: str) -> list[str]:
    """Extract paragraph blocks >100 chars, excluding code blocks and headers."""
    lines = text.splitlines()
    blocks: list[str] = []
    current: list[str] = []
    in_code = False
    for line in lines:
        if line.strip().startswith("```"):
            in_code = not in_code
            if current and len(" ".join(current).strip()) > 100:
                blocks.append(" ".join(current).strip())
            current = []
            continue
        if in_code:
            continue
        if line.startswith("#"):
            if current and len(" ".join(current).strip()) > 100:
                blocks.append(" ".join(current).strip())
            current = []
            continue
        if not line.strip():
            if current and len(" ".join(current).strip()) > 100:
                blocks.append(" ".join(current).strip())
            current = []
            continue
        current.append(line.strip())
    if current and len(" ".join(current).strip()) > 100:
        blocks.append(" ".join(current).strip())
    return blocks


def extract_section_headers(text: str) -> set[str]:
    """Extract all section headers (## or ###) as lowercase strings."""
    headers = set()
    for line in text.splitlines():
        if line.startswith("##"):
            header = line.lstrip("#").strip().lower()
            if header:
                headers.add(header)
    return headers


def resolve_link(base: Path, target: str) -> Path:
    """Resolve a markdown link target relative to base file's directory."""
    clean = target.split("#")[0].split("?")[0].strip()
    if not clean or clean.startswith("http"):
        return base  # external or anchor-only — skip
    return (base.parent / clean).resolve()


def check_link_integrity(file_path: Path, verbose: bool) -> list[str]:
    """Check that all markdown links in a file point to existing files."""
    issues: list[str] = []
    text = file_path.read_text(encoding="utf-8")
    for link in extract_links(text):
        resolved = resolve_link(file_path, link)
        if link.startswith("http") or link.startswith("#"):
            continue
        if not resolved.exists():
            issues.append(f"  {file_path.name}: broken link '{link}' -> {resolved}")
    if verbose and not issues:
        print(f"  [ok] link integrity: {file_path.name}")
    return issues


def check_content_duplication(file_a: Path, file_b: Path, verbose: bool) -> list[str]:
    """Check for identical paragraph blocks between two files."""
    issues: list[str] = []
    blocks_a = set(extract_paragraph_blocks(file_a.read_text(encoding="utf-8")))
    blocks_b = set(extract_paragraph_blocks(file_b.read_text(encoding="utf-8")))
    shared = blocks_a & blocks_b
    for block in shared:
        preview = block[:80] + "..." if len(block) > 80 else block
        issues.append(f"  duplicated content ({len(block)} chars): '{preview}'")
    if verbose and not issues:
        print(f"  [ok] no content duplication between {file_a.name} and {file_b.name}")
    return issues


# ---------------------------------------------------------------------------
# Code-vs-docs checks (automated semantic checks)
# ---------------------------------------------------------------------------

def get_justfile_targets(project_root: Path) -> set[str]:
    """Extract recipe names from Justfile/justfile."""
    targets: set[str] = set()
    for name in ("Justfile", "justfile", "JUSTFILE"):
        justfile = project_root / name
        if justfile.exists():
            for line in justfile.read_text(encoding="utf-8").splitlines():
                # Just recipes: "recipe_name:" or "recipe_name args:"
                # Exclude ":=" variable assignments
                m = re.match(r"^([a-zA-Z_][\w-]*)\b[^:]*:(?!=)", line)
                if m:
                    targets.add(m.group(1))
    return targets


def get_makefile_targets(project_root: Path) -> set[str]:
    """Extract targets from Makefile."""
    targets: set[str] = set()
    makefile = project_root / "Makefile"
    if makefile.exists():
        for line in makefile.read_text(encoding="utf-8").splitlines():
            m = re.match(r"^([a-zA-Z_][\w-]*)\s*:", line)
            if m and not line.startswith("\t"):
                targets.add(m.group(1))
    return targets


def get_npm_scripts(project_root: Path) -> set[str]:
    """Extract script names from package.json."""
    pkg = project_root / "package.json"
    if not pkg.exists():
        return set()
    try:
        data = json.loads(pkg.read_text(encoding="utf-8"))
        return set((data.get("scripts") or {}).keys())
    except (json.JSONDecodeError, KeyError):
        return set()


def extract_just_commands(text: str) -> set[str]:
    """Extract `just <command>` references from markdown text."""
    return set(re.findall(r"\bjust\s+([a-zA-Z_][\w-]*)", text))


def extract_make_commands(text: str) -> set[str]:
    """Extract `make <command>` references from markdown text."""
    return set(re.findall(r"\bmake\s+([a-zA-Z_][\w-]*)", text))


def extract_npm_commands(text: str) -> set[str]:
    """Extract `npm run <command>` references from markdown text."""
    return set(re.findall(r"\bnpm\s+run\s+([a-zA-Z_][\w-]*)", text))


def check_command_existence(file_path: Path, project_root: Path, verbose: bool) -> list[str]:
    """Check that commands referenced in a doc file exist in the task runner."""
    issues: list[str] = []
    text = file_path.read_text(encoding="utf-8")

    just_targets = get_justfile_targets(project_root)
    make_targets = get_makefile_targets(project_root)
    npm_scripts = get_npm_scripts(project_root)

    # Check `just` commands
    for cmd in extract_just_commands(text):
        if just_targets and cmd not in just_targets:
            issues.append(f"  {file_path.name}: `just {cmd}` referenced but not found in Justfile")

    # Check `make` commands
    for cmd in extract_make_commands(text):
        if make_targets and cmd not in make_targets:
            issues.append(f"  {file_path.name}: `make {cmd}` referenced but not found in Makefile")

    # Check `npm run` commands
    for cmd in extract_npm_commands(text):
        if npm_scripts and cmd not in npm_scripts:
            issues.append(f"  {file_path.name}: `npm run {cmd}` referenced but not found in package.json scripts")

    if verbose and not issues:
        print(f"  [ok] command existence: {file_path.name}")
    return issues


def strip_code_blocks(text: str) -> str:
    """Remove triple-backtick code blocks from markdown text."""
    result: list[str] = []
    in_code = False
    for line in text.splitlines():
        if line.strip().startswith("```"):
            in_code = not in_code
            continue
        if not in_code:
            result.append(line)
    return "\n".join(result)


def extract_tree_dirs(text: str) -> set[str]:
    """Extract directory names from tree-block lines (├──, └──) inside code blocks.

    Only extracts multi-level paths (containing /) to avoid false positives from
    generic subdirectory names (scripts, references, etc.) in sub-folder AGENTS.md files.
    """
    dirs: set[str] = set()
    in_code = False
    for line in text.splitlines():
        if line.strip().startswith("```"):
            in_code = not in_code
            continue
        if not in_code:
            continue
        # Tree entries: ├── dirname/ or └── dirname/
        m = re.match(r"^[│├└─\s]+(.+?)/?\s*(?:#.*)?$", line)
        if m:
            entry = m.group(1).strip()
            # Only accept multi-level paths with / (e.g., src/current/, apps/web/)
            # Skip single names (scripts, references, assets) — too many false positives
            if "/" in entry and re.match(r"^[\w./-]+$", entry):
                # Take the path up to the first space (in case of inline comments)
                path_part = entry.split()[0].rstrip("/")
                if path_part and ".." not in path_part:
                    dirs.add(path_part)
    return dirs


def extract_directory_refs(text: str) -> set[str]:
    """Extract directory-like paths referenced in markdown text.

    Conservative: only extracts paths that are clearly filesystem paths.
    - Tree block entries (├──, └──) inside code blocks
    - Inline backtick paths starting with known project prefixes (src/, build/, .github/, etc.)
    Skips: Go package names, generic subdir names, GitHub repo paths, relative paths with ..
    """
    dirs: set[str] = set()
    # Known top-level directory prefixes that indicate a real filesystem path
    path_prefixes = (
        "src/", "build/", ".github/", ".agents/", "internal-docs/",
        "apps/", "packages/",
        "./",
    )
    # Strip code blocks, then look for inline backtick paths
    prose = strip_code_blocks(text)
    for m in re.finditer(r"`([^`\n]+)`", prose):
        path = m.group(1).strip()
        # Only accept paths with known prefixes
        if not path.startswith(path_prefixes):
            continue
        # Skip paths with wildcards, template syntax, or angle brackets
        if "*" in path or "<" in path or ">" in path or "?" in path:
            continue
        if " in path or " in path:
            continue
        if ".." in path:
            continue
        dirs.add(path.rstrip("/"))
    # Also extract from tree blocks
    dirs.update(extract_tree_dirs(text))
    return dirs


def check_directory_existence(file_path: Path, project_root: Path, verbose: bool) -> list[str]:
    """Check that directories referenced in a doc file exist on disk.

    Paths are resolved relative to the project root, not the doc file's location,
    since documentation paths are conventionally project-root-relative.
    """
    issues: list[str] = []
    text = file_path.read_text(encoding="utf-8")
    for dir_ref in extract_directory_refs(text):
        resolved = (project_root / dir_ref).resolve()
        try:
            resolved.relative_to(project_root)
        except ValueError:
            continue  # outside project root — skip
        if not resolved.exists():
            issues.append(f"  {file_path.name}: directory '{dir_ref}' referenced but not found at {resolved}")
    if verbose and not issues:
        print(f"  [ok] directory existence: {file_path.name}")
    return issues



def find_agents_files(root: Path) -> list[Path]:
    """Find all AGENTS.md files in the project."""
    return sorted(root.rglob("AGENTS.md"))


def check_convention_file(file_path: Path, agents_path: Path, verbose: bool) -> list[str]:
    """Check that a convention file (CLAUDE.md, AGENT.md) is a valid referral or symlink.

    A valid convention file is either:
    - A symlink pointing to AGENTS.md (or any existing file)
    - A referral containing @AGENTS.md or a markdown link to AGENTS.md
    """
    issues: list[str] = []
    if not file_path.exists():
        return issues  # not present — nothing to check

    # Check if it's a symlink
    if file_path.is_symlink():
        target = file_path.resolve()
        if not target.exists():
            issues.append(f"  {file_path.name}: symlink target {target} does not exist")
        elif verbose:
            print(f"  [ok] {file_path.name} is a valid symlink -> {target.name}")
        return issues

    # Not a symlink — check if it's a referral
    content = file_path.read_text(encoding="utf-8").strip()
    # Referral patterns: @AGENTS.md, "Refer to AGENTS.md", "[AGENTS.md](AGENTS.md)"
    is_referral = (
        "@AGENTS.md" in content
        or "refer to" in content.lower() and "agents.md" in content.lower()
        or re.search(r"\[.*?AGENTS\.md.*?\]\(AGENTS\.md\)", content, re.IGNORECASE)
    )
    if is_referral:
        # Verify the referenced AGENTS.md exists
        if not agents_path.exists():
            issues.append(f"  {file_path.name}: refers to AGENTS.md but {agents_path} does not exist")
        elif verbose:
            print(f"  [ok] {file_path.name} is a valid referral to AGENTS.md")
    else:
        # Not a symlink and not a referral — independent content
        issues.append(
            f"  {file_path.name}: contains independent content (not a symlink or referral to AGENTS.md). "
            f"Consider converting to a referral (@AGENTS.md) or symlink to AGENTS.md to maintain a single source of truth."
        )
    return issues


def verify(project_root: Path, verbose: bool) -> list[str]:
    """Run all consistency checks. Returns list of issue strings."""
    issues: list[str] = []

    root_agents = project_root / "AGENTS.md"
    readme = project_root / "README.md"
    dev_guide = project_root / ".agents" / "knowledge" / "developer.md"
    oos_dir = project_root / "internal-docs" / "oos"
    improvements_index = project_root / "internal-docs" / "improvements" / "INDEX.md"
    anti_patterns_index = project_root / "internal-docs" / "anti-patterns" / "INDEX.md"
    claude_md = project_root / "CLAUDE.md"
    agent_md = project_root / "AGENT.md"

    # --- Internal checks ---

    # 1. Root AGENTS.md exists
    if not root_agents.exists():
        issues.append(f"  MISSING: root AGENTS.md not found at {root_agents}")
        return issues  # can't check anything else without it
    if verbose:
        print(f"  [ok] root AGENTS.md exists")

    # 2. Developer guide exists if referenced
    root_text = root_agents.read_text(encoding="utf-8")
    if "developer.md" in root_text or "developer" in root_text.lower():
        if not dev_guide.exists():
            issues.append(f"  MISSING: developer guide referenced in AGENTS.md but {dev_guide} not found")
        elif verbose:
            print(f"  [ok] developer guide exists at .agents/knowledge/developer.md")

    # 3. Link integrity for all AGENTS.md files
    agents_files = find_agents_files(project_root)
    for af in agents_files:
        issues.extend(check_link_integrity(af, verbose))

    # 4. internal-docs/oos/ exists if referenced
    if "internal-docs/oos" in root_text or "out of scope" in root_text.lower():
        if not oos_dir.exists():
            issues.append(f"  MISSING: out-of-scope referenced in AGENTS.md but {oos_dir} not found")
        elif verbose:
            print(f"  [ok] internal-docs/oos/ exists")

    # 5. internal-docs/improvements/INDEX.md exists if referenced
    if "internal-docs/improvements" in root_text or "improvements" in root_text.lower():
        if not improvements_index.exists():
            issues.append(f"  MISSING: improvements referenced in AGENTS.md but {improvements_index} not found")
        elif verbose:
            print(f"  [ok] internal-docs/improvements/INDEX.md exists")

    # 6. internal-docs/anti-patterns/INDEX.md exists if referenced
    if "internal-docs/anti-patterns" in root_text or "anti-patterns" in root_text.lower() or "anti patterns" in root_text.lower():
        if not anti_patterns_index.exists():
            issues.append(f"  MISSING: anti-patterns referenced in AGENTS.md but {anti_patterns_index} not found")
        elif verbose:
            print(f"  [ok] internal-docs/anti-patterns/INDEX.md exists")

    # 7. Root AGENTS.md line count
    line_count = len(root_text.splitlines())
    if line_count > 250:
        issues.append(f"  root AGENTS.md is {line_count} lines (recommended <250 for token efficiency)")
    elif verbose:
        print(f"  [ok] root AGENTS.md is {line_count} lines")

    # --- Convention checks (CLAUDE.md / AGENT.md) ---

    # 8-10. Check convention files
    issues.extend(check_convention_file(claude_md, root_agents, verbose))
    issues.extend(check_convention_file(agent_md, root_agents, verbose))

    # --- Cross-checks against README.md ---

    if not readme.exists():
        if verbose:
            print(f"  [skip] no README.md found — cross-checks skipped (run readme-upsert first)")
        # Still run code-vs-docs checks even without README
        for af in agents_files:
            issues.extend(check_command_existence(af, project_root, verbose))
            issues.extend(check_directory_existence(af, project_root, verbose))
        return issues

    readme_text = readme.read_text(encoding="utf-8")

    # 6. README links to AGENTS.md
    if "AGENTS.md" not in readme_text:
        issues.append(f"  README.md does not link to AGENTS.md — README should reference the AI agent documentation")
    elif verbose:
        print(f"  [ok] README.md links to AGENTS.md")

    # 7. Project name consistency
    agents_h1 = extract_h1(root_text)
    readme_h1 = extract_h1(readme_text)
    if agents_h1 and readme_h1 and agents_h1.lower() != readme_h1.lower():
        issues.append(f"  project name mismatch: AGENTS.md H1='{agents_h1}' vs README.md H1='{readme_h1}'")
    elif verbose and agents_h1 and readme_h1:
        print(f"  [ok] project name consistent: '{agents_h1}'")

    # 8. No content duplication
    issues.extend(check_content_duplication(root_agents, readme, verbose))

    # 9. README doesn't have AGENTS.md-style sections
    readme_sections = extract_section_headers(readme_text)
    leaked = readme_sections & AGENTS_ONLY_SECTIONS
    if leaked:
        issues.append(f"  README.md contains AGENTS.md-style sections: {', '.join(sorted(leaked))}")
    elif verbose:
        print(f"  [ok] README.md has no AGENTS.md-style sections")

    # --- Code-vs-docs checks (automated semantic checks) ---

    # 10. Command existence — commands in AGENTS.md files must exist in task runner
    for af in agents_files:
        issues.extend(check_command_existence(af, project_root, verbose))

    # 11. Directory existence — directories named in AGENTS.md files must exist
    for af in agents_files:
        issues.extend(check_directory_existence(af, project_root, verbose))

    return issues


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify AGENTS.md hierarchy consistency and cross-check against README.md")
    parser.add_argument("project_root", type=Path, help="Path to the project root to verify")
    parser.add_argument("--verbose", "-v", action="store_true", help="Print passing checks too")
    args = parser.parse_args()

    project_root = args.project_root.resolve()
    if not project_root.is_dir():
        print(f"ERROR: {project_root} is not a directory", file=sys.stderr)
        return 2

    print(f"Verifying AGENTS.md consistency in: {project_root}")
    issues = verify(project_root, args.verbose)

    if issues:
        print(f"\nFAILED — {len(issues)} issue(s) found:", file=sys.stderr)
        for issue in issues:
            print(issue, file=sys.stderr)
        return 1

    print("\nPASSED — all consistency checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
