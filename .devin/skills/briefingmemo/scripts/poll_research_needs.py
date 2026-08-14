#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Poll Research Needs Script for BriefingMemo Skill
Polls committee members for information needs before deliberation
"""

import json
import yaml
from pathlib import Path
from typing import List, Dict
from datetime import datetime

def load_committee_config():
    """Load committee configuration"""
    config_path = Path(__file__).parent.parent / "config" / "committee.yaml"
    with open(config_path, 'r') as f:
        return yaml.safe_load(f)

def generate_research_poll(brief_path: str, output_path: str):
    """Generate research needs poll for committee members"""
    
    # Load brief content
    with open(brief_path, 'r') as f:
        brief_content = f.read()
    
    # Extract key questions from brief
    questions_start = brief_content.find("## Key Questions")
    questions_end = brief_content.find("##", questions_start + 1)
    if questions_end == -1:
        questions_end = len(brief_content)
    
    questions_section = brief_content[questions_start:questions_end]
    
    # Load committee config
    config = load_committee_config()
    committee_members = config['committee']['members']
    
    # Generate poll for each member
    poll_results = {
        "brief_path": brief_path,
        "poll_timestamp": datetime.now().isoformat(),
        "research_requests": []
    }
    
    for member in committee_members:
        member_request = {
            "member": member['name'],
            "persona": member['persona'],
            "research_needs": []
        }
        
        # Generate research needs based on persona
        if "Financial" in member['name']:
            member_request["research_needs"] = [
                "Current financial metrics and projections",
                "Market comparables and valuation multiples",
                "ROI analysis for different scenarios"
            ]
        elif "Legal" in member['name']:
            member_request["research_needs"] = [
                "Regulatory requirements and constraints",
                "Contractual obligations and liabilities",
                "Compliance checklist for proposed actions"
            ]
        elif "Customer" in member['name']:
            member_request["research_needs"] = [
                "Customer feedback and satisfaction data",
                "User behavior analytics",
                "Support ticket trends and pain points"
            ]
        elif "Market" in member['name']:
            member_request["research_needs"] = [
                "Competitive landscape analysis",
                "Market size and growth projections",
                "Industry trends and benchmarks"
            ]
        elif "Statistician" in member['name']:
            member_request["research_needs"] = [
                "Statistical significance of observed trends",
                "Confidence intervals for key metrics",
                "Data quality assessment and gaps"
            ]
        elif "Operations" in member['name']:
            member_request["research_needs"] = [
                "Current capacity and resource utilization",
                "Implementation timeline and dependencies",
                "Operational risk assessment"
            ]
        elif "Technical" in member['name']:
            member_request["research_needs"] = [
                "Technical architecture assessment",
                "Scalability and performance implications",
                "Technical debt and migration costs"
            ]
        elif "Risk" in member['name']:
            member_request["research_needs"] = [
                "Risk matrix for all identified scenarios",
                "Historical failure rates and mitigation success",
                "External risk factors and early warning indicators"
            ]
        else:
            # Generic research needs for other members
            member_request["research_needs"] = [
                "Historical precedents for similar decisions",
                "Best practices and industry standards",
                "Stakeholder impact assessment"
            ]
        
        poll_results["research_requests"].append(member_request)
    
    # Add research agent assignments
    poll_results["research_agents"] = [
        {
            "agent": "Data Scientist",
            "assigned_requests": [
                "Statistical analysis requests",
                "Quantitative modeling needs",
                "Data visualization requirements"
            ]
        },
        {
            "agent": "Market Analyst", 
            "assigned_requests": [
                "Market research requests",
                "Competitive intelligence needs",
                "Industry benchmark requirements"
            ]
        },
        {
            "agent": "Industry Analyst",
            "assigned_requests": [
                "Industry-specific analysis",
                "Regulatory landscape research",
                "Supply chain and ecosystem analysis"
            ]
        }
    ]
    
    # Save poll results
    with open(output_path, 'w') as f:
        json.dump(poll_results, f, indent=2)
    
    print(f"✓ Research poll generated at: {output_path}")
    print(f"✓ Polled {len(committee_members)} committee members")
    
    return poll_results

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description='Poll committee for research needs')
    parser.add_argument('--brief', required=True, help='Path to brief file')
    parser.add_argument('--output', required=True, help='Output path for poll results')
    
    args = parser.parse_args()
    
    brief_path = Path(args.brief)
    output_path = Path(args.output)
    
    if not brief_path.exists():
        print(f"Error: Brief file not found: {brief_path}")
        return 1
    
    output_path.parent.mkdir(parents=True, exist_ok=True)
    
    generate_research_poll(str(brief_path), str(output_path))
    return 0

if __name__ == "__main__":
    exit(main())
