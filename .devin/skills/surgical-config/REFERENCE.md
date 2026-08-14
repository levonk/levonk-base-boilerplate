# Surgical Configuration Reference

This document provides comprehensive reference material for the surgical hierarchy approach to configuration management.

## Tool Reference

### Primary Interface: surgical-edit.sh

**Purpose**: Intelligent file type detection and automatic tool selection for surgical configuration modifications

**Usage**:
```bash
# Basic usage
./scripts/surgical-edit.sh <file> <operation>

# Project-aware editing
./scripts/surgical-edit.sh --detect-project <file> <operation>

# Pattern replacement for code files
./scripts/surgical-edit.sh <file> <pattern> <replacement>
```

**Features**:
- Automatic file type detection
- Intelligent tool selection from hierarchy
- Project-aware editing with detection integration
- Automatic backup creation
- Validation and rollback on failure
- Loop prevention for nested calls

**Advantages**:
- Single interface for all configuration editing
- No need to know underlying tools
- Automatic fallback when preferred tools unavailable
- Preserves comments and formatting when possible
- Handles complex file type detection

**Underlying Tool Hierarchy**:
The script automatically selects tools from the following hierarchy based on file type and availability:

### Semantic Parsers

#### jq
**Purpose**: JSON processor and data formatter

**Installation**:
```bash
# Package managers
sudo apt install jq
brew install jq

# From source
git clone https://github.com/stedolan/jq.git
cd jq && autoreconf -fi && ./configure && make && sudo make install
```

**Common Operations**:
```bash
# Read values (handled automatically by surgical-edit.sh)
./scripts/surgical-edit.sh docker-compose.json '.services.web.port'

# Update values (preserves comments when using yq-go)
./scripts/surgical-edit.sh docker-compose.json '.services.web.port = 8080'

# Add array elements
./scripts/surgical-edit.sh package.json '.packages += ["nodejs", "rust"]'

# Filter and transform
./scripts/surgical-edit.sh package.json '.dependencies | to_entries | map(select(.value | startswith("@")))'
```

**Advantages**:
- Powerful JSON processing capabilities
- Extensive filtering and transformation features
- Widely available and well-documented
- Fast and efficient

**Limitations**:
- **JSON only** (no YAML, TOML, etc.)
- **Does not preserve comments or formatting**
- Recreates files (loses original structure)
- Not suitable for configuration files with comments

**Use Case**: Primary semantic parser for structured formats. **Note**: surgical-edit.sh prioritizes yq-go as the preferred tool for JSON, YAML, TOML, and XML files due to its comment preservation capabilities.

#### jo
**Purpose**: JSON output from shell/command-line

**Installation**:
```bash
# Package managers
sudo apt install jo
brew install jo

# Cargo
cargo install jo
```

**Usage**:
```bash
# Create JSON objects
jo name=John age=30 city="New York"
# Output: {"name":"John","age":30,"city":"New York"}

# Create arrays
jo -a apple banana cherry
# Output: ["apple","banana","cherry"]

# Nested objects
jo name=John $(jo address street="123 Main" city="NYC")
# Output: {"name":"John","address":{"street":"123 Main","city":"NYC"}}
```

**Advantages**:
- Simple JSON creation from shell
- Good for generating JSON data
- Lightweight and fast

**Limitations**:
- Creation only (no editing existing files)
- Limited complex structure support
- Not for configuration file editing

**Use Case**: JSON creation from shell. **Note**: surgical-edit.sh uses jo internally for JSON creation operations when needed.

#### dot-json
**Purpose**: JSON manipulation with dot notation

**Installation**:
```bash
# npm
npm install -g dot-json

# Cargo
cargo install dot-json
```

**Usage**:
```bash
# Set values
dot-json set package.json version 1.0.0

# Get values
dot-json get package.json version

# Delete keys
dot-json delete package.json deprecated

# Merge objects
dot-json merge package.json update.json
```

**Advantages**:
- Simple dot notation interface
- Direct file editing
- Good for simple key-value operations

**Limitations**:
- Limited to basic operations
- Less powerful than jq for complex transformations
- May not preserve formatting

**Use Case**: Simple dot notation interface. **Note**: surgical-edit.sh may use dot-json for simple key-value operations when yq-go is unavailable.

