import { useState, useEffect } from 'react'
import { motion } from 'framer-motion'
import { Sun, Moon } from '@phosphor-icons/react'
import { useTheme } from '../lib/theme'
import { Button } from './ui/Button'
import { easing, duration } from '../lib/motion'

export default function Nav() {
  const { theme, toggleTheme } = useTheme()
  const [scrolled, setScrolled] = useState(false)

  useEffect(() => {
    const handleScroll = () => setScrolled(window.scrollY > 60)
    window.addEventListener('scroll', handleScroll)
    return () => window.removeEventListener('scroll', handleScroll)
  }, [])

  return (
    <motion.nav
      className={`fixed top-0 left-0 right-0 z-50 transition-all ${
        scrolled
          ? 'bg-surface-container-low/60 backdrop-blur-glass border-b border-glass/[0.08]'
          : 'bg-transparent'
      }`}
      initial={{ y: -80 }}
      animate={{ y: 0 }}
      transition={{ duration: duration.slow, ease: easing.out }}
    >
      <div className="max-w-7xl mx-auto px-6 h-20 flex items-center justify-between">
        <div className="flex items-center gap-3">
          <img src="/logo.png" alt="OmniLink" className="h-8 w-8" />
          <span className="text-headline-md font-display text-primary-container">OmniLink</span>
        </div>

        <div className="hidden md:flex items-center gap-8">
          <a
            href="#features"
            className="text-body-md text-on-surface-variant hover:text-primary transition-colors duration-200"
          >
            Features
          </a>
          <a
            href="#file-types"
            className="text-body-md text-on-surface-variant hover:text-primary transition-colors duration-200"
          >
            File Types
          </a>
          <a
            href="#how-it-works"
            className="text-body-md text-on-surface-variant hover:text-primary transition-colors duration-200"
          >
            How It Works
          </a>
        </div>

        <div className="flex items-center gap-3">
          <motion.button
            onClick={toggleTheme}
            className="p-2.5 rounded-button bg-glass/[0.04] border border-glass/[0.08] text-on-surface-variant hover:text-primary hover:bg-glass/[0.08] transition-colors duration-200 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-container"
            aria-label={`Switch to ${theme === 'dark' ? 'light' : 'dark'} mode`}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            transition={{ duration: duration.fast, ease: easing.inOut }}
          >
            {theme === 'dark' ? <Sun size={18} weight="regular" /> : <Moon size={18} weight="regular" />}
          </motion.button>
          <Button variant="primary">Get Started</Button>
        </div>
      </div>
    </motion.nav>
  )
}
