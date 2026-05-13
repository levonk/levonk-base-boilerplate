---
id: t-feature-flag-posthog
status: open
deps: [t-feature-flag-facade]
links: []
created: 2026-01-27T18:21:00Z
type: feature
priority: 1
assignee: lrepo52
---

# PostHog Feature Flag Provider Implementation

Create a concrete implementation of the feature flag provider for PostHog, integrating with both the Node.js backend SDK and the JavaScript browser SDK. This implementation will depend on the core facade package.

## PostHog Integration Details

PostHog provides comprehensive feature flag management with A/B testing capabilities:
- Backend SDK: https://github.com/PostHog/posthog
- Frontend SDK: https://github.com/PostHog/posthog-js

## Implementation Requirements

### Backend Provider (Node.js)
```typescript
import { PostHog } from 'posthog-node';
import { FeatureFlagProvider, EvaluationContext, Variant } from '@job-aide/feature-flag-core';

export class PostHogProvider implements FeatureFlagProvider {
  private client: PostHog;
  
  async initialize(config: PostHogConfig): Promise<void>;
  async isEnabled(flagKey: string, context?: EvaluationContext): Promise<boolean>;
  async getValue<T>(flagKey: string, defaultValue: T, context?: EvaluationContext): Promise<T>;
  async getVariant(flagKey: string, context?: EvaluationContext): Promise<Variant | null>;
  async trackEvent(event: string, properties?: Record<string, any>): Promise<void>;
  async destroy(): Promise<void>;
}
```

### Frontend Provider (Browser)
```typescript
import posthog from 'posthog-js';
import { FeatureFlagProvider, EvaluationContext, Variant } from '@job-aide/feature-flag-core';

export class PostHogBrowserProvider implements FeatureFlagProvider {
  private client: typeof posthog;
  
  async initialize(config: PostHogBrowserConfig): Promise<void>;
  async isEnabled(flagKey: string, context?: EvaluationContext): Promise<boolean>;
  async getValue<T>(flagKey: string, defaultValue: T, context?: EvaluationContext): Promise<T>;
  async getVariant(flagKey: string, context?: EvaluationContext): Promise<Variant | null>;
  async trackEvent(event: string, properties?: Record<string, any>): Promise<void>;
  async destroy(): Promise<void>;
}
```

## Package Structure

```text
src/
├── index.ts (main exports)
├── providers/
│   ├── posthog-provider.ts (backend)
│   ├── posthog-browser-provider.ts (frontend)
│   └── index.ts
├── types/
│   ├── posthog-config.ts
│   └── index.ts
├── utils/
│   ├── context-mapper.ts
│   ├── variant-mapper.ts
│   └── index.ts
└── __tests__/
    ├── posthog-provider.test.mts
    ├── posthog-browser-provider.test.mts
    └── integration.test.mts
```

## Configuration Types

```typescript
interface PostHogConfig {
  apiKey: string;
  host?: string;
  personalApiKey?: string;
  featureFlagsRequestTimeoutMs?: number;
}

interface PostHogBrowserConfig {
  apiKey: string;
  apiHost?: string;
  uiHost?: string;
  personProfiles?: 'always' | 'identified_only' | 'never';
}
```

## Special Features

### 1. A/B Testing Integration
- Support for PostHog's experiment framework
- Automatic exposure tracking
- Variant payload handling

### 2. Real-time Updates
- Webhook support for real-time flag changes
- Local cache invalidation
- Event-driven updates

### 3. Advanced Targeting
- Cohort-based targeting
- Property-based conditions
- Geographic targeting
- User segment matching

## Implementation Strategy

📦 **Package** - This should be implemented as `@job-aide/feature-flag-posthog` in `packages/active/services/feature-flag/typescript/adapter-posthog/`

## Dependencies

```json
{
  "dependencies": {
    "@job-aide/feature-flag-core": "workspace:*",
    "posthog-node": "^3.1.0",
    "posthog-js": "^1.100.0"
  },
  "peerDependencies": {
    "@job-aide/feature-flag-core": "*"
  }
}
```

## Usage Examples

### Backend Usage
```typescript
import { PostHogProvider } from '@job-aide/feature-flag-posthog';
import { FeatureFlagFacade } from '@job-aide/feature-flag-core';

const provider = new PostHogProvider();
await provider.initialize({
  apiKey: process.env.POSTHOG_API_KEY!,
  host: 'https://app.posthog.com'
});

const facade = new FeatureFlagFacade(provider);
const isEnabled = await facade.isEnabled('new-dashboard', {
  userId: 'user-123',
  email: 'user@example.com'
});
```

### Frontend Usage
```typescript
import { PostHogBrowserProvider } from '@job-aide/feature-flag-posthog/browser';
import { FeatureFlagFacade } from '@job-aide/feature-flag-core';

const provider = new PostHogBrowserProvider();
await provider.initialize({
  apiKey: 'phc_...',
  apiHost: 'https://app.posthog.com'
});

const facade = new FeatureFlagFacade(provider);
const variant = await facade.getVariant('new-checkout-flow');
```

## Acceptance Criteria

- [ ] Backend provider implements all facade methods
- [ ] Frontend provider implements all facade methods
- [ ] Real-time flag updates work correctly
- [ ] A/B testing experiments are properly tracked
- [ ] Error handling covers PostHog API failures
- [ ] Local caching reduces API calls
- [ ] TypeScript types are complete and strict
- [ ] Unit tests cover all functionality
- [ ] Integration tests verify end-to-end behavior
- [ ] Documentation includes setup and usage examples
- [ ] Package works in both Node.js and browser environments
- [ ] Performance benchmarks meet requirements (<100ms for flag evaluation)
