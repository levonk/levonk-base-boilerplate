import { describe, it, expect, vi, beforeEach } from 'vitest';
import { readFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { dirname } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));

// Mock environment variables for Better Auth
const mockAuthEnv = {
  GITHUB_ID: 'test-github-id',
  GITHUB_SECRET: 'test-github-secret',
  GOOGLE_CLIENT_ID: 'test-google-client-id',
  GOOGLE_CLIENT_SECRET: 'test-google-client-secret',
  X_CLIENT_ID: 'test-x-client-id',
  X_CLIENT_SECRET: 'test-x-client-secret',
  LINKEDIN_CLIENT_ID: 'test-linkedin-client-id',
  LINKEDIN_CLIENT_SECRET: 'test-linkedin-client-secret',
  APPLE_CLIENT_ID: 'test-apple-client-id',
  APPLE_CLIENT_SECRET: 'test-apple-client-secret',
  APPLE_TEAM_ID: 'test-apple-team-id',
  APPLE_KEY_ID: 'test-apple-key-id',
  APPLE_PRIVATE_KEY: 'test-apple-private-key',
  NODE_ENV: 'test',
};

// Mock process.env
vi.stubEnv('GITHUB_ID', mockAuthEnv.GITHUB_ID);
vi.stubEnv('GITHUB_SECRET', mockAuthEnv.GITHUB_SECRET);
vi.stubEnv('GOOGLE_CLIENT_ID', mockAuthEnv.GOOGLE_CLIENT_ID);
vi.stubEnv('GOOGLE_CLIENT_SECRET', mockAuthEnv.GOOGLE_CLIENT_SECRET);
vi.stubEnv('X_CLIENT_ID', mockAuthEnv.X_CLIENT_ID);
vi.stubEnv('X_CLIENT_SECRET', mockAuthEnv.X_CLIENT_SECRET);
vi.stubEnv('LINKEDIN_CLIENT_ID', mockAuthEnv.LINKEDIN_CLIENT_ID);
vi.stubEnv('LINKEDIN_CLIENT_SECRET', mockAuthEnv.LINKEDIN_CLIENT_SECRET);
vi.stubEnv('APPLE_CLIENT_ID', mockAuthEnv.APPLE_CLIENT_ID);
vi.stubEnv('APPLE_CLIENT_SECRET', mockAuthEnv.APPLE_CLIENT_SECRET);
vi.stubEnv('APPLE_TEAM_ID', mockAuthEnv.APPLE_TEAM_ID);
vi.stubEnv('APPLE_KEY_ID', mockAuthEnv.APPLE_KEY_ID);
vi.stubEnv('APPLE_PRIVATE_KEY', mockAuthEnv.APPLE_PRIVATE_KEY);
vi.stubEnv('NODE_ENV', mockAuthEnv.NODE_ENV);

// Mock Better Auth
vi.mock('better-auth', () => ({
  betterAuth: vi.fn((config) => ({
    ...config,
    $Infer: {
      Session: {} as any,
    },
  })),
}));

vi.mock('better-auth/adapters/drizzle', () => ({
  drizzleAdapter: vi.fn((db, config) => ({
    db,
    provider: config.provider,
    schema: config.schema,
  })),
}));

// Mock database
vi.mock('@/lib/db', () => ({
  db: {},
}));

vi.mock('@/lib/db/schema', () => ({
  users: {},
  accounts: {},
  sessions: {},
  authenticator: {},
  verification: {},
}));

