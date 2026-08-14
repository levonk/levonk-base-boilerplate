# Node.js/TypeScript Project Changes

This document outlines all changes made by the project-adopter skill specifically for Node.js and TypeScript projects.

## Detection Patterns

Projects are detected as Node.js/TypeScript when they contain:
- `package.json` (npm/pnpm/yarn/bun projects)
- `tsconfig.json` (TypeScript projects)
- `yarn.lock`, `pnpm-lock.yaml`, `package-lock.json`

## Files Created

### Core Files
- **devbox.json** - Environment with Node.js packages
- **justfile** - Node.js-specific targets and commands
- **README.md** - Node.js development setup guide
- **AGENTS.md** - Node.js AI agent configuration
- **.envrc** - Node.js environment configuration

## devbox.json Changes

### Adopt Mode Packages
```json
{
  "packages": [
    "just", "yq-go", "jq", "ripgrep", "fd", "bat",
    "nodejs_22", "pnpm", "typescript", "eslint", "prettier", "jest"
  ]
}
```

### Standardize Mode Packages
```json
{
  "packages": [
    "just", "yq-go", "jq", "ripgrep", "fd", "bat",
    "nodejs_22", "pnpm", "typescript", "eslint", "prettier", "jest",
    "playwright", "tailwindcss", "postcss", "vite", "webpack", "rollup", "esbuild"
  ]
}
```

### Scripts Added
```json
{
  "scripts": {
    "bootstrap": "just bootstrap_impl",
    "build": "just build_impl",
    "test": "just test_impl",
    "dev": "just dev_impl",
    "lint": "just lint_impl",
    "typecheck": "just typecheck_impl",
    "clean": "just clean_impl"
  }
}
```

## justfile Changes

### Standard Interface Targets
```just
# Standard interface (uses devbox)
dev:
    devbox shell dev

build:
    devbox shell build

test:
    devbox shell test

lint:
    devbox shell lint

typecheck:
    devbox shell typecheck

clean:
    devbox shell clean
```

### Language-Specific *_impl Targets
```just
# Node.js-specific implementations
dev_impl:
    pnpm run dev

build_impl:
    pnpm run build

test_impl:
    pnpm run test

lint_impl:
    pnpm run lint

typecheck_impl:
    pnpm run typecheck

clean_impl:
    rm -rf dist/ node_modules/.cache/

bootstrap_impl:
    pnpm install
    echo "Node.js development environment ready!"
```

### Additional Targets
```just
# Development loop
loop: || (bootstrap build test dev)

# CI pipeline
ci: || (bootstrap lint typecheck test build)

# Package management
install:
    pnpm install

update:
    pnpm update

audit:
    pnpm audit
```

## package.json Surgical Changes

### Development Scripts Added

| Script | Source of Truth | Command | Purpose |
|--------|------------------|---------|---------|
| **bootstrap** | `apply_surgical_configs()` - Node.js scripts section | `just bootstrap_impl` | Bootstrap the project |
| **build** | `apply_surgical_configs()` - Node.js scripts section | `just build_impl` | Build the project |
| **test** | `apply_surgical_configs()` - Node.js scripts section | `just test_impl` | Run tests |
| **dev** | `apply_surgical_configs()` - Node.js scripts section | `just dev_impl` | Start development server |
| **lint** | `apply_surgical_configs()` - Node.js scripts section | `just lint_impl` | Run linting |
| **typecheck** | `apply_surgical_configs()` - Node.js scripts section | `just typecheck_impl` | Run type checking |
| **clean** | `apply_surgical_configs()` - Node.js scripts section | `just clean_impl` | Clean build artifacts |
| **loop** | `apply_surgical_configs()` - Node.js scripts section | `just loop` | Development loop |
| **ci** | `apply_surgical_configs()` - Node.js scripts section | `just ci` | CI pipeline |

### Monorepo Support (Nx/Turborepo)

#### Nx Changes (Preferred per ADR 20260419001)
| File | Source of Truth | Changes Made |
|------|------------------|------------|
| **nx.json** | `apply_surgical_configs()` - monorepo section | Create Nx workspace configuration |
| **package.json** (root) | `apply_surgical_configs()` - monorepo section | Add Nx dependencies and scripts |
| **project.json** (workspace) | `apply_surgical_configs()` - monorepo section | Add Nx project configuration |

