import {
  TextAa,
  ImageSquare,
  Code,
  FileZip,
  LinkSimple,
  MicrophoneStage,
  FilePdf,
  AndroidLogo,
} from '@phosphor-icons/react'
import type { Icon } from '@phosphor-icons/react'

export interface FileTypeGroup {
  Icon: Icon
  name: string
  description: string
  items: { Icon: Icon; label: string }[]
  /** Featured groups get wider grid placement */
  featured?: boolean
}

export const FILE_TYPE_GROUPS: FileTypeGroup[] = [
  {
    Icon: TextAa,
    name: 'Plain Text & Rich Data',
    description:
      'Notes, code blocks, and paragraphs. Links get their Open Graph data scraped in the background and render as rich preview cards.',
    items: [
      { Icon: TextAa, label: 'Notes & snippets' },
      { Icon: LinkSimple, label: 'URLs with previews' },
    ],
    featured: true,
  },
  {
    Icon: ImageSquare,
    name: 'Media Files',
    description:
      'Images render as proportional thumbnails in the masonry grid. Video plays inline. Voice notes record straight from the mobile quick-action.',
    items: [
      { Icon: ImageSquare, label: 'JPG · PNG · WebP · GIF' },
      { Icon: MicrophoneStage, label: 'Voice notes' },
    ],
  },
  {
    Icon: Code,
    name: 'Developer & Executable',
    description:
      'Source files render with their language icon. APKs move between devices without a cable, an email, or a cloud drive detour.',
    items: [
      { Icon: Code, label: '.py · .dart · .js · .html' },
      { Icon: AndroidLogo, label: 'APK packages' },
    ],
    featured: true,
  },
  {
    Icon: FileZip,
    name: 'Documents & Archives',
    description:
      'The storage layer treats uploads as agnostic byte streams, so there is no extension allowlist to fight with.',
    items: [
      { Icon: FilePdf, label: 'PDF · DOCX · XLSX' },
      { Icon: FileZip, label: '.zip · .rar' },
    ],
  },
]
