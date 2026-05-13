### 🧊 Docker Nix Service Boilerplate (`docker-nix/`)

**Purpose**: Builds reproducible Docker images using Nix, including a dual-image workflow (minimal prod + debug tooling).

**Use Cases**:
- Incident-ready services that need a minimal production footprint and a tool-rich debug image
- Binary applications packaged via Nix flakes
- Teams that prefer hermetic builds with pinned inputs

**Generated Components**:
- `flake.nix` and supporting shell files
- Dual-target `Dockerfile` (runtime + debug)
- `Makefile` with Nix-aware targets
- `README.md` documenting the workflow

**Highlights**:
- `make build` / `make build-debug` produce and load the two images
- `make up` / `make debug` orchestrate runtime vs. debug profiles
- [`Linting & Security Commands`](docker-nix/README.md#linting--security-commands) section explains how to run `make lint-*`, `make trivy`, `make runtime-scan`, and `make audit` from day one
- **Security Tooling Guide**: The README documents all [`make lint-*`, `make trivy`, `make runtime-scan`, and `make audit`](docker-nix/README.md#linting--security-commands) targets, making it easy to discover the containerized scanners that ship with the boilerplate.

- **Security Tooling Guide**: The generated README now includes a dedicated ["Linting & Security Checks"](docker-linux/README.md#linting--security-checks) section that walks through `make lint`, Trivy, Docker Scout, Falco, and docker-bench targets so new teams can run the scanners immediately.

# Docker Infrastructure Boilerplates

This directory contains comprehensive Docker boilerplates for creating secure, production-ready containerized services using the `copier` tool. These boilerplates follow enterprise-grade security practices and integrate with the localnet infrastructure.

## 📦 Available Boilerplates

### 🧊 Docker Nix Service Boilerplate (`docker-nix/`)

**Purpose**: Creates secure, production-ready Docker services using standardized base images with a choice of operating system.

**Use Cases**:
- **Debian Mode**: Web apps, complex dependencies, broader ecosystem compatibility
- **Alpine Mode**: Microservices, security-critical apps, resource-constrained environments

**Key Features**:
- **Dual Base OS Support**: Choose between `base-debian` (Debian 12-slim) or `base-alpine` (Alpine 3.19)
- **Unified Tooling**: Consistent Makefile, scripts, and CI/CD across both OS types
- **Security**: Non-root execution, minimal attack surface, built-in security scanning
- **Production Ready**: Complete build system, health checks, testing, and backup automation

**Configuration Options**:
- `base_os`: Choose `debian` (default) or `alpine`
- `_include_tests`: Generate test suite (default: true)
- `_include_ui`: Add web UI component
- `_ui_port`: Port for web UI (if included)

- **Generated Components**:
  - `Dockerfile` - OS-specific container definition
  - `Makefile` - Complete build/deploy automation
  - `README.md` - Service documentation
  - `healthcheck/` - Health monitoring scripts
  - `scripts/` - Utility scripts (backup, security scan)
  - `tests/` - Automated test suite (optional)
  - `.env.example` - Configuration template
- **Security Tooling Guide**: See the [`Linting & Security Checks`](docker-linux/README.md#linting--security-checks) section inside the generated README for a tour of `make lint`, Trivy, Docker Scout, Falco, and docker-bench targets.

### 🐳 Docker Compose Boilerplate (`docker-compose/`)

**Purpose**: Creates secure multi-container Docker Compose configurations for complex services.

**Use Cases**:
- Services with multiple containers (app + database)
- Services with UI components
- Load-balanced applications
- Services requiring reverse proxy integration

**Key Features**:
- **Multi-Service**: Support for main service + UI components
- **Reverse Proxy**: Optional Traefik integration with automatic TLS
- **Monitoring**: Prometheus metrics collection
- **Networking**: Isolated networks with security controls
- **Development**: Hot-reload support via docker-compose.override.yml

**Configuration Options**:
- `_include_ui`: Add web UI container
- `_use_traefik`: Enable reverse proxy with TLS
- `_enable_monitoring`: Add Prometheus metrics
- Custom domains and ports

- **Generated Components**:
  - `docker-compose.yml` - Production service configuration
  - `docker-compose.override.yml` - Development overrides
  - `README.md` - Deployment and configuration guide

## 🧩 Shared Partials via Wrapper Script

This directory includes a **shared partials system** that allows multiple Copier templates to reuse common Jinja2 partials.

### The Challenge

Copier has several limitations that prevent straightforward sharing of partials:
- **Symlinks don't work**: Copier's Jinja2 sandbox cannot resolve symlinks to templates
- **Relative parent/sibling paths don't work**: Copier only searches within the template subdirectory
- **External paths don't work**: Copier's template rendering is sandboxed to the template directory

### Our Solution: Wrapper Script

We implemented a **wrapper script approach** that:
1. **Copies shared partials** from a central `_shared-partials/` directory into each template's `partials.bak/` directory
2. **Runs before Copier**: The wrapper script executes the copy operation before invoking the actual `copier` command
3. **Uses fresh copies**: Always removes and recreates the partials to ensure they're up-to-date
4. **Maintains single source of truth**: Shared partials live in one central location

#### Directory Structure
```
boilerplate/apps/infrastructure/docker/
├── _shared-partials/              # Central shared partials
│   ├── docker-header.jinja       # Common Docker header
│   └── docker-footer.jinja       # Common Docker footer
├── copier-wrapper.sh              # Wrapper script
├── test-template/                 # Example template using shared partials
│   ├── copier.yml
│   └── files/
│       └── README.md.jinja        # Includes shared partials
└── .gitignore                     # Excludes generated partials.bak/
```

#### Usage

```bash
# Use the wrapper script instead of direct copier
./copier-wrapper.sh copy docker-linux /tmp/my-project --defaults

# The wrapper:
# 1. Copies partials from _shared-partials/ to test-template/partials.bak/
# 2. Runs copier with all arguments
# 3. Ensures partials.bak/ is not copied to final output
```

#### Including Shared Partials

Templates include partials using standard Jinja2 syntax:
```jinja
{% include "partials.bak/docker-header.jinja" %}

# Your template content here

{% include "partials.bak/docker-footer.jinja" %}
```

### Future Expansion

This pattern is designed to expand across all boilerplate categories using a **mirrored directory structure** that maintains the same hierarchy as the boilerplates themselves:

#### Proposed Structure: Mirrored Hierarchy

```
boilerplate/
├── _shared/                       # Global shared templates (mirrors boilerplate structure)
│   ├── apps/                      # App-level shared templates
│   │   ├── infrastructure/        # Infrastructure app templates
│   │   │   ├── docker/            # Docker-specific shared files
│   │   │   │   ├── docker-header.jinja
│   │   │   │   ├── docker-footer.jinja
│   │   │   │   ├── Dockerfile.base.jinja
│   │   │   │   └── docker-compose.base.yml.jinja
│   │   │   ├── k8s/               # Kubernetes shared files
│   │   │   │   ├── deployment.yaml.jinja
│   │   │   │   └── service.yaml.jinja
│   │   │   └── airflow/           # Airflow shared files
│   │   │       ├── dag-template.py.jinja
│   │   │       └── requirements.txt.jinja
│   │   ├── web/                   # Web app shared templates
│   │   │   └── typescript/
│   │   │       └── nextjs/
│   │   │           ├── next.config.js.jinja
│   │   │           └── tailwind.config.js.jinja
│   │   ├── mobile/                # Mobile app shared templates
│   │   │   ├── kotlin-android/
│   │   │   │   └── build.gradle.jinja
│   │   │   └── react-native/
│   │   │       └── package.json.jinja
│   │   └── plugins/               # Plugin shared templates
│   │       └── mcp/
│   │           └── package.json.jinja
│   └── packages/                  # Package-level shared templates
│       └── category/
│           └── web/
│               └── domain/
│                   └── package-name/
│                       ├── python3/
│                       │   ├── pyproject.toml.jinja
│                       │   └── setup.py.jinja
│                       └── typescript/
│                           ├── package.json.jinja
│                           ├── tsconfig.json.jinja
│                           └── eslint.config.mjs.jinja
├── apps/                          # Actual boilerplate templates
│   ├── infrastructure/
│   │   ├── docker/
│   │   │   ├── docker-linux/
│   │   │   │   └── files/
│   │   │   │       └── Dockerfile.jinja
│   │   │   │           # Includes: {% include "partials.bak/Dockerfile.base.jinja" %}
│   │   │   └── docker-compose/
│   │   │       └── files/
│   │   │           └── docker-compose.yml.jinja
│   │   │               # Includes: {% include "partials.bak/docker-compose.base.yml.jinja" %}
│   │   └── k8s/
│   │       └── deployment/
│   │           └── files/
│   │               └── deployment.yaml.jinja
│   │                   # Includes: {% include "partials.bak/deployment.yaml.jinja" %}
│   └── web/
│       └── typescript/
│           └── nextjs/
│               └── files/
│                   └── next.config.js.jinja
│                       # Includes: {% include "partials.bak/next.config.js.jinja" %}
└── copier-wrapper.sh              # Universal wrapper for all templates
```

#### Benefits of Mirrored Structure

- **Clear Scope**: The exact path in `_shared/` shows where a template will be used
- **Intuitive Discovery**: Developers can easily find shared templates by following the same structure
- **Scalable Organization**: Each boilerplate category has its own shared space
- **Whole Files Support**: Not just partials - entire files can be shared (e.g., complete Dockerfiles, config files)
- **Hierarchical Overrides**: More specific levels can override or extend general templates

#### Example Usage Patterns

**1. Complete File Sharing**
```jinja
{# In docker-linux/files/Dockerfile.jinja #}
{% include "partials.bak/Dockerfile.base.jinja" %}

# Add runtime-specific customizations below
RUN useradd -m appuser
USER appuser
```

**2. Configuration File Sharing**
```jinja
{# In nextjs/files/next.config.js.jinja #}
{% include "partials.bak/next.config.js.jinja" %}

# Add project-specific configuration
module.exports = {
  ...sharedConfig,
  experimental: {
    appDir: true,
  },
};
```

**3. Multi-file Composition**
```jinja
{# In k8s-deployment/files/k8s.yaml.jinja #}
{% include "partials.bak/deployment.yaml.jinja" %}

---
{% include "partials.bak/service.yaml.jinja" %}
```

#### Implementation Strategy

1. **Gradual Migration**: Start with Docker templates, then expand to other categories
2. **Wrapper Script Enhancement**: Update `copier-wrapper.sh` to handle the mirrored structure
3. **Template Discovery**: The wrapper could auto-discover shared files based on template location
4. **Naming Convention**: Use `.jinja` suffix for all shared templates that need rendering

### Benefits of This Approach

- **DRY principle**: Shared partials are defined once and reused
- **Consistent updates**: Changes to shared partials are reflected in all templates
- **Works within Copier limitations**: Doesn't require modifying Copier itself
- **Fresh copies guaranteed**: Each run ensures partials are up-to-date
- **Scalable**: Can easily expand to other boilerplate categories
- **Git-friendly**: Generated `partials.bak/` directories are excluded from version control

### Implementation Details

See `internal-docs/adr/adr-20250123001-shared-partials-wrapper.md` for the complete technical decision record explaining the rationale, alternatives considered, and implementation details.

## 🔒 Security Features

All boilerplates include enterprise-grade security:

### Container Security
- **Non-root users**: All services run as unprivileged users
- **Minimal base images**: Reduced attack surface
- **Health checks**: Built-in monitoring and self-healing
- **Resource limits**: CPU and memory constraints
- **Network isolation**: Private networks with controlled access

### Nix Minimal Runtime + Optional Debug Image

This repo supports a two-image strategy that keeps production deployments small and hardened while still making deep debugging possible when needed.

- **Minimal runtime image (default)**
  - Built from pinned Nix inputs.
  - Uses a scratch-style closure copy (final image is effectively “no OS”).
  - Runs as a non-root user.
  - Avoids shipping interactive shells and diagnostic tooling.

  Scratch-style closure copy means the final container image is based on `scratch` and contains only:
  - The app binary (or entrypoint script).
  - The Nix store paths the app needs at runtime (its dependency closure).
  - Minimal runtime files you explicitly add (for example: cert bundle for TLS, user/group files if needed).

  This works well when the app is fully provided by Nix packages because Nix can build a complete runtime closure without relying on the base OS package manager.

  Practical implications:
  - **No package manager in prod**: there is nothing to `apt-get install` or `apk add`.
  - **No shell by default**: `docker exec -it ... sh` will not work unless you include a shell in the runtime closure.
  - **TLS needs certs**: if the app makes HTTPS calls, include `cacert`/CA bundle in the runtime closure.
  - **Dynamic linking still works**: Nix provides glibc and friends in the closure, so a dynamically linked binary can run without a distro userland.

- **Debug image (opt-in; not deployed by default)**
  - Built from the same Dockerfile via an additional build target.
  - Adds troubleshooting tools (for example: `bash`, `curl`, `jq`, `git`, `procps` (`ps`), `htop`, `strace`, `lsof`, `iputils` (`ping`), `net-tools` (`netstat`), `tcpdump`, `openssh`, `vim`).
  - Intended for ad-hoc debugging, incident response, and local experimentation.
  - Enabled via a separate Docker build target and a Compose `profile` so it stays out of normal deployments.

Example patterns:

```bash
# Build the minimal runtime image
docker build --target runtime -t my-service:runtime .

# Build the debug image only when needed
docker build --target debug -t my-service:debug .
```

Suggested Makefile semantics:

```bash
# Build both targets (cache-friendly)
make build

# Run runtime only
make up

# Run runtime only (deployment semantics)
make deploy

# Opt-in debug container
make debug
```

```yaml
# docker-compose.yml
services:
  app:
    image: my-service:runtime

  app-debug:
    image: my-service:debug
    profiles: ["debug"]
```

```bash
# Normal (debug container is not started)
docker compose up -d

# Opt-in debug container
docker compose --profile debug up -d
```

### Operational Security
- **Secret management**: Environment-based configuration
- **Backup encryption**: Secure data protection
- **Security scanning**: Automated vulnerability assessment
- **Access control**: Proper file permissions and ownership

### Compliance
- **CIS benchmarks**: Container security best practices
- **OWASP guidelines**: Web application security
- **GDPR considerations**: Data protection and privacy

## 🚀 Quick Start

### Generate a New Service

```bash
# Create a Debian-based service (default)
copier copy docker-linux my-debian-service
cd my-debian-service

# Create an Alpine-based service
copier copy docker-linux my-alpine-service -d base_os=alpine
cd my-alpine-service

# Create a multi-container service
copier copy docker-compose my-multi-service
cd my-multi-service
```

### Basic Usage

```bash
# Configure environment
cp env.example .env
# Edit .env with your settings

# Build and start
make build
make up

# Check health
make health-check

# View logs
make logs
```

## 🛠️ Development Workflow

### Local Development
```bash
# Start with development overrides
make up

# Run tests
make test

# Lint configuration
make lint

# Access service shell
make shell
```

### Production Deployment
```bash
# Security scan before deployment
make security-scan

# Deploy to staging/production
make build
make up

# Monitor health
make health-check
```

## 📊 Monitoring & Observability

### Health Checks
- HTTP endpoint monitoring (`/health`)
- Container resource usage tracking
- Service dependency validation
- Automated recovery mechanisms

### Logging
- Structured JSON logs
- Correlation IDs for request tracing
- Configurable log levels
- Secure log aggregation

### Metrics
- Prometheus-compatible metrics
- Application performance monitoring
- Resource utilization tracking
- Custom business metrics

## 🔄 CI/CD Integration

### GitHub Actions Pipeline
- **Lint**: Configuration validation and Dockerfile linting
- **Security**: Automated vulnerability scanning with Trivy
- **Build & Test**: Automated testing and health verification
- **Deploy**: Staging and production deployment workflows

### Security Gates
- Block deployments with critical vulnerabilities
- Require security scan approval for high-risk changes
- Automated dependency updates with testing

## 🛡️ Security Scanning

### Automated Tools
- **Trivy**: Container vulnerability scanning
- **Dockle**: Container security best practices
- **Hadolint**: Dockerfile security linting
- **NPM Audit**: Dependency vulnerability checks

### Manual Checks
- Secret detection in configuration files
- Permission and ownership validation
- Network security assessment

## 📦 Backup & Recovery

### Automated Backups
- **Configuration**: Environment files and compose configs
- **Data**: Docker volumes with encryption
- **Logs**: Container and application logs
- **Integrity**: Backup verification and compression

### Recovery Procedures
- Point-in-time restoration
- Data integrity validation
- Service verification after restore

## 🔧 Customization

### Template Variables
Each boilerplate supports extensive customization through copier variables:

```yaml
_service_name: "my-service"
_service_description: "A secure Docker service"
_service_port: "8080"
_service_health_endpoint: "/health"
_include_ui: false
_use_traefik: false
_enable_monitoring: true
```

### Extending Boilerplates
- Add custom health checks
- Integrate additional monitoring
- Include service-specific configurations
- Add custom build steps

## 📚 Documentation

### Generated Documentation
Each service generates comprehensive documentation including:
- Setup and deployment guides
- Configuration reference
- Security considerations
- Troubleshooting guides
- API documentation templates

### Boilerplate Maintenance
- Regular security updates
- Dependency version management
- Best practice updates
- Community contribution guidelines

## 🤝 Contributing

1. Follow security best practices
2. Test changes thoroughly
3. Update documentation
4. Submit security scan results

## 📄 License

See LICENSE file in the project root.

---

These boilerplates provide a solid foundation for secure, scalable Docker services with enterprise-grade tooling and practices built-in from day one. 🚀
