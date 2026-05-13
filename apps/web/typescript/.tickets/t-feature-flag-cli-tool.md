---
id: t-feature-flag-cli-tool
status: open
deps: [t-feature-flag-facade, t-feature-flag-posthog, t-feature-flag-unleash, t-feature-flag-flagsmith, t-feature-flag-featurevisor]
links: []
created: 2026-01-27T18:27:00Z
type: feature
priority: 1
assignee: lrepo52
---

# Feature Flag CLI Tool

Create a command-line interface tool for quickly testing and comparing feature flag providers. This CLI will enable rapid evaluation, benchmarking, and management of feature flags across all providers from the command line.

## CLI Features

### 1. Provider Management
- List available providers
- Test provider connections
- Switch between providers
- Configure provider settings

### 2. Flag Operations
- List all flags
- Get flag values
- Set flag values (where supported)
- Test flag evaluation with different contexts

### 3. Benchmarking
- Performance benchmarks
- Load testing
- Comparison reports
- Export results

### 4. Self-Hosting Helpers
- Generate Docker configurations
- Setup wizards
- Health checks
- Log monitoring

## CLI Commands

### Provider Management
```bash
# List all available providers
feature-flag providers list

# Test connection to a provider
feature-flag providers test posthog

# Configure a provider
feature-flag providers configure unleash \
  --url "http://localhost:4242" \
  --api-key "your-api-key"

# Switch active provider
feature-flag providers switch featurevisor
```

### Flag Operations
```bash
# List all flags
feature-flag flags list

# Get flag value
feature-flag flags get new-dashboard \
  --user-id "user-123" \
  --email "user@example.com"

# Test flag with custom context
feature-flag flags test checkout-flow \
  --context '{"plan":"premium","country":"US"}'

# Set flag value (if supported)
feature-flag flags set new-feature --enabled true
```

### Benchmarking
```bash
# Run performance benchmark
feature-flag benchmark run \
  --iterations 10000 \
  --providers all \
  --export results.json

# Compare providers
feature-flag benchmark compare \
  --providers posthog,unleash,featurevisor

# Load testing
feature-flag benchmark load \
  --concurrency 100 \
  --duration 30s
```

### Self-Hosting
```bash
# Generate Docker config
feature-flag setup generate posthog \
  --output docker-compose.yml

# Start provider
feature-flag setup start unleash

# Check health
feature-flag setup health flagsmith

# View logs
feature-flag setup logs featurevisor
```

## Implementation Structure

```text
src/
├── index.ts (CLI entry point)
├── cli/
│   ├── commands/
│   │   ├── providers.ts
│   │   ├── flags.ts
│   │   ├── benchmark.ts
│   │   └── setup.ts
│   ├── utils/
│   │   ├── config.ts
│   │   ├── output.ts
│   │   ├── validation.ts
│   │   └── logger.ts
│   └── types/
│       ├── cli-options.ts
│       └── command-results.ts
├── providers/
│   ├── provider-factory.ts
│   ├── posthog-cli.ts
│   ├── unleash-cli.ts
│   ├── flagsmith-cli.ts
│   └── featurevisor-cli.ts
├── benchmark/
│   ├── runner.ts
│   ├── metrics.ts
│   ├── reporters.ts
│   └── load-tester.ts
├── setup/
│   ├── docker-generator.ts
│   ├── wizard.ts
│   ├── health-checker.ts
│   └── log-monitor.ts
└── templates/
    ├── docker-compose.posthog.yml
    ├── docker-compose.unleash.yml
    ├── docker-compose.flagsmith.yml
    └── docker-compose.featurevisor.yml
```

## Core Components

### CLI Entry Point
```typescript
#!/usr/bin/env node
import { Command } from 'commander';
import { providersCommand } from './cli/commands/providers';
import { flagsCommand } from './cli/commands/flags';
import { benchmarkCommand } from './cli/commands/benchmark';
import { setupCommand } from './cli/commands/setup';

const program = new Command();

program
  .name('feature-flag')
  .description('CLI for testing and managing feature flag providers')
  .version('1.0.0');

program.addCommand(providersCommand);
program.addCommand(flagsCommand);
program.addCommand(benchmarkCommand);
program.addCommand(setupCommand);

program.parse();
```

