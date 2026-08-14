# Configuration

## Project-Level Configuration
Create `.quality-validator.json` in project root:

```json
{
  "languages": ["javascript", "rust"],
  "phases": {
    "lint": {
      "enabled": true,
      "fail_on_error": true
    },
    "format": {
      "enabled": true,
      "auto_fix": true
    },
    "test": {
      "enabled": true,
      "coverage": true
    },
    "security": {
      "enabled": true,
      "audit_dependencies": true
    }
  },
  "custom": {
    "pre_commands": ["npm install"],
    "post_commands": ["npm run build"]
  }
}
```

## Language-Specific Settings

### JavaScript/TypeScript
```json
{
  "javascript": {
    "eslint_config": ".eslintrc.js",
    "prettier_config": ".prettierrc",
    "test_command": "npm test",
    "coverage_command": "npm run coverage"
  }
}
```

### Rust
```json
{
  "rust": {
    "clippy_args": ["--deny", "warnings"],
    "format_check": true,
    "test_command": "cargo test",
    "audit_command": "cargo audit"
  }
}
```
