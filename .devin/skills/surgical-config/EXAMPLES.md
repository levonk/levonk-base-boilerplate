# Surgical Configuration Examples

This document provides practical examples of applying the surgical hierarchy approach to common configuration management scenarios.

## Package Management Examples

### Adding Dependencies to package.json

```bash
# Before: Monolithic approach (AVOID)
cat > package.json << 'EOF'
{
  "name": "my-app",
  "version": "1.0.0",
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF

# After: Surgical approach (PREFERRED)
./scripts/surgical-edit.sh package.json '.dependencies += {"lodash": "^4.17.21", "cors": "^2.8.5"}'
```

### Updating Cargo.toml Dependencies

```bash
# Add new dependencies without touching existing ones
./scripts/surgical-edit.sh Cargo.toml '.dependencies += {"tokio": {version = "1.0", features = ["full"]}}'
./scripts/surgical-edit.sh Cargo.toml '.dev-dependencies += {"tokio-test": "0.4"}'
```

### Managing Python Requirements

```bash
# For simple requirements.txt (line-based)
./scripts/surgical-edit.sh requirements.txt 'old_pattern' 'requests>=2.28.0'

# For pyproject.toml (structured)
./scripts/surgical-edit.sh pyproject.toml '.dependencies += ["requests>=2.28.0"]'
```

## Development Environment Examples

### Updating devbox.json Packages

```bash
# Add development packages
./scripts/surgical-edit.sh devbox.json '.packages += ["nodejs", "python", "rust"]'

# Update shell initialization
./scripts/surgical-edit.sh devbox.json '.shell.init_hook = "export NODE_ENV=development"'
```

### Modifying Docker Compose Configuration

```bash
# Update service port
./scripts/surgical-edit.sh docker-compose.yml '.services.web.ports = ["8080:80"]'

# Add environment variables
./scripts/surgical-edit.sh docker-compose.yml '.services.web.environment += {"DEBUG": "true", "LOG_LEVEL": "info"}'

# Add volume mounts
./scripts/surgical-edit.sh docker-compose.yml '.services.web.volumes += ["./src:/app/src"]'
```

### Updating Environment Files

```bash
# For .env files (simple text-based)
./scripts/surgical-edit.sh .env 'DATABASE_URL=.*' 'DATABASE_URL=postgresql://localhost:5432/myapp'

# Add new environment variable
./scripts/surgical-edit.sh .env 'end_of_file' 'REDIS_URL=redis://localhost:6379'
```

## Build Configuration Examples

### TypeScript Configuration Updates

```bash
# Update compiler options
./scripts/surgical-edit.sh tsconfig.json '.compilerOptions.target = "ES2020"'
./scripts/surgical-edit.sh tsconfig.json '.compilerOptions.strict = true'

# Add new include paths
./scripts/surgical-edit.sh tsconfig.json '.include += ["src/**/*.ts", "types/**/*.d.ts"]'
```

### Webpack Configuration Modifications

```bash
# For webpack.config.js (JavaScript - use pattern replacement)
./scripts/surgical-edit.sh webpack.config.js 'module.exports = {:[config]}' 'module.exports = {:[config],\n  devtool: "source-map"}'

# Add new loader configuration
./scripts/surgical-edit.sh webpack.config.js 'rules: [:[rules]]' 'rules: [:[rules],\n    {\n      test: /\.scss$/,\n      use: ["style-loader", "css-loader", "sass-loader"]\n    }]'
```

## Code Pattern Examples

### Adding Serde Derives to Rust Structs

```bash
# Use surgical-edit.sh for structural code changes
./scripts/surgical-edit.sh src/main.rs 'struct :[name] {:[body]}' '#[derive(Serialize, Deserialize)]\nstruct :[name] {:[body]}'
```

### Updating Import Statements

```bash
# Add new imports to Python files
./scripts/surgical-edit.sh src/main.py 'import :[imports]' 'import :[imports]\nfrom typing import Optional'

# For JavaScript/TypeScript
./scripts/surgical-edit.sh src/main.ts 'import {:[imports]} from ":[module]"' 'import {:[imports]} from ":[module]"\nimport { Logger } from "winston"'
```

