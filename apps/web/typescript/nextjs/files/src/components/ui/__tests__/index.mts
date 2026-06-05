// Component Library Test Suite
// This file exports all test utilities and serves as the main test entry point

export * from './setup'

// Import all component tests
import './button.test'
import './input.test'
import './checkbox.test'
import './dialog.test'

// Test utilities for component testing
export const createMockProps = <T extends Record<string, any>>(defaults: T) => {
  return (overrides: Partial<T> = {}): T => ({
    ...defaults,
    ...overrides,
  })
}

export const expectComponentToRender = (component: HTMLElement) => {
  expect(component).toBeInTheDocument()
  expect(component).toBeVisible()
}

export const expectAccessibilityAttributes = (
  element: HTMLElement,
  attributes: Record<string, string>
) => {
  Object.entries(attributes).forEach(([attr, value]) => {
    expect(element).toHaveAttribute(attr, value)
  })
}

// Common test scenarios
export const commonComponentTests = {
  rendersWithDefaultProps: (Component: React.ComponentType<any>, props: any = {}) => {
    test('renders with default props', () => {
      render(<Component {...props} />)
      expectComponentToRender(screen.getByRole('button'))
    })
  },

  handlesClickEvents: (Component: React.ComponentType<any>, props: any = {}) => {
    test('handles click events', async () => {
      const handleClick = vi.fn()
      render(<Component {...props} onClick={handleClick} />)
      const element = screen.getByRole('button')
      await userEvent.click(element)
      expect(handleClick).toHaveBeenCalledTimes(1)
    })
  },

  supportsDisabledState: (Component: React.ComponentType<any>, props: any = {}) => {
    test('can be disabled', () => {
      render(<Component {...props} disabled />)
      const element = screen.getByRole('button')
      expect(element).toBeDisabled()
    })
  },

  supportsCustomClassName: (Component: React.ComponentType<any>, props: any = {}) => {
    test('applies custom className', () => {
      render(<Component {...props} className="custom-class" />)
      const element = screen.getByRole('button')
      expect(element).toHaveClass('custom-class')
    })
  },
}
