# Java Containerization

Detailed guidance for packaging Java applications as container images with
multi-stage builds, JRE-only runtimes, and container-aware JVM flags.

## JRE vs JDK in Containers

**Never ship a JDK in a production container image.** The JDK is significantly
larger than the JRE and includes compilers, debuggers, and tools that are
unnecessary at runtime. Use a multi-stage build:

- **Builder stage** — full JDK, builds the application JAR
- **Runtime stage** — JRE only (or a slim JDK image if runtime tools are needed)

### Image Selection

| Image | Base | Size | Use Case |
|-------|------|------|----------|
| `eclipse-temurin:17-jre-alpine` | Alpine | ~80 MB | Minimal runtime, JRE only |
| `eclipse-temurin:17-jre-jammy` | Ubuntu | ~230 MB | Full glibc, JRE only |
| `eclipse-temurin:17-jdk-alpine` | Alpine | ~180 MB | Build stage |
| `eclipse-temurin:17-jdk-jammy` | Ubuntu | ~380 MB | Build stage, full glibc |
| `openjdk:17-alpine` (deprecated) | Alpine | — | Legacy; prefer Temurin |

For Alpine-based images using the `openjdk17` package (as seen in infrahub
sidecar builds):

```dockerfile
FROM alpine:3.19 AS builder
RUN apk add --no-cache openjdk17-jdk maven
# ... build steps ...

FROM alpine:3.19 AS runtime
RUN apk add --no-cache openjdk17-jre-headless
COPY --from=builder /app/target/app.jar /app/app.jar
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
```

## Multi-Stage Dockerfile (Maven)

```dockerfile
# ---- Builder stage ----
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN --mount=type=cache,target=/root/.m2 \
    mvn -B clean package -DskipTests

# ---- Runtime stage ----
FROM eclipse-temurin:17-jre-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/target/app.jar /app/app.jar
EXPOSE 8080
ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-jar", "/app/app.jar"]
```

## Multi-Stage Dockerfile (Gradle)

```dockerfile
# ---- Builder stage ----
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /app
ENV GRADLE_VERSION=8.5
RUN wget -q https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip \
    && unzip -q gradle-${GRADLE_VERSION}-bin.zip -d /opt \
    && ln -s /opt/gradle-${GRADLE_VERSION}/bin/gradle /usr/local/bin/gradle
COPY settings.gradle.kts build.gradle.kts ./
COPY gradle ./gradle
COPY gradlew ./
RUN chmod +x gradlew
COPY src ./src
RUN --mount=type=cache,target=/root/.gradle \
    ./gradlew bootJar --no-daemon

# ---- Runtime stage ----
FROM eclipse-temurin:17-jre-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/build/libs/app.jar /app/app.jar
EXPOSE 8080
ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-jar", "/app/app.jar"]
```

## JVM Container Flags

### `-XX:+UseContainerSupport`

Enabled by default on JDK 11+. Makes the JVM aware of cgroup memory and CPU
limits so it does not assume the host's full resources. **Always verify this
is enabled** — some base images or custom launch scripts may disable it.

### `-XX:MaxRAMPercentage`

Instead of hardcoding `-Xmx`, use a percentage of the container's memory limit:

```
-XX:MaxRAMPercentage=75.0
```

| Percentage | Use Case |
|------------|----------|
| 25.0 | Sidecar / shared container with other processes |
| 50.0 | Container with a significant non-heap workload |
| 75.0 | Dedicated JVM container (default recommendation) |
| 100.0 | JVM is the only process and you control off-heap memory |

### `-XX:InitialRAMPercentage`

Set the initial heap as a percentage of container memory:

```
-XX:InitialRAMPercentage=50.0
```

## Spring Boot Layered Jars

Spring Boot 2.3+ supports layered jars for better Docker layer caching.
Extract layers so that dependencies (rarely changing) are in separate layers
from application code (frequently changing):

```dockerfile
# ---- Builder stage ----
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /app
COPY . .
RUN ./gradlew bootJar --no-daemon
RUN java -Djarmode=layertools -jar build/libs/app.jar extract

# ---- Runtime stage ----
FROM eclipse-temurin:17-jre-alpine AS runtime
WORKDIR /app
COPY --from=builder /app/dependencies/ ./
COPY --from=builder /app/spring-boot-loader/ ./
COPY --from=builder /app/snapshot-dependencies/ ./
COPY --from=builder /app/application/ ./
ENTRYPOINT ["java", "org.springframework.boot.loader.launch.JarLauncher"]
```

This means changing application code only invalidates the final layer —
dependency layers are cached.

## Health Checks

Use a lightweight health check that doesn't require the JDK:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD java -version || exit 1
```

For Spring Boot actuator:

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:8080/actuator/health || exit 1
```

## Cache Volumes

| Build System | Cache Volume Name | Mount Path |
|--------------|-------------------|------------|
| Maven | `java-m2-cache` | `~/.m2/repository` |
| Gradle | `gradle-cache` | `~/.gradle` |

In CI pipelines, mount these as named volumes to avoid re-downloading
dependencies on every build.