## Complex Multi-Tool Examples

### Scenario: Full Stack Application Setup

```bash
# 1. Update package.json (semantic parser)
./scripts/surgical-edit.sh package.json '.dependencies += {"express": "^4.18.0", "mongoose": "^6.0.0"}'

# 2. Update Docker configuration (semantic parser)
./scripts/surgical-edit.sh docker-compose.yml '.services.api.build = "."'
./scripts/surgical-edit.sh docker-compose.yml '.services.api.ports = ["3000:3000"]'

# 3. Add environment variables (text-based)
./scripts/surgical-edit.sh .env 'end_of_file' 'MONGODB_URI=mongodb://localhost:27017/myapp'
./scripts/surgical-edit.sh .env 'end_of_file' 'PORT=3000'

# 4. Update TypeScript config (semantic parser)
./scripts/surgical-edit.sh tsconfig.json '.compilerOptions.outDir = "./dist"'
./scripts/surgical-edit.sh tsconfig.json '.include += ["src/**/*.ts"]'
```

### Scenario: Rust Project Enhancement

```bash
# 1. Add dependencies (semantic parser)
./scripts/surgical-edit.sh Cargo.toml '.dependencies += {"tokio": {version = "1.0", features = ["full"]}}'
./scripts/surgical-edit.sh Cargo.toml '.dependencies += {"serde": {version = "1.0", features = ["derive"]}}'

# 2. Add derives to structs (structural rewriter)
./scripts/surgical-edit.sh src/main.rs 'struct :[name] {:[body]}' '#[derive(Serialize, Deserialize)]\nstruct :[name] {:[body]}'

# 3. Update main function (text-based for simple changes)
./scripts/surgical-edit.sh src/main.rs 'fn main()' '#[tokio::main]\nasync fn main()'
```

## Error Handling Examples

### Safe Dependency Addition

```bash
# Check if dependency exists before adding (surgical-edit.sh handles this automatically)
./scripts/surgical-edit.sh package.json '.dependencies += {"express": "^4.18.0"}'

# Manual checking (if needed)
if ! ./scripts/surgical-edit.sh package.json '.dependencies | has("express")' 2>/dev/null; then
  ./scripts/surgical-edit.sh package.json '.dependencies += {"express": "^4.18.0"}'
  echo "Added express dependency"
else
  echo "Express dependency already exists"
fi
```

### Configuration Validation

```bash
# Validate JSON after modification (surgical-edit.sh does this automatically)
if ./scripts/surgical-edit.sh package.json '.' >/dev/null 2>&1; then
  echo "package.json is valid"
else
  echo "ERROR: Invalid JSON in package.json"
  exit 1
fi

# Validate YAML configuration
if ./scripts/surgical-edit.sh docker-compose.yml '.' >/dev/null 2>&1; then
  echo "docker-compose.yml is valid"
else
  echo "ERROR: Invalid YAML in docker-compose.yml"
  exit 1
fi
```

### Backup and Rollback

```bash
# Create backup before modification (surgical-edit.sh does this automatically)
cp package.json package.json.backup

# Apply changes
./scripts/surgical-edit.sh package.json '.version = "1.1.0"'

# Test changes
if npm test >/dev/null 2>&1; then
  echo "Changes validated successfully"
else
  echo "Rolling back changes"
  cp package.json.backup package.json
  exit 1
fi
```

## Integration Examples

### With Git Hooks

```bash
# Pre-commit hook to validate configurations
#!/bin/bash
# .git/hooks/pre-commit

echo "Validating configuration files..."

for file in package.json tsconfig.json docker-compose.yml; do
  if [ -f "$file" ]; then
    if ! ./scripts/surgical-edit.sh "$file" '.' >/dev/null 2>&1; then
      echo "ERROR: Invalid $file"
      exit 1
    fi
  fi
done

echo "All configuration files valid"
```

### With CI/CD Pipeline

```bash
# GitHub Actions step
- name: Validate Configurations
  run: |
    echo "Validating all configuration files..."
    find . -name "*.json" -o -name "*.yml" -o -name "*.yaml" | while read file; do
      if ! ./scripts/surgical-edit.sh "$file" '.' >/dev/null 2>&1; then
        echo "ERROR: Invalid configuration in $file"
        exit 1
      fi
    done
```

