import { vi } from 'vitest';
import { config } from '@vue/test-utils';

// Global test setup
beforeAll(() => {
  // Set up global test environment
  process.env.NODE_ENV = 'test';
  
  // Mock console methods in tests
  global.console = {
    ...console,
    // Uncomment to suppress console.log in tests
    // log: vi.fn(),
    // warn: vi.fn(),
    // error: vi.fn(),
  };
});

beforeEach(() => {
  // Clear all mocks before each test
  vi.clearAllMocks();
});

// Custom matchers
expect.extend({
  toBeValidEmail(received: string) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    const pass = emailRegex.test(received);
    return {
      pass,
      message: () => `expected ${received} to be a valid email address`,
    };
  },
  
  toBeValidUrl(received: string) {
    try {
      new URL(received);
      return {
        pass: true,
        message: () => `expected ${received} not to be a valid URL`,
      };
    } catch {
      return {
        pass: false,
        message: () => `expected ${received} to be a valid URL`,
      };
    }
  },
  
  toBeWithinRange(received: number, min: number, max: number) {
    const pass = received >= min && received <= max;
    return {
      pass,
      message: () => `expected ${received} to be within range ${min}-${max}`,
    };
  },
});

// Type declarations for custom matchers
declare global {
  namespace Vi {
    interface Assertion<T = any> {
      toBeValidEmail(): T;
      toBeValidUrl(): T;
      toBeWithinRange(min: number, max: number): T;
    }
  }
}
