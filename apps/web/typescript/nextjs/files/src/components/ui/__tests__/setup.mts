import '@testing-library/jest-dom'
import { vi } from 'vitest'

// Mock Radix UI components to avoid dependency issues
vi.mock('@radix-ui/react-checkbox', () => ({
  CheckboxPrimitive: {
    Root: ({ children, ...props }: any) => <button role="checkbox" {...props}>{children}</button>,
    Indicator: ({ children, ...props }: any) => <span {...props}>{children}</span>,
  },
}))

vi.mock('@radix-ui/react-dialog', () => ({
  DialogPrimitive: {
    Root: ({ children }: any) => <div>{children}</div>,
    Trigger: ({ children, ...props }: any) => <button {...props}>{children}</button>,
    Portal: ({ children }: any) => <div>{children}</div>,
    Overlay: ({ children, ...props }: any) => <div data-testid="dialog-overlay" {...props}>{children}</div>,
    Content: ({ children, ...props }: any) => <div role="dialog" aria-modal="true" {...props}>{children}</div>,
    Close: ({ children, ...props }: any) => <button {...props}>{children}</button>,
    Title: ({ children, ...props }: any) => <h2 {...props}>{children}</h2>,
    Description: ({ children, ...props }: any) => <p {...props}>{children}</p>,
  },
}))

vi.mock('@radix-ui/react-label', () => ({
  LabelPrimitive: {
    Root: ({ children, ...props }: any) => <label {...props}>{children}</label>,
  },
}))

vi.mock('@radix-ui/react-select', () => ({
  SelectPrimitive: {
    Root: ({ children }: any) => <div>{children}</div>,
    Value: ({ children, ...props }: any) => <span {...props}>{children}</span>,
    Trigger: ({ children, ...props }: any) => <button {...props}>{children}</button>,
    Content: ({ children, ...props }: any) => <div {...props}>{children}</div>,
    Label: ({ children, ...props }: any) => <label {...props}>{children}</label>,
    Item: ({ children, ...props }: any) => <div {...props}>{children}</div>,
    Group: ({ children, ...props }: any) => <div {...props}>{children}</div>,
    Separator: ({ ...props }: any) => <hr {...props} />,
    ScrollUpButton: ({ ...props }: any) => <div {...props}>↑</div>,
    ScrollDownButton: ({ ...props }: any) => <div {...props}>↓</div>,
  },
}))

vi.mock('@radix-ui/react-switch', () => ({
  SwitchPrimitive: {
    Root: ({ children, ...props }: any) => <button role="switch" {...props}>{children}</button>,
    Thumb: ({ children, ...props }: any) => <span {...props}>{children}</span>,
  },
}))

vi.mock('@radix-ui/react-tabs', () => ({
  TabsPrimitive: {
    Root: ({ children }: any) => <div>{children}</div>,
    List: ({ children, ...props }: any) => <div role="tablist" {...props}>{children}</div>,
    Trigger: ({ children, ...props }: any) => <button role="tab" {...props}>{children}</button>,
    Content: ({ children, ...props }: any) => <div role="tabpanel" {...props}>{children}</div>,
  },
}))

// Mock lucide-react icons
vi.mock('lucide-react', () => ({
  Check: ({ ...props }: any) => <span data-testid="check-icon" {...props}>✓</span>,
  ChevronDown: ({ ...props }: any) => <span data-testid="chevron-down-icon" {...props}>▼</span>,
  ChevronUp: ({ ...props }: any) => <span data-testid="chevron-up-icon" {...props}>▲</span>,
  X: ({ ...props }: any) => <span data-testid="x-icon" {...props}>×</span>,
}))

// Mock the cn utility function
vi.mock('@/lib/utils', () => ({
  cn: (...classes: any[]) => classes.filter(Boolean).join(' '),
}))

// Mock userEvent
const userEvent = await import('@testing-library/user-event')
export { userEvent }
