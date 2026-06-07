---
modeline: 'vim: set ft=markdown:'
title: 'ADR: Nix Container Architecture'
adr-id: '20260109001'
slug: '20260109001-nix-container-architecture'
url: '/internal-docs/adr/adr-20260109001-nix-container-architecture.md'
synopsis: 'Establishes daemonless Nix architecture with flake-based dependency management for containerized services.'
author: 'https://github.com/levonk'
date-created: '2025-01-09'
date-updated: '2025-01-09'
version: '1.0.0'
status: 'accepted'
aliases: []
tags: ['doc/architecture/adr', 'adr', 'nix', 'containers', 'architecture']
supersedes: []
superseded-by: []
related-to:
  [
    'adr-20251218002-docker-service-standards',
    'adr-20260106001-container-privilege-dropping-standard',
  ]
scope:
  impact-scope: ['nix-sidecar', 'dev-base', 'all containers using Nix']
  excluded-scope: []
---

# Decision Record: Nix Container Architecture

- belongs in `internal-docs/adr/adr-20260109001-nix-container-architecture.md`

---

## Context

The monorepo uses Nix for package management across multiple containerized services. Current implementation shows inconsistent approaches:

- nix-sidecar: Daemonless, maintenance-focused
- dev-base: Runs nix daemon with multi-user installation
- Other containers: Mixed approaches with unclear dependency management

Key architectural questions emerged:

1. Should containers use nix daemon or daemonless mode?
2. How should dependencies be declared and managed?
3. How should base images (nix-base) and derived images (dev-base) relate?
4. How do we ensure reproducibility across containers?

## Constraints

- Must support containerized environments where each container runs as a single user
- Must maintain reproducible builds and dependency management
- Must follow Docker best practices (lightweight, single-purpose containers)
- Must support inheritance patterns (base → derived images)
- Must work with shared `/nix/store` volumes across containers
- Must avoid single points of failure in container orchestration

## Decision

### 1. Daemonless Architecture for All Containers

**Decision**: All containers will use daemonless Nix mode except where specifically required for multi-user scenarios.

**Rationale**:

- Container environments are inherently single-user
- Daemon adds unnecessary complexity and resource overhead
- Direct store access provides better performance
- Simplifies container startup and health monitoring
- Eliminates single point of failure

### 2. Flake-Based Dependency Management

**Decision**: Every container using Nix must declare dependencies via its own `flake.nix` file.

**Rationale**:

- Ensures reproducible builds - containers work independently
- Eliminates hidden dependencies on shared store state
- Provides explicit dependency documentation
- Enables `nix develop` to guarantee required packages are available
- Supports proper inheritance patterns

### 3. Hierarchical Flake Inheritance

**Decision**: Use child-flake-inherits-from-parent pattern for base/derived relationships.

**Structure**:

```
nix-sidecar/
├── assets/static/
│   ├── nix-sidecar/
│   │   ├── flake.nix          # Core Nix + maintenance tools
│   │   └── entrypoint.sh
│   ├── etc/nix/nix.conf
│   └── usr/local/bin/healthcheck.sh
└── Dockerfile.nix-sidecar

dev-base/
├── assets/static/
│   ├── dev-base/
│   │   ├── flake.nix          # Inherits nix-sidecar + adds dev tools
│   │   └── entrypoint.sh
│   └── etc/nix/nix.conf
├── Dockerfile.dev-base        # FROM nix-sidecar
└── docker-compose.dev-base.yml
```

**Implementation**:

```nix
# dev-base/assets/static/dev-base/flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nix-sidecar.url = "path:../nix-sidecar/assets/static/nix-sidecar";
  };

  outputs = { self, nixpkgs, nix-sidecar }: {
    devShells.default = nixpkgs.mkShell {
      inputsFrom = [ nix-sidecar.devShells.default ];
      packages = with nixpkgs; [
        nodejs
        git
        vim
        # ... dev tools
      ];
    };
  };
}
```

