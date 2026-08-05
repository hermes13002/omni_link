import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
  type ReactNode,
} from 'react'

export type Theme = 'dark' | 'light'

const STORAGE_KEY = 'omnilink-theme'

interface ThemeContextValue {
  theme: Theme
  toggleTheme: () => void
}

const ThemeContext = createContext<ThemeContextValue | null>(null)

function readInitialTheme(): Theme {
  // Guard for SSR / non-browser contexts.
  if (typeof window === 'undefined') return 'dark'

  try {
    const stored = window.localStorage.getItem(STORAGE_KEY)
    if (stored === 'light' || stored === 'dark') return stored
  } catch {
    // localStorage can throw in private mode , fall through to system pref.
  }

  return window.matchMedia('(prefers-color-scheme: light)').matches ? 'light' : 'dark'
}

/**
 * Theme lives in context, not a bare hook. A bare hook gives every caller its
 * own useState, so a toggle in the nav would not update any other consumer.
 */
export function ThemeProvider({ children }: { children: ReactNode }) {
  const [theme, setTheme] = useState<Theme>(readInitialTheme)

  useEffect(() => {
    // The .light class drives the CSS custom properties in index.css.
    document.documentElement.classList.toggle('light', theme === 'light')
    document.documentElement.style.colorScheme = theme

    try {
      window.localStorage.setItem(STORAGE_KEY, theme)
    } catch {
      // Persistence is best-effort.
    }
  }, [theme])

  const toggleTheme = useCallback(() => {
    setTheme((prev) => (prev === 'dark' ? 'light' : 'dark'))
  }, [])

  const value = useMemo(() => ({ theme, toggleTheme }), [theme, toggleTheme])

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>
}

export function useTheme(): ThemeContextValue {
  const ctx = useContext(ThemeContext)
  if (!ctx) throw new Error('useTheme must be used within a ThemeProvider')
  return ctx
}
