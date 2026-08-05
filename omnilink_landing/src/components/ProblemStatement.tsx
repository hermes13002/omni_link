import { motion } from 'framer-motion'
import { X, ChatCircleDots, FloppyDisk, EnvelopeSimple } from '@phosphor-icons/react'
import { Section } from './ui/Section'
import { revealUp, staggerParent, viewportOnce } from '../lib/motion'

const PAIN_POINTS = [
  { Icon: ChatCircleDots, text: 'Self-DMs on WhatsApp' },
  { Icon: FloppyDisk, text: 'Slack saved messages' },
  { Icon: EnvelopeSimple, text: 'Emailing yourself' },
] as const

export default function ProblemStatement() {
  return (
    <Section dark>
      <motion.div
        className="max-w-3xl mx-auto text-center"
        initial="hidden"
        whileInView="visible"
        viewport={viewportOnce}
        variants={staggerParent}
      >
        <motion.h2
          variants={revealUp}
          className="text-headline-lg font-display text-on-surface mb-6"
        >
          Stop juggling scattered notes
        </motion.h2>
        <motion.p
          variants={revealUp}
          className="text-body-lg text-on-surface-variant mb-10"
        >
          You're already using private channels to send things to yourself. OmniLink
          replaces all of them with one universal pipeline.
        </motion.p>
        <motion.div
          variants={revealUp}
          className="flex flex-wrap justify-center gap-4"
        >
          {PAIN_POINTS.map(({ Icon, text }) => (
            <div
              key={text}
              className="relative group flex items-center gap-3 px-5 py-3 bg-glass/[0.04] backdrop-blur-[12px] border border-glass/[0.08] rounded-button"
            >
              <Icon size={20} weight="regular" className="text-on-surface-variant" />
              <span className="text-body-md text-on-surface-variant">{text}</span>
              <X
                size={16}
                weight="bold"
                className="text-error absolute -top-1 -right-1 bg-error/10 rounded-full p-0.5"
              />
            </div>
          ))}
        </motion.div>
      </motion.div>
    </Section>
  )
}
