# Enhanced Tool Hierarchy

## Tool Hierarchy Details

1. **Template Processor** - Handle templated structured files
   - Extract template content (e.g., strip `.jinja` templating)
   - Process as structured format
   - Reapply template if needed

2. **Semantic Parsers** (`yq-go`) - Format-aware modifications
   - **Primary choice**: Preserves comments, formatting, and structure
   - **Alternatives**: `jq` (JSON only), `jo` (JSON creation), `dot-json` (JSON from CLI)
   - **Type-aware operations** and **idempotent transformations**

3. **Structural Rewriters** (`comby`, `ast-grep`) - Code pattern transformations
   - Language-agnostic patterns
   - AST-based semantic changes
   - Safe structural modifications

4. **Patch Managers** (`quilt`, `guilt`) - Managed patch application
   - Version-controlled changes
   - Rollback capability
   - Complex change management

5. **Text-based Utilities** (`sd`, `sed`, `echo`) - Simple text operations
   - Line-based modifications
   - Simple substitutions
   - Content additions

## Smart Tool Selection Based on Project

| Project Type | Preferred Tools | Special Handling |
|--------------|----------------|------------------|
| **Node.js** | yq-go, jq, sd | Respects package-lock.json, npm scripts |
| **Rust** | yq-go, sd | Preserves Cargo.lock, uses Cargo.toml |
| **Python** | yq-go, sd | Respects requirements.txt, pyproject.toml |
| **Go** | yq-go, sd | Preserves go.mod, go.sum |
| **Java/Maven** | yq-go, sd | Preserves pom.xml, Maven structure |
| **Docker** | yq-go, sd | Respects docker-compose.yml, Dockerfile |
| **Kubernetes** | yq-go, kubectl | Preserves k8s manifests, Helm charts |

## Required Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| **yq-go** | Primary semantic parser (preserves comments) | `go install github.com/mikefarah/yq/v4@latest` |
| **jq** | JSON fallback processor | `brew install jq` or `sudo apt install jq` |
| **comby** | Structural code rewriter | `cargo install comby` |
| **ast-grep** | AST-based code transformations | `npm install -g ast-grep` |
| **sd** | Modern sed replacement | `cargo install sd` |
| **jinja2-cli** | Template processor | `pip install jinja2-cli` |
| **quilt** | Patch management | `sudo apt install quilt` |
| **guilt** | Git-based patch management | `brew install guilt` |

## Environment Validation

```bash
# Validate your setup
./skills/surgical-config/scripts/ensure-environment.sh --validate

# Test surgical editing
./skills/surgical-config/scripts/surgical-edit.sh --help
```
