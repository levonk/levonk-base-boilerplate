# Configuration Precedence

This document describes how configuration values are loaded and merged from different sources.

## Precedence Order

Configuration is loaded from multiple sources in the following order (lowest to highest precedence):

1. **Default Values** - Built-in defaults from the code
2. **System Config** - `/etc/{{ project_slug }}/config.toml`
3. **User Config** - `~/.config/myorg/{{ project_slug }}/config.toml`
4. **Local Config** - `.config/{{ project_slug }}/config.toml` (project directory)
5. **Environment Variables** - `{{ PROJECT_SLUG }}_*` prefixed variables
6. **Command Line Arguments** - CLI flags (highest precedence)

Higher precedence sources override values from lower precedence sources.

## Environment Variables

All configuration values can be overridden via environment variables with the `{{ PROJECT_SLUG }}_` prefix:

| Config Field | Environment Variable | Example |
|-------------|---------------------|---------|
| `log_level` | `{{ PROJECT_SLUG }}_LOG_LEVEL` | `export {{ PROJECT_SLUG }}_LOG_LEVEL=debug` |
| `color` | `{{ PROJECT_SLUG }}_COLOR` | `export {{ PROJECT_SLUG }}_COLOR=never` |
| `output_format` | `{{ PROJECT_SLUG }}_OUTPUT_FORMAT` | `export {{ PROJECT_SLUG }}_OUTPUT_FORMAT=json` |
| `quiet` | `{{ PROJECT_SLUG }}_QUIET` | `export {{ PROJECT_SLUG }}_QUIET=true` |
| `max_concurrent` | `{{ PROJECT_SLUG }}_MAX_CONCURRENT` | `export {{ PROJECT_SLUG }}_MAX_CONCURRENT=8` |
| `timeout` | `{{ PROJECT_SLUG }}_TIMEOUT` | `export {{ PROJECT_SLUG }}_TIMEOUT=60` |
| `experimental` | `{{ PROJECT_SLUG }}_EXPERIMENTAL` | `export {{ PROJECT_SLUG }}_EXPERIMENTAL=true` |
| `mode` | `{{ PROJECT_SLUG }}_MODE` | `export {{ PROJECT_SLUG }}_MODE=agent` |
| `default_format` | `{{ PROJECT_SLUG }}_DEFAULT_FORMAT` | `export {{ PROJECT_SLUG }}_DEFAULT_FORMAT=toon` |
| `truncation_limit` | `{{ PROJECT_SLUG }}_TRUNCATION_LIMIT` | `export {{ PROJECT_SLUG }}_TRUNCATION_LIMIT=2000` |
| `enable_contextual_help` | `{{ PROJECT_SLUG }}_ENABLE_CONTEXTUAL_HELP` | `export {{ PROJECT_SLUG }}_ENABLE_CONTEXTUAL_HELP=false` |
| `session_context_enabled` | `{{ PROJECT_SLUG }}_SESSION_CONTEXT_ENABLED` | `export {{ PROJECT_SLUG }}_SESSION_CONTEXT_ENABLED=true` |

## AXI-Specific Configuration

The following configuration fields are specific to Agent eXperience Interface (AXI) integration:

### Mode

- **`mode`**: Determines the operational mode
  - `agent`: Optimized for AI agent integration with TOON output format
  - `human`: Optimized for human interaction with traditional output
  - Default: `agent`

### Default Format

- **`default_format`**: Output format for agent mode
  - `toon`: Token-Oriented Object Notation (compact, agent-optimized)
  - `json`: Standard JSON format
  - `human`: Human-readable text format
  - Default: `toon`

### Truncation Limit

- **`truncation_limit`**: Maximum length for output fields before truncation
  - Fields exceeding this length are truncated with metadata
  - Default: `1000` characters

### Contextual Help

- **`enable_contextual_help`**: Include help text in agent output
  - When `true`, help text is included in agent responses
  - Default: `true`

### Session Context

- **`session_context_enabled`**: Output ambient context information
  - When `true`, includes cwd, repo_root, audit_log, etc.
  - Default: `false`

## Configuration Migration

When the configuration version changes (tracked by the `version` field), the system automatically:

1. Creates a backup of the existing config file (`.toml.bak`)
2. Merges old configuration with new defaults
3. Writes the migrated configuration
4. Logs the migration operation

This ensures existing user configurations are preserved while adding new fields with sensible defaults.

## Example Configuration

```toml
# {{ project_name }} Configuration File
version = 2

# Basic settings
log_level = "info"
color = "auto"
output_format = "text"
quiet = false

# Performance settings
max_concurrent = 4
timeout = 30

# AXI settings
mode = "agent"
default_format = "toon"
truncation_limit = 1000
enable_contextual_help = true
session_context_enabled = false
```

## Best Practices

- Use system config for organization-wide defaults
- Use user config for personal preferences
- Use local config for project-specific settings
- Use environment variables for CI/CD or temporary overrides
- Use command-line arguments for one-off operations
- Keep sensitive configuration in user config (not in version control)
