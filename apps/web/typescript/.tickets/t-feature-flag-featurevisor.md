---
id: t-feature-flag-featurevisor
status: open
deps: [t-feature-flag-facade]
links: []
created: 2026-01-27T18:24:00Z
type: feature
priority: 1
assignee: lrepo52
---

# Featurevisor Feature Flag Provider Implementation

Create a concrete implementation of the feature flag provider for Featurevisor, integrating with both the Node.js backend SDK and providing Next.js integration examples. This implementation will depend on the core facade package.

## Featurevisor Integration Details

Featurevisor is an open-source feature flagging and A/B testing framework with excellent TypeScript support:
- Core SDK: https://github.com/featurevisor/featurevisor
- Next.js Example: https://github.com/featurevisor/featurevisor-example-nextjs

## Implementation Requirements

### Backend Provider (Node.js)
```typescript
import { createFeaturevisorInstance } from '@featurevisor/sdk';
import { FeatureFlagProvider, EvaluationContext, Variant } from '@job-aide/feature-flag-core';

export class FeaturevisorProvider implements FeatureFlagProvider {
  private instance: ReturnType<typeof createFeaturevisorInstance>;
  
  async initialize(config: FeaturevisorConfig): Promise<void>;
  async isEnabled(flagKey: string, context?: EvaluationContext): Promise<boolean>;
  async getValue<T>(flagKey: string, defaultValue: T, context?: EvaluationContext): Promise<T>;
  async getVariant(flagKey: string, context?: EvaluationContext): Promise<Variant | null>;
  async trackEvent(event: string, properties?: Record<string, any>): Promise<void>;
  async destroy(): Promise<void>;
}
```

### Next.js Provider (React/SSR)
```typescript
import { createFeaturevisorInstance } from '@featurevisor/sdk';
import { FeatureFlagProvider, EvaluationContext, Variant } from '@job-aide/feature-flag-core';

export class FeaturevisorNextJSProvider implements FeatureFlagProvider {
  private instance: ReturnType<typeof createFeaturevisorInstance>;
  
  async initialize(config: FeaturevisorNextJSConfig): Promise<void>;
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
│   ├── featurevisor-provider.ts (backend)
│   ├── featurevisor-nextjs-provider.ts (Next.js)
│   └── index.ts
├── types/
│   ├── featurevisor-config.ts
│   ├── featurevisor-datafile.ts
│   └── index.ts
├── utils/
│   ├── context-builder.ts
│   ├── datafile-loader.ts
│   ├── variant-mapper.ts
│   └── index.ts
├── nextjs/
│   ├── hooks.tsx
│   ├── server.tsx
│   ├── client.tsx
│   └── index.ts
└── __tests__/
    ├── featurevisor-provider.test.mts
    ├── featurevisor-nextjs-provider.test.mts
    └── integration.test.mts
```

## Configuration Types

```typescript
interface FeaturevisorConfig {
  datafileUrl: string;
  environment?: string;
  refreshInterval?: number;
  stickyFeatures?: string[];
  onRefresh?: () => void;
  onError?: (error: Error) => void;
}

interface FeaturevisorNextJSConfig extends FeaturevisorConfig {
  // Next.js specific configuration
  serverDatafileUrl?: string;
  clientDatafileUrl?: string;
  enableServerSide?: boolean;
  enableClientSide?: boolean;
}
```

## Special Features

### 1. Datafile-based Architecture
- JSON/YAML datafile format
- Fast in-memory evaluation
- No network calls after initial load
- CDN-friendly distribution

### 2. Advanced Targeting Rules
- AND/OR conditions
- String/number/boolean operators
- Regex matching
- Date/time comparisons
- Custom segments

### 3. A/B Testing Integration
- Weighted variants
- Traffic allocation
- Cohort-based testing
- Statistical significance

