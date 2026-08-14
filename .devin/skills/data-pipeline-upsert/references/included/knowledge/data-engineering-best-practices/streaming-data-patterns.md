---
type: Practice
title: Streaming Data Patterns — Exactly-Once, Watermarks, and Windowing
description: Design streaming pipelines with explicit delivery guarantees, event-time watermarks, and windowing strategies that handle late events without unbounded state growth.
tags: [data-engineering, streaming, kafka, kinesis, exactly-once, watermark, windowing, flink, kafka-connect, ksqldb]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-08-09"
  last-used: "2026-08-09"

sources:
  - id: apache-flink-streaming-concepts
    resource: "https://nightlies.apache.org/flink/flink-docs-stable/docs/concepts/time/"
    title: "Apache Flink Streaming Concepts"
  - id: kafka-streams-delivery-guarantees
    resource: "https://kafka.apache.org/documentation/streams/architecture"
    title: "Kafka Streams Delivery Guarantees"
  - id: datatalksclub-zoomcamp-streaming
    resource: "https://github.com/DataTalksClub/data-engineering-zoomcamp/tree/main/07-streaming"
    title: "Data Engineering Zoomcamp — Module 7: Streaming (Kafka, Kafka Streams, KSQL, Schema Registry)"
---

# Streaming Data Patterns

## Failure Mode

Streaming pipelines produce duplicate results, drop late events, or run out of
memory because delivery semantics are ambiguous, processing time is used instead
of event time, and windows are not bounded.

## Symptoms

- Duplicate records appear in sink after a consumer restart.
- Late events are silently dropped or assigned to the wrong window.
- State backends grow unbounded, causing OOM.
- Results differ between replay and live processing.

## Practice

### Delivery Guarantees

| Guarantee | Behavior | Trade-off |
|-----------|----------|-----------|
| At-most-once | No retries | May lose data, lowest latency |
| At-least-once | Retry on failure | May duplicate data, needs idempotent sinks |
| Exactly-once | Idempotent processing + transactional sinks | Highest correctness cost, needed for finance/ops |

Use idempotent sinks and offset/commits for exactly-once semantics.

### Event Time vs Processing Time

- Use event time (the timestamp in the record) for windowing and aggregation.
- Use watermarks to track event-time progress and trigger window evaluation.
- Processing time is useful only for monitoring and latency SLAs.

### Watermarks

- Bounded-out-of-orderness watermarks: `maxEventTime - maxDelay`.
- Choose `maxDelay` based on observed event-time skew in the source.
- After watermark passes, late events go to a side output, not the main result.

### Windowing

| Window | Use Case |
|--------|----------|
| Tumbling | Non-overlapping fixed intervals (e.g. hourly aggregates) |
| Sliding | Overlapping fixed intervals (e.g. 5-min averages every 1 min) |
| Session | User activity gaps (e.g. sessionize web events) |
| Global | Single aggregate over all data; needs careful triggering |

### State Management

- TTL state to avoid unbounded growth.
- Use RocksDB state backend for large keyed state.
- Enable checkpointing to recover from failures without reprocessing from the
  beginning.

### Schema Management

- Use a Schema Registry with Avro serialization so producers and consumers
  evolve independently — see
  [Schema Registry and Avro](/schema-registry-avro.md) for compatibility
  rules and evolution patterns.
- Never share schemas implicitly via JSON — silent deserialization failures are
  the most common streaming bug.

### Kafka Connect and ksqlDB

- **Kafka Connect** provides source and sink connectors (databases → Kafka,
  Kafka → warehouses) without custom producer/consumer code. Configure with
  Avro converters and the Schema Registry for automatic schema management.
- **ksqlDB** runs SQL queries over Kafka streams — filters, joins, and
  aggregations without a separate stream processing cluster. Infer column
  types from the Schema Registry for Avro topics.
- Use Kafka Connect for integration and ksqlDB for lightweight stream
  transformations; use Flink/Kafka Streams for stateful processing with
  custom logic and watermarks.
