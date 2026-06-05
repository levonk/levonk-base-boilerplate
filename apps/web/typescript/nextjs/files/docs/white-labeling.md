# White Labeling System

This Next.js boilerplate includes a comprehensive white labeling system that allows you to customize branding, theming, and content for different clients or deployments.

## Overview

The white labeling system provides:

- **Dynamic Branding**: Custom logos, colors, fonts, and brand identity
- **Theme Customization**: Light/dark mode support with customizable color palettes
- **Content Management**: Navigation, footer content, and legal pages
- **Feature Toggles**: Enable/disable features per deployment
- **TypeScript Support**: Full type safety with Zod schema validation
- **Runtime Updates**: Change branding without redeploying

## Quick Start

### 1. Basic Setup

```typescript
import { setWhiteLabelConfig } from "@/lib/white-label"
import { exampleWhiteLabelConfig } from "@/lib/white-label-config.example"

// Set your custom configuration
setWhiteLabelConfig({
  brand: {
    name: "Your Company",
    logo: "/your-logo.svg",
    website: "https://yourcompany.com",
  },
  theme: {
    colors: {
      primary: "#your-brand-color",
      // ... other colors
    },
  },
  // ... rest of configuration
})
```

### 2. Provider Integration

Wrap your app with the `WhiteLabelProvider` (usually in `layout.tsx`):

```tsx
import { WhiteLabelProvider } from "@/components/providers/white-label-provider"

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html>
      <body>
        <WhiteLabelProvider>
          {children}
        </WhiteLabelProvider>
      </body>
    </html>
  )
}
```

### 3. Use White Label Components

```tsx
import { BrandLogo, Navigation, Footer } from "@/components/white-label"
import { useBrand, useTheme } from "@/components/providers/white-label-provider"

export default function Header() {
  const brand = useBrand()
  const theme = useTheme()
  
  return (
    <header>
      <Navigation />
      <BrandLogo size="md" />
      <h1 style={{ color: theme.colors.primary }}>
        {brand.name}
      </h1>
    </header>
  )
}
```

## Configuration Structure

### Brand Configuration

```typescript
brand: {
  name: string           // Company name
  logo?: string         // Path to logo image
  logoDark?: string     // Dark mode logo (optional)
  favicon?: string      // Path to favicon
  website?: string      // Company website URL
  supportEmail?: string // Support email address
}
```

### Theme Configuration

```typescript
theme: {
  colors: {
    // Light theme colors
    background: string
    foreground: string
    primary: string
    // ... more colors
    
    // Optional dark theme override
    dark?: {
      background: string
      foreground: string
      // ... dark theme colors
    }
  },
  fonts: {
    sans: string[]      // Sans-serif font stack
    mono: string[]      // Monospace font stack
  },
  borderRadius: {
    xs: string
    sm: string
    // ... more radius values
  }
}
```

### Content Configuration

```typescript
content: {
  title: string                    // Page title
  description: string              // Meta description
  navigation: Array<{
    label: string
    href: string
    external?: boolean
  }>
  footer: {
    description?: string
    copyright: string
    links?: Array<{
      label: string
      href: string
    }>
  }
}
```

### Features Configuration

```typescript
features: {
  enableAnalytics: boolean
  enableDarkMode: boolean
  enableMultiLanguage: boolean
  customComponents?: {
    header?: string      // Custom header component path
    footer?: string      // Custom footer component path
  }
}
```

## Available Hooks

The system provides several hooks for accessing white label data:

```typescript
import { 
  useWhiteLabel,    // Full configuration
  useBrand,         // Brand information only
  useTheme,         // Theme configuration only
  useContent,       // Content configuration only
  useFeatures       // Feature flags only
} from "@/components/providers/white-label-provider"

// Usage examples
const brand = useBrand()
const theme = useTheme()
const { enableDarkMode } = useFeatures()
```

## Components

### BrandLogo

Displays the company logo with fallback to text.

```tsx
<BrandLogo 
  size="sm"           // "sm" | "md" | "lg"
  variant="light"     // "light" | "dark"
  className="custom-class"
  priority={false}    // Image loading priority
/>
```

### Navigation

Renders navigation links with white label content.

```tsx
<Navigation 
  className="nav-class"
  showLogo={true}     // Show logo in navigation
  variant="header"    // "header" | "footer"
/>
```

### Footer

Displays footer with white label content and links.

```tsx
<Footer 
  className="footer-class"
  showNavigation={true}  // Show navigation in footer
  variant="full"         // "simple" | "full"
/>
```

## Token Integration

The white label system integrates with the design token system:

