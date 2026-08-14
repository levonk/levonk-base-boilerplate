#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Generate a self-contained HTML council report from a markdown transcript.

Reads a council transcript markdown file and emits a single HTML file with
inline CSS, collapsible advisor sections, and the chairman's verdict
prominently displayed at the top.

Input markdown should contain sections:
  ## Chairman's Verdict
  ## Advisor Responses
  ### [Advisor Name]
  ## Peer Reviews

Quiet by default: prints only the output HTML path. Use --verbose for
diagnostics. Use --dry-run to preview without writing.

Includes devbox and rtk detection patterns per skill script standards.
"""

import argparse
import html
import os
import re
import shutil
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional


# ---------------------------------------------------------------------------
# Devbox detection
# ---------------------------------------------------------------------------
def is_devbox_available() -> bool:
    if os.environ.get("DEVBOX_SHELL") or os.environ.get("IN_DEVBOX_SHELL"):
        return False
    if not shutil.which("devbox"):
        return False
    return os.path.isfile("devbox.json")


def devbox_run(cmd: list, **kwargs) -> subprocess.CompletedProcess:
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


# ---------------------------------------------------------------------------
# Markdown parsing
# ---------------------------------------------------------------------------
def parse_transcript(md: str) -> Dict:
    """Extract sections from the transcript markdown."""
    sections = {"question": "", "verdict": "", "advisors": {}, "reviews": ""}
    lines = md.split("\n")

    def _save_section(sects, sect, advisor, buf):
        if sect == "advisor" and advisor:
            sects["advisors"][advisor] = "\n".join(buf).strip()
        elif sect == "reviews":
            sects["reviews"] = "\n".join(buf).strip()
        elif sect == "verdict":
            sects["verdict"] = "\n".join(buf).strip()
        elif sect == "question":
            sects["question"] = "\n".join(buf).strip()
    current_section = None
    current_advisor = None
    buffer: List[str] = []

    for line in lines:
        h2 = re.match(r"^## (.+)$", line)
        h3 = re.match(r"^### (.+)$", line)
        if h2:
            _save_section(sections, current_section, current_advisor, buffer)
            current_section = h2.group(1).strip().lower().replace("'", "")
            current_advisor = None
            buffer = []
            if "question" in current_section:
                current_section = "question"
            elif "verdict" in current_section or "chairman" in current_section:
                current_section = "verdict"
            elif "advisor" in current_section:
                current_section = "advisor"
            elif "review" in current_section:
                current_section = "reviews"
            else:
                current_section = "other"
        elif h3 and current_section == "advisor":
            if current_advisor:
                sections["advisors"][current_advisor] = "\n".join(buffer).strip()
            current_advisor = h3.group(1).strip()
            buffer = []
        else:
            buffer.append(line)
    _save_section(sections, current_section, current_advisor, buffer)
    return sections


def md_to_html(text: str) -> str:
    """Minimal markdown-to-HTML: paragraphs, bold, lists, headings."""
    if not text:
        return ""
    lines = text.strip().split("\n")
    out: List[str] = []
    in_list = False
    for line in lines:
        stripped = line.strip()
        if stripped.startswith("- "):
            if not in_list:
                out.append("<ul>")
                in_list = True
            out.append(f"<li>{html.escape(stripped[2:])}</li>")
        elif stripped.startswith("**") and stripped.endswith("**"):
            if in_list:
                out.append("</ul>")
                in_list = False
            out.append(f"<p><strong>{html.escape(stripped[2:-2])}</strong></p>")
        elif stripped:
            if in_list:
                out.append("</ul>")
                in_list = False
            # bold inline
            line_html = re.sub(
                r"\*\*(.+?)\*\*", r"<strong>\1</strong>", html.escape(stripped)
            )
            out.append(f"<p>{line_html}</p>")
    if in_list:
        out.append("</ul>")
    return "\n".join(out)


# ---------------------------------------------------------------------------
# HTML generation
# ---------------------------------------------------------------------------
CSS = """
body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
       max-width: 900px; margin: 40px auto; padding: 0 20px; color: #1a1a1a;
       background: #fff; line-height: 1.6; }
