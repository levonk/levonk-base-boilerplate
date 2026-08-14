#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# ///
"""
Tech Maturity Assessment Script

Analyzes a project's technical maturity using the Tech Maturity rubric.
Generates scores, visualizations, and improvement recommendations.

Usage:
    python assess_maturity.py /path/to/project --interactive
    python assess_maturity.py /path/to/project --automated assessments.json
"""

import argparse
import json
import os
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Any, Optional
import yaml


def load_rubric(rubric_path: str) -> Dict[str, Any]:
    """Load the capabilities rubric from YAML file."""
    try:
        with open(rubric_path, 'r') as f:
            return yaml.safe_load(f)
    except Exception as e:
        print(f"Error loading rubric: {e}")
        sys.exit(1)


def parse_capabilities(rubric: Dict[str, Any]) -> Dict[str, Dict[str, Any]]:
    """Parse the flat YAML structure into organized capabilities."""
    capabilities = {}
    categories = {}

    # First pass: identify categories and collect all items
    for key, value in rubric.items():
        if key in ['a', 'b', 'c', 'd', 'e', 'f']:
            # These are category identifiers
            categories[key] = value
        elif '_' not in key or key.endswith('_min'):
            # Skip non-capability keys
            continue
        else:
            # Parse capability keys (e.g., "a1", "a1_1", "a1_2", etc.)
            if '_' in key:
                parts = key.split('_')
                base_key = '_'.join(parts[:-1])
                level = parts[-1]

                if base_key not in capabilities:
                    capabilities[base_key] = {
                        'name': '',
                        'levels': {},
                        'min_level': None
                    }

                if level.isdigit():
                    capabilities[base_key]['levels'][int(level)] = value

    # Second pass: extract names and minimum levels
    for key, value in rubric.items():
        if key.endswith('_min'):
            base_key = key.replace('_min', '')
            if base_key in capabilities:
                capabilities[base_key]['min_level'] = value
        elif '_' not in key and key not in ['a', 'b', 'c', 'd', 'e', 'f']:
            # This is likely a capability name (e.g., "a1", "b1", etc.)
            if key in capabilities:
                capabilities[key]['name'] = value

    # Map capabilities to categories
    category_mapping = {
        'a': 'Code',
        'b': 'Build and Test',
        'c': 'Release',
        'd': 'Operations',
        'e': 'Security',
        'f': 'Architecture'
    }

    for cap_key, cap_data in capabilities.items():
        category_letter = cap_key[0]
        cap_data['category'] = category_mapping.get(category_letter, 'Unknown')

    return capabilities


def calculate_scores(assessments: Dict[str, int], capabilities: Dict[str, Dict]) -> Dict[str, Any]:
    """Calculate dimension scores and overall maturity."""
    dimension_scores = {}
    dimension_counts = {}

    for cap_key, score in assessments.items():
        if cap_key in capabilities:
            category = capabilities[cap_key]['category']
            if category not in dimension_scores:
                dimension_scores[category] = 0
                dimension_counts[category] = 0
            dimension_scores[category] += score
            dimension_counts[category] += 1

    # Calculate averages
    for category in dimension_scores:
        if dimension_counts[category] > 0:
            dimension_scores[category] = dimension_scores[category] / dimension_counts[category]

    # Calculate overall score
    overall_score = sum(dimension_scores.values()) / len(dimension_scores) if dimension_scores else 0

    # Check minimum level compliance
    compliance_issues = []
    for cap_key, cap_data in capabilities.items():
        if cap_data['min_level'] is not None and cap_key in assessments:
            if assessments[cap_key] < cap_data['min_level']:
                compliance_issues.append({
                    'capability': cap_key,
                    'name': cap_data['name'],
                    'required_level': cap_data['min_level'],
                    'current_level': assessments[cap_key]
                })

    return {
        'dimension_scores': dimension_scores,
        'overall_score': overall_score,
        'compliance_issues': compliance_issues,
        'total_capabilities': len(capabilities),
        'assessed_capabilities': len(assessments)
    }


