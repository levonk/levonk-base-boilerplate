import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { expect, test, describe } from 'vitest'
import { Checkbox } from '../checkbox'

describe('Checkbox', () => {
  test('renders with default styling', () => {
    render(<Checkbox />)
    const checkbox = screen.getByRole('checkbox')
    expect(checkbox).toBeInTheDocument()
    expect(checkbox).toHaveClass('peer', 'h-4', 'w-4')
  })

  test('can be checked and unchecked', async () => {
    const handleChange = vi.fn()
    render(<Checkbox onCheckedChange={handleChange} />)
    const checkbox = screen.getByRole('checkbox')
    
    await userEvent.click(checkbox)
    expect(checkbox).toBeChecked()
    expect(handleChange).toHaveBeenCalledWith(true)
    
    await userEvent.click(checkbox)
    expect(checkbox).not.toBeChecked()
    expect(handleChange).toHaveBeenCalledWith(false)
  })

  test('supports default checked state', () => {
    render(<Checkbox defaultChecked />)
    const checkbox = screen.getByRole('checkbox')
    expect(checkbox).toBeChecked()
  })

  test('can be disabled', () => {
    render(<Checkbox disabled />)
    const checkbox = screen.getByRole('checkbox')
    expect(checkbox).toBeDisabled()
  })

  test('renders with label', () => {
    render(
      <label>
        <Checkbox />
        Accept terms
      </label>
    )
    expect(screen.getByText('Accept terms')).toBeInTheDocument()
  })

  test('supports ref forwarding', () => {
    const ref = { current: null }
    render(<Checkbox ref={ref} />)
    expect(ref.current).toBeInstanceOf(HTMLButtonElement)
  })

  test('has proper accessibility attributes', () => {
    render(<Checkbox aria-label="Accept terms" />)
    const checkbox = screen.getByRole('checkbox', { name: 'Accept terms' })
    expect(checkbox).toBeInTheDocument()
  })
})
