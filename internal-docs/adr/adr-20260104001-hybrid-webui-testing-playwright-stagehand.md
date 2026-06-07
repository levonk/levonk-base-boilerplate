---
modeline: "vim: set ft=markdown:"
title: "ADR: Hybrid Graphical Testing with Playwright and Stagehand"
adr-id: "adr-20260104001"
slug: "20260104001-hybrid-webui-testing-playwright-stagehand"
url: "https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20260104001-hybrid-webui-testing-playwright-stagehand.md"
synopsis: "Adopt a hybrid approach for graphical web application testing, using Playwright for deterministic checks and Stagehand for AI-powered, resilient automation."
author: "https://github.com/levonk"
date-created: "2026-01-04"
date-updated: "2026-01-04"
version: "1.0.0"
status: "proposed"
tags: ["doc/architecture/adr", "testing", "playwright", "stagehand", "webui"]
related-to: ["adr-20251106002-vitest-for-testing", "adr-20251129003-python-services-and-packages-standard"]
package: "@job-aide/tools-node-testing-webui"
---

# ADR: Hybrid Graphical Testing with Playwright and Stagehand

- belongs in `internal-docs/adr/*.md`

---

## Context

We need a resilient and efficient way to perform graphical tests for web applications. While Playwright is excellent for deterministic tests, it can be brittle when UI selectors change. Stagehand provides an AI-powered abstraction layer that increases resilience but introduces latency and cost.

The short answer is: They are not redundant. In fact, Stagehand is built on top of Playwright.

Think of Playwright as the engine and Stagehand as an AI-powered driver.

## Decision

We will use a hybrid approach for graphical tests:

- **Playwright** for deterministic, performance-critical, and stable infrastructure tests (80% of cases).
- **Stagehand** for brittle flows, complex navigation, third-party integrations, and cross-app workflows (20% of cases).

The standard package for these utilities will be `@job-aide/tools-node-testing-webui` (located at `packages/active/tools/node/testing/webui/typescript`).

## Rationale

Here is the breakdown of why you should likely use both, and how to decide which tool handles which test.

### 1. Are they redundant?

No.

