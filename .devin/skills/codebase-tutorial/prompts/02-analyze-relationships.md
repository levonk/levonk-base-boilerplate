# Prompt: Analyze Relationships

Analyze how the identified abstractions relate to each other and generate a project summary.

## Template

````text
Based on the following abstractions and relevant code snippets from the project `{project_name}`:

List of Abstraction Indices and Names:
{abstraction_listing}

Context (Abstractions, Descriptions, Code):
{context}

Please provide:
1. A high-level `summary` of the project's main purpose and functionality in a few beginner-friendly sentences. Use markdown formatting with **bold** and *italic* text to highlight important concepts.
2. A list (`relationships`) describing the key interactions between these abstractions. For each relationship, specify:
    - `from_abstraction`: Index of the source abstraction (e.g., `0 # AbstractionName1`)
    - `to_abstraction`: Index of the target abstraction (e.g., `1 # AbstractionName2`)
    - `label`: A brief label for the interaction **in just a few words** (e.g., "Manages", "Inherits", "Uses")

IMPORTANT: Make sure EVERY abstraction is involved in at least ONE relationship (either as source or target).

Format the output as YAML:

```yaml
summary: |
  A brief, simple explanation of the project.
  Can span multiple lines with **bold** and *italic* for emphasis.
relationships:
  - from_abstraction: 0 # AbstractionName1
    to_abstraction: 1 # AbstractionName2
    label: "Manages"
  - from_abstraction: 2 # AbstractionName3
    to_abstraction: 0 # AbstractionName1
    label: "Provides config"
```
````

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{project_name}` | Name of the project | `flask` |
| `{abstraction_listing}` | List of `idx # name` entries | `0 # Flask Application` |
| `{context}` | Abstractions with descriptions + relevant code | See below |

### context format

```text
Identified Abstractions:
- Index 0: Flask Application (Relevant file indices: [0, 5])
  Description: The central object that ties everything together...
- Index 1: Request Context (Relevant file indices: [2, 5])
  Description: A temporary workspace created for each request...

Relevant File Snippets:
--- File: 0 # src/flask/app.py ---
[code content]

--- File: 2 # src/flask/ctx.py ---
[code content]
```

## Validation Rules

- Output must have `summary` (string) and `relationships` (list)
- Summary should use markdown formatting
- Each relationship must have:
  - `from_abstraction`: valid index
  - `to_abstraction`: valid index
  - `label`: short descriptive string (few words)
- Every abstraction index must appear in at least one relationship
- Relationships should be backed by actual code interactions (calls, imports, inheritance)

## Example Output

See [examples/relationships-flask.yaml](../examples/relationships-flask.yaml) for a complete example.

<!-- vim: set ft=markdown -->