def generate_recommendations(scores: Dict[str, Any], capabilities: Dict[str, Dict]) -> List[Dict[str, Any]]:
    """Generate improvement recommendations based on scores."""
    recommendations = []

    # Address compliance issues first
    for issue in scores['compliance_issues']:
        recommendations.append({
            'priority': 'CRITICAL',
            'category': 'Compliance',
            'capability': issue['name'],
            'action': f"Raise maturity level from {issue['current_level']} to {issue['required_level']}",
            'reason': 'Minimum level requirement not met'
        })

    # Address low-scoring dimensions
    for dimension, score in scores['dimension_scores'].items():
        if score < 2.0:
            recommendations.append({
                'priority': 'HIGH',
                'category': dimension,
                'capability': 'Overall Dimension',
                'action': f"Improve {dimension} practices from level {score:.1f} to level 2+",
                'reason': 'Dimension score below minimum acceptable level'
            })
        elif score < 3.0:
            recommendations.append({
                'priority': 'MEDIUM',
                'category': dimension,
                'capability': 'Overall Dimension',
                'action': f"Standardize {dimension} practices to reach level 3+",
                'reason': 'Dimension shows room for improvement'
            })

    return recommendations


def generate_report(project_path: str, assessments: Dict[str, int],
                    capabilities: Dict[str, Dict], scores: Dict[str, Any]) -> Dict[str, Any]:
    """Generate the complete assessment report."""
    recommendations = generate_recommendations(scores, capabilities)

    return {
        'project_path': project_path,
        'assessment_date': datetime.now().isoformat(),
        'overall_score': scores['overall_score'],
        'dimension_scores': scores['dimension_scores'],
        'capability_assessments': assessments,
        'compliance_status': {
            'compliant': len(scores['compliance_issues']) == 0,
            'issues': scores['compliance_issues']
        },
        'recommendations': recommendations,
        'summary': {
            'total_capabilities': scores['total_capabilities'],
            'assessed_capabilities': scores['assessed_capabilities'],
            'completion_percentage': (scores['assessed_capabilities'] / scores['total_capabilities'] * 100) if scores['total_capabilities'] > 0 else 0
        }
    }


def save_report(report: Dict[str, Any], output_path: str) -> None:
    """Save the assessment report to a JSON file."""
    try:
        with open(output_path, 'w') as f:
            json.dump(report, f, indent=2)
        print(f"✓ Report saved to: {output_path}")
    except Exception as e:
        print(f"Error saving report: {e}")
        sys.exit(1)


def print_summary(report: Dict[str, Any]) -> None:
    """Print a summary of the assessment results."""
    print("\n" + "="*60)
    print("TECH MATURITY ASSESSMENT SUMMARY")
    print("="*60)
    print(f"Project: {report['project_path']}")
    print(f"Date: {report['assessment_date']}")
    print(f"\nOverall Maturity Score: {report['overall_score']:.2f}/4.0")

    print("\nDimension Scores:")
    for dimension, score in report['dimension_scores'].items():
        print(f"  {dimension}: {score:.2f}/4.0")

    print(f"\nCompliance Status: {'✓ COMPLIANT' if report['compliance_status']['compliant'] else '✗ NON-COMPLIANT'}")
    if not report['compliance_status']['compliant']:
        print("\nCompliance Issues:")
        for issue in report['compliance_status']['issues']:
            print(f"  - {issue['name']}: Level {issue['current_level']} (required: {issue['required_level']})")

    print(f"\nAssessment Coverage: {report['summary']['assessed_capabilities']}/{report['summary']['total_capabilities']} capabilities ({report['summary']['completion_percentage']:.1f}%)")

    if report['recommendations']:
        print(f"\nTop Recommendations:")
        for i, rec in enumerate(report['recommendations'][:5], 1):
            print(f"  {i}. [{rec['priority']}] {rec['action']}")

    print("="*60 + "\n")


