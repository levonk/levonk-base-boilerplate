#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Generate an HTML review viewer for skill evaluation results.

Usage:
    python generate_review.py <workspace/iteration-N>

Example:
    python generate_review.py ./pdf-rotator-workspace/iteration-1
"""

import argparse
import json
from datetime import datetime
from pathlib import Path


def load_eval_results(workspace_path: Path) -> dict:
    """Load all evaluation results from the workspace."""
    results = {}

    if not workspace_path.exists():
        raise ValueError(f"Workspace path does not exist: {workspace_path}")

    # Find all eval directories
    eval_dirs = [d for d in workspace_path.iterdir() if d.is_dir() and d.name.startswith("eval-")]

    for eval_dir in sorted(eval_dirs, key=lambda x: int(x.name.split("-")[1])):
        eval_id = int(eval_dir.name.split("-")[1])

        # Load metadata
        metadata_file = eval_dir / "eval_metadata.json"
        if metadata_file.exists():
            with open(metadata_file, "r") as f:
                metadata = json.load(f)
        else:
            metadata = {
                "eval_id": eval_id,
                "eval_name": f"Eval {eval_id}",
                "prompt": "Unknown",
                "assertions": []
            }

        # Load timing data
        with_skill_timing = {}
        without_skill_timing = {}

        with_skill_timing_file = eval_dir / "with_skill" / "timing.json"
        if with_skill_timing_file.exists():
            with open(with_skill_timing_file, "r") as f:
                with_skill_timing = json.load(f)

        without_skill_timing_file = eval_dir / "without_skill" / "timing.json"
        if without_skill_timing_file.exists():
            with open(without_skill_timing_file, "r") as f:
                without_skill_timing = json.load(f)

        results[eval_id] = {
            "metadata": metadata,
            "with_skill": {
                "timing": with_skill_timing,
                "outputs_dir": eval_dir / "with_skill" / "outputs"
            },
            "without_skill": {
                "timing": without_skill_timing,
                "outputs_dir": eval_dir / "without_skill" / "outputs"
            }
        }

    return results


def generate_html(results: dict, workspace_path: Path) -> str:
    """Generate HTML review viewer."""

    # Calculate summary statistics
    total_evals = len(results)
    total_tokens_with_skill = sum(
        r["with_skill"]["timing"].get("total_tokens", 0)
        for r in results.values()
    )
    total_tokens_without_skill = sum(
        r["without_skill"]["timing"].get("total_tokens", 0)
        for r in results.values()
    )
    total_duration_with_skill = sum(
        r["with_skill"]["timing"].get("total_duration_seconds", 0)
        for r in results.values()
    )
    total_duration_without_skill = sum(
        r["without_skill"]["timing"].get("total_duration_seconds", 0)
        for r in results.values()
    )

    # Calculate token savings
    token_savings = total_tokens_without_skill - total_tokens_with_skill
    token_savings_percent = (
        (token_savings / total_tokens_without_skill * 100)
        if total_tokens_without_skill > 0
        else 0
    )

    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Skill Evaluation Review</title>
    <style>
        body {{{ "{{" }}}
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            margin: 0;
            padding: 20px;
            background: #f5f5f5;
        {{{ "}}" }}}
        .container {{{ "{{" }}}
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        {{{ "}}" }}}
        h1 {{{ "{{" }}}
            color: #333;
            margin-bottom: 10px;
        {{{ "}}" }}}
        .summary {{{ "{{" }}}
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 30px 0;
            padding: 20px;
            background: #f9f9f9;
            border-radius: 6px;
        {{{ "}}" }}}
        .summary-card {{{ "{{" }}}
            text-align: center;
        {{{ "}}" }}}
        .summary-value {{{ "{{" }}}
            font-size: 2em;
            font-weight: bold;
            color: #2563eb;
        {{{ "}}" }}}
        .summary-label {{{ "{{" }}}
            color: #666;
            font-size: 0.9em;
            margin-top: 5px;
        {{{ "}}" }}}
        .positive {{{ "{{" }}}
            color: #16a34a;
        {{{ "}}" }}}
        .negative {{{ "{{" }}}
            color: #dc2626;
        {{{ "}}" }}}
        .eval-section {{{ "{{" }}}
            margin: 30px 0;
            border-top: 2px solid #e5e5e5;
            padding-top: 20px;
        {{{ "}}" }}}
        .eval-header {{{ "{{" }}}
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        {{{ "}}" }}}
        .eval-title {{{ "{{" }}}
            font-size: 1.3em;
            font-weight: bold;
            color: #333;
        {{{ "}}" }}}
        .prompt {{{ "{{" }}}
            background: #fffbeb;
            border-left: 4px solid #f59e0b;
            padding: 15px;
            margin: 15px 0;
            border-radius: 4px;
        {{{ "}}" }}}
        .comparison {{{ "{{" }}}
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin: 20px 0;
        {{{ "}}" }}}
        .comparison-card {{{ "{{" }}}
            padding: 20px;
            border-radius: 6px;
            border: 1px solid #e5e5e5;
        {{{ "}}" }}}
        .comparison-card.with-skill {{{ "{{" }}}
            background: #f0fdf4;
            border-color: #16a34a;
        {{{ "}}" }}}
        .comparison-card.without-skill {{{ "{{" }}}
            background: #fef2f2;
            border-color: #dc2626;
        {{{ "}}" }}}
        .card-title {{{ "{{" }}}
            font-weight: bold;
            margin-bottom: 15px;
            font-size: 1.1em;
        {{{ "}}" }}}
        .metric {{{ "{{" }}}
            display: flex;
            justify-content: space-between;
            margin: 8px 0;
            padding: 5px 0;
            border-bottom: 1px solid rgba(0,0,0,0.05);
        {{{ "}}" }}}
        .metric-label {{{ "{{" }}}
            color: #666;
        {{{ "}}" }}}
        .metric-value {{{ "{{" }}}
            font-weight: bold;
        {{{ "}}" }}}
        .assertions {{{ "{{" }}}
            margin-top: 15px;
            padding: 15px;
            background: #f8fafc;
            border-radius: 6px;
        {{{ "}}" }}}
        .assertion {{{ "{{" }}}
            margin: 8px 0;
            padding: 8px;
            background: white;
            border-radius: 4px;
            border-left: 3px solid #64748b;
        {{{ "}}" }}}
        .timestamp {{{ "{{" }}}
            color: #999;
            font-size: 0.9em;
            margin-top: 30px;
            text-align: center;
        {{{ "}}" }}}
    </style>
</head>
<body>
    <div class="container">
        <h1>Skill Evaluation Review</h1>
        <p style="color: #666;">{workspace_path.name}</p>

        <div class="summary">
            <div class="summary-card">
                <div class="summary-value">{total_evals}</div>
                <div class="summary-label">Total Evaluations</div>
            </div>
            <div class="summary-card">
                <div class="summary-value {token_savings_class if token_savings >= 0 else 'negative'}">
                    {token_savings:+,}
                </div>
                <div class="summary-label">Token Savings</div>
            </div>
            <div class="summary-card">
                <div class="summary-value {token_savings_class if token_savings >= 0 else 'negative'}">
                    {token_savings_percent:+.1f}%
                </div>
                <div class="summary-label">Savings Percentage</div>
            </div>
            <div class="summary-card">
                <div class="summary-value">
                    {total_duration_with_skill:.1f}s
                </div>
                <div class="summary-label">Total Duration (with skill)</div>
            </div>
        </div>
"""

    # Add individual eval sections
    for eval_id, result in sorted(results.items()):
        metadata = result["metadata"]
        with_skill = result["with_skill"]
        without_skill = result["without_skill"]

        html += f"""
        <div class="eval-section">
            <div class="eval-header">
                <div class="eval-title">{metadata.get('eval_name', f'Eval {eval_id}')}</div>
            </div>

            <div class="prompt">
                <strong>Prompt:</strong> {metadata.get('prompt', 'Unknown')}
            </div>

            <div class="comparison">
                <div class="comparison-card with-skill">
                    <div class="card-title">With Skill</div>
                    <div class="metric">
                        <span class="metric-label">Tokens:</span>
                        <span class="metric-value">{with_skill['timing'].get('total_tokens', 0):,}</span>
                    </div>
                    <div class="metric">
                        <span class="metric-label">Duration:</span>
                        <span class="metric-value">{with_skill['timing'].get('total_duration_seconds', 0):.2f}s</span>
                    </div>
                </div>

                <div class="comparison-card without-skill">
                    <div class="card-title">Without Skill</div>
                    <div class="metric">
                        <span class="metric-label">Tokens:</span>
                        <span class="metric-value">{without_skill['timing'].get('total_tokens', 0):,}</span>
                    </div>
                    <div class="metric">
                        <span class="metric-label">Duration:</span>
                        <span class="metric-value">{without_skill['timing'].get('total_duration_seconds', 0):.2f}s</span>
                    </div>
                </div>
            </div>

            {generate_assertions_html(metadata.get('assertions', []))}
        </div>
"""

    html += f"""
        <div class="timestamp">
            Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
        </div>
    </div>
</body>
</html>
"""

    return html