#### yq-go
**Purpose**: Format-aware, structure-preserving modifications for JSON, YAML, TOML, XML

**Installation**:
```bash
# Go install
go install github.com/mikefarah/yq/v4@latest

# Package managers
brew install yq
sudo apt install yq
```

**Common Operations**:
```bash
# Read values (handled by surgical-edit.sh)
./scripts/surgical-edit.sh docker-compose.yml '.services.web.port'

# Update values
./scripts/surgical-edit.sh docker-compose.yml '.services.web.port = 8080'

# Add array elements
./scripts/surgical-edit.sh devbox.json '.packages += ["nodejs", "rust"]'

# Add object properties
./scripts/surgical-edit.sh package.json '.dependencies += {"express": "^4.18.0"}'

# Conditional updates
./scripts/surgical-edit.sh config.yml 'select(.environment == "production") | .debug = false'

# Merge configurations
./scripts/surgical-edit.sh config.yml '. * load("override.yml")'
```

**Supported Formats**:
- JSON (.json)
- YAML (.yml, .yaml)
- TOML (.toml)
- XML (.xml)

**Advantages**:
- Preserves comments and formatting
- Understands data structure
- Type-aware operations
- Idempotent operations

**Limitations**:
- Limited to supported formats
- Complex queries can be verbose
- Performance on very large files

### Structural Rewriters

#### comby
**Purpose**: Pattern-based code transformations with structural awareness

**Installation**:
```bash
# Download binary
curl -L https://github.com/comby-tools/comby/releases/latest/download/comby-linux-x64.tar.gz | tar xz
sudo mv comby-linux-x64/comby /usr/local/bin/

# Package managers
brew install comby
```

**Pattern Syntax**:
```bash
# Basic pattern matching (handled by surgical-edit.sh)
./scripts/surgical-edit.sh src/main.rs 'println!(:[args])' 'log::info!(:[args])'

# Structural patterns
./scripts/surgical-edit.sh src/main.rs 'struct :[name] {:[body]}' '#[derive(Serialize, Deserialize)]\nstruct :[name] {:[body]}'

# Import patterns
./scripts/surgical-edit.sh src/main.ts 'import {:[imports]} from ":[module]"' 'import {:[imports]} from ":[module]"\nimport { Logger } from "winston"'
```

**Metavariables**:
- `:[name]` - Identifier matching
- `:[...]` - Multi-line content
- `:[args]` - Function arguments
- `:[body]` - Block content

**Advantages**:
- Language-agnostic patterns
- Preserves formatting
- Handles nested structures
- Safe transformations

**Limitations**:
- Learning curve for patterns
- Limited to text-based structures
- Performance on large codebases

**Use Case**: Language-agnostic pattern transformations. **Note**: surgical-edit.sh uses comby for code pattern transformations when structural editing is needed.

#### ast-grep
**Purpose**: AST-based code transformations with semantic understanding

**Installation**:
```bash
# npm
npm install -g ast-grep

# Cargo
cargo install ast-grep
```

**Configuration Files**:
```yaml
# add-serde-derive.yml
rule:
  pattern: struct $NAME {
    $BODY
  }
  fix: |-
    #[derive(Serialize, Deserialize)]
    struct $NAME {
      $BODY
    }
```

**Usage**:
```bash
# Apply rule (surgical-edit.sh may use ast-grep for complex patterns)
./scripts/surgical-edit.sh src/ --rule add-serde-derive.yml

# Inline pattern (surgical-edit.sh handles ast-grep integration)
./scripts/surgical-edit.sh src/ --pattern 'console.log($MSG)' --rewrite 'console.info($MSG)'
```

**Advantages**:
- True AST understanding
- Language-specific semantics
- Precise transformations
- Type awareness

**Limitations**:
- Language-specific rules required
- Complex setup
- Limited language support

**Use Case**: AST-based semantic transformations. **Note**: surgical-edit.sh may use ast-grep for language-specific semantic changes when available.

### Patch Managers

#### quilt
**Purpose**: Managed patch application with version control integration

**Installation**:
```bash
# Package managers
sudo apt install quilt
brew install quilt

# From source
git clone https://github.com/quilt-dev/quilt.git
cd quilt && make && sudo make install
```

