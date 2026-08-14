# Conversation Continuity Skill

This skill enables seamless continuation of work across AI sessions by capturing comprehensive context from ongoing conversations and providing it to fresh sessions.

## Usage

### End of Session - Capture Context
Simply ask: "Capture the current conversation context for continuation"

The AI will generate a comprehensive context document including:
- Project overview and current status
- Key decisions made
- Technical context and important files
- Prioritized next steps
- Success criteria
- Open questions and blockers

### Start New Session - Restore Context
1. Start a fresh AI session
2. Paste or attach the context document
3. Say: "Continue work from this context document"

The AI will understand the context and immediately begin with the next step without asking questions.

## Features

- **Comprehensive Context Capture**: Ensures nothing important is lost
- **Standardized Format**: Consistent structure for easy parsing
- **Priority-Based Next Steps**: Clear action items in order
- **Success Criteria**: Defined outcomes to track progress
- **Minimal Setup**: No complex configuration needed

## Helper Script

Use the included `capture_context.py` script for guided context capture:

```bash
python scripts/capture_context.py [output_file]
```

The script will prompt you for all necessary information and generate a properly formatted context document.

## Best Practices

1. **Capture context at natural breakpoints** - End of day, major milestones, or when switching AI sessions
2. **Be specific in next steps** - Clear, actionable items with deliverables
3. **Update context regularly** - After completing major steps, update the document
4. **Store context with project** - Keep context files in the project directory for team reference

## File Structure

```
conversation-continuity/
├── SKILL.md                    # Main skill documentation
├── scripts/
│   └── capture_context.py      # Helper script for guided capture
└── README.md                   # This file
```

## Example Context Document

```markdown
# Conversation Context Handoff

## Metadata
- **Created**: 2025-01-15T14:30:00Z
- **Session Duration**: ~2 hours
- **Primary Goal**: Implement user authentication system

## Project Overview
### Objective
Add JWT-based authentication to the Node.js Express API

### Current Status
Mid-implementation - JWT middleware created, refresh token storage pending

## Next Steps
1. Implement refresh token endpoint in `/auth/refresh`
2. Add token rotation logic
3. Update login endpoint to return refresh token

## Success Criteria
- Users can log in and receive both tokens
- Access tokens expire after 15 minutes
- Refresh tokens can generate new access tokens
```

## Troubleshooting

- **Context too long**: Focus on decisions and next steps, move details to references
- **Missing information**: When restoring, ask specific questions about gaps
- **Context outdated**: Update after each major milestone, not just at session end
