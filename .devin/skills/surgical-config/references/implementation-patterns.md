# Implementation Patterns

## Pattern 1: Additive Configuration

Always prefer adding to existing configuration rather than replacing:

```bash
# GOOD: Use surgical-edit.sh for intelligent tool selection
./scripts/surgical-edit.sh devbox.json '.packages += ["new-package"] | .packages | sort'

# AVOID: Overwrite entire packages array
```

## Pattern 2: Idempotent Operations

Design changes that are safe to run multiple times:

```bash
# GOOD: Let surgical-edit.sh handle checking and adding
./scripts/surgical-edit.sh package.json '.dependencies += {"serde": "1.0"}'

# AVOID: Manual duplicate additions
```

## Pattern 3: Preservation of User Content

Maintain user comments, formatting, and customizations:

```bash
# surgical-edit.sh automatically preserves comments and formatting using yq-go
# Falls back gracefully while maintaining structure
# Avoid tools that strip formatting
```

## Common Configuration File Patterns

### Package Management Files

- **package.json**: Use `surgical-edit.sh` for dependency management
- **Cargo.toml**: Use `surgical-edit.sh` for crate dependencies
- **requirements.txt**: Use `surgical-edit.sh` for simple additions
- **go.mod**: Use `go mod` commands instead of direct editing

### Development Environment Files

- **devbox.json**: Use `surgical-edit.sh` for package and shell modifications
- **docker-compose.yml**: Use `surgical-edit.sh` for service configuration
- **.env files**: Use `surgical-edit.sh` for variable updates
- **Makefile**: Use `surgical-edit.sh` for rule modifications

### Build Configuration Files

- **tsconfig.json**: Use `surgical-edit.sh` for compiler options
- **webpack.config.js**: Use `surgical-edit.sh` for plugin additions
- **CMakeLists.txt**: Use `surgical-edit.sh` for target modifications

## Enhanced Backup Strategy

All modifications use mirrored directory tree backups:

```bash
# Backup path structure
${REPO_ROOT}/.cache/${MIRRORED_PATH}/${FILE_NAME}.YYYYMMDDHHmmss

# Example:
# Original: /home/user/project/config/package.json
# Backup:  /home/user/project/.cache/home/user/project/config/package.json.20250202203900
```

## Configuration Management Operations

This Skill supports comprehensive configuration operations through both tools:

### Core Operations

- **set** - Set value at path (creates path if needed)
- **set-if-value** - Set only if current value equals expected
- **array-add** - Add value to array (ifMissing|always modes)
- **array-remove** - Remove value from array (ifPresent|all|single modes)
- **object-set** - Set object[key] (always|ifMissing|ifValue modes)
- **object-remove** - Remove object[key] (always|ifValue modes)

### Dependency Management

Available through both tools with different approaches:

**surgical-edit.sh**: Direct dependency manipulation

```bash
./scripts/surgical-edit.sh package.json '.dependencies += {"express": "^4.18.0"}'
```

**manage-config.mjs**: Structured dependency management

- **add** - Add/update dependencies
- **remove** - Remove dependencies
- **dependency-type** - runtime vs devDependency
- **package-manager** - package.json, Cargo.toml, etc.

### Validation Operations

- **validate** - Check if settings exist and have expected values
- **schema-check** - Validate against JSON schema if available
- **syntax-check** - Verify file format validity

## Context-Aware Editing Examples

```bash
# Node.js project - detect and edit appropriately
if [[ "$build_systems" == *"npm"* ]]; then
    # Check for existing package.json
    if [[ -f "package.json" ]]; then
        # Apply surgical edit preserving npm structure
        ./scripts/surgical-edit.sh package.json '.scripts += {"config:surgical": "./scripts/surgical-edit.js"}'
    fi
fi

# Rust project - detect and edit appropriately
if [[ "$build_systems" == *"cargo"* ]]; then
    # Check for existing Cargo.toml
    if [[ -f "Cargo.toml" ]]; then
        # Apply surgical edit preserving Cargo structure
        ./scripts/surgical-edit.sh Cargo.toml '.dependencies += {"surgical-config": "0.1.0"}'
    fi
fi

# Python project - detect and edit appropriately
if [[ "$build_systems" == *"poetry"* ]]; then
    # Check for pyproject.toml
    if [[ -f "pyproject.toml" ]]; then
        # Apply surgical edit preserving Poetry structure
        ./scripts/surgical-edit.sh pyproject.toml '.dependencies += {"surgical-config": "^0.1.0"}'
    fi
fi
```
