---
type: Practice
title: Schema Registry and Avro — Schema Evolution for Streaming Pipelines
description: Manage streaming schemas with a Schema Registry and Avro serialization so producers and consumers evolve independently — enforce backward/forward compatibility, avoid silent deserialization failures, and reduce payload size with binary encoding.
tags: [data-engineering, streaming, kafka, avro, schema-registry, schema-evolution, confluent, compatibility]
date:
  created: "2026-08-09"
  knowledge-basis: "2026-08-09"
  last-used: "2026-08-09"

sources:
  - id: datatalksclub-zoomcamp-streaming
    resource: "https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/07-streaming"
    title: "Data Engineering Zoomcamp — Module 7: Streaming (Kafka Schema Registry, Avro)"
  - id: confluent-schema-registry-docs
    resource: "https://docs.confluent.io/platform/current/schema-registry/index.html"
    title: "Confluent Schema Registry documentation"
  - id: avro-specification
    resource: "https://avro.apache.org/docs/"
    title: "Apache Avro specification"
---

# Schema Registry and Avro

## Failure Mode

Streaming producers and consumers share an implicit schema via JSON or
untyped byte arrays. When a producer adds or renames a field, consumers
silently fail to deserialize, drop messages, or crash — with no warning until
downstream data is missing.

## Symptoms

- A producer adds a `phone_number` field and half the consumers crash on
  deserialization while the other half silently drop it.
- A field is renamed from `user_id` to `userId` and downstream KSQL queries
  return null for a week before anyone notices.
- Messages are JSON-encoded at 2 KB each; the same data in Avro would be 200
  bytes — broker storage and network costs are 10x higher than necessary.
- There is no record of which schema version produced which messages, so
  replay is impossible after a schema change.

## Practice

### Avro Serialization

- Use Avro (or Protobuf) for binary serialization instead of JSON — smaller
  payloads, faster deserialization, and a formal schema attached to every
  message.
- Avro schemas are JSON-defined; the schema is registered in the Schema
  Registry and referenced by ID in each message envelope.
- Consumers fetch the schema by ID from the registry — they always
  deserialize with the exact schema the producer used.

### Schema Registry

- Deploy a Schema Registry (Confluent, Apicurio, AWS Glue) alongside the
  message broker.
- Every message produced is validated against the registered schema — the
  broker rejects messages that do not conform.
- The registry stores every schema version with a unique ID, enabling replay
  with the correct schema at any point in time.

### Compatibility Rules

| Compatibility | Meaning | Use When |
|---------------|---------|----------|
| BACKWARD | New consumers can read old data | Adding optional fields, consumers upgraded first |
| FORWARD | Old consumers can read new data | Removing optional fields, producers upgraded first |
| FULL | Both backward and forward | Safest — use for shared topics with multiple consumers |
| NONE | No enforcement | Development only — never in production |

- Set `FULL` compatibility for topics with multiple independent consumer
  teams.
- Set `BACKWARD` for topics where you control all consumers and upgrade them
  first.
- Evolving a schema under `FULL`: add fields with defaults, remove optional
  fields, never rename or change types without a migration plan.

### Schema Evolution Patterns

- **Add a field**: give it a default value so old messages deserialize without
  it.
- **Remove a field**: ensure no consumer references it; old messages still
  carry it (ignored by new consumers).
- **Rename a field**: add the new field with a default, deprecate the old one,
  migrate consumers, then remove the old field in a later version.
- **Change a type**: use a new field name with the new type and a migration
  plan — never change a field type in place under `FULL` compatibility.

### Kafka Connect and ksqlDB

- **Kafka Connect** uses the Schema Registry automatically for source/sink
  connectors — configure the converter as `AvroConverter` and the registry
  URL.
- **ksqlDB** reads Avro schemas from the registry to infer stream column
  types — no manual DDL for Avro topics.
- Register schemas for Connect source connectors before starting the connector
  to avoid auto-registration of incompatible schemas.

## Related Concepts

- [Streaming Data Patterns](/streaming-data-patterns.md) — delivery
  guarantees, watermarks, and windowing that schema management complements.
- [Data Quality Testing](/data-quality-testing.md) — schema validation is the
  streaming equivalent of source schema tests.
