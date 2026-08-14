#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Anonymize a set of responses for blind peer review.

Reads a JSON object on stdin (or from a file path arg) of the form:

    {
      "question": "The shared question all responses answer",
      "responses": [
        {"author": "The Contrarian", "text": "..."},
        {"author": "First Principles", "text": "..."}
      ]
    }

Emits two files:
  - peer-review-anonymized-<timestamp>.md — the shuffled A-N bundle for
    reviewers (no author names).
  - peer-review-mapping-<timestamp>.json — the A-N -> author mapping, to be
    revealed to the synthesizer only.

Quiet by default: prints only the two output paths. Use --verbose for full
diagnostic output. Use --dry-run to preview without writing files.

Includes devbox and rtk detection patterns per skill script standards.
"""

import argparse
import json
import os
import random
import shutil
import string
import subprocess
import sys
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional, Tuple


# ---------------------------------------------------------------------------
# Devbox detection — use `devbox run --` to execute commands when devbox
# is available and a devbox.json exists, unless already inside a devbox shell.
# ---------------------------------------------------------------------------
def is_devbox_available() -> bool:
    """Check if devbox is available and not already in a devbox shell."""
    if os.environ.get("DEVBOX_SHELL") or os.environ.get("IN_DEVBOX_SHELL"):
        return False
    if not shutil.which("devbox"):
        return False
    return os.path.isfile("devbox.json")


def devbox_run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    """Run a command through devbox if available, otherwise directly."""
    if is_devbox_available():
        return subprocess.run(["devbox", "run", "--", *cmd], **kwargs)
    return subprocess.run(cmd, **kwargs)


# ---------------------------------------------------------------------------
# RTK (Rust Token Killer) detection — use rtk as a proxy for git and other
# supported commands when available to reduce LLM token consumption by 60-90%.
# See: https://github.com/rtk-ai/rtk
# ---------------------------------------------------------------------------
def is_rtk_available() -> bool:
    """Check if rtk is available on the system."""
    return shutil.which("rtk") is not None


def rtk_wrap(tool: str, *args: str, **kwargs) -> subprocess.CompletedProcess:
    """Run a command through rtk if available, otherwise directly."""
    if is_rtk_available():
        return devbox_run(["rtk", tool, *args], **kwargs)
    return devbox_run([tool, *args], **kwargs)


# ---------------------------------------------------------------------------
# Anonymization logic
# ---------------------------------------------------------------------------
def labels(n: int) -> list[str]:
    """Generate N unique labels: A, B, ..., Z, AA, AB, ..."""
    out: list[str] = []
    i = 0
    while len(out) < n:
        s = ""
        x = i
        while True:
            s = string.ascii_uppercase[x % 26] + s
            x = x // 26 - 1
            if x < 0:
                break
        out.append(s)
        i += 1
    return out


def anonymize(payload: dict, seed: Optional[int] = None) -> Tuple[str, dict]:
    """Shuffle responses into a randomized A-N mapping.

    Returns (anonymized_markdown, mapping_dict).
    """
    rng = random.Random(seed)
    responses = payload.get("responses", [])
    n = len(responses)
    if n == 0:
        raise ValueError("No responses to anonymize")

    indices = list(range(n))
    rng.shuffle(indices)
    labs = labels(n)

    lines: list[str] = []
    lines.append(f"# Anonymized Peer-Review Bundle\n")
    lines.append(f"## Question\n\n{payload.get('question', '(unspecified)')}\n")
    lines.append("## Responses (anonymized, shuffled)\n")
    for label, idx in zip(labs, indices):
        lines.append(f"**Response {label}:**\n")
        lines.append(f"{responses[idx]['text'].strip()}\n")

    mapping = {
        "question": payload.get("question", ""),
        "label_to_author": {
            lab: responses[idx]["author"] for lab, idx in zip(labs, indices)
        },
        "label_to_index": {lab: idx for lab, idx in zip(labs, indices)},
        "seed": seed,
    }
    return "\n".join(lines), mapping


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Anonymize responses for blind peer review."
    )
    parser.add_argument(
        "input",
        nargs="?",
        default="-",
        help="Path to input JSON (default: stdin)",
    )
    parser.add_argument(
        "--out-dir",
        default=".",
        help="Directory to write outputs (default: cwd)",
    )
    parser.add_argument(
        "--seed",
        type=int,
        default=None,
        help="Random seed for reproducible shuffling",
    )
    parser.add_argument("--verbose", action="store_true", help="Full diagnostic output")
    parser.add_argument("--dry-run", action="store_true", help="Preview without writing")
    args = parser.parse_args()

    raw = sys.stdin.read() if args.input == "-" else Path(args.input).read_text()
    if args.verbose:
        print(f"[read] {len(raw)} bytes from {'stdin' if args.input == '-' else args.input}", file=sys.stderr)

    payload = json.loads(raw)
    if args.verbose:
        print(f"[parse] {len(payload.get('responses', []))} responses", file=sys.stderr)

    md, mapping = anonymize(payload, seed=args.seed)

    ts = datetime.now().strftime("%Y%m%d-%H%M%S")
    out_dir = Path(args.out_dir)
    md_path = out_dir / f"peer-review-anonymized-{ts}.md"
    map_path = out_dir / f"peer-review-mapping-{ts}.json"

    if args.dry_run:
        print(f"[dry-run] would write {md_path} ({len(md)} bytes)")
        print(f"[dry-run] would write {map_path} ({len(json.dumps(mapping))} bytes)")
        if args.verbose:
            print("---markdown---")
            print(md)
            print("---mapping---")
            print(json.dumps(mapping, indent=2))
        return 0

    out_dir.mkdir(parents=True, exist_ok=True)
    md_path.write_text(md)
    map_path.write_text(json.dumps(mapping, indent=2))
    print(str(md_path))
    print(str(map_path))
    return 0


if __name__ == "__main__":
    sys.exit(main())
