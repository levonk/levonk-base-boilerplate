# File-Based Mode Analysis Framework

When operating in file-based mode (analyzing and improving existing files), follow this comprehensive process:

## Core Principles

This skill applies the same quality principles used in creating new AI guidance, but in reverse: it analyzes existing files and identifies areas for improvement.

## Analysis Framework

The shared process discipline (prioritize, propose before applying, confirm,
apply as separate commits, update dates, validate, never silently overwrite)
follows the shared audit methodology:

---
description: Shared audit and improvement methodology for upserting/improving existing AI guidance files
---

### Audit Methodology

When updating or improving an existing AI guidance file (skill, workflow, agent,
prompt, rule, AGENTS.md), follow this process. The type-specific audit checklist
stays in each consumer's own reference file; this include covers the shared
process discipline that applies to all guidance types.

#### Step 1: Read Fully

Read the existing file completely — frontmatter, body, and any bundled resources
(`scripts/`, `references/`, `assets/`, `evals/`). Understand what the guidance
currently does before proposing any changes. Do not skip this step even if the
file looks familiar.

#### Step 2: Audit Against Guidelines

Check the existing file for compliance with the type-specific guidelines. The
audit checklist for each type lives in the consumer's own reference file — this
step is where type-specific knowledge is applied. Flag every issue found.

#### Delegating the Audit to a Subagent

Steps 2–4 (audit, prioritize, propose) are the most context-heavy part of
the update workflow — the subagent reads the full skill, checks every
checklist item, and produces the lettered findings list. This is a strong
`[fork]` candidate per the `subagent-delegation` include. When delegating:

**Front-load to the subagent** (it starts with a fresh context — it does
NOT inherit the inlined includes the orchestrator has in its SKILL.md):

- **Goal**: "Audit the skill at `<path>` against the skill guidelines and
  return a lettered findings list. Propose only — do not apply."
- **Inputs**: exact file paths — `SKILL.md`, frontmatter, `scripts/`,
  `references/`, `assets/`, `evals/`. Don't make it search for what you
  already know.
- **The audit checklist**: copy the type-specific checklist from the
  consumer's reference file (e.g. `skill-upsert.md` Step 2 for skills,
  `workflow-upsert.md` for workflows). The subagent won't have the
  reference file in context.
- **The lettered-findings format**: tell it explicitly — "Each finding
  gets a stable uppercase letter (`A)`, `B)`, `C)`, …) + one-line title +
  before/after + tier (`Critical` / `Important` / `Nice to have`). Group
  by tier first, then letter within tier." The subagent won't have
  Step 4's format spec in context.
- **Constraints**: "Propose only. Do not modify any files. Return the
  findings list in the lettered format."
- **What to return**: the lettered findings list (same shape the
  orchestrator would present to the user per Step 4).

**The orchestrator keeps** (these are orchestrator-user interactions;
the subagent never sees the user):

- **Step 5 (Confirm)**: the ack-rule (`Go` = apply all) is an
  orchestrator-user interaction. The subagent proposes; the orchestrator
  presents to the user; the user acknowledges; the orchestrator applies.
- **Step 6 (Apply)**: the orchestrator applies approved changes (or
  delegates the apply to a second subagent with the approved subset).
- **Step 9 (Reflect & Promote)**: the reflection asks "what did *I*
  have to research/do?" — the "I" is the orchestrator, who reviewed the
  subagent's work and decided to apply it. The subagent's work is an
  *input* to the reflection, not the reflection itself. Feed the
  subagent's findings into the reflection's Q1.

**Review the subagent's work** (per `subagent-delegation` — delegation is
not abdication):

1. Verify the findings list covers every checklist item (not just the
   obvious ones).
2. Check that letters are stable and unambiguous.
3. Run the smallest check that would fail if the audit is wrong — spot
   one finding against the actual file.

#### Step 3: Prioritize

Not all issues are equally important. Group findings into three tiers:

