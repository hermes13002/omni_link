import { motion } from 'framer-motion'
import { Card } from './ui/Card'
import { Section } from './ui/Section'
import { STAGGER_STEP, revealUp, viewportOnce } from '../lib/motion'
import { FILE_TYPE_GROUPS } from '../data/fileTypes'

/**
 * Masonry layout matching the Flutter timeline pattern: columns auto-fit
 * at 320px max width, 24px gaps. Items of varying height stack vertically
 * within columns, letting shorter cards fill the visual rhythm naturally.
 */
export function FileTypeShowcase() {
  return (
    <Section
      eyebrow="Universal Pipeline"
      title="Handles literally everything"
      description="Text, images, code, APKs, documents , your universal pipeline accepts any file type without an allowlist to fight with."
      dark
    >
      <motion.div
        className="masonry-grid"
        initial="hidden"
        whileInView="visible"
        viewport={viewportOnce}
        transition={{ staggerChildren: STAGGER_STEP }}
      >
        {FILE_TYPE_GROUPS.map((group, i) => (
          <motion.div key={i} variants={revealUp} className="masonry-item">
            <Card hover glass="high" className="h-full">
              <div className="flex items-start gap-4 mb-4">
                <div className="w-12 h-12 rounded-full bg-primary-container/10 border border-primary-container/20 flex items-center justify-center flex-shrink-0">
                  <group.Icon size={24} weight="regular" className="text-primary-container" />
                </div>
                <div>
                  <h3 className="text-headline-md font-display text-on-surface mb-2">
                    {group.name}
                  </h3>
                  <p className="text-body-md text-on-surface-variant">{group.description}</p>
                </div>
              </div>
              <div className="flex flex-wrap gap-2 mt-4">
                {group.items.map((item, j) => (
                  <div
                    key={j}
                    className="inline-flex items-center gap-2 px-3 py-1.5 rounded-chip bg-surface-container-highest/50 border border-outline-variant/10"
                  >
                    <item.Icon size={14} weight="regular" className="text-on-surface-variant" />
                    <span className="text-label-sm font-mono text-on-surface-variant">
                      {item.label}
                    </span>
                  </div>
                ))}
              </div>
            </Card>
          </motion.div>
        ))}
      </motion.div>
    </Section>
  )
}
