---
type: Practice
title: Java in Containers — JRE vs JDK, multi-stage builds, Alpine vs Debian
description: Ship JRE-only in the runtime stage; use multi-stage builds to keep the JDK in the builder; choose Alpine openjdk17 for infra sidecars or Debian JDK for applications with native dependencies.
tags: [java, containers, docker, jre, jdk, multi-stage, alpine, debian, openjdk17]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: infrahub-java-sidecar-dockerfile
    resource: https://github.com/levonk/infrahub/blob/main/shared/active/03-container/services/artifact/java-sidecar/Dockerfile.java-sidecar
    title: infrahub java-sidecar Dockerfile
  - id: infrahub-gradle-sidecar-dockerfile
    resource: https://github.com/levonk/infrahub/blob/main/shared/active/03-container/services/artifact/gradle-sidecar/Dockerfile.gradle-sidecar
    title: infrahub gradle-sidecar Dockerfile
  - id: eclipse-temurin-images
    resource: https://hub.docker.com/_/eclipse-temurin
    title: Eclipse Temurin images
  - id: docker-multi-stage-build-documentation
    resource: https://docs.docker.com/build/building/multi-stage/
    title: Docker multi-stage build documentation
  - id: general-multi-stage-pattern
    resource: ../container-best-practices/multi-stage-builds.md
    title: general multi-stage pattern
---

# Java in Containers — JRE vs JDK, multi-stage builds, Alpine vs Debian

## Failure Mode

Shipping a full JDK in the runtime container image when only the JRE is needed
to run the application. The JDK adds the compiler (`javac`), tools (`jstack`,
`jmap`), and source archives — increasing image size by ~150 MB and expanding
the attack surface.

## Symptoms

- Runtime image is 400+ MB when a JRE-only image would be ~180 MB.
- Security scanners flag JDK tools and source archives that are never used at
  runtime.
- Build tooling (Gradle, Maven) accidentally included in the runtime image
  because the Dockerfile copies the entire build directory.

## Practice

### JRE vs JDK

| Image | Contains | Size (approx) | Use when |
|-------|----------|---------------|----------|
| `openjdk17` (Alpine) | Full JDK | ~350 MB | Builder stage, development sidecars |
| `openjdk17-jre` (Alpine) | JRE only | ~180 MB | Runtime stage, production |
| `eclipse-temurin:17-jre` (Debian) | JRE only | ~260 MB | Runtime with glibc native deps |
| `eclipse-temurin:17-jdk` (Debian) | Full JDK | ~400 MB | Builder stage with glibc |

The infrahub sidecars demonstrate this split:

- **java-sidecar** (`Dockerfile.java-sidecar`): Installs `openjdk17` (full JDK)
  because it's a development sidecar that needs `javac` for compilation.
- **gradle-sidecar** (`Dockerfile.gradle-sidecar`): Multi-stage build — builder
  stage downloads Gradle 8.5, runtime stage installs `openjdk17-jre` only and
  copies the Gradle distribution from the builder.

### Multi-stage build pattern for Java

```dockerfile
# Builder stage — JDK + build tools
FROM eclipse-temurin:17-jdk AS builder
WORKDIR /build
COPY gradle/wrapper/ gradle/wrapper/
COPY gradlew build.gradle settings.gradle ./
RUN ./gradlew dependencies --no-daemon
COPY src/ src/
RUN ./gradlew build -x test --no-daemon

# Runtime stage — JRE only
FROM eclipse-temurin:17-jre
COPY --from=builder /build/build/libs/app.jar /app/app.jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

### Alpine openjdk17 vs Debian JDK

| Base | libc | JDK package | Native compat | Use when |
|------|------|-------------|---------------|----------|
| Alpine | musl | `openjdk17` / `openjdk17-jre` | Limited (see [java-alpine-compatibility](/java-alpine-compatibility.md)) | Infra sidecars, no JNI |
| Debian | glibc | `eclipse-temurin:17-jdk` | Full glibc | Applications with native deps |

The infrahub sidecars use Alpine `openjdk17` because they are infrastructure
sidecars with no JNI native dependencies. For application containers with
native libraries (Netty native transport, RocksDB, SQLite JNI), prefer Debian
to avoid the musl compatibility issues documented in
[java-alpine-compatibility](/java-alpine-compatibility.md).

### Real example: infrahub gradle-sidecar

The `Dockerfile.gradle-sidecar` demonstrates the full pattern:

```dockerfile
# Build stage — downloads Gradle 8.5
FROM localnet-base-alpine:latest as gradle-builder
RUN --mount=type=cache,target=/tmp/gradle-cache,id=gradle-sidecar-gradle \
    apk add curl unzip ca-certificates && \
    curl -L "https://services.gradle.org/distributions/gradle-8.5-bin.zip" -o /tmp/gradle.zip && \
    unzip /tmp/gradle.zip -d /opt/gradle --strip-components=1

# Runtime stage — JRE only, Gradle copied from builder
FROM localnet-base-sidecar:latest
RUN apk add openjdk17-jre
COPY --from=gradle-builder /opt/gradle /opt/gradle
RUN ln -sf /opt/gradle/bin/gradle /usr/local/bin/gradle
```

## Related

- [java-alpine-compatibility](/java-alpine-compatibility.md) — musl libc issues
  with JNI and native libraries.
- [java-sidecar-pattern](/java-sidecar-pattern.md) — full sidecar architecture.
- [jvm-tuning](/jvm-tuning.md) — JVM flags for the runtime stage.