- **Critical**: Missing required frontmatter, broken references, stale text that
  misleads, anything that breaks functionality or discovery.
- **Important**: Description quality, progressive disclosure, context
  declaration, structure issues that cause token inefficiency.
- **Nice to have**: Tag cleanup, see-also relationships, unused example files,
  minor audience separation issues.

#### Step 4: Propose — Do Not Apply Yet

Present a prioritized list of specific, actionable changes. For each change,
show the before/after so the author can see exactly what will change and why.
Do not modify the file at this stage.

**Letter every finding.** Each proposed change gets a stable uppercase letter
(`A)`, `B)`, `C)`, `D)`, …) in addition to its tier label, so the author can
cherry-pick by letter in a subsequent reply (e.g. `Go A C F` or `1A, 2C, 3B`).
Reuse the option format from `clarifying-questions.md` — letter + one-line
title + before/after + tier (`Critical` / `Important` / `Nice to have`). When
the list is long, group by tier first, then letter within tier. The letters
are the contract: a subsequent reply that references letters resolves
unambiguously to these findings.

Example findings list:

```text
Critical:
  A) Add missing `date.knowledge-basis` to frontmatter
     before: (field absent)
     after:  `knowledge-basis: "2026-07-27"`

Important:
  B) Move the 200-line script-inlining block to `scripts/foo.py`
     before: <inline code in SKILL.md body>
     after:  `scripts/foo.py` + one-line call site in SKILL.md

Nice to have:
  C) Add `see-also: skill: cli-tool-upsert` (sibling relationship)
```

#### Step 5: Confirm Before Applying

Present the proposed changes and ask whether to proceed. Let the author:
- Accept all changes
- Accept a subset (cherry-pick by letter, e.g. `Go A C F` or `1A, 2C, 3B`)
- Reject entirely

**Bare acknowledgements mean "apply all".** A reply that is just `Go`, `Run`,
`Yes`, `y`, `continue`, `resume`, `proceed`, `ok`, `do it`, or any other
bare acknowledgement with no letter references is treated as **accept all
proposed changes** — the author is approving the entire findings list, not
asking the agent to pick. Apply every finding from Step 4 in this case. Only
an explicit letter subset (`Go A C F`), an explicit rejection (`No` / `Stop`
/ `Cancel`), or a custom instruction changes that default.

Do not modify the file until the author confirms. The author may have
intentionally deviated from a guideline — propose, explain the benefit, and let
them decide.

#### Step 6: Apply as Separate Commits

Apply approved changes as separate commits, one logical change per commit
(same discipline as format conversion): frontmatter fixes, structure changes,
resource cleanup, include additions — each independently reviewable and
revertable.

#### Step 7: Update Dates

Update `date.knowledge-basis` and `date.last-used` in the frontmatter when changes are
applied. Set both to the current date (YYYY-MM-DD).

#### Step 8: Validate

After applying improvements:

1. **Check for new conflicts** introduced by changes
2. **Verify all references** point to valid files/sections
3. **Test Go text/templates** render correctly (if `.tmpl` files were modified)
4. **Run `just validate`** to check for leaked delimiters and frontmatter issues
5. **Run `just build`** to confirm the build succeeds

#### Step 9: Reflect & Promote

After validation passes, run the post-task reflection pass. The full
protocol is the **Post-Task Reflection** section already inlined into
every guidance skill via `base-ai-guidance.md.tmpl` — run it now. It
asks three questions (what did I have to research/do? is any of it
generic across guidance types? does the include already exist and is
this skill written to consume it?) and produces a short **Reflection**
section appended to the audit summary. The reflection is mandatory
after every apply; if it surfaces nothing to promote, the section is a
single `Reflection: nothing to promote.` line. Do not skip the section
— its presence is the contract that the reflection ran.

This step is the post-task mirror of `research-phase.md`'s pre-task
search: research-phase asks "what already exists that I should reuse?",
Step 9 asks "what did I just do that someone else will have to redo
unless I promote it to a shared include?"

