import { motion } from 'framer-motion'
import type { ReactNode } from 'react'
import { useEffect, useState } from 'react'

interface BackgroundProps {
  children: ReactNode
}

/**
 * Animated grid background. A subtle, pulsing grid that adds a premium
 * technical feel without distracting from the content.
 */
export function AnimatedBackground({ children }: BackgroundProps) {
  const [mounted, setMounted] = useState(false)

  useEffect(() => {
    setMounted(true)
  }, [])

  return (
    <div className="relative">
      {/* Grid background */}
      <div className="fixed inset-0 pointer-events-none z-0 flex justify-center overflow-hidden">
        <svg className="absolute inset-0 h-full w-full" xmlns="http://www.w3.org/2000/svg">
          <defs>
            <pattern id="grid-pattern" width="48" height="48" patternUnits="userSpaceOnUse">
              <path d="M 48 0 L 0 0 0 48" fill="none" stroke="currentColor" strokeWidth="1" className="text-on-surface opacity-[0.05]" />
            </pattern>
            
            {/* Gradients for pulsing lines */}
            <linearGradient id="glow-line-horizontal" x1="0%" y1="0%" x2="100%" y2="0%">
              <stop offset="0%" stopColor="rgb(var(--primary))" stopOpacity="0" />
              <stop offset="50%" stopColor="rgb(var(--primary))" stopOpacity="0.8" />
              <stop offset="100%" stopColor="rgb(var(--primary))" stopOpacity="0" />
            </linearGradient>
            <linearGradient id="glow-line-vertical" x1="0%" y1="0%" x2="0%" y2="100%">
              <stop offset="0%" stopColor="rgb(var(--primary))" stopOpacity="0" />
              <stop offset="50%" stopColor="rgb(var(--primary))" stopOpacity="0.8" />
              <stop offset="100%" stopColor="rgb(var(--primary))" stopOpacity="0" />
            </linearGradient>
          </defs>

          {/* Base grid */}
          <rect width="100%" height="100%" fill="url(#grid-pattern)" />

          {/* Pulsing lines - only render after mount to avoid hydration mismatch if needed, though SVGs with framer-motion are usually fine. */}
          {mounted && (
            <>
              <motion.line
                x1="0"
                y1="144"
                x2="100%"
                y2="144"
                stroke="url(#glow-line-horizontal)"
                strokeWidth="1"
                initial={{ opacity: 0 }}
                animate={{ opacity: [0, 1, 0] }}
                transition={{ duration: 6, repeat: Infinity, ease: 'easeInOut', delay: 1 }}
              />
              
              <motion.line
                x1="0"
                y1="432"
                x2="100%"
                y2="432"
                stroke="url(#glow-line-horizontal)"
                strokeWidth="1"
                initial={{ opacity: 0 }}
                animate={{ opacity: [0, 0.8, 0] }}
                transition={{ duration: 8, repeat: Infinity, ease: 'easeInOut', delay: 3 }}
              />

              <motion.line
                x1="288"
                y1="0"
                x2="288"
                y2="100%"
                stroke="url(#glow-line-vertical)"
                strokeWidth="1"
                initial={{ opacity: 0 }}
                animate={{ opacity: [0, 1, 0] }}
                transition={{ duration: 7, repeat: Infinity, ease: 'easeInOut', delay: 2 }}
              />
              
              <motion.line
                x1="768"
                y1="0"
                x2="768"
                y2="100%"
                stroke="url(#glow-line-vertical)"
                strokeWidth="1"
                initial={{ opacity: 0 }}
                animate={{ opacity: [0, 0.6, 0] }}
                transition={{ duration: 9, repeat: Infinity, ease: 'easeInOut', delay: 0.5 }}
              />
            </>
          )}
        </svg>
      </div>

      {/* Children content wrapper */}
      <div className="relative z-10">
        {children}
      </div>
    </div>
  )
}