```typescript
import tokens, { getCSSCustomProperties } from "@/tokens"

// Tokens automatically use white label colors
const primaryColor = tokens.colors["accent.default"] // Uses white label primary

// Generate CSS variables for styling
const cssVars = getCSSCustomProperties()
// Returns: "--color-accent-default: #3b82f6; ..."
```

## Runtime Updates

You can update the white label configuration at runtime:

```typescript
import { updateWhiteLabelConfig } from "@/components/providers/white-label-provider"

function ThemeSwitcher() {
  const { updateConfig } = useWhiteLabel()
  
  const switchToDarkTheme = () => {
    updateConfig({
      theme: {
        colors: {
          // Update specific colors
          primary: "#new-color"
        }
      }
    })
  }
  
  return <button onClick={switchToDarkTheme}>Switch Theme</button>
}
```

## CSS Variables

The system automatically generates CSS custom properties:

```css
:root {
  --color-fg-primary: #0f172a;
  --color-bg-canvas: #ffffff;
  --color-accent-default: #3b82f6;
  --font-family-sans: Inter, system-ui, sans-serif;
  --radius-sm: 0.25rem;
  /* ... more variables */
}
```

Use them in your components:

```css
.my-component {
  color: var(--color-accent-default);
  border-radius: var(--radius-sm);
  font-family: var(--font-family-sans);
}
```

## Dark Mode

Dark mode is automatically supported. Provide dark theme colors in your configuration:

```typescript
theme: {
  colors: {
    primary: "#3b82f6",
    // Light theme colors...
    dark: {
      background: "#0f172a",
      foreground: "#f8fafc",
      primary: "#3b82f6",
      // Dark theme colors...
    }
  }
}
```

The system will automatically switch between light and dark colors based on the user's preference.

## Validation

All configurations are validated using Zod schemas. Invalid configurations will throw descriptive errors:

```typescript
import { WhiteLabelConfig } from "@/lib/white-label"

// TypeScript will validate your configuration
const config: WhiteLabelConfig = {
  // Invalid configuration will show type errors
  brand: {
    name: 123, // Error: Type 'number' is not assignable to type 'string'
  }
}
```

## Best Practices

### 1. Configuration Management

- Store configurations in environment-specific files
- Use environment variables for sensitive data
- Validate configurations on application start

### 2. Asset Organization

- Place logos in the `public/` directory
- Use consistent naming conventions
- Provide multiple sizes and formats for logos

### 3. Performance

- Use optimized image formats (WebP, AVIF)
- Implement lazy loading for large logos
- Cache configurations appropriately

### 4. Testing

- Test themes in both light and dark modes
- Verify responsive design with different content
- Test runtime configuration updates

## Example Implementations

### Multi-Tenant Application

```typescript
// tenant-configs.ts
export const tenantConfigs = {
  clientA: {
    brand: { name: "Client A", logo: "/client-a-logo.svg" },
    theme: { colors: { primary: "#ff6b6b" } }
  },
  clientB: {
    brand: { name: "Client B", logo: "/client-b-logo.svg" },
    theme: { colors: { primary: "#4ecdc4" } }
  }
}

// Apply tenant configuration
const tenant = getTenantFromDomain()
setWhiteLabelConfig(tenantConfigs[tenant])
```

### Dynamic Theme Loading

```typescript
// Load theme from API
async function loadThemeFromAPI(themeId: string) {
  const response = await fetch(`/api/themes/${themeId}`)
  const themeConfig = await response.json()
  setWhiteLabelConfig(themeConfig)
}
```

## Troubleshooting

### Common Issues

1. **Configuration not applying**: Ensure `WhiteLabelProvider` wraps your app
2. **Colors not updating**: Check CSS variable generation and DOM injection
3. **Type errors**: Verify your configuration matches the `WhiteLabelConfig` schema
4. **Logo not displaying**: Check file paths and ensure images exist in `public/`

### Debug Mode

Enable debug logging to troubleshoot issues:

```typescript
// Enable debug mode in development
if (process.env.NODE_ENV === 'development') {
  console.log('White Label Config:', getWhiteLabelConfig())
}
```

## Migration Guide

### From Static Theming

1. Replace static color values with white label configuration
2. Update components to use white label hooks
3. Replace hardcoded text with content configuration
4. Add `WhiteLabelProvider` to your app root

### From CSS Variables

1. Keep existing CSS variables (they're still supported)
2. Add white label configuration for dynamic updates
3. Use the `getCSSCustomProperties()` helper for consistency

## Contributing

When adding new white label features:

1. Update the Zod schema in `white-label.ts`
2. Add corresponding hooks in the provider
3. Update TypeScript types
4. Add examples to the configuration file
5. Update documentation

## License

This white labeling system is part of the Next.js boilerplate and follows the same license terms.
