import { motion } from 'framer-motion'

interface GlowBackdropProps {
  variant: 'primary' | 'tertiary'
  className?: string
}

export function GlowBackdrop({ variant, className = '' }: GlowBackdropProps) {
  const colorClass = variant === 'primary' ? 'bg-primary-glow' : 'bg-tertiary-glow'

  return (
    <motion.div
      className={`absolute rounded-full blur-3xl ${colorClass} ${className}`}
      animate={{
        x: [0, 10, 0],
        y: [0, 10, 0],
      }}
      transition={{
        duration: 8,
        repeat: Infinity,
        ease: 'easeInOut',
      }}
    />
  )
}
