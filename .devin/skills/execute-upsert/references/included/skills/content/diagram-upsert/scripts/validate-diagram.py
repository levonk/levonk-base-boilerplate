#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
Validate a diagram by rendering it and reporting parse errors.

Supports:
  - Mermaid (fenced code block or .mmd file) — rendered via
    `pnpm dlx @mermaid-js/mermaid-cli` (never npx, per project AGENTS.md).
  - PlantUML (@startuml..@enduml or .puml file) — rendered via
    `java -jar plantuml.jar` if a local jar is on PATH.
  - Excalidraw (.excalidraw JSON) — validated as JSON with structural checks.

Usage:
    # Validate a standalone diagram file (type inferred from extension/content)
    uv run --script validate-diagram.py path/to/diagram.mmd
    uv run --script validate-diagram.py path/to/diagram.puml
    uv run --script validate-diagram.py path/to/diagram.excalidraw

    # Validate a fenced block inside a markdown file by line range (1-based, inclusive)
    uv run --script validate-diagram.py --file path/to/adr.md --lang mermaid --start 60 --end 178

    # Validate from stdin
    echo 'flowchart TD
        A --> B' | uv run --script validate-diagram.py --lang mermaid

Exit codes:
    0  — diagram rendered successfully (or validation skipped with --skip-missing-tool)
    1  — parse error (rendering failed)
    2  — usage error
    3  — required rendering tool unavailable and --strict set

Output:
    Quiet by default on success. On failure, prints the error with line
    numbers and the offending token. Use --verbose for rendering tool output.
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


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
# Tool resolution — prefer pnpm dlx over npx (project rule). For PlantUML,
# look for a local jar on PATH or in common locations.
# ---------------------------------------------------------------------------
def find_pnpm() -> str | None:
    return shutil.which("pnpm")


def find_plantuml_jar() -> Path | None:
    """Find a local plantuml.jar on PATH or in common locations."""
    env_path = os.environ.get("PLANTUML_JAR")
    if env_path and Path(env_path).is_file():
        return Path(env_path)
    for candidate in (
        "plantuml.jar",
        "/usr/local/share/plantuml/plantuml.jar",
        "/opt/homebrew/share/plantuml/plantuml.jar",
        str(Path.home() / ".local/share/plantuml/plantuml.jar"),
    ):
        p = Path(candidate)
        if p.is_file():
            return p
    # Check if `plantuml` is on PATH (some distros wrap the jar)
    if shutil.which("plantuml"):
        return Path("__plantuml-on-path__")
    return None


def find_java() -> str | None:
    return shutil.which("java")


# ---------------------------------------------------------------------------
# Diagram type detection
# ---------------------------------------------------------------------------
def detect_lang_from_content(text: str) -> str:
    stripped = text.lstrip()
    if stripped.startswith("@startuml") or stripped.startswith("@startmindmap") or stripped.startswith("@startsalt"):
        return "plantuml"
    if stripped.startswith("{") and '"type"' in text and "excalidraw" in text.lower():
        return "excalidraw"
    # Mermaid is the default for flowchart/sequenceDiagram/stateDiagram/etc.
    if re.match(r"^(flowchart|graph|sequenceDiagram|stateDiagram|classDiagram|erDiagram|gantt|pie|journey|mindmap|timeline|gitGraph|C4Context|C4Container|C4Component)", stripped, re.MULTILINE):
        return "mermaid"
    # Fallback: assume mermaid for any non-empty text that isn't clearly plantuml/excalidraw
    return "mermaid"


def detect_lang_from_path(path: Path) -> str:
    suffix = path.suffix.lower()
    if suffix in (".mmd", ".mermaid"):
        return "mermaid"
    if suffix in (".puml", ".plantuml"):
        return "plantuml"
    if suffix == ".excalidraw":
        return "excalidraw"
    # Fall back to content inspection
    return detect_lang_from_content(path.read_text())


def extract_fenced_block(text: str, start: int, end: int) -> str:
    """Extract lines [start, end] (1-based, inclusive) from text."""
    lines = text.splitlines()
    # 1-based to 0-based
    return "\n".join(lines[start - 1 : end])


# ---------------------------------------------------------------------------
# Renderers
# ---------------------------------------------------------------------------
def render_mermaid(source: str, verbose: bool) -> tuple[bool, str]:
    """Render Mermaid via @mermaid-js/mermaid-cli. Returns (ok, message)."""
    pnpm = find_pnpm()
    if not pnpm:
        return False, "pnpm not found on PATH — cannot render Mermaid. Install pnpm or run via devbox."
    with tempfile.TemporaryDirectory() as tmp:
        src = Path(tmp) / "diagram.mmd"
        out = Path(tmp) / "diagram.svg"
        src.write_text(source)
        cmd = ["pnpm", "dlx", "@mermaid-js/mermaid-cli", "-i", str(src), "-o", str(out), "--quiet"]
        try:
            result = devbox_run(cmd, capture_output=True, text=True, timeout=120)
        except subprocess.TimeoutExpired:
            return False, "mermaid-cli timed out after 120s"
        if result.returncode == 0 and out.is_file():
            return True, f"OK: rendered {out.stat().st_size} bytes SVG"
        stderr = result.stderr.strip() or result.stdout.strip()
        if verbose:
            stderr = f"--- stdout ---\n{result.stdout}\n--- stderr ---\n{result.stderr}\n{stderr}"
        return False, f"mermaid-cli parse error:\n{stderr}"


