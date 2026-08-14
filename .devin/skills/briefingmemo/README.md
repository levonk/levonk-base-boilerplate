# BriefingMemo Skill

A deterministic multi-agent strategic decision-making system that transforms structured briefs into well-researched decisions through committee deliberation.

## Overview

This skill implements a 5-phase process:
1. **Brief Creation** - Structured input with required sections
2. **Research Phase** - Committee polls for information needs, research agents gather data
3. **Committee Deliberation** - 15 specialized agents debate in deterministic rounds
4. **Decision Memo** - CSO synthesizes final decision with rationale
5. **Post-Decision Review** - Cultural, philanthropic, and environmental impact assessment

## Quick Start

### Interactive Mode (Recommended)
Launch the TUI interface for full briefing management:
```bash
python3 scripts/manage_briefings.py --tui
```

This provides:
- 📝 Create new briefings with guided input
- ⏳ View and manage pending briefings
- 🔄 Track in-progress deliberations
- ✅ Browse completed decisions
- 🔍 Search through all briefings

### Command Line Mode

#### Create a New Brief
```bash
python3 scripts/create_brief.py --template --output "my_decision_brief.md" --title "Strategic Decision Title"
```

#### Start Full Deliberation Process
```bash
python3 scripts/start_deliberation.py --brief my_decision_brief.md --time 5 --budget 5
```

#### Skip Research Phase
```bash
python3 scripts/start_deliberation.py --brief my_decision_brief.md --skip-research
```

#### Briefing Management
```bash
# List all briefings
python3 scripts/manage_briefings.py --list

# Quick create briefing
python3 scripts/manage_briefings.py --create "Decision Title"
```

## Committee Composition

### Executive Leadership
- **CSO (Chief of Strategy)**: Orchestrates deliberation, makes final decision

### Core Committee (15 Members)
1. Financial/Investment Agent
2. Legal/Compliance Agent
3. Customer/User Advocate
4. Market Analyst
5. Statistician
6. Operations/Execution Agent
7. Culture Agent
8. Futurist
9. Risk Management Agent
10. Innovation/R&D Agent
11. Compounder
12. Product Strategist
13. Contrarian
14. Moonshot
15. Technical Architect

### Post-Decision Review (Non-influential)
- Philanthropic Agent
- Environmental Agent

## Deterministic Features

- Fixed speaking order (alphabetical)
- Round-robin turn allocation
- Configurable time/budget limits
- Consistent voting patterns based on personas
- Reproducible outcomes for same inputs

## File Structure

```
briefingmemo/
├── SKILL.md                    # Main skill documentation
├── scripts/                    # Executable scripts
│   ├── create_brief.py         # Create/validate briefs
│   ├── poll_research_needs.py  # Poll committee for research needs
│   ├── orchestrate_deliberation.py  # Run committee deliberation
│   ├── generate_memo.py        # Generate final decision memo
│   └── start_deliberation.py  # Main entry point
├── references/                 # Documentation
│   ├── brief_template.md       # Brief structure template
│   └── committee_roles.md      # Role definitions
├── config/                     # Configuration files
│   └── committee.yaml          # Committee and process settings
└── assets/                     # Templates and frameworks
```

## Configuration

Edit `config/committee.yaml` to customize:
- Committee composition
- Model assignments
- Time and budget limits
- Research phase settings

## Output Files

Each deliberation generates:
- `decision_memo.md` - Final decision with rationale
- `deliberation_transcript.md` - Full committee discussion
- `deliberation.json` - Raw deliberation data
- `post_decision_reviews.md` - Cultural/social/environmental assessment
- `research_package.json` - Compiled research data (if research phase enabled)

## Usage Examples

### Example 1: Acquisition Decision
```bash
# Create brief
python3 scripts/create_brief.py --template --output "acquisition_brief.md" --title "Company X Acquisition"

# Run deliberation with research
python3 scripts/start_deliberation.py --brief acquisition_brief.md --time 10 --budget 10
```

### Example 2: Product Launch Decision
```bash
# Create brief manually, then run
python3 scripts/start_deliberation.py --brief product_launch_brief.md --output-dir ./decisions/2025-03-24
```

## Process Flow

1. **Input**: Strategic question or decision point
2. **Brief**: Structured document with situation, stakes, constraints, questions
3. **Research**: Committee identifies information gaps, research agents gather data
4. **Deliberation**: Parallel debate with adversarial perspectives
5. **Decision**: CSO synthesizes input, makes final call
6. **Review**: Post-decision impact assessments

## Key Principles

- **Structured Input**: All briefs follow template format
- **Research First**: Committee has relevant data before deliberating
- **Parallel Processing**: All agents deliberate simultaneously
- **Adversarial Design**: Conflicting perspectives expose all angles
- **Post-Decision Review**: Cultural/social/environmental impacts assessed separately

## Error Handling

- Invalid briefs: Auto-reject with specific feedback
- Time/budget exceeded: Graceful termination with partial results
- Agent failures: Continue with available agents, log failures
- Research gaps: Proceed with available information, note gaps

## Customization

### Adding New Agents
1. Edit `config/committee.yaml`
2. Add persona to `references/committee_roles.md`
3. Update voting logic in `scripts/orchestrate_deliberation.py`

### Modifying Decision Process
1. Update deliberation phases in `orchestrate_deliberation.py`
2. Modify memo generation in `generate_memo.py`
3. Update documentation

## Security Considerations

- All briefs validated before processing
- Research sources tracked and cited
- Decision audit trail maintained
- Post-decision reviews isolated from decision process
