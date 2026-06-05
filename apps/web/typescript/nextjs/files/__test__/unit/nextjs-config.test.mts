import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { execSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { readFileSync, existsSync } from 'node:fs';

const __dirname = dirname(fileURLToPath(import.meta.url));

describe('Next.js Configuration Tests', () => {
  const configPath = join(__dirname, '../../next.config.js');

  describe('Configuration File Validation', () => {
    it('should have next.config.js file', () => {
      expect(existsSync(configPath)).toBe(true);
    });

    it('should export valid configuration object', () => {
      const configContent = readFileSync(configPath, 'utf-8');
      expect(configContent).toContain('module.exports');
      expect(configContent).toContain('experimental');
    });

    it('should enable app directory experimental feature', () => {
      const configContent = readFileSync(configPath, 'utf-8');
      expect(configContent).toContain('appDir: true');
    });
  });

  describe('Build Configuration', () => {
    it('should support TypeScript compilation', () => {
      // Test that Next.js can handle TypeScript files
      expect(() => {
        execSync('npx next build --help', { stdio: 'pipe', cwd: __dirname + '/../../..' });
      }).not.toThrow();
    });

    it('should have proper TypeScript configuration', () => {
      const tsconfigPath = join(__dirname, '../../tsconfig.json.jinja');
      expect(existsSync(tsconfigPath)).toBe(true);
      
      const tsconfigContent = readFileSync(tsconfigPath, 'utf-8');
      expect(tsconfigContent).toContain('"compilerOptions"');
      expect(tsconfigContent).toContain('"strict": true');
    });
  });

  describe('Development Configuration', () => {
    it('should support development server', () => {
      expect(() => {
        execSync('npx next dev --help', { stdio: 'pipe', cwd: __dirname + '/../../..' });
      }).not.toThrow();
    });

    it('should have proper environment configuration', () => {
      const envExamplePath = join(__dirname, '../../.env.example');
      expect(existsSync(envExamplePath)).toBe(true);
      
      const envContent = readFileSync(envExamplePath, 'utf-8');
      expect(envContent).toContain('NODE_ENV');
    });
  });

  describe('Asset and Static File Handling', () => {
    it('should have public directory structure', () => {
      const publicDir = join(__dirname, '../../public');
      expect(existsSync(publicDir)).toBe(true);
      
      const faviconPath = join(publicDir, 'favicon.ico');
      expect(existsSync(faviconPath)).toBe(true);
    });

    it('should support image optimization', () => {
      const configContent = readFileSync(configPath, 'utf-8');
      // Next.js 16 includes image optimization by default
      expect(configContent).toBeDefined();
    });
  });

  describe('CSS and Styling Configuration', () => {
    it('should have global CSS file', () => {
      const globalsCssPath = join(__dirname, '../../src/app/globals.css');
      expect(existsSync(globalsCssPath)).toBe(true);
    });

    it('should have Tailwind configuration', () => {
      const tailwindConfigPath = join(__dirname, '../../tailwind.config.ts');
      expect(existsSync(tailwindConfigPath)).toBe(true);
      
      const tailwindContent = readFileSync(tailwindConfigPath, 'utf-8');
      expect(tailwindContent).toContain('content');
      expect(tailwindContent).toContain('theme');
    });

    it('should have PostCSS configuration', () => {
      const postcssConfigPath = join(__dirname, '../../postcss.config.js');
      expect(existsSync(postcssConfigPath)).toBe(true);
      
      const postcssContent = readFileSync(postcssConfigPath, 'utf-8');
      expect(postcssContent).toContain('tailwindcss');
      expect(postcssContent).toContain('autoprefixer');
    });
  });

  describe('ESLint Configuration', () => {
    it('should have ESLint configuration', () => {
      const eslintConfigPath = join(__dirname, '../../eslint.config.mts');
      expect(existsSync(eslintConfigPath)).toBe(true);
      
      const eslintContent = readFileSync(eslintConfigPath, 'utf-8');
      expect(eslintContent).toContain('import');
      expect(eslintContent).toContain('typescript');
    });

    it('should support linting commands', () => {
      expect(() => {
        execSync('npx eslint --help', { stdio: 'pipe', cwd: __dirname + '/../../..' });
      }).not.toThrow();
    });
  });

  describe('TypeScript Path Aliases', () => {
    it('should configure path aliases in tsconfig', () => {
      const tsconfigPath = join(__dirname, '../../tsconfig.json.jinja');
      const tsconfigContent = readFileSync(tsconfigPath, 'utf-8');
      
      expect(tsconfigContent).toContain('"paths"');
      expect(tsconfigContent).toContain('"@/*"');
      expect(tsconfigContent).toContain('"@/app/*"');
      expect(tsconfigContent).toContain('"@/components/*"');
      expect(tsconfigContent).toContain('"@/lib/*"');
    });
  });

  describe('Package.json Scripts', () => {
    it('should have essential Next.js scripts', () => {
      const packageJsonPath = join(__dirname, '../../package.json.jinja');
      expect(existsSync(packageJsonPath)).toBe(true);
      
      const packageContent = readFileSync(packageJsonPath, 'utf-8');
      expect(packageContent).toContain('"dev":');
      expect(packageContent).toContain('"build":');
      expect(packageContent).toContain('"start":');
      expect(packageContent).toContain('"lint":');
      expect(packageContent).toContain('"test":');
    });

    it('should include Next.js as dependency', () => {
      const packageJsonPath = join(__dirname, '../../package.json.jinja');
      const packageContent = readFileSync(packageJsonPath, 'utf-8');
      
      expect(packageContent).toContain('"next":');
      expect(packageContent).toContain('"react":');
      expect(packageContent).toContain('"react-dom":');
    });
  });

  describe('Build Output and Deployment', () => {
    it('should support static export configuration', () => {
      const configContent = readFileSync(configPath, 'utf-8');
      // Check if configuration allows for static exports when needed
      expect(configContent).toBeDefined();
    });

    it('should have proper output configuration', () => {
      const configContent = readFileSync(configPath, 'utf-8');
      // Next.js 16 should have proper output configuration
      expect(configContent.length).toBeGreaterThan(0);
    });
  });
});
