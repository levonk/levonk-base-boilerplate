# Test Patterns

Common unit test patterns — parametrized tests, test doubles (mocks, stubs,
fakes), fixtures, and async testing.

## Parametrized / Data-Driven Tests

When the same logic should hold across multiple inputs, use one parametrized
test instead of N copy-pasted tests.

**Vitest:**
```typescript
it.each([
  [0, 0],
  [1, 1],
  [2, 2],
  [10, 55],
  [-1, undefined],
])("fibonacci(%i) returns %i", (input, expected) => {
  expect(fibonacci(input)).toBe(expected);
});
```

**pytest:**
```python
@pytest.mark.parametrize("input,expected", [
    (0, 0),
    (1, 1),
    (2, 2),
    (10, 55),
    (-1, None),
])
def test_fibonacci(input, expected):
    assert fibonacci(input) == expected
```

**Rules:**
- Each row is one logical test case — if a row fails, the others still run
- Name the test with the inputs in the format string so failures are readable
- Don't mix scenarios — if some rows should throw and others should return, split into two parametrized tests

## Test Doubles

### Stub

Returns canned answers when called. **Does not** verify interactions.

```typescript
const userStub: User = { id: "123", name: "Alice", email: "alice@example.com" };
const repoStub = {
  findById: (id: string) => id === "123" ? userStub : null,
};
const service = new UserService(repoStub);

expect(service.getUserName("123")).toBe("Alice");
```

Use a stub when the unit under test needs a dependency to provide inputs but
you don't care how the unit interacts with it.

### Mock

Records calls and lets you assert on them. **Verifies interactions.**

```typescript
const emailerMock = { send: vi.fn() };
const service = new UserService(repo, emailerMock);

service.welcome("123");

expect(emailerMock.send).toHaveBeenCalledWith({
  to: "alice@example.com",
  subject: "Welcome!",
});
expect(emailerMock.send).toHaveBeenCalledTimes(1);
```

Use a mock when the **interaction itself** is the behavior — e.g., "the
service sends exactly one welcome email with the right fields."

**Caution:** mocks couple tests to implementation. If you change the number
of internal calls without changing observable behavior, mock-based tests
break. Prefer stubs + asserting on the return value.

### Fake

A working but simplified implementation of a dependency.

```typescript
class InMemoryUserRepo implements UserRepo {
  private users = new Map<string, User>();

  save(user: User) { this.users.set(user.id, user); }
  findById(id: string) { return this.users.get(id) ?? null; }
}

const repo = new InMemoryUserRepo();
const service = new UserService(repo);

repo.save({ id: "123", name: "Alice", email: "alice@example.com" });
expect(service.getUserName("123")).toBe("Alice");
```

Use a fake when the dependency's behavior is part of the test's contract —
e.g., a repository that should persist and retrieve. Fakes give you real
behavior without the cost of the real implementation (database, network).

**Prefer fakes over mocks.** Fakes test behavior; mocks test interactions.

### Spy

Wraps a real implementation and records calls, but delegates to the real
implementation. Use when you want to verify an interaction without replacing
the behavior.

```typescript
const realRepo = new UserRepo(db);
const repoSpy = vi.spyOn(realRepo, "findById");

const service = new UserService(realRepo);
service.getUserName("123");

expect(repoSpy).toHaveBeenCalledWith("123");
```

## Fixtures

A fixture is the **arrange** state — the inputs and dependencies a test
needs. Good fixtures are:

- **Immutable** — the test can't mutate the fixture
- **Minimal** — only what this test needs, nothing more
- **Reusable** — common fixtures live in factory functions, not `beforeEach` with mutable state

**Factory pattern (preferred over `beforeEach`):**
```typescript
function createCart(items: Item[] = []): Cart {
  return new Cart(items);
}

function createItem(name: string, price: number, opts: ItemOpts = {}): Item {
  return new Item(name, price, opts);
}

it("calculateTotal_emptyCart_returnsZero", () => {
  const cart = createCart();
  expect(cart.calculateTotal()).toBe(0);
});

it("calculateTotal_singleItem_returnsItemPrice", () => {
  const cart = createCart([createItem("book", 20)]);
  expect(cart.calculateTotal()).toBe(20);
});
```

**Why factories over `beforeEach`:**
- Each test gets a fresh instance — no state leakage
- The test shows what it needs — readability
- Tests can override defaults per-test — flexibility
- No hidden setup that the test doesn't show — maintainability

## Async Testing

**Always await the act step.** A test that doesn't await an async operation
is a test that passes before the operation completes.

```typescript
it("fetchUser_validId_returnsUser", async () => {
  const repo = createRepo();
  const service = new UserService(repo);

  const user = await service.fetchUser("123"); // await!

  expect(user).toEqual({ id: "123", name: "Alice" });
});
```

**Testing rejections:**
```typescript
it("fetchUser_notFound_throwsNotFoundError", async () => {
  const service = new UserService(emptyRepo);

  await expect(service.fetchUser("missing")).rejects.toThrow(NotFoundError);
});
```

**Don't use fake timers unless you're testing time itself.** Real async with
real awaits is more trustworthy than `vi.useFakeTimers()` for most cases.

## Test Organization

- Group tests by the unit they test (one `describe` per class or module)
- Within a `describe`, order tests from simplest to most complex behavior
- Order describes from the most central unit to the most peripheral
- Keep all tests for a unit in one file — don't split across files

## See Also

- [Roy Osherove Principles](roy-osherove-principles.md) — the three pillars and naming conventions
- [Test Anti-Patterns](test-anti-patterns.md) — what to avoid

## Sources

- Synthesized from common unit testing practice and Roy Osherove's "The Art of Unit Testing"
- Migrated from `src/current/rules/software-dev/general/code-create-unit-tests.md`
