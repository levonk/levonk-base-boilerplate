# Usability Test Generation

How to produce Stagehand (web) and finalrun-agent (mobile) test specs from
usability task definitions.

## Web: Stagehand Test Specs

Stagehand tests are TypeScript files that use `act()`, `agent.execute()`, and
`extract()` to drive the browser with natural language.

### Test File Structure

```
tests/
  ux-usability/
    web/
      purchase-product.spec.ts
      invite-member.spec.ts
      reset-password.spec.ts
```

### Template

```typescript
import { Stagehand } from "@browserbasehq/stagehand";
import { z } from "zod";
import { test, expect } from "@playwright/test";

const stagehand = new Stagehand({
  env: "LOCAL",
  modelName: "google/gemini-2.0-flash",
});

test.describe("UX Usability — Purchase a product", () => {
  test("TASK-001: Find a product and purchase it", async () => {
    const page = stagehand.context.pages()[0];
    await page.goto("http://localhost:3000");

    // Give the AI the goal — not the steps
    await stagehand.act("find a product you like and purchase it using test card 4242424242424242");

    // Verify the outcome
    const { success } = await stagehand.extract(
      "did the purchase complete successfully?",
      z.object({
        success: z.boolean(),
        orderNumber: z.string().optional(),
      }),
    );

    expect(success).toBe(true);
  });
});
```

### Multi-Step Tasks

For complex tasks, use `stagehand.agent()`:

```typescript
test("TASK-002: Invite a team member", async () => {
  const page = stagehand.context.pages()[0];
  await page.goto("http://localhost:3000");

  const agent = stagehand.agent();
  await agent.execute("invite a new member to your team using email test@example.com");

  const { success } = await stagehand.extract(
    "was the invitation sent successfully?",
    z.object({ success: z.boolean() }),
  );

  expect(success).toBe(true);
});
```

### Cost Control

- Use `google/gemini-2.0-flash` for the free tier (or set via env).
- Stagehand auto-caches actions — repeat runs skip AI calls.
- For local LLMs, configure Ollama as the model provider.

## Mobile: finalrun-agent Test Specs

finalrun-agent tests are YAML files with natural-language steps.

### Test File Structure

```
.finalrun/
  tests/
    purchase-product.yaml
    invite-member.yaml
    reset-password.yaml
  suites/
    critical-paths.yaml
```

### Template

```yaml
# .finalrun/tests/purchase-product.yaml
name: "TASK-001: Purchase a product"
steps:
  - "Open the app and find a product you like"
  - "Purchase it using test card 4242424242424242"
expected_state:
  - "Order confirmation screen is visible"
  - "Order number is displayed"
```

### Suite File

Group tasks by class for CI scheduling:

```yaml
# .finalrun/suites/critical-paths.yaml
name: "Critical path usability tests"
tests:
  - tests/purchase-product.yaml
  - tests/invite-member.yaml
  - tests/reset-password.yaml
```

### Running

```bash
# Single test
finalrun test purchase-product.yaml --platform android --model google/gemini-3-flash-preview

# Suite
finalrun suite critical-paths.yaml --platform android --model google/gemini-3-flash-preview
```

## Usability Test Report

After running usability tests, classify each result:

| Result | Meaning | Action |
|--------|---------|--------|
| `PASS` | Task completed successfully | No action |
| `PARTIAL` | Task completed with difficulty (wrong turns, backtracking) | Report as usability issue |
| `FAIL` | Task not completed | Report as critical usability issue |

```yaml
usability_report:
  total_tasks: 8
  passed: 5
  partial: 2
  failed: 1
  results:
    - id: "TASK-001"
      name: "Purchase a product"
      result: "PASS"
      steps_taken: 4
      duration_seconds: 12
    - id: "TASK-004"
      name: "Export data to CSV"
      result: "PARTIAL"
      steps_taken: 9
      notes: "Agent took wrong turn into Settings before finding Export in Reports"
    - id: "TASK-006"
      name: "Cancel subscription"
      result: "FAIL"
      notes: "Agent could not find cancellation flow — buried in 3 levels of settings"
```

Partial and fail results are usability issues to fix, not test failures. The
report is delivered to the product team for UI improvements.
