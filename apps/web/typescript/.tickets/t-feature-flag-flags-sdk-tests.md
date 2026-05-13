---
id: t-feature-flag-flags-sdk-tests
status: open
deps: [t-feature-flag-flags-sdk]
links: []
created: 2026-01-27T18:29:00Z
type: feature
priority: 1
assignee: lrepo52
---

# Flags SDK Provider Unit Tests

Create comprehensive unit tests for the Flags SDK feature flag provider implementation, ensuring full coverage of all functionality including backend provider, browser provider, adapters, and integration scenarios.

## Test Coverage Requirements

### 1. Backend Provider Tests
- Initialization and configuration
- Flag evaluation methods
- Error handling and edge cases
- Caching behavior
- Real-time updates
- Performance characteristics

### 2. Browser Provider Tests
- Browser-specific initialization
- Local/session storage integration
- Background synchronization
- WebSocket/polling behavior
- Offline functionality

### 3. Adapter Tests
- Storage adapter functionality
- Fetch adapter behavior
- Context mapping accuracy
- Variant mapping correctness

### 4. Integration Tests
- End-to-end flag evaluation
- Provider switching
- Real-world usage scenarios
- Performance under load

## Test Structure

```text
src/
├── __tests__/
│   ├── unit/
│   │   ├── providers/
│   │   │   ├── flags-sdk-provider.test.mts
│   │   │   └── flags-sdk-browser-provider.test.mts
│   │   ├── adapters/
│   │   │   ├── storage-adapter.test.mts
│   │   │   ├── fetch-adapter.test.mts
│   │   │   └── context-mapper.test.mts
│   │   ├── utils/
│   │   │   ├── flag-mapper.test.mts
│   │   │   ├── variant-mapper.test.mts
│   │   │   └── cache-manager.test.mts
│   │   └── types/
│   │       └── config-validation.test.mts
│   ├── integration/
│   │   ├── backend-integration.test.mts
│   │   ├── browser-integration.test.mts
│   │   ├── real-time-updates.test.mts
│   │   └── performance.test.mts
│   ├── e2e/
│   │   ├── complete-workflow.test.mts
│   │   ├── multi-provider.test.mts
│   │   └── error-recovery.test.mts
│   ├── fixtures/
│   │   ├── mock-responses.ts
│   │   ├── test-data.ts
│   │   ├── flag-configurations.ts
│   │   └── user-contexts.ts
│   ├── mocks/
│   │   ├── flags-sdk-mock.ts
│   │   ├── storage-mock.ts
│   │   ├── websocket-mock.ts
│   │   └── fetch-mock.ts
│   └── utils/
│       ├── test-helpers.ts
│       ├── performance-measurer.ts
│       └── assertion-helpers.ts
```

## Core Test Implementations