def interactive_assessment(capabilities: Dict[str, Dict]) -> Dict[str, int]:
    """Guide user through interactive assessment process."""
    assessments = {}

    print("\n" + "="*60)
    print("INTERACTIVE TECH MATURITY ASSESSMENT")
    print("="*60)
    print("\nYou will be asked to assess each capability on a scale of 1-4:")
    print("  1 - Initial/ad-hoc processes")
    print("  2 - Defined and documented processes")
    print("  3 - Established and standardized processes")
    print("  4 - Optimized and continuously improving")
    print("\nEnter 's' to skip a capability, 'q' to quit early.\n")

    # Group capabilities by category
    categories = {}
    for cap_key, cap_data in capabilities.items():
        category = cap_data['category']
        if category not in categories:
            categories[category] = []
        categories[category].append((cap_key, cap_data))

    for category, caps in categories.items():
        print(f"\n{category.upper()}")
        print("-" * 60)

        for cap_key, cap_data in caps:
            print(f"\n{cap_data['name']}")
            if cap_data['min_level']:
                print(f"  (Minimum required level: {cap_data['min_level']})")

            print("\nMaturity levels:")
            for level, description in cap_data['levels'].items():
                print(f"  {level}. {description}")

            while True:
                response = input(f"\nScore [1-4, s=skip, q=quit]: ").strip().lower()

                if response == 'q':
                    print("\nAssessment quit early.")
                    return assessments
                elif response == 's':
                    print("  -> Skipped")
                    break
                elif response in ['1', '2', '3', '4']:
                    score = int(response)
                    assessments[cap_key] = score
                    print(f"  -> Scored: {score}")

                    # Warn if below minimum
                    if cap_data['min_level'] and score < cap_data['min_level']:
                        print(f"  ⚠ WARNING: Below minimum required level {cap_data['min_level']}")

                    break
                else:
                    print("  Invalid input. Enter 1-4, s, or q.")

    return assessments


def load_assessments_from_file(assessment_file: str) -> Dict[str, int]:
    """Load pre-computed assessments from a JSON file."""
    try:
        with open(assessment_file, 'r') as f:
            data = json.load(f)
            return data.get('assessments', {})
    except Exception as e:
        print(f"Error loading assessments: {e}")
        sys.exit(1)


def generate_analysis_guide(project_path: str, capabilities: Dict[str, Dict]) -> Dict[str, Any]:
    """Generate an analysis guide to help AI assess project maturity automatically."""

    analysis_guide = {
        'project_path': project_path,
        'analysis_instructions': {
            'general': 'Examine the codebase, documentation, and configuration files to assess each capability. Score based on evidence of actual practices, not intentions.',
            'evidence_sources': [
                'Source code organization and quality',
                'Configuration files (.github/, .gitlab-ci.yml, Dockerfile, etc.)',
                'Documentation (README, docs/, etc.)',
                'Test files and coverage reports',
                'CI/CD pipeline definitions',
                'Deployment configurations',
                'Monitoring and logging setup'
            ]
        },
        'capabilities': {}
    }

    # Add analysis guidance for each capability
    for cap_key, cap_data in capabilities.items():
        analysis_guide['capabilities'][cap_key] = {
            'name': cap_data['name'],
            'category': cap_data['category'],
            'min_level': cap_data['min_level'],
            'levels': cap_data['levels'],
            'analysis_hints': get_analysis_hints(cap_key)
        }

    return analysis_guide


def get_analysis_hints(capability_key: str) -> List[str]:
    """Provide specific analysis hints for each capability."""
    hints = {
        'a1': ['Look for docstrings, code comments, documentation generation tools'],
        'a2': ['Check git history for branching patterns', 'Look for PR/MR workflows'],
        'a3': ['Examine test directories', 'Check for test coverage reports', 'Look for test types (unit, integration, e2e)'],
        'a4': ['Check for logging frameworks', 'Look for monitoring/telemetry integrations'],
        'a5': ['Examine API versioning', 'Check for backward compatibility tests'],
        'a6': ['Look for monitoring dashboards', 'Check for alert configurations'],
        'a7': ['Examine team structure', 'Check if developers write tests'],
        'a8': ['Look for library usage vs custom implementations', 'Check for internal package reuse'],
        'a9': ['Check for chaos engineering tools', 'Look for failure testing'],
        'a10': ['Look for prototype directories', 'Check for spike solutions'],
        'a11': ['Examine requirements documentation', 'Check for design docs before implementation'],
        'a12': ['Look for Gherkin/features files', 'Check for BDD frameworks'],
        'b1': ['Check for Definition of Done documentation', 'Review acceptance criteria'],
        'b2': ['Look for coverage reports', 'Check code quality tools (SonarQube, etc.)'],
        'b3': ['Check for security scanning tools (Snyk, OWASP, etc.)', 'Look for security CI steps'],
        'b4': ['Examine test automation', 'Check for end-to-end testing frameworks'],
        'b5': ['Look for CI/CD pipelines (GitHub Actions, GitLab CI, Jenkins)', 'Check for automated builds'],
        'b6': ['Check for load testing tools', 'Look for performance monitoring'],
        'b7': ['Examine config management', 'Check for secrets management'],
        'b8': ['Look for consumer-driven contract testing', 'Check for API contract tests'],
        'c1': ['Examine deployment processes', 'Check for rollback procedures'],
        'c2': ['Look for release automation', 'Check for versioning strategies'],
        'c3': ['Examine documentation quality', 'Check for API docs'],
        'c4': ['Look for changelog generation', 'Check for release notes'],
    }
    return hints.get(capability_key, ['Examine relevant code and documentation'])


