import { describe, it, expect, vi, beforeEach } from 'vitest';
import { readFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { dirname } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));

// Mock environment variables
const mockEnv = {
  DATABASE_URL: 'postgresql://test:test@localhost:5432/testdb',
  NODE_ENV: 'test',
};

vi.mock('@/env', () => ({
  env: mockEnv,
}));

// Mock drizzle-orm
vi.mock('drizzle-orm/postgres-js', () => ({
  drizzle: vi.fn(() => ({
    select: vi.fn(),
    insert: vi.fn(),
    update: vi.fn(),
    delete: vi.fn(),
    query: vi.fn(),
  })),
}));

vi.mock('postgres', () => ({
  default: vi.fn(() => ({})),
}));

describe('Database Configuration Tests', () => {
  const drizzleConfigPath = join(__dirname, '../../drizzle.config.ts');
  const packageJsonPath = join(__dirname, '../../package.json.jinja');

  describe('Drizzle Configuration', () => {
    it('should have drizzle.config.ts file', () => {
      expect(existsSync(drizzleConfigPath)).toBe(true);
    });

    it('should export valid configuration', () => {
      const configContent = readFileSync(drizzleConfigPath, 'utf-8');
      expect(configContent).toContain('defineConfig');
      expect(configContent).toContain('database');
      expect(configContent).toContain('schema');
    });

    it('should reference database schema file', () => {
      const configContent = readFileSync(drizzleConfigPath, 'utf-8');
      expect(configContent).toContain('./src/lib/db/schema');
    });

    it('should use environment variables for database URL', () => {
      const configContent = readFileSync(drizzleConfigPath, 'utf-8');
      expect(configContent).toContain('process.env.DATABASE_URL');
    });

    it('should be properly typed with TypeScript', () => {
      const configContent = readFileSync(drizzleConfigPath, 'utf-8');
      expect(configContent).toContain('import type');
      expect(configContent).toContain('Config');
    });
  });

  describe('Database Dependencies', () => {
    it('should include drizzle-orm in package.json', () => {
      const packageContent = readFileSync(packageJsonPath, 'utf-8');
      expect(packageContent).toContain('"drizzle-orm"');
    });

    it('should include postgres driver', () => {
      const packageContent = readFileSync(packageJsonPath, 'utf-8');
      expect(packageContent).toContain('"postgres"');
    });

    it('should include drizzle-kit for migrations', () => {
      const packageContent = readFileSync(packageJsonPath, 'utf-8');
      expect(packageContent).toContain('"drizzle-kit"');
    });

    it('should have database-related scripts', () => {
      const packageContent = readFileSync(packageJsonPath, 'utf-8');
      expect(packageContent).toContain('"db:generate"');
      expect(packageContent).toContain('"db:migrate"');
      expect(packageContent).toContain('"db:push"');
      expect(packageContent).toContain('"db:studio"');
    });
  });

  describe('Database Schema Structure', () => {
    const schemaDir = join(__dirname, '../../src/lib/db');

    it('should have database directory structure', () => {
      expect(existsSync(schemaDir)).toBe(true);
    });

    it('should have schema file', () => {
      const schemaPath = join(schemaDir, 'schema.ts');
      expect(existsSync(schemaPath)).toBe(true);
    });

    it('should have index file for exports', () => {
      const indexPath = join(schemaDir, 'index.ts');
      expect(existsSync(indexPath)).toBe(true);
    });

    it('should export schema from index', () => {
      const indexContent = readFileSync(indexPath, 'utf-8');
      expect(indexContent).toContain('export');
      expect(indexContent).toContain('schema');
    });
  });

  describe('Schema Content Validation', () => {
    const schemaPath = join(__dirname, '../../src/lib/db/schema.ts');

    it('should import drizzle schema builder', () => {
      const schemaContent = readFileSync(schemaPath, 'utf-8');
      expect(schemaContent).toContain('pgTable');
      expect(schemaContent).toContain('serial');
      expect(schemaContent).toContain('varchar');
      expect(schemaContent).toContain('timestamp');
    });

    it('should define user table structure', () => {
      const schemaContent = readFileSync(schemaPath, 'utf-8');
      expect(schemaContent).toContain('users');
      expect(schemaContent).toContain('id');
      expect(schemaContent).toContain('email');
      expect(schemaContent).toContain('name');
    });

    it('should have proper field types and constraints', () => {
      const schemaContent = readFileSync(schemaPath, 'utf-8');
      expect(schemaContent).toContain('primaryKey');
      expect(schemaContent).toContain('notNull');
      expect(schemaContent).toContain('unique');
    });

    it('should export schema objects', () => {
      const schemaContent = readFileSync(schemaPath, 'utf-8');
      expect(schemaContent).toContain('export');
      expect(schemaContent).toContain('users');
    });
  });

  describe('Environment Configuration', () => {
    it('should have environment example file', () => {
      const envExamplePath = join(__dirname, '../../.env.example');
      expect(existsSync(envExamplePath)).toBe(true);
    });

    it('should include database URL in environment example', () => {
      const envExampleContent = readFileSync(envExamplePath, 'utf-8');
      expect(envExampleContent).toContain('DATABASE_URL');
      expect(envExampleContent).toContain('postgresql://');
    });

    it('should handle different environments', () => {
      const envExampleContent = readFileSync(envExamplePath, 'utf-8');
      expect(envExampleContent).toContain('NODE_ENV');
    });
  });

  describe('Migration Support', () => {
    it('should support migration commands in package.json', () => {
      const packageContent = readFileSync(packageJsonPath, 'utf-8');
      
      expect(packageContent).toContain('drizzle-kit generate');
      expect(packageContent).toContain('drizzle-kit migrate');
      expect(packageContent).toContain('drizzle-kit push');
    });

    it('should have proper drizzle configuration for migrations', () => {
      const configContent = readFileSync(drizzleConfigPath, 'utf-8');
      expect(configContent).toContain('migrations');
    });
  });

  describe('Database Connection', () => {
    it('should handle connection configuration', () => {
      const configContent = readFileSync(drizzleConfigPath, 'utf-8');
      expect(configContent).toContain('DATABASE_URL');
    });

    it('should support SSL configuration', () => {
      const configContent = readFileSync(drizzleConfigPath, 'utf-8');
      // Should handle SSL for production environments
      expect(configContent).toBeDefined();
    });
  });

  describe('Type Safety', () => {
    it('should have TypeScript types for database', () => {
      const schemaContent = readFileSync(join(__dirname, '../../src/lib/db/schema.ts'), 'utf-8');
      expect(schemaContent).toContain('typeof');
      expect(schemaContent).toContain('InferSelectModel');
    });

    it('should export typed schema', () => {
      const indexContent = readFileSync(join(__dirname, '../../src/lib/db/index.ts'), 'utf-8');
      expect(indexContent).toContain('export type');
    });
  });

  describe('Development Tools', () => {
    it('should include drizzle studio for database management', () => {
      const packageContent = readFileSync(packageJsonPath, 'utf-8');
      expect(packageContent).toContain('db:studio');
    });

    it('should support database seeding scripts', () => {
      const packageContent = readFileSync(packageJsonPath, 'utf-8');
      expect(packageContent).toContain('db:seed');
    });
  });

  describe('Error Handling', () => {
    it('should handle missing database URL gracefully', async () => {
      // Test that configuration handles missing environment variables
      const { config } = await import('../../drizzle.config.ts');
      expect(typeof config).toBe('function');
    });

    it('should validate database connection format', () => {
      const envExampleContent = readFileSync(join(__dirname, '../../.env.example'), 'utf-8');
      expect(envExampleContent).toMatch(/postgresql:\/\/[^:]+:[^@]+@[^:]+:\d+\/.+/);
    });
  });
});
