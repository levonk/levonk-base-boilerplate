# Kotlin CLI Boilerplate

Scaffolds a production-ready Kotlin CLI application with modern tooling and best practices.

## Features

- **Modern Kotlin**: Uses Kotlin 1.9.22 with JVM target 17
- **CLI Framework**: Built with [Clikt](https://github.com/ajalt/clikt) for powerful command-line parsing
- **Logging**: Structured logging with SLF4J and Logback
- **Testing**: JUnit 5 + MockK for comprehensive testing
- **Build System**: Gradle with Kotlin DSL
- **Devbox**: Reproducible development environment
- **Just**: Modern task runner for common operations
- **Docker**: Multi-stage Dockerfile for containerized builds
- **Optional Database Support**: PostgreSQL and SQLite support available

## Usage

### Generate a New Project

```bash
# Create an answers file
cat > copier-answers.yml <<EOF
project_name: my-tool
project_slug: my-tool
description: "A useful CLI tool"
kotlin_version: "1.9.22"
group_id: "com.example"
include_postgres: false
include_sqlite: false
EOF

# Run copier-wrapper.sh to generate the project
devbox run -- ./boilerplate/copier-wrapper.sh copy \
  ./boilerplate/apps/cli/kotlin/core \
  ./path/to/my-tool \
  --data @copier-answers.yml
```

### Development Workflow

```bash
cd ./path/to/my-tool

# Initialize environment
just bootstrap

# Run in development mode
just dev

# Build the project
just build

# Run tests
just test

# Run linting
just lint

# Type check
just typecheck

# Release build
just release

# Clean build artifacts
just clean

# Check environment health
just doctor
```

## Template Variables

- `project_name`: Human-readable project name
- `project_slug`: Kebab-case identifier (default: lowercased project_name)
- `description`: Short project description
- `kotlin_version`: Kotlin version (default: "1.9.22")
- `group_id`: Maven group ID (default: "com.example")
- `include_postgres`: Include PostgreSQL support (default: false)
- `include_sqlite`: Include SQLite support (default: false)

## Project Structure

```
.
├── build.gradle.kts          # Gradle build configuration
├── settings.gradle.kts       # Gradle settings
├── gradle.properties         # Gradle properties
├── devbox.json              # Devbox environment configuration
├── Dockerfile               # Multi-stage Docker build
├── docker-compose.yml       # Docker Compose configuration
├── justfile                 # Just task runner recipes
├── src/
│   ├── main/kotlin/         # Source code
│   │   └── com/example/     # Package structure
│   │       └── my_tool/     # Project package
│   │           └── Main.kt  # Application entry point
│   └── test/kotlin/         # Test code
│       └── com/example/
│           └── my_tool/
│               └── MainTest.kt
└── README.md                # This file
```

## Dependencies

### Core Dependencies
- **clikt**: CLI argument parsing
- **slf4j-api + logback-classic**: Logging
- **jackson-databind + jackson-module-kotlin**: JSON handling
- **kotlinx-coroutines-core**: Coroutines support

### Testing Dependencies
- **kotlin-test**: Kotlin testing utilities
- **junit-jupiter**: JUnit 5 testing framework
- **mockk**: Kotlin mocking library

### Optional Database Dependencies
- **postgresql**: PostgreSQL JDBC driver
- **sqlite-jdbc**: SQLite JDBC driver

## Devbox Environment

The template includes a devbox.json configuration that provides:
- OpenJDK 17
- Gradle
- Kotlin compiler
- Just task runner
- PostgreSQL (if enabled)

## Docker Support

The template includes a multi-stage Dockerfile:
- **Builder stage**: Eclipse Temurin JDK 17 Alpine for building
- **Runtime stage**: Eclipse Temurin JRE 17 Alpine for running

Build and run with Docker:

```bash
docker-compose build
docker-compose run cli --help
```

## Just Commands

The justfile provides convenient commands for common operations:

- `just bootstrap` - Initialize development environment
- `just build` - Build the project
- `just test` - Run tests
- `just lint` - Run linting (detekt)
- `just typecheck` - Run type checking
- `just dev` - Run in development mode
- `just release` - Full release pipeline
- `just clean` - Clean build artifacts
- `just doctor` - Check environment health
- `just prime` - Index documentation
- `just doc-search` - Search documentation and memory
- `just tasks` - List current tasks (tkr)
- `just task-ready` - Get next available task
- `just task-start` - Start working on available task

## Memory and Task Management

The template integrates with:
- **qmd**: Documentation search and memory management
- **tkr**: Ticket tracking and task management

Run `just bootstrap` to initialize the memory structure and tkr.

## Best Practices

- Use `just dev` for development with hot reload
- Run `just quality` before committing (runs lint, test, typecheck)
- Use `just release` for production builds
- Keep dependencies updated with `gradle dependencyUpdates`
- Follow Kotlin coding conventions
- Write tests for all new features
- Use structured logging with SLF4J

## References

- [Clikt Documentation](https://github.com/ajalt/clikt)
- [Kotlin Documentation](https://kotlinlang.org/docs/)
- [Gradle Kotlin DSL](https://docs.gradle.org/current/userguide/kotlin_dsl.html)
- [Devbox Documentation](https://www.jetify.dev/devbox)
- [Just Documentation](https://github.com/casey/just)
