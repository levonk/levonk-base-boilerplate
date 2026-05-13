---
id: t-feature-flag-unleash
status: open
deps: [t-feature-flag-facade]
links: []
created: 2026-01-27T18:22:00Z
type: feature
priority: 1
assignee: lrepo52
---

# Unleash Feature Flag Provider Implementation

Create a concrete implementation of the feature flag provider for Unleash, integrating with both the Node.js backend SDK and the React frontend SDK. This implementation will depend on the core facade package.

## Unleash Integration Details

Unleash is an open-source feature flag platform with enterprise-grade capabilities:
- Backend SDK: https://github.com/Unleash/unleash
- React SDK: https://docs.getunleash.io/sdks/react

## Implementation Requirements

### Backend Provider (Node.js)
```typescript
import { UnleashClient } from 'unleash-client';
import { FeatureFlagProvider, EvaluationContext, Variant } from '@job-aide/feature-flag-core';

export class UnleashProvider implements FeatureFlagProvider {
  private client: UnleashClient;
  
  async initialize(config: UnleashConfig): Promise<void>;
  async isEnabled(flagKey: string, context?: EvaluationContext): Promise<boolean>;
  async getValue<T>(flagKey: string, defaultValue: T, context?: EvaluationContext): Promise<T>;
  async getVariant(flagKey: string, context?: EvaluationContext): Promise<Variant | null>;
  async trackEvent(event: string, properties?: Record<string, any>): Promise<void>;
  async destroy(): Promise<void>;
}
```

### Frontend Provider (React)
```typescript
import { useUnleashClient, UnleashProvider as UnleashContext } from '@unleash/proxy-client-react';
import { FeatureFlagProvider, EvaluationContext, Variant } from '@job-aide/feature-flag-core';

export class UnleashReactProvider implements FeatureFlagProvider {
  private client: ReturnType<typeof useUnleashClient>;
  
  async initialize(config: UnleashReactConfig): Promise<void>;
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
│   ├── unleash-provider.ts (backend)
│   ├── unleash-react-provider.ts (frontend)
│   └── index.ts
├── types/
│   ├── unleash-config.ts
│   ├── unleash-context.ts
│   └── index.ts
├── utils/
│   ├── context-builder.ts
│   ├── variant-mapper.ts
│   └── index.ts
├── react/
│   ├── hooks.tsx
│   ├── context.tsx
│   └── index.ts
└── __tests__/
    ├── unleash-provider.test.mts
    ├── unleash-react-provider.test.mts
    └── integration.test.mts
```

## Configuration Types

```typescript
interface UnleashConfig {
  url: string;
  appName: string;
  instanceId: string;
  apiKey?: string;
  environment?: string;
  refreshInterval?: number;
  metricsInterval?: number;
  disableMetrics?: boolean;
}

interface UnleashReactConfig {
  url: string;
  clientKey: string;
  appName: string;
  environment?: string;
  refreshInterval?: number;
}
```

## Special Features

### 1. Advanced Strategy Support
- Gradual rollout strategies
- User with ID strategies
- Flexible rollout strategies
- Remote address strategies
- Custom strategy implementations

### 2. Segment Integration
- User segment targeting
- Dynamic segment updates
- Segment-based rollouts

### 3. Impression Data
- Feature flag impression tracking
- Analytics integration
- Performance monitoring

### 4. React Hooks Integration
```typescript
export function useFeatureFlag(flagKey: string, context?: EvaluationContext) {
  return {
    enabled: boolean,
    variant: Variant | null,
    loading: boolean,
    error: Error | null
  };
}

export function useVariant(flagKey: string, context?: EvaluationContext) {
  return {
    variant: Variant | null,
    loading: boolean,
    error: Error | null
  };
}
```

## Implementation Strategy

📦 **Package** - This should be implemented as `@job-aide/feature-flag-unleash` in `packages/active/services/feature-flag/typescript/adapter-unleash/`

## Dependencies

```json
{
  "dependencies": {
    "@job-aide/feature-flag-core": "workspace:*",
    "unleash-client": "^5.0.0",
    "@unleash/proxy-client-react": "^1.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  },
  "peerDependencies": {
    "@job-aide/feature-flag-core": "*",
    "react": ">=18.0.0",
    "react-dom": ">=18.0.0"
  }
}
```

## Usage Examples

### Backend Usage
```typescript
import { UnleashProvider } from '@job-aide/feature-flag-unleash';
import { FeatureFlagFacade } from '@job-aide/feature-flag-core';

const provider = new UnleashProvider();
await provider.initialize({
  url: 'https://app.unleash.com',
  appName: 'my-app',
  instanceId: 'instance-123',
  apiKey: process.env.UNLEASH_API_KEY!,
  environment: 'production'
});

const facade = new FeatureFlagFacade(provider);
const isEnabled = await facade.isEnabled('new-feature', {
  userId: 'user-123',
  sessionId: 'session-456'
});
```

### React Usage
```typescript
import { UnleashReactProvider, useFeatureFlag } from '@job-aide/feature-flag-unleash/react';
import { FeatureFlagFacade } from '@job-aide/feature-flag-core';

// App setup
function App() {
  const provider = new UnleashReactProvider();
  
  return (
    <UnleashReactProvider provider={provider}>
      <MyComponent />
    </UnleashReactProvider>
  );
}

// Component usage
function MyComponent() {
  const { enabled, variant } = useFeatureFlag('new-dashboard', {
    userId: 'user-123'
  });
  
  if (enabled) {
    return <NewDashboard variant={variant} />;
  }
  
  return <OldDashboard />;
}
```

## Acceptance Criteria

- [ ] Backend provider implements all facade methods
- [ ] React provider implements all facade methods
- [ ] React hooks work correctly with context
- [ ] Advanced strategies (gradual rollout, user targeting) work
- [ ] Segment integration functions properly
- [ ] Impression data is tracked correctly
- [ ] Real-time flag updates via polling/webhooks
- [ ] Error handling covers network failures and timeouts
- [ ] TypeScript types are complete and strict
- [ ] Unit tests cover all functionality
- [ ] Integration tests verify end-to-end behavior
- [ ] Documentation includes setup and usage examples
- [ ] Package works in both Node.js and React environments
- [ ] Performance benchmarks meet requirements (<50ms for local flag evaluation)
