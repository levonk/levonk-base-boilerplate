# Framework Detection

The skill never imposes a test framework the project does not use. Run
`project-detection` to identify the project's test framework, then use the
per-framework conventions below for test file location, naming, and SHA
referencing.

## Detection Matrix

`project-detection` detects the framework by inspecting the project's
manifest files, config files, and dependency listings. The common signals:

| Framework | Language | Detection signals |
|-----------|----------|-------------------|
| Vitest | TypeScript/JS | `vitest` in `devDependencies`, `vitest.config.ts`, `vite.config.ts` with `test` key |
| Jest | TypeScript/JS | `jest` in `devDependencies`, `jest.config.{js,ts}`, `jest` key in `package.json` |
| pytest | Python | `pytest` in `requirements.txt`/`pyproject.toml`, `pytest.ini`, `conftest.py`, `[tool.pytest]` in `pyproject.toml` |
| unittest | Python | `unittest` in stdlib (no install needed), `unittest.TestCase` subclasses |
| Go testing | Go | `*_test.go` files, `testing` package import |
| Rust cargo test | Rust | `Cargo.toml`, `#[test]` or `#[cfg(test)]` |
| JUnit | Java | `junit` in `pom.xml`/`build.gradle`, `@Test` annotations |
| xUnit / NUnit | C# | `xunit`/`nunit` package references, `*.Tests.csproj` |
| RSpec | Ruby | `rspec` in `Gemfile`, `spec/` directory |
| Minitest | Ruby | `minitest` in `Gemfile`, `test/` directory with `Minitest::Test` |

## Per-Framework Conventions

### Vitest / Jest (TypeScript/JavaScript)

- **Test file location:** colocated with source (`foo.test.ts`) or in a
  `__tests__/` / `test/` directory
- **Test file naming:** `<source>.test.{ts,js}` or `<source>.spec.{ts,js}`
- **Test structure:** `describe` / `it` / `expect`
- **SHA reference:** comment above the `it` block:
  ```typescript
  // Regression test for fix abc1234 — <one-line bug description>
  it("calculateTotal_appliesDiscountToEligibleItems_returnsDiscountedTotal", () => {
    // ...
  });
  ```

### pytest (Python)

- **Test file location:** `tests/` directory or colocated
- **Test file naming:** `test_<module>.py` or `<module>_test.py`
- **Test structure:** `def test_<scenario>():` with `assert`
- **SHA reference:** docstring on the test function:
  ```python
  def test_calculate_total_applies_discount_to_eligible_items():
      """Regression test for fix abc1234 — discount not applied to eligible items."""
      # ...
  ```

### Go testing

- **Test file location:** colocated (`foo_test.go` alongside `foo.go`)
- **Test file naming:** `<source>_test.go`
- **Test structure:** `func Test<Scenario>(t *testing.T)`
- **SHA reference:** comment above the function:
  ```go
  // TestCalculateTotalAppliesDiscount is a regression test for fix abc1234:
  // discount not applied to eligible items.
  func TestCalculateTotalAppliesDiscount(t *testing.T) {
      // ...
  }
  ```

### Rust cargo test

- **Test file location:** `#[cfg(test)] mod tests` at the bottom of the
  source file, or `tests/` integration test directory
- **Test file naming:** `<source>.rs` (unit) or `tests/<name>.rs` (integration)
- **Test structure:** `#[test] fn <name>()`
- **SHA reference:** doc comment above the test:
  ```rust
  /// Regression test for fix abc1234 — discount not applied to eligible items.
  #[test]
  fn calculate_total_applies_discount_to_eligible_items() {
      // ...
  }
  ```

### JUnit (Java)

- **Test file location:** `src/test/java/...` mirroring the main source
- **Test file naming:** `<Class>Test.java`
- **Test structure:** `@Test void <scenario>()`
- **SHA reference:** `@DisplayName` or Javadoc comment:
  ```java
  /** Regression test for fix abc1234 — discount not applied to eligible items. */
  @Test
  @DisplayName("calculateTotal applies discount to eligible items")
  void calculateTotalAppliesDiscountToEligibleItems() {
      // ...
  }
  ```

## When project-detection Fails

If `project-detection` cannot identify a framework:

1. **Check for a test directory** — `tests/`, `test/`, `__tests__/`, `spec/`.
   If present, inspect an existing test file to identify the framework.
2. **Ask the user** — present the detected candidates (if any) and ask which
   framework to use. Do not guess.
3. **If no framework exists** — the project has no test infrastructure. This
   is a separate concern from regression test mining. Recommend setting up
   a framework first (via `project-adopter` or `project-configuration`),
   then re-running this skill.
