---
type: Practice
title: Java Testing — JUnit 5, Mockito, Testcontainers, and the Surefire/Failsafe Split
description: Use JUnit 5 with AssertJ and Mockito, run unit tests with surefire and integration tests with failsafe, and use Testcontainers for real database/service integration in tests.
tags: [java, testing, junit, mockito, testcontainers, surefire, failsafe]
date:
  created: "2026-07-18"
  knowledge-basis: "2026-07-17"
  last-used: "2026-07-17"
sources:
  - id: junit-5-documentation
    resource: https://junit.org/junit5/docs/current/user-guide/
    title: JUnit 5 documentation
  - id: testcontainers-java
    resource: https://java.testcontainers.org/
    title: Testcontainers Java
---

# Java Testing

## Failure Mode

Java projects have slow, flaky, or low-value test suites because tests mix unit
and integration concerns, use heavy shared test databases, or mock too much of
the runtime environment.

## Symptoms

- `mvn test` fails because PostgreSQL is not running locally.
- Tests pass or fail depending on execution order due to shared mutable state.
- Mocked DAOs hide real SQL syntax errors until production.
- Integration tests run on every local build, slowing the edit-compile-test loop.

## Practice

### Unit Tests

- Use JUnit 5 (`org.junit.jupiter.api`) with AssertJ for fluent assertions.
- Mockito for behavior verification; prefer `MockitoExtension` over manual
  `MockitoAnnotations.openMocks`.
- Keep unit tests fast (<100 ms per test when possible) and deterministic.

### Integration Tests

- Use Testcontainers for real databases, message brokers, or cloud services.
- Run integration tests with `maven-failsafe-plugin` or Gradle's separate
  `integrationTest` source set.
- Use `@Testcontainers` and `@Container` with `DockerImageName.parse(...)`
  pinned to a specific digest.

### Test Split

| Concern | Tool | Runs When |
|---------|------|-----------|
| Unit | Surefire / `test` | Every build |
| Integration | Failsafe / `integrationTest` | CI or explicit profile |
| Contract / API | Testcontainers + RestAssured | CI nightly |

### Container Considerations

- Inside containers, Testcontainers needs Docker-in-Docker or an external
  Docker socket. Prefer a dedicated `integrationTest` CI job that runs on a
  Docker-enabled runner over trying to run integration tests inside the app
  container at startup.
