# Asset Spec: Crown Warden Phase Transition Frame Animation

Date: 2026-07-19
Story: `production/epics/player-abilities/story-176-crown-warden-dedicated-phase-transition-frame-animation.md`
Status: Implemented

## Role

The animation communicates Crown Warden relocking into Phase II. It replaces a
long hold on the final `hurt` frame with a continuous sovereign energy pulse,
without changing the mechanical transition, adding an attack tell, or baking
the existing overlay and debris effects into the character art.

## Contract

| Field | Value |
|-------|-------|
| Runtime type | Existing `AnimatedSprite2D + SpriteFrames` |
| Animation | `phase_transition` |
| Frame count | Exactly 3 distinct frames |
| Runtime canvas | Transparent sRGBA `192x192` PNG |
| Playback | `6 FPS`, `loop=true`; five loops fill the `2.5s` window |
| Facing | Authored right-facing; runtime keeps existing `flip_h` behavior |
| Anchor | Center pivot `(96,96)`; shared floor baseline within 2 px of `idle` |
| Directory | `assets/characters/crown_warden/phase_transition/` |
| Naming | `crown_warden_phase_transition_000.png` through `_002.png` |

## Visual Direction

- Frame 000 is a compact royal lock: planted talons, restrained wings, bright
  cyan optics and a charging violet chest core.
- Frame 001 is the transformation crest: both wings rise symmetrically and
  cyan/violet energy stays close to the body. It is broad but has no forward
  lunge, extended strike, red warning vane or projectile.
- Frame 002 settles into an empowered compact stance that can return smoothly
  to frame 000.
- Charcoal steel, aged brass, cyan optics, violet core and amber feather edges
  preserve Story146 identity. The generated frames contain no floor, shadow,
  HUD, debris, text, environment or baked full-screen effect.

## Pipeline

- Identity reference:
  `assets/characters/crown_warden/source/crown_warden_frames_preview_20260712.png`.
- Retained RGB source: strict horizontal three-cell `2172x724` image-generation
  output over a keyed magenta background.
- Retained RGBA alpha intermediate: sampled border key, soft matte and despill.
- Split the source into three `724x724` cells, nearest-resize each complete cell
  to `188x188`, then place it on a transparent `192x192` canvas with documented
  offsets. This keeps authored pixel relationships and avoids repainting.
- Exact prompt, processing values, offsets and hashes are retained in
  `assets/characters/crown_warden/source/crown_warden_phase_transition_sheet_imagegen_20260719.md`.
- Godot 4.7 imports source, alpha and all runtime frames through the normal
  texture pipeline; runtime filtering remains nearest/lossless.

## Validation

- All three frame files exist, have transparent corners, differ pixel-for-pixel
  and are mounted at their exact resource paths.
- Runtime frame bottoms differ by at most 2 px, centers by at most 3 px, and
  every bottom remains within 2 px of the existing `idle` baseline.
- Godot MCP observed `frame 0 -> 1 -> 0` across `0.64s`, with
  `animation=phase_transition`, `playing=true`, and the transition still active.
- The MCP screenshot shows the full Boss, readable Phase II HUD and no crop or
  placeholder block; final game/editor logs contain no project errors.
