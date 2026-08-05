import { motion } from 'framer-motion'
import type { ReactNode } from 'react'

interface BackgroundProps {
  children: ReactNode
}

/**
 * Animated grid background. Subtle data-pipeline aesthetic , moving grid
 * lines that suggest network topology without competing with foreground
 * content for attention.
 */
export function AnimatedBackground({ children }: BackgroundProps) {
  return (
    <div className="relative">
      {/* Grid lines */}
      <div className="fixed inset-0 pointer-events-none overflow-hidden opacity-[0.015]">
        <svg className="w-full h-full">
          <defs>
            <pattern id="grid" width="40" height="40" patternUnits="userSpaceOnUse">
              <motion.path
                d="M 40 0 L 0 0 0 40"
                fill="none"
                stroke="white"
                strokeWidth="0.5"
                initial={{ opacity: 0.3 }}
                animate={{ opacity: [0.3, 0.6, 0.3] }}
                transition={{ duration: 4, repeat: Infinity, ease: 'easeInOut' }}
              />
            </pattern>
          </defs>
          <rect width="100%" height="100%" fill="url(#grid)" />
        </svg>
      </div>

      {/* Floating particles */}
      <div className="fixed inset-0 pointer-events-none overflow-hidden">
        {Array.from({ length: 12 }).map((_, i) => (
          <motion.div
            key={i}
            className="absolute w-1 h-1 bg-primary-container/20 rounded-full"
            style={{
              left: `${(i * 8 + 10) % 100}%`,
              top: `${(i * 13 + 5) % 100}%`,
            }}
            animate={{
              y: [0, -30, 0],
              x: [0, Math.sin(i) * 20, 0],
              opacity: [0, 0.4, 0],
            }}
            transition={{
              duration: 8 + i * 0.5,
              repeat: Infinity,
              delay: i * 0.7,
              ease: 'easeInOut',
            }}
          />
        ))}
      </div>

      {children}
    </div>
  )
}
