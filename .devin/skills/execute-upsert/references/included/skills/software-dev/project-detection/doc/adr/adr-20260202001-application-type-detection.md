# ADR-20260202001: Application Type Detection and Project Characterization System

## Status
Accepted

## Context
The project-adopter skill was adding inappropriate tooling to projects (e.g., Playwright to CLI applications) because it only detected build systems without understanding the application's purpose or type. This led to bloated development environments with unnecessary dependencies and tools.

## Problem Statement
Build system detection alone is insufficient for determining appropriate development tooling:
- npm projects could be web apps, CLI tools, libraries, or APIs
- Cargo projects could be web apps, CLI tools, system utilities, or libraries
- Adding browser testing tools to non-web applications wastes resources and confuses developers
- Different application types require fundamentally different development workflows and tooling

## Decision
Implement a multi-layered detection system that characterizes projects along three dimensions:
1. **Build Systems** - Package managers and build tools
2. **Application Types** - High-level application categories (web, cli, api, etc.)
3. **Project Types** - Specific project classifications (frontend-web, cli-tool, api-service, etc.)

## Rationale

### Why Multi-Layered Detection?
1. **Build systems are ambiguous** - npm can power anything from a simple script to a complex web application
2. **Application intent matters** - A web app needs browser testing; a CLI tool needs argument parsing
3. **Tooling should be contextual** - Different development workflows require different tools
4. **Avoid false positives** - Multiple detection layers reduce misclassification

### Why Pattern-Based Detection?
1. **File system patterns are reliable** - Configuration files and directory structures indicate intent
2. **Framework-specific files are unambiguous** - `next.config.js` clearly indicates a Next.js web app
3. **Directory naming conventions** - `src/components/` suggests a UI/web application
4. **Dependency analysis** - Presence of `playwright` or `commander` in package.json indicates purpose

### Why Structured Output?
1. **Machine-parseable** - Pipe-separated key-value pairs are easy to parse in shell scripts
2. **Extensible** - New characteristics can be added without breaking existing consumers
3. **Human-readable** - The format is understandable when debugging
4. **Backward compatible** - Can still extract just build systems if needed

## Technical Approach

### Detection Algorithm
```bash
# 1. Build System Detection (existing)
detect_systems() {
    # Check for package.json, Cargo.toml, go.mod, etc.
}

# 2. Application Type Detection (new)
detect_app_type() {
    # Check for framework configs, directory structures, dependencies
    # Score matches and return highest-scoring type
}

# 3. Project Type Detection (new)  
detect_project_type() {
    # More specific categorization based on framework patterns
    # e.g., "frontend-web" vs "fullstack-web"
}

# 4. Combined Characteristics
detect_project_characteristics() {
    # Execute all three and return structured output
    # Format: "build_systems:npm|app_type:web|project_type:frontend-web"
}
```

### Pattern Matching Strategy
1. **Specific patterns first** - `next.config.js` is more specific than `package.json`
2. **Directory structure analysis** - `src/components/` indicates UI components
3. **Dependency inspection** - Check package.json for framework dependencies
4. **Scoring system** - More matches = higher confidence in classification

### Application Type Hierarchy
```
web (most specific)
├── frontend-web
├── fullstack-web  
└── api-service

cli
├── cli-tool
└── utility

library
├── component-library
└── sdk

desktop, mobile, game, ml, devops, docs
```

## Affected Components

### Modified Files
- `scripts/detect-build-systems.sh` - Enhanced with app/project type detection
- `../project-adopter/scripts/adopt-project.sh` - Updated to use characteristics

### New Functions
- `detect_app_type()` - Application category detection
- `detect_project_type()` - Specific project classification  
- `detect_project_characteristics()` - Combined detection
- `parse_project_characteristics()` - Result parsing utility

### Enhanced CLI Interface
```bash
# Original (still supported)
./detect-build-systems.sh /path/to/project

# New capabilities
./detect-build-systems.sh -t app /path/to/project          # Application type only
./detect-build-systems.sh -t project /path/to/project      # Project type only  
./detect-build-systems.sh -t characteristics /path/to/project # All characteristics
./detect-build-systems.sh -v -t characteristics /path/to/project # Verbose output
```