## Best Practices Summary

1. **Always prefer semantic parsers** (yq-go) for structured files
2. **Use structural rewriters** (comby, ast-grep) for code patterns
3. **Apply text utilities** (sd, echo) only for simple line operations
4. **Validate after every modification**
5. **Create backups before complex changes**
6. **Test idempotency** by running changes twice

### XML Files and Templates

**Common Uses**: XML configuration, Android manifests, Maven POMs, Spring configuration

**Recommended Tool**: yq-go (preserves comments and formatting)

**Examples**:
```bash
# Update XML configuration
./scripts/surgical-edit.sh config.xml '.config.port = 8080'

# Add element to XML
./scripts/surgical-edit.sh services.xml '.services += {"web": {"port": 8080}}'

# Process XML template
# config.xml.jinja -> process with jinja2 -> surgical-edit.sh edit
```

### Template Files (Multiple Formats)

**Common Uses**: Configuration templates, Kubernetes manifests, Docker Compose templates

**Examples**:
```bash
# Process JSON template
jinja2 config.json.jinja -D version="1.0.0" > config.json
./scripts/surgical-edit.sh config.json '.version = "1.0.0"'

# Process YAML template
jinja2 docker-compose.yml.jinja -D env="production" > docker-compose.yml
./scripts/surgical-edit.sh docker-compose.yml '.services.web.environment.ENV = "production"'

# Process XML template
jinja2 config.xml.jinja -D debug="true" > config.xml
./scripts/surgical-edit.sh config.xml '.config.debug = true'

# Process INI template
jinja2 app.conf.jinja -D log_level="info" > app.conf
./scripts/surgical-edit.sh app.conf 'log_level=.*' 'log_level=info'
```

### Markup Files

**Common Uses**: Documentation, README files, technical writing

**Examples**:
```bash
# Update Markdown frontmatter
./scripts/surgical-edit.sh README.md 'title: .*' 'title: "New Title"'

# Update RST metadata
./scripts/surgical-edit.sh docs/index.rst ':version: .*' ':version: 2.0.0'

# Update LaTeX metadata
./scripts/surgical-edit.sh document.txt '\\\\title{.*}' '\\\\title{New Title}'
```

### Data Files (CSV/TSV)

**Common Uses**: Data exports, configuration data, tabular data

**Examples**:
```bash
# Update CSV header
./scripts/surgical-edit.sh data.csv 'old_column' 'new_column'

# Update specific values
./scripts/surgical-edit.sh data.csv 'old_value' 'new_value'

# Process TSV files
./scripts/surgical-edit.sh data.tsv 'old_value' 'new_value'
```

### Binary Configuration Files

**Common Uses**: macOS plist files, application configuration
**Examples**:
```bash
# Validate plist file
plutil -lint config.plist

# Convert plist to JSON for editing
plutil -convert json config.plist - | jq '.key = "value"' | plutil -convert json - -o config.plist

# Manual binary editing (last resort)
xxd config.plist | sed 's/old_pattern/new_pattern/' | xxd -r > config.plist
```

### Expanded File Type Support

The enhanced surgical-config Skill now supports:

- **Templated Structured**: `*.json.jinja`, `*.yaml.jinja`, `*.xml.jinja`, `*.cfg.jinja`, etc.
- **Structured**: `*.json`, `*.yaml`, `*.toml`, `*.xml`
- **Code**: `*.rs`, `*.js`, `*.ts`, `*.py`, `*.go`, `*.java`, `*.php`, `*.rb`, etc.
- **Configuration**: `*.env`, `*.conf`, `*.ini`, `*.cfg`, `*.properties`, `*.tfvars`, `*.hcl`
- **Markup**: `*.md`, `*.rst`, `*.tex`, `*.adoc`
- **Data**: `*.csv`, `*.tsv`
- **Binary Configs**: `*.plist`, `*.binary`

Each file type is automatically detected and processed with the appropriate tool from the hierarchy.
7. **Preserve user content** like comments and formatting
