# dbt Model Development

> Detailed guidance for developing dbt models, tests, snapshots, and macros with
> clear layering, materialization strategy, and incremental processing.

## Model Layers

Organize models into layers that mirror data flow:

- **staging** (`models/staging/`) — 1:1 cleaned views of source data.
- **intermediate** (`models/intermediate/`) — joins, aggregations, business logic.
- **mart** (`models/mart/`) — final tables for analytics and BI.

## Materialization Strategy

| Materialization | Use When |
|-------------------|----------|
| `view` | Lightweight, always-fresh, small source |
| `table` | Heavy transformation, frequently queried |
| `incremental` | Large table, append or upsert pattern |
| `ephemeral` | Reusable CTE, not materialized |

## Incremental Models

- Use `is_incremental()` to branch between full and incremental loads.
- Set `unique_key` for upserts.
- Filter source data by `max(_loaded_at)` or partition column.
- Choose `incremental_strategy` (`merge`, `delete+insert`, `append`) based on
  target warehouse.

```sql
{{ config(
   materialized='incremental',
   unique_key='order_id',
   incremental_strategy='merge'
) }}

select *
from {{ source('sales', 'orders') }}

{% if is_incremental() %}
where _loaded_at > (select max(_loaded_at) from {{ this }})
{% endif %}
```

## Tests

- Generic: `not_null`, `unique`, `accepted_values`, `relationships`.
- Custom tests for business rules.
- Source freshness tests on `loaded_at` columns.
- Run `dbt build` (compile + run + test) in CI.

## Snapshots

- Use for slowly changing dimensions (SCD2).
- Define `unique_key` and `updated_at`/`dbt_updated_at`.
- Query `dbt_valid_to is null` for current records.

## Macros and Packages

- Extract reusable logic to `macros/`.
- Import community packages via `packages.yml`.
- Pin package versions with `revision` or commit hash.

## CI/CD

- Run `dbt deps`, `dbt compile`, `dbt build` in CI.
- Use `dbt docs generate` and publish docs.
- Use `dbt-cloud` or a CI job for state-aware runs (`+state:modified+`).

## Citations

[1] [dbt Materializations](https://docs.getdbt.com/docs/build/materializations)
[2] [dbt Tests](https://docs.getdbt.com/docs/build/tests)
[3] [dbt Snapshots](https://docs.getdbt.com/docs/build/snapshots)