### Backend Provider Tests
```typescript
// src/__tests__/unit/providers/flags-sdk-provider.test.mts
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { FlagsSDKProvider } from '../../src/providers/flags-sdk-provider';
import { createMockFlagsSDK } from '../mocks/flags-sdk-mock';
import { testContexts, testFlags } from '../fixtures/test-data';

describe('FlagsSDKProvider', () => {
  let provider: FlagsSDKProvider;
  let mockSDK: ReturnType<typeof createMockFlagsSDK>;

  beforeEach(() => {
    mockSDK = createMockFlagsSDK();
    provider = new FlagsSDKProvider();
    vi.mock('@flags-sdk/core', () => mockSDK);
  });

  afterEach(async () => {
    await provider.destroy();
    vi.clearAllMocks();
  });

  describe('initialization', () => {
    it('should initialize with valid configuration', async () => {
      const config = {
        endpoint: 'https://api.flags-sdk.com',
        apiKey: 'test-api-key',
        environment: 'test'
      };

      await provider.initialize(config);

      expect(mockSDK.createFlagProvider).toHaveBeenCalledWith(config);
      expect(mockSDK.provider.initialize).toHaveBeenCalled();
    });

    it('should throw error with invalid configuration', async () => {
      const invalidConfig = {
        endpoint: '',
        apiKey: ''
      };

      await expect(provider.initialize(invalidConfig))
        .rejects.toThrow('Invalid configuration');
    });

    it('should handle initialization timeout', async () => {
      mockSDK.provider.initialize.mockRejectedValue(new Error('Timeout'));

      const config = {
        endpoint: 'https://api.flags-sdk.com',
        apiKey: 'test-api-key'
      };

      await expect(provider.initialize(config))
        .rejects.toThrow('Timeout');
    });
  });

  describe('flag evaluation', () => {
    beforeEach(async () => {
      await provider.initialize({
        endpoint: 'https://api.flags-sdk.com',
        apiKey: 'test-api-key'
      });
    });

    it('should evaluate boolean flag correctly', async () => {
      mockSDK.provider.getBooleanFlag.mockResolvedValue(true);

      const result = await provider.isEnabled('test-flag', testContexts.premiumUser);

      expect(result).toBe(true);
      expect(mockSDK.provider.getBooleanFlag).toHaveBeenCalledWith(
        'test-flag',
        expect.objectContaining({
          userId: 'user-123',
          customAttributes: { plan: 'premium' }
        })
      );
    });

    it('should evaluate string flag with default', async () => {
      mockSDK.provider.getStringFlag.mockResolvedValue('variant-a');

      const result = await provider.getValue(
        'string-flag',
        'default-value',
        testContexts.freeUser
      );

      expect(result).toBe('variant-a');
    });

    it('should return default value when flag not found', async () => {
      mockSDK.provider.getStringFlag.mockResolvedValue(null);

      const result = await provider.getValue(
        'non-existent-flag',
        'default-value',
        testContexts.freeUser
      );

      expect(result).toBe('default-value');
    });

    it('should evaluate variant flag correctly', async () => {
      const mockVariant = {
        key: 'variant-b',
        name: 'Variant B',
        enabled: true,
        payload: { color: 'blue' }
      };

      mockSDK.provider.getVariant.mockResolvedValue(mockVariant);

      const result = await provider.getVariant('variant-flag', testContexts.premiumUser);

      expect(result).toEqual(mockVariant);
    });

    it('should handle evaluation errors gracefully', async () => {
      mockSDK.provider.getBooleanFlag.mockRejectedValue(new Error('Network error'));

      const result = await provider.isEnabled('test-flag', testContexts.premiumUser);

      expect(result).toBe(false); // Default fallback
    });
  });

  describe('caching', () => {
    beforeEach(async () => {
      await provider.initialize({
        endpoint: 'https://api.flags-sdk.com',
        apiKey: 'test-api-key',
        cache: { ttl: 60000, maxSize: 100 }
      });
    });

    it('should cache flag evaluation results', async () => {
      mockSDK.provider.getBooleanFlag.mockResolvedValue(true);

      // First call
      const result1 = await provider.isEnabled('cached-flag', testContexts.premiumUser);
      // Second call (should use cache)
      const result2 = await provider.isEnabled('cached-flag', testContexts.premiumUser);

      expect(result1).toBe(true);
      expect(result2).toBe(true);
      expect(mockSDK.provider.getBooleanFlag).toHaveBeenCalledTimes(1);
    });

    it('should invalidate cache on real-time updates', async () => {
      mockSDK.provider.getBooleanFlag.mockResolvedValue(true);

      const result1 = await provider.isEnabled('cached-flag', testContexts.premiumUser);
      
      // Simulate real-time update
      await provider.refreshFlags();
      
      const result2 = await provider.isEnabled('cached-flag', testContexts.premiumUser);

      expect(mockSDK.provider.getBooleanFlag).toHaveBeenCalledTimes(2);
    });

    it('should respect cache TTL', async () => {
      vi.useFakeTimers();
      
      mockSDK.provider.getBooleanFlag.mockResolvedValue(true);

      const result1 = await provider.isEnabled('cached-flag', testContexts.premiumUser);
      
      // Advance time beyond TTL
      vi.advanceTimersByTime(61000);
      
      const result2 = await provider.isEnabled('cached-flag', testContexts.premiumUser);

      expect(mockSDK.provider.getBooleanFlag).toHaveBeenCalledTimes(2);
      vi.useRealTimers();
    });
  });

  describe('event tracking', () => {
    beforeEach(async () => {
      await provider.initialize({
        endpoint: 'https://api.flags-sdk.com',
        apiKey: 'test-api-key'
      });
    });

    it('should track events successfully', async () => {
      mockSDK.provider.trackEvent.mockResolvedValue(undefined);

      await provider.trackEvent('feature-used', {
        flagKey: 'test-flag',
        userId: 'user-123',
        timestamp: Date.now()
      });

      expect(mockSDK.provider.trackEvent).toHaveBeenCalledWith(
        'feature-used',
        expect.objectContaining({
          flagKey: 'test-flag',
          userId: 'user-123'
        })
      );
    });

    it('should handle tracking errors gracefully', async () => {
      mockSDK.provider.trackEvent.mockRejectedValue(new Error('Tracking failed'));

      // Should not throw
      await expect(provider.trackEvent('test-event'))
        .resolves.toBeUndefined();
    });
  });

  describe('cleanup', () => {
    it('should cleanup resources properly', async () => {
      await provider.initialize({
        endpoint: 'https://api.flags-sdk.com',
        apiKey: 'test-api-key'
      });

      await provider.destroy();

      expect(mockSDK.provider.destroy).toHaveBeenCalled();
    });
  });
});
```

