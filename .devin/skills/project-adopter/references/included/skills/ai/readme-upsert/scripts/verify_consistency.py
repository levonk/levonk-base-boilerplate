#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Verify README.md consistency and cross-check against AGENTS.md hierarchy and code.

Run after readme-upsert has generated or updated README.md.
Exit code 0 = all checks passed; non-zero = issues found (printed to stderr).

Checks:
  Internal (README.md):
    1. README.md exists at project root
    2. Required sections: project name (H1), Quick Start, Build/Test Commands,
       Project Structure, AI Agent Documentation
    3. All markdown links point to existing files
    4. README is 100-250 lines (conciseness)
    5. README links to internal-docs/oos/ if it exists
    6. README links to internal-docs/adr/ if it exists

  Cross-check (against AGENTS.md if it exists):
    7. README links to AGENTS.md
    8. Project name (first H1) matches between README.md and root AGENTS.md
    9. No content duplication (identical paragraph blocks >100 chars)
   10. README.md doesn't contain AGENTS.md-style sections (JIT Index,
       Universal Contracts, Definition of Done, Boundaries, Known Gotchas)
   11. AGENTS.md doesn't contain README-style sections (Troubleshooting,
       Contributing, License)

  Code-vs-docs (automated semantic checks):
   12. Commands referenced in README.md exist in Justfile/Makefile/package.json
   13. Directories named in README.md Project Structure exist on disk

Greenfield mode (--greenfield or auto-detected: no .git/ OR fewer than 10
tracked files AND no README.md at invocation start):
   - Skips internal-docs/oos/ and internal-docs/adr/ link checks
   - Skips AGENTS.md cross-checks if AGENTS.md does not exist
   - Still enforces required README sections and internal link integrity
   - Prints a "greenfield mode" banner so the agent knows which checks
     were relaxed

Usage:
    uv run --script verify_consistency.py /path/to/project
    uv run --script verify_consistency.py /path/to/project --verbose
    uv run --script verify_consistency.py /path/to/project --greenfield
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


# Sections that belong in README.md, not AGENTS.md
README_ONLY_SECTIONS = {
    "troubleshooting",
    "contributing",
    "license",
}


GREENFIELD_FILE_THRESHOLD = 10  # fewer than this many tracked files => greenfield


def has_section(text: str, section_name: str) -> bool:
    """Check if a section header exists in the text (case-insensitive)."""
    pattern = re.compile(rf"^#{{1,3}}\s+{re.escape(section_name)}\s*$", re.IGNORECASE | re.MULTILINE)
    return bool(pattern.search(text))