Playwright is a low-level automation framework. It requires you to provide specific selectors (#login-btn, .submit-form). It is incredibly fast and cheap to run, but it breaks the moment a developer changes a CSS class or an ID.

Stagehand is an abstraction layer that uses LLMs (like GPT-4o) to "see" the page and interact with it using natural language or intent. It uses Playwright under the hood to actually click the buttons it finds.

### 2. Should you split tests between them?

Yes. This is currently the "best practice" for modern QA engineering. You should use a hybrid approach.

**Use Playwright (Deterministic) for:**

- **High-Volume Smoke Tests**: Testing if the page loads, if the API responds, or basic "happy paths."
- **Performance Critical Tests**: Playwright executes in milliseconds. AI requests take seconds.
- **Stable Infrastructure**: If you have a stable design system with data-testid attributes that rarely change, Playwright is superior because it is free (no token costs) and 100% predictable.
- **Deep Assertions**: Checking if a specific value in a table is exactly 1,204.50.

**Use Stagehand (AI) for:**

- **Brittle Flows**: Areas of the UI that change frequently (e.g., a marketing landing page or a checkout flow undergoing A/B testing).
- **Complex Navigation**: Scenarios where you’d normally have to write 20 lines of "Wait for element," "Scroll to view," etc. You can just tell Stagehand: "Find the checkout button and click it."
- **Third-Party Integrations**: Testing how your app interacts with platforms you don't control (like a Stripe portal or a Google Login popup) where selectors might change without notice.
- **Cross-App Workflows**: If you need to navigate through three different websites to complete a flow.

### 3. Does Stagehand do "deterministic" tests poorly?

It’s not that Stagehand is "bad" at deterministic tests, but it is inefficient for them.

If you use Stagehand for a test that could be deterministic, you encounter these three issues:

- **Latency**: An LLM call takes 2–10 seconds. A CSS selector takes 0.001 seconds. If you have 500 tests, Stagehand will make your CI/CD pipeline take hours instead of minutes.
- **Cost**: Every time Stagehand "thinks," it costs you money in LLM tokens (OpenAI/Anthropic). Playwright is free.
- **The "Flake" Factor**: Even the best AI has a non-zero chance of hallucinating or failing to find an object it found yesterday. Deterministic tests (Playwright) are binary: either the element is there or it isn't.

### The Strategy: The 80/20 Rule

Most teams are moving toward an 80/20 split:

- **80% Playwright**: Use this for your core business logic, API testing, and stable UI components. Use data-testid to keep them from breaking.
- **20% Stagehand**: Use this for "End-to-End" flows that simulate a human user. Use it for the "flaky" parts of your app that break Playwright scripts every week.

## Technical Approach

### Integration

Don't choose one. Use Playwright as your primary framework. When you hit a specific test that is constantly breaking because the UI is too dynamic or the selectors are a mess, wrap that specific test (or that specific step) in Stagehand.

Stagehand actually allows you to pass its page object directly into Playwright logic, so you can switch between "AI mode" and "Deterministic mode" in the same script.

### Running Stagehand for Free

To run Stagehand tests for free, focus on three strategies: using Local LLMs (via Ollama), using Free Tier Cloud APIs (like Google Gemini), and utilizing Stagehand’s Caching to skip AI calls entirely after the first run.

#### 1. The Best Free Option: Google Gemini 2.0 Flash

Currently, this is the most recommended way to run Stagehand for free. Google’s "Flash" models are fast, highly accurate for browser automation, and have a very generous free tier.

- **Free Tier Limits**: ~15 requests per minute and 1,500 requests per day (as of late 2025).
- **Setup**: Get a free API key from Google AI Studio. Add `GOOGLE_GENERATIVE_AI_API_KEY=your_key` to your `.env` file.

```typescript
import { Stagehand } from "@browserbasehq/stagehand";

const stagehand = new Stagehand({
  env: "LOCAL", // Runs on your machine, not the cloud
  modelName: "google/gemini-2.0-flash", // High-performing free model
});
```

#### 2. The Truly Local Option: Ollama

If you want 100% privacy and zero cost, run Stagehand with Ollama. Note: Stagehand requires "Structured Outputs" (JSON mode), and smaller local models often struggle.

- **Setup**: Install Ollama and run a model like `llama3.1:8b` or `qwen2.5:7b`.
- **Manual Config**: Point Stagehand to your local URL:

```typescript
const stagehand = new Stagehand({
  env: "LOCAL",
  llmClient: new CustomOpenAIClient({
    modelName: "llama3.1",
    client: new OpenAI({
      apiKey: "ollama", // Required but ignored by Ollama
      baseURL: "http://localhost:11434/v1",
    }),
  }),
});
```

#### 3. Use "Auto-Caching" to Save Tokens

Stagehand has a powerful feature called Action Caching. Once Stagehand successfully finds an element (e.g., the "Checkout" button) using AI, it caches the Playwright selector for that action.

- **Benefit**: On the second run of your test, Stagehand checks the cache. If the page hasn't changed, it uses the raw Playwright selector without calling the LLM.
- **How to use it**: Ensure `cacheDir` is set in your config (default: `./stagehand/cache`).
- **Result**: Tests cost $0.00 after the first successful run until the UI changes.

#### 4. Other Free API Providers

- **Groq**: Incredible speed. Use `groq/llama-3.3-70b-versatile`.
- **Cerebras**: Extremely fast inference, often has a free trial/tier.
- **Together AI**: Offers free credit to new users.

### Configuration and Validation

To ensure Stagehand is running locally and utilizing the cache:

#### 1. Configuration File (Best Practice)

```typescript
// stagehand.config.ts
import type { StagehandConfig } from "@browserbasehq/stagehand";

export const stagehandConfig: StagehandConfig = {
  env: "LOCAL",
  cacheDir: "./stagehand/cache", // Default or custom path
  modelName: "gpt-4o",
  modelClientOptions: {
    apiKey: process.env.OPENAI_API_KEY,
  },
};
```

#### 2. Programmatic Assertion (Unit Test)

```typescript
// tests/config.test.ts
import { stagehandConfig } from "../stagehand.config";
import { expect, test } from "vitest";
import fs from "fs";
import path from "path";

test("Stagehand is configured for local execution and caching", () => {
  expect(stagehandConfig.env).toBe("LOCAL");
  expect(stagehandConfig.cacheDir).toBeDefined();

  const cachePath = path.resolve(stagehandConfig.cacheDir!);
  const exists = fs.existsSync(cachePath);
  expect(exists).toBe(true);
});
```

#### 3. Runtime Verification (The "Fail-Safe" Check)

```typescript
import { Stagehand } from "@browserbasehq/stagehand";
import { stagehandConfig } from "./stagehand.config";

async function runTest() {
  if (stagehandConfig.env !== "LOCAL") {
    throw new Error("CRITICAL: Stagehand is not in LOCAL mode. Stopping to prevent cloud costs.");
  }

  const stagehand = new Stagehand(stagehandConfig);
  await stagehand.init();
}
```

### Shared Wrapper Package Pattern

We centralize logic that enforces `LOCAL` mode and caching in a "Testing Base" package (e.g., `@job-aide/tools-node-testing-webui`).

**Key Benefits**:

- **Global Cache Invalidation**: Update the package to change `cacheDir` suffix (e.g., `.stagehand-cache-v2`) and all projects update simultaneously.
- **Safety Rails**: Bake in environment checks (e.g., `GOOGLE_API_KEY`).
- **Model Management**: Switch models in one place for all projects.
- **Cost Control**: Prevent accidental `env: "BROWSERBASE"` usage.

## Affected Components

- All web application E2E test suites.
- CI/CD pipelines (test duration and token usage).
- Shared testing utilities package.

## Consequences

### Positive

- **Resilience**: Tests survive UI changes that would break pure Playwright scripts.
- **Efficiency**: Hybrid approach balances speed (Playwright) and maintenance (Stagehand).
- **Cost Control**: Local LLMs and caching minimize/eliminate API costs.
- **Consistency**: Standardized wrapper package ensures best practices across the monorepo.

### Negative

- **Latency**: AI-powered tests are slower than deterministic ones.
- **Complexity**: Developers need to decide which tool to use for each test step.
- **Flake Factor**: AI has a non-zero chance of hallucinations compared to binary selectors.

## Alternatives Considered

- **Playwright Only**: Rejected due to high maintenance cost of brittle selectors.
- **Stagehand Only**: Rejected due to latency, cost, and inefficiency for simple assertions.

## Rollout / Migration

1. **Scaffold Shared Package**: Create `@job-aide/tools-node-testing-webui` with standard factory and configuration.
2. **Standardize CI/CD**: Ensure CI environments support local Chromium and have required LLM keys (if not using local LLMs).
3. **Incremental Adoption**: Identify the top 20% flakiest E2E tests and migrate them to use Stagehand wrappers.

## Validation

- Monitor CI/CD test duration and token costs.
- Track reduction in "brittle selector" related test failures.

## References

- [Playwright Documentation](https://playwright.dev/)
- [Stagehand Documentation](https://docs.stagehand.dev/)
- [Google Gemini 2.0 Flash](https://ai.google.dev/gemini-api/docs/models/gemini#gemini-2.0-flash)
- [Ollama](https://ollama.com/)

<!-- vim: set ft=markdown: -->
