---
modeline: "vim: set ft=markdown:"
title: "ADR: Docker Compose Profile-Based Service Organization Strategy"
adr-id: adr-20260322002
slug: 20260322002-docker-compose-profile-strategy
url: /internal-docs/adr/adr-20260322002-docker-compose-profile-strategy.md
synopsis: Establish a unified profile-based approach for Docker Compose service organization with YAML substitution for maintainable service clusters and debugging workflows
author: https://github.com/levonk
date-created: 2026-03-22
date-updated: 2026-03-26
version: 1.0.0
status: "proposed"
aliases: []
tags: ["doc/architecture/adr", "docker-compose", "profiles", "infrastructure", "devops"]
supersedes: []
superseded-by: []
related-to: ["adr-20260131001-standard-developer-ux-flow", "adr-20260322001-agent-base-image-selection"]
---

## Build Order Dependencies

### Problem: `depends_on` Does Not Control Build Order

A critical discovery during implementation: Docker Compose's `depends_on` only controls **runtime** container startup order, **not** build order. When building services, Docker Compose builds all services in a profile **in parallel**.

This creates a problem for base images that depend on other locally-built images:

```yaml
# services/base/docker-compose.base-kali.yml
services:
  base-kali:
    image: localnet-base-kali:latest
    profiles: [base01]
    
  base-kalinix:
    build:
      dockerfile: ./Dockerfile.base-kalinix  # FROM localnet-base-kali:latest
    profiles: [base01]  # Would fail - builds in parallel with base-kali!
```

The `base-kalinix` Dockerfile uses `FROM localnet-base-kali:latest`, but when both services are in `base01`, they build simultaneously. If `base-kali` hasn't finished building, `base-kalinix` fails with:

```
pull access denied for localnet-base-kali, repository does not exist
```

### Solution: Profile-Based Build Sequencing

We use **sequential profile execution** in the justfile to enforce build order:

```yaml
# docker-compose.base-kali.yml
services:
  base-kali:
    image: localnet-base-kali:latest
    profiles: [base01]  # Builds first
    
  base-kalinix:
    build:
      dockerfile: ./Dockerfile.base-kalinix  # FROM localnet-base-kali:latest
    profiles: [base02]  # Builds AFTER base01 completes
    depends_on:
      base-kali:
        condition: service_started  # Runtime only!
```

The justfile enforces sequential builds:

```bash
base-up-internal:
    docker compose ... --profile base01 up -d  # Step 1: Build base images
    docker compose ... --profile base02 up -d  # Step 2: Build dependent images  
    docker compose ... --profile base03 up -d  # Step 3: Build final images
```

### Profile Hierarchy for Build Ordering

| Profile | Services | Build Dependencies | Purpose |
|---------|----------|-------------------|---------|
| `base01` | base-alpine, base-debian, base-kali, nix-sidecar | External base images | Foundation images from Docker Hub |
| `base02` | base-kalinix, base-nix, base-debnix | base01 images | Nix-enabled variants |
| `base03` | base-sidecar, base-dev | base02 images | Final development environment |

### Future: Native Build Dependencies

**TODO:** When `additional_contexts` is supported by OrbStack, Podman, Colima, and Lima, migrate to native Docker Compose build dependencies:

```yaml
# Future syntax (when universally supported)
base-kalinix:
  build:
    additional_contexts:
      localnet-base-kali:latest: service:base-kali
```

This would eliminate the need for profile-based sequencing and allow single-command builds.

**Current Status:** Profile-based sequencing is required because `additional_contexts` requires BuildKit, which is not consistently supported across alternative container engines (OrbStack, Podman, Colima, Lima).

## Context

The current LocalNet Docker Compose architecture has evolved into a complex multi-file system:

- `docker-compose.shared.yml` - Shared resources (networks, volumes)
- `docker-compose.include.yml` - External resource references
- `docker-compose.localnet.yml` - Main orchestrator with manual includes
- Multiple service-specific compose files with manual includes

This approach creates several problems:

1. **Complexity**: Multiple files with manual includes are hard to manage
2. **Debugging Difficulty**: Hard to isolate specific service clusters
3. **Maintenance Overhead**: Adding new services requires updating multiple files
4. **Profile Inconsistency**: Profiles like `base01`, `base02` are not standardized
5. **No Unified Launch**: No single entry point for different deployment scenarios

We need a strategy that:
- Uses profiles consistently for service clustering
- Enables easy debugging of specific services
- Provides a unified launch interface
- Reduces file complexity and maintenance overhead
- Supports both development and production scenarios

## Decision

