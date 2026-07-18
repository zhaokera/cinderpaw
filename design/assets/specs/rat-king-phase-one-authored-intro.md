# Asset Spec: Rat King Phase-I Authored Intro

> **Story**: Combat Presentation 035
> **Generation policy**: built-in image generation with Rat King reference,
> chroma-key alpha processing, Godot 4.7 import

## Runtime Contract

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Rat King Phase-I entrance | Three distinct transparent sRGBA `192x192` frames; one right-facing identity, common scale and `y=191` ground baseline | `res://assets/characters/rat_king/phase_1_intro/rat_king_phase_1_intro_000.png` through `_002.png` |
| SpriteFrames state | `phase_1_intro`, 3 frames, non-looping; existing timing and idle handoff retained | `res://assets/characters/rat_king/rat_king_sprite_frames.tres` |
| Retained source | RGB generated sheet, full-size alpha intermediate, exact prompt, processing settings and hashes | `res://assets/characters/rat_king/source/rat_king_phase_1_intro_sheet_*_20260718.*` |

## Visual Direction

Preserve the existing giant right-facing scrap-mechanical rat identity: dark
riveted armor, cylindrical trash-can lower body, jagged crown, exposed cable
accents and one red eye/core. The entrance must read in three beats without
changing collision or gameplay scale: low shadowed anticipation, rising red
ignition, then a crown-up forward-claw threat ready to hand off to idle.

No background, floor, contact shadow, particles, UI, text, extra props or extra
character may be baked into a runtime frame. Each complete silhouette must stay
inside the canvas with transparent safety padding.

## Processing And Import

- Generate one strict three-cell horizontal sheet on uniform magenta using the
  existing Rat King source sheet as the identity and rendering reference.
- Remove the border key with soft matte and despill, retain the alpha sheet,
  and split it into three exact equal cells rather than trimming poses to
  independent scales.
- Resize every complete cell to `190x190` and composite at the same `(1,25)`
  anchor on transparent `192x192` canvases; target baseline is `y=191`.
- Replace only the three existing runtime PNGs so SpriteFrames paths, animation
  timing, boss state machine, hitboxes, damage and phase logic remain unchanged.
- Godot MCP must show the real Main-scene Rat King AnimatedSprite2D playing the
  imported `phase_1_intro`, with three distinct frames and clean runtime logs.
