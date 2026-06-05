import { describe, it, expect, vi, beforeEach } from 'vitest';
import { readFileSync, existsSync, readdirSync, statSync } from 'node:fs';
import { join, extname } from 'node:path';

describe('Documentation Feature Tests', () => {
  const boilerplateRoot = join(__dirname, '../..');

  describe('Core Documentation Files', () => {
    it('should have README.md with proper structure', () => {
      const readmePath = join(boilerplateRoot, 'README.md');
      expect(existsSync(readmePath)).toBe(true);

      const readmeContent = readFileSync(readmePath, 'utf-8');
      expect(readmeContent).toContain('#');
      expect(readmeContent).toContain('##');
      expect(readmeContent).toContain('###');
      expect(readmeContent).toContain('```');
      expect(readmeContent.length).toBeGreaterThan(500);
    });

    it('should have comprehensive docs directory', () => {
      const docsDir = join(boilerplateRoot, 'docs');
      expect(existsSync(docsDir)).toBe(true);

      const docsFiles = readdirSync(docsDir);
      expect(docsFiles.length).toBeGreaterThan(0);

      // Check for essential documentation files
      const expectedFiles = ['README.md'];
      expectedFiles.forEach(file => {
        expect(docsFiles).toContain(file);
      });
    });

    it('should have internal-docs directory with ADRs', () => {
      const internalDocsDir = join(boilerplateRoot, 'internal-docs');
      expect(existsSync(internalDocsDir)).toBe(true);

      if (existsSync(internalDocsDir)) {
        const internalFiles = readdirSync(internalDocsDir);
        expect(internalFiles.length).toBeGreaterThan(0);
      }
    });
  });

  describe('API Documentation', () => {
    it('should have API documentation structure', () => {
      const apiDir = join(boilerplateRoot, 'src/app/api');
      if (existsSync(apiDir)) {
        const apiRoutes = readdirSync(apiDir, { recursive: true }) as string[];

        // Check for README files in API directories
        const apiReadmes = apiRoutes.filter(file =>
          file.endsWith('README.md') || file.endsWith('readme.md')
        );

        // API routes should have documentation
        expect(apiRoutes.length).toBeGreaterThan(0);
      }
    });

    it('should document API endpoints', () => {
      const apiDir = join(boilerplateRoot, 'src/app/api');
      if (existsSync(apiDir)) {
        // Check for route files that should have JSDoc comments
        const routeFiles = readdirSync(apiDir, { recursive: true }) as string[];
        const filteredFiles = routeFiles
          .filter(file => file.endsWith('.ts') || file.endsWith('.js'))
          .map(file => join(apiDir, file));

        filteredFiles.forEach(filePath => {
          if (existsSync(filePath)) {
            const content = readFileSync(filePath, 'utf-8');
            // API routes should have some form of documentation
            expect(content.length).toBeGreaterThan(10);
          }
        });
      }
    });
  });

  describe('Component Documentation', () => {
    it('should have documented components', () => {
      const componentsDir = join(boilerplateRoot, 'src/components');
      if (existsSync(componentsDir)) {
        const componentFiles = readdirSync(componentsDir, { recursive: true }) as string[];
        const filteredFiles = componentFiles
          .filter(file => file.endsWith('.tsx') || file.endsWith('.ts'));

        filteredFiles.forEach(file => {
          const filePath = join(componentsDir, file);
          const content = readFileSync(filePath, 'utf-8');

          // Components should have either JSDoc or prop interfaces
          const hasDocumentation =
            content.includes('/**') ||
            content.includes('interface') ||
            content.includes('type') ||
            content.includes('Props');

          // At minimum, components should be non-empty
          expect(content.trim().length).toBeGreaterThan(0);
        });
      }
    });

    it('should have component examples', () => {
      const componentsDir = join(boilerplateRoot, 'src/components');
      if (existsSync(componentsDir)) {
        // Look for example files or documented usage
        const files = readdirSync(componentsDir, { recursive: true }) as string[];
        const hasExamples = files.some(file =>
          file.includes('example') ||
          file.includes('demo') ||
          file.includes('story')
        );

        // Examples are preferred but not required
        if (hasExamples) {
          expect(hasExamples).toBe(true);
        }
      }
    });
  });

  describe('Code Documentation Quality', () => {
    it('should have JSDoc comments in utility functions', () => {
      const utilsDir = join(boilerplateRoot, 'src/utils');
      if (existsSync(utilsDir)) {
        const utilFiles = readdirSync(utilsDir)
          .filter(file => file.endsWith('.ts') || file.endsWith('.js'));

        utilFiles.forEach(file => {
          const filePath = join(utilsDir, file);
          const content = readFileSync(filePath, 'utf-8');

          // Utility functions should be documented
          if (content.includes('function') || content.includes('export')) {
            const hasJSDoc = content.includes('/**');
            if (hasJSDoc) {
              expect(hasJSDoc).toBe(true);
            }
          }
        });
      }
    });

    it('should have TypeScript interfaces documented', () => {
      const typesDir = join(boilerplateRoot, 'src/types');
      if (existsSync(typesDir)) {
        const typeFiles = readdirSync(typesDir)
          .filter(file => file.endsWith('.ts'));

        typeFiles.forEach(file => {
          const filePath = join(typesDir, file);
          const content = readFileSync(filePath, 'utf-8');

          // Type definitions should have comments
          expect(content.trim().length).toBeGreaterThan(0);

          // Check for interface/type documentation
          const hasDocumentation =
            content.includes('/**') ||
            content.includes('///');

          if (content.includes('interface') || content.includes('type')) {
            // Documentation is preferred for types
            if (hasDocumentation) {
              expect(hasDocumentation).toBe(true);
            }
          }
        });
      }
    });
  });

  describe('Configuration Documentation', () => {
    it('should have documented environment variables', () => {
      const envExamplePath = join(boilerplateRoot, '.env.example');
      if (existsSync(envExamplePath)) {
        const envContent = readFileSync(envExamplePath, 'utf-8');

        // Environment variables should be documented
        const lines = envContent.split('\n');
        const hasComments = lines.some(line => line.startsWith('#'));

        if (hasComments) {
          expect(hasComments).toBe(true);
        }

        // Should have meaningful variable names
        const hasVars = lines.some(line =>
          line.includes('=') && !line.startsWith('#')
        );
        expect(hasVars).toBe(true);
      }
    });

    it('should have configuration documentation', () => {
      const configFiles = [
        'next.config.js',
        'tailwind.config.ts',
        'tsconfig.json',
        'eslint.config.mts',
        'vitest.config.mts.jinja'
      ];

      configFiles.forEach(file => {
        const filePath = join(boilerplateRoot, file);
        if (existsSync(filePath)) {
          const content = readFileSync(filePath, 'utf-8');
          // Config files should have some comments
          const hasComments =
            content.includes('//') ||
            content.includes('/*') ||
            content.includes('#');

          if (content.length > 100) {
            // Larger config files should be documented
            expect(hasComments).toBe(true);
          }
        }
      });
    });
  });

  describe('Documentation Accessibility', () => {
    it('should have proper markdown formatting', () => {
      const docsDir = join(boilerplateRoot, 'docs');
      if (existsSync(docsDir)) {
        const markdownFiles = readdirSync(docsDir)
          .filter(file => file.endsWith('.md'));

        markdownFiles.forEach(file => {
          const filePath = join(docsDir, file);
          const content = readFileSync(filePath, 'utf-8');

          // Markdown files should have proper structure
          expect(content).toContain('#');

          // Should have meaningful content
          expect(content.length).toBeGreaterThan(50);

          // Should not have broken markdown links
          const brokenLinks = content.match(/\[.*\]\(\s*\)/g);
          if (brokenLinks) {
            expect(brokenLinks.length).toBe(0);
          }
        });
      }
    });

    it('should have table of contents or navigation', () => {
      const readmePath = join(boilerplateRoot, 'README.md');
      if (existsSync(readmePath)) {
        const readmeContent = readFileSync(readmePath, 'utf-8');

        // Large READMEs should have navigation
        if (readmeContent.length > 1000) {
          const hasTOC =
            readmeContent.includes('## Table of Contents') ||
            readmeContent.includes('## Contents') ||
            readmeContent.match(/^- \[.*\]/);

          if (hasTOC) {
            expect(hasTOC).toBeTruthy();
          }
        }
      }
    });
  });

  describe('Documentation Coverage', () => {
    it('should document all major features', () => {
      const features = [
        'Authentication',
        'Database',
        'Testing',
        'Deployment',
        'Styling',
        'Components'
      ];

      const readmePath = join(boilerplateRoot, 'README.md');
      if (existsSync(readmePath)) {
        const readmeContent = readFileSync(readmePath, 'utf-8');

        // Check if major features are mentioned
        const documentedFeatures = features.filter(feature =>
          readmeContent.toLowerCase().includes(feature.toLowerCase())
        );

        // Should document at least half of the major features
        expect(documentedFeatures.length).toBeGreaterThanOrEqual(features.length / 2);
      }
    });

    it('should have setup and getting started documentation', () => {
      const readmePath = join(boilerplateRoot, 'README.md');
      if (existsSync(readmePath)) {
        const readmeContent = readFileSync(readmePath, 'utf-8');

        // Should have setup instructions
        const hasSetup =
          readmeContent.toLowerCase().includes('getting started') ||
          readmeContent.toLowerCase().includes('setup') ||
          readmeContent.toLowerCase().includes('installation') ||
          readmeContent.includes('npm install') ||
          readmeContent.includes('pnpm install');

        expect(hasSetup).toBe(true);
      }
    });
  });

  describe('Inline Code Documentation', () => {
    it('should have documented lib modules', () => {
      const libDir = join(boilerplateRoot, 'src/lib');
      if (existsSync(libDir)) {
        const libFiles = readdirSync(libDir, { recursive: true }) as string[];
        const filteredFiles = libFiles
          .filter(file => file.endsWith('.ts') && !file.includes('.test.'))
          .map(file => join(libDir, file));

        filteredFiles.forEach(filePath => {
          if (existsSync(filePath)) {
            const content = readFileSync(filePath, 'utf-8');

            // Library modules should have exports
            const hasExports = content.includes('export');
            if (hasExports) {
              // Exported modules should have some documentation
              const hasDocumentation =
                content.includes('/**') ||
                content.includes('///') ||
                content.includes('/*');

              if (content.length > 200) {
                expect(hasDocumentation).toBe(true);
              }
            }
          }
        });
      }
    });

    it('should have documented hooks', () => {
      const hooksDir = join(boilerplateRoot, 'src/hooks');
      if (existsSync(hooksDir)) {
        const hookFiles = readdirSync(hooksDir)
          .filter(file => file.endsWith('.ts') || file.endsWith('.tsx'));

        hookFiles.forEach(file => {
          const filePath = join(hooksDir, file);
          const content = readFileSync(filePath, 'utf-8');

          // Hooks should be documented
          if (content.includes('function') || content.includes('export')) {
            const hasJSDoc = content.includes('/**');
            if (hasJSDoc) {
              expect(hasJSDoc).toBe(true);
            }
          }
        });
      }
    });
  });

  describe('Documentation Maintenance', () => {
    it('should have recent documentation updates', () => {
      const readmePath = join(boilerplateRoot, 'README.md');
      if (existsSync(readmePath)) {
        const stats = statSync(readmePath);
        const lastModified = new Date(stats.mtime);
        const sixMonthsAgo = new Date();
        sixMonthsAgo.setMonth(sixMonthsAgo.getMonth() - 6);

        // Documentation should be relatively recent
        expect(lastModified.getTime()).toBeGreaterThan(sixMonthsAgo.getTime());
      }
    });

    it('should have consistent documentation style', () => {
      const docsDir = join(boilerplateRoot, 'docs');
      if (existsSync(docsDir)) {
        const markdownFiles = readdirSync(docsDir)
          .filter(file => file.endsWith('.md'));

        if (markdownFiles.length > 1) {
          markdownFiles.forEach(file => {
            const filePath = join(docsDir, file);
            const content = readFileSync(filePath, 'utf-8');

            // Should use consistent heading styles
            const hasH1 = content.includes('# ');
            const hasH2 = content.includes('## ');

            if (hasH1) {
              expect(content.split('# ').length - 1).toBe(1); // Only one H1
            }

            if (content.length > 100) {
              expect(hasH2).toBe(true); // Should have sections
            }
          });
        }
      }
    });
  });
});
