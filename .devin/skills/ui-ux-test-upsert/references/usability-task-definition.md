# Usability Task Definition

How to define natural-language user tasks for usability testing. The key
principle: **describe the goal, not the steps.** If you include step-by-step
instructions, you are testing the instructions, not the UI.

## What Makes a Good Usability Task

A good usability task:

1. **States the goal** — what the user wants to accomplish
2. **Does NOT state the steps** — how to accomplish it is what the test
   discovers
3. **Is realistic** — something a real user would actually do
4. **Has a clear success criterion** — how to know the task is complete
5. **Is platform-appropriate** — works within the application's scope

## Good vs Bad Task Definitions

### Bad (includes steps)

> "Click on the Products tab, search for 'wireless headphones', click the
> first result, click 'Add to Cart', click the cart icon, click 'Checkout',
> fill in the shipping form, and complete the purchase."

This tests whether the AI can follow instructions, not whether the UI is
usable.

### Good (goal only)

> "Find wireless headphones and purchase them."

This tests whether the UI guides the user from intent to completion without
external documentation.

## Task Sources

### From User Stories

User stories are the best source — they already describe goals:

| User Story | Usability Task |
|------------|----------------|
| "As a shopper, I want to find products so I can buy them" | "Find a product you like and add it to your cart" |
| "As a team admin, I want to invite members so we can collaborate" | "Invite a new member to your team" |
| "As a user, I want to reset my password so I can regain access" | "Reset your password" |

### From Critical Paths

Identify the 3-5 critical paths in the application — the tasks that users
must be able to accomplish for the application to deliver value:

1. **Onboarding** — "Sign up for a new account"
2. **Core action** — "Complete the primary action the app exists for"
3. **Settings** — "Change your account settings"
4. **Recovery** — "Recover from an error or forgotten password"
5. **Offboarding** — "Cancel your subscription / delete your account"

### From Support Tickets

Support tickets reveal tasks users struggle with — these are the highest-value
usability tests because they target known pain points.

## Task Classification

Classify each task by criticality for CI scheduling:

| Class | Description | CI Schedule |
|-------|-------------|-------------|
| `critical` | Tasks users must accomplish for the app to deliver value | Every PR (smoke) + nightly (full) |
| `important` | Tasks most users will attempt | Nightly |
| `edge-case` | Tasks few users attempt but must work | Release |

## Output Format

The task definition produces a structured list — one entry per task. This
list is the input to [Usability Test Generation](usability-test-generation.md).

```yaml
usability_tasks:
  - id: "TASK-001"
    name: "Purchase a product"
    goal: "Find a product you like and purchase it"
    platform: "web"
    class: "critical"
    success_criterion: "Order confirmation screen is visible"
    source: "US-12"
  - id: "TASK-002"
    name: "Invite team member"
    goal: "Invite a new member to your team"
    platform: "web"
    class: "critical"
    success_criterion: "Invitation sent confirmation is visible"
    source: "US-08"
  - id: "TASK-003"
    name: "Reset password"
    goal: "Reset your password"
    platform: "mobile"
    class: "critical"
    success_criterion: "Password changed confirmation is visible"
    source: "US-31"
```

## Anti-Patterns

- **Do not include UI element names** — "Click the 'Settings' gear icon"
  tells the AI where to look. Say "Change your settings" instead.
- **Do not include navigation paths** — "Go to Dashboard > Settings >
  Profile" is a step-by-step instruction. Say "Update your profile" instead.
- **Do not include form field names** — "Fill in the 'email' field with
  test@test.com" is an instruction. Say "Sign up with your email" instead.
- **Do include necessary test data** — "Use the test credit card
  4242424242424242" is acceptable — it provides data, not navigation.
