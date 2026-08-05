import { motion } from 'framer-motion'
import type { ReactNode } from 'react'
import { easing, duration } from '../../lib/motion'

interface ButtonProps {
  children: ReactNode
  variant?: 'primary' | 'secondary' | 'ghost'
  href?: string
  className?: string
  icon?: ReactNode
}

/**
 * Press feedback uses scale only , never layout properties , so hover/press
 * cannot shift surrounding content (skill rule: stable-interaction-states).
 */
export function Button({ children, variant = 'primary', href = '#', className = '', icon }: ButtonProps) {
  const variants = {
    primary:
      'bg-primary text-on-primary hover:bg-primary-container border border-transparent',
    secondary:
      'bg-glass/[0.06] backdrop-blur-[12px] text-on-surface border border-glass/[0.12] hover:bg-glass/[0.10] hover:border-glass/20',
    ghost:
      'bg-transparent text-on-surface-variant border border-transparent hover:text-on-surface',
  }

  return (
    <motion.a
      href={href}
      className={`inline-flex items-center justify-center gap-2 px-6 py-3 rounded-button text-body-md font-medium cursor-pointer transition-colors duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-container focus-visible:ring-offset-2 focus-visible:ring-offset-surface ${variants[variant]} ${className}`}
      whileHover={{ scale: 1.02 }}
      whileTap={{ scale: 0.98 }}
      transition={{ duration: duration.fast, ease: easing.inOut }}
    >
      {children}
      {icon}
    </motion.a>
  )
}
