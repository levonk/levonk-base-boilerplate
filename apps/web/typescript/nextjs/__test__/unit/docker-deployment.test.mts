import { describe, it, expect, vi, beforeEach } from 'vitest';
import { readFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import { dirname } from 'node:path';

const __dirname = dirname(fileURLToPath(import.meta.url));

// Mock Docker-related modules
vi.mock('node:child_process', () => ({
  execSync: vi.fn(),
  spawn: vi.fn(),
}));

describe('Docker Deployment Tests', () => {
  const dockerfilePath = join(__dirname, '../../Dockerfile.jinja');
  const dockerComposePath = join(__dirname, '../../docker-compose.yml.jinja');
  const dockerComposeDevPath = join(__dirname, '../../docker-compose.dev.yml.jinja');

  describe('Dockerfile Configuration', () => {
    it('should have Dockerfile template', () => {
      expect(existsSync(dockerfilePath)).toBe(true);
    });

    it('should use Node.js base image', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toContain('FROM node:');
      expect(dockerfileContent).toContain('alpine');
    });

    it('should set working directory', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toContain('WORKDIR /app');
    });

    it('should copy package files first', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toContain('COPY package*.json ./');
      expect(dockerfileContent).toContain('RUN npm ci');
    });

    it('should copy application source code', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toContain('COPY . .');
    });

    it('should build the application', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toContain('RUN npm run build');
    });

    it('should expose port 3000', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toContain('EXPOSE 3000');
    });

    it('should set correct user', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toContain('USER node');
    });

    it('should set the start command', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toContain('CMD ["npm", "start"]');
    });

    it('should use multi-stage build for optimization', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toContain('AS base');
      expect(dockerfileContent).toContain('AS builder');
      expect(dockerfileContent).toContain('AS runner');
    });
  });

  describe('Docker Compose Configuration', () => {
    it('should have production docker-compose file', () => {
      expect(existsSync(dockerComposePath)).toBe(true);
    });

    it('should have development docker-compose file', () => {
      expect(existsSync(dockerComposeDevPath)).toBe(true);
    });

    it('should configure web service', () => {
      const composeContent = readFileSync(dockerComposePath, 'utf-8');
      expect(composeContent).toContain('services:');
      expect(composeContent).toContain('web:');
    });

    it('should use build context', () => {
      const composeContent = readFileSync(dockerComposePath, 'utf-8');
      expect(composeContent).toContain('build:');
      expect(composeContent).toContain('context: .');
    });

    it('should map ports correctly', () => {
      const composeContent = readFileSync(dockerComposePath, 'utf-8');
      expect(composeContent).toContain('ports:');
      expect(composeContent).toContain('"3000:3000"');
    });

    it('should configure environment variables', () => {
      const composeContent = readFileSync(dockerComposePath, 'utf-8');
      expect(composeContent).toContain('environment:');
      expect(composeContent).toContain('NODE_ENV: production');
    });

    it('should include health check', () => {
      const composeContent = readFileSync(dockerComposePath, 'utf-8');
      expect(composeContent).toContain('healthcheck:');
      expect(composeContent).toContain('test: ["CMD", "curl", "-f", "http://localhost:3000"]');
    });
  });

  describe('Development Docker Compose', () => {
    it('should configure development environment', () => {
      const devComposeContent = readFileSync(dockerComposeDevPath, 'utf-8');
      expect(devComposeContent).toContain('NODE_ENV: development');
    });

    it('should enable hot reload', () => {
      const devComposeContent = readFileSync(dockerComposeDevPath, 'utf-8');
      expect(devComposeContent).toContain('volumes:');
      expect(devComposeContent).toContain('./src:/app/src');
      expect(devComposeContent).toContain('./public:/app/public');
    });

    it('should map development ports', () => {
      const devComposeContent = readFileSync(dockerComposeDevPath, 'utf-8');
      expect(devComposeContent).toContain('"3000:3000"');
    });

    it('should include development services', () => {
      const devComposeContent = readFileSync(dockerComposeDevPath, 'utf-8');
      expect(devComposeContent).toContain('services:');
    });
  });

  describe('Docker Ignore Configuration', () => {
    const dockerignorePath = join(__dirname, '../../.dockerignore');

    it('should have .dockerignore file', () => {
      expect(existsSync(dockerignorePath)).toBe(true);
    });

    it('should exclude node_modules', () => {
      const dockerignoreContent = readFileSync(dockerignorePath, 'utf-8');
      expect(dockerignoreContent).toContain('node_modules');
    });

    it('should exclude build artifacts', () => {
      const dockerignoreContent = readFileSync(dockerignorePath, 'utf-8');
      expect(dockerignoreContent).toContain('.next');
      expect(dockerignoreContent).toContain('dist');
    });

    it('should exclude development files', () => {
      const dockerignoreContent = readFileSync(dockerignorePath, 'utf-8');
      expect(dockerignoreContent).toContain('.git');
      expect(dockerignoreContent).toContain('README.md');
      expect(dockerignoreContent).toContain('Dockerfile*');
      expect(dockerignoreContent).toContain('docker-compose*');
    });
  });

  describe('Container Security', () => {
    it('should use non-root user', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toContain('USER node');
    });

    it('should set appropriate file permissions', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toContain('COPY --chown=node:node');
    });

    it('should use specific Node.js version', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toMatch(/FROM node:\d+\.\d+\.\d+-alpine/);
    });
  });

  describe('Container Optimization', () => {
    it('should use multi-stage builds', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toContain('AS builder');
      expect(dockerfileContent).toContain('AS runner');
    });

    it('should clean up build artifacts', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toContain('npm ci --only=production');
    });

    it('should use appropriate base images for stages', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toContain('node:alpine');
    });
  });

  describe('Environment Variables', () => {
    it('should configure production environment', () => {
      const composeContent = readFileSync(dockerComposePath, 'utf-8');
      expect(composeContent).toContain('NODE_ENV: production');
    });

    it('should include port configuration', () => {
      const composeContent = readFileSync(dockerComposePath, 'utf-8');
      expect(composeContent).toContain('PORT: 3000');
    });

    it('should support database URL', () => {
      const composeContent = readFileSync(dockerComposePath, 'utf-8');
      expect(composeContent).toContain('DATABASE_URL');
    });
  });

  describe('Development Features', () => {
    it('should support live reloading', () => {
      const devComposeContent = readFileSync(dockerComposeDevPath, 'utf-8');
      expect(devComposeContent).toContain('volumes:');
    });

    it('should include development dependencies', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toContain('RUN npm ci');
    });

    it('should configure development ports', () => {
      const devComposeContent = readFileSync(dockerComposeDevPath, 'utf-8');
      expect(devComposeContent).toContain('ports:');
    });
  });

  describe('Build Process', () => {
    it('should handle TypeScript compilation', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toContain('RUN npm run build');
    });

    it('should optimize for production', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toContain('npm ci --only=production');
    });

    it('should set appropriate environment', () => {
      const dockerfileContent = readFileSync(dockerfilePath, 'utf-8');
      expect(dockerfileContent).toContain('ENV NODE_ENV=production');
    });
  });

  describe('Container Health', () => {
    it('should include health checks', () => {
      const composeContent = readFileSync(dockerComposePath, 'utf-8');
      expect(composeContent).toContain('healthcheck:');
    });

    it('should configure health check intervals', () => {
      const composeContent = readFileSync(dockerComposePath, 'utf-8');
      expect(composeContent).toContain('interval:');
      expect(composeContent).toContain('timeout:');
    });

    it('should have appropriate health check endpoints', () => {
      const composeContent = readFileSync(dockerComposePath, 'utf-8');
      expect(composeContent).toContain('http://localhost:3000');
    });
  });

  describe('Docker Scripts', () => {
    const makefilePath = join(__dirname, '../../Makefile.jinja');

    it('should have Docker-related Makefile', () => {
      expect(existsSync(makefilePath)).toBe(true);
    });

    it('should include build target', () => {
      const makefileContent = readFileSync(makefilePath, 'utf-8');
      expect(makefileContent).toContain('build:');
      expect(makefileContent).toContain('docker build');
    });

    it('should include run target', () => {
      const makefileContent = readFileSync(makefilePath, 'utf-8');
      expect(makefileContent).toContain('run:');
      expect(makefileContent).toContain('docker-compose up');
    });

    it('should include clean target', () => {
      const makefileContent = readFileSync(makefilePath, 'utf-8');
      expect(makefileContent).toContain('clean:');
      expect(makefileContent).toContain('docker-compose down');
    });
  });
});
