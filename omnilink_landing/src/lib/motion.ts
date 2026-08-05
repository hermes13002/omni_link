/**
 * Global motion tokens. Every animation in the landing page pulls duration and
 * easing from here so the whole surface shares one rhythm.
 *
 * Curves follow the skill's Modern Dark recommendation: Expo.out
 * bezier(0.16, 1, 0.3, 1) for entrances , fast start, long settle.
 */

export const easing = {
  /** Entrances. Expo.out: decisive start, soft landing. */
  out: [0.16, 1, 0.3, 1] as const,
  /** Exits and hover returns. */
  inOut: [0.4, 0, 0.2, 1] as const,
} as const

export const duration = {
  /** Micro-interactions: hover, press, icon shifts. */
  fast: 0.2,
  /** Standard element entrance. */
  base: 0.5,
  /** Section-level reveals. */
  slow: 0.7,
} as const

/** Stagger step between list/grid children. Skill guidance: 30–50ms. */
export const STAGGER_STEP = 0.06

/** Standard scroll-reveal variant. Pair with `whileInView`. */
export const revealUp = {
  hidden: { opacity: 0, y: 20 },
  visible: {
    opacity: 1,
    y: 0,
    transition: { duration: duration.base, ease: easing.out },
  },
} as const

/** Parent wrapper that staggers its children on reveal. */
export const staggerParent = {
  hidden: {},
  visible: {
    transition: { staggerChildren: STAGGER_STEP },
  },
} as const

/** Viewport config for scroll reveals , fires once, slightly before full entry. */
export const viewportOnce = { once: true, margin: '-80px' } as const