#### Turborepo Changes (Legacy - Superseded by Nx)
| File | Source of Truth | Changes Made |
|------|------------------|------------|
| **package.json** (root) | `apply_surgical_configs()` - monorepo section | Add Turborepo configuration |
| **turbo.json** | `apply_surgical_configs()` - monorepo section | Create Turborepo configuration |
| **package.json** (workspace) | `apply_surgical_configs()` - monorepo section | Add workspace scripts |

### Root package.json additions (Based on Boilerplate):
```json
{
  "scripts": {
    "preinstall": "pnpm dlx only-allow pnpm",
    "dev": "next dev --turbopack",
    "watchmode": "node --watch-path=. --watch-extensions=ts,tsx,js,jsx,json --eval 'console.log(\"Node watchmode active. Monitoring for changes...\")'",
    "build": "next build",
    "optimize-images": "node scripts/optimize-images.ts",
    "yakbak:record": "node scripts/yakbak-proxy.mjs",
    "yakbak:replay": "YAKBAK_NO_RECORD=1 node scripts/yakbak-proxy.mjs",
    "start": "next start",
    "export": "next build && next export",
    "lint": "eslint .",
    "lint:fix": "eslint . --fix",
    "clean": "rm -rf dist .next",
    "clean:hard": "rm -rf dist .next node_modules",
    "test": "vitest run",
    "test:performance": "vitest run --project performance",
    "test:integration": "vitest run --project integration",
    "test:e2e:requirements": "vitest run --project e2e-requirements",
    "test:e2e:usecases": "vitest run --project e2e-usecases",
    "test:coverage": "vitest run --coverage",
    "test:watch": "vitest",
    "typecheck": "tsc --noEmit",
    "db:setup": "pnpm exec tsx lib/db/setup.ts",
    "db:seed": "pnpm exec tsx lib/db/seed.ts",
    "db:generate": "drizzle-kit generate",
    "db:migrate": "drizzle-kit migrate",
    "db:studio": "drizzle-kit studio",
    "bootstrap": "just bootstrap_impl",
    "build": "just build_impl",
    "test": "just test_impl",
    "dev": "just dev_impl",
    "lint": "just lint_impl",
    "typecheck": "just typecheck_impl",
    "clean": "just clean_impl",
    "loop": "just loop",
    "ci": "just ci",
    "nx": "nx",
    "build:packages": "nx run-many --target=build",
    "test:packages": "nx run-many --target=test",
    "lint:packages": "nx run-many --target=lint",
    "dev:packages": "nx run-many --target=dev",
    "clean": "nx run-many --target=clean"
  },
  "workspaces": [
    "packages/*",
    "apps/*"
  ],
  "devDependencies": {
    "@nx/js": "^19.0.0",
    "@nx/workspace": "^19.0.0",
    "nx": "^19.0.0"
  }
}
```

**nx.json configuration (Preferred):**
```json
{
  "$schema": "https://nx.dev/schemas/nx-schema.json",
  "namedInputs": {
    "default": ["{projectRoot}/**/*"],
    "production": [
      "{projectRoot}/**/*.ts",
      "{projectRoot}/**/*.tsx",
      "{projectRoot}/**/*.js",
      "{projectRoot}/**/*.jsx"
    ]
  },
  "targetDefaults": {
    "build": {
      "cache": true,
      "dependsOn": ["^build"],
      "inputs": ["production", "^production"]
    },
    "test": {
      "cache": true,
      "inputs": ["default", "^production"]
    },
    "lint": {
      "cache": true,
      "inputs": ["default"]
    }
  }
}
```

### Workspace package.json additions (for monorepo packages):
```json
{
  "scripts": {
    "bootstrap": "just bootstrap_impl",
    "build": "just build_impl",
    "test": "just test_impl",
    "dev": "just dev_impl",
    "lint": "just lint_impl",
    "typecheck": "just typecheck_impl",
    "clean": "just clean_impl",
    "loop": "just loop",
    "ci": "just ci",
    "nx": "nx",
    "build:all": "nx run build --all",
    "test:all": "nx run test --all",
    "lint:all": "nx run lint --all",
    "graph": "nx graph",
    "affected": "nx affected"
  },
  "devDependencies": {
    "@nx/workspace": "^16.0.0",
    "@nx/vite": "^16.0.0",
    "@nx/eslint-plugin": "^16.0.0"
  }
}
```

**nx.json configuration:**
```json
{
  "$schema": "./node_modules/nx/schemas/nx-schema.json",
  "extends": "@nx/workspace/presets/npm.json",
  "targetDefaults": {
    "build": {
      "cache": true,
      "dependsOn": ["^build"]
    },
    "test": {
      "cache": true
    },
    "lint": {
      "cache": true
    }
  },
  "tasksRunnerOptions": {
    "runner": "nx/tasks-runners/default",
    "cacheDirectoryOperations": ["read", "write"]
  }
}
```