h1 { font-size: 1.6em; border-bottom: 2px solid #e0e0e0; padding-bottom: 10px; }
h2 { font-size: 1.3em; margin-top: 2em; color: #2a2a2a; }
h3 { font-size: 1.1em; margin-top: 1.5em; color: #444; }
.question { background: #f7f7f7; padding: 15px 20px; border-left: 4px solid #4a90d9;
            border-radius: 4px; margin: 20px 0; }
.verdict { background: #f0f7ff; padding: 20px; border: 1px solid #d0e0f0;
           border-radius: 6px; margin: 20px 0; }
.verdict h2 { margin-top: 0; }
.advisor { border: 1px solid #e0e0e0; border-radius: 4px; margin: 10px 0; }
.advisor summary { padding: 10px 15px; cursor: pointer; font-weight: 600;
                   color: #4a90d9; }
.advisor-content { padding: 0 15px 15px; }
.reviews { background: #fafafa; padding: 15px; border-radius: 4px; margin: 10px 0; }
.footer { margin-top: 3em; padding-top: 15px; border-top: 1px solid #e0e0e0;
          font-size: 0.85em; color: #888; }
ul { padding-left: 20px; }
"""


def build_html(sections: Dict, timestamp: str) -> str:
    parts: List[str] = []
    parts.append("<!DOCTYPE html>")
    parts.append('<html lang="en"><head><meta charset="utf-8">')
    parts.append(f"<title>Council Report — {timestamp}</title>")
    parts.append(f"<style>{CSS}</style></head><body>")
    parts.append("<h1>Council Report</h1>")

    if sections["question"]:
        parts.append('<div class="question">')
        parts.append("<h2>Question</h2>")
        parts.append(md_to_html(sections["question"]))
        parts.append("</div>")

    if sections["verdict"]:
        parts.append('<div class="verdict">')
        parts.append("<h2>Chairman's Verdict</h2>")
        parts.append(md_to_html(sections["verdict"]))
        parts.append("</div>")

    if sections["advisors"]:
        parts.append("<h2>Advisor Responses</h2>")
        for name, content in sections["advisors"].items():
            parts.append('<details class="advisor">')
            parts.append(f"<summary>{html.escape(name)}</summary>")
            parts.append('<div class="advisor-content">')
            parts.append(md_to_html(content))
            parts.append("</div></details>")

    if sections["reviews"]:
        parts.append("<h2>Peer Reviews</h2>")
        parts.append('<div class="reviews">')
        parts.append(md_to_html(sections["reviews"]))
        parts.append("</div>")

    parts.append('<div class="footer">')
    parts.append(f"<p>Generated {timestamp} from council transcript.</p>")
    parts.append("</div>")
    parts.append("</body></html>")
    return "\n".join(parts)


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Generate HTML council report from a markdown transcript."
    )
    parser.add_argument("transcript", help="Path to council transcript markdown")
    parser.add_argument(
        "--out-dir", default=".", help="Directory to write output (default: cwd)"
    )
    parser.add_argument("--verbose", action="store_true")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()

    md = Path(args.transcript).read_text()
    if args.verbose:
        print(f"[read] {len(md)} bytes from {args.transcript}", file=sys.stderr)

    sections = parse_transcript(md)
    if args.verbose:
        print(
            f"[parse] {len(sections['advisors'])} advisors, "
            f"verdict={'yes' if sections['verdict'] else 'no'}",
            file=sys.stderr,
        )

    ts = datetime.now().strftime("%Y%m%d-%H%M%S")
    html_content = build_html(sections, ts)
    out_path = Path(args.out_dir) / f"council-report-{ts}.html"

    if args.dry_run:
        print(f"[dry-run] would write {out_path} ({len(html_content)} bytes)")
        if args.verbose:
            print(html_content[:500] + "...")
        return 0

    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(html_content)
    print(str(out_path))
    return 0


if __name__ == "__main__":
    sys.exit(main())