### 4. Next.js Integration
```typescript
// Server-side hooks
export function useServerFeatureFlag(flagKey: string, context?: EvaluationContext) {
  return {
    enabled: boolean,
    variant: Variant | null,
    loading: boolean
  };
}

// Client-side hooks
export function useClientFeatureFlag(flagKey: string, context?: EvaluationContext) {
  return {
    enabled: boolean,
    variant: Variant | null,
    loading: boolean
  };
}

// Hybrid SSR provider
export function FeaturevisorSSRProvider({ 
  children, 
  datafile, 
  context 
}: FeaturevisorSSRProviderProps) {
  // Server-side rendering with client-side hydration
}
```

## Implementation Strategy

📦 **Package** - This should be implemented as `@job-aide/feature-flag-featurevisor` in `packages/active/services/feature-flag/typescript/adapter-featurevisor/`

## Dependencies

```json
{
  "dependencies": {
    "@job-aide/feature-flag-core": "workspace:*",
    "@featurevisor/sdk": "^1.0.0"
  },
  "peerDependencies": {
    "@job-aide/feature-flag-core": "*",
    "next": ">=13.0.0",
    "react": ">=18.0.0"
  },
  "optionalDependencies": {
    "next": ">=13.0.0",
    "react": ">=18.0.0"
  }
}
```

## Usage Examples

### Backend Usage
```typescript
import { FeaturevisorProvider } from '@job-aide/feature-flag-featurevisor';
import { FeatureFlagFacade } from '@job-aide/feature-flag-core';

const provider = new FeaturevisorProvider();
await provider.initialize({
  datafileUrl: 'https://cdn.example.com/datafile.json',
  environment: 'production',
  refreshInterval: 60000
});

const facade = new FeatureFlagFacade(provider);
const isEnabled = await facade.isEnabled('new-feature', {
  userId: 'user-123',
  attributes: {
    plan: 'premium',
    country: 'US'
  }
});
```

### Next.js Usage
```typescript
import { 
  FeaturevisorNextJSProvider,
  useServerFeatureFlag,
  useClientFeatureFlag 
} from '@job-aide/feature-flag-featurevisor/nextjs';

// Server-side
export async function getServerSideProps(context) {
  const provider = new FeaturevisorNextJSProvider();
  await provider.initialize({
    datafileUrl: 'https://cdn.example.com/datafile.json',
    enableServerSide: true
  });
  
  const featureFlags = await provider.getAllFlags({
    userId: context.req.cookies.userId,
    attributes: {
      userAgent: context.req.headers['user-agent']
    }
  });
  
  return {
    props: {
      featureFlags,
      datafile: await provider.getDatafile()
    }
  };
}

// Client-side component
function MyComponent({ featureFlags }) {
  const { enabled } = useClientFeatureFlag('new-dashboard');
  
  if (enabled) {
    return <NewDashboard />;
  }
  
  return <OldDashboard />;
}
```

### A/B Testing Example
```typescript
const facade = new FeatureFlagFacade(provider);
const variant = await facade.getVariant('checkout-experiment', {
  userId: 'user-123',
  attributes: {
    totalOrders: 15
  }
});

switch (variant?.key) {
  case 'control':
    return <StandardCheckout />;
  case 'variant_a':
    return <SimplifiedCheckout />;
  case 'variant_b':
    return <OnePageCheckout />;
  default:
    return <StandardCheckout />;
}
```

## Acceptance Criteria

- [ ] Backend provider implements all facade methods
- [ ] Next.js provider implements all facade methods
- [ ] Datafile loading and refresh works correctly
- [ ] Advanced targeting rules are evaluated properly
- [ ] A/B testing variants are handled correctly
- [ ] Server-side rendering works in Next.js
- [ ] Client-side hydration works without flicker
- [ ] Real-time datafile refresh functions properly
- [ ] Error handling covers datafile loading failures
- [ ] TypeScript types are complete and strict
- [ ] Unit tests cover all functionality
- [ ] Integration tests verify end-to-end behavior
- [ ] Documentation includes setup and usage examples
- [ ] Package works in both Node.js and Next.js environments
- [ ] Performance benchmarks meet requirements (<10ms for in-memory evaluation)
