# Testing Guide

This guide covers the comprehensive testing setup included in this Next.js boilerplate.

## Overview

The boilerplate includes a complete testing infrastructure powered by Vitest with support for:
- Unit tests
- Integration tests  
- End-to-end requirements testing
- End-to-end use case testing
- Performance testing
- Code coverage reporting

## Test Structure

```
__test__/
├── unit/                    # Fast unit tests
│   ├── basic.test.mts
│   ├── boilerplate-structure.test.mts
│   ├── nextjs-config.test.mts
│   ├── react-components.test.mts
│   ├── auth-config.test.mts
│   ├── database-config.test.mts
│   ├── docker-deployment.test.mts
│   ├── user-management.test.mts
│   └── vitest-config.test.mts
├── integration/             # Integration tests
├── e2e/                     # End-to-end tests
│   ├── requirements/        # Requirements-based E2E tests
│   └── usecases/           # Use case-based E2E tests
└── api/                     # API-specific tests
```

## Configuration

### Vitest Configuration

The `vitest.config.mts` file provides a multi-project setup:

```typescript
export default defineConfig({
  resolve: {
    alias: [
      { find: /^@\/app\/(.*)$/, replacement: path.resolve(__dirname, "src/$1") },
      { find: /^@\/components\/(.*)$/, replacement: path.resolve(__dirname, "src/components/$1") },
      { find: /^@\/lib\/(.*)$/, replacement: path.resolve(__dirname, "src/lib/$1") },
      { find: /^@\/utils\/(.*)$/, replacement: path.resolve(__dirname, "src/utils/$1") },
      { find: /^@\/types\/(.*)$/, replacement: path.resolve(__dirname, "src/types/$1") },
    ],
  },
  projects: [
    defineProject({
      test: {
        name: "unit",
        include: ["tests/unit/**/*.test.mts", "__tests__/unit/**/*.test.mts"],
        environment: "node",
        testTimeout: 30_000,
        hookTimeout: 30_000
      }
    }),
    // ... other projects (integration, e2e, performance)
  ]
});
```

### Environment Variables

Tests run with `NODE_ENV=test` automatically. Additional test environment variables can be set in `.env.test`:

```bash
# .env.test
NODE_ENV=test
DATABASE_URL=postgresql://test:test@localhost:5432/test_db
NEXTAUTH_SECRET=test-secret
NEXTAUTH_URL=http://localhost:3000
```

## Running Tests

### Basic Commands

```bash
# Run all tests
pnpm test

# Run tests in watch mode
pnpm test:watch

# Run specific test project
pnpm test:integration
pnpm test:e2e:requirements
pnpm test:e2e:usecases
pnpm test:performance

# Run with coverage
pnpm test:coverage
```

### Advanced Usage

```bash
# Run specific test file
npx vitest run basic.test.mts

# Run tests matching pattern
npx vitest run --grep "should render"

# Run tests with specific reporter
npx vitest run --reporter=verbose

# Run tests in specific project
npx vitest run --project unit
```

## Writing Tests

### Test File Naming

- Use `.test.mts` extension for all test files
- Place unit tests in `__test__/unit/` or `tests/unit/`
- Place integration tests in `__test__/integration/` or `tests/integration/`
- Place E2E tests in `__test__/e2e/` or `tests/e2e/`

### Basic Test Structure

```typescript
import { describe, it, expect, beforeAll, afterAll, beforeEach, afterEach } from 'vitest';
import { render, screen, cleanup } from '@testing-library/react';
import { UserButton } from '@/components/UserButton';

describe('UserButton Component', () => {
  beforeEach(() => {
    cleanup();
  });

  it('should render user name', () => {
    render(<UserButton name="John Doe" />);
    expect(screen.getByText('John Doe')).toBeInTheDocument();
  });

  it('should handle click events', async () => {
    const handleClick = vi.fn();
    render(<UserButton name="Test" onClick={handleClick} />);
    
    await userEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });
});
```

### Async Testing

```typescript
import { describe, it, expect } from 'vitest';
import { getUserData } from '@/lib/api';

describe('API Functions', () => {
  it('should fetch user data', async () => {
    const user = await getUserData('123');
    expect(user).toBeDefined();
    expect(user.id).toBe('123');
  });

  it('should handle API errors', async () => {
    await expect(getUserData('invalid')).rejects.toThrow('User not found');
  });
});
```

