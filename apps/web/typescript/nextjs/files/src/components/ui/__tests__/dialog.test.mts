import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { expect, test, describe } from 'vitest'
import { Dialog, DialogContent, DialogTrigger, DialogHeader, DialogTitle, DialogDescription } from '../dialog'

describe('Dialog', () => {
  test('renders closed by default', () => {
    render(
      <Dialog>
        <DialogTrigger>Open Dialog</DialogTrigger>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Test Dialog</DialogTitle>
            <DialogDescription>This is a test dialog</DialogDescription>
          </DialogHeader>
        </DialogContent>
      </Dialog>
    )
    
    expect(screen.getByText('Open Dialog')).toBeInTheDocument()
    expect(screen.queryByText('Test Dialog')).not.toBeInTheDocument()
  })

  test('opens when trigger is clicked', async () => {
    render(
      <Dialog>
        <DialogTrigger>Open Dialog</DialogTrigger>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Test Dialog</DialogTitle>
            <DialogDescription>This is a test dialog</DialogDescription>
          </DialogHeader>
        </DialogContent>
      </Dialog>
    )
    
    await userEvent.click(screen.getByText('Open Dialog'))
    expect(screen.getByText('Test Dialog')).toBeInTheDocument()
    expect(screen.getByText('This is a test dialog')).toBeInTheDocument()
  })

  test('closes when close button is clicked', async () => {
    render(
      <Dialog>
        <DialogTrigger>Open Dialog</DialogTrigger>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Test Dialog</DialogTitle>
            <DialogDescription>This is a test dialog</DialogDescription>
          </DialogHeader>
        </DialogContent>
      </Dialog>
    )
    
    await userEvent.click(screen.getByText('Open Dialog'))
    expect(screen.getByText('Test Dialog')).toBeInTheDocument()
    
    const closeButton = screen.getByRole('button', { name: 'Close' })
    await userEvent.click(closeButton)
    expect(screen.queryByText('Test Dialog')).not.toBeInTheDocument()
  })

  test('closes when escape key is pressed', async () => {
    render(
      <Dialog>
        <DialogTrigger>Open Dialog</DialogTrigger>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Test Dialog</DialogTitle>
          </DialogHeader>
        </DialogContent>
      </Dialog>
    )
    
    await userEvent.click(screen.getByText('Open Dialog'))
    expect(screen.getByText('Test Dialog')).toBeInTheDocument()
    
    await userEvent.keyboard('{Escape}')
    expect(screen.queryByText('Test Dialog')).not.toBeInTheDocument()
  })

  test('has proper accessibility attributes', async () => {
    render(
      <Dialog>
        <DialogTrigger>Open Dialog</DialogTrigger>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Test Dialog</DialogTitle>
            <DialogDescription>Description</DialogDescription>
          </DialogHeader>
        </DialogContent>
      </Dialog>
    )
    
    await userEvent.click(screen.getByText('Open Dialog'))
    
    const dialog = screen.getByRole('dialog')
    expect(dialog).toHaveAttribute('role', 'dialog')
    expect(dialog).toHaveAttribute('aria-modal', 'true')
    
    const title = screen.getByRole('heading', { name: 'Test Dialog' })
    expect(title).toBeInTheDocument()
  })

  test('supports custom className', async () => {
    render(
      <Dialog>
        <DialogTrigger>Open Dialog</DialogTrigger>
        <DialogContent className="custom-dialog">
          <DialogHeader>
            <DialogTitle>Test Dialog</DialogTitle>
          </DialogHeader>
        </DialogContent>
      </Dialog>
    )
    
    await userEvent.click(screen.getByText('Open Dialog'))
    const dialog = screen.getByRole('dialog')
    expect(dialog).toHaveClass('custom-dialog')
  })
})
