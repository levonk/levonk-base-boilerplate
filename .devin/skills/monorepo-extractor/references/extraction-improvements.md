# Extraction Improvements

## Key Improvements (v3.0)

The `extract-project-strict.sh` script now includes **intelligent AI/IDE configuration analysis and filtering**:

### 1. AI/IDE Configuration Analysis

- **Comprehensive Detection**: Analyzes README.md, AGENTS.md, MEMORY.md, TOOLS.md, SOUL.md, IDENTITY.md, USER.md, HEARTBEAT.md
- **IDE Configuration Support**: Evaluates .windsurf/, .cursor/, .claud/, .gemini/, .qwen/, .crush/, .clienrules/, .vscode/, .agents/
- **Development Environment**: Assesses .devbox/, .iflow/, .specify/, .tickets/, .trae/ directories
- **Relevance Scoring**: Scores each file/directory (1-10) based on migration importance
- **Project-Specific Detection**: Identifies configurations that reference the target project

### 2. Smart Content Filtering

- **Monorepo Reference Cleanup**: Automatically replaces monorepo-specific terminology
- **Content Adaptation**: Converts shared configurations for standalone use
- **Selective Migration**: Prioritizes high-relevance files (7-10 score)
- **Conditional Preservation**: Keeps medium-relevance items only if project-specific
- **Low-Relevance Filtering**: Excludes generated or environment-specific configs

### 3. Enhanced Migration Intelligence

- **Content Analysis**: Evaluates file contents for project relevance
- **Terminology Mapping**:
  - "monorepo" → "standalone repository"
  - "this repository contains" → "this project provides"
  - "shared with" → "self-contained"
  - "repository-wide" → "project-specific"
- **Documentation Enhancement**: Improves project descriptions for standalone context
- **Configuration Optimization**: Adapts AI/IDE configs for independent project use

### 4. Advanced Analysis Options

```bash
# Enable AI/IDE analysis (default: enabled)
./scripts/extract-project-strict.sh /path/to/monorepo project-name /path/to/new-repo

# Skip AI/IDE analysis if not needed
./scripts/extract-project-strict.sh --no-ai-analysis /path/to/monorepo project-name /path/to/new-repo

# Skip content filtering (keep original content)
./scripts/extract-project-strict.sh --no-ai-filtering /path/to/monorepo project-name /path/to/new-repo

# Combined with other options
./scripts/extract-project-strict.sh --verbose --branch main --no-ai-filtering /path/to/monorepo project-name /path/to/new-repo
```

## Key Improvements (v2.0)

The `extract-project-improved.sh` script addresses common issues with monorepo extraction:

### 1. Flexible Validation

- `--force` flag to bypass strict validation warnings
- Handles uncommitted changes gracefully
- Works with active development branches

### 2. Branch-Specific Extraction

- `--branch` flag to clone specific branches
- Preserves exact commit SHAs from target branch
- Maintains proper git history context

### 3. Simplified Workflow

- Single-command extraction with git-filter-repo
- Automatic file restructuring (move to root)
- Clean history filtering without manual steps

### 4. Better Error Handling

- Clear error messages and recovery options
- Dry-run mode for testing
- Graceful fallbacks for missing tools
