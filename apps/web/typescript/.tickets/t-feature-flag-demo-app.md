---
id: t-feature-flag-demo-app
status: open
deps: [t-feature-flag-facade, t-feature-flag-posthog, t-feature-flag-unleash, t-feature-flag-flagsmith, t-feature-flag-featurevisor]
links: []
created: 2026-01-27T18:26:00Z
type: feature
priority: 1
assignee: lrepo52
---

# Feature Flag Demo Application

Create an interactive demo application that allows you to test and compare all feature flag providers in real-time. This will be a practical tool for evaluating provider behavior, UI/UX, and performance in a self-hosted environment.

## Demo Application Features

### 1. Provider Switching
- Runtime provider selection
- Configuration management
- Connection status monitoring
- Real-time switching without restart

### 2. Interactive Feature Testing
- Create/edit/disable flags
- Test different user contexts
- See immediate results
- A/B testing visualization

### 3. Performance Dashboard
- Real-time metrics
- Response time graphs
- Memory usage monitoring
- Network request tracking

### 4. Self-Hosting Setup
- Docker Compose configurations
- One-click provider deployment
- Setup wizards
- Health monitoring

## Application Structure

```text
src/
├── app/
│   ├── layout.tsx
│   ├── page.tsx
│   ├── globals.css
│   └── components/
│       ├── provider-selector.tsx
│       ├── flag-editor.tsx
│       ├── context-builder.tsx
│       ├── performance-dashboard.tsx
│       ├── feature-preview.tsx
│       └── comparison-table.tsx
├── lib/
│   ├── providers/
│   │   ├── provider-manager.ts
│   │   ├── posthog-connector.ts
│   │   ├── unleash-connector.ts
│   │   ├── flagsmith-connector.ts
│   │   └── featurevisor-connector.ts
│   ├── hooks/
│   │   ├── use-feature-flags.ts
│   │   ├── use-performance.ts
│   │   └── use-provider.ts
│   ├── stores/
│   │   ├── provider-store.ts
│   │   ├── flag-store.ts
│   │   └── metrics-store.ts
│   └── utils/
│       ├── config-manager.ts
│       ├── metrics-collector.ts
│       └── demo-data.ts
├── components/
│   └── demo/
│       ├── feature-card.tsx
│       ├── variant-picker.tsx
│       ├── user-simulator.tsx
│       └── metrics-chart.tsx
├── pages/
│   ├── index.tsx (dashboard)
│   ├── flags.tsx (flag management)
│   ├── performance.tsx (performance metrics)
│   ├── comparison.tsx (provider comparison)
│   └── setup.tsx (self-hosting setup)
└── docker/
    ├── docker-compose.posthog.yml
    ├── docker-compose.unleash.yml
    ├── docker-compose.flagsmith.yml
    └── docker-compose.featurevisor.yml
```

## Key Components

### Provider Manager
```typescript
class ProviderManager {
  private providers: Map<string, FeatureFlagProvider> = new Map();
  private currentProvider: string = 'posthog';
  
  async switchProvider(providerName: string): Promise<void>;
  async getCurrentProvider(): Promise<FeatureFlagProvider>;
  async getProviderStatus(providerName: string): Promise<ProviderStatus>;
  async testConnection(providerName: string): Promise<boolean>;
}
```

### Feature Flag Editor
```typescript
interface FlagEditorProps {
  provider: string;
  flagKey: string;
  onSave: (flag: FeatureFlagConfig) => void;
}

function FlagEditor({ provider, flagKey, onSave }: FlagEditorProps) {
  // UI for creating/editing flags
  // Support for different provider-specific features
  // Real-time validation
}
```

### Performance Dashboard
```typescript
function PerformanceDashboard() {
  const metrics = usePerformanceMetrics();
  
  return (
    <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
      <MetricCard title="Avg Response Time" value={metrics.avgTime} unit="ms" />
      <MetricCard title="Requests/Second" value={metrics.rps} />
      <MetricCard title="Cache Hit Rate" value={metrics.cacheHitRate} unit="%" />
      <MetricCard title="Memory Usage" value={metrics.memoryUsage} unit="MB" />
    </div>
  );
}
```

### User Context Simulator
```typescript
function UserContextSimulator() {
  const [context, setContext] = useState<EvaluationContext>({});
  
  return (
    <div className="space-y-4">
      <Input
        placeholder="User ID"
        value={context.userId}
        onChange={(e) => setContext({ ...context, userId: e.target.value })}
      />
      <Input
        placeholder="Email"
        type="email"
        value={context.email}
        onChange={(e) => setContext({ ...context, email: e.target.value })}
      />
      <KeyValueEditor
        title="Custom Attributes"
        value={context.customAttributes}
        onChange={(attrs) => setContext({ ...context, customAttributes: attrs })}
      />
    </div>
  );
}
```

## Demo Scenarios

### 1. Basic Flag Testing
```typescript
const demoFlags = [
  {
    key: 'new-dashboard',
    type: 'boolean',
    description: 'Enable the new dashboard design',
    variants: [
      { key: 'enabled', name: 'Enabled' },
      { key: 'disabled', name: 'Disabled' }
    ]
  },
  {
    key: 'checkout-flow',
    type: 'variant',
    description: 'A/B test different checkout flows',
    variants: [
      { key: 'control', name: 'Standard Checkout' },
      { key: 'simplified', name: 'Simplified Checkout' },
      { key: 'one-page', name: 'One Page Checkout' }
    ]
  },
  {
    key: 'api-endpoints',
    type: 'json',
    description: 'Configure API endpoints per environment',
    defaultValue: {
      production: 'https://api.example.com',
      staging: 'https://staging-api.example.com'
    }
  }
];
```