### Framework-Specific Changes

#### Next.js Projects
| File | Source of Truth | Changes Made |
|------|------------------|------------|
| **next.config.js** | `apply_surgical_configs()` - Next.js section | Add optimized configuration |
| **package.json** | `apply_surgical_configs()` - Next.js section | Add Next.js dependencies |

**next.config.js additions:**
```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    appDir: true,
    serverComponentsExternalPackages: ['@mui/material', '@mui/icons-material']
  },
  images: {
    domains: ['example.com'],
    formats: ['image/webp', 'image/avif']
  },
  webpack: (config, { isServer }) => {
    if (!isServer) {
      config.resolve.fallback = {
        fs: false,
        path: false,
        os: false
      }
    }
    return config
  }
}

module.exports = nextConfig
```

#### React Projects
| File | Source of Truth | Changes Made |
|------|------------------|------------|
| **vite.config.ts** | `apply_surgical_configs()` - React section | Add optimized Vite configuration |
| **package.json** | `apply_surgical_configs()` - React section | Add React dependencies |

**vite.config.ts additions:**
```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  build: {
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          router: ['react-router-dom']
        }
      }
    }
  },
  optimizeDeps: {
    include: ['react', 'react-dom', 'react-router-dom']
  }
})
```

#### Vue.js Projects
| File | Source of Truth | Changes Made |
|------|------------------|------------|
| **vite.config.ts** | `apply_surgical_configs()` - Vue.js section | Add Vue.js configuration |
| **package.json** | `apply_surgical_configs()` - Vue.js section | Add Vue.js dependencies |

**vite.config.ts additions:**
```typescript
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  build: {
    sourcemap: true,
    rollupOptions: {
      output: {
        manualChunks: {
          vue: ['vue', 'vue-router'],
          vendor: ['pinia']
        }
      }
    }
  },
  optimizeDeps: {
    include: ['vue', 'vue-router', 'pinia']
  }
})
```

### Development Dependencies Added (Adopt Mode)

| Dependency | Source of Truth | Version | Purpose |
|-----------|------------------|--------|---------|
| **@types/node** | `apply_surgical_configs()` - Node.js deps | ^20.0.0 | Node.js type definitions |
| **typescript** | `apply_surgical_configs()` - Node.js deps | ^5.0.0 | TypeScript compiler |
| **eslint** | `apply_surgical_configs()` - Node.js deps | ^8.0.0 | Code linting |
| **prettier** | `apply_surgical_configs()` - Node.js deps | ^3.0.0 | Code formatting |
| **jest** | `apply_surgical_configs()` - Node.js deps | ^29.0.0 | Testing framework |
| **@types/jest** | `apply_surgical_configs()` - Node.js deps | ^29.0.0 | Jest type definitions |

### Runtime Dependencies Added (Adopt Mode)

| Dependency | Source of Truth | Version | Purpose |
|-----------|------------------|--------|---------|
| **next** | `apply_surgical_configs()` - Node.js deps | * | React framework |
| **react** | `apply_surgical_configs()` - Node.js deps | * | React library |
| **typescript** | `apply_surgical_configs()` - Node.js deps | * | TypeScript runtime |
| **better-all** | `apply_surgical_configs()` - Node.js deps | github.com/shuding/better-all | Better-all tools and utilities |

### Development Dependencies Added (Standardize Mode)

| Dependency | Source of Truth | Version | Purpose |
|-----------|------------------|--------|---------|
| **playwright** | `apply_surgical_configs()` - Node.js deps | ^1.40.0 | E2E testing |
| **@playwright/test** | `apply_surgical_configs()` - Node.js deps | ^1.40.0 | Playwright test runner |
| **tailwindcss** | `apply_surgical_configs()` - Node.js deps | ^3.0.0 | CSS framework |
| **postcss** | `apply_surgical_configs()` - Node.js deps | ^8.0.0 | CSS processing |
| **autoprefixer** | `apply_surgical_configs()` - Node.js deps | ^10.0.0 | CSS vendor prefixes |
| **vite** | `apply_surgical_configs()` - Node.js deps | ^5.0.0 | Build tool |
| **webpack** | `apply_surgical_configs()` - Node.js deps | ^5.0.0 | Module bundler |
| **rollup** | `apply_surgical_configs()` - Node.js deps | ^4.0.0 | Module bundler |
| **esbuild** | `apply_surgical_configs()` - Node.js deps | ^0.19.0 | JavaScript bundler |
| **storybook** | `apply_surgical_configs()` - Node.js deps | ^7.0.0 | Component documentation |
| **cypress** | `apply_surgical_configs()` - Node.js deps | ^13.0.0 | E2E testing alternative |
| **msw** | `apply_surgical_configs()` - Node.js deps | ^1.0.0 | API mocking |
| **husky** | `apply_surgical_configs()` - Node.js deps | ^8.0.0 | Git hooks |
| **lint-staged** | `apply_surgical_configs()` - Node.js deps | ^15.0.0 | Pre-commit linting |

