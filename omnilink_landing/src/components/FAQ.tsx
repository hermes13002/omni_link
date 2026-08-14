import { useState } from 'react'
import { motion, AnimatePresence } from 'framer-motion'
import { CaretDown } from '@phosphor-icons/react'
import { Card } from './ui/Card'
import { Section } from './ui/Section'
import { staggerParent, revealUp, viewportOnce } from '../lib/motion'

const FAQS = [
  {
    question: 'What is OmniLink?',
    answer:
      'OmniLink is a simple way to move your text, links, photos, and files between all your devices. Instead of emailing yourself or sending messages to a private chat, you just drop it in OmniLink and it instantly appears everywhere.',
  },
  {
    question: 'What platforms are supported?',
    answer:
      'OmniLink works across all major platforms, including iPhone, Android, Mac, Windows, and directly in your web browser.',
  },
  {
    question: 'Is there a file size limit?',
    answer:
      'Yes, currently there is a 50MB limit per file upload to ensure fast and reliable syncing across all your devices.',
  },
  {
    question: 'Is my data secure?',
    answer:
      'Absolutely. We use industry-standard security and individual device secrets. Your files are securely stored, and you can delete your data at any time.',
  },
  {
    question: 'How is this different from AirDrop?',
    answer:
      'AirDrop only works between Apple devices and requires you to be physically close. OmniLink works across ANY operating system (like Mac to Android) over the cloud, no matter where your devices are located.',
  },
]

export default function FAQ() {
  const [openIndex, setOpenIndex] = useState<number | null>(null)

  return (
    <Section eyebrow="FAQ" title="Frequently Asked Questions" description="Everything you need to know about OmniLink">
      <motion.div
        className="max-w-3xl mx-auto flex flex-col gap-4"
        initial="hidden"
        whileInView="visible"
        viewport={viewportOnce}
        variants={staggerParent}
      >
        {FAQS.map((faq, index) => {
          const isOpen = openIndex === index

          return (
            <motion.div key={index} variants={revealUp}>
              <Card glass="low" className="p-0 overflow-hidden">
                <button
                  className="w-full text-left p-6 flex justify-between items-center focus:outline-none focus-visible:ring-2 focus-visible:ring-primary"
                  onClick={() => setOpenIndex(isOpen ? null : index)}
                  aria-expanded={isOpen}
                >
                  <span className="text-headline-md font-display text-on-surface text-xl">{faq.question}</span>
                  <motion.div
                    animate={{ rotate: isOpen ? 180 : 0 }}
                    transition={{ duration: 0.2, ease: 'easeInOut' }}
                    className="text-on-surface-variant shrink-0 ml-4"
                  >
                    <CaretDown size={24} weight="bold" />
                  </motion.div>
                </button>

                <AnimatePresence initial={false}>
                  {isOpen && (
                    <motion.div
                      initial={{ height: 0, opacity: 0 }}
                      animate={{ height: 'auto', opacity: 1 }}
                      exit={{ height: 0, opacity: 0 }}
                      transition={{ duration: 0.3, ease: 'easeInOut' }}
                    >
                      <div className="px-6 pb-6 text-body-md text-on-surface-variant leading-relaxed">
                        {faq.answer}
                      </div>
                    </motion.div>
                  )}
                </AnimatePresence>
              </Card>
            </motion.div>
          )
        })}
      </motion.div>
    </Section>
  )
}
