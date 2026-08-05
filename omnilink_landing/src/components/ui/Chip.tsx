import { motion } from 'framer-motion'

interface ChipProps {
  children: React.ReactNode
  className?: string
}

export function Chip({ children, className = '' }: ChipProps) {
  return (
    <motion.span
      className={`inline-block px-4 py-1.5 rounded-chip bg-surface-container-highest border border-outline-variant/10 text-label-md font-mono text-on-surface-variant ${className}`}
      whileHover={{ scale: 1.05 }}
      transition={{ duration: 0.3 }}
    >
      {children}
    </motion.span>
  )
}
