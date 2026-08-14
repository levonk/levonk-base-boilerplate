# Tool Selection

## Tool Selection Logic

```mermaid
flowchart TD
    A[User calls surgical-edit.sh] --> B{Detect File Type}

    B -->|Templated Structured| C[Template Processor]
    B -->|Structured Format| D[Semantic Parser]
    B -->|Code File| E[Structural Rewriter]
    B -->|Text File| F[Text Utility]

    C --> G[Extract Template]
    G --> H{Template Success?}
    H -->|Yes| D
    H -->|No| F

    D --> I{yq-go Available?}
    I -->|Yes| J[Apply Semantic Edit]
    I -->|No| K[Fallback to jq/dot-json]

    K --> L{jq Available?}
    L -->|Yes| M[Apply jq Edit]
    L -->|No| N[Fallback to Text Tools]

    E --> O{comby/ast-grep Available?}
    O -->|Yes| P[Apply Structural Edit]
    O -->|No| F

    F --> Q{sd/sed Available?}
    Q -->|Yes| R[Apply Text Edit]
    Q -->|No| S[Manual Intervention]

    J --> T[Validate Result]
    M --> T
    N --> T
    P --> T
    R --> T

    T --> U{Validation Success?}
    U -->|Yes| V[Success]
    U -->|No| W[Rollback & Retry]

    W --> X{Fallback Available?}
    X -->|Yes| Y[Try Next Tool]
    X -->|No| Z[Error]
```

## File Type Detection

| File Type | Extensions | Primary Tool | Fallback Tools | Special Handling |
|-----------|-------------|--------------|----------------|------------------|
| **Templated Structured** | `*.json.jinja`, `*.yaml.jinja`, `*.yml.jinja`, `*.toml.jinja`, `*.xml.jinja`, `*.cfg.jinja`, `*.conf.jinja`, `*.ini.jinja` | Template Processor → Semantic Parser | Text Utilities | Extract template, process structured data |
| **Structured** | `*.json`, `*.yaml`, `*.yml`, `*.toml`, `*.xml` | yq-go (preserves comments) | jq, jo, dot-json, comby, sd | yq-go preferred for comment preservation |
| **Code** | `*.rs`, `*.js`, `*.ts`, `*.py`, `*.go`, `*.java`, `*.c`, `*.cpp`, `*.hs`, `*.php`, `*.rb`, `*.swift`, `*.kt` | comby, ast-grep | sd | Pattern-based transformations |
| **Configuration** | `*.env`, `*.conf`, `*.ini`, `*.cfg`, `*.properties`, `*.tfvars`, `*.hcl` | sd | sed | Simple text operations |
| **Markup** | `*.md`, `*.rst`, `*.tex`, `*.adoc` | sd | sed, pandoc | Structured text operations |
| **Text** | `*.txt`, `*.log`, `*.csv` | sd | sed, echo | Line-based operations |
| **Binary Configs** | `*.plist`, `*.binary` | hexedit, xxd | Manual intervention | Binary file operations |
