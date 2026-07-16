# Asset Spec: Rat Minion Attack Tell Frame Animation

> **Story**: Combat Presentation 032
> **Generation policy**: built-in image generation with Rat Minion reference,
> chroma-key alpha processing, Godot 4.7 import

## Runtime Contract

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Rat Minion bite anticipation | Three transparent sRGBA `96x96` frames; common right-facing direction, horizontal center and `y=91` ground baseline; no attack travel/contact | `res://assets/characters/rat_minion/attack_tell/rat_minion_attack_tell_000.png` through `_002.png` |
| SpriteFrames state | `attack_tell`, 3 frames, non-looping, `9 FPS` | `res://assets/characters/rat_minion/rat_minion_sprite_frames.tres` |
| Retained source | RGB generated strip, full-size alpha intermediate and prompt record | `res://assets/characters/rat_minion/source/rat_minion_attack_tell_strip_*_20260716.*` |

## Visual Direction

Preserve the existing charcoal-fur scavenger with blackened/rusted armor,
orange-red eyes, dorsal spikes and segmented tail. The anticipation silhouette
must grow in stored energy rather than forward displacement: low crouch,
compressed coil, then planted maximum tension. The active leap remains in the
existing `attack` animation so startup and danger are visually distinct.

## Processing And Import

- Generate one three-cell strip on uniform magenta using the existing Rat
  Minion preview as identity/style reference.
- Remove the border key with soft matte and despill, retain the alpha strip,
  crop each isolated subject and fit inside `88x71` without distortion.
- Center on exact transparent `96x96` canvases with four-pixel side padding and
  the existing `y=91` ground baseline.
- Import all frames with Godot 4.7 and map them only to `attack_tell`.
- MCP must show a real Main-scene summoned Rat Minion using the state with no
  active bite hitbox, followed by the unchanged active transition.
