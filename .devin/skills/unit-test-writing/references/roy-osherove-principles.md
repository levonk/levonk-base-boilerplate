# Roy Osherove Principles

Core principles from Roy Osherove's "The Art of Unit Testing" — the canonical
reference for writing readable, maintainable, and trustworthy unit tests.

## The Three Pillars

Every unit test must satisfy all three pillars. If a test fails any of them,
it's a liability, not an asset.

### 1. Readable

A new team member should understand the test in **seconds** — without reading
the production code first.

**How to achieve readability:**
- Use the three-part naming pattern: `MethodUnderTest_Scenario_ExpectedOutcome`
- Separate Arrange, Act, Assert with blank lines and comments
- Use meaningful variable names — `eligibleItem`, not `i` or `obj`
- Avoid magic values — `const ELIGIBLE_PRICE = 20` beats `20`
- Hide irrelevant setup behind factory functions or builders
- One test = one behavior = one logical assertion

**Readability smell test:** cover the test name and ask a teammate to predict
what the test does. If they can't, the name or the structure is wrong.

### 2. Maintainable

The test should survive **unrelated** refactors of the production code. If
renaming a private method breaks your test, your test is overspecified.

**How to achieve maintainability:**
- Test through the public API, not private internals
- Assert on observable outcomes (return values, state changes), not call counts
- Avoid asserting on order of internal operations
- Use fakes and stubs, not mocks, when possible — mocks couple to interactions
- Centralize test setup in factory functions, not in `beforeEach` with mutable state
- Remove dead tests; don't disable them with `.skip` and forget

**Maintainability smell test:** rename a private method in the production
code. Do your tests still pass? They should.

### 3. Trustworthy

The test should **fail when the code is wrong** and **pass when the code is
right** — and never pass for the wrong reason.

**How to achieve trustworthiness:**
- Make the test fail first (TDD) or watch it fail after injecting a deliberate bug
- Don't catch exceptions in tests — let them propagate
- Don't write tests that always pass (`expect(true).toBe(true)`)
- Don't mock the system under test — only its dependencies
- Don't assert on tautologies (`expect(result).toBe(result)`)
- Use exact assertions, not "contains" or "matches" when you mean "equals"

**Trustworthiness smell test:** delete the body of the production function
under test. Does the test fail? It should.

## The Seven Sins of Unit Testing

1. **Multiple asserts in one test** — split into multiple tests
2. **Testing private methods** — test through the public API
3. **Overspecification** — asserting on things that don't matter to the behavior
4. **Shared mutable setup** — leaks state between tests
5. **Test logic in production code** — `if (isTest)` branches
6. **Sleep-based timing** — flaky and slow
7. **Catching exceptions to assert they're thrown** — use the framework's `expectException`

## Test Naming

The three-part pattern: `MethodUnderTest_Scenario_ExpectedOutcome`

- **MethodUnderTest** — the method being tested, exactly as it's named in code
- **Scenario** — the input or state condition being tested
- **ExpectedOutcome** — what should happen (return value, thrown exception, state change)

**Examples:**
- `calculateTotal_emptyCart_returnsZero`
- `applyDiscount_expiredDiscount_throwsExpiredDiscountError`
- `submitOrder_outOfStockItem_returnsOutOfStockError`
- `login_validCredentials_returnsAuthToken`

The name describes **behavior**, not implementation. A reader should know
what the test verifies without reading the body.

## AAA Pattern

Every test has exactly three sections:

```typescript
it("MethodUnderTest_Scenario_ExpectedOutcome", () => {
  // Arrange — minimal setup, only what this test needs
  const unit = createUnit();
  const input = createInput();

  // Act — call the unit under test exactly once
  const result = unit.methodUnderTest(input);

  // Assert — verify the single observable outcome
  expect(result).toBe(expectedOutcome);
});
```

**Rules:**
- **One Act per test** — if you have two `act` lines, you have two tests
- **One logical assertion per test** — multiple `expect` calls checking one outcome are fine; checking multiple outcomes is not
- **No logic in tests** — no `if`, no `for`, no `switch`. If you need logic, you have multiple tests

## What to Test (and What Not to Test)

**Test:**
- Public API methods
- Edge cases: empty input, null, boundary values, off-by-one
- Error paths: invalid input, missing dependencies, network failures
- State changes: did the unit's state change correctly?
- Interaction contracts: did the unit call its dependency with the right args?

**Don't test:**
- Private methods — test through the public API
- Getters and setters that just assign — they're trivial
- Third-party code — it's the vendor's job to test
- Framework features (the ORM, the DI container) — test your use of them, not them
- Configuration loading — test the configured behavior, not the loader

## Test Order

Tests should run in **any order** and produce the same result. Don't depend
on test execution order — it's a flakiness factory.

If tests share expensive setup, use a `beforeAll` for **immutable** fixtures
only. Never share mutable state across tests.

## Trust by Failing

A test you can't make fail is a test that tests nothing. Always verify your
test fails for the right reason:

1. Write the test
2. Run it — it should fail (TDD) or it should fail after you inject a bug
3. If it passes without the production code, it's a tautology — fix it

## See Also

- [Test Patterns](test-patterns.md) — parametrized tests, mocks vs stubs, fakes, fixtures
- [Test Anti-Patterns](test-anti-patterns.md) — catalog of anti-patterns with examples and fixes

## Sources

- Roy Osherove, "The Art of Unit Testing" — https://www.artofunittesting.com/
- Migrated from `src/current/rules/software-dev/general/code-create-unit-tests.md`
