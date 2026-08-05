import { motion } from 'framer-motion'
import { Files, Lightning, DeviceMobileSpeaker } from '@phosphor-icons/react'
import { Card } from './ui/Card'
import { Section } from './ui/Section'
import { staggerParent, revealUp, viewportOnce } from '../lib/motion'

const PILLARS = [
  {
    Icon: Files,
    title: 'Multi-Format Files & Links',
    description:
      'Text, images, videos, code, APKs, documents , OmniLink handles anything you throw at it.',
  },
  {
    Icon: Lightning,
    title: 'Instant Real-Time Stream',
    description:
      'Drop a file on one device and watch it appear on all others within milliseconds via SSE + Redis pub/sub.',
  },
  {
    Icon: DeviceMobileSpeaker,
    title: 'Multiple Device Types Connected',
    description:
      'Your entire device topography , phones, laptops, desktops across iOS, Android, macOS, Windows, and web.',
  },
] as const

export function Pillars() {
  return (
    <Section
      eyebrow="Core Pillars"
      title="Built for speed, flexibility, and true cross-platform sync"
    >
      <motion.div
        className="grid md:grid-cols-3 gap-6"
        initial="hidden"
        whileInView="visible"
        viewport={viewportOnce}
        variants={staggerParent}
      >
        {PILLARS.map(({ Icon, title, description }, i) => (
          <motion.div key={i} variants={revealUp}>
            <Card hover glass="high" className="h-full">
              <div className="w-14 h-14 rounded-xl bg-primary-container/10 border border-primary-container/20 flex items-center justify-center mb-4">
                <Icon size={28} weight="regular" className="text-primary-container" />
              </div>
              <h3 className="text-headline-md font-display text-on-surface mb-3">{title}</h3>
              <p className="text-body-md text-on-surface-variant">{description}</p>
            </Card>
          </motion.div>
        ))}
      </motion.div>
    </Section>
  )
}
