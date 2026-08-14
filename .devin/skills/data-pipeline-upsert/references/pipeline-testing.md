# Pipeline Testing

> Data quality and integration testing for data pipelines: schema validation,
> freshness checks, Great Expectations, Soda, and Testcontainers.

## Test Layers

| Layer | Tests | Tooling |
|-------|-------|---------|
| Source | Schema, row count, freshness, null rates | dbt source freshness, Soda, custom SQL |
| Staging | Type casting, not-null, accepted values, uniqueness | dbt tests, Great Expectations |
| Mart | Referential integrity, business rules, thresholds | dbt tests, Soda CLIs |
| Integration | End-to-end pipeline against real dependencies | Testcontainers, fixture data |

## dbt Tests

- Generic tests: `not_null`, `unique`, `accepted_values`, `relationships`.
- Custom tests for business rules.
- Source freshness:

```yaml
sources:
  - name: sales
    freshness:
      warn_after: {count: 1, period: hour}
      error_after: {count: 2, period: hour}
```

## Great Expectations

- Define expectations as JSON or Python suites.
- Good for data contracts and data docs.
- Example:

```python
validator.expect_column_values_to_not_null("order_id")
validator.expect_column_values_to_be_unique("order_id")
validator.expect_table_row_count_to_be_between(100, 10000)
```

## Soda

- Lightweight YAML checks for CI.
- Example:

```yaml
checks for orders:
  - row_count > 0
  - missing_count(order_id) = 0
  - freshness(loaded_at) < 1h
```

## Testcontainers

- Use for integration tests with Postgres, MySQL, Kafka, or cloud emulators.
- Pin container image digests.
- Scope tests: bring up fixtures, run pipeline, assert output.

## Pipeline Gates

- Fail the pipeline on `error` severity.
- Warn on `warn` severity but alert.
- Gate downstream tasks on data quality task success.

## Citations

[1] [dbt tests](https://docs.getdbt.com/docs/build/tests)
[2] [Great Expectations](https://greatexpectations.io/)
[3] [Soda](https://docs.soda.io/)
[4] [Testcontainers](https://testcontainers.com/)