We establish a **unified profile-based Docker Compose strategy** with YAML substitution and a single orchestrator file.

### Core Principles

1. **Single Orchestrator**: One main `docker-compose.yml` with all services
2. **Profile-Based Grouping**: Services grouped by functional profiles
3. **YAML Substitution**: Environment-based configuration injection
4. **Hierarchical Profiles**: Nested profile relationships for complex scenarios
5. **Debug-Friendly**: Easy to isolate and test specific services

### Profile Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│                    ALL (Production)                          │
├───────────────────┬───────────────────┬─────────────────────────┤
│     BASE         │   DEVELOPMENT     │       SECURITY           │
│   (base01)        │   (base02)        │    (security)            │
├─────────┬─────────┼─────────┬─────────┼─────────┬───────────────┤
│  CORE   │  NIX    │  DEBUG  │  TEST   │  AGENT  │   DMZ         │
│ (core)  │ (nix)   │ (debug) │ (test)  │(agent) │ (dmz)         │
└─────────┴─────────┴─────────┴─────────┴─────────┴───────────────┘
```

### Profile Definitions

#### Core Infrastructure Profiles
- **`core`**: Essential infrastructure (networks, basic services)
- **`nix`**: Nix package management and build services
- **`dns`**: DNS resolution and caching services
- **`ntp`**: Time synchronization services

#### Development Profiles
- **`base01`**: Production-ready base infrastructure
- **`base02`**: Development infrastructure with debugging
- **`debug`**: Debug and monitoring services
- **`test`**: Testing and CI/CD services

#### Application Profiles
- **`security`**: Security services (firewall, monitoring)
- **`agents`**: AI and agent services
- **`dmz`**: DMZ services for controlled access
- **`apps`**: Application services

#### Specialized Profiles
- **`localnet`**: Full localnet environment
- **`minimal`**: Minimal required services
- **`full`**: All services including experimental

### File Structure

```
docker-compose.yml                 # Main orchestrator
├── profiles/                      # Profile-specific configurations
│   ├── core.yml                  # Core services
│   ├── nix.yml                   # Nix services
│   ├── dns.yml                    # DNS services
│   ├── base01.yml                # Production base
│   ├── base02.yml                # Development base
│   ├── security.yml              # Security services
│   ├── agents.yml                # Agent services
│   └── dmz.yml                   # DMZ services
├── config/                        # Environment-based configurations
│   ├── shared.yml                # Shared resources (networks, volumes)
│   ├── production.yml             # Production overrides
│   ├── development.yml            # Development overrides
│   └── testing.yml                # Testing overrides
└── scripts/                       # Launch scripts
    ├── up.sh                     # Unified launch script
    ├── debug.sh                  # Debug launch script
    └── test.sh                   # Test launch script
```

### Implementation Strategy

#### 1. Main Orchestrator (`docker-compose.yml`)

```yaml
---
version: '3.8'

# Include shared resources first
include:
  - config/shared.yml

# Include all service profiles
include:
  - profiles/core.yml
  - profiles/nix.yml
  - profiles/dns.yml
  - profiles/base01.yml
  - profiles/base02.yml
  - profiles/security.yml
  - profiles/agents.yml
  - profiles/dmz.yml

# Environment-specific overrides
include:
  - config/${COMPOSE_ENV:-development}.yml

# Default profile for backward compatibility
profiles:
  default: [core, nix, dns, base01]
