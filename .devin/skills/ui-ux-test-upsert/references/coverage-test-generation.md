# Coverage Test Generation

How to map extracted requirements to agent-browser (web) and agent-device
(mobile) verification commands.

## Mapping Rules

### Elements → Find Commands

| Requirement Type | Web (agent-browser) | Mobile (agent-device) |
|-----------------|---------------------|----------------------|
| Button | `find role button text --name "<name>"` | snapshot → find ref by role+name |
| Form field | `find label "<label>" text` | snapshot → find ref by label |
| Link | `find role link text --name "<text>"` | snapshot → find ref by role+name |
| Heading | `find role heading text --name "<text>"` | snapshot → find ref by role+name |
| testid element | `find testid "<id>" text` | snapshot → find ref by testid |
| Image | `find alt "<alt text>" text` | snapshot → find ref by label |

### Flows → Command Sequences

For each flow, produce a sequence of commands that navigates from the entry
point to the exit state:

```bash
# Web flow: Checkout
agent-browser open http://localhost:3000/cart
agent-browser snapshot
agent-browser find testid "checkout-btn" click --settle
agent-browser snapshot
agent-browser find label "Card Number" fill "4242424242424242" --settle
agent-browser find testid "confirm-purchase" click --settle
agent-browser snapshot
agent-browser find text "Order confirmed" text  # verify exit state
```

```bash
# Mobile flow: Checkout
agent-device open MyApp --platform ios
agent-device snapshot -i
agent-device press @e_checkout --settle        # ref from snapshot
agent-device fill @e_cardnumber "4242424242424242" --settle
agent-device press @e_confirm --settle
agent-device snapshot -i
# verify "Order confirmed" text is present in snapshot
```

### States → Conditional Checks

For each state, produce a command that sets up the condition and verifies
the expected element:

```bash
# Web state: Empty cart
agent-browser open http://localhost:3000/cart
agent-browser eval "localStorage.clear(); location.reload()"  # clear cart
agent-browser snapshot
agent-browser find text "Your cart is empty" text  # verify message
```

## Test File Structure

Generate test files alongside existing tests. Use the project's detected test
framework (Vitest, Playwright test runner, etc.):

```
tests/
  ui-coverage/
    web/
      checkout.spec.ts        # Playwright test runner + agent-browser
      settings.spec.ts
    mobile/
      checkout.ad             # agent-device replay script
      settings.ad
```

### Web Coverage Test (Playwright + agent-browser)

```typescript
import { test, expect } from "@playwright/test";
import { execSync } from "child_process";

test.describe("UI Requirements Coverage — Checkout", () => {
  test.beforeAll(() => {
    execSync("agent-browser open http://localhost:3000");
  });

  test.afterAll(() => {
    execSync("agent-browser close");
  });

  test("REQ-001: Submit button exists on checkout page", () => {
    execSync("agent-browser open http://localhost:3000/checkout");
    const output = execSync("agent-browser find role button text --name Submit", { encoding: "utf-8" });
    expect(output).toContain("Submit");
  });

  test("REQ-002: Email field exists on checkout page", () => {
    const output = execSync("agent-browser find label Email text", { encoding: "utf-8" });
    expect(output).toContain("Email");
  });

  test("FLOW-001: Checkout flow is reachable", () => {
    execSync("agent-browser open http://localhost:3000/cart");
    execSync("agent-browser find testid checkout-btn click --settle");
    const output = execSync("agent-browser find testid confirm-purchase text", { encoding: "utf-8" });
    expect(output).toContain("confirm-purchase");
  });
});
```

### Mobile Coverage Test (agent-device replay script)

agent-device replay scripts (`.ad`) record a session for CI replay:

```
# checkout.ad — Coverage test for checkout flow
open MyApp --platform ios
snapshot -i
press @e_checkout --settle
fill @e_cardnumber "4242424242424242" --settle
press @e_confirm --settle
snapshot -i
assert text "Order confirmed"
screenshot ./evidence/checkout-complete.png
close
```

## Coverage Report

After running coverage tests, produce a structured report:

```yaml
coverage_report:
  total_requirements: 45
  covered: 42
  gaps: 3
  gaps_detail:
    - id: "REQ-023"
      element: "Export to CSV button"
      query: "find role button text --name 'Export to CSV'"
      result: "not found"
      page: "Reports"
      source: "PRD §5.3"
    - id: "FLOW-007"
      name: "Password reset flow"
      result: "not reachable"
      source: "US-31"
    - id: "STATE-004"
      name: "Admin-only nav item"
      result: "not found"
      source: "PRD §6.1"
```

Coverage gaps fail the CI build. Each gap includes the requirement source for
traceability.
