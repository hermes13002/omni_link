import { motion } from 'framer-motion'
import { Lock, Key, Cloud, Trash } from '@phosphor-icons/react'
import { Card } from './ui/Card'
import { Section } from './ui/Section'
import { staggerParent, revealUp, viewportOnce } from '../lib/motion'

const FEATURES = [
  {
    Icon: Lock,
    title: 'JWT Authentication',
    description: 'Industry-standard token-based auth with refresh tokens',
  },
  {
    Icon: Key,
    title: 'Device Secrets',
    description: 'Each device gets its own secret for secure streaming',
  },
  {
    Icon: Cloud,
    title: 'Cloud Storage',
    description: 'Files stored securely on Google Cloud Storage',
  },
  {
    Icon: Trash,
    title: 'Account Deletion',
    description: 'Full control , delete your account and data anytime',
  },
] as const

export default function Security() {
  return (
    <Section eyebrow="Security" title="Built with security in mind" description="Your data, your control">
      <motion.div
        className="grid md:grid-cols-2 lg:grid-cols-4 gap-5"
        initial="hidden"
        whileInView="visible"
        viewport={viewportOnce}
        variants={staggerParent}
      >
        {FEATURES.map(({ Icon, title, description }) => (
          <motion.div key={title} variants={revealUp}>
            <Card glass="low" className="text-center h-full">
              <div className="w-12 h-12 mx-auto mb-4 rounded-xl bg-primary-container/10 border border-primary-container/20 flex items-center justify-center">
                <Icon size={24} weight="regular" className="text-primary-container" />
              </div>
              <h3 className="text-headline-md font-display text-on-surface mb-2">{title}</h3>
              <p className="text-body-md text-on-surface-variant">{description}</p>
            </Card>
          </motion.div>
        ))}
      </motion.div>
    </Section>
  )
}