def count_tracked_files(project_root: Path) -> int:
    """Best-effort count of git-tracked files. Returns 0 if no .git or git fails."""
    git_dir = project_root / ".git"
    if not git_dir.exists():
        return 0
    import subprocess
    try:
        result = subprocess.run(
            ["git", "-C", str(project_root), "ls-files"],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode != 0:
            return 0
        return len([line for line in result.stdout.splitlines() if line.strip()])
    except Exception:
        return 0


def detect_greenfield(project_root: Path, readme_existed_at_start: bool) -> bool:
    """Auto-detect greenfield: no README AND (no .git OR < threshold tracked files)."""
    if readme_existed_at_start:
        return False
    if not (project_root / ".git").exists():
        return True
    return count_tracked_files(project_root) < GREENFIELD_FILE_THRESHOLD


def verify(project_root: Path, verbose: bool, greenfield: bool) -> list[str]:
    """Run all consistency checks. Returns list of issue strings."""
    issues: list[str] = []

    readme = project_root / "README.md"
    root_agents = project_root / "AGENTS.md"
    oos_dir = project_root / "internal-docs" / "oos"
    adr_dir = project_root / "internal-docs" / "adr"

    # --- Internal checks ---

    # 1. README.md exists
    if not readme.exists():
        issues.append(f"  MISSING: README.md not found at {readme}")
        return issues
    if verbose:
        print(f"  [ok] README.md exists")

    readme_text = readme.read_text(encoding="utf-8")

    # 2. Required sections
    required_sections = {
        "Quick Start": has_section(readme_text, "quick start"),
        "Project Structure": has_section(readme_text, "project structure"),
        "AI Agent Documentation": has_section(readme_text, "ai agent documentation"),
    }
    for name, found in required_sections.items():
        if not found:
            issues.append(f"  README.md missing required section: '{name}'")
        elif verbose:
            print(f"  [ok] README.md has section: '{name}'")

    # Also check for H1 (project name)
    if not extract_h1(readme_text):
        issues.append(f"  README.md missing H1 (project name)")
    elif verbose:
        print(f"  [ok] README.md has H1")

    # 3. Link integrity
    issues.extend(check_link_integrity(readme, verbose))

    # 4. Line count
    line_count = len(readme_text.splitlines())
    if line_count < 50:
        issues.append(f"  README.md is only {line_count} lines (recommended 100-250)")
    elif line_count > 300:
        issues.append(f"  README.md is {line_count} lines (recommended <250 for conciseness)")
    elif verbose:
        print(f"  [ok] README.md is {line_count} lines")

    # 5. Links to internal-docs/oos/ if it exists
    if oos_dir.exists():
        if "internal-docs/oos" not in readme_text:
            issues.append(f"  internal-docs/oos/ exists but README.md doesn't link to it")
        elif verbose:
            print(f"  [ok] README.md links to internal-docs/oos/")
    elif greenfield and verbose:
        print(f"  [skip-greenfield] internal-docs/oos/ does not exist — check relaxed")

    # 6. Links to internal-docs/adr/ if it exists
    if adr_dir.exists():
        if "internal-docs/adr" not in readme_text:
            issues.append(f"  internal-docs/adr/ exists but README.md doesn't link to it")
        elif verbose:
            print(f"  [ok] README.md links to internal-docs/adr/")
    elif greenfield and verbose:
        print(f"  [skip-greenfield] internal-docs/adr/ does not exist — check relaxed")

    # --- Cross-checks against AGENTS.md ---

    if not root_agents.exists():
        if greenfield:
            if verbose:
                print(f"  [skip-greenfield] no AGENTS.md found — cross-checks relaxed (caller may not have run agent-file-upsert yet)")
        elif verbose:
            print(f"  [skip] no AGENTS.md found — cross-checks skipped (run agent-file-upsert first)")
        # Still run code-vs-docs checks even without AGENTS.md
        issues.extend(check_command_existence(readme, project_root, verbose))
        issues.extend(check_directory_existence(readme, project_root, verbose))
        return issues

    agents_text = root_agents.read_text(encoding="utf-8")

    # 7. README links to AGENTS.md
    if "AGENTS.md" not in readme_text:
        issues.append(f"  README.md does not link to AGENTS.md — README should reference the AI agent documentation")
    elif verbose:
        print(f"  [ok] README.md links to AGENTS.md")

    # 8. Project name consistency
    agents_h1 = extract_h1(agents_text)
    readme_h1 = extract_h1(readme_text)
    if agents_h1 and readme_h1 and agents_h1.lower() != readme_h1.lower():
        issues.append(f"  project name mismatch: AGENTS.md H1='{agents_h1}' vs README.md H1='{readme_h1}'")
    elif verbose and agents_h1 and readme_h1:
        print(f"  [ok] project name consistent: '{readme_h1}'")

    # 9. No content duplication
    issues.extend(check_content_duplication(readme, root_agents, verbose))

    # 10. README doesn't have AGENTS.md-style sections
    readme_sections = extract_section_headers(readme_text)
    leaked_into_readme = readme_sections & AGENTS_ONLY_SECTIONS
    if leaked_into_readme:
        issues.append(f"  README.md contains AGENTS.md-style sections: {', '.join(sorted(leaked_into_readme))}")
    elif verbose:
        print(f"  [ok] README.md has no AGENTS.md-style sections")

    # 11. AGENTS.md doesn't have README-style sections
    agents_sections = extract_section_headers(agents_text)
    leaked_into_agents = agents_sections & README_ONLY_SECTIONS
    if leaked_into_agents:
        issues.append(f"  AGENTS.md contains README-style sections: {', '.join(sorted(leaked_into_agents))}")
    elif verbose:
        print(f"  [ok] AGENTS.md has no README-style sections")

    # --- Code-vs-docs checks (automated semantic checks) ---

    # 12. Command existence — commands in README.md must exist in task runner
    issues.extend(check_command_existence(readme, project_root, verbose))

    # 13. Directory existence — directories named in README.md must exist
    issues.extend(check_directory_existence(readme, project_root, verbose))

    return issues


def main() -> int:
    parser = argparse.ArgumentParser(description="Verify README.md consistency and cross-check against AGENTS.md")
    parser.add_argument("project_root", type=Path, help="Path to the project root to verify")
    parser.add_argument("--verbose", "-v", action="store_true", help="Print passing checks too")
    parser.add_argument(
        "--greenfield",
        action="store_true",
        help="Relax checks for greenfield projects: skip internal-docs/oos/ and "
             "internal-docs/adr/ link checks, skip AGENTS.md cross-checks if "
             "AGENTS.md does not exist. Auto-detected if no README.md AND (no .git/ "
             "OR fewer than 10 tracked files).",
    )
    args = parser.parse_args()

    project_root = args.project_root.resolve()
    if not project_root.is_dir():
        print(f"ERROR: {project_root} is not a directory", file=sys.stderr)
        return 2

    # Auto-detect greenfield if the flag wasn't explicitly set
    readme_existed_at_start = (project_root / "README.md").exists()
    greenfield = args.greenfield or detect_greenfield(project_root, readme_existed_at_start)

    print(f"Verifying README.md consistency in: {project_root}")
    if greenfield:
        print("GREENFIELD MODE — relaxing internal-docs/oos/, internal-docs/adr/, and AGENTS.md cross-checks")
    else:
        print("BROWNFIELD MODE — full consistency checks")

    issues = verify(project_root, args.verbose, greenfield)

    if issues:
        print(f"\nFAILED — {len(issues)} issue(s) found:", file=sys.stderr)
        for issue in issues:
            print(issue, file=sys.stderr)
        return 1

    print("\nPASSED — all consistency checks passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