> The protocol is not re-included here. `base-ai-guidance.md.tmpl`
> already inlines `post-task-reflection.md` into every skill that
> includes it (which is every guidance skill, including every upsert
> skill that also includes this audit methodology). Re-including it
> here would duplicate the full protocol in SKILL.md for the 6 upsert
> skills that inline `audit-methodology` directly. If you are reading
> this audit methodology in a context that did NOT also include
> `base-ai-guidance`, load `references/included/...` or the published
> `post-task-reflection.md` via the three-tier resolver — but in
> practice every consumer of this include also consumes
> `base-ai-guidance`, so the protocol is already in context.

#### Never Silently Overwrite

The author may have intentionally deviated from a guideline. Propose, explain
the benefit, and let them decide. Never blindly overwrite the author's intent.

#### Deeper Analysis

For cross-file and system-wide issues (conflicts between files, duplications
across multiple guidance files, scattered context across the AI system), use
the `ai-guidance-improver` skill, which has the full cross-file analysis
framework. Type-specific upsert skills focus on single-file compliance; the
improver handles system-wide consistency.


The type-specific parts of this framework are the issue catalog (Step 1 below),
the fix examples (Step 3), and the type-specific guidance at the end.

### Step 1: Identify Issues

Analyze the target AI guidance file(s) for the following issues:

#### Conflicting Instructions
- **Symptom**: Multiple instructions that contradict each other
- **Example**: "Always use X" in one section, "Never use X" in another
- **Fix**: Resolve conflicts by clarifying intent or removing conflicting guidance

#### Duplicated Instructions
- **Symptom**: Same information repeated in multiple places
- **Example**: Same procedure explained in three different sections
- **Fix**: Consolidate to single source of truth with references

#### Inadequate Frontmatter
- **Symptom**: Missing or incomplete frontmatter fields
- **Example**: Missing `last-used` field, no `see_also` relationships, no `tags`
- **Fix**: Apply standard frontmatter template from `base-frontmatter.md.tmpl`

#### Poor Progressive Disclosure
- **Symptom**: Detailed information inline instead of in reference files
- **Example**: 200-line troubleshooting guide in main body instead of separate file
- **Fix**: Move detailed information to reference files with clear pointers

#### Scattered Context
- **Symptom**: File paths, URLs, project info scattered throughout
- **Example**: `~/p/gh/levonk/dotfiles/...` repeated in multiple places
- **Fix**: Consolidate context at bottom in Context Declaration section

#### Specific vs General Solutions
- **Symptom**: Hardcoded paths/URLs where indirect references would work
- **Example**: Full user-specific path instead of "the project's AGENTS.md"
- **Fix**: Use indirect references and declare actual paths in context section

#### Multiple Audiences Without Separation
- **Symptom**: One file serving multiple distinct audiences without separation
- **Example**: Boilerplate repo with deployer and creator guidance mixed
- **Fix**: Use progressive disclosure to separate audience-specific information

#### Missing Go Text/Template Includes
- **Symptom**: Repeated patterns that could be shared via templates
- **Example**: Same frontmatter structure copied across 10 files
- **Fix**: Create shared templates and use Go text/template includes

#### Python Scripts Missing PEP 723 / uv Header
- **Symptom**: Bundled `.py` scripts in `scripts/` lack the PEP 723 inline script metadata header, so they require a manual venv/build step instead of running via `uv run --script`
- **Example**: Script starts with `#!/usr/bin/env python3` and no `# /// script` block; dependencies installed via inline `pip install` or a separate requirements file
- **Fix**: Add the `#!/usr/bin/env -S uv run --script` shebang and `# /// script` metadata block (see the `python-script-standards` include); declare third-party deps in the `dependencies` array; remove inline `pip install` calls