def render_plantuml(source: str, verbose: bool) -> tuple[bool, str]:
    """Render PlantUML via local jar. Returns (ok, message)."""
    jar = find_plantuml_jar()
    if not jar:
        return False, "plantuml.jar not found — set PLANTUML_JAR or install plantuml. Validation skipped (server-only validation is not authoritative)."
    java = find_java()
    if not java:
        return False, "java not found on PATH — cannot run plantuml.jar."
    with tempfile.TemporaryDirectory() as tmp:
        src = Path(tmp) / "diagram.puml"
        src.write_text(source)
        if str(jar) == "__plantuml-on-path__":
            cmd = ["plantuml", "-checkonly", "-failfast", str(src)]
        else:
            cmd = [java, "-jar", str(jar), "-checkonly", "-failfast", str(src)]
        try:
            result = devbox_run(cmd, capture_output=True, text=True, timeout=120)
        except subprocess.TimeoutExpired:
            return False, "plantuml timed out after 120s"
        if result.returncode == 0:
            return True, "OK: PlantUML syntax valid"
        stderr = result.stderr.strip() or result.stdout.strip()
        if verbose:
            stderr = f"--- stdout ---\n{result.stdout}\n--- stderr ---\n{result.stderr}\n{stderr}"
        return False, f"PlantUML parse error:\n{stderr}"


def validate_excalidraw(source: str, verbose: bool) -> tuple[bool, str]:
    """Validate Excalidraw JSON structure."""
    try:
        data = json.loads(source)
    except json.JSONDecodeError as e:
        return False, f"Excalidraw JSON parse error at line {e.lineno} col {e.colno}: {e.msg}"
    if not isinstance(data, dict):
        return False, "Excalidraw root must be a JSON object"
    if "type" not in data or data.get("type") != "excalidraw":
        return False, "Excalidraw root must have \"type\": \"excalidraw\""
    if "elements" not in data:
        return False, "Excalidraw object missing \"elements\" array"
    if not isinstance(data["elements"], list):
        return False, "Excalidraw \"elements\" must be a list"
    if "appState" not in data:
        return False, "Excalidraw object missing \"appState\""
    return True, f"OK: {len(data['elements'])} elements"


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main() -> int:
    parser = argparse.ArgumentParser(description="Validate a diagram by rendering it.")
    parser.add_argument("path", nargs="?", help="Path to diagram file (type inferred from extension/content)")
    parser.add_argument("--file", help="Path to a markdown file containing a fenced block")
    parser.add_argument("--lang", choices=["mermaid", "plantuml", "excalidraw"], help="Diagram language (required for stdin, optional for files)")
    parser.add_argument("--start", type=int, help="Start line (1-based, inclusive) for fenced block extraction")
    parser.add_argument("--end", type=int, help="End line (1-based, inclusive) for fenced block extraction")
    parser.add_argument("--verbose", action="store_true", help="Show full renderer output")
    parser.add_argument("--strict", action="store_true", help="Exit non-zero if the rendering tool is unavailable")
    args = parser.parse_args()

    # Resolve source text and language
    if args.file:
        if not args.start or not args.end:
            print("ERROR: --file requires --start and --end", file=sys.stderr)
            return 2
        text = Path(args.file).read_text()
        source = extract_fenced_block(text, args.start, args.end)
        lang = args.lang or detect_lang_from_content(source)
    elif args.path:
        p = Path(args.path)
        if not p.is_file():
            print(f"ERROR: file not found: {p}", file=sys.stderr)
            return 2
        source = p.read_text()
        lang = args.lang or detect_lang_from_path(p)
    elif not sys.stdin.isatty():
        source = sys.stdin.read()
        lang = args.lang or detect_lang_from_content(source)
    else:
        parser.print_help(sys.stderr)
        return 2

    if not source.strip():
        print("ERROR: empty diagram source", file=sys.stderr)
        return 2

    print(f"Detected language: {lang}", file=sys.stderr)

    if lang == "mermaid":
        ok, msg = render_mermaid(source, args.verbose)
    elif lang == "plantuml":
        ok, msg = render_plantuml(source, args.verbose)
    elif lang == "excalidraw":
        ok, msg = validate_excalidraw(source, args.verbose)
    else:
        print(f"ERROR: unsupported language: {lang}", file=sys.stderr)
        return 2

    if ok:
        print(msg)
        return 0
    # Distinguish "tool unavailable" from "parse error"
    if "not found" in msg or "Validation skipped" in msg:
        print(f"WARNING: {msg}", file=sys.stderr)
        return 3 if args.strict else 0
    print(f"FAIL: {msg}", file=sys.stderr)
    return 1


if __name__ == "__main__":
    sys.exit(main())
