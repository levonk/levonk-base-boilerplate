# Test Anti-Patterns

Catalog of common unit test anti-patterns, why they're harmful, and how to
fix them.

## 1. Multiple Asserts in One Test

**Smell:** One test checks multiple unrelated outcomes.

```typescript
// BAD
it("userService_worksCorrectly", () => {
  const user = service.createUser("Alice");
  expect(user.id).toBeDefined();
  expect(user.name).toBe("Alice");
  expect(user.createdAt).toBeDefined();
  expect(repo.save)._calledOnceWith(user);
  expect(emailer.send)._calledOnce();
});
```

**Why it's bad:**
- When it fails, you don't know which assertion failed (without reading the stack)
- One failing assertion hides failures in later asserts
- Tests multiple behaviors — violates single-behavior rule

**Fix:** Split into multiple tests, one per behavior.

```typescript
it("createUser_returnsUserWithGeneratedId", () => {
  const user = service.createUser("Alice");
  expect(user.id).toBeDefined();
});

it("createUser_returnsUserWithProvidedName", () => {
  const user = service.createUser("Alice");
  expect(user.name).toBe("Alice");
});

it("createUser_persistsUserToRepository", () => {
  service.createUser("Alice");
  expect(repo.save)._calledOnce();
});

it("createUser_sendsWelcomeEmail", () => {
  service.createUser("Alice");
  expect(emailer.send)._calledOnce();
});
```

## 2. Testing Private Methods

**Smell:** Reaching into private internals to test them directly.

```typescript
// BAD
it("validateEmail_internalValidator_returnsTrueForValidEmail", () => {
  const validator = new EmailValidator();
  expect((validator as any).validateInternal("alice@example.com")).toBe(true);
});
```

**Why it's bad:**
- Couples tests to implementation — refactoring breaks tests
- Tests the "how" not the "what"
- If a private method needs its own tests, it probably wants to be its own class

**Fix:** Test through the public API.

```typescript
it("isValid_validEmail_returnsTrue", () => {
  const validator = new EmailValidator();
  expect(validator.isValid("alice@example.com")).toBe(true);
});
```

If the private method is complex enough to warrant direct testing, extract
it into its own class with a public API and test that.

## 3. Overspecification

**Smell:** Asserting on internal details that don't matter to the behavior.

```typescript
// BAD
it("processOrder_callsRepoThenEmailerThenLogger", () => {
  service.processOrder(order);

  expect(repo.save)._calledBefore(emailer.send);
  expect(emailer.send)._calledBefore(logger.log);
  expect(repo.save)._calledExactly(1);
  expect(emailer.send)._calledExactly(1);
  expect(logger.log)._calledExactly(1);
});
```

**Why it's bad:**
- Refactoring the implementation (e.g., batching logger calls) breaks the test
- The test verifies the call order, not the outcome
- Couples tests to internal sequencing that callers shouldn't care about

**Fix:** Assert on observable outcomes.

```typescript
it("processOrder_validOrder_persistsAndSendsConfirmation", () => {
  const result = service.processOrder(order);

  expect(result.status).toBe("confirmed");
  expect(repo.findById(result.orderId)).toEqual(order);
  expect(emailer.lastSentEmail?.subject).toBe("Order Confirmed");
});
```

## 4. Shared Mutable Setup

**Smell:** `beforeEach` mutates a shared fixture; tests depend on each other's
side effects.

```typescript
// BAD
let cart: Cart;

beforeEach(() => {
  cart = new Cart();
});

it("addItem_addsToCart", () => {
  cart.add(item1);
  expect(cart.items).toHaveLength(1);
});

it("addItem_multipleItems_addsAllToCart", () => {
  // RELIES ON THE PREVIOUS TEST HAVING RUN
  cart.add(item2);
  expect(cart.items).toHaveLength(2);
});
```

**Why it's bad:**
- Tests can't run in isolation — order matters
- One test's failure cascades into others
- Hard to reason about what state a test starts in

**Fix:** Use factory functions; each test creates its own fixture.

```typescript
it("addItem_addsToCart", () => {
  const cart = new Cart();
  cart.add(item1);
  expect(cart.items).toHaveLength(1);
});

it("addItem_multipleItems_addsAllToCart", () => {
  const cart = new Cart([item1]);
  cart.add(item2);
  expect(cart.items).toHaveLength(2);
});
```