#### Stale or Contradictory Text
- **Symptom**: Documentation that no longer reflects current reality
- **Example**: References to deleted files, outdated workflows, rules that were superseded
- **Fix**: Remove stale text immediately instead of explaining why it changed

#### Diary Entries Instead of Stable Contracts
- **Symptom**: Documentation records history or process narrative instead of durable contracts
- **Example**: "We used to do X but switched to Y" instead of just stating the current rule
- **Fix**: Document stable contracts, not history. Delete stale notes instead of explaining them

#### Misplaced Detail (Wrong Level)
- **Symptom**: Broad rules in child docs or concrete details in parent docs
- **Example**: Repo-wide coding standards inside a sub-package AGENTS.md, or package-specific file paths in the root
- **Fix**: Put broad rules in parent docs and concrete details in child docs

#### Warnings for Non-Existent Risks
- **Symptom**: Cautions about risks that no longer apply
- **Example**: "Be careful not to break the legacy build system" when the legacy system was removed
- **Fix**: Trim warnings for risks that no longer exist

### Step 2: Apply Improvements

For each identified issue, apply the appropriate fix:

#### Applying Standard Frontmatter

Use the base frontmatter template:

```go-template
---
description: Standard frontmatter template for AI guidance files (skills, workflows, agents, prompts)
---

### Standard Frontmatter Template

This template provides consistent frontmatter structure across all AI guidance files. Use jinja templating to include only the fields relevant to your file type.

#### Required Fields (All Types)

```yaml
# Basic identification
name: <string>                    # Human-readable name
description: <string>            # What this does and when to use it (100-200 words ideal)
```

#### Common Optional Fields

```yaml
# Versioning and status
version: <string>                 # Semantic version (e.g., 1.0.0)
status: <enum>                    # draft | ready | deprecated | archived
date:
  created: <YYYY-MM-DD>           # Creation date (never changed after creation)
  knowledge-basis: <YYYY-MM-DD>   # Last verification of 3rd-party tech refs (omit if none)
  last-used: <YYYY-MM-DD>         # Last usage date (for maintenance tracking)

# Ownership and metadata
owner: <url>                      # Repository or team URL
tags: <array<string>>             # Discoverability tags
see-also: <array>                 # Related resources (use base-ai-guidance or base-workflow-guidance)
dependencies: <array>            # Required skills/tools/templates

# Execution control (workflows/agents)
triggers: <array<string>>        # When this should activate
concurrency:
  group: <string>                 # Concurrency control group
  cancel_in_progress: <boolean>  # Whether to cancel running instances
retries:
  max: <number>                   # Maximum retry attempts
  backoff_secs: <number>          # Backoff delay between retries
safety:
  dry_run: <boolean>              # Whether to run in dry-run mode
  confirm_dangerous_ops: <boolean> # Whether to confirm dangerous operations

# Artifacts and permissions
artifacts: <array<string>>        # Files this creates
permissions: <array<string>>      # Required permissions
tools: <array<object>>           # Tools this uses

# Runtime information
runtime:
  duration:
    min: <string>                 # Minimum execution time
    max: <string>                 # Maximum execution time
    avg: <string>                 # Average execution time
  terminate: <string>            # Termination condition