## Consequences

### Positive
- **Accurate tooling selection** - Web apps get Playwright, CLI apps get argument parsers
- **Reduced bloat** - No unnecessary dependencies in development environments
- **Better developer experience** - Tools match the actual development workflow
- **Extensible** - Easy to add new application types and patterns
- **Backward compatible** - Existing build system detection still works

### Negative  
- **Increased complexity** - More detection logic to maintain
- **Pattern maintenance** - Need to keep detection patterns up to date
- **Potential false negatives** - New frameworks might not be recognized immediately

### Risks
- **Detection accuracy** - Complex projects might have mixed characteristics
- **Pattern drift** - Frameworks change file naming conventions
- **Performance** - Additional file system checks increase detection time

## Alternatives Considered

### 1. Package.json Analysis Only
- **Pros**: Simple, uses existing dependency information
- **Cons**: Can't detect project structure, fails for non-package-manager projects

### 2. Machine Learning Classification  
- **Pros**: Could learn complex patterns
- **Cons**: Overkill, requires training data, black box behavior

### 3. User-Specified Project Type
- **Pros**: 100% accurate if user knows what they're doing
- **Cons**: Adds cognitive burden, users might not know the right type

### 4. Heuristic-Based Scoring
- **Pros**: More nuanced than simple pattern matching
- **Cons**: Complex to tune, harder to debug

## Implementation Details

### Pattern Matching Rules
1. **Framework configs trump all** - `next.config.js` = web application
2. **Directory structure matters** - `src/cli/` = CLI application  
3. **Dependencies confirm intent** - `playwright` in package.json = web testing
4. **Multiple patterns increase confidence** - More matches = higher score

### Tie-Breaking Strategy
When multiple application types have the same score:
1. **Prefer more specific patterns** - Framework config > generic file
2. **Prefer directory structures** - `src/components/` > generic file
3. **Default to library** - If unclear, assume it's a library (least intrusive)

### Error Handling
- **Graceful degradation** - If detection fails, fall back to build system only
- **Verbose logging** - Debug mode shows scoring and decision process
- **Unknown types** - Return "unknown" rather than making incorrect assumptions

## Validation Strategy

### Test Cases
1. **Next.js application** → `app_type:web`, `project_type:frontend-web`
2. **Express API** → `app_type:api`, `project_type:api-service`  
3. **CLI tool with Commander** → `app_type:cli`, `project_type:cli-tool`
4. **Rust web app with Trunk** → `app_type:web`, `project_type:frontend-web`
5. **Python CLI with Click** → `app_type:cli`, `project_type:cli-tool`
6. **Documentation project** → `app_type:docs`, `project_type:documentation`

### Integration Testing
- Verify project-adopter generates appropriate devbox.json configurations
- Confirm web apps get Playwright, CLI apps get argument parsers
- Test with mixed projects (e.g., fullstack applications)

## Rollout Plan

### Phase 1: Core Detection (Complete)
- [x] Implement basic application type detection
- [x] Add project type classification  
- [x] Create combined characteristics output
- [x] Update project-adopter integration

### Phase 2: Pattern Refinement (Future)
- [ ] Add more framework-specific patterns
- [ ] Improve tie-breaking logic
- [ ] Add confidence scoring
- [ ] Expand test coverage

### Phase 3: Advanced Features (Future)
- [ ] Support for mixed-type projects
- [ ] Learning from user corrections
- [ ] Integration with package registries for dependency analysis

## Review Schedule
- **Monthly**: Review detection patterns for new frameworks
- **Quarterly**: Analyze detection accuracy and false positives
- **Annually**: Major review of detection strategy and patterns

## References
- [Project-Adopter ADRs](../project-adopter/doc/adr/)
- [Surgical-Config Skill](../surgical-config/)
- [Detection Script Implementation](../scripts/detect-build-systems.sh)
