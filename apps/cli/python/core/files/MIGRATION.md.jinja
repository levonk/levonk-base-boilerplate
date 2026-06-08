# Migration Guide

This guide helps you migrate an existing CLI generated from an older version of the Python CLI boilerplate to the current version.

## Overview

The current Python CLI boilerplate includes significant enhancements while maintaining backward compatibility through feature flags. New features are opt-in via template options during project generation.

## What's New

### New Features (Opt-In)

- **Advanced Configuration**: `include_advanced_config` - Config validation, migration, and precedence (default: true)
- **TUI Mode**: `include_tui` - Interactive terminal user interface (default: false)
- **Health Check**: `include_health_check` - Container health check mechanism (default: false)
- **Privacy Mode**: `include_privacy` - Privacy mode with anonymous lists (default: false)
- **Audit Logging**: `include_audit` - Audit logging with retention (default: false)

### Enhanced Features

- **Structured Logging**: Auto-detection of log formats (human, JSON, structured)
- **Config Reload**: Signal-based (SIGHUP) and manual config reload
- **Color Control**: Enhanced NO_COLOR support and TTY detection
- **Error Formatting**: VSCode-compatible file references
- **Daemon Mode**: Background process support
- **Progress Indicators**: Progress bars and spinners
- **Pager Integration**: Automatic paging for long output
- **Resource Limits**: Memory and CPU usage monitoring
- **Deprecation Policy**: Legacy deprecation warnings

## Migration Steps

### Step 1: Backup Your Existing CLI

```bash
# Backup your project
cp -r your-cli your-cli.backup
```

### Step 2: Regenerate from New Template

Use copier to regenerate your CLI with the new template:

```bash
# Navigate to your project directory
cd your-cli

# Regenerate with copier (answer prompts to match your existing setup)
copier copy /path/to/levonk-base-boilerplate/apps/cli/python/core .
```

### Step 3: Compare and Merge Changes

Review the generated files and merge your custom changes:

```bash
# Use git to see differences
git diff
```

Key files to review:
- `src/{{ project_slug }}/__main__.py` - Main CLI logic
- `src/{{ project_slug }}/config.py` - Configuration management (if enabled)
- `src/{{ project_slug }}/logging.py` - Logging enhancements
- `tests/` - New test files

### Step 4: Update Dependencies

The new template may require additional dependencies. Update your `pyproject.toml` or `requirements.txt`:

```bash
# Install new dependencies
pip install -r requirements.txt
# or
pip install -e .
```

### Step 5: Test Your CLI

Run your existing tests to ensure compatibility:

```bash
pytest tests/
```

### Step 6: Enable New Features (Optional)

If you want to use new features, regenerate with the appropriate options:

```bash
# Example: Enable TUI mode
copier copy /path/to/levonk-base-boilerplate/apps/cli/python/core . \
  --data include_tui=true
```

## Breaking Changes

**None** - All new features are opt-in via template options. Existing functionality remains unchanged when using default template options.

## Feature Compatibility

| Feature | Old Template | New Template | Migration Action |
|---------|-------------|--------------|------------------|
| Basic CLI | ✅ | ✅ | No action needed |
| Help/Version | ✅ | ✅ | No action needed |
| Stdin Processing | ✅ | ✅ | No action needed |
| Globbing | ✅ | ✅ | No action needed |
| JSON Output | ✅ | ✅ | No action needed |
| Exit Codes | ✅ | ✅ | No action needed |
| Shell Completion | ✅ | ✅ | No action needed |
| Color Control | ✅ | ✅ | Enhanced (NO_COLOR support) |
| Error Formatting | ✅ | ✅ | Enhanced (VSCode-compatible) |
| Advanced Config | ❌ | ✅ (opt-in) | Enable via `include_advanced_config` |
| TUI Mode | ❌ | ✅ (opt-in) | Enable via `include_tui` |
| Health Check | ❌ | ✅ (opt-in) | Enable via `include_health_check` |
| Privacy Mode | ❌ | ✅ (opt-in) | Enable via `include_privacy` |
| Audit Logging | ❌ | ✅ (opt-in) | Enable via `include_audit` |
| Daemon Mode | ❌ | ✅ (opt-in) | Enable via `include_daemon` |
| Config Reload | ❌ | ✅ (opt-in) | Enable via `include_advanced_config` |
| Progress Indicators | ❌ | ✅ (opt-in) | Included in new template |
| Pager Integration | ❌ | ✅ (opt-in) | Included in new template |

## Rollback

If you encounter issues, you can rollback to your backup:

```bash
# Remove the regenerated files
rm -rf your-cli

# Restore from backup
mv your-cli.backup your-cli
```

## Support

If you encounter migration issues:

1. Check the [README.md](README.md) for feature documentation
2. Review the [copier.yml](copier.yml) for template options
3. Open an issue with your migration steps and error messages

## Testing Checklist

After migration, verify:

- [ ] All existing tests pass
- [ ] CLI help output works: `your-cli --help`
- [ ] Version command works: `your-cli --version`
- [ ] Basic file processing works: `your-cli file.txt`
- [ ] Stdin processing works: `cat file.txt | your-cli -`
- [ ] JSON output works: `your-cli file.txt --json`
- [ ] Exit codes are correct for error cases
- [ ] Shell completion works (if installed)

## Next Steps

After successful migration:

1. Review new features in the [README.md](README.md)
2. Enable optional features that match your needs
3. Update your documentation to reflect new capabilities
4. Consider adding new tests for enabled features