### 2. Performance Testing
```typescript
function PerformanceTestRunner() {
  const [isRunning, setIsRunning] = useState(false);
  const [results, setResults] = useState<PerformanceResult[]>([]);
  
  const runTest = async () => {
    setIsRunning(true);
    const testResults = await Promise.all([
      testProvider('posthog'),
      testProvider('unleash'),
      testProvider('flagsmith'),
      testProvider('featurevisor')
    ]);
    setResults(testResults);
    setIsRunning(false);
  };
  
  return (
    <div>
      <button onClick={runTest} disabled={isRunning}>
        {isRunning ? 'Running Tests...' : 'Run Performance Tests'}
      </button>
      <PerformanceChart data={results} />
    </div>
  );
}
```

### 3. Self-Hosting Setup
```typescript
function SelfHostingSetup() {
  const [selectedProvider, setSelectedProvider] = useState('posthog');
  const [isRunning, setIsRunning] = useState(false);
  
  const startProvider = async (provider: string) => {
    setIsRunning(true);
    await fetch(`/api/setup/${provider}`, { method: 'POST' });
    setIsRunning(false);
  };
  
  return (
    <div className="space-y-6">
      <ProviderSelector 
        selected={selectedProvider}
        onChange={setSelectedProvider}
      />
      
      <DockerComposeViewer provider={selectedProvider} />
      
      <button 
        onClick={() => startProvider(selectedProvider)}
        disabled={isRunning}
        className="bg-blue-500 text-white px-4 py-2 rounded"
      >
        {isRunning ? 'Starting...' : `Start ${selectedProvider}`}
      </button>
      
      <HealthStatus provider={selectedProvider} />
    </div>
  );
}
```

## Docker Configurations

### PostHog Setup
```yaml
# docker-compose.posthog.yml
version: '3.8'
services:
  posthog-web:
    image: posthog/posthog:latest
    environment:
      POSTHOG_WEB_SECRET: ${POSTHOG_WEB_SECRET}
      DATABASE_URL: postgres://postgres:postgres@postgres:5432/posthog
      REDIS_URL: redis://redis:6379
      EMAIL_HOST: mailhog
    ports:
      - "8000:8000"
    depends_on:
      - postgres
      - redis
      - mailhog
  
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: posthog
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:7-alpine
    
  mailhog:
    image: mailhog/mailhog
    ports:
      - "1025:1025"
      - "8025:8025"

volumes:
  postgres_data:
```

### Unleash Setup
```yaml
# docker-compose.unleash.yml
version: '3.8'
services:
  unleash:
    image: unleashorg/unleash-server:latest
    environment:
      DATABASE_URL: postgres://postgres:postgres@postgres:5432/unleash
      DATABASE_SSL: 'false'
      LOG_LEVEL: info
    ports:
      - "4242:4242"
    depends_on:
      - postgres
  
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: unleash
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

## API Routes

### Provider Management
```typescript
// app/api/provider/[provider]/route.ts
export async function POST(
  request: Request,
  { params }: { params: { provider: string } }
) {
  const { config } = await request.json();
  
  // Initialize provider with config
  const provider = createProvider(params.provider, config);
  await provider.initialize(config);
  
  // Store in session/state
  providerManager.setProvider(params.provider, provider);
  
  return Response.json({ success: true });
}

export async function GET(
  request: Request,
  { params }: { params: { provider: string } }
) {
  const status = await providerManager.getProviderStatus(params.provider);
  return Response.json(status);
}
```

### Flag Testing
```typescript
// app/api/flags/test/route.ts
export async function POST(request: Request) {
  const { provider, flagKey, context } = await request.json();
  
  const providerInstance = await providerManager.getProvider(provider);
  
  const results = {
    enabled: await providerInstance.isEnabled(flagKey, context),
    value: await providerInstance.getValue(flagKey, null, context),
    variant: await providerInstance.getVariant(flagKey, context)
  };
  
  return Response.json(results);
}
```

## Implementation Strategy

📦 **Package** - This should be implemented as a Next.js demo app in `apps/active/demo/feature-flag-playground/`

## Dependencies

```json
{
  "dependencies": {
    "next": "14.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "@job-aide/feature-flag-core": "workspace:*",
    "@job-aide/feature-flag-posthog": "workspace:*",
    "@job-aide/feature-flag-unleash": "workspace:*",
    "@job-aide/feature-flag-flagsmith": "workspace:*",
    "@job-aide/feature-flag-featurevisor": "workspace:*",
    "recharts": "^2.8.0",
    "zustand": "^4.4.0",
    "tailwindcss": "^3.3.0"
  }
}
```

## Acceptance Criteria

- [ ] All 4 providers can be tested in one interface
- [ ] Provider switching works without page reload
- [ ] Flags can be created/edited through the UI
- [ ] Real-time performance metrics are displayed
- [ ] Docker setups work with one click
- [ ] User context simulation is intuitive
- [ ] A/B testing visualization is clear
- [ ] Comparison tables show provider differences
- [ ] Setup wizards guide through self-hosting
- [ ] Health monitoring shows provider status
- [ ] Responsive design works on mobile
- [ ] Dark mode support
- [ ] Export/import configurations
- [ ] Session persistence for provider settings
