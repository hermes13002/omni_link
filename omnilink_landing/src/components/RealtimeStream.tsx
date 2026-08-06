import { forwardRef, useRef, type ReactNode } from 'react'
import { motion, useReducedMotion } from 'framer-motion'
import {
  AppleLogo,
  DeviceMobile,
  DeviceTablet,
  Laptop,
  WindowsLogo,
} from '@phosphor-icons/react'

import { cn } from '@/lib/utils'
import { AnimatedBeam } from './ui/animated-beam'
import { Section } from './ui/Section'

/** Glass pill holding a device icon plus its name. */
const DeviceNode = forwardRef<
  HTMLDivElement,
  { className?: string; children: ReactNode; label: string }
>(({ className, children, label }, ref) => (
  <div className="flex flex-col items-center gap-2">
    <div
      ref={ref}
      className={cn(
        'z-10 flex size-12 items-center justify-center rounded-full',
        'bg-surface-container-low border border-glass/[0.14] text-on-surface',
        'shadow-[0_0_24px_-10px_rgba(0,0,0,0.9)]',
        className,
      )}
    >
      {children}
    </div>
    <span className="text-label-sm font-mono text-on-surface-variant whitespace-nowrap">
      {label}
    </span>
  </div>
))
DeviceNode.displayName = 'DeviceNode'

export function RealtimeStream() {
  const reduceMotion = useReducedMotion()

  const containerRef = useRef<HTMLDivElement>(null)
  const macbookRef = useRef<HTMLDivElement>(null)
  const iphoneRef = useRef<HTMLDivElement>(null)
  const androidRef = useRef<HTMLDivElement>(null)
  const windowsRef = useRef<HTMLDivElement>(null)
  const ipadRef = useRef<HTMLDivElement>(null)
  const hubRef = useRef<HTMLDivElement>(null)

  // Circular layout radius (adjust for responsiveness if needed, but 160 works well on most screens)
  const radius = 160

  // Random delays to make the pulsing sequence random instead of sequential
  // Devices placed around the circle (angles in degrees).
  const sources = [
    { ref: macbookRef, label: 'MacBook Pro', icon: <Laptop size={22} weight="regular" />, angle: -90, delay: 1.2 },
    { ref: iphoneRef, label: 'iPhone', icon: <AppleLogo size={22} weight="regular" />, angle: -18, delay: 0.3 },
    { ref: androidRef, label: 'Android', icon: <DeviceMobile size={22} weight="regular" />, angle: 54, delay: 2.8 },
    { ref: windowsRef, label: 'Windows PC', icon: <WindowsLogo size={22} weight="regular" />, angle: 126, delay: 0.9 },
    { ref: ipadRef, label: 'iPad', icon: <DeviceTablet size={22} weight="regular" />, angle: 198, delay: 2.1 },
  ]

  return (
    <Section
      eyebrow="Real-time"
      title="Every device, one stream"
      description="Copy on your laptop. It's on your phone before you reach for it. A persistent SSE connection per device, fanned out from a single Redis multiplexer."
    >
      <div
        ref={containerRef}
        className="relative mx-auto flex h-[500px] w-full max-w-3xl items-center justify-center overflow-visible px-2 py-10 sm:px-6"
      >
        {/* Sync hub — pulses */}
        <div className="absolute z-20 flex flex-col items-center gap-2">
          <motion.div
            ref={hubRef}
            className="flex size-16 items-center justify-center rounded-full border border-primary-container/40 bg-surface-container text-primary-container shadow-[0_0_40px_-8px_rgba(173,198,255,0.55)]"
            animate={reduceMotion ? undefined : { scale: [1, 0.92, 1.04, 1] }}
            transition={{ duration: 0.8, repeat: Infinity, repeatDelay: 0, ease: 'easeInOut' }}
          >
            <img src="/logo.png" alt="" className="size-8 object-contain" />
          </motion.div>
          <span className="text-label-sm font-mono text-primary-container whitespace-nowrap">
            OmniLink
          </span>
        </div>

        {/* Sending devices arranged in a circle */}
        {sources.map((source) => (
          <div
            key={source.label}
            className="absolute z-10"
            style={{
              transform: `rotate(${source.angle}deg) translate(${radius}px) rotate(${-source.angle}deg)`,
            }}
          >
            <DeviceNode ref={source.ref} label={source.label}>
              {source.icon}
            </DeviceNode>
          </div>
        ))}

        {/* device ↔ hub beams */}
        {sources.map(({ ref, delay }, i) => (
          <AnimatedBeam
            key={`beam-${i}`}
            containerRef={containerRef}
            fromRef={ref}
            toRef={hubRef}
            curvature={0} // Straight lines to the center look best
            delay={delay}
            duration={2.4}
            pathColor="white"
            pathOpacity={0.28}
            pathWidth={2}
            gradientStartColor="#4edea3"
            gradientStopColor="#adc6ff"
            repeatType="reverse" // Makes the beam go back and forth
          />
        ))}
      </div>
    </Section>
  )
}