### Mocking

```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { UserService } from '@/lib/user-service';

// Mock entire module
vi.mock('@/lib/api', () => ({
  fetchUser: vi.fn(),
  updateUser: vi.fn()
}));

// Mock specific function
const mockFetchUser = vi.mocked(fetchUser);

describe('UserService', () => {
  beforeEach(() => {
    vi.clearAllMocks();
  });

  it('should use mocked API', async () => {
    mockFetchUser.mockResolvedValue({ id: '123', name: 'Test' });
    
    const user = await UserService.getUser('123');
    expect(user.name).toBe('Test');
    expect(mockFetchUser).toHaveBeenCalledWith('123');
  });
});
```

## Test Utilities

### Setup and Teardown

```typescript
import { beforeAll, afterAll, beforeEach, afterEach } from 'vitest';
import { setupTestDatabase, cleanupTestDatabase } from '@/test/utils/database';

describe('Database Tests', () => {
  beforeAll(async () => {
    await setupTestDatabase();
  });

  afterAll(async () => {
    await cleanupTestDatabase();
  });

  beforeEach(async () => {
    await resetTestData();
  });
});
```

### Custom Matchers

```typescript
import { expect } from 'vitest';
import { User } from '@/types/user';

// Custom matcher
expect.extend({
  toBeValidUser(received: User) {
    const isValid = received.id && received.name && received.email;
    return {
      pass: isValid,
      message: () => `expected ${received} to be a valid user`
    };
  }
});

// Usage
expect(user).toBeValidUser();
```

## React Component Testing

### Rendering Components

```typescript
import { render, screen } from '@testing-library/react';
import { AuthProvider } from '@/contexts/auth-context';
import { UserProfile } from '@/components/UserProfile';

const renderWithAuth = (component: React.ReactElement) => {
  return render(
    <AuthProvider>
      {component}
    </AuthProvider>
  );
};

describe('UserProfile', () => {
  it('should display user profile', () => {
    renderWithAuth(<UserProfile userId="123" />);
    expect(screen.getByTestId('user-profile')).toBeInTheDocument();
  });
});
```

### User Interactions

```typescript
import { render, screen } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { LoginForm } from '@/components/LoginForm';

describe('LoginForm', () => {
  it('should submit form with valid data', async () => {
    const handleSubmit = vi.fn();
    render(<LoginForm onSubmit={handleSubmit} />);
    
    await userEvent.type(screen.getByLabelText(/email/i), 'test@example.com');
    await userEvent.type(screen.getByLabelText(/password/i), 'password123');
    await userEvent.click(screen.getByRole('button', { name: /submit/i }));
    
    expect(handleSubmit).toHaveBeenCalledWith({
      email: 'test@example.com',
      password: 'password123'
    });
  });
});
```

## API Testing

### Route Handlers

```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { GET, POST } from '@/app/api/users/route';
import { NextRequest } from 'next/server';

describe('/api/users', () => {
  beforeEach(() => {
    // Reset mock data
    vi.clearAllMocks();
  });

  it('GET should return users list', async () => {
    const request = new NextRequest('http://localhost:3000/api/users');
    const response = await GET(request);
    const data = await response.json();
    
    expect(response.status).toBe(200);
    expect(Array.isArray(data)).toBe(true);
  });

  it('POST should create new user', async () => {
    const userData = { name: 'John', email: 'john@example.com' };
    const request = new NextRequest('http://localhost:3000/api/users', {
      method: 'POST',
      body: JSON.stringify(userData),
      headers: { 'Content-Type': 'application/json' }
    });
    
    const response = await POST(request);
    const data = await response.json();
    
    expect(response.status).toBe(201);
    expect(data.name).toBe(userData.name);
  });
});
```

## Database Testing

### Test Database Setup

