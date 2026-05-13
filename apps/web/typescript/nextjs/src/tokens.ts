// Design tokens for the Next.js boilerplate
// This file integrates with the white label system to provide dynamic theming

import { getWhiteLabelConfig } from "@/lib/white-label"

// Get white label configuration (falls back to defaults if not set)
const whiteLabelConfig = getWhiteLabelConfig()

// Convert white label colors to token format
const colors = {
  // Primary colors from white label config
  "fg.primary": whiteLabelConfig.theme.colors.foreground,
  "fg.muted": whiteLabelConfig.theme.colors.mutedForeground,
  "bg.canvas": whiteLabelConfig.theme.colors.background,
  "bg.surface": whiteLabelConfig.theme.colors.card,
  "accent.default": whiteLabelConfig.theme.colors.primary,
  "accent.hover": whiteLabelConfig.theme.colors.ring,
  "border.default": whiteLabelConfig.theme.colors.border,
  "danger.default": whiteLabelConfig.theme.colors.destructive,
  "danger.fg": whiteLabelConfig.theme.colors.destructiveForeground,

  // Additional semantic colors
  "fg.secondary": whiteLabelConfig.theme.colors.secondaryForeground,
  "bg.secondary": whiteLabelConfig.theme.colors.secondary,
  "bg.input": whiteLabelConfig.theme.colors.input,
  "accent.fg": whiteLabelConfig.theme.colors.primaryForeground,
  "bg.popover": whiteLabelConfig.theme.colors.popover,
  "fg.popover": whiteLabelConfig.theme.colors.popoverForeground,
  "bg.card": whiteLabelConfig.theme.colors.card,
  "fg.card": whiteLabelConfig.theme.colors.cardForeground,
}

// Spacing tokens (can be extended from white label config if needed)
const space = {
  px: "1px",
  0: "0rem",
  1: "0.25rem",
  2: "0.5rem",
  3: "0.75rem",
  4: "1rem",
  6: "1.5rem",
  8: "2rem",
  10: "2.5rem",
  12: "3rem",
  16: "4rem",
  20: "5rem",
  24: "6rem",
}

// Border radius from white label config
const radius = whiteLabelConfig.theme.borderRadius

// Font sizes
const fontSize = {
  xs: "0.75rem",
  sm: "0.875rem",
  md: "1rem",
  lg: "1.125rem",
  xl: "1.25rem",
  "2xl": "1.5rem",
  "3xl": "1.875rem",
  "4xl": "2.25rem",
  "5xl": "3rem",
}

// Font families from white label config
const fontFamily = whiteLabelConfig.theme.fonts

// Shadow tokens
const shadow = {
  sm: "0 1px 2px rgba(0,0,0,0.05)",
  md: "0 4px 6px rgba(0,0,0,0.1)",
  lg: "0 10px 15px rgba(0,0,0,0.15)",
  xl: "0 20px 25px rgba(0,0,0,0.2)",
}

// Z-index tokens
const zIndex = {
  dropdown: 1000,
  modal: 1100,
  toast: 1200,
  tooltip: 1300,
}

// Export the complete token system
export default {
  colors,
  space,
  radius,
  fontSize,
  fontFamily,
  shadow,
  zIndex,
} as const

// Export individual token categories for convenience
export { colors, space, radius, fontSize, fontFamily, shadow, zIndex }

// Helper function to get CSS custom properties from tokens
export function getCSSCustomProperties() {
  const cssVars: string[] = []

  // Generate color variables
  Object.entries(colors).forEach(([key, value]) => {
    const cssVar = `--color-${key.replace(/\./g, '-')}`
    cssVars.push(`${cssVar}: ${value};`)
  })

  // Generate space variables
  Object.entries(space).forEach(([key, value]) => {
    cssVars.push(`--space-${key}: ${value};`)
  })

  // Generate radius variables
  Object.entries(radius).forEach(([key, value]) => {
    cssVars.push(`--radius-${key}: ${value};`)
  })

  // Generate font size variables
  Object.entries(fontSize).forEach(([key, value]) => {
    cssVars.push(`--font-size-${key}: ${value};`)
  })

  // Generate font family variables
  Object.entries(fontFamily).forEach(([key, value]) => {
    cssVars.push(`--font-family-${key}: ${value.join(', ')};`)
  })

  // Generate shadow variables
  Object.entries(shadow).forEach(([key, value]) => {
    cssVars.push(`--shadow-${key}: ${value};`)
  })

  // Generate z-index variables
  Object.entries(zIndex).forEach(([key, value]) => {
    cssVars.push(`--z-index-${key}: ${value};`)
  })

  return cssVars.join('\n')
}

// vim: set ft=typescript:
