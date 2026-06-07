---
modeline: "vim: set ft=markdown:"
title: "ADR: Memory Management and Local Task Tracking Standardization"
adr-id: adr-20260322003
slug: 20260322003-memory-management-local-task-tracking
url: /internal-docs/adr/adr-20260322003-memory-management-local-task-tracking.md
synopsis: Standardize on qmd for memory search, Obsidian for memory markdowns, and tkr for task management across all projects
author: https://github.com/levonk
date-created: 2026-03-22
date-updated: 2026-03-22
version: 1.0.0
status: "proposed"
aliases: []
tags: ["doc/architecture/adr", "memory-management", "task-management", "tooling", "productivity"]
supersedes: []
superseded-by: []
related-to: ["adr-20260131001-standard-developer-ux-flow", "adr-20251129002-architecture-decision-records-process"]
scope:
  impact-scope: ["all applications", "all packages", "internal-docs", "developer-workflow"]
  excluded-scope: []
---

# Decision Record: Memory Management and Local Task Tracking Standardization

- belongs in `internal-docs/adr/adr-20260322003-memory-management-local-task-tracking.md`

---

## Context

Developers and AI agents need consistent tools for managing knowledge memory and tracking local tasks across the monorepo. Currently, there is no standardized approach for:

1. **Memory Search**: Finding relevant information across project documentation, code, and previous decisions
2. **Memory Management**: Organizing and maintaining knowledge as markdown files
3. **Local Task Tracking**: Managing development tasks at the local/project level without requiring external services

This leads to:
- Inconsistent memory organization across projects
- Difficulty finding relevant information quickly
- Fragmented task tracking approaches
- Reduced developer productivity due to tool switching

## Constraints

- The solution must work locally without requiring external services
- Must be compatible with existing editor workflows (VS Code, Windsurf, etc.)
- Should integrate well with our existing ADR process and documentation standards
- Must support both human developers and AI agents
- Should be lightweight and fast for daily use

## Decision

We will standardize on the following tools for memory management and local task tracking:

