import { motion, useReducedMotion } from 'framer-motion'
import { ArrowRight, AppleLogo, AndroidLogo, WindowsLogo, Globe } from '@phosphor-icons/react'
import { Button } from './ui/Button'
import { easing, duration, STAGGER_STEP } from '../lib/motion'

const PLATFORMS = [
  { Icon: AppleLogo, label: 'iOS' },
  { Icon: AndroidLogo, label: 'Android' },
  { Icon: AppleLogo, label: 'macOS' },
  { Icon: WindowsLogo, label: 'Windows' },
  { Icon: Globe, label: 'Web' },
] as const

export function Hero() {
  const reduceMotion = useReducedMotion()

  return (
    <section className="relative min-h-[92vh] flex items-center justify-center overflow-hidden px-6 pt-28 pb-20">
      {/* Ambient light blobs — the app's own primaryGlow / tertiaryGlow constants */}
      {!reduceMotion && (
        <>
          <motion.div
            aria-hidden
            className="absolute -top-40 -right-32 w-[32rem] h-[32rem] rounded-full blur-[120px]"
            style={{ background: 'rgba(173, 198, 255, 0.20)' }}
            animate={{ x: [0, 30, 0], y: [0, 20, 0] }}
            transition={{ duration: 14, repeat: Infinity, ease: 'easeInOut' }}
          />
          <motion.div
            aria-hidden
            className="absolute -bottom-40 -left-32 w-[28rem] h-[28rem] rounded-full blur-[120px]"
            style={{ background: 'rgba(78, 222, 163, 0.10)' }}
            animate={{ x: [0, -25, 0], y: [0, -20, 0] }}
            transition={{ duration: 18, repeat: Infinity, ease: 'easeInOut' }}
          />
        </>
      )}

      <motion.div
        className="relative z-10 max-w-4xl mx-auto text-center"
        initial="hidden"
        animate="visible"
        variants={{
          hidden: {},
          visible: { transition: { staggerChildren: STAGGER_STEP, delayChildren: 0.1 } },
        }}
      >
        {/* <motion.div
          variants={{
            hidden: { opacity: 0, y: 16 },
            visible: { opacity: 1, y: 0, transition: { duration: duration.base, ease: easing.out } },
          }}
          className="inline-flex items-center gap-2 px-4 py-1.5 rounded-chip bg-glass/[0.06] backdrop-blur-[12px] border border-glass/[0.12] mb-8"
        >
          <span className="relative flex h-2 w-2">
            {!reduceMotion && (
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-tertiary opacity-75" />
            )}
            <span className="relative inline-flex rounded-full h-2 w-2 bg-tertiary" />
          </span>
          <span className="text-label-sm font-mono text-on-surface-variant">
            Real-time sync across every device
          </span>
        </motion.div> */}

        <motion.h1
          variants={{
            hidden: { opacity: 0, y: 20 },
            visible: { opacity: 1, y: 0, transition: { duration: duration.slow, ease: easing.out } },
          }}
          className="text-display-lg font-display text-on-surface mb-6"
        >
          Your digital universe,
          <br />
          <span className="text-primary-container">seamlessly organized</span>
        </motion.h1>

        <motion.p
          variants={{
            hidden: { opacity: 0, y: 16 },
            visible: { opacity: 1, y: 0, transition: { duration: duration.base, ease: easing.out } },
          }}
          className="text-body-lg text-on-surface-variant max-w-2xl mx-auto mb-10"
        >
          Stop sending files to yourself on WhatsApp. Organize with tags, sync across
          devices, and share anything instantly — from a code snippet to an APK.
        </motion.p>

        <motion.div
          variants={{
            hidden: { opacity: 0, y: 16 },
            visible: { opacity: 1, y: 0, transition: { duration: duration.base, ease: easing.out } },
          }}
          className="flex flex-col sm:flex-row gap-3 justify-center mb-14"
        >
          <Button variant="primary" icon={<ArrowRight size={18} weight="bold" />}>
            Get Started Free
          </Button>
          <Button variant="secondary" href="#how-it-works">
            See how it works
          </Button>
        </motion.div>

        <motion.div
          variants={{
            hidden: { opacity: 0 },
            visible: { opacity: 1, transition: { duration: duration.base, ease: easing.out } },
          }}
          className="flex flex-wrap items-center justify-center gap-x-8 gap-y-4"
        >
          {PLATFORMS.map(({ Icon, label }) => (
            <div key={label} className="flex items-center gap-2 text-on-surface-variant/70">
              <Icon size={18} weight="regular" />
              <span className="text-label-md font-mono">{label}</span>
            </div>
          ))}
        </motion.div>
      </motion.div>
    </section>
  )
}
