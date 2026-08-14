#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Start Deliberation Script for BriefingMemo Skill
Main entry point for the briefing-to-memo decision process
"""

import argparse
import json
import subprocess
import sys
from datetime import datetime
from pathlib import Path

def run_command(cmd, description):
    """Run a command and handle errors"""
    print(f"\n--- {description} ---")
    try:
        result = subprocess.run(cmd, shell=True, check=True, capture_output=True, text=True)
        print(f"✓ {description} completed")
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"✗ {description} failed: {e}")
        print(f"Error output: {e.stderr}")
        return None

def main():
    parser = argparse.ArgumentParser(description='Start strategic decision deliberation')
    parser.add_argument('--brief', required=True, help='Path to brief file')
    parser.add_argument('--time', type=int, default=5, help='Deliberation time limit in minutes (default: 5)')
    parser.add_argument('--budget', type=int, default=5, help='Budget limit in dollars (default: 5)')
    parser.add_argument('--skip-research', action='store_true', help='Skip research phase')
    parser.add_argument('--output-dir', help='Output directory for results')
    
    args = parser.parse_args()
    
    # Validate brief exists
    brief_path = Path(args.brief)
    if not brief_path.exists():
        print(f"Error: Brief file not found: {brief_path}")
        return 1
    
    # Set up output directory
    if args.output_dir:
        output_dir = Path(args.output_dir)
    else:
        output_dir = brief_path.parent / f"deliberation_{datetime.now().strftime('%Y%m%d_%H%M%S')}"
    
    output_dir.mkdir(parents=True, exist_ok=True)
    print(f"Output directory: {output_dir}")
    
    # Get script directory
    script_dir = Path(__file__).parent
    config_path = script_dir.parent / "config" / "committee.yaml"
    
    # Step 1: Validate brief
    print("\n=== Step 1: Validating Brief ===")
    validate_cmd = f"python3 {script_dir}/create_brief.py --validate {brief_path}"
    if not run_command(validate_cmd, "Brief validation"):
        return 1
    
    # Step 2: Research phase (unless skipped)
    research_package_path = None
    if not args.skip_research:
        print("\n=== Step 2: Research Phase ===")
        
        # Poll for research needs
        poll_path = output_dir / "research_poll.json"
        poll_cmd = f"python3 {script_dir}/poll_research_needs.py --brief {brief_path} --output {poll_path}"
        poll_result = run_command(poll_cmd, "Research polling")
        
        if poll_result:
            # Simulate research gathering (in real implementation, this would call research agents)
            research_package_path = output_dir / "research_package.json"
            research_data = {
                "package_timestamp": datetime.now().isoformat(),
                "brief_analyzed": str(brief_path),
                "research_findings": {
                    "market_analysis": "Market conditions favorable for decision",
                    "financial_projections": "ROI within acceptable range",
                    "risk_assessment": "Risks identified and manageable",
                    "operational_feasibility": "Implementation feasible with proper planning"
                },
                "data_sources": [
                    "Internal metrics database",
                    "Market research reports",
                    "Industry benchmarks",
                    "Financial models"
                ]
            }
            
            with open(research_package_path, 'w') as f:
                json.dump(research_data, f, indent=2)
            
            print(f"✓ Research package created: {research_package_path}")
    
    # Step 3: Orchestrate deliberation
    print("\n=== Step 3: Committee Deliberation ===")
    deliberation_path = output_dir / "deliberation.json"
    deliberation_cmd = f"python3 {script_dir}/orchestrate_deliberation.py --brief {brief_path} --config {config_path} --time {args.time} --budget {args.budget}"
    
    if research_package_path:
        deliberation_cmd += f" --research {research_package_path}"
    
    deliberation_cmd += f" > {deliberation_path}"
    
    if not run_command(deliberation_cmd, "Committee deliberation"):
        return 1
    
    # Step 4: Generate decision memo
    print("\n=== Step 4: Generating Decision Memo ===")
    memo_path = output_dir / "decision_memo.md"
    memo_cmd = f"python3 {script_dir}/generate_memo.py --deliberation {deliberation_path} --brief {brief_path} --output {memo_path} --config {config_path}"
    
    if not run_command(memo_cmd, "Memo generation"):
        return 1
    
    # Step 5: Summary
    print("\n=== Deliberation Complete ===")
    print(f"Decision memo: {memo_path}")
    print(f"Deliberation transcript: {output_dir}/deliberation_transcript.md")
    
    if (output_dir / "post_decision_reviews.md").exists():
        print(f"Post-decision reviews: {output_dir}/post_decision_reviews.md")
    
    print(f"\nAll outputs saved to: {output_dir}")
    
    # Display decision summary
    try:
        with open(memo_path, 'r') as f:
            memo_content = f.read()
        
        # Extract executive summary
        exec_start = memo_content.find("## Executive Summary")
        exec_end = memo_content.find("---", exec_start)
        
        if exec_start != -1 and exec_end != -1:
            exec_summary = memo_content[exec_start:exec_end]
            print("\n" + exec_summary)
    except:
        pass
    
    return 0

if __name__ == "__main__":
    exit(main())
