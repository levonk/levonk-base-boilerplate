# Prompt: Identify Abstractions

Identify the core abstractions in a codebase that would help a newcomer understand it.

## Template

````
For the project `{project_name}`:

Codebase Context:
{files_context}

Analyze the codebase and identify the top 5-{max_abstraction_num} core abstractions that would help someone new understand this codebase.

For each abstraction, provide:
1. A concise `name`
2. A beginner-friendly `description` explaining what it is with a simple analogy, in around 100 words
3. A list of relevant `file_indices` (integers) using the format `idx # path/comment`

List of file indices and paths present in the context:
{file_listing}

Format the output as a YAML list:

```yaml
- name: |
    Query Processing
  description: |
    Explains what the abstraction does.
    It's like a central dispatcher routing requests.
  file_indices:
    - 0 # path/to/file1.py
    - 3 # path/to/related.py
- name: |
    Query Optimization
  description: |
    Another core concept, similar to a blueprint for objects.
  file_indices:
    - 5 # path/to/another.js
````

```

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{project_name}` | Name of the project | `flask` |
| `{files_context}` | Concatenated file contents with index headers | See below |
| `{max_abstraction_num}` | Maximum abstractions to identify | `10` |
| `{file_listing}` | List of `idx # path` entries | `0 # src/app.py` |

### files_context format

```

--- File Index 0: src/app.py ---
[file content here]

--- File Index 1: src/utils.py ---
[file content here]

```

## Validation Rules

- Output must be valid YAML list
- Each item must have:
  - `name`: non-empty string
  - `description`: non-empty string
  - `file_indices`: list of integers or `idx # comment` strings
- All file indices must be valid (0 to file_count-1)
- Aim for 5-10 abstractions (not too few, not overwhelming)

## Example Output

See [examples/abstractions-flask.yaml](../examples/abstractions-flask.yaml) for a complete example.

<!-- vim: set ft=markdown -->
```
