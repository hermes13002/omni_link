import { motion } from 'framer-motion'
import type { ReactNode } from 'react'

interface BackgroundProps {
  children: ReactNode
}

/**
 * Animated dot grid background. Subtle data-pipeline aesthetic — a field of
 * dots that pulse and shimmer, suggesting a distributed network without
 * competing with foreground content.
 */
export function AnimatedBackground({ children }: BackgroundProps) {
  // 20x12 grid of dots, evenly spaced
  const cols = 20
  const rows = 12
  const dots = Array.from({ length: cols * rows }, (_, i) => ({
    id: i,
    col: i % cols,
    row: Math.floor(i / cols),
  }))

  return (
    <div className="relative">
      {/* Dot grid */}
      <div className="fixed inset-0 pointer-events-none overflow-hidden opacity-[0.15]">
        <svg className="w-full h-full" preserveAspectRatio="xMidYMid slice">
          <defs>
            <radialGradient id="dotGrad">
              <stop offset="0%" stopColor="rgb(var(--primary-container))" stopOpacity="1" />
              <stop offset="100%" stopColor="rgb(var(--primary-container))" stopOpacity="0" />
            </radialGradient>
          </defs>
          {dots.map(({ id, col, row }) => {
            const x = ((col + 0.5) / cols) * 100
            const y = ((row + 0.5) / rows) * 100
            const delay = (col * 0.08 + row * 0.12) % 3

            return (
              <motion.circle
                key={id}
                cx={`${x}%`}
                cy={`${y}%`}
                r="1.5"
                fill="url(#dotGrad)"
                initial={{ opacity: 0.3, scale: 1 }}
                animate={{
                  opacity: [0.3, 0.7, 0.3],
                  scale: [1, 1.4, 1],
                }}
                transition={{
                  duration: 4,
                  repeat: Infinity,
                  delay,
                  ease: 'easeInOut',
                }}
              />
            )
          })}
        </svg>
      </div>

      {children}
    </div>
  )
}