### Provider Commands
```typescript
export const providersCommand = new Command('providers')
  .description('Manage feature flag providers');

providersCommand
  .command('list')
  .description('List all available providers')
  .action(async () => {
    const providers = ['posthog', 'unleash', 'flagsmith', 'featurevisor'];
    console.table(providers.map(p => ({ provider: p })));
  });

providersCommand
  .command('test <provider>')
  .description('Test connection to a provider')
  .action(async (provider) => {
    const providerInstance = await createProvider(provider);
    try {
      await providerInstance.initialize(getProviderConfig(provider));
      console.log(`✅ ${provider} connection successful`);
    } catch (error) {
      console.error(`❌ ${provider} connection failed:`, error.message);
      process.exit(1);
    }
  });

providersCommand
  .command('configure <provider>')
  .description('Configure a provider')
  .option('--url <url>', 'Provider URL')
  .option('--api-key <key>', 'API key')
  .option('--environment <env>', 'Environment')
  .action(async (provider, options) => {
    const config = { ...options };
    await saveProviderConfig(provider, config);
    console.log(`✅ ${provider} configured successfully`);
  });
```

### Flag Commands
```typescript
export const flagsCommand = new Command('flags')
  .description('Manage feature flags');

flagsCommand
  .command('list')
  .description('List all flags')
  .option('--provider <provider>', 'Provider to use')
  .action(async (options) => {
    const provider = await getProvider(options.provider);
    const flags = await provider.getAllFlags();
    console.table(flags);
  });

flagsCommand
  .command('get <flagKey>')
  .description('Get flag value')
  .option('--user-id <id>', 'User ID')
  .option('--email <email>', 'User email')
  .option('--context <json>', 'Additional context (JSON)')
  .action(async (flagKey, options) => {
    const provider = await getProvider();
    const context = buildContext(options);
    
    const results = {
      enabled: await provider.isEnabled(flagKey, context),
      value: await provider.getValue(flagKey, null, context),
      variant: await provider.getVariant(flagKey, context)
    };
    
    console.log(JSON.stringify(results, null, 2));
  });

flagsCommand
  .command('test <flagKey>')
  .description('Test flag with multiple contexts')
  .option('--contexts <file>', 'Contexts file (JSON)')
  .action(async (flagKey, options) => {
    const provider = await getProvider();
    const contexts = await loadContexts(options.contexts);
    
    const results = [];
    for (const context of contexts) {
      const result = {
        context: context.name,
        enabled: await provider.isEnabled(flagKey, context),
        variant: await provider.getVariant(flagKey, context)
      };
      results.push(result);
    }
    
    console.table(results);
  });
```

### Benchmark Commands
```typescript
export const benchmarkCommand = new Command('benchmark')
  .description('Run performance benchmarks');

benchmarkCommand
  .command('run')
  .description('Run performance benchmark')
  .option('--iterations <n>', 'Number of iterations', '10000')
  .option('--providers <list>', 'Providers to test (comma-separated)', 'all')
  .option('--export <file>', 'Export results to file')
  .action(async (options) => {
    const providers = options.providers === 'all' 
      ? ['posthog', 'unleash', 'flagsmith', 'featurevisor']
      : options.providers.split(',');
    
    const results = [];
    
    for (const providerName of providers) {
      console.log(`\n🏃 Testing ${providerName}...`);
      const result = await runBenchmark(providerName, parseInt(options.iterations));
      results.push(result);
      console.log(`✅ ${providerName}: ${result.avgTime.toFixed(2)}ms avg`);
    }
    
    console.log('\n📊 Results:');
    console.table(results);
    
    if (options.export) {
      await writeFile(options.export, JSON.stringify(results, null, 2));
      console.log(`\n💾 Results exported to ${options.export}`);
    }
  });

benchmarkCommand
  .command('compare')
  .description('Compare providers side-by-side')
  .option('--providers <list>', 'Providers to compare', 'all')
  .action(async (options) => {
    const providers = options.providers === 'all'
      ? ['posthog', 'unleash', 'flagsmith', 'featurevisor']
      : options.providers.split(',');
    
    const comparison = await runComparison(providers);
    console.log('\n🏆 Provider Comparison:');
    console.table(comparison);
    
    // Show winner for each metric
    console.log('\n🥇 Winners:');
    console.log(`Fastest: ${comparison.fastest.provider}`);
    console.log(`Lowest Memory: ${comparison.lowestMemory.provider}`);
    console.log(`Highest Cache Hit Rate: ${comparison.highestCacheHit.provider}`);
  });
```

