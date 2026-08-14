# Legacy Code Techniques

Michael Feathers' techniques from "Working Effectively with Legacy Code" for
refactoring code that lacks tests. The core challenge: to refactor safely you
need tests, but to add tests you often need to refactor — a chicken-and-egg
problem these techniques break.

## Core Definitions

### Legacy Code

Code **without tests**. Not necessarily old, not necessarily bad — but
unverified. Without tests, every change is a gamble.

### Seam

A place in the codebase where you can alter behavior **without editing that
location** — typically by substituting a dependency or overriding a method in
a subclass for testing.

**Kinds of seams:**
- **Object seam** — subclass and override a method in tests
- **Link seam** — swap a library/module at link time
- **Preprocessing seam** — macro-based substitution (rare; usually avoid)

### Characterization Test

A test that captures the **current** behavior of the code (bugs and all) so
you can refactor without silently changing behavior. Write the test, run it,
and if it fails — that's a discovery about what the code actually does. Update
the test to match reality, then refactor.

## Dependency-Breaking Techniques

### 1. Extract Interface

When a class is hard to substitute in tests because callers depend on its
concrete type, extract an interface and have callers depend on the interface.
Enables object seams via fake implementations.

### 2. Parameterize Constructor / Method

When a dependency is created inside the unit under test, add a parameter so
the test can pass in a fake. The production call site supplies the real
implementation; the test supplies a fake.

### 3. Extract and Override Factory Method

When a constructor creates a dependency you need to fake, extract the
creation into a protected factory method, then subclass in tests and override
the factory.

### 4. Subclass and Override Method

The workhorse technique: subclass the class under test, override the method
that's getting in the way (a dependency-creating method, a side-effecting
method), and test against the subclass.

### 5. Wrap Method / Wrap Class

When you can't change the original class (third-party, shared), wrap it in a
new class that adds the behavior or substitution point you need. The wrapper
becomes your seam.

### 6. Adapt Parameter

When a method takes a concrete type that's hard to construct in tests, adapt
the signature to accept an interface or a smaller role the test can satisfy.

### 7. Encapsulate Global References

When code reaches for globals, singletons, or static methods, wrap the global
access in an instance method on a class you can substitute. The global stays;
the seam is the wrapper.

## Procedure for Safely Refactoring Untested Code

1. **Identify the change point** — where do you need to edit?
2. **Find the seam** — where can you substitute behavior without editing the change point?
3. **Break the dependency** — apply one of the techniques above so the unit becomes testable in isolation.
4. **Write characterization tests** — capture current behavior. Run them; if they fail, you've discovered actual behavior — update the test.
5. **Make the intended change** — now with tests in place, refactor toward the new behavior.
6. **Verify** — characterization tests still pass for unchanged behavior; new tests pass for new behavior.

## When to Use Each Technique

| Situation | Technique |
|-----------|-----------|
| Concrete class hard to substitute | Extract Interface |
| Dependency created inside the unit | Parameterize Constructor, or Extract and Override Factory Method |
| Side effect (clock, network, file) inside the unit | Subclass and Override Method |
| Can't modify the original class | Wrap Method / Wrap Class |
| Hard-to-construct parameter | Adapt Parameter |
| Global / singleton access | Encapsulate Global References |

## See Also

- [Code Smell Catalog](code-smell-catalog.md) — what to look for once tests are in place.
- [Refactor Checklist](refactor-checklist.md) — verification gates between refactor steps.

## Sources

- Synthesized from Michael Feathers, "Working Effectively with Legacy Code" (2004)
- Migrated from `src/current/rules/software-dev/general/code-plan-refactor.md`
