# {{ project_name }}

{{ description }}

{% if include_tui %}
## TUI Mode

This CLI supports TUI (Terminal User Interface) mode for interactive configuration. Use the `--interactive` or `--tui` flag to launch the TUI:

```bash
{{ project_slug }} --interactive
# or
{{ project_slug }} --tui
```

In TUI mode, you can:
- View all CLI arguments before execution
- Modify arguments interactively
- Confirm execution before proceeding

TUI mode is optional and can be disabled during project generation.
{% endif %}
