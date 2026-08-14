# Architecture Overview

The ai-development-loop skill uses an orchestrator pattern to delegate to language-specific helpers, ensuring clean separation of concerns and avoiding code duplication.

**Orchestrator Pattern:**
```bash
# Orchestrator Script
detect_project_type() → get_helper_script() → execute helper_script "$@"
```

**Language-Specific Helpers:**
- **`dev-loop-helper.sh`**: Generic development loop with comprehensive environment support
- **`node-loop-helper.sh`**: Node.js-specific logic (package manager detection, justfile generation)
- **`python-loop-helper.sh`**: Python-specific logic (Poetry, pipenv, uv, requirements.txt)
- **`rust-loop-helper.sh`**: Rust-specific logic (Cargo, clippy, justfile)
- **`go-loop-helper.sh`**: Go-specific logic (go mod, build, test)
- **`cmake-loop-helper.sh`**: CMake-specific logic
- **`make-loop-helper.sh`**: Makefile-specific logic

**Priority Order:**
1. **Project Type Detection**: `detect_project_type()` determines project language
2. **Helper Selection**: `get_helper_script()` selects appropriate helper
3. **Delegation**: `execute helper_script "$@"` delegates all arguments

**Language-Specific Features:**
- **Node.js**: Package manager detection (pnpm, yarn, npm), justfile generation
- **Python**: Package manager detection (Poetry, pipenv, uv), virtual environments
- **Rust**: Cargo integration, clippy linting, workspace management
- **Go**: Go mod support, build/test commands, workspace management

### Benefits

- **Clean Separation**: Each language has its own helper with domain-specific logic
- **Maintainability**: Changes to language logic only affect one file
- **Extensibility**: Easy to add new language helpers
- **Performance**: No need to parse multiple project types in one script
- **Consistency**: Language-specific best practices in each helper

### Usage Examples**

```bash
# Generic loop (auto-detects project type)
./scripts/orchestrator.sh loop

# Language-specific loop (explicit)
./scripts/orchestrator.sh smart-loop

# Environment info
./scripts/orchestrator.sh env

# Language-specific loop (explicit)
./scripts/node-loop-helper.sh loop
./scripts/python-loop-helper.sh loop
./scripts/rust-loop-helper.sh loop
```

### Loop Architecture

The system uses a three-tier architecture:

1. **Generic Loop (`dev-loop-helper.sh`)** - Discovers and runs justfile targets
2. **Language Helpers (`node-loop-helper.sh`)** - Language-specific logic and justfile generation
3. **Project Adopter** - Creates project-appropriate justfiles

### Standard Loop Targets

The loop expects these standard targets in justfiles:
- `install` - Install dependencies
- `build` - Build the project
- `lint` - Run linting
- `test` - Run tests
- `dev` - Start development server
- `e2e` - Run end-to-end tests

The loop fails fast if any target fails, allowing quick iteration and fixes.
