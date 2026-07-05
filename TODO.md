# TODO - Marble Simulation

> **Convention** — Sections below map to kanban columns. Inline source-code tags use the same vocabulary so items stay cross-referenced between this file and the codebase. `KANBAN.canvas` auto-generates from this file and inline tags — do not hand-edit it.
>
> | Column      | Markdown section  | Inline tag  |
> |-------------|-------------------|-------------|
> | Backlog     | `## Backlog`      |             |
> | TODO        | `## TODO`         | `# TODO:`   |
> | In Progress | `## In Progress`  | `# FIXME:`  |
> | Bugs        | `## Bugs`         | `# BUG:`    |
> | Done        | `- [x]` items / `## Done` | —   |
>
> `# DEPRECATED:` tags should be tracked as TODO items for removal at the stated version.

## In Progress

_No items in progress._

## TODO

- [ ] **TodoScope Alignment**: Finish aligning repo to conventions
  - [ ] Run scanner and verify kanban board matches expectations

## Backlog

- [ ] **Menu UX Cleanup**: Polish hamburger menu styling, layout, and feel
  - [ ] Improve touch targets on mobile
  - [ ] Visual feedback and overall polish

## Bugs

_No known bugs. Use `# BUG:` inline tags to flag defects in source._

## Done

- [x] **Marble Physics & Rendering**: Canvas-based marble with tilt/keyboard controls
- [x] **Wood Block Collision Sounds**: Synthetic pentatonic wood block sounds per wall
  - [x] C major pentatonic: C5 (left), D5 (right), E5 (top), G5 (bottom)
  - [x] Velocity-scaled volume
- [x] **Surface-Bending Gravity**: Gaussian surface warp with pop-on-release
  - [x] Toggleable between surface bend and point attractor
  - [x] Contour ring visualization
- [x] **Real Sample Audio**: Freewavesamples.com woodblock, pitch-shifted per wall
  - [x] Sample loads on init, toggle enables it
  - [x] Synthetic fallback always available
