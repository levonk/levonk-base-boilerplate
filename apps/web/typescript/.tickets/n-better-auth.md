---
id: n-36368
status: in_progress
deps: []
links: []
created: 2026-01-27T17:50:00Z
type: feature
priority: 1
assignee: lrepo52
---

# Replace NextAuth with Better-Auth implementation

## Description
Replace Vercel's NextAuth with Better-Auth for authentication in the Next.js boilerplate.

## References
- Better-Auth: https://github.com/better-auth/better-auth
- Example implementation: https://github.com/laduniestu/nextstart

## Acceptance Criteria
- [ ] Remove NextAuth dependencies and configuration
- [ ] Install and configure Better-Auth
- [ ] Implement authentication routes (sign-in, sign-up, sign-out)
- [ ] Configure session management with Better-Auth
- [ ] Update database schema for Better-Auth compatibility
- [ ] Implement social providers (GitHub, Google) using Better-Auth
- [ ] Update middleware to use Better-Auth session handling
- [ ] Create comprehensive unit tests for authentication
- [ ] Update environment variables and documentation
- [ ] Ensure backward compatibility with existing user management

## Implementation Notes
- Better-Auth offers better TypeScript support and performance
- Should integrate with existing Drizzle ORM setup
- Need to update user types and interfaces
- Consider migration path from NextAuth to Better-Auth
- Update all authentication-related components and hooks
