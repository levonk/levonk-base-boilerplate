# Java Testing

Detailed guidance for setting up Java testing infrastructure with JUnit 5,
Mockito, Testcontainers, and AssertJ.

## JUnit 5 (Jupiter)

### Maven

```xml
<dependencyManagement>
    <dependencies>
        <dependency>
            <groupId>org.junit</groupId>
            <artifactId>junit-bom</artifactId>
            <version>5.10.2</version>
            <type>pom</type>
            <scope>import</scope>
        </dependency>
    </dependencies>
</dependencyManagement>

<dependencies>
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

### Gradle

```kotlin
dependencies {
    testImplementation(platform("org.junit:junit-bom:5.10.2"))
    testImplementation("org.junit.jupiter:junit-jupiter")
}

tasks.test {
    useJUnitPlatform()
}
```

### Basic Test

```java
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class CalculatorTest {
    @Test
    void addsTwoNumbers() {
        var calc = new Calculator();
        assertEquals(5, calc.add(2, 3));
    }
}
```

## AssertJ

Prefer AssertJ's fluent assertions over JUnit's built-in assertions for
readability and richer error messages:

```xml
<dependency>
    <groupId>org.assertj</groupId>
    <artifactId>assertj-core</artifactId>
    <version>3.26.0</version>
    <scope>test</scope>
</dependency>
```

```java
import static org.assertj.core.api.Assertions.*;

@Test
void listContainsExpectedElements() {
    var result = service.getItems();
    assertThat(result)
        .hasSize(3)
        .extracting(Item::name)
        .containsExactly("alpha", "beta", "gamma");
}
```

## Mockito

```xml
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-core</artifactId>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.mockito</groupId>
    <artifactId>mockito-junit-jupiter</artifactId>
    <scope>test</scope>
</dependency>
```

Use `@ExtendWith(MockitoExtension.class)` and `@Mock` annotations:

```java
@ExtendWith(MockitoExtension.class)
class OrderServiceTest {
    @Mock
    PaymentGateway gateway;

    @InjectMocks
    OrderService service;

    @Test
    void chargesPaymentOnCheckout() {
        when(gateway.charge(any())).thenReturn(true);
        var result = service.checkout(new Cart());
        assertTrue(result);
        verify(gateway).charge(any());
    }
}
```

## Testcontainers

Testcontainers provides disposable Docker-based dependencies for integration
tests (databases, message brokers, etc.):

```xml
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>junit-jupiter</artifactId>
    <version>1.19.8</version>
    <scope>test</scope>
</dependency>
<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>postgresql</artifactId>
    <version>1.19.8</version>
    <scope>test</scope>
</dependency>
```

```java
@Testcontainers
class RepositoryIT {
    @Container
    static PostgreSQLContainer<?> postgres = new PostgreSQLContainer<>("postgres:16");

    @Test
    void savesAndRetrievesEntity() {
        var repo = new Repository(postgres.getJdbcUrl(),
                                  postgres.getUsername(),
                                  postgres.getPassword());
        repo.save(new Entity("test"));
        var found = repo.findByName("test");
        assertThat(found).isPresent();
    }
}
```

## Surefire / Failsafe Split (Maven)

Split unit tests from integration tests by naming convention:

- Unit tests: `**/*Test.java` → run by surefire during `test` phase
- Integration tests: `**/*IT.java` → run by failsafe during
  `integration-test` phase

See `references/maven-project-setup.md` for the full plugin configuration.

Run only unit tests:

```bash
mvn test
```

Run integration tests (includes unit tests):

```bash
mvn verify
```

## Gradle Test Split

Use a separate source set for integration tests (see
`references/gradle-project-setup.md` — Test Source Sets). Run unit tests with
`./gradlew test` and integration tests with `./gradlew integrationTest`.

## Test Naming Conventions

| Type | Suffix | Runner |
|------|--------|--------|
| Unit test | `Test` | surefire / `test` task |
| Integration test | `IT` | failsafe / `integrationTest` task |

## Best Practices

- **Fast unit tests** — no I/O, no network, no Docker. Mock external
  dependencies.
- **Integration tests with Testcontainers** — real databases, real brokers,
  disposable containers.
- **AssertJ for assertions** — fluent, readable, rich error messages.
- **Mockito for mocking** — use `@ExtendWith(MockitoExtension.class)` and
  annotation-based mocks.
- **Parallel execution** — enable in surefire/failsafe for unit tests;
  keep integration tests sequential unless containers are isolated.