```

#### Type-Specific Fields

**Skills:**
```yaml
# No additional fields beyond common ones
```

**Workflows:**
```yaml
workflow: <string>               # Workflow identifier
slug: <string>                   # URL-friendly slug
use: <string>                    # When to use this workflow
role: <string>                   # Role this workflow embodies
aliases: <array<string>>         # Alternative names
visibility: <enum>               # internal | public | private
compliance: <array<string>>      # Compliance requirements
```

**Agents:**
```yaml
agent: <string>                  # Agent identifier
slug: <string>                   # URL-friendly slug
use: <string>                    # When to use this agent
role: <string>                   # Role this agent embodies
color: <string>                   # UI color hex code
icon: <string>                   # UI emoji/icon
categories: <array<string>>      # Categorization
capabilities: <array<string>>    # What this agent can do
model-level: <enum>              # default | advanced | experimental
model: <string>                  # Specific model override
```

**Prompts:**
```yaml
prompt: <string>                 # Prompt identifier
slug: <string>                   # URL-friendly slug
template: <string>               # Template this follows
use: <string>                    # When to use this prompt
role: <string>                   # Role this prompt embodies
```

#### see-also Best Practices

For most AI guidance files, reference the bundled templates rather than individual components:

- **Skills**: Use `base-ai-guidance` (includes self-update, ai-guidance-creation, base-content-principles)
- **Workflows**: Use `base-workflow-guidance` (includes base-ai-guidance + levonk-methodology + workflow-design-principles)
- **Execution-only workflows**: Use `base-ai-guidance` (no methodology/design principles needed)

Example:
```yaml
see-also:
  - template: "base-workflow-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
  - template: "base-frontmatter"
    relationship: "structure-standard"
    description: "Standard frontmatter template for AI guidance files"
```

#### Self-Update Requirement Pattern

For files that track usage, include this pattern via the `base-ai-guidance` template:

```markdown
{{ include "includes/base-ai-guidance.md" . }}
```

This automatically includes the self-update requirement along with other base guidance.

#### Context Declaration Pattern

To preserve AI cache capability, declare context at the bottom:

```markdown
---
## Context Declaration

### File Paths
- Skill directory: `{{ skill_path }}`
- Reference files: `{{ references_path }}`
- Template files: `{{ templates_path }}`

### External Resources
- Documentation: {{ external_docs_url }}
- Repository: {{ repo_url }}

### Project Information
- Project name: {{ project_name }}
- Repository: {{ repo_name }}
- Owner: {{ owner }}
```

```

Customize fields based on the guidance type (skill, workflow, agent, prompt).

#### Implementing Progressive Disclosure

1. **Identify detailed sections** (>50 lines or deeply nested)
2. **Create reference files** in `references/` directory
3. **Add clear pointers** in main body
4. **Include context guidance** on when to read each reference

**Example transformation:**

**Before:**
```markdown
## Troubleshooting
[200 lines of detailed troubleshooting steps]
```

**After:**
```markdown
## Troubleshooting
For common issues and solutions, see [TROUBLESHOOTING.md](references/TROUBLESHOOTING.md).

### Quick Fixes
- Issue 1: Quick solution
- Issue 2: Quick solution

### When to Read Full Guide
- When quick fixes don't resolve the issue
- When you need detailed diagnostic procedures
- When dealing with complex multi-step issues
```

#### Consolidating Context

Move all file paths, URLs, and project-specific information to a Context Declaration section at the bottom:

```markdown
---
## Context Declaration

### File Paths
- Main file: `config/ai/skills/category/skill/SKILL.md`
- References: `config/ai/skills/category/skill/references/`

### External Resources
- Documentation: https://example.com/docs
- API reference: https://api.example.com

### Project Information
- Project: my-project
- Repository: https://github.com/user/repo
```

Replace scattered references with indirect references:
- "See `~/p/gh/levonk/dotfiles/AGENTS.md`" → "See the project's AGENTS.md"
- "Use the script at `~/p/gh/levonk/dotfiles/scripts/foo.sh`" → "Use the project's foo script"

#### Separating Multiple Audiences

For files serving multiple audiences:

1. **Identify each audience** and their information needs
2. **Create audience-specific sections** or separate files
3. **Add clear navigation** to guide each audience
4. **Use progressive disclosure** to hide audience-specific details

**Example for boilerplate repository:**

```markdown
## Using Boilerplates

For deploying existing boilerplates, see [Quick Start Guide](docs/quick-start.md).

For creating or modifying boilerplates, see [Boilerplate Development Guide](docs/development.md).

### Quick Navigation
- **I want to deploy a boilerplate**: See Quick Start Guide
- **I want to create a new boilerplate**: See Development Guide
- **I want to modify an existing boilerplate**: See Development Guide
```