## 5. Test Logic in Production Code

**Smell:** Production code branches on whether it's running in a test.

```typescript
// BAD
class UserService {
  async fetchUser(id: string) {
    if (process.env.NODE_ENV === "test") {
      return fakeUsers.get(id);
    }
    return this.repo.findById(id);
  }
}
```

**Why it's bad:**
- Production code carries test baggage forever
- The "test" branch can drift from the real branch — tests pass but production breaks
- Hides the real dependency that should be injected

**Fix:** Dependency injection.

```typescript
class UserService {
  constructor(private repo: UserRepo) {}

  async fetchUser(id: string) {
    return this.repo.findById(id);
  }
}

// Production
const service = new UserService(realRepo);

// Test
const service = new UserService(fakeRepo);
```

## 6. Sleep-Based Timing

**Smell:** Tests use `sleep` or `setTimeout` to wait for async operations.

```typescript
// BAD
it("fetchUser_eventuallyReturnsUser", async () => {
  service.fetchUser("123").then(user => {
    expect(user.name).toBe("Alice");
  });
  await sleep(1000); // Hope it's done by now
});
```

**Why it's bad:**
- Flaky — passes on fast machines, fails on slow ones
- Slow — adds latency even when the operation is instant
- Doesn't actually verify the operation completed — just that time passed

**Fix:** Await the operation directly, or use polling with a timeout.

```typescript
it("fetchUser_returnsUser", async () => {
  const user = await service.fetchUser("123");
  expect(user.name).toBe("Alice");
});
```

For operations that genuinely take time (polling, retries), use a fake clock
or a polling helper with a timeout — never a bare `sleep`.

## 7. Catching Exceptions to Assert They're Thrown

**Smell:** Wrapping the act in try/catch and asserting after.

```typescript
// BAD
it("fetchUser_notFound_throwsError", () => {
  try {
    service.fetchUser("missing");
    fail("should have thrown");
  } catch (e) {
    expect(e.message).toBe("User not found");
  }
});
```

**Why it's bad:**
- Easy to forget the `fail` call — test passes if no exception is thrown
- Verbose and error-prone
- Frameworks have a better way

**Fix:** Use the framework's `expectException` / `rejects.toThrow`.

```typescript
it("fetchUser_notFound_throwsNotFoundError", () => {
  expect(() => service.fetchUser("missing")).toThrow(NotFoundError);
});

// Async
it("fetchUser_notFound_throwsNotFoundError", async () => {
  await expect(service.fetchUser("missing")).rejects.toThrow(NotFoundError);
});
```

## 8. Tautological Assertions

**Smell:** Asserting that a value equals itself, or that something is defined
when it's always defined.

```typescript
// BAD
it("createUser_returnsUser", () => {
  const user = service.createUser("Alice");
  expect(user).toBe(user);
  expect(user).toBeDefined(); // It's obviously defined — we just assigned it
});
```

**Why it's bad:**
- The test cannot fail — it tests nothing
- Gives false confidence in coverage

**Fix:** Assert on the specific outcomes that matter.

```typescript
it("createUser_returnsUserWithProvidedName", () => {
  const user = service.createUser("Alice");
  expect(user.name).toBe("Alice");
});
```

## 9. Testing Framework Features

**Smell:** Writing tests that verify the testing framework, the ORM, or the
language runtime works.

```typescript
// BAD
it("Array.push_addsItemToEnd", () => {
  const arr = [1, 2];
  arr.push(3);
  expect(arr).toEqual([1, 2, 3]);
});
```

**Why it's bad:**
- Tests third-party code that the vendor already tests
- Wastes time and adds maintenance burden
- Distracts from the actual unit under test

**Fix:** Delete the test. Test your code, not the framework.

## See Also

- [Roy Osherove Principles](roy-osherove-principles.md) — the three pillars and naming conventions
- [Test Patterns](test-patterns.md) — correct patterns to use instead

## Sources

- Synthesized from common unit testing practice and Roy Osherove's "The Art of Unit Testing"
- Migrated from `src/current/rules/software-dev/general/code-create-unit-tests.md`