def generate_assertions_html(assertions: list) -> str:
    """Generate HTML for assertions section."""
    if not assertions:
        return ""

    html = '<div class="assertions"><strong>Assertions:</strong>'
    for assertion in assertions:
        html += f"""
        <div class="assertion">
            <strong>{assertion.get('name', 'Unnamed')}:</strong> {assertion.get('description', 'No description')}
        </div>
"""
    html += '</div>'
    return html


def main():
    parser = argparse.ArgumentParser(description="Generate HTML review viewer for skill evaluation results")
    parser.add_argument("workspace", help="Path to the workspace iteration directory (e.g., ./skill-workspace/iteration-1)")

    args = parser.parse_args()

    workspace_path = Path(args.workspace).resolve()

    try:
        results = load_eval_results(workspace_path)
    except ValueError as e:
        print(f"Error: {e}")
        sys.exit(1)

    if not results:
        print("No evaluation results found in workspace")
        sys.exit(1)

    html = generate_html(results, workspace_path)

    output_file = workspace_path / "review.html"
    with open(output_file, "w") as f:
        f.write(html)

    print(f"✓ Review generated: {output_file}")
    print(f"  Evaluations: {len(results)}")
    print(f"  Open in browser: file://{output_file.absolute()}")


if __name__ == "__main__":
    main()