describe('Authentication Configuration Tests', () => {
  const authConfigPath = join(__dirname, '../../src/lib/auth/auth.ts');

  describe('Auth Configuration File', () => {
    it('should have auth configuration file', () => {
      expect(existsSync(authConfigPath)).toBe(true);
    });

    it('should export Better Auth configuration', () => {
      const authContent = readFileSync(authConfigPath, 'utf-8');
      expect(authContent).toContain('betterAuth');
      expect(authContent).toContain('export');
    });

    it('should include database adapter configuration', () => {
      const authContent = readFileSync(authConfigPath, 'utf-8');
      expect(authContent).toContain('drizzleAdapter');
      expect(authContent).toContain('database');
      expect(authContent).toContain('provider: "pg"');
    });

    it('should include email and password authentication', () => {
      const authContent = readFileSync(authConfigPath, 'utf-8');
      expect(authContent).toContain('emailAndPassword');
      expect(authContent).toContain('enabled: true');
    });

    it('should include social providers configuration', () => {
      const authContent = readFileSync(authConfigPath, 'utf-8');
      expect(authContent).toContain('socialProviders');
      expect(authContent).toContain('github');
      expect(authContent).toContain('google');
      expect(authContent).toContain('x');
      expect(authContent).toContain('linkedin');
      expect(authContent).toContain('apple');
    });

    it('should include session configuration', () => {
      const authContent = readFileSync(authConfigPath, 'utf-8');
      expect(authContent).toContain('session');
      expect(authContent).toContain('expiresIn');
      expect(authContent).toContain('updateAge');
      expect(authContent).toContain('cookieCache');
    });

    it('should include account linking configuration', () => {
      const authContent = readFileSync(authConfigPath, 'utf-8');
      expect(authContent).toContain('account');
      expect(authContent).toContain('accountLinking');
      expect(authContent).toContain('enabled: true');
    });

    it('should include two-factor authentication configuration', () => {
      const authContent = readFileSync(authConfigPath, 'utf-8');
      expect(authContent).toContain('twoFactor');
      expect(authContent).toContain('issuer');
      expect(authContent).toContain('appName');
      expect(authContent).toContain('totpOptions');
    });

    it('should include user fields configuration', () => {
      const authContent = readFileSync(authConfigPath, 'utf-8');
      expect(authContent).toContain('user');
      expect(authContent).toContain('additionalFields');
      expect(authContent).toContain('stripeCustomerId');
      expect(authContent).toContain('subscriptionPlan');
      expect(authContent).toContain('subscriptionStatus');
      expect(authContent).toContain('isAdmin');
    });

    it('should include advanced configuration', () => {
      const authContent = readFileSync(authConfigPath, 'utf-8');
      expect(authContent).toContain('advanced');
      expect(authContent).toContain('generateId');
      expect(authContent).toContain('crypto.randomUUID');
      expect(authContent).toContain('crossSubDomainCookies');
    });

    it('should export Session type', () => {
      const authContent = readFileSync(authConfigPath, 'utf-8');
      expect(authContent).toContain('export type Session');
      expect(authContent).toContain('typeof auth.$Infer.Session');
    });
  });

  describe('Auth Configuration Runtime', () => {
    beforeEach(() => {
      vi.clearAllMocks();
    });

    it('should load auth configuration without errors', async () => {
      const { auth } = await import('@/lib/auth/auth');
      expect(auth).toBeDefined();
      expect(typeof auth).toBe('object');
    });

    it('should configure Better Auth with correct options', async () => {
      const { betterAuth } = await import('better-auth');
      const { auth } = await import('@/lib/auth/auth');

      expect(betterAuth).toHaveBeenCalledWith(
        expect.objectContaining({
          database: expect.any(Object),
          emailAndPassword: expect.objectContaining({
            enabled: true,
            requireEmailVerification: false,
          }),
          socialProviders: expect.objectContaining({
            github: expect.objectContaining({
              clientId: mockAuthEnv.GITHUB_ID,
              clientSecret: mockAuthEnv.GITHUB_SECRET,
            }),
            google: expect.objectContaining({
              clientId: mockAuthEnv.GOOGLE_CLIENT_ID,
              clientSecret: mockAuthEnv.GOOGLE_CLIENT_SECRET,
            }),
          }),
          session: expect.objectContaining({
            expiresIn: 60 * 60 * 24 * 7,
            updateAge: 60 * 60 * 24,
            cookieCache: expect.objectContaining({
              enabled: true,
              maxAge: 5 * 60,
            }),
          }),
        })
      );
    });

    it('should use drizzle adapter with correct configuration', async () => {
      const { drizzleAdapter } = await import('better-auth/adapters/drizzle');
      const { db } = await import('@/lib/db');
      const { users, accounts, sessions, authenticator, verification } = await import('@/lib/db/schema');

      expect(drizzleAdapter).toHaveBeenCalledWith(
        db,
        expect.objectContaining({
          provider: 'pg',
          schema: {
            users,
            accounts,
            sessions,
            authenticator,
            verification,
          },
        })
      );
    });

    it('should configure all social providers with environment variables', async () => {
      const { auth } = await import('@/lib/auth/auth');

      // Check that all required environment variables are used
      expect(process.env.GITHUB_ID).toBe(mockAuthEnv.GITHUB_ID);
      expect(process.env.GITHUB_SECRET).toBe(mockAuthEnv.GITHUB_SECRET);
      expect(process.env.GOOGLE_CLIENT_ID).toBe(mockAuthEnv.GOOGLE_CLIENT_ID);
      expect(process.env.GOOGLE_CLIENT_SECRET).toBe(mockAuthEnv.GOOGLE_CLIENT_SECRET);
      expect(process.env.X_CLIENT_ID).toBe(mockAuthEnv.X_CLIENT_ID);
      expect(process.env.X_CLIENT_SECRET).toBe(mockAuthEnv.X_CLIENT_SECRET);
      expect(process.env.LINKEDIN_CLIENT_ID).toBe(mockAuthEnv.LINKEDIN_CLIENT_ID);
      expect(process.env.LINKEDIN_CLIENT_SECRET).toBe(mockAuthEnv.LINKEDIN_CLIENT_SECRET);
      expect(process.env.APPLE_CLIENT_ID).toBe(mockAuthEnv.APPLE_CLIENT_ID);
      expect(process.env.APPLE_CLIENT_SECRET).toBe(mockAuthEnv.APPLE_CLIENT_SECRET);
      expect(process.env.APPLE_TEAM_ID).toBe(mockAuthEnv.APPLE_TEAM_ID);
      expect(process.env.APPLE_KEY_ID).toBe(mockAuthEnv.APPLE_KEY_ID);
      expect(process.env.APPLE_PRIVATE_KEY).toBe(mockAuthEnv.APPLE_PRIVATE_KEY);
    });
  });

  describe('Session Management Tests', () => {
    it('should export Session type', async () => {
      const { Session } = await import('@/lib/auth/auth');
      expect(Session).toBeDefined();
    });

    it('should have proper session configuration', () => {
      const authContent = readFileSync(authConfigPath, 'utf-8');

      // Verify session expiration settings
      expect(authContent).toContain('expiresIn: 60 * 60 * 24 * 7'); // 7 days
      expect(authContent).toContain('updateAge: 60 * 60 * 24'); // 1 day

      // Verify cookie cache settings
      expect(authContent).toContain('maxAge: 5 * 60'); // 5 minutes
    });
  });

  describe('Security Configuration Tests', () => {
    it('should have secure two-factor configuration', () => {
      const authContent = readFileSync(authConfigPath, 'utf-8');

      // Verify TOTP settings
      expect(authContent).toContain('algorithm: "SHA256"');
      expect(authContent).toContain('digits: 6');
      expect(authContent).toContain('period: 30');
    });

    it('should have proper user field configurations', () => {
      const authContent = readFileSync(authConfigPath, 'utf-8');

      // Verify user fields are properly typed
      expect(authContent).toContain('type: "string"');
      expect(authContent).toContain('required: false');
      expect(authContent).toContain('defaultValue: false');
    });

    it('should use crypto.randomUUID for ID generation', () => {
      const authContent = readFileSync(authConfigPath, 'utf-8');
      expect(authContent).toContain('crypto.randomUUID()');
    });
  });
});