### Runtime Dependencies Added (Standardize Mode)

| Dependency | Source of Truth | Version | Purpose |
|-----------|------------------|--------|---------|
| **next** | `apply_surgical_configs()` - Node.js deps | * | React framework |
| **react** | `apply_surgical_configs()` - Node.js deps | * | React library |
| **typescript** | `apply_surgical_configs()` - Node.js deps | * | TypeScript runtime |
| **better-all** | `apply_surgical_configs()` - Node.js deps | github.com/shuding/better-all | Better-all tools and utilities |
| **better-auth** | `apply_surgical_configs()` - Node.js deps | ^1.1.1 | Authentication library |
| **@better-auth/drizzle-adapter** | `apply_surgical_configs()` - Node.js deps | ^1.5.0-beta.9 | Drizzle adapter for better-auth |
| **@antfu/ni** | `apply_surgical_configs()` - Node.js deps | * | Package manager utilities |
| **@job-aide/tools-platform-next-config** | `apply_surgical_configs()` - Node.js deps | workspace:* | Next.js configuration |
| **bcryptjs** | `apply_surgical_configs()` - Node.js deps | * | Password hashing |
| **class-variance-authority** | `apply_surgical_configs()` - Node.js deps | * | CSS class utilities |
| **clsx** | `apply_surgical_configs()` - Node.js deps | * | CSS class utilities |
| **dotenv** | `apply_surgical_configs()` - Node.js deps | * | Environment variables |
| **drizzle-kit** | `apply_surgical_configs()` - Node.js deps | * | Database toolkit |
| **jose** | `apply_surgical_configs()` - Node.js deps | * | JavaScript Object Signing |
| **lucide-react** | `apply_surgical_configs()` - Node.js deps | * | Icon library |
| **only-allow** | `apply_surgical_configs()` - Node.js deps | * | Package manager enforcement |
| **postgres** | `apply_surgical_configs()` - Node.js deps | * | PostgreSQL client |
| **radix-ui** | `apply_surgical_configs()` - Node.js deps | * | UI components |
| **server-only** | `apply_surgical_configs()` - Node.js deps | * | Server-only code marker |
| **stripe** | `apply_surgical_configs()` - Node.js deps | * | Payment processing |
| **swr** | `apply_surgical_configs()` - Node.js deps | * | Data fetching |
| **tailwind-merge** | `apply_surgical_configs()` - Node.js deps | * | Tailwind class merging |
| **tailwindcss** | `apply_surgical_configs()` - Node.js deps | * | CSS framework |
| **tw-animate-css** | `apply_surgical_configs()` - Node.js deps | * | Tailwind animations |
| **zod** | `apply_surgical_configs()` - Node.js deps | * | Schema validation |

## Configuration Files

### tsconfig.json (Created if missing)
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "ESNext",
    "moduleResolution": "node",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "outDir": "./dist",
    "rootDir": "./src",
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

### .eslintrc.js (Created if missing)
```javascript
module.exports = {
  parser: '@typescript-eslint/parser',
  extends: [
    'eslint:recommended',
    '@typescript-eslint/recommended',
    'prettier'
  ],
  plugins: ['@typescript-eslint'],
  rules: {
    '@typescript-eslint/no-unused-vars': 'error',
    '@typescript-eslint/explicit-function-return-type': 'warn'
  }
};
```

### .prettierrc (Created if missing)
```json
{
  "semi": true,
  "trailingComma": "es5",
  "singleQuote": true,
  "printWidth": 80,
  "tabWidth": 2
}
```

### jest.config.js (Created if missing)
```javascript
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  roots: ['<rootDir>/src'],
  testMatch: ['**/__tests__/**/*.ts', '**/?(*.)+(spec|test).ts'],
  collectCoverageFrom: [
    'src/**/*.ts',
    '!src/**/*.d.ts'
  ]
};
```

