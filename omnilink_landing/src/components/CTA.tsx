import { motion } from 'framer-motion'
import { ArrowRight } from '@phosphor-icons/react'
import { Button } from './ui/Button'
import { revealUp, viewportOnce } from '../lib/motion'

export default function CTA() {
  return (
    <section className="py-32 px-6 relative overflow-hidden">
      <motion.div
        aria-hidden
        className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[36rem] h-[36rem] rounded-full blur-[140px]"
        style={{ background: 'rgba(173, 198, 255, 0.16)' }}
        animate={{ scale: [1, 1.08, 1] }}
        transition={{ duration: 8, repeat: Infinity, ease: 'easeInOut' }}
      />

      <motion.div
        className="max-w-4xl mx-auto text-center relative z-10"
        initial="hidden"
        whileInView="visible"
        viewport={viewportOnce}
        variants={revealUp}
      >
        <h2 className="text-display-lg font-display text-on-surface mb-6">
          Ready to sync your digital life?
        </h2>
        <p className="text-body-lg text-on-surface-variant mb-10 max-w-2xl mx-auto">
          Join thousands who've replaced scattered notes with one universal pipeline.
          Start free on all platforms.
        </p>
        <Button variant="primary" href="https://omnilink-frontend.onrender.com" icon={<ArrowRight size={18} weight="bold" />}>
          Get Started Free
        </Button>
      </motion.div>
    </section>
  )
}
