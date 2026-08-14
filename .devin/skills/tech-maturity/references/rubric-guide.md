# Tech Maturity Rubric Guide

This guide explains how to interpret and use the Tech Maturity capabilities rubric for technical assessments.

## Rubric Structure

The rubric (`capabilities.yaml`) uses a hierarchical structure:

### Categories (a-f)

- **a**: Code - Development practices and code quality
- **b**: Build and Test - CI/CD, testing, and build processes  
- **c**: Release - Deployment and release management
- **d**: Operations - Monitoring, incident management, and operational practices
- **e**: Security - Security policies and practices
- **f**: Architecture - System design and architectural patterns

### Capability Levels

Each capability is defined with four maturity levels:

- **Level 1**: Initial/ad-hoc - Processes are disorganized or undocumented
- **Level 2**: Defined - Processes are documented and followed inconsistently
- **Level 3**: Established - Processes are standardized and consistently applied
- **Level 4**: Optimized - Processes are continuously improved and automated

### Minimum Levels

Some capabilities have minimum required levels (e.g., `a3_min: 3` means Test Suite must be at least Level 3). These represent critical practices that should be in place for a mature engineering organization.

## Assessment Guidelines

### Scoring Principles

1. **Be objective**: Score based on evidence, not intentions
2. **Look for patterns**: One-off examples don't establish a practice
3. **Consider team-wide adoption**: Practices should be consistent across the team
4. **Account for context**: Small teams may legitimately score lower than large enterprises

### Red Flags

Watch for these warning signs during assessments:

- Level 1 in security capabilities
- No minimum level compliance
- Large gaps between dimensions
- Missing critical practices (testing, CI/CD, monitoring)

### Common Score Patterns

#### Healthy Progression
- Code and Build & Test lead (Levels 3-4)
- Release and Operations follow (Levels 2-3)
- Security and Architecture mature with scale (Levels 2-4)

#### Warning Patterns
- High Code scores but low Operations scores (deployment risk)
- High Build/Test but low Security (vulnerability risk)
- Inconsistent scores within dimensions (process breakdown)

## Capability Examples

### Code (a)

**a1 - Code Commenting Strategy**
- Level 1: No consistent commenting standards
- Level 2: New code has good comments
- Level 3: Most code is self-documenting
- Level 4: All code consistently documented and suitable for doc generation

**a2 - Code Management Strategy** (Minimum: Level 1)
- Level 1: Code in git but no branching strategy
- Level 2: Version branches with traceability
- Level 3: Short-lived feature branches (< 2 weeks)
- Level 4: Trunk-based development with daily check-ins

**a3 - Test Suite** (Minimum: Level 3)
- Level 1: Few or no tests
- Level 2: Some tests, mostly passing
- Level 3: Comprehensive tests for positive flows
- Level 4: Comprehensive tests for positive and negative flows, 100% critical path coverage

### Build and Test (b)

**b5 - Continuous Integration** (Minimum: Level 3)
- Level 1: No automated build pipeline
- Level 2: Manual steps in pipeline, may miss failures
- Level 3: Automated tests must pass for completion
- Level 4: Automated tests pass, failures monitored and handled

**b3 - Security Code Analysis** (Minimum: Level 2)
- Level 1: Never scanned with security scanner
- Level 2: Previously scanned (one-time)
- Level 3: Regularly scanned
- Level 4: Automatically scanned, defects prioritized into workload

### Release (c)

**c1 - Deployment Strategy**
- Level 1: No consistent deployment strategy
- Level 2: Defined strategy followed
- Level 3: Automated rollbacks, regression tests, configs, tracking
- Level 4: Fully automated with regression tests, configs, tracking

## Using the Assessment Script

The `assess_maturity.py` script provides:

1. **Interactive assessment**: Guides you through each capability
2. **Score calculation**: Computes dimension and overall scores
3. **Compliance checking**: Validates minimum level requirements
4. **Recommendations**: Suggests prioritized improvements
5. **Report generation**: Creates JSON and summary reports

### Running an Assessment

```bash
# Interactive assessment
python scripts/assess_maturity.py /path/to/project --interactive

# With custom output file
python scripts/assess_maturity.py /path/to/project --interactive --output my-report.json

# With custom rubric location
python scripts/assess_maturity.py /path/to/project --interactive --rubric /path/to/capabilities.yaml
```

### Interpreting Results

**Overall Score**: 0-4 scale
- 0-1.5: Immature - Significant improvement needed
- 1.5-2.5: Developing - Basic practices in place
- 2.5-3.5: Mature - Good practices, room for optimization
- 3.5-4.0: Advanced - Industry-leading practices

**Dimension Scores**: Identify strong and weak areas
- Look for dimensions below 2.0 (critical gaps)
- Check for large variances between dimensions (imbalances)

**Compliance Issues**: Must fix first
- Minimum level requirements represent critical practices
- Address these before other improvements

**Recommendations**: Prioritized improvement plan
- CRITICAL: Compliance issues and gaps below Level 2
- HIGH: Dimensions below Level 2
- MEDIUM: Dimensions between Level 2-3

## Integration with Development Processes

### Regular Assessments

- **Quarterly**: Track progress over time
- **Post-incident**: Identify process gaps
- **Pre-acquisition**: Technical due diligence
- **Team changes**: Establish baseline for new teams

### Using Results

1. **Planning**: Inform roadmap and investment decisions
2. **Hiring**: Set expectations for engineering practices
3. **Training**: Identify skill gaps and training needs
4. **Tooling**: Justify investments in DevOps tooling
5. **Management**: Communicate engineering health to stakeholders

## References

- **Tech Maturity Project**: https://github.com/techmaturity/techmaturity
- **Original Rubric**: Based on industry best practices and DevOps maturity models
- **Assessment Script**: `scripts/assess_maturity.py`
- **Capabilities Reference**: `capabilities.yaml`