---
modeline: "vim: set ft=markdown:"
title: "ADR: Per-Language Configuration Scripts"
adr-id: "adr20260202002"
slug: "per-language-configuration-scripts"
url: "src/current/skills/software-dev/project-adopter/doc/adr-20260202002-per-language-configuration-scripts.md"
synopsis: "Organize configuration management by language rather than by file type for better maintainability and multi-language support"
author: "https://github.com/levonk"
date-created: "2026-02-02"
date-updated: "2026-02-02"
date-review: "2026-08-02"
date-triggers: ["2026-02-02"]
version: "1.0.0"
status: "accepted"
aliases: []
tags: [doc/architecture/adr, project-adopter, configuration, language-specific, multi-language]
supersedes: []
superseded-by: []
related-to: ["adr20260202001-two-mode-project-adoption-system"]
scope:
  impact-scope: ["project-adopter skill", "configuration scripts", "file management", "language detection"]
  excluded-scope: ["core detection logic", "devbox.json generation"]
---

# Decision Record: Per-Language Configuration Scripts

## Context

The project-adopter skill needs to configure multiple configuration files per language (package.json, Cargo.toml, pyproject.toml, etc.) while respecting the two-mode system (adopt vs standardize).

Initial approach considered per-file scripts, but this leads to:
- Conditional logic scattered throughout codebase
- Risk of disconnect between language identification and file handling
- Difficulty supporting multi-language projects
- Poor maintainability when adding new languages

## Constraints

- Must support both adopt and standardize modes
- Must handle multiple configuration files per language
- Must support multi-language projects
- Must be maintainable and extensible
- Must avoid conditional spaghetti code

## Decision

Organize configuration management by language rather than by file type:

```
project-adopter/scripts/
├── adopt-project.sh           # Main orchestrator
├── configure-nodejs.sh       # Node.js/TypeScript configs
├── configure-rust.sh          # Rust configs  
├── configure-python.sh        # Python configs
├── configure-go.sh            # Go configs
├── configure-java.sh          # Java configs
└── configure-generic.sh       # Fallback for unknown languages
```

## Rationale

### Advantages of Per-Language Approach

1. **No Conditionals Sprinkled Everywhere** - Clean separation of concerns
2. **Language Expertise Encapsulation** - Each script becomes language expert
3. **Multi-Language Support** - Natural handling of projects with mixed languages
4. **Maintainability** - Easier to update language-specific logic
5. **Testing Isolation** - Test each language's configuration separately
6. **Extensibility** - Easy to add new languages without touching existing code

### Comparison with Per-File Approach

| Aspect | Per-File | Per-Language |
|--------|-----------|---------------|
| Conditional Logic | Scattered everywhere | Contained in language scripts |
| Multi-Language Support | Complex coordination | Natural orchestration |
| Testing | Complex interdependencies | Isolated per language |
| Maintainability | High coupling | Low coupling |
| Extensibility | Risk of breaking existing | Safe additions |

## Technical Approach

### Main Orchestrator Flow
```bash
# Detect all languages in project
detected_languages=$(detect_project_languages "$project_path")

# Configure each detected language
for lang in $detected_languages; do
    case "$lang" in
        nodejs) configure_nodejs_project "$project_path" "$mode" ;;
        rust) configure_rust_project "$project_path" "$mode" ;;
        python) configure_python_project "$project_path" "$mode" ;;
        go) configure_go_project "$project_path" "$mode" ;;
        java) configure_java_project "$project_path" "$mode" ;;
        *) configure_generic_project "$project_path" "$mode" ;;
    esac
done
```

### Language Script Interface
```bash
# configure-nodejs.sh
configure_nodejs_project() {
    local project_path="$1"
    local mode="$2"           # adopt | standardize
    
    # Handle package.json
    configure_package_json "$project_path" "$mode"
    
    # Handle tsconfig.json
    configure_tsconfig_json "$project_path" "$mode"
    
    # Handle vite.config.js (if detected)
    if [[ -f "$project_path/vite.config.js" ]]; then
        configure_vite_config "$project_path" "$mode"
    fi
}
```

### Mode-Aware Configuration
```bash
configure_package_json() {
    local project_path="$1"
    local mode="$2"
    
    if [[ "$mode" == "standardize" ]]; then
        # Add comprehensive scripts, dependencies, config
        add_standardize_package_json_scripts "$project_path"
        add_standardize_package_json_deps "$project_path"
    else
        # Add minimal essential additions only
        add_adopt_package_json_scripts "$project_path"
    fi
}
```

## Affected Components

- **project-adopter/scripts/adopt-project.sh** - Main orchestrator
- **project-adopter/scripts/configure-*.sh** - New language-specific scripts
- **project-detection/scripts/detect-build-systems.sh** - Language detection
- **devbox.json generation** - Still handled centrally
- **justfile generation** - Still handled centrally

## Consequences

### Positive

- **Clean Architecture** - Each language is self-contained
- **Mode-Aware** - Each script respects adopt vs standardize
- **File-Specific Expertise** - Language scripts know their config files
- **No Conditional Spaghetti** - No if/elif chains everywhere
- **Easy Testing** - Test each language independently
- **Future-Proof** - Add new languages without touching existing code

### Negative

- **More Files** - Additional script files to maintain
- **Interface Consistency** - Need to maintain consistent interfaces across language scripts
- **Discovery Complexity** - Need to understand which script handles which files

### Neutral

- **Learning Curve** - Developers need to know which script to modify
- **Documentation Overhead** - Need to document each language script's capabilities

## Alternatives Considered

### Option A: Per-File Scripts
- **Pros**: Clear file ownership
- **Cons**: Conditional logic everywhere, poor multi-language support

### Option B: Single Monolithic Script
- **Pros**: Single file to maintain
- **Cons**: Massive conditional complexity, hard to test

### Option C: Configuration-Driven Approach
- **Pros**: Declarative configuration
- **Cons**: Complex DSL, harder to understand

## Rollout / Migration

1. **Phase 1**: Create language script templates
2. **Phase 2**: Implement configure-nodejs.sh as proof of concept
3. **Phase 3**: Migrate existing configuration logic to language scripts
4. **Phase 4**: Add remaining language scripts (rust, python, go, java)
5. **Phase 5**: Update main orchestrator to use language scripts
6. **Phase 6**: Add comprehensive testing for each language script

## To Investigate

- Should language scripts return status codes for success/failure?
- Should we have a standard interface specification for language scripts?
- How should language scripts handle conflicts between existing and new configurations?
- Should language scripts be able to call each other for cross-language dependencies?

## Validation

- Test each language script independently with both modes
- Test multi-language projects to ensure proper coordination
- Measure maintainability improvements (fewer conditionals in main code)
- Monitor for any language-specific issues or edge cases

## Review Schedule

Review after 3 months of usage to assess:
- Effectiveness of per-language organization
- Need for additional language scripts
- Interface consistency across scripts
- Multi-language project handling

## Notes

The main orchestrator still handles devbox.json and justfile generation since these are cross-language concerns. Language scripts focus on language-specific configuration files.

## References

- [ADR: Two-Mode Project Adoption System](adr-20260202001-two-mode-project-adoption-system.md)
- [project-adopter SKILL.md](../SKILL.md)
- [Language-Specific Configuration Patterns](../REFERENCE.md#language-specific-configuration)

<!-- vim: set ft=markdown: -->