**Workflow**:
```bash
# Initialize quilt
quilt init

# Create new patch
quilt new add-feature-x.patch

# Edit files
quilt edit config/file.json
# Make changes...

# Refresh patch
quilt refresh

# Apply patches
quilt push -a

# Pop patches
quilt pop -a
```

**Configuration**:
```bash
# ~/.quiltrc
QUILT_DIFF_OPTS="-p"
QUILT_PATCH_OPTS="--unified"
QUILT_DIFF_ARGS="--no-color"
```

#### guilt
**Purpose**: Git-based patch management system

**Installation**:
```bash
# Package managers
sudo apt install guilt
brew install guilt

# From source
git clone https://github.com/jeffpc/guilt.git
cd guilt && make && sudo make install
```

**Usage**:
```bash
# Initialize guilt in git repo
guilt-init

# Create new patch
guilt-new my-patch.patch

# Start working on patch
guilt-push

# Make changes...
git add modified-files
guilt-refresh

# Apply all patches
guilt-push -a

# Pop patches
guilt-pop -a
```

**Advantages**:
- Git-native patch management
- Works with git branches
- Patch series management
- Rollback capability

**Limitations**:
- Requires git repository
- Complex workflow
- Learning curve

### Template Processing

#### jinja2-cli
**Purpose**: Process Jinja2 templated files

**Installation**:
```bash
# pip
pip install jinja2-cli

# Package managers
sudo apt install python3-jinja2
brew install jinja2-cli
```

**Usage**:
```bash
# Process template with variables
jinja2 config.json.jinja -D version="1.0.0" -D debug=true

# Process with environment variables
jinja2 config.json.jinja -e

# Process with YAML context file
jinja2 config.json.jsla context.yml
```

#### envsubst
**Purpose**: Environment variable substitution

**Installation**:
```bash
# Usually included with gettext
echo $PATH | grep -q gettext || sudo apt install gettext

# macOS (included with base system)
which envsubst || brew install gettext
```

**Usage**:
```bash
# Basic environment substitution
export VERSION=1.0.0
envsubst < config.template.json > config.json

# With specific variables
envsubst '$VERSION $DEBUG' < config.template.json > config.json
```

#### sd
**Purpose**: Modern sed replacement with regex support

**Installation**:
```bash
# Cargo
cargo install sd

# Package managers
brew install sd
sudo apt install sd
```

**Usage**:
```bash
# Simple substitution (handled by surgical-edit.sh)
./scripts/surgical-edit.sh config.txt 'old_value' 'new_value'

# Regex patterns
./scripts/surgical-edit.sh config.conf 'port\s*=\s*\d+' 'port = 8080'

# Multiple files (surgical-edit.sh handles file iteration)
for file in *.env; do
  ./scripts/surgical-edit.sh "$file" 'DEBUG=false' 'DEBUG=true'
done

# Preview changes (surgical-edit.sh may support preview mode)
./scripts/surgical-edit.sh --preview file.txt 'old' 'new'
```

**Advantages**:
- Simple syntax
- Regex support
- Preview mode
- Fast operations

**Limitations**:
- No structure awareness
- Can break file formats
- Limited to text operations

**Use Case**: Modern text replacement. **Note**: surgical-edit.sh uses sd as the primary text utility for simple substitutions when semantic parsing isn't required.

## Best Practices

### 1. Tool Selection Hierarchy

Always follow this order when choosing tools:

1. **surgical-edit.sh** - Primary interface (handles automatic tool selection)
2. **yq-go** - Preferred underlying tool for structured formats
3. **comby** - For code pattern transformations
4. **ast-grep** - For language-specific semantic changes
5. **sd** - For simple text substitutions
6. **quilt** - For complex, version-controlled changes

### 2. Idempotent Operations

Design changes that are safe to run multiple times:

```bash
# surgical-edit.sh handles checking automatically
./scripts/surgical-edit.sh package.json '.dependencies += {"package": "version"}'

# Manual checking (if needed)
if ! ./scripts/surgical-edit.sh package.json '.dependencies | has("package")' 2>/dev/null; then
  ./scripts/surgical-edit.sh package.json '.dependencies += {"package": "version"}'
fi

# Use set operations for arrays
./scripts/surgical-edit.sh config.json '.packages |= . + ["new"] | .packages | sort | unique'
```

