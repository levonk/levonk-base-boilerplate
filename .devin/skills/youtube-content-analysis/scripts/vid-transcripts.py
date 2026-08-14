#!/usr/bin/env python3
# /// script
# requires-python = ">=3.9"
# dependencies = []
# ///
"""Process video transcript VTT files: dedup, filter, and format conversion.

YouTube auto-captions use a 2-line progressive display where each VTT cue
overlaps ~80% with the previous one. This tool can deduplicate, filter by
time range, keep or drop flicker transitions, and output in multiple formats
(plain text, TOON, SRT, VTT, Obsidian markdown).

Defaults: TOON format, unix milliseconds, dedup on, flicker off, no timestamps
in text mode. Use flags to override any of these.

Usage:
    vid-transcripts.py [options] <input.vtt> [output]

Examples:
    # Defaults: TOON + dedup + unix-ms + no flicker
    vid-transcripts.py captions.vtt

    # Plain text with timestamps shown (HH:MM:SS)
    vid-transcripts.py --format text --timestamps --hhmmss captions.vtt

    # TOON format, only 5min-10min range
    vid-transcripts.py --from 00:05:00 --to 00:10:00 captions.vtt

    # Clean VTT output with flicker transitions kept
    vid-transcripts.py --format vtt --keep-flicker captions.vtt out.vtt

    # SRT subtitles
    vid-transcripts.py --format srt captions.vtt out.srt

    # Obsidian markdown note with embedded TOON transcript table
    vid-transcripts.py --format obsidian --video-id dQw4w9WgXcQ \\
        --title "Never Gonna Give You Up" --info-json video.info.json \\
        captions.vtt transcript.md
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path


# ---------------------------------------------------------------------------
# Parsing
# ---------------------------------------------------------------------------

def _to_sec(t: str) -> float:
    """Parse 'HH:MM:SS.mmm', 'MM:SS.mmm', or seconds string → float."""
    parts = t.split(":")
    if len(parts) == 3:
        h, m, s = parts
        return int(h) * 3600 + int(m) * 60 + float(s)
    if len(parts) == 2:
        m, s = parts
        return int(m) * 60 + float(s)
    return float(parts[0])


def _fmt_ts(sec: float, sep: str = ":") -> str:
    """Format seconds → HH:MM:SS."""
    h = int(sec // 3600)
    m = int((sec % 3600) // 60)
    s = int(sec % 60)
    return f"{h:02d}{sep}{m:02d}{sep}{s:02d}"


def _fmt_ms(sec: float) -> str:
    """Format seconds → integer milliseconds string (e.g. '1500')."""
    return str(int(round(sec * 1000)))


def _fmt_srt_time(sec: float) -> str:
    """Format seconds → SRT timestamp 'HH:MM:SS,mmm'."""
    h = int(sec // 3600)
    m = int((sec % 3600) // 60)
    s = int(sec % 60)
    ms = int((sec - int(sec)) * 1000)
    return f"{h:02d}:{m:02d}:{s:02d},{ms:03d}"


def _fmt_vtt_time(sec: float) -> str:
    """Format seconds → VTT timestamp 'HH:MM:SS.mmm'."""
    h = int(sec // 3600)
    m = int((sec % 3600) // 60)
    s = int(sec % 60)
    ms = int((sec - int(sec)) * 1000)
    return f"{h:02d}:{m:02d}:{s:02d}.{ms:03d}"


def _decode_entities(s: str) -> str:
    return (
        s.replace("&gt;", ">")
        .replace("&lt;", "<")
        .replace("&amp;", "&")
        .replace("&#39;", "'")
        .replace("&quot;", '"')
    )


def parse_vtt(vtt_path: str) -> list[dict]:
    """Parse a VTT file into a list of cue dicts with start, end, text."""
    content = Path(vtt_path).read_text(encoding="utf-8")
    cues: list[dict] = []
    lines = content.split("\n")
    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if "-->" in line:
            times = line.split("-->")
            start_sec = _to_sec(times[0].strip())
            end_str = times[1].strip().split(" ")[0]
            end_sec = _to_sec(end_str)

            speaker = ""
            text_lines: list[str] = []
            i += 1
            while i < len(lines) and lines[i].strip():
                if not speaker:
                    v_match = re.match(r"<v\s+([^>]+)>", lines[i])
                    if v_match:
                        speaker = v_match.group(1).strip()
                clean = re.sub(r"<[^>]+>", "", lines[i]).strip()
                if clean:
                    text_lines.append(clean)
                i += 1
            full_text = _decode_entities(" ".join(text_lines))
            cues.append({
                "start_sec": start_sec,
                "end_sec": end_sec,
                "text": full_text,
                "speaker": speaker,
            })
        else:
            i += 1
    return cues


# ---------------------------------------------------------------------------
# Chapter resolution
# ---------------------------------------------------------------------------

def parse_chapters_from_info_json(info_json_path: str) -> list[dict]:
    """Parse chapters from yt-dlp info-json file.

    Returns list of {title, start_sec, end_sec} sorted by start_sec.
    """
    try:
        data = json.loads(Path(info_json_path).read_text(encoding="utf-8"))
    except (json.JSONDecodeError, FileNotFoundError, OSError):
        return []
    chapters = data.get("chapters") or []
    result = []
    for ch in chapters:
        result.append({
            "title": ch.get("title", ""),
            "start_sec": float(ch.get("start_time", 0)),
            "end_sec": float(ch.get("end_time", 0)),
        })
    return sorted(result, key=lambda c: c["start_sec"])


def parse_chapters_from_description(description: str) -> list[dict]:
    """Parse chapter timestamps from a YouTube video description.

    Recognizes lines like '0:00 Intro', '5:30 Main Topic', '1:02:15 Chapter'.
    Requires at least 2 timestamped lines to be treated as chapters.
    """
    result = []
    pattern = re.compile(r"^(\d{1,2}:\d{2}(?::\d{2})?)\s+(.+)$")
    for line in description.split("\n"):
        line = line.strip()
        m = pattern.match(line)
        if m:
            ts, title = m.group(1), m.group(2).strip()
            result.append({
                "title": title,
                "start_sec": _to_sec(ts),
                "end_sec": 0,
            })
    if len(result) < 2:
        return []
    result.sort(key=lambda c: c["start_sec"])
    for i in range(len(result) - 1):
        result[i]["end_sec"] = result[i + 1]["start_sec"]
    result[-1]["end_sec"] = float("inf")
    return result


def _extract_description_from_info_json(info_json_path: str) -> str | None:
    """Extract the description field from a yt-dlp info-json file."""
    try:
        data = json.loads(Path(info_json_path).read_text(encoding="utf-8"))
        return data.get("description")
    except (json.JSONDecodeError, FileNotFoundError, OSError):
        return None


def resolve_chapters(info_json_path: str | None, description: str | None) -> list[dict]:
    """Resolve chapters: try info-json chapters array first, fall back to description."""
    if info_json_path:
        chapters = parse_chapters_from_info_json(info_json_path)
        if chapters:
            return chapters
        if not description:
            description = _extract_description_from_info_json(info_json_path)
    if description:
        return parse_chapters_from_description(description)
    return []


def _find_chapter_for_time(chapters: list[dict], sec: float) -> str:
    """Find the chapter name containing the given time, or empty string."""
    for ch in chapters:
        if ch["start_sec"] <= sec < ch["end_sec"]:
            return ch["title"]
    return ""


# ---------------------------------------------------------------------------
# Transforms
# ---------------------------------------------------------------------------

def filter_time(
    cues: list[dict], from_sec: float | None, to_sec: float | None
) -> list[dict]:
    """Keep only cues within [from_sec, to_sec] by start time."""
    result = cues
    if from_sec is not None:
        result = [c for c in result if c["start_sec"] >= from_sec]
    if to_sec is not None:
        result = [c for c in result if c["start_sec"] <= to_sec]
    return result


def filter_flicker(cues: list[dict], keep_flicker: bool) -> list[dict]:
    """Drop ultra-short transition cues (< 0.1s) unless keep_flicker."""
    if keep_flicker:
        return [c for c in cues if c["text"].strip()]
    duration = lambda c: c["end_sec"] - c["start_sec"]
    return [c for c in cues if duration(c) >= 0.1 and c["text"].strip()]


def dedup(cues: list[dict]) -> list[dict]:
    """Extract only the genuinely new text from each progressive cue.

    YouTube auto-captions overlap consecutive cues ~80%. This strips the
    overlapping prefix (or suffix-overlap) and keeps only new text, preserving
    the original start/end times.
    """
    result: list[dict] = []
    prev_full_text = ""
    for c in cues:
        text = c["text"].strip()
        if not text:
            continue
        if prev_full_text and text.startswith(prev_full_text):
            new_part = text[len(prev_full_text):].strip()
        else:
            overlap = 0
            min_len = min(len(prev_full_text), len(text))
            for j in range(min_len, 0, -1):
                if prev_full_text.endswith(text[:j]):
                    overlap = j
                    break
            new_part = text[overlap:].strip() if overlap > 10 else text
        if new_part:
            result.append({
                "start_sec": c["start_sec"],
                "end_sec": c["end_sec"],
                "text": new_part,
                "speaker": c.get("speaker", ""),
            })
        prev_full_text = text
    return result


# ---------------------------------------------------------------------------
# Output formatters
# ---------------------------------------------------------------------------

def _toon_quote(s: str, delimiter: str) -> str:
    """Quote a string for TOON if it contains the delimiter or special chars."""
    needs_quote = (
        not s
        or s in ("true", "false", "null")
        or s.startswith("-")
        or delimiter in s
        or ":" in s
        or '"' in s
        or "\\" in s
        or s != s.strip()
    )
    if not needs_quote:
        return s
    escaped = s.replace("\\", "\\\\").replace('"', '\\"')
    return f'"{escaped}"'


def format_text(segments: list[dict], timestamps: bool, unix_time: bool = True) -> str:
    lines = []
    for s in segments:
        if timestamps:
            ts = _fmt_ms(s["start_sec"]) if unix_time else _fmt_ts(s["start_sec"])
            lines.append(f"[{ts}] {s['text']}")
        else:
            lines.append(s["text"])
    return "\n".join(lines) + "\n"


def format_toon(segments: list[dict], timestamps: bool = False, unix_time: bool = True) -> str:
    """Encode segments as a TOON tabular array with pipe delimiter."""
    n = len(segments)
    if n == 0:
        return "segments: []\n"
    if timestamps:
        header = f"segments[{n}|]{{start|end|text}}:"
        rows = []
        for s in segments:
            if unix_time:
                start = _fmt_ms(s["start_sec"])
                end = _fmt_ms(s["end_sec"])
            else:
                start = _fmt_ts(s["start_sec"])
                end = _fmt_ts(s["end_sec"])
            text = _toon_quote(s["text"], "|")
            rows.append(f"  {start}|{end}|{text}")
    else:
        header = f"segments[{n}|]{{text}}:"
        rows = []
        for s in segments:
            text = _toon_quote(s["text"], "|")
            rows.append(f"  {text}")
    return header + "\n" + "\n".join(rows) + "\n"


def format_srt(segments: list[dict], timestamps: bool = False) -> str:
    blocks = []
    for idx, s in enumerate(segments, 1):
        if timestamps:
            start = _fmt_srt_time(s["start_sec"])
            end = _fmt_srt_time(s["end_sec"])
            blocks.append(f"{idx}\n{start} --> {end}\n{s['text']}")
        else:
            blocks.append(f"{idx}\n{s['text']}")
    return "\n\n".join(blocks) + "\n"


def format_vtt(segments: list[dict], timestamps: bool = False) -> str:
    blocks = []
    for s in segments:
        if timestamps:
            start = _fmt_vtt_time(s["start_sec"])
            end = _fmt_vtt_time(s["end_sec"])
            blocks.append(f"{start} --> {end}\n{s['text']}")
        else:
            blocks.append(s["text"])
    return "WEBVTT\n\n" + "\n\n".join(blocks) + "\n"


def format_obsidian(
    segments: list[dict],
    video_id: str,
    title: str,
    chapters: list[dict],
    lang: str,
) -> str:
    """Format as an Obsidian markdown note with an embedded 9-column TOON transcript table.

    Columns: idx|start|end|duration|text|link|chapter|speaker|lang
    Times are HH:MM:SS (human-readable for Obsidian). Links are youtu.be deep-links
    with ?t=<seconds> for clickable navigation into the video.
    """
    from datetime import date

    today = date.today().isoformat()
    base_url = f"https://youtu.be/{video_id}"
    watch_url = f"https://www.youtube.com/watch?v={video_id}"

    lines = [
        "---",
        f'title: "{title}"',
        f'source: "{watch_url}"',
        f'video_id: "{video_id}"',
        f'lang: "{lang}"',
        f'fetch_date: "{today}"',
        "---",
        "",
        f"# {title} — Transcript",
        "",
        f"Source: [{watch_url}]({watch_url})",
        "",
    ]

    if chapters:
        lines.append("## Chapters")
        lines.append("")
        for ch in chapters:
            ts = _fmt_ts(ch["start_sec"])
            t_param = int(ch["start_sec"])
            lines.append(f"- [{ts}]({base_url}?t={t_param}) {ch['title']}")
        lines.append("")

    lines.append("## Transcript")
    lines.append("")
    lines.append("```toon")
    n = len(segments)
    col_header = "{idx|start|end|duration|text|link|chapter|speaker|lang}"
    lines.append(f"segments[{n}|]{col_header}:")
    for idx, s in enumerate(segments, 1):
        start = _fmt_ts(s["start_sec"])
        end = _fmt_ts(s["end_sec"])
        duration = round(s["end_sec"] - s["start_sec"], 2)
        text = _toon_quote(s["text"], "|")
        link = f"{base_url}?t={int(s['start_sec'])}"
        chapter = _toon_quote(_find_chapter_for_time(chapters, s["start_sec"]), "|")
        speaker = _toon_quote(s.get("speaker", ""), "|")
        lines.append(f"  {idx}|{start}|{end}|{duration}|{text}|{link}|{chapter}|{speaker}|{lang}")
    lines.append("```")
    lines.append("")

    return "\n".join(lines)


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def build_parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(
        prog="vid-transcripts.py",
        description="Process video transcript VTT files: dedup, filter, and format conversion.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="Defaults: TOON format, unix milliseconds, dedup on, flicker off, no timestamps in text mode.\n"
               "Output formats: toon (default), text, srt, vtt, obsidian\n"
               "If no output file is given, writes to stdout.",
    )
    p.add_argument("input", help="Input VTT file path")
    p.add_argument("output", nargs="?", default=None, help="Output file (default: stdout)")
    p.add_argument(
        "--format", choices=["toon", "text", "srt", "vtt", "obsidian"], default="toon",
        help="Output format (default: toon). 'obsidian' emits a markdown note with embedded TOON transcript table.",
    )
    p.add_argument("--no-dedup", action="store_true", help="Disable deduplication")
    p.add_argument("--timestamps", action="store_true", help="Show timestamps in all formats (off by default)")
    p.add_argument("--keep-flicker", action="store_true", help="Keep ultra-short transition cues (< 0.1s)")
    p.add_argument("--from", dest="from_time", default=None, help="Start time (HH:MM:SS or seconds)")
    p.add_argument("--to", dest="to_time", default=None, help="End time (HH:MM:SS or seconds)")
    p.add_argument(
        "--hhmmss", action="store_true",
        help="Use HH:MM:SS timestamps instead of unix milliseconds (all formats)",
    )
    p.add_argument("--video-id", default=None, help="YouTube video ID (required for obsidian format)")
    p.add_argument("--video-url", default=None, help="YouTube video URL (alternative to --video-id)")
    p.add_argument("--title", default="Untitled", help="Video title (for obsidian format header)")
    p.add_argument("--info-json", default=None, help="Path to yt-dlp info-json file (for chapters and metadata)")
    p.add_argument("--description", default=None, help="Video description text (fallback for chapter parsing)")
    p.add_argument("--lang", default="en", help="Language code for the transcript (default: en)")
    return p


def main() -> int:
    args = build_parser().parse_args()

    from_sec = _to_sec(args.from_time) if args.from_time else None
    to_sec = _to_sec(args.to_time) if args.to_time else None

    cues = parse_vtt(args.input)
    cues = filter_time(cues, from_sec, to_sec)
    cues = filter_flicker(cues, args.keep_flicker)
    if not args.no_dedup:
        segments = dedup(cues)
    else:
        segments = [c for c in cues if c["text"].strip()]

    if args.format == "text":
        out = format_text(segments, args.timestamps, not args.hhmmss)
    elif args.format == "toon":
        out = format_toon(segments, args.timestamps, not args.hhmmss)
    elif args.format == "srt":
        out = format_srt(segments, args.timestamps)
    elif args.format == "vtt":
        out = format_vtt(segments, args.timestamps)
    elif args.format == "obsidian":
        video_id = args.video_id
        if not video_id and args.video_url:
            m = re.search(r"(?:v=|youtu\.be/)([\w-]{11})", args.video_url)
            video_id = m.group(1) if m else ""
        if not video_id:
            print("Error: --video-id or --video-url required for obsidian format", file=sys.stderr)
            return 1
        chapters = resolve_chapters(args.info_json, args.description)
        out = format_obsidian(segments, video_id, args.title, chapters, args.lang)
    else:
        print(f"Unknown format: {args.format}", file=sys.stderr)
        return 1

    if args.output:
        Path(args.output).write_text(out, encoding="utf-8")
    else:
        sys.stdout.write(out)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