## README.md Sections

### Node.js-Specific Content
```markdown
## Development Setup

### Prerequisites
- Node.js 22+
- pnpm
- Devbox
- Just

### Quick Start
```bash
# Clone and setup
git clone <repository-url>
cd project-name

# Setup development environment
devbox shell

# Bootstrap the project
just bootstrap

# Start development
just dev
```

## Available Commands

### Devbox Commands
```bash
devbox --list
devbox bootstrap
devbox build
devbox test
devbox dev
devbox lint
devbox typecheck
devbox clean
```

### Just Commands
```bash
just --list
just loop
just ci
just install
just update
```

## Project Structure
src/                     # Source code
├── components/          # React/Vue/Angular components
├── lib/                  # Library code
├── types/                # TypeScript type definitions
├── utils/                # Utility functions
└── index.ts             # Main entry point

tests/                   # Test files
├── unit/                 # Unit tests
├── integration/          # Integration tests
└── e2e/                  # End-to-end tests

dist/                    # Build output
node_modules/            # Dependencies (auto-generated)
```

## Testing Strategy
- **Unit tests**: `just test` (Jest)
- **Integration tests**: `just test:integration`
- **E2E tests**: `just test:e2e` (Playwright)
- **Type checking**: `just typecheck`
```

## AGENTS.md Sections

### Node.js-Specific Content
```markdown
## Repository Structure

### Core Directories
```
src/                     # Source code
├── components/          # React/Vue/Angular components
├── lib/                  # Library code
├── types/                # TypeScript type definitions
├── utils/                # Utility functions
└── index.ts             # Main entry point

tests/                   # Test files
├── unit/                 # Unit tests
├── integration/          # Integration tests
└── e2e/                  # End-to-end tests
```

### Configuration Files
- **package.json** - Dependencies and scripts
- **tsconfig.json** - TypeScript configuration
- **jest.config.js** - Test configuration
- **.eslintrc.js** - Linting configuration
- **tailwind.config.js** - CSS framework configuration
- **next.config.js** - Next.js configuration (if applicable)

### Essential Tools
- **pnpm** - Fast package manager
- **TypeScript** - Type-safe JavaScript
- **ESLint** - Code linting
- **Prettier** - Code formatting
- **Jest** - Testing framework

### Testing Strategy
- **Unit tests**: `just test` (Jest)
- **Integration tests**: `just test:integration`
- **E2E tests**: `just test:e2e` (Playwright)
- **Type checking**: `just typecheck`
```

## Environment Changes

### .envrc Node.js Configuration
```bash
# Project Environment Configuration
if command -v devbox >/dev/null 2>&1; then
    eval "$(devbox shellenv)"
fi

export PROJECT_NAME="$(basename "$PWD")"
export PROJECT_PATH="$PWD"
export NODE_ENV="development"

watch_file devbox.json
watch_file package.json
watch_file tsconfig.json
watch_file pnpm-lock.yaml
```

## Mode-Specific Differences

### Adopt Mode (Conservative)
- **Essential packages only** - Node.js, TypeScript, ESLint, Prettier, Jest
- **Basic configuration** - Minimal tsconfig, eslint, prettier configs
- **Standard scripts** - dev, build, test, lint, typecheck
- **Preserves existing** - Won't override existing configurations

### Standardize Mode (Comprehensive)
- **Full ecosystem** - Adds Playwright, Tailwind, Vite, Webpack, Rollup
- **Complete configuration** - Comprehensive configs for all tools
- **Advanced scripts** - Additional build and deployment scripts
- **Standardizes** - Enforces our preferred configurations

## Safety and Validation

### Post-Adoption Verification
```bash
# Verify Node.js environment
node --version
pnnpm --version

# Verify tooling
pnpm run lint
pnpm run typecheck
pnpm test

# Verify just integration
just --list
just loop
```

### Common Issues
- **Node version mismatch** - Ensure Node.js 22+ in devbox.json
- **pnpm not found** - Check devbox shell environment
- **TypeScript errors** - Verify tsconfig.json configuration
- **Test failures** - Check Jest configuration

## Related Documentation

- [All Projects Changes](changes-all-projects.md)
- [Rust Project Changes](changes-rust-projects.md)
- [Python Project Changes](changes-python-projects.md)
- [Go Project Changes](changes-go-projects.md)
- [Java Project Changes](changes-java-projects.md)

<!-- vim: set ft=markdown: -->