```

#### 2. Profile Files (`profiles/*.yml`)

```yaml
# profiles/core.yml
services:
  # Core infrastructure services
  shared-resources:
    image: nixpkgs/nix:latest
    profiles: [core, base01, base02]
    networks: [localnet]
    volumes: [nix-cache, nix-config]
```

#### 3. Configuration Files (`config/*.yml`)

```yaml
# config/shared.yml
networks:
  localnet:
    name: localnet-network
    driver: bridge
    ipam:
      config:
        - subnet: 172.26.0.0/16
          gateway: 172.26.0.1

volumes:
  nix-cache:
    name: localnet-base-nix-cache-volume
  nix-config:
    name: localnet-base-nix-config-volume
```

#### 4. Launch Scripts

```bash
#!/bin/bash
# scripts/up.sh - Unified launch script

set -euo pipefail

# Default profile
PROFILE=${1:-localnet}

# Environment
COMPOSE_ENV=${COMPOSE_ENV:-development}

echo "Starting LocalNet with profile: $PROFILE"
echo "Environment: $COMPOSE_ENV"

# Launch with profile
docker compose --profile "$PROFILE" up -d

echo "✅ LocalNet started with profile: $PROFILE"
```

### Usage Patterns

#### Development Workflow
```bash
# Start development environment
./scripts/up.sh base02

# Start with debugging
./scripts/debug.sh

# Start specific service cluster
docker compose --profile core --profile nix up -d

# Debug specific service
docker compose --profile debug up nix-sidecar
```

#### Production Workflow
```bash
# Start production environment
COMPOSE_ENV=production ./scripts/up.sh base01

# Start full production stack
COMPOSE_ENV=production ./scripts/up.sh localnet
```

#### Testing Workflow
```bash
# Start test environment
./scripts/test.sh

# Test specific service
docker compose --profile test --profile core up -d
```

### YAML Substitution Strategy

#### Environment-Based Configuration
```yaml
services:
  nix-sidecar:
    image: ${NIX_SIDEFANG_IMAGE:-nixpkgs/nix:latest}
    environment:
      - TZ=${TZ:-UTC}
      - USERNAME=${USERNAME:-cuser}
    profiles: [nix, base01, base02]
```

#### Profile-Based Service Selection
```yaml
services:
  # Production service
  nix-sidecar-prod:
    extends: nix-sidecar
    profiles: [base01]
    environment:
      - LOG_LEVEL=warn
  
  # Development service
  nix-sidecar-dev:
    extends: nix-sidecar
    profiles: [base02]
    environment:
      - LOG_LEVEL=debug
      - DEBUG_MODE=true
```

## Rationale

### Benefits

1. **Simplified Management**: Single orchestrator with profile-based includes
2. **Easy Debugging**: Isolate specific services or clusters with profiles
3. **Consistent Launch**: Unified scripts for different scenarios
4. **Environment Flexibility**: YAML substitution for different environments
5. **Maintainability**: Clear separation of concerns and hierarchical organization
6. **Backward Compatibility**: Existing workflows continue to work

### Trade-offs

1. **Learning Curve**: New profile-based approach requires learning
2. **File Organization**: More files but better organized
3. **Complexity**: Initial setup is more complex but pays off long-term

## Implementation Plan

### Phase 1: Core Infrastructure (Week 1)
- [ ] Create main orchestrator structure
- [ ] Implement core profiles (core, nix, dns)
- [ ] Set up shared resources configuration
- [ ] Create basic launch scripts

### Phase 2: Service Migration (Week 2)
- [ ] Migrate existing services to profile structure
- [ ] Implement base01/base02 profiles
- [ ] Create development and testing profiles
- [ ] Update justfile integration

### Phase 3: Advanced Features (Week 3)
- [ ] Implement security and agent profiles
- [ ] Add DMZ and specialized profiles
- [ ] Create advanced launch scripts
- [ ] Add monitoring and debugging tools

### Phase 4: Documentation and Training (Week 4)
- [ ] Update AGENTS.md with new workflows
- [ ] Create migration guide
- [ ] Add debugging documentation
- [ ] Team training and adoption

## Migration Strategy

### Backward Compatibility

Existing commands continue to work:
```bash
# Old way (still works)
just up
just base-up

# New way (recommended)
./scripts/up.sh localnet
./scripts/up.sh base01
```

### Gradual Migration

1. **Parallel Operation**: Run both systems side-by-side
2. **Feature Parity**: Ensure all existing functionality works
3. **Gradual Adoption**: Teams can migrate at their own pace
4. **Deprecation Plan**: Phase out old approach after migration

## Consequences

### Positive Consequences

1. **Improved Debugging**: Easy to isolate and test specific services
2. **Better Organization**: Clear separation of concerns
3. **Flexible Deployment**: Environment-specific configurations
4. **Easier Maintenance**: Profile-based service management
5. **Team Productivity**: Faster debugging and testing cycles

### Negative Consequences

1. **Initial Complexity**: More files and structure to learn
2. **Migration Effort**: Time required to migrate existing services
3. **Documentation Updates**: Need to update all documentation

### Mitigation Strategies

1. **Comprehensive Documentation**: Clear guides and examples
2. **Migration Tools**: Scripts to help with migration
3. **Training Materials**: Workshops and tutorials
4. **Gradual Rollout**: Phase-by-phase implementation

## Future Considerations

### Automation
- CI/CD pipeline integration
- Automated testing of profiles
- Configuration validation tools

### Monitoring
- Profile health monitoring
- Service dependency tracking
- Performance metrics by profile

### Extensions
- Multi-environment support
- Cloud deployment profiles
- Microservices orchestration

## Status

**Status**: Proposed
**Next Steps**: Implement Phase 1 (Core Infrastructure)
**Review Date**: 2026-03-29
