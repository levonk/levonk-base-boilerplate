#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Brief Creation Script for BriefingMemo Skill
Creates structured briefs with required sections for strategic decision-making
"""

import argparse
import os
import sys
from datetime import datetime
from pathlib import Path

def create_template(output_path):
    """Create a brief template file"""
    template = f"""# Strategic Decision Brief - [TITLE]

*Created: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}*
*Status: Draft*

## Situation/Debrief
[Clear description of the current situation, context, and background. Include relevant history and current state.]

## Stakes
### Financial Implications
[Quantify financial impact and risks]

### Strategic Importance
[Explain strategic value and long-term implications]

### Impact on Stakeholders
[Describe impact on employees, customers, investors, partners]

### Opportunity Costs
[What are we giving up by pursuing/not pursuing this?]

## Constraints
### Time Constraints
[Decision deadlines and time-sensitive factors]

### Budget Constraints
[Financial limitations and resource constraints]

### Legal Constraints
[Regulatory requirements, compliance obligations]

### Operational Constraints
[Resource limitations, capacity constraints]

### Market Constraints
[External factors, market conditions]

## Key Questions
1. [Primary question 1]
2. [Primary question 2]
3. [Primary question 3]
4. [Primary question 4]
5. [Primary question 5]

## Context Files
- [Link to business metrics]
- [Link to product overview]
- [Link to market analysis]
- [Link to technical specifications]
- [Link to financial statements]

## Additional Notes
[Any other relevant information]
"""
    
    with open(output_path, 'w') as f:
        f.write(template)
    
    print(f"✓ Brief template created at: {output_path}")
    return True

def validate_brief(brief_path):
    """Validate that brief contains all required sections"""
    required_sections = [
        "## Situation/Debrief",
        "## Stakes",
        "## Constraints", 
        "## Key Questions"
    ]
    
    with open(brief_path, 'r') as f:
        content = f.read()
    
    missing_sections = []
    for section in required_sections:
        if section not in content:
            missing_sections.append(section)
    
    if missing_sections:
        print(f"✗ Brief validation failed. Missing sections: {', '.join(missing_sections)}")
        return False
    
    # Check key questions count
    questions_start = content.find("## Key Questions")
    questions_end = content.find("##", questions_start + 1)
    if questions_end == -1:
        questions_end = len(content)
    
    questions_section = content[questions_start:questions_end]
    question_count = questions_section.count("1.") + questions_section.count("2.") + questions_section.count("3.") + questions_section.count("4.") + questions_section.count("5.")
    
    if question_count < 1:
        print("✗ Brief must have at least 1 key question")
        return False
    
    print("✓ Brief validation passed")
    return True

def main():
    parser = argparse.ArgumentParser(description='Create or validate strategic decision briefs')
    parser.add_argument('--template', action='store_true', help='Create a brief template')
    parser.add_argument('--output', '-o', help='Output path for template')
    parser.add_argument('--validate', help='Validate existing brief')
    parser.add_argument('--title', help='Brief title (for template)')
    
    args = parser.parse_args()
    
    if args.template:
        if not args.output:
            print("Error: --output required when creating template")
            sys.exit(1)
        
        output_path = Path(args.output)
        output_path.parent.mkdir(parents=True, exist_ok=True)
        
        if create_template(output_path):
            if args.title:
                # Replace placeholder title
                with open(output_path, 'r') as f:
                    content = f.read()
                content = content.replace("[TITLE]", args.title)
                with open(output_path, 'w') as f:
                    f.write(content)
                print(f"✓ Title set to: {args.title}")
    
    elif args.validate:
        brief_path = Path(args.validate)
        if not brief_path.exists():
            print(f"Error: Brief file not found: {brief_path}")
            sys.exit(1)
        
        validate_brief(brief_path)
    
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
