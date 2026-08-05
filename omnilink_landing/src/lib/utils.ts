import { clsx, type ClassValue } from 'clsx'
import { twMerge } from 'tailwind-merge'

/**
 * Merge Tailwind classes safely — clsx resolves conditionals, twMerge
 * de-duplicates conflicting utilities so later classes win.
 */
export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}
