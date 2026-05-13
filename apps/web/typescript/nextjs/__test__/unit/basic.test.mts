import { describe, it, expect } from 'vitest';

describe('Basic Test Setup Validation', () => {
  it('should run a basic test', () => {
    expect(true).toBe(true);
  });

  it('should support ES modules', () => {
    expect(typeof 'import').toBe('string');
  });

  it('should support async/await', async () => {
    const result = await Promise.resolve('test');
    expect(result).toBe('test');
  });

  it('should have vitest globals available', () => {
    expect(typeof describe).toBe('function');
    expect(typeof it).toBe('function');
    expect(typeof expect).toBe('function');
  });
});
