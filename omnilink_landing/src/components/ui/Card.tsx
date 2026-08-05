import { motion } from 'framer-motion'
import type { ReactNode } from 'react'
import { easing, duration } from '../../lib/motion'

interface CardProps {
  children: ReactNode
  className?: string
  hover?: boolean
  /** Glass intensity , 'low' for dense grids, 'high' for feature panels */
  glass?: 'low' | 'high'
}

/**
 * Glassmorphic surface. Depth comes from layered translucency + backdrop blur
 * rather than drop shadows, matching the Flutter app's flat elevation model.
 *
 * Tint uses the --glass-tint token (white in dark mode, near-black in light)
 * so panels stay legible in both themes.
 */
export function Card({ children, className = '', hover = false, glass = 'low' }: CardProps) {
  const intensity = {
    low: 'bg-glass/[0.04] backdrop-blur-[12px] border-glass/[0.08]',
    high: 'bg-glass/[0.07] backdrop-blur-glass border-glass/[0.12]',
  }

  const base = `relative overflow-hidden rounded-card border p-6 ${intensity[glass]}`

  if (!hover) {
    return <div className={`${base} ${className}`}>{children}</div>
  }

  return (
    <motion.div
      className={`${base} ${className} group`}
      whileHover={{ y: -4 }}
      transition={{ duration: duration.fast, ease: easing.inOut }}
    >
      {/* Specular highlight , the light-source cue that makes glass read as glass */}
      <div
        className="pointer-events-none absolute inset-0 opacity-0 transition-opacity duration-300 group-hover:opacity-100"
        style={{
          background:
            'linear-gradient(135deg, rgb(var(--glass-tint) / 0.10) 0%, transparent 55%)',
        }}
      />
      {/* Border brightening on hover , no layout shift */}
      <div className="pointer-events-none absolute inset-0 rounded-card border border-transparent transition-colors duration-300 group-hover:border-primary-container/25" />
      <div className="relative">{children}</div>
    </motion.div>
  )
}
