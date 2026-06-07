---
modeline: "vim: set ft=markdown:"
title: "ADR: SSH Connection Strategy with Mux, Tailscale, and Zellij"
adr-id: "adr-20260325001"
slug: "ssh-connection-strategy-mux-tailscale-zellij"
url: "https://github.com/lrepo52/job-aide/blob/main/internal-docs/adr/adr-20260325001.md"
synopsis: "Implement a robust SSH connection strategy using Mux for unstable connections, Tailscale for zero-trust networking, and Zellij for terminal multiplexing with fallback options"
author: "https://github.com/levonk"
date-created: "2026-03-25"
date-updated: "2026-03-25"
date-review: "2026-09-25"
date-triggers: ["2026-03-25"]
version: "1.0.0"
status: "proposed"
aliases: []
tags: [doc/architecture/adr]
supersedes: []
superseded-by: []
related-to: []
scope:
  impact-scope: ["remote-access", "development-environment", "infrastructure"]
  excluded-scope: ["application-logic", "database-access"]
---
# Decision Record: SSH Connection Strategy with Mux, Tailscale, and Zellij

- belongs in `internal-docs/adr/adr-20260325001.md`

---

## Context

Remote development and server management requires reliable SSH connections, especially when working across unstable networks or during travel. Traditional SSH connections can be fragile, dropping frequently and losing session state. This impacts developer productivity and makes remote work unreliable.

Current challenges include:
- SSH connections dropping on network interruptions
- Losing terminal sessions and work progress
- Manual reconnection processes
- Inconsistent access across different network environments
- Security concerns with direct SSH exposure

## Constraints

- Must maintain zero-trust security principles
- Should work across various network conditions (stable/unstable)
- Must preserve terminal sessions and state
- Should provide fallback mechanisms for reliability
- Must integrate with existing development workflows
- Should support both interactive and automated access patterns

## Decision

Implement a layered SSH connection strategy: Mosh (mobile shell) for connection resilience over Tailscale for zero-trust networking, terminating in Zellij for terminal session persistence, with fallback to direct SSH with key-based authentication.

## Rationale

This approach provides multiple layers of reliability and security:

1. **Mosh (Mobile Shell)**: Provides resilient connections that survive network interruptions, IP changes, and high-latency conditions with predictive local echo
2. **Tailscale**: Provides zero-trust networking with automatic key management, NAT traversal, and encrypted peer-to-peer connections
3. **Zellij**: Terminal multiplexer that preserves session state, windows, and processes across disconnections
4. **Fallback SSH**: Ensures connectivity even when Tailscale or Mosh are unavailable

The trade-off is increased complexity, but the reliability and security benefits outweigh this for remote development scenarios.

## Technical Approach

### Architecture Overview

**Tailscale** → gives you stable, authenticated, zero‑trust connectivity to the host  
**Mosh** → gives you roaming‑proof, sleep‑proof, jitter‑proof terminal transport  
**Zellij** → gives you persistent sessions, panes, layouts, plugins, and workspace recovery  

| Failure Mode | Solved By |
|--------------|-----------|
| Wi‑Fi changes, laptop sleep, network jitter | **Mosh** |
| Remote session continuity | **Zellij** |
| NAT traversal, stable addressing, ACLs | **Tailscale** |

### Primary Connection Path
```
Client → Mosh (mobile shell) → Tailscale → Zellij → Zsh
```

### Fallback Connection Path
```
Client → SSH (direct) → Tailscale → Zellij → Zsh
```

### Implementation Details

#### 1. Connect via Tailscale
```bash
tailscale ip -4
# e.g. 100.x.y.z
```

#### 2. Auto-start Zellij on login (recommended)
Add to `~/.bashrc` or `~/.zshrc`:
```bash
if [[ -z "$ZELLIJ" ]] && [[ $TERM != "dumb" ]]; then
  zellij attach --create main
fi
```

#### 3. Connect using Mosh
```bash
mosh --ssh="ssh -p 22" user@100.x.y.z
```

#### 4. Resume session anytime
```bash
mosh user@100.x.y.z
# Zellij auto‑attaches
```

#### 5. Recommended Aliases
Add to `~/.bash_aliases` or `~/.zshrc`:
```bash
alias m='mosh user@100.x.y.z'
alias zj='zellij attach --create main'
alias mz='mosh user@100.x.y.z -- zellij attach --create main'
```

#### 6. Optional: Deterministic Layouts
Example `~/.config/zellij/layouts/work.yml`:
```yaml
session:
  name: work
  layout:
    direction: Horizontal
    parts:
      - direction: Vertical
        parts:
          - run: { command: "htop" }
          - run: { command: "bash" }
      - run: { command: "bash" }
```

Start with: `zellij --layout work`

#### 7. SSH Key Management
- Use ed25519 keys for security and performance
- Implement key rotation policies
- Store keys in hardware security modules where possible

## Affected Components

- **Development Machines**: SSH client configuration, Mosh setup, Tailscale client
- **Remote Servers**: SSH server configuration, Mosh server, Tailscale client, Zellij installation
- **Network Infrastructure**: Tailscale coordination service, firewall rules
- **Authentication Systems**: SSH key management, Tailscale ACL policies
- **Developer Workflows**: Connection scripts, documentation, training

## Consequences

### Negative

- Increased complexity in connection setup
- Additional software dependencies (Mosh, Tailscale, Zellij)
- Learning curve for developers unfamiliar with terminal multiplexers
- Potential troubleshooting complexity with multiple layers
- Dependency on Tailscale service availability

### Positive

- Dramatically improved connection reliability
- Automatic session persistence across disconnections
- Zero-trust security model with Tailscale
- Faster reconnection with Mosh's predictive local echo
- Consistent development environment across locations
- Reduced productivity loss from network issues

