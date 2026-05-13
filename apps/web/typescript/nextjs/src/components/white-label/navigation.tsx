"use client"

import * as React from "react"
import Link from "next/link"
import { useContent, useBrand } from "@/components/providers/white-label-provider"
import { BrandLogo } from "./brand-logo"
import { Button } from "@/components/ui/button"
import { cn } from "@/lib/utils"

interface NavigationProps {
  className?: string
  showLogo?: boolean
  variant?: "header" | "footer"
}

export function Navigation({ className, showLogo = true, variant = "header" }: NavigationProps) {
  const { navigation } = useContent()
  const brand = useBrand()
  
  if (variant === "footer") {
    return (
      <nav className={cn("flex flex-wrap gap-6", className)}>
        {navigation.map((item, index) => (
          <Link
            key={index}
            href={item.href}
            target={item.external ? "_blank" : undefined}
            rel={item.external ? "noopener noreferrer" : undefined}
            className="text-sm text-muted-foreground hover:text-foreground transition-colors"
          >
            {item.label}
          </Link>
        ))}
      </nav>
    )
  }
  
  return (
    <nav className={cn("flex items-center gap-6", className)}>
      {showLogo && (
        <Link href="/" className="flex items-center gap-2">
          <BrandLogo size="sm" />
          <span className="font-semibold text-lg">{brand.name}</span>
        </Link>
      )}
      
      <div className="flex items-center gap-6">
        {navigation.map((item, index) => (
          <Link
            key={index}
            href={item.href}
            target={item.external ? "_blank" : undefined}
            rel={item.external ? "noopener noreferrer" : undefined}
            className="text-sm font-medium text-muted-foreground hover:text-foreground transition-colors"
          >
            {item.label}
          </Link>
        ))}
      </div>
    </nav>
  )
}

interface MobileNavigationProps {
  className?: string
  isOpen: boolean
  onClose: () => void
}

export function MobileNavigation({ className, isOpen, onClose }: MobileNavigationProps) {
  const { navigation } = useContent()
  const brand = useBrand()
  
  if (!isOpen) return null
  
  return (
    <div className={cn("fixed inset-0 z-50 bg-background md:hidden", className)}>
      <div className="fixed inset-0 bg-black/50" onClick={onClose} />
      <div className="fixed right-0 top-0 h-full w-full max-w-sm bg-background p-6 shadow-lg">
        <div className="flex items-center justify-between mb-8">
          <div className="flex items-center gap-2">
            <BrandLogo size="sm" />
            <span className="font-semibold text-lg">{brand.name}</span>
          </div>
          <Button variant="ghost" size="sm" onClick={onClose}>
            <svg className="h-4 w-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M6 18L18 6M6 6l12 12" />
            </svg>
          </Button>
        </div>
        
        <nav className="flex flex-col gap-4">
          {navigation.map((item, index) => (
            <Link
              key={index}
              href={item.href}
              target={item.external ? "_blank" : undefined}
              rel={item.external ? "noopener noreferrer" : undefined}
              className="text-sm font-medium text-muted-foreground hover:text-foreground transition-colors py-2"
              onClick={onClose}
            >
              {item.label}
            </Link>
          ))}
        </nav>
      </div>
    </div>
  )
}
