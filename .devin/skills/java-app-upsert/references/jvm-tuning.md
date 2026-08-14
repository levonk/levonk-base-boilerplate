# JVM Tuning

Detailed guidance for JVM heap sizing, garbage collector selection,
container-aware flags, profiling, and class data sharing.

## Heap Sizing

### Container-Aware Heap

Never hardcode `-Xmx` in containerized environments. Use percentage-based
flags that adapt to the container's memory limit:

```
-XX:+UseContainerSupport
-XX:InitialRAMPercentage=50.0
-XX:MaxRAMPercentage=75.0
```

### Bare-Metal / VM Heap

When running outside containers (or when you need precise control):

```
-Xms2g -Xmx2g
```

Set `-Xms` equal to `-Xmx` to avoid heap resizing pauses in production.

### Metaspace

Metaspace (replacing PermGen since Java 8) grows automatically. For
applications with heavy class loading, set an upper bound:

```
-XX:MaxMetaspaceSize=512m
```

## Garbage Collector Selection

| GC | Flag | Best For | Latency | Throughput |
|----|------|----------|---------|------------|
| G1 | `-XX:+UseG1GC` (default JDK 9+) | General-purpose, balanced | Low pauses | High |
| ZGC | `-XX:+UseZGC` | Low-latency, large heaps (>16 GB) | Sub-millisecond | Moderate |
| Parallel | `-XX:+UseParallelGC` | Batch processing, max throughput | High pauses | Highest |
| Shenandoah | `-XX:+UseShenandoahGC` | Low-latency (Red Hat builds) | Sub-millisecond | Moderate |

### G1GC (Default)

G1 is the default collector from JDK 9 onward. Tune pause-time goals:

```
-XX:MaxGCPauseMillis=200
-XX:G1HeapRegionSize=16m
```

### ZGC

ZGC is production-ready from JDK 17. Best for large heaps and latency-sensitive
workloads:

```
-XX:+UseZGC
-XX:+ZGenerational
```

`ZGenerational` (JDK 21+) enables generational ZGC for better throughput.

### Parallel GC

Best for batch jobs where throughput matters more than pause times:

```
-XX:+UseParallelGC
-XX:ParallelGCThreads=4
```

## Container-Aware Flags Summary

| Flag | Default | Purpose |
|------|---------|---------|
| `-XX:+UseContainerSupport` | On (JDK 11+) | Detect cgroup limits |
| `-XX:MaxRAMPercentage` | 25.0 | Max heap as % of container memory |
| `-XX:InitialRAMPercentage` | 1.5625 | Initial heap as % of container memory |
| `-XX:MinRAMPercentage` | 50.0 | Heap for small containers (< ~250 MB) |

**Note**: `MinRAMPercentage` applies when the container has less than ~250 MB
of memory. Above that, `MaxRAMPercentage` controls the heap.

## JFR / JMC Profiling

### Java Flight Recorder (JFR)

JFR is built into the JDK (free since JDK 11). Record profiling data with
minimal overhead (< 1%):

```bash
# Start a 60-second recording
java -XX:StartFlightRecording=duration=60s,filename=app.jfr -jar app.jar

# Continuous recording with disk storage
java -XX:StartFlightRecording=filename=/var/log/app.jfr,maxsize=100m,maxage=1h -jar app.jar

# Attach to a running process
jcmd <pid> JFR.start duration=60s filename=app.jfr
```

### JDK Mission Control (JMC)

Download JMC from https://adoptium.net/jmc/ to analyze `.jfr` files. JMC
provides dashboards for:
- CPU profiling (method-level hotspots)
- Memory allocation profiling
- GC analysis (pause times, collection frequency)
- Thread analysis (blocking, waiting)
- I/O profiling

### Common JFR Diagnostics

| Symptom | JFR Event to Check |
|---------|-------------------|
| High CPU | `jdk.ExecutionSample` — method-level CPU samples |
| Slow GC | `jdk.GCPhasePause` — pause durations |
| Memory leak | `jdk.OldObjectSample` — long-lived objects |
| Thread blocking | `jdk.JavaMonitorWait` / `jdk.ThreadPark` |
| I/O bottleneck | `jdk.FileRead` / `jdk.FileWrite` / `jdk.SocketRead` |

## Class Data Sharing (CDS)

CDS reduces startup time by sharing pre-processed class metadata across JVM
instances. Especially valuable for short-lived JVMs (serverless, CLI tools).

### Default CDS Archive

JDK ships with a default CDS archive. Enable application class data sharing:

```bash
# Generate an archive for your application
java -Xshare:off -XX:DumpLoadedClassList=app.classlist -jar app.jar
java -Xshare:off -XX:SharedClassList=app.classlist \
     -XX:SharedArchiveFile=app.jsa -jar app.jar

# Run with the archive
java -Xshare:on -XX:SharedArchiveFile=app.jsa -jar app.jar
```

### Spring Boot CDS

Spring Boot 3.3+ supports CDS extraction:

```bash
java -Djarmode=tools -jar app.jar extract-cds --application --output app-cds.jsa
java -Xshare:on -XX:SharedArchiveFile=app-cds.jsa -jar app.jar
```

Typical startup improvement: 20-40% for Spring Boot applications.

## Summary Checklist

- [ ] Use `-XX:+UseContainerSupport` and `-XX:MaxRAMPercentage` (not `-Xmx`)
      in containers
- [ ] Select GC based on workload (G1 default, ZGC for low-latency, Parallel
      for batch)
- [ ] Set `-Xms` = `-Xmx` for bare-metal production
- [ ] Record JFR profiles under realistic load
- [ ] Enable CDS for short-lived JVMs
- [ ] Monitor GC logs: `-Xlog:gc*:file=/var/log/gc.log:time,uptime`
