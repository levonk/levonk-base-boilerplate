"use client"

import * as React from "react"
import { getWhiteLabelConfig, generateCSSVariables, type WhiteLabelConfig } from "@/lib/white-label"

interface WhiteLabelProviderProps {
  children: React.ReactNode
  config?: Partial<WhiteLabelConfig>
}

export function WhiteLabelProvider({ children, config }: WhiteLabelProviderProps) {
  const [currentConfig, setCurrentConfig] = React.useState<WhiteLabelConfig>(() => {
    if (config) {
      const baseConfig = getWhiteLabelConfig()
      return {
        ...baseConfig,
        ...config,
        brand: { ...baseConfig.brand, ...config.brand },
        theme: {
          ...baseConfig.theme,
          ...config.theme,
          colors: { ...baseConfig.theme.colors, ...config.theme?.colors },
          fonts: { ...baseConfig.theme.fonts, ...config.theme?.fonts },
          borderRadius: { ...baseConfig.theme.borderRadius, ...config.theme?.borderRadius },
        },
        content: {
          ...baseConfig.content,
          ...config.content,
          footer: { ...baseConfig.content.footer, ...config.content?.footer },
          navigation: config.content?.navigation || baseConfig.content.navigation,
        },
        features: { ...baseConfig.features, ...config.features },
      }
    }
    return getWhiteLabelConfig()
  })

  // Update CSS variables when config changes
  React.useEffect(() => {
    const root = document.documentElement
    const cssVars = generateCSSVariables(currentConfig)
    
    // Create a style element for the CSS variables
    let styleElement = document.getElementById('white-label-styles')
    if (!styleElement) {
      styleElement = document.createElement('style')
      styleElement.id = 'white-label-styles'
      document.head.appendChild(styleElement)
    }
    
    styleElement.textContent = `:root { ${cssVars} }`
    
    // Update document title and meta
    if (typeof window !== 'undefined') {
      document.title = currentConfig.content.title
      
      // Update or create meta description
      let metaDescription = document.querySelector('meta[name="description"]') as HTMLMetaElement
      if (!metaDescription) {
        metaDescription = document.createElement('meta')
        metaDescription.name = 'description'
        document.head.appendChild(metaDescription)
      }
      metaDescription.content = currentConfig.content.description
      
      // Update favicon if provided
      if (currentConfig.brand.favicon) {
        let favicon = document.querySelector('link[rel="icon"]') as HTMLLinkElement
        if (!favicon) {
          favicon = document.createElement('link')
          favicon.rel = 'icon'
          document.head.appendChild(favicon)
        }
        favicon.href = currentConfig.brand.favicon
      }
    }
  }, [currentConfig])

  // Update config function
  const updateConfig = React.useCallback((newConfig: Partial<WhiteLabelConfig>) => {
    setCurrentConfig(prev => ({
      ...prev,
      ...newConfig,
      brand: { ...prev.brand, ...newConfig.brand },
      theme: {
        ...prev.theme,
        ...newConfig.theme,
        colors: { ...prev.theme.colors, ...newConfig.theme?.colors },
        fonts: { ...prev.theme.fonts, ...newConfig.theme?.fonts },
        borderRadius: { ...prev.theme.borderRadius, ...newConfig.theme?.borderRadius },
      },
      content: {
        ...prev.content,
        ...newConfig.content,
        footer: { ...prev.content.footer, ...newConfig.content?.footer },
        navigation: newConfig.content?.navigation || prev.content.navigation,
      },
      features: { ...prev.features, ...newConfig.features },
    }))
  }, [])

  const contextValue = React.useMemo(() => ({
    config: currentConfig,
    updateConfig,
  }), [currentConfig, updateConfig])

  return (
    <WhiteLabelContext.Provider value={contextValue}>
      {children}
    </WhiteLabelContext.Provider>
  )
}

const WhiteLabelContext = React.createContext<{
  config: WhiteLabelConfig
  updateConfig: (config: Partial<WhiteLabelConfig>) => void
} | null>(null)

export function useWhiteLabel() {
  const context = React.useContext(WhiteLabelContext)
  if (!context) {
    throw new Error("useWhiteLabel must be used within a WhiteLabelProvider")
  }
  return context
}

// Export individual hooks for convenience
export function useBrand() {
  const { config } = useWhiteLabel()
  return config.brand
}

export function useTheme() {
  const { config } = useWhiteLabel()
  return config.theme
}

export function useContent() {
  const { config } = useWhiteLabel()
  return config.content
}

export function useFeatures() {
  const { config } = useWhiteLabel()
  return config.features
}
