# Prompt: Write Chapter

Generate a beginner-friendly tutorial chapter for a single abstraction.

## Template

````
Write a very beginner-friendly tutorial chapter (in Markdown format) for the project `{project_name}` about the concept: "{abstraction_name}". This is Chapter {chapter_num}.

Concept Details:
- Name: {abstraction_name}
- Description:
{abstraction_description}

Complete Tutorial Structure:
{full_chapter_listing}

Context from previous chapters:
{previous_chapters_summary}

Relevant Code Snippets:
{file_context}

Instructions for the chapter:
- Start with a clear heading: `# Chapter {chapter_num}: {abstraction_name}`

- If this is not the first chapter, begin with a brief transition from the previous chapter, referencing it with a proper Markdown link using its name.

- Begin with a high-level motivation explaining what problem this abstraction solves. Start with a central use case as a concrete example. The whole chapter should guide the reader to understand how to solve this use case. Make it very minimal and friendly to beginners.

- If the abstraction is complex, break it down into key concepts. Explain each concept one-by-one in a very beginner-friendly way.

- Explain how to use this abstraction to solve the use case. Give example inputs and outputs for code snippets (if the output isn't values, describe at a high level what will happen).

- Each code block should be BELOW 10 lines! If longer code blocks are needed, break them down into smaller pieces and walk through them one-by-one. Aggressively simplify the code to make it minimal. Use comments to skip non-important implementation details. Each code block should have a beginner friendly explanation right after it.

- Describe the internal implementation to help understand what's under the hood. First provide a non-code or code-light walkthrough on what happens step-by-step when the abstraction is called. Use a simple sequenceDiagram with a dummy example - keep it minimal with at most 5 participants.

- Then dive deeper into code for the internal implementation with references to files. Provide example code blocks, but make them similarly simple and beginner-friendly.

- IMPORTANT: When you need to refer to other core abstractions covered in other chapters, ALWAYS use proper Markdown links like this: [Chapter Title](filename.md). Use the Complete Tutorial Structure above to find the correct filename.

- Use mermaid diagrams to illustrate complex concepts (```mermaid``` format).

- Heavily use analogies and examples throughout to help beginners understand.

- End the chapter with a brief conclusion that summarizes what was learned and provides a transition to the next chapter. If there is a next chapter, use a proper Markdown link.

- Ensure the tone is welcoming and easy for a newcomer to understand.

- Output *only* the Markdown content for this chapter.
````

## Variables

| Variable                      | Description                | Example                 |
| ----------------------------- | -------------------------- | ----------------------- |
| `{project_name}`              | Name of the project        | `flask`                 |
| `{chapter_num}`               | Chapter number (1-indexed) | `1`                     |
| `{abstraction_name}`          | Name of the concept        | `Flask Application`     |
| `{abstraction_description}`   | Description from Step 1    | `The central object...` |
| `{full_chapter_listing}`      | All chapters with links    | See below               |
| `{previous_chapters_summary}` | Content of prior chapters  | See below               |
| `{file_context}`              | Relevant code snippets     | See below               |

### full_chapter_listing format

```
1. [Flask Application](01_flask_application.md)
2. [Routing](02_routing.md)
3. [Request Context](03_request_context.md)
4. [Templates](04_templates.md)
5. [Blueprints](05_blueprints.md)
```

### previous_chapters_summary format

For Chapter 1: `This is the first chapter.`

For later chapters: Content of all previous chapters concatenated with `---` separators.

### file_context format

```
--- File: src/flask/app.py ---
[relevant code snippets]

--- File: src/flask/globals.py ---
[relevant code snippets]
```

## Chapter Structure Guidelines

1. **Heading**: `# Chapter N: Concept Name`
2. **Transition** (if not first): Link to previous chapter
3. **Motivation**: What problem does this solve? Concrete use case.
4. **Key Concepts**: Break down into digestible pieces
5. **How to Use**: Example code (<10 lines each) with explanations
6. **Under the Hood**: Sequence diagram + code walkthrough
7. **Summary**: What we learned + link to next chapter

## Validation Rules

- Must start with `# Chapter {chapter_num}:`
- Code blocks should be under 10 lines
- Should contain at least one mermaid diagram
- Should have proper Markdown links to other chapters
- Tone should be welcoming and beginner-friendly

## Example Output

See [examples/chapter-flask-app.md](../examples/chapter-flask-app.md) for a complete example chapter.

<!-- vim: set ft=markdown -->