### Browser Provider Tests
```typescript
// src/__tests__/unit/providers/flags-sdk-browser-provider.test.mts
import { describe, it, expect, beforeEach, afterEach, vi } from 'vitest';
import { FlagsSDKBrowserProvider } from '../../src/providers/flags-sdk-browser-provider';

describe('FlagsSDKBrowserProvider', () => {
  let provider: FlagsSDKBrowserProvider;
  let mockLocalStorage: Storage;
  let mockSessionStorage: Storage;

  beforeEach(() => {
    // Mock browser APIs
    mockLocalStorage = {
      getItem: vi.fn(),
      setItem: vi.fn(),
      removeItem: vi.fn(),
      clear: vi.fn(),
      length: 0,
      key: vi.fn()
    };

    mockSessionStorage = {
      getItem: vi.fn(),
      setItem: vi.fn(),
      removeItem: vi.fn(),
      clear: vi.fn(),
      length: 0,
      key: vi.fn()
    };

    Object.defineProperty(window, 'localStorage', {
      value: mockLocalStorage
    });

    Object.defineProperty(window, 'sessionStorage', {
      value: mockSessionStorage
    });

    provider = new FlagsSDKBrowserProvider();
  });

  it('should initialize with localStorage enabled', async () => {
    const config = {
      endpoint: 'https://api.flags-sdk.com',
      apiKey: 'test-api-key',
      localStorage: true
    };

    await provider.initialize(config);

    expect(mockLocalStorage.setItem).toHaveBeenCalled();
  });

  it('should sync flags in background', async () => {
    const config = {
      endpoint: 'https://api.flags-sdk.com',
      apiKey: 'test-api-key',
      backgroundSync: true,
      polling: { interval: 1000, enabled: true }
    };

    await provider.initialize(config);

    // Verify polling is set up
    vi.advanceTimersByTime(1000);
    // Expect sync to be called
  });

  it('should work offline with cached flags', async () => {
    // Setup cached flags
    mockLocalStorage.getItem.mockReturnValue(JSON.stringify({
      'test-flag': { enabled: true, timestamp: Date.now() }
    }));

    const config = {
      endpoint: 'https://api.flags-sdk.com',
      apiKey: 'test-api-key',
      localStorage: true
    };

    await provider.initialize(config);

    // Should work even when offline
    const result = await provider.isEnabled('test-flag', { userId: 'test' });
    expect(result).toBe(true);
  });
});
```

### Integration Tests
```typescript
// src/__tests__/integration/real-time-updates.test.mts
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { FlagsSDKProvider } from '../../src/providers/flags-sdk-provider';
import { WebSocketMock } from '../mocks/websocket-mock';

describe('Real-time Updates Integration', () => {
  let provider: FlagsSDKProvider;
  let wsMock: WebSocketMock;

  beforeEach(() => {
    wsMock = new WebSocketMock();
    global.WebSocket = wsMock as any;
    provider = new FlagsSDKProvider();
  });

  afterEach(async () => {
    await provider.destroy();
    wsMock.cleanup();
  });

  it('should receive real-time flag updates', async () => {
    await provider.initialize({
      endpoint: 'https://api.flags-sdk.com',
      apiKey: 'test-api-key',
      polling: { enabled: false } // Use WebSocket only
    });

    const updatePromise = new Promise((resolve) => {
      provider.on('flagsChanged', resolve);
    });

    // Simulate WebSocket message
    wsMock.simulateMessage({
      type: 'flags_updated',
      data: {
        'test-flag': { enabled: true, variant: 'new-variant' }
      }
    });

    await updatePromise;
    
    // Verify flag value is updated
    const result = await provider.isEnabled('test-flag', { userId: 'test' });
    expect(result).toBe(true);
  });

  it('should fallback to polling on WebSocket failure', async () => {
    await provider.initialize({
      endpoint: 'https://api.flags-sdk.com',
      apiKey: 'test-api-key',
      polling: { enabled: true, interval: 1000 }
    });

    // Simulate WebSocket failure
    wsMock.simulateError(new Error('Connection failed'));

    // Should fallback to polling
    vi.advanceTimersByTime(1000);
    
    // Verify polling occurs
    expect(provider.getCurrentTransport()).toBe('polling');
  });
});
```

