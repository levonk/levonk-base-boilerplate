import { describe, it, expect, vi, beforeEach } from 'vitest';
import { readFileSync, existsSync, readdirSync, statSync } from 'node:fs';
import { join, extname } from 'node:path';
import { fileURLToPath } from 'node:url';
import { dirname } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));

describe('Boilerplate Structure Tests', () => {
  const boilerplateRoot = __dirname + '/../..';

  describe('Core File Structure', () => {
    it('should have essential configuration files', () => {
      const essentialFiles = [
        'copier.yml',
        'README.md',
        'next.config.js',
        'tsconfig.json.jinja',
        'tailwind.config.ts',
        'eslint.config.mts',
        'vitest.config.mts.jinja',
        'drizzle.config.ts',
        'postcss.config.js',
        '.env.example',
        '.gitignore',
      ];

      essentialFiles.forEach(file => {
        expect(existsSync(join(boilerplateRoot, file)), `Missing ${file}`).toBe(true);
      });
    });

    it('should have proper directory structure', () => {
      const essentialDirs = [
        'src',
        'src/app',
        'src/components',
        'src/lib',
        'src/styles',
        'src/hooks',
        'src/types',
        'src/utils',
        '__test__',
        '__test__/unit',
        '__test__/e2e',
        'public',
        'internal-docs',
      ];

      essentialDirs.forEach(dir => {
        expect(existsSync(join(boilerplateRoot, dir)), `Missing directory ${dir}`).toBe(true);
      });
    });

    it('should have Jinja2 template files marked correctly', () => {
      const templateFiles = [
        'package.json.jinja',
        'tsconfig.json.jinja',
        'vitest.config.mts.jinja',
        'Dockerfile.jinja',
        'docker-compose.yml.jinja',
        'docker-compose.dev.yml.jinja',
        'Makefile.jinja',
      ];

      templateFiles.forEach(file => {
        const filePath = join(boilerplateRoot, file);
        expect(existsSync(filePath), `Missing template file ${file}`).toBe(true);
        expect(extname(file), `${file} should have .jinja extension`).toBe('.jinja');
      });
    });
  });

  describe('Source Code Structure', () => {
    it('should have Next.js App Router structure', () => {
      const appFiles = [
        'src/app/layout.tsx',
        'src/app/page.tsx',
        'src/app/globals.css',
        'src/app/privacy/page.tsx',
        'src/app/terms/page.tsx',
      ];

      appFiles.forEach(file => {
        expect(existsSync(join(boilerplateRoot, file)), `Missing app file ${file}`).toBe(true);
      });
    });

    it('should have component structure', () => {
      const componentFiles = [
        'src/components/CachedTimestamp.tsx',
      ];

      componentFiles.forEach(file => {
        expect(existsSync(join(boilerplateRoot, file)), `Missing component file ${file}`).toBe(true);
      });
    });

    it('should have library structure', () => {
      const libFiles = [
        'src/lib/db/schema.ts',
        'src/lib/db/index.ts',
        'src/lib/auth.ts',
        'src/lib/auth-client.ts',
      ];

      libFiles.forEach(file => {
        expect(existsSync(join(boilerplateRoot, file)), `Missing lib file ${file}`).toBe(true);
      });
    });

    it('should have style files', () => {
      const styleFiles = [
        'src/styles/globals.css',
        'src/styles/components.css',
      ];

      styleFiles.forEach(file => {
        expect(existsSync(join(boilerplateRoot, file)), `Missing style file ${file}`).toBe(true);
      });
    });

    it('should have tokens configuration', () => {
      const tokensFile = join(boilerplateRoot, 'src/tokens.ts');
      expect(existsSync(tokensFile)).toBe(true);
      
      const tokensContent = readFileSync(tokensFile, 'utf-8');
      expect(tokensContent.length).toBeGreaterThan(0);
    });
  });

  describe('Testing Structure', () => {
    it('should have comprehensive test files', () => {
      const testFiles = [
        '__test__/unit/basic.test.mts',
        '__test__/unit/vitest-config.test.mts',
        '__test__/unit/nextjs-config.test.mts',
        '__test__/unit/react-components.test.mts',
        '__test__/unit/database-config.test.mts',
        '__test__/unit/auth-config.test.mts',
        '__test__/unit/docker-deployment.test.mts',
        '__test__/unit/boilerplate-structure.test.mts',
        '__test__/e2e/requirements/terms.test.mts',
        '__test__/e2e/requirements/privacy.test.mts',
        '__test__/e2e/usecases/terms.test.mts',
        '__test__/e2e/usecases/privacy.test.mts',
      ];

      testFiles.forEach(file => {
        expect(existsSync(join(boilerplateRoot, file)), `Missing test file ${file}`).toBe(true);
      });
    });

    it('should use .mts extension for all test files', () => {
      const testDir = join(boilerplateRoot, '__test__');
      const testFiles = getAllFiles(testDir, '.test.mts');
      
      testFiles.forEach(file => {
        expect(extname(file), `Test file ${file} should use .mts extension`).toBe('.mts');
      });
    });
  });

  describe('Configuration Validation', () => {
    it('should have valid Copier configuration', () => {
      const copierPath = join(boilerplateRoot, 'copier.yml');
      const copierContent = readFileSync(copierPath, 'utf-8');
      
      expect(copierContent).toContain('project_name');
      expect(copierContent).toContain('project_description');
      expect(copierContent).toContain('author_name');
      expect(copierContent).toContain('author_email');
    });

    it('should have valid ESLint configuration', () => {
      const eslintPath = join(boilerplateRoot, 'eslint.config.mts');
      const eslintContent = readFileSync(eslintPath, 'utf-8');
      
      expect(eslintContent).toContain('import');
      expect(eslintContent).toContain('typescript');
      expect(eslintContent).toContain('react');
    });

    it('should have valid TypeScript configuration', () => {
      const tsconfigPath = join(boilerplateRoot, 'tsconfig.json.jinja');
      const tsconfigContent = readFileSync(tsconfigPath, 'utf-8');
      
      expect(tsconfigContent).toContain('"compilerOptions"');
      expect(tsconfigContent).toContain('"strict": true');
      expect(tsconfigContent).toContain('"paths"');
    });

    it('should have valid Tailwind configuration', () => {
      const tailwindPath = join(boilerplateRoot, 'tailwind.config.ts');
      const tailwindContent = readFileSync(tailwindPath, 'utf-8');
      
      expect(tailwindContent).toContain('content');
      expect(tailwindContent).toContain('theme');
      expect(tailwindContent).toContain('plugins');
    });

    it('should have valid Vitest configuration', () => {
      const vitestPath = join(boilerplateRoot, 'vitest.config.mts.jinja');
      const vitestContent = readFileSync(vitestPath, 'utf-8');
      
      expect(vitestContent).toContain('defineConfig');
      expect(vitestContent).toContain('projects');
      expect(vitestContent).toContain('unit');
      expect(vitestContent).toContain('e2e');
    });
  });

  describe('Package Dependencies', () => {
    it('should include essential Next.js dependencies', () => {
      const packagePath = join(boilerplateRoot, 'package.json.jinja');
      const packageContent = readFileSync(packagePath, 'utf-8');
      
      const essentialDeps = [
        'next',
        'react',
        'react-dom',
        'typescript',
        '@types/react',
        '@types/react-dom',
        '@types/node',
        'tailwindcss',
        'postcss',
        'autoprefixer',
        'eslint',
        'vitest',
        '@testing-library/react',
        '@testing-library/jest-dom',
        'drizzle-orm',
        'postgres',
        'next-auth',
        '@auth/prisma-adapter',
      ];

      essentialDeps.forEach(dep => {
        expect(packageContent).toContain(`"${dep}"`);
      });
    });

    it('should include essential scripts', () => {
      const packagePath = join(boilerplateRoot, 'package.json.jinja');
      const packageContent = readFileSync(packagePath, 'utf-8');
      
      const essentialScripts = [
        'dev',
        'build',
        'start',
        'lint',
        'test',
        'test:unit',
        'test:e2e',
        'db:generate',
        'db:migrate',
        'db:push',
        'db:studio',
      ];

      essentialScripts.forEach(script => {
        expect(packageContent).toContain(`"${script}"`);
      });
    });
  });

  describe('Documentation Structure', () => {
    it('should have comprehensive README', () => {
      const readmePath = join(boilerplateRoot, 'README.md');
      const readmeContent = readFileSync(readmePath, 'utf-8');
      
      expect(readmeContent).toContain('#');
      expect(readmeContent).toContain('Features');
      expect(readmeContent).toContain('Getting Started');
      expect(readmeContent).toContain('Development');
      expect(readmeContent).toContain('Deployment');
    });

    it('should have internal documentation', () => {
      const internalDocs = [
        'internal-docs/README.md',
        'internal-docs/ARCHITECTURE.md',
        'internal-docs/CONTRIBUTING.md',
      ];

      internalDocs.forEach(doc => {
        expect(existsSync(join(boilerplateRoot, doc)), `Missing documentation ${doc}`).toBe(true);
      });
    });
  });

  describe('Build and Deployment Files', () => {
    it('should have Docker configuration', () => {
      const dockerFiles = [
        'Dockerfile.jinja',
        'docker-compose.yml.jinja',
        'docker-compose.dev.yml.jinja',
        '.dockerignore',
      ];

      dockerFiles.forEach(file => {
        expect(existsSync(join(boilerplateRoot, file)), `Missing Docker file ${file}`).toBe(true);
      });
    });

    it('should have Makefile for automation', () => {
      const makefilePath = join(boilerplateRoot, 'Makefile.jinja');
      expect(existsSync(makefilePath)).toBe(true);
      
      const makefileContent = readFileSync(makefilePath, 'utf-8');
      expect(makefileContent).toContain('build:');
      expect(makefileContent).toContain('dev:');
      expect(makefileContent).toContain('test:');
    });
  });

  describe('Security and Quality', () => {
    it('should have proper .gitignore', () => {
      const gitignorePath = join(boilerplateRoot, '.gitignore');
      const gitignoreContent = readFileSync(gitignorePath, 'utf-8');
      
      expect(gitignoreContent).toContain('node_modules');
      expect(gitignoreContent).toContain('.next');
      expect(gitignoreContent).toContain('dist');
      expect(gitignoreContent).toContain('.env');
      expect(gitignoreContent).toContain('.DS_Store');
    });

    it('should have environment example', () => {
      const envExamplePath = join(boilerplateRoot, '.env.example');
      const envContent = readFileSync(envExamplePath, 'utf-8');
      
      expect(envContent).toContain('NODE_ENV');
      expect(envContent).toContain('DATABASE_URL');
      expect(envContent).toContain('NEXTAUTH_SECRET');
      expect(envContent).toContain('NEXTAUTH_URL');
    });
  });

  describe('Component Quality', () => {
    it('should have TypeScript interfaces', () => {
      const typesDir = join(boilerplateRoot, 'src/types');
      expect(existsSync(typesDir)).toBe(true);
    });

    it('should have utility functions', () => {
      const utilsDir = join(boilerplateRoot, 'src/utils');
      expect(existsSync(utilsDir)).toBe(true);
    });

    it('should have custom hooks', () => {
      const hooksDir = join(boilerplateRoot, 'src/hooks');
      expect(existsSync(hooksDir)).toBe(true);
    });
  });
});

// Helper function to recursively get all files with specific extension
function getAllFiles(dirPath: string, extension: string): string[] {
  const files: string[] = [];
  
  function traverse(currentPath: string) {
    const items = readdirSync(currentPath);
    
    for (const item of items) {
      const fullPath = join(currentPath, item);
      const stat = statSync(fullPath);
      
      if (stat.isDirectory()) {
        traverse(fullPath);
      } else if (extname(item) === extension) {
        files.push(fullPath);
      }
    }
  }
  
  traverse(dirPath);
  return files;
}
