import { forwardRef, useRef, type ReactNode } from 'react'
import { motion, useReducedMotion } from 'framer-motion'
import {
  AppleLogo,
  DeviceMobile,
  DeviceTablet,
  Laptop,
  Monitor,
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
  const displayRef = useRef<HTMLDivElement>(null)

  // Sources fan into the hub; each is offset in time so packets arrive in sequence.
  const sources = [
    { ref: macbookRef, curvature: -80, endYOffset: -12, delay: 0 },
    { ref: iphoneRef, curvature: -35, endYOffset: -6, delay: 0.8 },
    { ref: androidRef, curvature: 0, endYOffset: 0, delay: 1.6 },
    { ref: windowsRef, curvature: 35, endYOffset: 6, delay: 2.4 },
    { ref: ipadRef, curvature: 80, endYOffset: 12, delay: 3.2 },
  ]

  return (
    <Section
      eyebrow="Real-time"
      title="Every device, one stream"
      description="Copy on your laptop. It's on your phone before you reach for it. A persistent SSE connection per device, fanned out from a single Redis multiplexer."
    >
      <div
        ref={containerRef}
        className="relative mx-auto flex w-full max-w-3xl items-center justify-between gap-4 overflow-hidden px-2 py-10 sm:px-6"
      >
        {/* Sending devices */}
        <div className="flex flex-col justify-between gap-8">
          <DeviceNode ref={macbookRef} label="MacBook Pro">
            <Laptop size={22} weight="regular" />
          </DeviceNode>
          <DeviceNode ref={iphoneRef} label="iPhone">
            <AppleLogo size={22} weight="regular" />
          </DeviceNode>
          <DeviceNode ref={androidRef} label="Android">
            <DeviceMobile size={22} weight="regular" />
          </DeviceNode>
          <DeviceNode ref={windowsRef} label="Windows PC">
            <WindowsLogo size={22} weight="regular" />
          </DeviceNode>
          <DeviceNode ref={ipadRef} label="iPad">
            <DeviceTablet size={22} weight="regular" />
          </DeviceNode>
        </div>

        {/* Sync hub — pulses as each packet lands */}
        <div className="flex flex-col items-center gap-2">
          <motion.div
            ref={hubRef}
            className="z-10 flex size-16 items-center justify-center rounded-full border border-primary-container/40 bg-surface-container text-primary-container shadow-[0_0_40px_-8px_rgba(173,198,255,0.55)]"
            animate={reduceMotion ? undefined : { scale: [1, 0.92, 1.04, 1] }}
            transition={{ duration: 0.8, repeat: Infinity, repeatDelay: 0, ease: 'easeInOut' }}
          >
            <img src="/logo.png" alt="" className="size-8 object-contain" />
          </motion.div>
          <span className="text-label-sm font-mono text-primary-container whitespace-nowrap">
            OmniLink
          </span>
        </div>

        {/* Receiving display */}
        <div className="flex flex-col items-center gap-2">
          <DeviceNode ref={displayRef} label="Main Display" className="size-14">
            <Monitor size={26} weight="regular" />
          </DeviceNode>
        </div>

        {/* device → hub */}
        {sources.map(({ ref, curvature, endYOffset, delay }, i) => (
          <AnimatedBeam
            key={`in-${i}`}
            containerRef={containerRef}
            fromRef={ref}
            toRef={hubRef}
            curvature={curvature}
            endYOffset={endYOffset}
            delay={delay}
            duration={2.4}
            pathColor="white"
            pathOpacity={0.28}
            pathWidth={2}
            gradientStartColor="#4edea3"
            gradientStopColor="#adc6ff"
          />
        ))}

        {/* hub → main display, staggered to fire just after each arrival */}
        {sources.map(({ delay }, i) => (
          <AnimatedBeam
            key={`out-${i}`}
            containerRef={containerRef}
            fromRef={hubRef}
            toRef={displayRef}
            curvature={0}
            delay={delay + 1.1}
            duration={1.8}
            pathColor="white"
            pathOpacity={0.28}
            pathWidth={2}
            gradientStartColor="#adc6ff"
            gradientStopColor="#4edea3"
          />
        ))}
      </div>
    </Section>
  )
}
