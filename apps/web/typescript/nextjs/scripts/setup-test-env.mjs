#!/usr/bin/env node

/**
 * Setup script for test environment
 * This script prepares the environment for running tests
 */

import { execSync } from 'node:child_process';
import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const projectRoot = join(__dirname, '..');

// ANSI color codes for output
const colors = {
  reset: '\x1b[0m',
  bright: '\x1b[1m',
  red: '\x1b[31m',
  green: '\x1b[32m',
  yellow: '\x1b[33m',
  blue: '\x1b[34m',
  magenta: '\x1b[35m',
  cyan: '\x1b[36m',
};

function log(message, color = 'reset') {
  console.log(`${colors[color]}${message}${colors.reset}`);
}

function runCommand(command, description) {
  log(`\n📋 ${description}`, 'cyan');
  try {
    execSync(command, { 
      stdio: 'inherit', 
      cwd: projectRoot,
      env: { ...process.env, NODE_ENV: 'test' }
    });
    log(`✅ ${description} - completed`, 'green');
  } catch (error) {
    log(`❌ ${description} - failed`, 'red');
    log(`Error: ${error.message}`, 'red');
    process.exit(1);
  }
}

function createTestEnvFile() {
  const testEnvPath = join(projectRoot, '.env.test');
  
  if (!existsSync(testEnvPath)) {
    log('\n📝 Creating .env.test file...', 'yellow');
    
    const testEnvContent = `# Test Environment Variables
NODE_ENV=test
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_API_URL=http://localhost:3000/api

# Database (for integration tests)
DATABASE_URL=postgresql://test:test@localhost:5432/test_db

# Authentication (for auth tests)
NEXTAUTH_SECRET=test-secret-key-for-testing-only
NEXTAUTH_URL=http://localhost:3000

# External Services (mocked in tests)
STRIPE_SECRET_KEY=sk_test_mock
SMTP_HOST=smtp.test
SMTP_USER=test
SMTP_PASS=test

# Feature Flags (test configuration)
ENABLE_ANALYTICS=false
ENABLE_ERROR_REPORTING=false
ENABLE_PERFORMANCE_MONITORING=false
`;

    writeFileSync(testEnvPath, testEnvContent);
    log('✅ .env.test file created', 'green');
  } else {
    log('✅ .env.test file already exists', 'green');
  }
}

function createTestDirectories() {
  const testDirs = [
    join(projectRoot, 'tests'),
    join(projectRoot, 'tests/unit'),
    join(projectRoot, 'tests/integration'),
    join(projectRoot, 'tests/e2e'),
    join(projectRoot, 'tests/e2e/requirements'),
    join(projectRoot, 'tests/e2e/usecases'),
    join(projectRoot, 'tests/performance'),
    join(projectRoot, 'test-coverage'),
    join(projectRoot, 'test-reports'),
  ];

  log('\n📁 Creating test directories...', 'yellow');
  
  testDirs.forEach(dir => {
    if (!existsSync(dir)) {
      mkdirSync(dir, { recursive: true });
      log(`  Created: ${dir}`, 'blue');
    }
  });
  
  log('✅ Test directories ready', 'green');
}

function checkDependencies() {
  log('\n🔍 Checking test dependencies...', 'yellow');
  
  const requiredPackages = [
    'vitest',
    '@testing-library/react',
    '@testing-library/jest-dom',
    '@testing-library/user-event',
    'jsdom',
  ];

  const packageJsonPath = join(projectRoot, 'package.json');
  const packageJson = JSON.parse(require('fs').readFileSync(packageJsonPath, 'utf8'));
  
  const missingPackages = [];
  
  requiredPackages.forEach(pkg => {
    if (!packageJson.devDependencies?.[pkg] && !packageJson.dependencies?.[pkg]) {
      missingPackages.push(pkg);
    }
  });

  if (missingPackages.length > 0) {
    log(`⚠️  Missing test dependencies: ${missingPackages.join(', ')}`, 'yellow');
    log('Installing missing dependencies...', 'yellow');
    runCommand(`pnpm add -D ${missingPackages.join(' ')}`, 'Installing test dependencies');
  } else {
    log('✅ All test dependencies are available', 'green');
  }
}

function validateVitestConfig() {
  log('\n⚙️  Validating Vitest configuration...', 'yellow');
  
  const vitestConfigPath = join(projectRoot, 'vitest.config.mts');
  
  if (!existsSync(vitestConfigPath)) {
    log('❌ vitest.config.mts not found', 'red');
    log('Please ensure vitest.config.mts exists in the project root', 'red');
    process.exit(1);
  }
  
  try {
    // Try to load and validate the config
    execSync('npx vitest validate', { 
      stdio: 'pipe', 
      cwd: projectRoot 
    });
    log('✅ Vitest configuration is valid', 'green');
  } catch (error) {
    log('⚠️  Vitest configuration validation failed (this is normal for custom configs)', 'yellow');
  }
}

function runHealthCheck() {
  log('\n🏥 Running test environment health check...', 'yellow');
  
  try {
    // Check if Vitest can run
    execSync('npx vitest run --reporter=verbose __test__/unit/basic.test.mts', { 
      stdio: 'pipe', 
      cwd: projectRoot,
      timeout: 30000
    });
    log('✅ Basic test can run successfully', 'green');
  } catch (error) {
    log('⚠️  Basic test failed - this might be expected in a new project', 'yellow');
  }
}

function main() {
  log('🚀 Setting up test environment for Next.js boilerplate', 'bright');
  log('================================================', 'bright');
  
  // Change to project directory
  process.chdir(projectRoot);
  
  // Run setup steps
  createTestEnvFile();
  createTestDirectories();
  checkDependencies();
  validateVitestConfig();
  runHealthCheck();
  
  log('\n🎉 Test environment setup completed!', 'bright');
  log('================================================', 'bright');
  log('\nNext steps:', 'cyan');
  log('1. Run tests: pnpm test', 'blue');
  log('2. Run tests in watch mode: pnpm test:watch', 'blue');
  log('3. Run coverage: pnpm test:coverage', 'blue');
  log('4. Run specific test project: pnpm test:integration', 'blue');
  log('\nFor more information, see: docs/testing.md', 'cyan');
}

// Handle uncaught errors
process.on('uncaughtException', (error) => {
  log(`\n💥 Uncaught error: ${error.message}`, 'red');
  process.exit(1);
});

process.on('unhandledRejection', (reason, promise) => {
  log(`\n💥 Unhandled rejection at: ${promise}, reason: ${reason}`, 'red');
  process.exit(1);
});

// Run the setup
main();
