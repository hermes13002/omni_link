import type { Config } from 'tailwindcss'

/** Wraps a CSS variable so Tailwind opacity modifiers still work. */
const c = (name: string) => `rgb(var(--${name}) / <alpha-value>)`

export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        surface: {
          DEFAULT: c('surface'),
          'container-lowest': c('surface-container-lowest'),
          'container-low': c('surface-container-low'),
          container: c('surface-container'),
          'container-high': c('surface-container-high'),
          'container-highest': c('surface-container-highest'),
        },
        primary: {
          DEFAULT: c('primary'),
          container: c('primary-container'),
        },
        'on-primary': c('on-primary'),
        secondary: c('secondary'),
        'on-secondary': c('on-secondary'),
        tertiary: {
          DEFAULT: c('tertiary'),
          container: c('tertiary-container'),
        },
        'on-tertiary': c('on-tertiary'),
        'on-surface': {
          DEFAULT: c('on-surface'),
          variant: c('on-surface-variant'),
        },
        outline: {
          DEFAULT: c('outline'),
          variant: c('outline-variant'),
        },
        error: c('error'),
        'on-error': c('on-error'),
        glass: c('glass-tint'),
      },
      fontFamily: {
        display: ['Geist', 'sans-serif'],
        body: ['Inter', 'sans-serif'],
        mono: ['JetBrains Mono', 'monospace'],
      },
      fontSize: {
        'display-lg': ['48px', { lineHeight: '1.1', letterSpacing: '-0.02em', fontWeight: '700' }],
        'headline-lg': ['32px', { lineHeight: '1.2', fontWeight: '600' }],
        'headline-md': ['24px', { lineHeight: '1.3', fontWeight: '600' }],
        'body-lg': ['18px', { lineHeight: '1.6', fontWeight: '400' }],
        'body-md': ['16px', { lineHeight: '1.5', fontWeight: '400' }],
        'label-md': ['14px', { lineHeight: '1.4', fontWeight: '500' }],
        'label-sm': ['12px', { lineHeight: '1.4', fontWeight: '500' }],
        'label-xs': ['10px', { lineHeight: '1.4', fontWeight: '500' }],
      },
      borderRadius: {
        card: '12px',
        button: '9999px',
        chip: '9999px',
      },
      backdropBlur: {
        glass: '15px',
      },
    },
  },
  plugins: [],
} satisfies Config
