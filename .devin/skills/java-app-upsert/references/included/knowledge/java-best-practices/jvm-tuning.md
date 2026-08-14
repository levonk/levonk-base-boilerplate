---
type: Practice
title: JVM Tuning — Container-aware heap, GC selection, and cgroup limits
description: Use -XX:MaxRAMPercentage and -XX:+UseContainerSupport for container-aware heap sizing; select G1 for general-purpose or ZGC for low-latency workloads.
tags: [java, jvm, gc, g1gc, zgc, containers, heap, tuning, performance]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: jep-343-packaging-tool-jpackage
    resource: https://openjdk.org/jeps/343
    title: 'JEP 343: Packaging Tool (jpackage)'
  - id: jep-377-zgc-a-scalable-low-latency-garbage-collector
    resource: https://openjdk.org/jeps/377
    title: 'JEP 377: ZGC: A Scalable Low-Latency Garbage Collector'
  - id: jep-391-macosaarch64-port
    resource: https://openjdk.org/jeps/391
    title: 'JEP 391: macOS/AArch64 Port'
  - id: java-container-support-documentation
    resource: https://docs.oracle.com/en/java/javase/17/docs/api/java.base/java/lang/Runtime.html#maxMemory--
    title: Java Container Support documentation
  - id: infrahub-java-sidecar-dockerfile
    resource: https://github.com/levonk/infrahub/blob/main/shared/active/03-container/services/artifact/java-sidecar/Dockerfile.java-sidecar
    title: infrahub java-sidecar Dockerfile
---

# JVM Tuning — Container-aware heap, GC selection, and cgroup limits

## Failure Mode

Running a JVM inside a container without container-aware flags. The JVM either
ignores cgroup memory limits (on older JVMs) and gets OOM-killed, or uses a
fixed `-Xmx` that doesn't adapt to the container's memory allocation — leading
to either wasted memory (heap too small for the container) or OOM kills (heap
too large for the container).

## Symptoms

- Container exits with code 137 (SIGKILL from OOM killer) because the JVM heap
  plus metaspace plus native memory exceeded the container memory limit.
- JVM uses only 256 MB of heap in a 4 GB container because `-Xmx` was hardcoded
  to a "safe" value.
- Long GC pauses on heaps > 4 GB with the default GC (Serial or Parallel) on
  older JVMs.
- `-XX:+UseCGroupMemoryLimitForHeap` deprecated in Java 11+, removed in Java 14+.

## Practice

### Container-aware heap sizing

Since Java 10, the JVM is container-aware by default (`-XX:+UseContainerSupport`
is enabled). Use **percentage-based** heap sizing instead of fixed `-Xmx`:

```bash
# Good: percentage of container memory limit
java -XX:MaxRAMPercentage=75.0 -XX:InitialRAMPercentage=50.0 -jar app.jar

# Bad: fixed heap that doesn't adapt to container size
java -Xmx2g -jar app.jar
```

- `MaxRAMPercentage` — max heap as a percentage of the container memory limit
  (default 25%). Use 75% for dedicated application containers; leave 25% for
  metaspace, thread stacks, native memory, and direct buffers.
- `InitialRAMPercentage` — initial heap size as a percentage (default 1.25%).
  Set to 50% for faster startup.
- `MinRAMPercentage` — minimum heap for small containers (default 50%).

### GC selection

| GC | Flag | Introduced | Use when |
|----|------|------------|----------|
| G1 | `-XX:+UseG1GC` | Java 9 default | General-purpose, heaps 4–32 GB, balanced throughput/latency |
| ZGC | `-XX:+UseZGC` | Java 15 (production) | Low-latency (<10 ms pause), heaps > 32 GB, sub-millisecond GC |
| Shenandoah | `-XX:+UseShenandoahGC` | Java 15 | Low-latency alternative to ZGC, similar pause times |
| Parallel | `-XX:+UseParallelGC` | Java 8 default | Batch jobs, maximum throughput, pause time not critical |

For Java 17 (as used in the infrahub sidecars), G1 is the default and is
appropriate for most workloads. Switch to ZGC only when you have measured GC
pause problems and need sub-10 ms pauses.

### JVM flags for containers

```bash
java \
  -XX:+UseContainerSupport \
  -XX:MaxRAMPercentage=75.0 \
  -XX:InitialRAMPercentage=50.0 \
  -XX:+UseG1GC \
  -XX:MaxGCPauseMillis=200 \
  -jar app.jar
```

## When to use fixed -Xmx

- When the container memory limit is fixed and well-known, and you want
  deterministic heap sizing.
- In sidecar/init containers with small, predictable memory needs (e.g. the
  infrahub Java sidecar runs `java -version` for health checks — no heap tuning
  needed).

## Related

- [java-in-containers](/java-in-containers.md) — JRE vs JDK in the runtime
  image; the JVM flags go in the runtime stage.
- [java-build-optimization](/java-build-optimization.md) — JVM tuning for the
  build daemon (Gradle) is separate from runtime tuning.