### Neutral

- Shift from simple SSH connections to layered approach
- Changes to developer onboarding documentation
- Modifications to existing connection scripts and automation

## Alternatives Considered

### Layer 1: Connection Transport Alternatives

#### Mosh (Mobile Shell) - CHOSEN
- **Pros**: Survives network interruptions, IP changes, predictive local echo, low latency feel, works on high-latency connections
- **Cons**: UDP-only (may be blocked), requires both client/server installation, limited to terminal sessions, no file transfer

#### Raw SSH
- **Pros**: Universal availability, file transfer (SCP/SFTP), port forwarding, widely supported
- **Cons**: Fragile on unstable connections, high latency on poor networks, no predictive echo, sessions drop on IP changes

#### WireGuard VPN
- **Pros**: High performance, modern cryptography, kernel-level integration, works with all applications
- **Cons**: Requires VPN infrastructure, more complex setup, all-or-nothing access, additional hop overhead

#### OpenVPN
- **Pros**: Mature, widely supported, flexible routing options
- **Cons**: Higher CPU usage, TCP-over-TCP performance issues, complex configuration, slower connection establishment

### Layer 2: Zero-Trust Networking Alternatives

#### Tailscale - CHOSEN
- **Pros**: Zero-trust by design, automatic key management, NAT traversal, built-in ACLs, easy setup, mesh networking
- **Cons**: Dependency on Tailscale service, commercial licensing for large deployments, limited to supported platforms

#### Cloudflare Tunnel / Cloudflare for Teams
- **Pros**: Free tier available, excellent DDoS protection, web interface management, integrates with Cloudflare ecosystem
- **Cons**: HTTP-centric, requires Cloudflare account, potential privacy concerns, less suitable for SSH-only workflows

#### NetBird
- **Pros**: Open source, self-hostable option, WireGuard-based, similar feature set to Tailscale
- **Cons**: Less mature ecosystem, smaller community, requires self-hosting for full control

#### Pangolin
- **Pros**: Open source, focuses on developer workflows, integrates with existing tools
- **Cons**: Early stage project, limited documentation, smaller feature set compared to established solutions

#### Nebula (by Slack)
- **Pros**: Open source, cryptographic verification, designed for distributed teams, overlay network
- **Cons**: Complex initial setup, requires certificate management, more enterprise-focused

#### Traditional VPN + Bastion Hosts
- **Pros**: Full control, no third-party dependencies, can integrate with existing infrastructure
- **Cons**: High operational overhead, single point of failure, complex key management, not zero-trust by default

### Layer 3: Terminal Multiplexer Alternatives

#### Zellij - CHOSEN
- **Pros**: Modern design, Rust-based (memory safe), excellent defaults, session persistence, layout management, plugin system
- **Cons**: Newer project (less battle-tested), smaller ecosystem than tmux, learning curve for users familiar with tmux

#### tmux
- **Pros**: Mature and stable, widely used, extensive documentation, large community, scriptable, pervasive in dev environments
- **Cons**: Complex configuration, default keybindings unintuitive, steeper learning curve, older codebase

#### GNU Screen
- **Pros**: Available everywhere, minimal dependencies, simple concept
- **Cons**: Limited features, poor scrolling, dated interface, no modern session management, actively maintained but feature-stagnant

#### Byobu
- **Pros**: Enhanced tmux/screen experience, nice defaults, useful status indicators, easy setup
- **Cons**: Additional layer of abstraction, depends on underlying multiplexer, may hide complexity from troubleshooting

#### No Multiplexer (Direct Shell)
- **Pros**: Zero dependencies, simple, immediate feedback
- **Cons**: No session persistence, lost work on disconnect, no multiple windows/panes, unsuitable for remote work

## Rollout / Migration

1. **Phase 1**: Install and configure Tailscale on all development machines and servers
2. **Phase 2**: Deploy Zellij with default configurations
3. **Phase 3**: Install and configure Mosh on client and server machines
4. **Phase 4**: Update connection documentation and provide developer training
5. **Phase 5**: Gradually migrate teams to new connection strategy
6. **Phase 6**: Deprecate old connection methods after validation period

Rollback plan: Maintain direct SSH access as fallback during transition period.

## To Investigate

- Optimal Mosh UDP port configuration for different network conditions
- Zellij session management best practices for team environments
- Tailscale ACL policies for development access patterns
- Performance impact of Mosh on high-latency connections
- Integration with existing CI/CD and automation systems

## Validation

- Measure connection uptime and reconnection times in various network conditions
- Survey developer satisfaction and productivity impact
- Test security posture through penetration testing
- Validate fallback mechanisms during network outages
- Monitor performance impact on development workflows

## Review Schedule

Review this decision 6 months after implementation, then annually. Trigger early review if:
- Significant connection reliability issues are reported
- New technologies emerge that could improve the strategy
- Security requirements change
- Developer feedback indicates workflow problems

## Notes

- Current SSH connections will remain functional during transition
- Documentation updates required for developer onboarding
- Consider creating connection helper scripts to simplify adoption
- Monitor Tailscale service level and plan for service continuity

## References

- [Mosh (Mobile Shell) documentation](https://mosh.org/)
- [Tailscale documentation](https://tailscale.com/kb/)
- [Zellij terminal multiplexer](https://zellij.dev/)
- [SSH configuration best practices](https://man.openbsd.org/ssh_config)
- [WireGuard documentation](https://www.wireguard.com/)
- [Cloudflare Tunnel documentation](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/)
- [NetBird documentation](https://netbird.io/)
- [tmux documentation](https://github.com/tmux/tmux/wiki)
- Related ADR: adr-20251219001-nix-direnv-dev-environment.md

<!-- vim: set ft=markdown: -->
