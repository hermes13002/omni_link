# OmniLink Landing Page

Marketing website for OmniLink , built with Vite + React + TypeScript + Tailwind.

## Development

```bash
npm install
npm run dev
```

Dev server runs at `http://localhost:3000`.

## Build

```bash
npm run build
```

Output goes to `dist/`. Deploy the contents as a static site.

## Design System

All colors, fonts, and motion curves are pulled directly from the Flutter app's theme files:
- Palette from `omnilink_frontend/lib/core/theme/app_colors.dart`
- Typography: Geist (display), Inter (body), JetBrains Mono (mono)
- Animation curves ported from `onboarding_screen.dart`

Dark mode is default; light mode available via the nav toggle.

## Deploy to Render

Already wired in `render.yaml` at the repo root. Render will:
1. `cd omnilink_landing && npm ci && npm run build`
2. Serve `omnilink_landing/dist` as a static site

No separate build script needed.