def save_analysis_guide(guide: Dict[str, Any], output_path: str) -> None:
    """Save the analysis guide to a JSON file."""
    try:
        with open(output_path, 'w') as f:
            json.dump(guide, f, indent=2)
        print(f"✓ Analysis guide saved to: {output_path}")
    except Exception as e:
        print(f"Error saving analysis guide: {e}")


def main():
    parser = argparse.ArgumentParser(description="Assess technical maturity using the Tech Maturity rubric")
    parser.add_argument("project_path", help="Path to the project to assess")
    parser.add_argument("--output", "-o", default="maturity-report.json", help="Output file for the report")
    parser.add_argument("--rubric", "-r",
                       default=str(Path(__file__).parent.parent / "references" / "capabilities.yaml"),
                       help="Path to the capabilities rubric YAML file")
    parser.add_argument("--interactive", "-i", action="store_true",
                       help="Run interactive assessment (prompts for each capability)")
    parser.add_argument("--automated", "-a", metavar="ASSESSMENTS_FILE",
                       help="Run automated assessment using pre-computed assessments from JSON file")
    parser.add_argument("--generate-guide", "-g", action="store_true",
                       help="Generate an analysis guide for AI-driven automated assessment")

    args = parser.parse_args()

    # Validate project path
    if not os.path.exists(args.project_path):
        print(f"Error: Project path does not exist: {args.project_path}")
        sys.exit(1)

    # Load rubric
    print(f"Loading rubric from: {args.rubric}")
    rubric = load_rubric(args.rubric)
    capabilities = parse_capabilities(rubric)
    print(f"Loaded {len(capabilities)} capabilities from rubric")

    # Generate analysis guide if requested
    if args.generate_guide:
        guide = generate_analysis_guide(args.project_path, capabilities)
        guide_path = args.output.replace('.json', '-analysis-guide.json')
        save_analysis_guide(guide, guide_path)
        print(f"\nAnalysis guide generated. Use this guide to conduct AI-driven assessment.")
        print(f"1. Examine the project using the analysis hints provided")
        print(f"2. Score each capability 1-4 based on evidence found")
        print(f'3. Create a JSON file with assessments: {{{ "{{" }}}assessments{{{ "}}" }}}: {{{ "{{" }}}a1{{{ "}}" }}}: 3, {{{ "{{" }}}a2{{{ "}}" }}}: 2, ...}}}')
        print(f"4. Run: python assess_maturity.py {args.project_path} --automated assessments.json")
        return

    # Get assessments
    if args.interactive:
        assessments = interactive_assessment(capabilities)
    elif args.automated:
        assessments = load_assessments_from_file(args.automated)
        print(f"Loaded {len(assessments)} pre-computed assessments from: {args.automated}")
    else:
        print("\nPlease specify either --interactive for manual assessment or --automated with an assessment file.")
        print("Use --generate-guide to create an analysis guide for AI-driven assessment.")
        sys.exit(1)

    if not assessments:
        print("\nNo capabilities were assessed. Exiting.")
        sys.exit(1)

    # Calculate scores
    scores = calculate_scores(assessments, capabilities)

    # Generate report
    report = generate_report(args.project_path, assessments, capabilities, scores)

    # Save and print summary
    save_report(report, args.output)
    print_summary(report)

    print(f"\nFull report saved to: {args.output}")


if __name__ == "__main__":
    main()