#### Applying Go Text/Template Includes

For repeated patterns:

1. **Identify repeated content** across multiple files
2. **Create shared template** in `includes/` directory
3. **Replace with Go text/template include** in each file
4. **Update template** to propagate changes

**Example:**

**Before (in 10 files):**
```yaml
---
name: skill-name
description: ...
date:
  created: "2026-01-01"
  knowledge-basis: "2026-01-01"
  last-used: "2026-01-01"
---
```

**After:**
```yaml
---
---
description: Standard frontmatter template for AI guidance files (skills, workflows, agents, prompts)
---

### Standard Frontmatter Template

This template provides consistent frontmatter structure across all AI guidance files. Use jinja templating to include only the fields relevant to your file type.

#### Required Fields (All Types)

```yaml
# Basic identification
name: <string>                    # Human-readable name
description: <string>            # What this does and when to use it (100-200 words ideal)
```

#### Common Optional Fields

```yaml
# Versioning and status
version: <string>                 # Semantic version (e.g., 1.0.0)
status: <enum>                    # draft | ready | deprecated | archived
date:
  created: <YYYY-MM-DD>           # Creation date (never changed after creation)
  knowledge-basis: <YYYY-MM-DD>   # Last verification of 3rd-party tech refs (omit if none)
  last-used: <YYYY-MM-DD>         # Last usage date (for maintenance tracking)

# Ownership and metadata
owner: <url>                      # Repository or team URL
tags: <array<string>>             # Discoverability tags
see-also: <array>                 # Related resources (use base-ai-guidance or base-workflow-guidance)
dependencies: <array>            # Required skills/tools/templates

# Execution control (workflows/agents)
triggers: <array<string>>        # When this should activate
concurrency:
  group: <string>                 # Concurrency control group
  cancel_in_progress: <boolean>  # Whether to cancel running instances
retries:
  max: <number>                   # Maximum retry attempts
  backoff_secs: <number>          # Backoff delay between retries
safety:
  dry_run: <boolean>              # Whether to run in dry-run mode
  confirm_dangerous_ops: <boolean> # Whether to confirm dangerous operations

# Artifacts and permissions
artifacts: <array<string>>        # Files this creates
permissions: <array<string>>      # Required permissions
tools: <array<object>>           # Tools this uses

# Runtime information
runtime:
  duration:
    min: <string>                 # Minimum execution time
    max: <string>                 # Maximum execution time
    avg: <string>                 # Average execution time
  terminate: <string>            # Termination condition
```

#### Type-Specific Fields

**Skills:**
```yaml
# No additional fields beyond common ones
```

**Workflows:**
```yaml
workflow: <string>               # Workflow identifier
slug: <string>                   # URL-friendly slug
use: <string>                    # When to use this workflow
role: <string>                   # Role this workflow embodies
aliases: <array<string>>         # Alternative names
visibility: <enum>               # internal | public | private
compliance: <array<string>>      # Compliance requirements
```

**Agents:**
```yaml
agent: <string>                  # Agent identifier
slug: <string>                   # URL-friendly slug
use: <string>                    # When to use this agent
role: <string>                   # Role this agent embodies
color: <string>                   # UI color hex code
icon: <string>                   # UI emoji/icon
categories: <array<string>>      # Categorization
capabilities: <array<string>>    # What this agent can do
model-level: <enum>              # default | advanced | experimental
model: <string>                  # Specific model override
```

**Prompts:**
```yaml
prompt: <string>                 # Prompt identifier
slug: <string>                   # URL-friendly slug
template: <string>               # Template this follows
use: <string>                    # When to use this prompt
role: <string>                   # Role this prompt embodies
```

#### see-also Best Practices

For most AI guidance files, reference the bundled templates rather than individual components:

- **Skills**: Use `base-ai-guidance` (includes self-update, ai-guidance-creation, base-content-principles)
- **Workflows**: Use `base-workflow-guidance` (includes base-ai-guidance + levonk-methodology + workflow-design-principles)
- **Execution-only workflows**: Use `base-ai-guidance` (no methodology/design principles needed)

Example:
```yaml
see-also:
  - template: "base-workflow-guidance"
    relationship: "base-framework"
    description: "Shared framework for creating all AI guidance types"
  - template: "base-frontmatter"
    relationship: "structure-standard"
    description: "Standard frontmatter template for AI guidance files"