### Performance Tests
```typescript
// src/__tests__/integration/performance.test.mts
import { describe, it, expect, beforeEach } from 'vitest';
import { FlagsSDKProvider } from '../../src/providers/flags-sdk-provider';
import { PerformanceMeasurer } from '../utils/performance-measurer';

describe('Performance Tests', () => {
  let provider: FlagsSDKProvider;
  let measurer: PerformanceMeasurer;

  beforeEach(async () => {
    provider = new FlagsSDKProvider();
    measurer = new PerformanceMeasurer();
    
    await provider.initialize({
      endpoint: 'https://api.flags-sdk.com',
      apiKey: 'test-api-key',
      cache: { ttl: 300000, maxSize: 1000 }
    });
  });

  it('should evaluate 10,000 flags under performance threshold', async () => {
    const iterations = 10000;
    const threshold = 5000; // 5 seconds

    measurer.start();
    
    for (let i = 0; i < iterations; i++) {
      await provider.isEnabled(`flag-${i % 100}`, {
        userId: `user-${i}`,
        customAttributes: { group: i % 10 }
      });
    }
    
    const duration = measurer.stop();
    
    expect(duration).toBeLessThan(threshold);
    expect(duration / iterations).toBeLessThan(1); // < 1ms per evaluation
  });

  it('should maintain high cache hit rate', async () => {
    // Warm up cache
    for (let i = 0; i < 100; i++) {
      await provider.isEnabled('cached-flag', { userId: `user-${i}` });
    }

    // Measure cache performance
    measurer.start();
    
    for (let i = 0; i < 1000; i++) {
      await provider.isEnabled('cached-flag', { userId: `user-${i % 100}` });
    }
    
    const duration = measurer.stop();
    const hitRate = provider.getCacheHitRate();
    
    expect(hitRate).toBeGreaterThan(0.95); // 95% cache hit rate
    expect(duration).toBeLessThan(100); // Should be very fast with cache
  });

  it('should handle concurrent evaluations', async () => {
    const concurrency = 100;
    const promises = [];

    measurer.start();
    
    for (let i = 0; i < concurrency; i++) {
      promises.push(
        provider.isEnabled('concurrent-flag', {
          userId: `user-${i}`,
          customAttributes: { batch: 'test' }
        })
      );
    }
    
    await Promise.all(promises);
    const duration = measurer.stop();
    
    expect(duration).toBeLessThan(1000); // Should handle concurrency well
  });
});
```

## Test Utilities

### Mock Implementations
```typescript
// src/__tests__/mocks/flags-sdk-mock.ts
export function createMockFlagsSDK() {
  const provider = {
    initialize: vi.fn().mockResolvedValue(undefined),
    getBooleanFlag: vi.fn(),
    getStringFlag: vi.fn(),
    getNumberFlag: vi.fn(),
    getJSONObjectFlag: vi.fn(),
    getVariant: vi.fn(),
    trackEvent: vi.fn().mockResolvedValue(undefined),
    refreshFlags: vi.fn().mockResolvedValue(undefined),
    destroy: vi.fn().mockResolvedValue(undefined),
    on: vi.fn(),
    off: vi.fn()
  };

  return {
    createFlagProvider: vi.fn().mockReturnValue(provider),
    provider
  };
}
```

### Performance Measurement
```typescript
// src/__tests__/utils/performance-measurer.ts
export class PerformanceMeasurer {
  private startTime: number = 0;
  private endTime: number = 0;

  start(): void {
    this.startTime = performance.now();
  }

  stop(): number {
    this.endTime = performance.now();
    return this.endTime - this.startTime;
  }

  measure<T>(fn: () => T | Promise<T>): Promise<{ result: T; duration: number }> {
    this.start();
    return Promise.resolve(fn()).then(result => ({
      result,
      duration: this.stop()
    }));
  }
}
```

## Test Configuration

### Vitest Configuration
```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    environment: 'jsdom',
    setupFiles: ['./src/__tests__/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      thresholds: {
        global: {
          branches: 90,
          functions: 95,
          lines: 95,
          statements: 95
        }
      }
    }
  }
});
```

### Test Setup
```typescript
// src/__tests__/setup.ts
import { vi } from 'vitest';

// Mock browser APIs
Object.defineProperty(window, 'WebSocket', {
  writable: true,
  value: vi.fn()
});

// Mock fetch
global.fetch = vi.fn();

// Mock performance API
Object.defineProperty(global, 'performance', {
  writable: true,
  value: {
    now: vi.fn(() => Date.now())
  }
});
```

## Implementation Strategy

📦 **Package** - Tests should be included in the `@job-aide/feature-flag-flags-sdk` package

## Acceptance Criteria

- [ ] All public methods have unit tests with >95% coverage
- [ ] Error scenarios are thoroughly tested
- [ ] Performance tests meet benchmarks
- [ ] Integration tests cover real-world scenarios
- [ ] Browser-specific features are properly mocked
- [ ] Real-time updates are tested with WebSocket mocks
- [ ] Caching behavior is verified
- [ ] Concurrent access is tested
- [ ] Memory leaks are prevented (cleanup tests)
- [ ] TypeScript types are tested at runtime
- [ ] All tests pass in CI/CD environment
- [ ] Test reports provide useful metrics
- [ ] Mock implementations are realistic and comprehensive