1. **qmd (https://github.com/tobi/qmd)** for memory search and indexing
2. **Obsidian (https://obsidian.md/)** for memory markdown management and organization  
3. **tkr (https://github.com/levonk/tkr)** for local task management and ticket tracking

## Rationale

### qmd for Memory Search

- **Purpose-built**: Designed specifically for searching markdown files and documentation
- **Fast indexing**: Provides quick search across large documentation sets
- **Local-first**: Works entirely locally without external dependencies
- **Markdown-native**: Optimized for markdown-based knowledge bases
- **Developer-friendly**: Integrates well with existing development workflows

### Obsidian for Memory Management

- **Markdown-based**: Uses standard markdown files that work with any editor
- **Linking system**: Powerful bidirectional linking for knowledge graphs
- **Local files**: Knowledge stored as plain files in the repository
- **Extensible**: Rich plugin ecosystem for custom workflows
- **Editor integration**: Works with VS Code, vim, and other editors
- **AI-agent compatible**: Plain markdown files are easily readable by AI tools

### tkr for Task Management

- **Local-first**: Manages tasks as markdown files without requiring external services
- **Git-friendly**: Designed to work with version control workflows
- **CLI-native**: Command-line interface that integrates with developer workflows
- **Markdown storage**: Tasks stored as human-readable markdown files
- **Dependency tracking**: Supports task dependencies and relationships
- **AI-agent designed**: Built specifically for AI agent workflows and automation

## Technical Approach

This implementation integrates with the **Standard Developer UX Flow** defined in [ADR 20260131001](./adr-20260131001-standard-developer-ux-flow.md), leveraging the existing `just` target architecture for seamless integration.

### 1. Integration with Standard Developer UX Flow

According to the standard flow, we use the pattern: `direnv → devbox → just (*-internal) → [build tool]`. The memory management tools integrate as follows:

- **Bootstrap**: Initialize tkr for task management
- **Prime**: Index documentation with qmd for fast search
- **New Target**: `doc-search` for quick memory search

### 2. Memory Search with qmd

**Integration with Prime Target**:
The existing `just prime-internal` target will be extended to include qmd indexing:

```just
prime-internal:
    # Update repository from remote
    echo "Updating repository..."
    git fetch || echo "git fetch failed (check remote connectivity)"
    
    # Existing code indexing (ctags, roam-code, desloppify)
    echo "Priming code indexing and analysis tools..."
    
    # qmd memory indexing
    echo "Indexing documentation with qmd..."
    if command -v qmd >/dev/null 2>&1; then
        qmd index docs/ internal-docs/ memory/ README.md || echo "qmd indexing failed (install with: cargo install qmd)"
    else
        echo "qmd not found - install with: cargo install qmd"
    fi
    
    echo "Code and documentation indexing complete!"
```

**New doc-search Target**:
```just
# Search documentation and memory (NEW)
doc-search:
    devbox shell doc-search

doc-search-internal:
    # Search memory and documentation with qmd
    if command -v qmd >/dev/null 2>&1; then
        query="${1:-.}"  # Default to show all if no query
        qmd search "$query" | head -20
    else
        echo "qmd not found - install with: cargo install qmd"
        echo "Falling back to ripgrep..."
        rg --type md "$query" docs/ internal-docs/ memory/ || true
    fi
```

**Usage**:
```bash
# Search for specific topics
just doc-search "authentication"
just doc-search "database"

# Show all indexed files
just doc-search
```

### 3. Task Management with tkr

**Integration with Bootstrap Target**:
The existing `just bootstrap-internal` target will be extended to initialize tkr:

```just
bootstrap-internal:
    # Existing bootstrap logic
    just setup
    
    # Initialize tkr for task management
    echo "Initializing task management with tkr..."
    if command -v tkr >/dev/null 2>&1; then
        if [ ! -d ".tickets" ]; then
            tkr init || echo "tkr init failed (install from: https://github.com/levonk/tkr)"
        else
            echo "tkr already initialized"
        fi
    else
        echo "tkr not found - install from: https://github.com/levonk/tkr"
    fi
    
    echo "Project bootstrap complete!"
```

**Enhanced justfile with Task Targets**:
```just
# Task management targets (NEW)
tasks:
    devbox shell tasks

tasks-internal:
    # List current tasks
    if command -v tkr >/dev/null 2>&1; then
        tkr list --status=open
    else
        echo "tkr not found"
    fi

task-ready:
    devbox shell task-ready

task-ready-internal:
    # Get next available task
    if command -v tkr >/dev/null 2>&1; then
        tkr ready
    else
        echo "tkr not found"
    fi

task-start:
    devbox shell task-start

task-start-internal:
    # Start working on available task
    if command -v tkr >/dev/null 2>&1; then
        task_id=$(tkr ready | head -1 | cut -d' ' -f1)
        if [ -n "$task_id" ]; then
            tkr start "$task_id"
            echo "Started task: $task_id"
        else
            echo "No available tasks"
        fi
    else
        echo "tkr not found"
    fi
```

### 4. Memory Management with Obsidian

**Directory Structure** (created during bootstrap):
```
memory/
├── 00-inbox/             # Random thoughts that need to be files
├── 01-projects/          # Project-specific knowledge
├── 02-decisions/         # Architecture decisions and rationale
├── 03-patterns/          # Design patterns and solutions
├── 04-learnings/         # Lessons learned and insights
├── 05-references/        # External references and links
├── 98-logs/              # Session logs
└── 99-daily/             # Daily notes, and temporary thoughts
```

**Bootstrap Integration**:
```just
bootstrap-internal:
    # ... existing bootstrap logic ...
    
    # Create memory directory structure
    echo "Setting up memory structure..."
    mkdir -p memory/{00-inbox,01-projects,02-decisions,03-patterns,04-learnings,05-references,98-logs,99-daily}
    
    # Create Obsidian configuration if needed
    if [ ! -d ".obsidian" ]; then
        mkdir -p .obsidian
        echo "# Obsidian configuration" > .obsidian/config.md
    fi
    
    echo "Memory structure created"
```

### 5. Updated Standard justfile

**Complete Integration** (following the standard UX flow pattern):

```just
# Normal targets - Developer interface (REQUIRED)
doc-search:
    devbox shell doc-search

tasks:
    devbox shell tasks

task-ready:
    devbox shell task-ready

task-start:
    devbox shell task-start

# Internal targets - Actual implementation (REQUIRED)
doc-search-internal:
    # qmd search implementation (see above)

tasks-internal:
    # tkr list implementation (see above)

task-ready-internal:
    # tkr ready implementation (see above)

task-start-internal:
    # tkr start implementation (see above)

# Enhanced existing targets
bootstrap-internal:
    # Existing bootstrap + tkr init + memory structure (see above)

prime-internal:
    # Existing prime + qmd indexing (see above)
```

### 6. Workflow Integration

**Daily Development Workflow** (following standard UX flow):
```bash
# 1. Enter project (direnv activates devbox)
cd project

# 2. Bootstrap initializes everything automatically
# (tkr init, memory structure, qmd indexing happens in bootstrap/prime)

# 3. Check available tasks
just tasks

# 4. Search memory for context
just doc-search "authentication patterns"

# 5. Start working on task
just task-start

# 6. Work with full context (qmd + Obsidian + tkr)
```

**AI Agent Workflow** (following devbox run + *-internal pattern):
```bash
# AI agents use direct internal calls
devbox run just task-ready-internal
devbox run just doc-search-internal "database design"
devbox run just task-start-internal
```

## Consequences

### Positive

1. **Consistent Knowledge Management**: Single approach across all projects
2. **Fast Information Retrieval**: qmd provides quick search across all documentation
3. **Rich Knowledge Graphs**: Obsidian linking creates interconnected knowledge base
4. **Local-First**: No external dependencies or services required
5. **Git-Friendly**: All tools work well with version control
6. **AI-Agent Compatible**: All tools designed to work with automated agents
7. **Developer Productivity**: Reduced context switching and tool fragmentation

### Negative

1. **Learning Curve**: Developers need to learn three new tools
2. **Setup Overhead**: Initial configuration required for each project
3. **Tool Maintenance**: Need to keep tools updated and configured
4. **Storage Overhead**: Additional files and indexes in repositories

### Neutral

1. **Multiple Tools**: Three specialized tools instead of one all-in-one solution
2. **Markdown-Centric**: Heavy reliance on markdown format for all knowledge

## Alternatives Considered

### Single Tool Solutions
- **Notion**: External service, not local-first
- **Logseq**: Good alternative to Obsidian, but Obsidian has better editor integration
- **Dendron**: VS Code extension, less flexible than Obsidian

### Built-in Solutions
- **Git Issues**: External service dependency, not local
- **Custom Scripts**: Higher maintenance burden, fewer features
- **IDE Features**: Limited to specific editors, less portable

### Search Only
- **ripgrep**: Fast but no knowledge graph features
- **Silver Searcher**: Similar limitations to ripgrep
- **grep**: Standard but limited functionality

## Rollout / Migration

### Phase 1: Foundation (Week 1)
1. Add tool installation to bootstrap scripts
2. Create default configurations for all three tools
3. Update developer onboarding documentation

### Phase 2: Memory Migration (Week 2-3)
1. Migrate existing documentation to Obsidian structure
2. Set up qmd indexing for all projects
3. Create linking strategy and naming conventions

### Phase 3: Task Integration (Week 3-4)
1. Initialize tkr in all active projects
2. Migrate existing task tracking to tkr
3. Integrate with existing workflows and CI/CD

### Phase 4: Workflow Optimization (Week 4-5)
1. Create integrated workflows and scripts
2. Train developers and AI agents on new tools
3. Optimize configurations based on usage patterns

## Validation

This ADR will be considered successful if:

- Developers can find relevant information 50% faster than before
- Task tracking consistency improves across all projects
- Knowledge reuse increases (measured by cross-project references)
- Developer satisfaction with tooling improves (survey feedback)
- AI agents can effectively use all three tools for context-aware work

## Implementation Details

### Required Files and Configurations

**qmd Configuration** (`.qmd/config.toml`):
```toml
[search]
directories = ["docs/", "internal-docs/", "memory/"]
file_patterns = ["*.md", "*.txt"]
exclude_patterns = ["node_modules/", ".git/", "target/"]

[indexing]
auto_update = true
update_interval = 300  # 5 minutes
```

**Obsidian Configuration** (`.obsidian/`):
- Standard Obsidian settings stored in repository
- Core plugins: File explorer, Search, Links, Tags
- Community plugins: Optional based on team preferences

**tkr Configuration** (`.tickets/config.toml`):
```toml
[storage]
directory = ".tickets"
format = "markdown"

[workflow]
default_status = "open"
auto_assign = false

[display]
date_format = "%Y-%m-%d"
time_format = "%H:%M"
```

### Integration Scripts

**Memory Search Script** (`scripts/memory-search.sh`):
```bash
#!/bin/bash
# Search memory with qmd and open results in editor
query="$1"
results=$(qmd search "$query")
echo "$results" | head -10
# Optional: open best match in editor
```

**Task Context Script** (`scripts/task-context.sh`):
```bash
#!/bin/bash
# Get current task context and search memory
current_task=$(tkr current)
if [ -n "$current_task" ]; then
    echo "Current task: $current_task"
    qmd search "$current_task"
    tkr show "$current_task"
fi
```

## References

- [qmd - Quick Markdown Search](https://github.com/tobi/qmd)
- [Obsidian - Knowledge Base](https://obsidian.md/)
- [tkr - Task Management](https://github.com/levonk/tkr)
- [ADR 20260131001 - Standard Developer UX Flow](./adr-20260131001-standard-developer-ux-flow.md)
- [ADR 20251129002 - Architecture Decision Records Process](./adr-20251129002-architecture-decision-records-process.md)

<!-- vim: set ft=markdown: -->