```typescript
import { drizzle } from 'drizzle-orm/postgres-js';
import postgres from 'postgres';
import * as schema from '@/lib/db/schema';
import { migrate } from 'drizzle-orm/postgres-js/migrator';

const testDb = drizzle(postgres(process.env.TEST_DATABASE_URL!), { schema });

export const setupTestDatabase = async () => {
  // Run migrations
  await migrate(testDb, { migrationsFolder: 'drizzle' });
};

export const resetTestData = async () => {
  // Clean up test data
  await testDb.delete(schema.users);
  await testDb.delete(schema.sessions);
};

export const cleanupTestDatabase = async () => {
  // Close connections
  await testDb.$client.end();
};
```

### Database Tests

```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { db } from '@/lib/db';
import { users } from '@/lib/db/schema';
import { UserService } from '@/lib/user-service';

describe('UserService Database Integration', () => {
  beforeEach(async () => {
    await resetTestData();
  });

  it('should create user in database', async () => {
    const userData = { name: 'John', email: 'john@example.com' };
    const user = await UserService.create(userData);
    
    expect(user.id).toBeDefined();
    
    // Verify in database
    const dbUser = await db.query.users.findFirst({
      where: eq(users.id, user.id)
    });
    expect(dbUser).toBeDefined();
    expect(dbUser?.name).toBe(userData.name);
  });
});
```

## Performance Testing

### Load Testing

```typescript
import { describe, it, expect } from 'vitest';
import { performance } from 'node:perf_hooks';
import { processLargeDataset } from '@/lib/data-processor';

describe('Performance Tests', () => {
  it('should process 10k records within acceptable time', async () => {
    const data = generateTestData(10000);
    const start = performance.now();
    
    await processLargeDataset(data);
    
    const duration = performance.now() - start;
    expect(duration).toBeLessThan(5000); // 5 seconds max
  });

  it('should handle memory efficiently', async () => {
    const initialMemory = process.memoryUsage().heapUsed;
    
    await processLargeDataset(generateTestData(100000));
    
    // Force garbage collection if available
    if (global.gc) global.gc();
    
    const finalMemory = process.memoryUsage().heapUsed;
    const memoryIncrease = finalMemory - initialMemory;
    
    // Should not increase by more than 100MB
    expect(memoryIncrease).toBeLessThan(100 * 1024 * 1024);
  });
});
```

## Best Practices

### 1. Test Organization

- Group related tests in `describe` blocks
- Use descriptive test names that explain the behavior
- Keep tests focused on a single piece of functionality
- Use `beforeEach`/`afterEach` for test isolation

### 2. Test Data

- Use factories or builders for test data
- Avoid hardcoding test values
- Use realistic but simple test data
- Clean up test data after each test

### 3. Assertions

- Use specific assertions (`toBe` vs `toEqual`)
- Test both positive and negative cases
- Include edge cases and error conditions
- Use custom matchers for domain-specific assertions

### 4. Mocking

- Mock external dependencies
- Use `vi.clearAllMocks()` in `beforeEach`
- Prefer integration tests over extensive mocking
- Mock at the boundary (HTTP, database, file system)

### 5. Performance

- Keep unit tests fast (< 100ms each)
- Use test projects to separate slow tests
- Run performance tests separately
- Monitor test execution time

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'pnpm'
      
      - run: pnpm install
      - run: pnpm test:coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage/lcov.info
```

## Troubleshooting

### Common Issues

1. **Import errors**: Check path aliases in `vitest.config.mts`
2. **Timeout errors**: Increase timeout in test configuration
3. **Memory issues**: Use `--no-threads` flag for memory-intensive tests
4. **Database connection**: Ensure test database is running and accessible

### Debug Mode

```bash
# Run tests with Node.js inspector
node --inspect-brk node_modules/.bin/vitest run

# Run single test in debug mode
node --inspect-brk node_modules/.bin/vitest run basic.test.mts
```

## Coverage

### Coverage Configuration

Coverage is configured to:
- Include all `src/` files
- Exclude test files and configuration
- Generate reports in multiple formats (lcov, html, text)

### Coverage Goals

- Aim for > 80% line coverage
- Focus on critical business logic
- Don't chase 100% coverage blindly
- Use coverage reports to identify untested code

### Coverage Reports

```bash
# Generate coverage report
pnpm test:coverage

# View HTML report
open coverage/index.html

# Check coverage thresholds
npx vitest run --coverage --reporter=verbose
```

This comprehensive testing setup provides a solid foundation for maintaining code quality and reliability in your Next.js applications.
