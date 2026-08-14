# Tool Comparison: surgical-edit.sh vs manage-config.mjs

This Skill provides two complementary tools for different use cases:

## surgical-edit.sh

**Primary Interface**: Single-file, interactive surgical modifications

**Use Cases**:

- Interactive terminal usage
- Quick ad-hoc modifications
- Shell script integration
- Single file edits

**Features**:

- Intelligent file type detection
- Automatic tool selection
- Project-aware editing with `--detect-project`
- Pattern-based code transformations
- Immediate feedback and validation

**Examples**:

```bash
# Single file operations
./scripts/surgical-edit.sh package.json '.dependencies += {"lodash": "^4.17.21"}'
./scripts/surgical-edit.sh docker-compose.yml '.services.web.port = 8080'
./scripts/surgical-edit.sh src/main.rs 'println!(:[args])' 'log::info!(:[args])'

# Project-aware editing
./scripts/surgical-edit.sh --detect-project package.json '.dependencies += {"express": "^4.18.0"}'
```

## manage-config.mjs

**Batch Operations**: Configuration-driven, multi-file processing

**Use Cases**:

- Bulk configuration updates across projects
- CI/CD pipeline integration
- Configuration-as-code workflows
- JavaScript/Node.js environments

**Features**:

- Directory traversal and file pattern matching
- JSON configuration file support
- Batch dependency management
- Template processing (Jinja2)
- Dry-run mode for safety
- Rich operation set (array-add, object-set, etc.)

**Examples**:

```bash
# Batch operations with config file
node scripts/manage-config.mjs --config batch-update.json --dry-run

# Single operation across multiple files
node scripts/manage-config.mjs --operation set --key-path version --value '"1.0.0"' --file-name package.json

# Dependency management
node scripts/manage-config.mjs --config deps-config.json
```

## When to Use Which Tool

| Scenario | Recommended Tool | Reason |
|----------|------------------|---------|
| **Quick single file edit** | `surgical-edit.sh` | Faster, simpler, immediate feedback |
| **Interactive development** | `surgical-edit.sh` | Designed for terminal usage |
| **Bulk project updates** | `manage-config.mjs` | Directory traversal, pattern matching |
| **CI/CD pipeline** | `manage-config.mjs` | Configuration-driven, dry-run support |
| **Complex multi-file operations** | `manage-config.mjs` | Rich operation set, batch processing |
| **Shell script integration** | `surgical-edit.sh` | Simple CLI, easy to pipe |
| **JavaScript ecosystem** | `manage-config.mjs` | Node.js native, better integration |

## Integration Example

Both tools can work together in a workflow:

```bash
# 1. Use manage-config.mjs for bulk updates
node scripts/manage-config.mjs --config standardize-configs.json

# 2. Use surgical-edit.sh for fine-tuning
./scripts/surgical-edit.sh --detect-project critical-config.json '.timeout = 30000'
```
