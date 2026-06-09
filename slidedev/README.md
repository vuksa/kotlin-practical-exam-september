# Slide Deck

This directory contains a standalone Slidev presentation for the assignment.
It is separate from the Gradle project and is excluded from the student submission ZIP.

## Prerequisites

- Node.js and npm installed
- Run all Slidev commands from the `slidedev/` directory

## Start the slides

First start on a machine:

```bash
cd slidedev
npm ci
npm run dev
```

After the dependencies are installed once:

```bash
cd slidedev
npm run dev
```

Slidev will print a local URL in the terminal. Open that URL in a browser.

## Edit the deck

Main files:

- `slides.md`: slide content
- `style.css`: shared deck styling
- `global-bottom.vue`: Kotlin logo shown on every slide
- `public/kotlin-logo.svg`: logo asset

While `npm run dev` is running, Slidev reloads the presentation after changes.

## Build or export

Create a production build:

```bash
cd slidedev
npm run build
```

Export a static version:

```bash
cd slidedev
npm run export
```

## Notes

- Replace the repository URL placeholder in `slides.md` before presenting.
- The student `zip-project.cmd` helper intentionally skips the entire `slidedev/` directory.