```

#### Self-Update Requirement Pattern

For files that track usage, include this pattern via the `base-ai-guidance` template:

```markdown
{{ include "includes/base-ai-guidance.md" . }}
```

This automatically includes the self-update requirement along with other base guidance.

#### Context Declaration Pattern

To preserve AI cache capability, declare context at the bottom:

```markdown
---
## Context Declaration

### File Paths
- Skill directory: `{{ skill_path }}`
- Reference files: `{{ references_path }}`
- Template files: `{{ templates_path }}`

### External Resources
- Documentation: {{ external_docs_url }}
- Repository: {{ repo_url }}

### Project Information
- Project name: {{ project_name }}
- Repository: {{ repo_name }}
- Owner: {{ owner }}
```

name: skill-name
description: ...
```

### Step 3: Document Changes

For significant improvements, document:

1. **What was changed** and why
2. **Benefits achieved** (token savings, maintainability, etc.)
3. **Any breaking changes** for consumers
4. **Migration guide** if needed

## Type-Specific Guidance

### Skills

**Skill-specific issues to check:**
- Missing `last-used` field in frontmatter
- SKILL.md body exceeding 500 lines
- Missing `see_also` relationships for dependencies
- No context declaration at bottom
- Bundled resources not properly referenced

**Common improvements:**
- Apply standard skill frontmatter
- Move detailed procedures to reference files
- Add context declaration with skill-specific paths
- Implement progressive disclosure for complex workflows

### Workflows

**Workflow-specific issues to check:**
- Missing workflow-specific frontmatter fields
- Step sequences not clearly defined
- Missing safety and concurrency controls
- No tool usage documentation
- Phase transitions unclear

**Common improvements:**
- Apply standard workflow frontmatter
- Clarify phase boundaries and completion criteria
- Document tool usage and dependencies
- Add safety controls and concurrency settings
- Implement progressive disclosure for complex phases

### Agents

**Agent-specific issues to check:**
- Missing agent-specific frontmatter fields
- Incomplete capability documentation
- Missing input/output schemas
- No runtime constraints specified
- Integration points unclear

**Common improvements:**
- Apply standard agent frontmatter
- Document capabilities with examples
- Define clear input/output schemas
- Specify runtime constraints and timeouts
- Add integration documentation

### Prompts

**Prompt-specific issues to check:**
- Missing prompt-specific frontmatter fields
- No template variable documentation
- Unclear expected inputs/outputs
- Missing usage examples
- No template structure documentation

**Common improvements:**
- Apply standard prompt frontmatter
- Document all template variables
- Provide clear usage examples
- Specify expected input/output formats
- Add template structure documentation

### AGENTS.md

**AGENTS.md-specific issues to check:**
- Missing project-level context
- No clear hierarchy or navigation
- Universal rules not specified
- Missing JIT index for sub-directories
- No definition of done

**Common improvements:**
- Add project snapshot and setup instructions
- Implement hierarchical structure with sub-AGENTS.md files
- Define universal rules and conventions
- Create JIT index for navigation
- Specify clear definition of done

## Batch Processing

For improving multiple files:

1. **Start with shared templates** - Create base templates first
2. **Process by type** - Handle all skills, then all workflows, etc.
3. **Apply consistently** - Use the same improvements across all files of the same type
4. **Validate incrementally** - Check each file before moving to the next
5. **Document patterns** - Note common issues for future reference
