# Prompt: Order Chapters

Determine the best order to present abstractions in a tutorial for maximum learning.

## Template

````
Given the following project abstractions and their relationships for the project `{project_name}`:

Abstractions (Index # Name):
{abstraction_listing}

Context about relationships and project summary:
{context}

If you are going to make a tutorial for `{project_name}`, what is the best order to explain these abstractions, from first to last?

Ideally, first explain those that are the most important or foundational, perhaps user-facing concepts or entry points. Then move to more detailed, lower-level implementation details or supporting concepts.

Output the ordered list of abstraction indices, including the name in a comment for clarity:

```yaml
- 2 # FoundationalConcept
- 0 # CoreClassA
- 1 # CoreClassB (uses CoreClassA)
````

```

## Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `{project_name}` | Name of the project | `flask` |
| `{abstraction_listing}` | List of `idx # name` entries | `0 # Flask Application` |
| `{context}` | Summary + relationships from previous step | See below |

### context format

```

Project Summary:
Flask is a lightweight web framework...

Relationships (Indices refer to abstractions above):

- From 0 (Flask Application) to 3 (Routing): Registers routes
- From 3 (Routing) to 1 (Request Context): Creates context

```

## Ordering Guidelines

1. **Start with entry points**: User-facing concepts, main classes, CLI interfaces
2. **Then foundational concepts**: Core abstractions that others depend on
3. **Then supporting concepts**: Utilities, helpers, internal implementations
4. **End with advanced topics**: Edge cases, optimizations, extensions

## Validation Rules

- Output must be a YAML list
- All abstraction indices must appear exactly once
- No duplicates
- No missing indices
- Each entry should be `idx # name` format

## Example Output

See [examples/chapter-order-flask.yaml](../examples/chapter-order-flask.yaml) for a complete example.

<!-- vim: set ft=markdown -->
```
