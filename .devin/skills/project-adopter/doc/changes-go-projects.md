# Go Project Changes

This document outlines all changes made by the project-adopter skill specifically for Go projects.

## Detection Patterns

Projects are detected as Go when they contain:
- `go.mod`
- `go.sum`
- `main.go` or `*.go` files
- `Gopkg.toml`

## Files Created

### Core Files
- **devbox.json** - Environment with Go packages
- **justfile** - Go-specific targets and commands
- **README.md** - Go development setup guide
- **AGENTS.md** - Go AI agent configuration
- **.envrc** - Go environment configuration

## devbox.json Changes

### Adopt Mode Packages
```json
{
  "packages": [
    "just", "yq-go", "jq", "ripgrep", "fd", "bat",
    "go", "gopls", "golangci-lint", "go-swagger"
  ]
}
```

### Standardize Mode Packages
```json
{
  "packages": [
    "just", "yq-go", "jq", "ripgrep", "fd", "bat",
    "go", "gopls", "golangci-lint", "go-swagger",
    "go-test-coverage", "go-mod-tidy", "gofmt", "staticcheck", "revive"
  ]
}
```

## justfile Changes

### Language-Specific *_impl Targets
```just
# Go-specific implementations
dev_impl:
    go run ./cmd/main.go

build_impl:
    go build ./...

test_impl:
    go test ./...

lint_impl:
    golangci-lint run

typecheck_impl:
    go vet ./...

clean_impl:
    rm -f bin/* coverage.out

bootstrap_impl:
    go mod download
    go mod tidy
    echo "Go development environment ready!"
```

### Additional Targets
```just
# Development loop
loop: || (bootstrap build test dev)

# CI pipeline
ci: || (bootstrap lint typecheck test build)

# Module management
tidy:
    go mod tidy

download:
    go mod download

# Coverage
coverage:
    go test -coverprofile=coverage.out ./...
    go tool cover -html=coverage.out

# Cross-platform builds
build-all:
    go build -o bin/main-linux linux/amd64 ./...
    go build -o bin/main-darwin darwin/amd64 ./...
    go build -o bin/main-windows windows/amd64 ./...
```

## go.mod Surgical Changes

### Development Dependencies Added
```go
// go.mod additions
require (
    github.com/stretchr/testify v1.8.4 // indirect
    github.com/golang/mock v1.6.0 // indirect
)
```

## Configuration Files

### .golangci.yml (Created if missing)
```yaml
run:
  timeout: 5m
  tests: true

linters:
  enable:
    - gofmt
    - govet
    - ineffassign
    - misspell
    - unconvert
    - unused
    - staticcheck

linters-settings:
  gofmt:
    simplify: true
```

## Mode-Specific Differences

### Adopt Mode (Conservative)
- **Essential packages only** - go, gopls, golangci-lint, go-swagger
- **Basic configuration** - Minimal golangci.yml config
- **Standard commands** - build, test, run, vet, tidy
- **Preserves existing** - Won't override existing go.mod sections

### Standardize Mode (Comprehensive)
- **Full ecosystem** - Adds go-test-coverage, staticcheck, revive, etc.
- **Complete configuration** - Comprehensive linting rules
- **Advanced commands** - Coverage analysis, cross-platform builds
- **Standardizes** - Enforces our preferred Go configurations

## Related Documentation

- [All Projects Changes](changes-all-projects.md)
- [Node.js Project Changes](changes-nodejs-typescript-projects.md)
- [Rust Project Changes](changes-rust-projects.md)
- [Python Project Changes](changes-python-projects.md)
- [Java Project Changes](changes-java-projects.md)

<!-- vim: set ft=markdown: -->