### 4. Service Separation of Concerns

**Decision**: nix-sidecar focuses on store maintenance, not package provision.

**nix-sidecar responsibilities**:

- Store optimization (`nix store optimise`)
- Store verification (`nix store verify --all`)
- Scheduled maintenance via supercronic
- Environment restoration from bootstrap tarball
- **Lightweight healthcheck** - Basic operational readiness only
- **Heavy verification tasks** - Daily integrity checks via supercronic, not healthcheck

**Container responsibilities**:

- Declare own dependencies via flake.nix
- Use `nix develop` to ensure packages available
- Operate independently of nix-sidecar
- **Call base's flake** - Containers should inherit from base flake.nix and extend as needed

### 5. Shared Volume Architecture

**Decision**: `/etc/nix` and `/nix` are shared volumes that sidecar initializes.

**Volume initialization**:

- nix-sidecar creates `bootstrap-slash-nix.tar` during build
- At runtime, sidecar extracts tarball to initialize shared volumes
- Other containers mount these volumes after initialization
- Enables store sharing while maintaining container independence

### 6. Debugging Support Strategy

**Decision**: Multi-layer Dockerfile approach for debugging containers.

**Implementation**:

- Base layer: Production container (minimal, optimized)
- Debug layer: Additional debugging tools and utilities
- Debug containers built from service images when needed
- Enables troubleshooting without bloating production images

## Consequences

### Positive

- **Reproducibility**: Each container works independently with explicit dependencies
- **Simplicity**: Daemonless mode reduces complexity and resource usage
- **Fault Tolerance**: Container failure doesn't affect others' Nix operations
- **Performance**: Direct store access eliminates daemon overhead
- **Clarity**: Flake.nix provides clear dependency documentation
- **Flexibility**: Containers can customize their Nix environment as needed

### Negative

- **Initial Setup**: Requires migrating existing daemon-based containers
- **Learning Curve**: Teams need to understand flake-based dependency management
- **Build Time**: Each container may need to download/build its own packages initially
- **Coordination**: Need to ensure flake versions stay compatible across related containers

### Neutral

- **Store Sharing**: Still benefits from shared `/nix/store` for deduplication
- **Maintenance**: nix-sidecar continues to provide store optimization services
- **Development**: dev-base retains comprehensive development environment

## Implementation Plan

### Phase 1: Update nix-sidecar (Complete)

- ✅ Remove daemon dependencies
- ✅ Add flake.nix with core packages
- ✅ Implement daemonless health checks
- ✅ Add supercronic scheduled tasks

### Phase 2: Migrate dev-base

- [ ] Remove nix daemon installation
- [ ] Create flake.nix inheriting from nix-base
- [ ] Update Dockerfile to use daemonless mode
- [ ] Add Dockerfile comments explaining base flake inheritance
- [ ] Update entrypoint comments to clarify flake usage

### Phase 3: Update Other Containers

- [ ] Audit containers using Nix
- [ ] Create flake.nix for each container
- [ ] Remove daemon dependencies where present
- [ ] Add Dockerfile/entrypoint comments for base flake usage
- [ ] Update documentation and examples

### Phase 4: Validation

- [ ] Test container independence
- [ ] Verify reproducible builds
- [ ] Validate store sharing still works
- [ ] Update development documentation

## Future Considerations

- **Dynamic Profile Loading**: Consider implementing profile discovery mechanisms for complex scenarios
- **Build Optimization**: Explore build caching strategies for flake-based dependencies
- **Monitoring**: Add metrics for Nix store usage and optimization effectiveness
- **Security**: Review Nix store permissions in daemonless multi-container environments

## References

- [Nix Manual - Daemonless Mode](https://nixos.org/manual/nix/stable/command-ref/nix-store.html)
- [Flakes - Nix Package Manager](https://nixos.wiki/wiki/Flakes)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- Container Architecture Decision Records in this repository