### Setup Commands
```typescript
export const setupCommand = new Command('setup')
  .description('Self-hosting setup helpers');

setupCommand
  .command('generate <provider>')
  .description('Generate Docker configuration')
  .option('--output <file>', 'Output file', 'docker-compose.yml')
  .action(async (provider, options) => {
    const config = await generateDockerConfig(provider);
    await writeFile(options.output, config);
    console.log(`✅ Docker config generated: ${options.output}`);
    console.log(`\n🚀 Run: docker-compose -f ${options.output} up -d`);
  });

setupCommand
  .command('start <provider>')
  .description('Start a provider')
  .action(async (provider) => {
    console.log(`🚀 Starting ${provider}...`);
    await exec(`docker-compose -f docker-compose.${provider}.yml up -d`);
    
    // Wait for startup
    await sleep(10000);
    
    const healthy = await checkHealth(provider);
    if (healthy) {
      console.log(`✅ ${provider} is healthy and ready`);
    } else {
      console.log(`⚠️  ${provider} started but health check failed`);
    }
  });

setupCommand
  .command('health <provider>')
  .description('Check provider health')
  .action(async (provider) => {
    const healthy = await checkHealth(provider);
    const status = healthy ? '✅ Healthy' : '❌ Unhealthy';
    console.log(`${provider}: ${status}`);
    
    if (!healthy) {
      console.log('\n📋 Recent logs:');
      await exec(`docker-compose logs --tail=20 ${provider}`);
    }
  });
```

## Configuration Management

### Config File Structure
```typescript
// ~/.feature-flag/config.json
{
  "defaultProvider": "posthog",
  "providers": {
    "posthog": {
      "apiKey": "your-api-key",
      "url": "https://app.posthog.com",
      "environment": "production"
    },
    "unleash": {
      "url": "http://localhost:4242",
      "apiKey": "your-api-key",
      "environment": "development"
    },
    "flagsmith": {
      "apiKey": "your-api-key",
      "url": "https://api.flagsmith.com"
    },
    "featurevisor": {
      "datafileUrl": "https://cdn.example.com/datafile.json",
      "environment": "production"
    }
  }
}
```

### Context Files
```json
// test-contexts.json
[
  {
    "name": "Free User",
    "userId": "user-free-1",
    "email": "free@example.com",
    "customAttributes": {
      "plan": "free",
      "country": "US"
    }
  },
  {
    "name": "Premium User",
    "userId": "user-premium-1",
    "email": "premium@example.com",
    "customAttributes": {
      "plan": "premium",
      "country": "US",
      "signupDate": "2024-01-01"
    }
  },
  {
    "name": "Admin User",
    "userId": "user-admin-1",
    "email": "admin@example.com",
    "customAttributes": {
      "role": "admin",
      "permissions": ["read", "write", "admin"]
    }
  }
]
```

## Implementation Strategy

📦 **Package** - This should be implemented as `@job-aide/feature-flag-cli` in `packages/active/tools/cli/feature-flag/`

## Dependencies

```json
{
  "dependencies": {
    "@job-aide/feature-flag-core": "workspace:*",
    "@job-aide/feature-flag-posthog": "workspace:*",
    "@job-aide/feature-flag-unleash": "workspace:*",
    "@job-aide/feature-flag-flagsmith": "workspace:*",
    "@job-aide/feature-flag-featurevisor": "workspace:*",
    "commander": "^11.0.0",
    "chalk": "^5.3.0",
    "ora": "^7.0.0",
    "inquirer": "^9.2.0",
    "cli-table3": "^0.6.3"
  },
  "bin": {
    "feature-flag": "./dist/index.js"
  }
}
```

## Usage Examples

### Quick Provider Testing
```bash
# Configure PostHog
feature-flag providers configure posthog \
  --api-key "phc_..." \
  --url "https://app.posthog.com"

# Test a flag
feature-flag flags get new-dashboard \
  --user-id "test-user" \
  --email "test@example.com"

# Switch to Unleash and test the same flag
feature-flag providers switch unleash
feature-flag flags get new-dashboard \
  --user-id "test-user" \
  --email "test@example.com"
```

### Performance Comparison
```bash
# Run full benchmark suite
feature-flag benchmark run \
  --iterations 50000 \
  --providers all \
  --export benchmark-results.json

# Quick comparison
feature-flag benchmark compare \
  --providers posthog,unleash,featurevisor
```

### Self-Hosting Setup
```bash
# Generate and start PostHog
feature-flag setup generate posthog
feature-flag setup start posthog
feature-flag setup health posthog

# Generate all provider configs
for provider in posthog unleash flagsmith featurevisor; do
  feature-flag setup generate $provider --output docker-compose.$provider.yml
done
```

## Acceptance Criteria

- [ ] All providers can be managed from CLI
- [ ] Flag operations work with context
- [ ] Benchmark results are accurate and comparable
- [ ] Docker configurations are generated correctly
- [ ] Health checks work reliably
- [ ] Configuration is persisted locally
- [ ] Output is formatted and readable
- [ ] Error handling is comprehensive
- [ ] Help documentation is complete
- [ ] CLI follows standard conventions
- [ ] Performance is suitable for large-scale testing
- [ ] Integration with existing tools works seamlessly
