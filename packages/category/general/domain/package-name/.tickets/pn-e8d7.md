---
id: pn-e8d7
status: closed
deps: []
links: []
created: 2026-01-29T08:08:38Z
type: task
priority: 1
assignee: lrepo52
parent: pn-fed6
---
# Update typescript template

## Notes

**2026-01-29T09:49:00Z**

Started updating TypeScript template to match Go template standards:
- Need to create proper `files/` directory structure
- Update `copier.yaml` with `_subdirectory: files` and `_templates_suffix: .jinja`
- Add missing files: devbox.json.jinja, .envrc.jinja, README.md.jinja, AGENTS.md.jinja, LICENSE.jinja, Dockerfile.jinja, .gitignore.jinja
- Use `git mv` for any tracked files to preserve history
