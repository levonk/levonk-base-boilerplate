"use client"

import * as React from "react"
import Image from "next/image"
import { useBrand } from "@/components/providers/white-label-provider"

interface BrandLogoProps {
  className?: string
  size?: "sm" | "md" | "lg"
  variant?: "light" | "dark"
  priority?: boolean
}

export function BrandLogo({ 
  className = "", 
  size = "md", 
  variant = "light",
  priority = false 
}: BrandLogoProps) {
  const brand = useBrand()
  
  const sizeClasses = {
    sm: "h-8 w-auto",
    md: "h-10 w-auto", 
    lg: "h-12 w-auto"
  }
  
  const logoSrc = variant === "dark" && brand.logoDark 
    ? brand.logoDark 
    : brand.logo

  if (!logoSrc) {
    // Fallback to text logo if no image provided
    return (
      <div className={`${sizeClasses[size]} flex items-center justify-center font-bold text-primary ${className}`}>
        {brand.name}
      </div>
    )
  }

  return (
    <div className={`relative ${sizeClasses[size]} ${className}`}>
      <Image
        src={logoSrc}
        alt={`${brand.name} logo`}
        fill
        className="object-contain"
        priority={priority}
      />
    </div>
  )
}
