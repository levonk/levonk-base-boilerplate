# Skill Creator

A skill for creating new skills and iteratively improving them through test-driven development and systematic evaluation.

## Benefits

### Token Efficiency
- **Concise guidance bodies**: Main skill content stays focused with deterministic phases extracted to scripts
- **Progressive disclosure**: Detailed information moved to reference files
- **Context preservation**: Context declared at bottom preserves AI cache capability
- **Shared templates**: Jinja templating reduces duplication across skills

### Consistency & Quality
- **Standard frontmatter**: Consistent structure across all AI guidance types
- **Shared principles**: Universal quality guidelines applied consistently
- **Best practices**: Matt Pocock's writing-great-skills principles integrated
- **Type-specific guidance**: Tailored advice for skills, workflows, agents, and prompts

### Maintainability
- **Single source of truth**: Common patterns defined once, referenced everywhere
- **Template propagation**: Changes to shared templates update all consuming files
- **Clear separation**: Distinct boundaries between metadata, body, and resources
- **Reduced duplication**: Eliminates repeated instructions and context

### Progressive Disclosure
- **Three-level loading**: Metadata (always) → Body (on trigger) → Resources (as needed)
- **Smart referencing**: Clear pointers with usage guidance for reference files
- **Audience separation**: Different information paths for different user needs
- **Hierarchical structure**: Organized from high-level to detailed information

### Development Workflow
- **Systematic process**: 8-step creation process (DECONSTRUCT → PACKAGE)
- **Test-driven**: Evaluation framework for measuring skill effectiveness
- **Iterative improvement**: Pruning techniques and failure mode analysis
- **Distribution ready**: Packaging guidance for sharing skills

## Architecture

### Shared Templates

The skill creator leverages shared templates for consistency:

- **`base-frontmatter.md.tmpl`** - Standard frontmatter structure
- **`base-content-principles.md.tmpl`** - Token efficiency and quality guidelines
- **`context-declaration.md.tmpl`** - Context management template
- **`ai-guidance-creation.md.tmpl`** - Universal creation framework

### Skill Structure

```
category-name/skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter metadata
│   └── Markdown instructions
└── Bundled Resources (optional)
    ├── scripts/     # Executable code
    ├── references/  # Documentation
    └── assets/      # Templates and files
```

### Three-Level Architecture

1. **Level 1: Metadata** - Always loaded (~100 words)
2. **Level 2: Instructions** - Loaded when skill triggers
3. **Level 3: Resources** - Loaded as needed (unlimited)

## Usage

### Creating a New Skill

```bash
# Use the ai-skill-upsert to guide you through the process
ai-skill-upsert "I want to create a skill for X"

# Or initialize structure manually
python scripts/init_skill.py <skill-name> --path <output-directory>
```

### Improving Existing Skills

When given an existing skill directory, this skill audits it against the skill guidelines (frontmatter, description quality, structure, progressive disclosure, context declaration, bundled resources, stale text), proposes prioritized changes, and asks for confirmation before applying. For cross-file and system-wide analysis (conflicts, duplications across multiple guidance files), use the companion `ai-guidance-improver` skill.

## Related Skills

- **`ai-guidance-improver`** - Analyze and improve existing AI guidance files
- **Shared templates** - Base templates for consistent structure and quality

## Best Practices

- **Front-load leading words** in descriptions for better triggering
- **Use progressive disclosure** to keep main content concise
- **Declare context at bottom** to preserve AI cache capability
- **Apply shared templates** for consistency across guidance types
- **Test iteratively** using the evaluation framework
- **Prune regularly** to remove no-ops and duplications

## Context

- **Main skill**: `config/ai/skills/ai/ai-skill-upsert/SKILL.md`
- **Shared templates**: `config/ai/skills/includes/`
- **Project**: levonk/dotfiles
- **Repository**: https://github.com/levonk/dotfiles
