# Java Project Changes

This document outlines all changes made by the project-adopter skill specifically for Java projects.

## Detection Patterns

Projects are detected as Java when they contain:
- `pom.xml` (Maven)
- `build.gradle` or `settings.gradle` (Gradle)
- `src/main/java/` directory
- `*.java` files

## Files Created

### Core Files
- **devbox.json** - Environment with Java packages
- **justfile** - Java-specific targets and commands
- **README.md** - Java development setup guide
- **AGENTS.md** - Java AI agent configuration
- **.envrc** - Java environment configuration

## devbox.json Changes

### Adopt Mode Packages
```json
{
  "packages": [
    "just", "yq-go", "jq", "ripgrep", "fd", "bat",
    "openjdk", "maven", "gradle", "checkstyle", "junit"
  ]
}
```

### Standardize Mode Packages
```json
{
  "packages": [
    "just", "yq-go", "jq", "ripgrep", "fd", "bat",
    "openjdk", "maven", "gradle", "checkstyle", "junit",
    "spotbugs", "pitest", "jacoco", "sonarqube",
    "dependency-check", "owasp-dependency-check"
  ]
}
```

## justfile Changes

### Language-Specific *_impl Targets
```just
# Java-specific implementations (Maven)
dev_impl:
    mvn spring-boot:run

build_impl:
    mvn compile

test_impl:
    mvn test

lint_impl:
    mvn checkstyle:check

typecheck_impl:
    mvn compile

clean_impl:
    mvn clean

bootstrap_impl:
    mvn dependency:resolve
    echo "Java development environment ready!"
```

### Alternative Gradle Targets
```just
# Java-specific implementations (Gradle)
dev_impl:
    ./gradlew bootRun

build_impl:
    ./gradlew build

test_impl:
    ./gradlew test

lint_impl:
    ./gradlew checkstyleMain

typecheck_impl:
    ./gradlew compileJava

clean_impl:
    ./gradlew clean

bootstrap_impl:
    ./gradlew dependencies
    echo "Java development environment ready!"
```

### Additional Targets
```just
# Development loop
loop: || (bootstrap build test dev)

# CI pipeline
ci: || (bootstrap lint typecheck test build)

# Package management
package:
    mvn package

install:
    mvn install

# Analysis
spotbugs:
    mvn spotbugs:check

coverage:
    mvn jacoco:report
```

## pom.xml Surgical Changes

### Dependencies Added (Adopt Mode)
```xml
<dependencies>
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <version>5.9.3</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

### Plugins Added (Adopt Mode)
```xml
<build>
    <plugins>
        <plugin>
            <groupId>org.apache.maven.plugins</groupId>
            <artifactId>maven-compiler-plugin</artifactId>
            <version>3.11.0</version>
            <configuration>
                <source>17</source>
                <target>17</target>
            </configuration>
        </plugin>
    </plugins>
</build>
```

## build.gradle Surgical Changes

### Dependencies Added (Adopt Mode)
```gradle
dependencies {
    testImplementation 'org.junit.jupiter:junit-jupiter:5.9.3'
}
```

### Plugins Added (Adopt Mode)
```gradle
plugins {
    id 'java'
    id 'checkstyle'
}

java {
    sourceCompatibility = JavaVersion.VERSION_17
    targetCompatibility = JavaVersion.VERSION_17
}
```

## Configuration Files

### checkstyle.xml (Created if missing)
```xml
<?xml version="1.0"?>
<!DOCTYPE module PUBLIC
    "-//Checkstyle//DTD Checkstyle Configuration 1.3//EN"
    "https://checkstyle.org/dtds/configuration_1_3.dtd">
<module name="Checker">
    <module name="TreeWalker">
        <module name="ConstantName"/>
        <module name="LocalVariableName"/>
        <module name="MethodName"/>
        <module name="PackageName"/>
        <module name="ParameterName"/>
        <module name="TypeName"/>
    </module>
</module>
```

## Mode-Specific Differences

### Adopt Mode (Conservative)
- **Essential packages only** - openjdk, maven, gradle, checkstyle, junit
- **Basic configuration** - Minimal checkstyle and compiler settings
- **Standard commands** - compile, test, package, clean
- **Preserves existing** - Won't override existing pom.xml/build.gradle sections

### Standardize Mode (Comprehensive)
- **Full ecosystem** - Adds spotbugs, pitest, jacoco, sonarqube, etc.
- **Complete configuration** - Comprehensive code quality and security rules
- **Advanced commands** - Security analysis, mutation testing, coverage
- **Standardizes** - Enforces our preferred Java configurations

## Related Documentation

- [All Projects Changes](changes-all-projects.md)
- [Node.js Project Changes](changes-nodejs-typescript-projects.md)
- [Rust Project Changes](changes-rust-projects.md)
- [Python Project Changes](changes-python-projects.md)
- [Go Project Changes](changes-go-projects.md)

<!-- vim: set ft=markdown: -->
