---
modeline: "vim: set ft=markdown:"
title: "ADR: Agent Base Image Selection Strategy"
adr-id: adr-20260322001
slug: 20260322001-agent-base-image-selection
url: /internal-docs/adr/adr-20260322001-agent-base-image-selection.md
synopsis: Define strategy for selecting base images for AI agents based on security requirements and operational context
author: https://github.com/levonk
date-created: 2026-03-22
date-updated: 2026-03-22
version: 1.0.0
status: "proposed"
aliases: []
tags: ["doc/architecture/adr", "agents", "security", "infrastructure", "docker"]
supersedes: []
superseded-by: []
related-to: ["adr-20260131001-standard-developer-ux-flow", "adr-20251226001-devbox-direnv-dev-environment"]
---

## Context

AI agents in the localnet environment have diverse requirements ranging from general-purpose assistance to specialized security operations. We need a strategy for selecting appropriate base images that balances:

1. **Security Requirements**: Some agents need specialized security tools for white/gray/blackhat operations
2. **Network Isolation**: Agents should not have unrestricted access to localnet services by default
3. **Operational Context**: Different agents have different trust levels and operational needs
4. **Maintainability**: Standardized base images reduce complexity and improve consistency

## Decision

We establish a conditional base image selection strategy for AI agents:

### Base Image Options

#### 1. `localnet-base-debiannix` - Standard Agent Base
- **Use Case**: General-purpose AI agents (code assistance, documentation, analysis)
- **Characteristics**: 
  - Debian-based with Nix package management
  - Standard development tools and libraries
  - Integrated with localnet services
  - Moderate security posture
- **Network Access**: Full localnet integration
- **Trust Level**: High (trusted agents)

#### 2. `localnet-base-kalinix` - Security Agent Base
- **Use Case**: Security-focused agents (red team, penetration testing, security analysis)
- **Characteristics**:
  - Kali Linux with Nix package management
  - Comprehensive security tool suite
  - Specialized security capabilities
  - Enhanced security posture
- **Network Access**: Isolated agent network with optional DMZ access
- **Trust Level**: Medium (security agents require isolation)

### Network Isolation Strategy

#### Agent Network Architecture
```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Localnet      │    │    DMZ Network   │    │  Agent Network  │
│   Services      │◄──►│  (Optional)      │◄──►│   (Isolated)    │
└─────────────────┘    └──────────────────┘    └─────────────────┘
         ▲                       ▲                       ▲
         │                       │                       │
    Trusted Agents        Controlled Access       Security Agents
  (base-debiannix)        (Limited Services)    (base-kalinix)
```

#### Network Access Rules

**Standard Agents (base-debiannix)**:
- Full access to localnet services
- Direct integration with development tools
- Shared volumes and resources

**Security Agents (base-kalinix)**:
- Isolated agent network by default
- Optional DMZ access for specific operations
- Persistent storage in isolated volumes
- No direct access to localnet services

**DMZ Access Conditions**:
- Explicit configuration required
- Service-specific firewall rules
- Audit logging for all cross-network access
- Time-limited access sessions

### Decision Matrix

| Agent Type | Base Image | Network | Trust Level | Use Cases |
|------------|------------|---------|-------------|-----------|
| Code Assistant | `localnet-base-debiannix` | Localnet | High | Code generation, debugging, documentation |
| Security Analyst | `localnet-base-kalinix` | Agent + DMZ | Medium | Vulnerability assessment, security analysis |
| Red Team Agent | `localnet-base-kalinix` | Agent Only | Low | Penetration testing, exploit development |
| Research Agent | `localnet-base-debiannix` | Localnet | High | Data analysis, documentation, research |
| Monitoring Agent | `localnet-base-debiannix` | Localnet | High | System monitoring, alerting, reporting |

### Implementation Guidelines

#### 1. Agent Classification
Agents must be classified during creation:

```yaml
# Agent Configuration Example
agent:
  name: "security-scanner"
  type: "security"  # "standard" or "security"
  base_image: "localnet-base-kalinix"
  network: "agent-network"
  dmz_access: false
  trust_level: "medium"
```

#### 2. Network Configuration
```yaml
# docker-compose.agent.yml
services:
  security-agent:
    build:
      context: .
      dockerfile: Dockerfile.security-agent
    networks:
      - agent-network
      # Optional DMZ access
      # - dmz-network
    profiles:
      - security
      - agents
```

#### 3. Security Controls
- **Mandatory**: All security agents must use isolated networks
- **Mandatory**: No direct access to localnet services without explicit DMZ configuration
- **Mandatory**: All cross-network access must be logged and audited
- **Recommended**: Time-limited sessions for DMZ access

## Rationale

### Security Benefits
1. **Isolation**: Security agents are isolated from critical localnet services
2. **Containment**: Potential security compromises are contained within agent network
3. **Auditability**: All cross-network access is logged and monitored
4. **Flexibility**: DMZ provides controlled access when needed

### Operational Benefits
1. **Specialization**: Security agents have access to comprehensive tool suites
2. **Performance**: Optimized base images reduce startup time and resource usage
3. **Maintainability**: Standardized base images simplify updates and maintenance
4. **Scalability**: Clear patterns for adding new agents

### Risk Mitigation
1. **Least Privilege**: Agents only have access to necessary resources
2. **Defense in Depth**: Multiple layers of network isolation
3. **Monitoring**: Comprehensive logging of agent activities
4. **Incident Response**: Clear containment procedures for security incidents

## Implementation Plan

### Phase 1: Base Image Development
- [ ] Create `localnet-base-kali` and `localnet-base-kalinix` images
- [ ] Implement security tool suites
- [ ] Add health checks and monitoring
- [ ] Test base image functionality

### Phase 2: Network Infrastructure
- [ ] Create isolated agent network
- [ ] Implement DMZ network configuration
- [ ] Set up firewall rules and logging
- [ ] Test network isolation and access controls

### Phase 3: Agent Migration
- [ ] Update existing security agents to use `base-kalinix`
- [ ] Implement agent classification system
- [ ] Update docker-compose configurations
- [ ] Test agent functionality in isolation

### Phase 4: Monitoring and Auditing
- [ ] Implement cross-network access logging
- [ ] Set up security monitoring
- [ ] Create incident response procedures
- [ ] Test security incident response

## Consequences

### Positive Consequences
1. **Enhanced Security**: Clear separation between trusted and security agents
2. **Specialized Tools**: Security agents have access to comprehensive tool suites
3. **Operational Clarity**: Clear patterns for agent deployment and management
4. **Risk Management**: Contained environment for potentially risky operations

### Negative Consequences
1. **Complexity**: Additional network configuration and management overhead
2. **Resource Usage**: Multiple base images increase storage requirements
3. **Integration Challenges**: Some agents may require cross-network access
4. **Maintenance**: Additional infrastructure components to maintain

### Mitigation Strategies
1. **Documentation**: Clear guidelines for agent classification and deployment
2. **Automation**: Automated tools for network configuration and monitoring
3. **Standardization**: Consistent patterns for agent development
4. **Testing**: Comprehensive testing of network isolation and security controls

## Future Considerations

### Scalability
- Consider automated agent classification based on requirements
- Implement dynamic network access controls
- Develop agent lifecycle management tools

### Evolution
- Evaluate additional specialized base images for other domains
- Consider container orchestration for large-scale agent deployments
- Implement advanced security monitoring and threat detection

### Integration
- Develop API for agent network access requests
- Implement automated security scanning for agent images
- Create integration with external security tools and platforms

## Status

**Status**: Proposed
**Next Steps**: Implement Phase 1 (Base Image Development)
**Review Date**: 2026-03-29
