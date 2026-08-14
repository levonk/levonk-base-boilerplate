# Assessment Process Reference

Detailed step-by-step process for conducting technical maturity assessments, including both AI-driven automated and manual interactive workflows.

## AI-Driven Automated Assessment

The skill supports fully automated AI-driven assessment where Claude can analyze a codebase and automatically determine maturity levels without human intervention.

### Automated Assessment Workflow

When a user requests a technical maturity assessment, Claude follows this workflow:

1. **Generate Analysis Guide**: Use the `--generate-guide` flag to create a comprehensive analysis guide with specific hints for each capability

2. **Examine Project Artifacts**: Claude examines:
   - Source code organization and quality
   - Configuration files (.github/, CI/CD configs, Dockerfile, etc.)
   - Documentation (README, docs/, API docs)
   - Test files and coverage reports
   - CI/CD pipeline definitions
   - Deployment configurations
   - Monitoring and logging setup

3. **Evaluate Capabilities Systematically**: For each of the 42 capabilities:
   - Review the capability definition and maturity levels
   - Examine relevant project artifacts using analysis hints
   - Assign a score (1-4) based on evidence of actual practices
   - Document the rationale for each score

4. **Generate Assessment JSON**: Create the assessments file with all scores

5. **Run Assessment Script**: Process scores through the assessment script to generate:
   - Dimension and overall maturity scores
   - Compliance status with minimum requirements
   - Prioritized improvement recommendations
   - Detailed JSON report

6. **Present Findings**: Share the maturity report with scores, compliance status, and recommendations

### Example AI-Driven Assessment

When a user asks "Assess the technical maturity of my project," Claude can:

1. Generate the analysis guide
2. Systematically examine the codebase
3. Score each capability based on evidence found
4. Generate the maturity report
5. Present findings with recommendations

### Automated Assessment Best Practices

- **Evidence-based scoring**: Base scores on actual artifacts, not intentions
- **Look for patterns**: One-off examples don't establish a practice
- **Consider context**: Account for project size, team size, and constraints
- **Document rationale**: Explain why each score was assigned
- **Flag uncertainties**: Note when evidence is insufficient for confident scoring

## Manual Assessment Steps

### Step 1: Gather Project Context

Examine the project to understand:
- Source code organization and quality
- Testing practices and coverage
- CI/CD pipeline configuration
- Documentation quality
- Deployment processes
- Monitoring and observability setup
- Security practices
- Architecture patterns

### Step 2: Evaluate Capabilities

For each capability in the rubric, assess the current practice level by:

1. Reading the capability description in `references/capabilities.yaml`
2. Examining relevant project artifacts (code, configs, docs)
3. Comparing observed practices against the four maturity levels
4. Assigning a score (1-4) based on best match

### Step 3: Generate Assessment Report

Use the assessment script to compile scores and generate visualizations:

```bash
python scripts/assess_maturity.py /path/to/project --output report.json
```

The script will:
- Parse the capabilities rubric
- Collect assessment data
- Calculate dimension scores and overall maturity
- Generate visualizations (radar charts, bar charts)
- Export results in JSON and HTML formats

### Step 4: Analyze Results

Review the generated report to:
- Identify high-scoring areas (strengths)
- Identify low-scoring areas (improvement opportunities)
- Compare against industry benchmarks
- Prioritize improvement initiatives

### Step 5: Create Improvement Plan

Based on the assessment, create a roadmap to improve maturity:
- Focus on capabilities with minimum level requirements first
- Address low-hanging fruit (quick wins)
- Plan longer-term improvements for complex areas
- Track progress over time
