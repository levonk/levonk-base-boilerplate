# Progressive Disclosure Patterns

Skills use a three-level loading system to manage context efficiently:

1. **Metadata** (name + description) - Always in context (~100 words)
2. **SKILL.md body** - When skill triggers
3. **Bundled resources** - As needed by Claude (unlimited because scripts can execute without reading into context window)

## Key Principles

### Keep SKILL.md Lean

Keep SKILL.md body to the essentials to minimize context bloat. Split content into separate files when it becomes unwieldy. Use `scripts/` for deterministic phases and `references/` for heavy detail.

**Important**: When splitting out content into other files, reference them from SKILL.md and describe clearly when to read them, to ensure the reader of the skill knows they exist and when to use them.

### Reference Files Clearly

All reference files should link directly from SKILL.md. Avoid deeply nested references - keep references one level deep.

### Structure Long Files

For reference files longer than 100 lines, include a table of contents at the top so Claude can see the full scope when previewing.

## Common Patterns

### Pattern 1: High-level guide with references

Use this when you have a simple overview with optional advanced topics.

```markdown
# PDF Processing

## Quick start
Extract text with pdfplumber:
```python
import pdfplumber
with pdfplumber.open("document.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```

## Advanced features
- **Form filling**: See [FORMS.md](FORMS.md) for complete guide
- **API reference**: See [REFERENCE.md](REFERENCE.md) for all methods
- **Examples**: See [EXAMPLES.md](EXAMPLES.md) for common patterns
```

Claude loads FORMS.md, REFERENCE.md, or EXAMPLES.md only when needed.

### Pattern 2: Domain-specific organization

For skills with multiple domains, organize content by domain to avoid loading irrelevant context.

```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── reference/
    ├── finance.md (revenue, billing metrics)
    ├── sales.md (opportunities, pipeline)
    ├── product.md (API usage, features)
    └── marketing.md (campaigns, attribution)
```

When a user asks about sales metrics, Claude only reads sales.md.

**SKILL.md example**:
```markdown
# BigQuery Analytics

This skill provides domain-specific guidance for querying different business areas.

## Domains
- **Finance**: See [reference/finance.md](reference/finance.md) for revenue, billing metrics
- **Sales**: See [reference/sales.md](reference/sales.md) for opportunities, pipeline
- **Product**: See [reference/product.md](reference/product.md) for API usage, features
- **Marketing**: See [reference/marketing.md](reference/marketing.md) for campaigns, attribution
```

### Pattern 3: Variant-specific organization

For skills supporting multiple frameworks or variants, organize by variant.

```
cloud-deploy/
├── SKILL.md (workflow + provider selection)
└── references/
    ├── aws.md (AWS deployment patterns)
    ├── gcp.md (GCP deployment patterns)
    └── azure.md (Azure deployment patterns)
```

When the user chooses AWS, Claude only reads aws.md.

**SKILL.md example**:
```markdown
# Cloud Deployment

This skill provides deployment guidance for major cloud providers.

## Provider Selection
Choose your provider and see the specific guide:
- **AWS**: See [references/aws.md](references/aws.md)
- **GCP**: See [references/gcp.md](references/gcp.md)
- **Azure**: See [references/azure.md](references/azure.md)
```

### Pattern 4: Conditional details

Show basic content, link to advanced content.

```markdown
# DOCX Processing

## Creating documents
Use docx-js for new documents. See [DOCX-JS.md](DOCX-JS.md).

## Editing documents
For simple edits, modify the XML directly.

**For tracked changes**: See [REDLINING.md](REDLINING.md)
**For OOXML details**: See [OOXML.md](OOXML.md)
```

Claude reads REDLINING.md or OOXML.md only when the user needs those features.

### Pattern 5b: Audience separation

When creating skills that serve multiple audiences (e.g., end users vs developers), apply progressive disclosure by separating audience-specific sections.

**Pattern:**
```markdown
## Quick Start (for end users)
[Basic usage, installation, common tasks]

---

## Advanced Usage (for power users)
[Advanced features, configuration options]

---

## Development Guide (for developers)
[Extending the skill, contributing, internal architecture]
```

**Implementation:**
- Keep common information in the main body
- Move audience-specific sections to clearly labeled parts
- Use horizontal rules (`---`) to visually separate audiences
- Consider creating separate files for developer-specific content if >200 lines

### Pattern 5: Step overview with topic-named references

Use this when converting a multi-step workflow to a skill. SKILL.md becomes a numbered step overview where each step links to a reference file or script named by topic, not by step number. This makes inserting a new step a one-line change in SKILL.md instead of renumbering across many files. Reference files may still contain their own internal numbered substeps — the restriction is on filenames only.

**Why topic-named references:** If reference files are named `step-1-check-flake.md`, `step-2-detect-access.md`, inserting a new first step requires renaming every file. If they are named `check-existing-flake.md`, `detect-access.sh`, inserting a new first step only requires adding one line to the numbered list in SKILL.md.

```
nixify-skill/
├── SKILL.md (numbered step overview + AI decision points)
├── scripts/
│   ├── check-existing-flake.sh
│   ├── detect-access.sh
│   ├── search-existing-work.sh
│   └── analyze-distribution.sh
└── references/
    ├── flake-templates.md (tarball, source-build, nixpkgs-wrapper variants)
    ├── devbox-templates.md (Rust, Node, Go, Python variants)
    └── architecture-analysis.md (success/failure patterns, build script guidance)
```

**SKILL.md example**:
```markdown
# Nixify: Add Nix Flake Support

## Steps

1. Check for existing flake: Run `scripts/check-existing-flake.sh`. If flake exists, abort.
2. Detect user and repo access: Run `scripts/detect-access.sh`. Determine fork vs direct clone.
3. Search for existing issues/PRs: Run `scripts/search-existing-work.sh`. If existing work found, present to user and ask whether to proceed.
4. Check for prebuilt tarballs: Run `scripts/check-prebuilt-tarballs.sh`. If tarballs exist, use fetchurl approach (see `references/flake-templates.md`).
5. Analyze distribution complexity: Run `scripts/analyze-distribution.sh`. If complex multi-component, see `references/architecture-analysis.md` for decision guidance.
6. Fork and clone: Run `scripts/fork-and-clone.sh`.
7. Validate existing tests: Run `scripts/validate-tests.sh`. Document any pre-existing failures.
8. Set up branch and git author: Run `scripts/setup-branch.sh`.
9. Check nixpkgs for upstream packages: Run `scripts/check-nixpkgs.sh`. Decide upstream vs source build.
10. Generate flake.nix: Use appropriate template from `references/flake-templates.md`.
11. Create devbox.json: Use template from `references/devbox-templates.md`.
12. Update .gitignore and README: Run `scripts/update-gitignore.sh`, then update README.
```

Inserting a new step 3 (e.g., "Check project license compatibility") only requires renumbering steps 3-12 in SKILL.md and adding one new reference file. No other reference files or scripts need renaming.

## Progressive Disclosure in Action

### Example: Multi-step process with optional details

```markdown
# Data Pipeline

## Quick start
1. Extract data from source
2. Transform using SQL
3. Load to destination

## Advanced: Error handling
See [ERROR_HANDLING.md](ERROR_HANDLING.md) for retry logic, dead letter queues, and monitoring.

## Advanced: Performance optimization
See [PERFORMANCE.md](PERFORMANCE.md) for parallel processing, caching, and partitioning strategies.
```

### Example: Framework selection

```markdown
# Web Framework Setup

## Frameworks
- **Next.js**: See [NEXTJS.md](NEXTJS.md) for React-based framework
- **Express**: See [EXPRESS.md](EXPRESS.md) for Node.js backend
- **Django**: See [DJANGO.md](DJANGO.md) for Python web framework

Choose the framework that matches your stack and language preference.
```

## Anti-Patterns to Avoid

### ❌ Duplicating information

Don't put the same information in both SKILL.md and references files. Choose one location and reference it.

### ❌ Deeply nested references

Avoid:
```
SKILL.md → references/guide.md → references/guide/advanced.md → references/guide/advanced/troubleshooting.md
```

Keep references one level deep:
```
SKILL.md → references/advanced.md
SKILL.md → references/troubleshooting.md
```

### ❌ Unclear references

Always explain when to read a reference file:

Bad:
```markdown
See [ADVANCED.md](ADVANCED.md)
```

Good:
```markdown
**For advanced error handling**: See [ADVANCED.md](ADVANCED.md)
```

### ❌ Step-numbered filenames

Don't name reference or script files by step number. Inserting a new step forces renaming every downstream file.

Bad:
```
references/step-1-check-flake.md
references/step-2-detect-access.md
references/step-3-search-existing.md
```

Good:
```
references/check-existing-flake.md
references/detect-access.md
references/search-existing-work.md
```

Step numbers in filenames cause cascading renames. Files should be named by topic. Reference files may still contain numbered substeps within their content — the restriction is on filenames only, not on numbered lists inside reference files.

### ❌ Embedded variant code in monolithic template files

Don't put multiple variant code blocks (one per language, framework, package
manager, etc.) in a single `references/template-x.md` file. The AI must load
all variants into context even when only one applies, and embedded code in
markdown creates bug risk — the AI may copy-paste the wrong block, mix syntax
across variants, or partially edit one variant while leaving siblings stale.

Bad:
```
references/
└── build-docs.md          # bun + pnpm + npm + yarn sections all inline
```

Good:
```
references/
└── build-docs/
    ├── bun.md
    ├── pnpm.md
    ├── npm.md
    └── yarn.md
```

SKILL.md links to the specific variant file, not to a monolithic file where
the AI must "choose the right section." When the skill lives in skills-src,
use `{{{ include }}}` directives to share common headers/boilerplate across
variant files instead of duplicating. See `references/anatomy.md` — Template
Files for the full pattern.

### ❌ Monolithic SKILL.md

Don't put everything in SKILL.md. Split deterministic phases into `scripts/` and heavy detail into `references/`.

## Testing Progressive Disclosure

When testing your skill, verify:
1. All reference files are clearly linked from SKILL.md with context
2. Reference files have table of contents if over 100 lines
3. No information is duplicated between SKILL.md and references
4. References are one level deep (no nesting)
5. Deterministic phases are extracted into scripts, not inline in SKILL.md
6. No monolithic template files with multiple embedded variant code blocks — each variant is its own file
