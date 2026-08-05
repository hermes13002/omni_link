import { motion } from 'framer-motion'
import { Tag, PushPin, MagnifyingGlass, Funnel } from '@phosphor-icons/react'
import { Card } from './ui/Card'
import { Section } from './ui/Section'
import { staggerParent, revealUp, viewportOnce } from '../lib/motion'

const FEATURES = [
  {
    Icon: Tag,
    title: 'Tags',
    description: 'Smart organization for your content with color-coded tags',
  },
  {
    Icon: PushPin,
    title: 'Pinning',
    description: 'Keep important items at the top of your timeline',
  },
  {
    Icon: MagnifyingGlass,
    title: 'Search',
    description: 'Full-text search across all your synced content',
  },
  {
    Icon: Funnel,
    title: 'Filter by Type',
    description: 'Quickly filter by text, media, code, or documents',
  },
] as const

export default function Organization() {
  return (
    <Section
      dark
      eyebrow="Organization"
      title="Find what you need, when you need it"
      description="Tags, pinning, search, and filters , built so retrieval never blocks creation."
    >
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
