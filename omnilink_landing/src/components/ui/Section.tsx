import { motion } from 'framer-motion'
import type { ReactNode } from 'react'
import { revealUp, viewportOnce } from '../../lib/motion'

interface SectionProps {
  children: ReactNode
  eyebrow?: string
  /** Omit to render a bare section and supply your own heading in children. */
  title?: string
  description?: string
  className?: string
  dark?: boolean
}

/**
 * Shared section wrapper. Applies the skill's layout rhythm: consistent
 * vertical spacing (48px/80px section padding), readable measure, and
 * scroll-reveal animation on the header.
 */
export function Section({ children, eyebrow, title, description, className = '', dark = false }: SectionProps) {
  const bg = dark ? 'bg-surface-container-lowest' : ''

  return (
    <section className={`py-20 px-6 ${bg} ${className}`}>
      <div className="max-w-6xl mx-auto">
        {title && (
          <motion.header
            className="mb-16 text-center max-w-3xl mx-auto"
            initial="hidden"
            whileInView="visible"
            viewport={viewportOnce}
            variants={revealUp}
          >
            {eyebrow && (
              <span className="inline-block text-label-md font-mono text-primary-container mb-3 tracking-wider uppercase">
                {eyebrow}
              </span>
            )}
            <h2 className="text-headline-lg font-display text-on-surface mb-4">{title}</h2>
            {description && (
              <p className="text-body-lg text-on-surface-variant">{description}</p>
            )}
          </motion.header>
        )}
        {children}
      </div>
    </section>
  )
}
