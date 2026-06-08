import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    // Security: Disable write and exec operations by default when API is exposed to network
    // See: https://github.com/vitest-dev/vitest/security/advisories
    api: {
      allowWrite: false,
      allowExec: false,
    },
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'out/',
        'dist/',
        '__tests__/',
        '*.config.ts',
        '*.config.js',
      ],
    },
  },
});
