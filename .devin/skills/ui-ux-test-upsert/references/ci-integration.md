# CI Integration

How to wire UI/UX tests into CI with graceful missing-key handling.

## Pipeline Structure

```
PR Pipeline:
  → Unit tests (always)
  → Coverage tests (always — no API keys needed)
  → Usability smoke tests (only if LLM keys available)

Nightly Pipeline:
  → Full test suite
  → Full usability suite (only if LLM keys available)

Release Pipeline:
  → Full test suite
  → Full usability suite (only if LLM keys available)
  → Edge-case usability tasks (only if LLM keys available)
```

## Graceful Missing-Key Handling

The quality gate degrades gracefully when LLM API keys are absent. Coverage
tests always run (deterministic, no keys). Usability tests skip with a
warning and exit 0.

### Key Detection Script

```bash
#!/usr/bin/env bash
# detect-llm-keys.sh — Check for LLM API keys
# Returns 0 if at least one key is found, 1 if none.

set -euo pipefail

keys_found=0

for key in GOOGLE_API_KEY OPENAI_API_KEY ANTHROPIC_API_KEY; do
  if [[ -n "${!key:-}" ]]; then
    echo "Found $key"
    keys_found=1
  fi
done

if [[ "$keys_found" -eq 0 ]]; then
  echo "WARNING: No LLM API key found. UX usability tests will be skipped."
  echo "Set one of: GOOGLE_API_KEY, OPENAI_API_KEY, ANTHROPIC_API_KEY"
  echo "Free tier: Google Gemini 2.0 Flash — https://ai.google.dev/"
  exit 1
fi

exit 0
```

### CI Workflow (GitHub Actions)

```yaml
# .github/workflows/ui-ux-tests.yml
name: UI/UX Tests

on:
  pull_request:
  push:
    branches: [main]

jobs:
  coverage:
    name: UI Requirements Coverage
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '24'
      - run: npm install -g agent-browser
      - run: agent-browser install
      - run: npx playwright install --with-deps
      # Start the app (adjust for your project)
      - run: npm run dev &
      - run: npx wait-on http://localhost:3000
      # Run coverage tests — always runs, no API keys needed
      - run: npx playwright test tests/ui-coverage/
      # Coverage gaps fail the build
      - run: agent-browser close

  usability:
    name: UX Usability Tests
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '24'
      - run: npm install -g agent-browser
      - run: agent-browser install
      - run: npm install @browserbasehq/stagehand
      - run: npx playwright install --with-deps
      - run: npm run dev &
      - run: npx wait-on http://localhost:3000
      # Check for LLM keys — graceful skip if missing
      - name: Detect LLM keys
        id: llm-keys
        continue-on-error: true
        run: |
          if ./scripts/detect-llm-keys.sh; then
            echo "has-keys=true" >> $GITHUB_OUTPUT
          else
            echo "has-keys=false" >> $GITHUB_OUTPUT
          fi
      - name: Run usability smoke tests
        if: steps.llm-keys.outputs.has-keys == 'true'
        run: npx playwright test tests/ux-usability/ --grep @smoke
      - name: Skip usability tests (no keys)
        if: steps.llm-keys.outputs.has-keys == 'false'
        run: |
          echo "UX usability tests skipped: no LLM API key found."
          echo "Set GOOGLE_API_KEY / OPENAI_API_KEY / ANTHROPIC_API_KEY as a repository secret to enable."
      - run: agent-browser close
```

### Mobile CI (GitHub Actions + agent-device)

```yaml
# .github/workflows/mobile-ui-ux-tests.yml
name: Mobile UI/UX Tests

on:
  pull_request:

jobs:
  ios-coverage:
    name: iOS Requirements Coverage
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '22'
      - run: npm install -g agent-device@latest
      - run: agent-device doctor
      # Build and install the app (adjust for your project)
      - run: xcodebuild -project MyApp.xcodeproj -scheme MyApp -destination 'platform=iOS Simulator,name=iPhone 16' build
      - run: agent-device open MyApp --platform ios
      # Run coverage replay scripts — always runs, no API keys needed
      - run: agent-device replay tests/ui-coverage/mobile/checkout.ad
      - run: agent-device close

  android-usability:
    name: Android UX Usability
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '22'
      - run: npm install -g agent-device@latest
      - run: curl -fsSL https://raw.githubusercontent.com/final-run/finalrun-agent/main/scripts/install.sh | bash
      # Check for LLM keys — graceful skip if missing
      - name: Detect LLM keys
        id: llm-keys
        continue-on-error: true
        run: |
          if ./scripts/detect-llm-keys.sh; then
            echo "has-keys=true" >> $GITHUB_OUTPUT
          else
            echo "has-keys=false" >> $GITHUB_OUTPUT
          fi
      - name: Run usability tests
        if: steps.llm-keys.outputs.has-keys == 'true'
        run: finalrun suite .finalrun/suites/critical-paths.yaml --platform android
      - name: Skip usability tests (no keys)
        if: steps.llm-keys.outputs.has-keys == 'false'
        run: |
          echo "UX usability tests skipped: no LLM API key found."
          echo "Set GOOGLE_API_KEY / OPENAI_API_KEY / ANTHROPIC_API_KEY as a repository secret to enable."
```

## Pre-Commit Hook

Coverage tests are fast enough for pre-commit hooks. Usability tests are not
(token costs, latency).

```bash
#!/usr/bin/env bash
# .husky/pre-commit — run UI coverage tests only
npx playwright test tests/ui-coverage/ --quiet
```

## Quality Gate Summary

| Gate | When | Keys Needed | Fails Build |
|------|------|-------------|-------------|
| Unit tests | PR + pre-commit | No | Yes |
| UI coverage tests | PR + pre-commit | No | Yes |
| Usability smoke | PR | Yes | No (skip if no keys) |
| Full usability suite | Nightly + release | Yes | No (skip if no keys) |

The gate ensures that missing LLM keys never block development — coverage
testing always enforces requirements, usability testing adds value when
keys are available.
