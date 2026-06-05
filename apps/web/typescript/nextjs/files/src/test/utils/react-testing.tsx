import React, { ReactElement } from 'react';
import { render, RenderOptions } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { AuthProvider } from '@/contexts/auth-context';
import { ThemeProvider } from '@/components/theme-provider';

// Create a custom render function that includes providers
const AllTheProviders = ({ children }: { children: React.ReactNode }) => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: {
        retry: false,
        gcTime: 0,
      },
    },
  });

  return (
    <QueryClientProvider client={queryClient}>
      <ThemeProvider>
        <AuthProvider>
          {children}
        </AuthProvider>
      </ThemeProvider>
    </QueryClientProvider>
  );
};

const customRender = (
  ui: ReactElement,
  options?: Omit<RenderOptions, 'wrapper'>
) => render(ui, { wrapper: AllTheProviders, ...options });

// Re-export everything from Testing Library
export * from '@testing-library/react';
export { customRender as render };

// Mock handlers for common scenarios
export const mockUser = {
  id: '1',
  name: 'Test User',
  email: 'test@example.com',
  role: 'user',
};

export const mockAdminUser = {
  ...mockUser,
  role: 'admin',
};

// Helper functions for testing
export const createMockResponse = <T>(data: T, status = 200) => {
  return Promise.resolve({
    ok: status >= 200 && status < 300,
    status,
    json: () => Promise.resolve(data),
    text: () => Promise.resolve(JSON.stringify(data)),
  } as Response);
};

export const createMockErrorResponse = (message: string, status = 400) => {
  return Promise.resolve({
    ok: false,
    status,
    json: () => Promise.resolve({ error: message }),
    text: () => Promise.resolve(JSON.stringify({ error: message })),
  } as Response);
};

// Common test data factories
export const createTestUser = (overrides = {}) => ({
  id: 'test-user-id',
  name: 'Test User',
  email: 'test@example.com',
  role: 'user',
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString(),
  ...overrides,
});

export const createTestPost = (overrides = {}) => ({
  id: 'test-post-id',
  title: 'Test Post',
  content: 'This is test content',
  authorId: 'test-user-id',
  published: false,
  createdAt: new Date().toISOString(),
  updatedAt: new Date().toISOString(),
  ...overrides,
});

// Form testing helpers
export const fillForm = async (form: HTMLElement, data: Record<string, string>) => {
  for (const [name, value] of Object.entries(data)) {
    const field = form.querySelector(`[name="${name}"]`) as HTMLInputElement;
    if (field) {
      // Handle different input types
      if (field.type === 'checkbox') {
        field.checked = Boolean(value);
      } else if (field.type === 'radio') {
        const radio = form.querySelector(`[name="${name}"][value="${value}"]`) as HTMLInputElement;
        if (radio) radio.checked = true;
      } else {
        field.value = value;
      }
      
      // Trigger change event
      field.dispatchEvent(new Event('change', { bubbles: true }));
      field.dispatchEvent(new Event('input', { bubbles: true }));
    }
  }
};

export const submitForm = async (form: HTMLElement) => {
  const submitButton = form.querySelector('button[type="submit"]') as HTMLButtonElement;
  if (submitButton) {
    submitButton.click();
  } else {
    form.dispatchEvent(new Event('submit', { bubbles: true }));
  }
};

// Async testing helpers
export const waitForLoadingToFinish = () => {
  return new Promise((resolve) => {
    setTimeout(resolve, 0);
  });
};

// Mock Next.js router
export const mockRouter = {
  push: vi.fn(),
  replace: vi.fn(),
  back: vi.fn(),
  forward: vi.fn(),
  refresh: vi.fn(),
  prefetch: vi.fn(),
};

// Mock Next.js navigation
export const mockNavigation = {
  push: vi.fn(),
  replace: vi.fn(),
  back: vi.fn(),
  forward: vi.fn(),
  refresh: vi.fn(),
  prefetch: vi.fn(),
};
