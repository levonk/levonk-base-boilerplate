import { render, screen } from "@testing-library/react"
import { describe, it, expect } from "vitest"
import { Button } from "./button"

describe("Button", () => {
  it("renders with default props", () => {
    render(<Button>Click me</Button>)
    const button = screen.getByRole("button", { name: "Click me" })
    expect(button).toBeInTheDocument()
    expect(button).toHaveClass("bg-primary")
  })

  it("renders with different variants", () => {
    render(<Button variant="destructive">Delete</Button>)
    const button = screen.getByRole("button", { name: "Delete" })
    expect(button).toHaveClass("bg-destructive")
  })

  it("renders with different sizes", () => {
    render(<Button size="lg">Large Button</Button>)
    const button = screen.getByRole("button", { name: "Large Button" })
    expect(button).toHaveClass("h-11")
  })

  it("can be disabled", () => {
    render(<Button disabled>Disabled</Button>)
    const button = screen.getByRole("button", { name: "Disabled" })
    expect(button).toBeDisabled()
    expect(button).toHaveClass("disabled:opacity-50")
  })

  it("renders as child when asChild is true", () => {
    render(
      <Button asChild>
        <a href="/test">Link Button</a>
      </Button>
    )
    const link = screen.getByRole("link", { name: "Link Button" })
    expect(link).toBeInTheDocument()
    expect(link).toHaveClass("bg-primary")
  })
})
