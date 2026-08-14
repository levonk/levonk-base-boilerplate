# Requirements Extraction

How to parse requirements documents into structured UI requirements for
coverage test generation.

## Sources

Requirements come from:

- **PRD (Product Requirements Document)** — functional requirements,
  non-functional requirements, user stories
- **User stories** — "As a [role], I want to [action] so that [outcome]"
- **Acceptance criteria** — Given/When/Then or checklist format
- **Design specs** — Figma descriptions, wireframe annotations
- **Existing tests** — reverse-engineer requirements from existing
  Playwright/Appium tests (Input Mode 2)

## Extraction Process

### Step 1: Identify UI elements

Scan the requirements document for nouns that represent UI components:

- Buttons ("Submit", "Cancel", "Add to Cart")
- Form fields ("Email", "Password", "Phone Number")
- Navigation items ("Dashboard", "Settings", "Profile")
- Display elements ("Order total", "User avatar", "Status badge")
- Interactive widgets ("Date picker", "Search bar", "Filter dropdown")

For each element, record:

| Field | Example |
|-------|---------|
| ID | `REQ-001` |
| Element | Submit button |
| Type | button |
| Role | button |
| Name/Label | "Submit" |
| testid | `submit-btn` (if specified) |
| Page/Screen | Checkout page |
| Requirement source | PRD §3.2 |

### Step 2: Identify UI flows

Scan for sequences of actions a user performs:

- "User logs in, navigates to settings, and updates their profile"
- "User adds item to cart, proceeds to checkout, and completes payment"
- "User searches for a product, filters by price, and views details"

For each flow, record:

| Field | Example |
|-------|---------|
| ID | `FLOW-001` |
| Name | Checkout flow |
| Steps | Navigate to cart → Click checkout → Fill payment → Confirm |
| Entry point | Cart page |
| Exit state | Order confirmation |
| Requirement source | User story US-12 |

### Step 3: Identify UI states

Scan for conditional or state-dependent UI:

- "When the cart is empty, show 'Your cart is empty' message"
- "When payment fails, show error message with retry button"
- "Admin users see an additional 'Manage Users' nav item"

For each state, record:

| Field | Example |
|-------|---------|
| ID | `STATE-001` |
| Name | Empty cart state |
| Condition | Cart has zero items |
| Expected element | "Your cart is empty" message |
| Page/Screen | Cart page |
| Requirement source | PRD §4.1 |

## Output Format

The extraction produces a structured list — one entry per requirement. This
list is the input to [Coverage Test Generation](coverage-test-generation.md).

```yaml
requirements:
  - id: "REQ-001"
    type: "element"
    element: "Submit button"
    role: "button"
    name: "Submit"
    testid: "submit-btn"
    page: "Checkout"
    source: "PRD §3.2"
  - id: "FLOW-001"
    type: "flow"
    name: "Checkout flow"
    entry: "Cart page"
    steps:
      - "Navigate to cart"
      - "Click checkout button"
      - "Fill payment form"
      - "Click confirm"
    exit_state: "Order confirmation"
    source: "US-12"
  - id: "STATE-001"
    type: "state"
    name: "Empty cart"
    condition: "Cart has zero items"
    expected_element: "Your cart is empty message"
    page: "Cart"
    source: "PRD §4.1"
```

## From-Scratch Mode

When no requirements document exists (Input Mode 3), interview the user:

1. "What are the main screens in your application?"
2. "What can a user do on each screen?"
3. "What are the critical user tasks (the top 3-5 things a user must
   accomplish)?"
4. "Are there any conditional states (empty, error, loading, admin-only)?"

Use the answers to populate the requirements list. The user's task
descriptions become both coverage requirements and usability task
definitions.
