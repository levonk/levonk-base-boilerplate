"use client"

import * as React from "react"
import Link from "next/link"
import { useContent, useBrand } from "@/components/providers/white-label-provider"
import { Navigation } from "./navigation"
import { cn } from "@/lib/utils"

interface FooterProps {
  className?: string
  showNavigation?: boolean
  variant?: "simple" | "full"
}

export function Footer({ className, showNavigation = true, variant = "full" }: FooterProps) {
  const { footer } = useContent()
  const brand = useBrand()
  
  if (variant === "simple") {
    return (
      <footer className={cn("border-t py-6", className)}>
        <div className="container mx-auto px-4">
          <p className="text-center text-sm text-muted-foreground">
            {footer.copyright}
          </p>
        </div>
      </footer>
    )
  }
  
  return (
    <footer className={cn("border-t bg-background", className)}>
      <div className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          {/* Brand Section */}
          <div className="space-y-4">
            <div className="flex items-center gap-2">
              <span className="font-semibold text-lg">{brand.name}</span>
            </div>
            <p className="text-sm text-muted-foreground max-w-xs">
              {footer.description || "Building amazing experiences with modern technology."}
            </p>
          </div>
          
          {/* Navigation Links */}
          {showNavigation && (
            <div className="space-y-4">
              <h3 className="font-semibold text-sm">Quick Links</h3>
              <Navigation variant="footer" className="flex-col gap-2" />
            </div>
          )}
          
          {/* Legal/Additional Links */}
          {footer.links && footer.links.length > 0 && (
            <div className="space-y-4">
              <h3 className="font-semibold text-sm">Legal</h3>
              <nav className="flex flex-col gap-2">
                {footer.links.map((link, index) => (
                  <Link
                    key={index}
                    href={link.href}
                    target={link.href.startsWith('http') ? "_blank" : undefined}
                    rel={link.href.startsWith('http') ? "noopener noreferrer" : undefined}
                    className="text-sm text-muted-foreground hover:text-foreground transition-colors"
                  >
                    {link.label}
                  </Link>
                ))}
              </nav>
            </div>
          )}
        </div>
        
        {/* Copyright */}
        <div className="mt-8 pt-8 border-t">
          <p className="text-center text-sm text-muted-foreground">
            {footer.copyright}
          </p>
        </div>
      </div>
    </footer>
  )
}
