# Tech Maturity Skill

A Devin skill for quantifying, auditing, and visualizing a project's technical maturity using the Tech Maturity rubric from [techmaturity.github.io](https://github.com/techmaturity/techmaturity).

## What This Skill Does

This skill enables Claude to:
- Assess technical maturity across 6 dimensions (Code, Build & Test, Release, Operations, Security, Architecture)
- Evaluate engineering practices using a standardized 4-level maturity rubric
- Generate scored assessments with compliance checking
- Provide prioritized improvement recommendations
- Visualize maturity gaps and strengths

## Skill Structure

```
tech-maturity/
├── SKILL.md                      # Main skill documentation
├── scripts/
│   └── assess_maturity.py        # Interactive assessment script
├── references/
│   ├── capabilities.yaml         # Complete maturity rubric (42 capabilities)
│   └── rubric-guide.md          # Guide for interpreting and using the rubric
├── evals/
│   └── evals.json               # Test cases for skill validation
└── .gitignore                   # Git ignore patterns
```

## Usage

### As a Skill
When invoked, the skill guides users through:
1. Understanding the 6 assessment dimensions
2. Evaluating capabilities using the rubric
3. Running the assessment script for automated scoring
4. Interpreting results and recommendations

### As a Script
The assessment script can be run directly:

```bash
python scripts/assess_maturity.py /path/to/project --interactive
```

This launches an interactive assessment that:
- Prompts for each of the 42 capabilities
- Provides maturity level descriptions for each
- Calculates dimension and overall scores
- Checks compliance with minimum level requirements
- Generates a JSON report with recommendations

## The Rubric

Based on the Tech Maturity project, the rubric evaluates:

### Code (12 capabilities)
- Code commenting strategy, code management, test suite, logging/telemetry
- Backward/forward compatibility, monitoring/alerting, quality engineering
- Code reuse, availability testing, incremental coding, feedback gathering, BDD

### Build and Test (8 capabilities)  
- Definition of done, code quality, security analysis, automated testing
- Continuous integration, performance testing, configuration management, service consumer tests

### Release (4 capabilities)
- Deployment strategy, release automation, documentation, release communication

### Operations (6 capabilities)
- Incident management, monitoring, disaster recovery, capacity planning, change management

### Security (6 capabilities)
- Security policies, vulnerability management, security testing, incident response, compliance

### Architecture (6 capabilities)
- System design, scalability, modularity, data management, integration patterns

## Scoring System

Each capability is scored 1-4:
- **Level 1**: Initial/ad-hoc processes
- **Level 2**: Defined and documented processes  
- **Level 3**: Established and standardized processes
- **Level 4**: Optimized and continuously improving

Some capabilities have minimum required levels for compliance.

## Output

The assessment generates:
- **Overall maturity score** (0-4 scale)
- **Dimension scores** for each of the 6 areas
- **Compliance status** with minimum level requirements
- **Prioritized recommendations** for improvement
- **JSON report** with detailed results

## Use Cases

- **Technical due diligence** for acquisitions or investments
- **Engineering health checks** and quarterly assessments
- **Process improvement** planning and roadmap prioritization
- **Team onboarding** to establish practice baselines
- **Tooling justification** for DevOps investments
- **Compliance audits** and security assessments

## References

- **Tech Maturity Project**: https://github.com/techmaturity/techmaturity
- **Original Rubric**: https://github.com/techmaturity/techmaturity/blob/main/app/assets/constants/capabilities.yaml

## Created

- Date: 2026-06-05
- Based on: Tech Maturity rubric v1.0
- Capabilities: 42 total across 6 dimensions
- Skill template: ai-upsert