### 3. Backup and Recovery

Always create backups before modifications:

```bash
# surgical-edit.sh creates automatic backups
./scripts/surgical-edit.sh package.json '.version = "1.0.0"'

# Manual backup (if needed)
backup_file() {
  local file="$1"
  local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$file" "$backup"
  echo "$backup"
}

# Validate and restore if needed
safe_edit() {
  local file="$1"
  local backup=$(backup_file "$file")

  # Apply changes with surgical-edit.sh
  ./scripts/surgical-edit.sh "$file" '.version = "1.1.0"'

  if ! validate_file "$file"; then
    cp "$backup" "$file"
    echo "Restored from backup due to validation failure"
    return 1
  fi
}
```

### 4. Validation

Always validate after modifications:

```bash
validate_json() {
  local file="$1"
  ./scripts/surgical-edit.sh "$file" '.' >/dev/null 2>&1
}

validate_yaml() {
  local file="$1"
  ./scripts/surgical-edit.sh "$file" '.' >/dev/null 2>&1
}

validate_toml() {
  local file="$1"
  ./scripts/surgical-edit.sh "$file" '.' >/dev/null 2>&1
}
```

### 5. Error Handling

Implement proper error handling:

```bash
#!/bin/bash

set -euo pipefail

edit_with_fallback() {
  local file="$1"
  local operation="$2"

  # surgical-edit.sh handles fallback automatically
  if ! ./scripts/surgical-edit.sh "$file" "$operation"; then
    echo "Surgical edit failed, trying manual approach"
    # Manual fallback would go here
    sd 'pattern' 'replacement' "$file"
  fi
}
```

## Integration Examples

### Git Hooks
```bash
#!/bin/sh
# .git/hooks/pre-commit

echo "Validating configuration files..."

for file in $(git diff --cached --name-only --diff-filter=AM | grep -E '\.(json|yml|yaml|toml)$'); do
  if ! ./scripts/surgical-edit.sh "$file" '.' >/dev/null 2>&1; then
    echo "ERROR: Invalid configuration in $file"
    exit 1
  fi
done

echo "All configuration files valid"
```

### CI/CD Pipeline
```yaml
# GitHub Actions
- name: Validate Configurations
  run: |
    echo "Checking all configuration files..."
    find . -name "*.json" -o -name "*.yml" -o -name "*.yaml" | while read file; do
      if ! ./scripts/surgical-edit.sh "$file" '.' >/dev/null 2>&1; then
        echo "ERROR: Invalid configuration in $file"
        exit 1
      fi
    done
```

### Makefile Integration
```makefile
.PHONY: validate-configs
validate-configs:
	@echo "Validating configuration files..."
	@find . -name "*.json" -o -name "*.yml" -o -name "*.yaml" | \
		while read file; do \
			if ! ./scripts/surgical-edit.sh "$file" . >/dev/null 2>&1; then \
				echo "ERROR: Invalid configuration in $$file"; \
				exit 1; \
			fi; \
		done

.PHONY: add-dep
add-dep:
	@if [ -z "$(PACKAGE)" ] || [ -z "$(VERSION)" ]; then \
		echo "Usage: make add-dep PACKAGE=name VERSION=x.y.z"; \
		exit 1; \
	fi
	@./scripts/surgical-edit.sh package.json '.dependencies += {"$(PACKAGE)": "$(VERSION)"}'
```

## Troubleshooting

### Common Issues

1. **yq-go not found**: Install yq-go or use alternative tools
2. **Invalid JSON/YAML**: Validate syntax before editing
3. **Permission denied**: Check file permissions
4. **Backup conflicts**: Use timestamped backups
5. **Pattern matching failures**: Test patterns with preview mode

### Debugging Tips

```bash
# Test surgical-edit operations without modifying files
./scripts/surgical-edit.sh --dry-run package.json '.dependencies'

# Preview changes (if supported)
./scripts/surgical-edit.sh --preview file.txt 'old' 'new'

# Validate file syntax
./scripts/surgical-edit.sh config.json '.' >/dev/null 2>&1 && echo "Valid" || echo "Invalid"
```

### Performance Considerations

- Use semantic parsers for large structured files
- Apply text utilities for simple substitutions
- Batch operations when possible
- Validate only changed files
- Use incremental backups for large files
