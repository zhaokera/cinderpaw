# Asset Spec: Sluice Matriarch

Date: 2026-07-11
Story: `production/epics/player-abilities/story-128-sluice-matriarch-playable-boss3-core.md`
Status: Implemented playable Boss3 core

## Role

Sluice Matriarch is Boss3 at the end of the Old Factory Tailrace route. Her
low, long organic silhouette must read as a mutated industrial leech and not a
scaled rat. The first production slice supports one readable pressure-lunge
attack, a faster second phase, hurt feedback, and a persistent death state.

## Visual Contract

| Field | Value |
|-------|-------|
| Runtime type | `AnimatedSprite2D + SpriteFrames` |
| Runtime canvas | `192x192` transparent RGBA PNG per frame |
| Animations | `idle`, `run`, `attack_tell`, `attack`, `hurt`, `death` |
| Frame count | Exactly 3 frames per animation, 18 frames total |
| Facing | Authored facing right; gameplay runtime uses `flip_h` |
| Anchor | Shared center pivot and ground baseline on every frame |
| Naming | `sluice_matriarch_<animation>_000.png` through `_002.png` |
| SpriteFrames | `assets/characters/sluice_matriarch/sluice_matriarch_sprite_frames.tres` |
| Character scene | `scenes/characters/sluice_matriarch.tscn` |
| Runtime scene | `src/gameplay/sluice_matriarch_boss.tscn` |

## Art Direction

- A charcoal-purple wet body, steel pressure clamps, cracked ceramic plates,
  rust-orange hardware, and cyan mutation seams tie the boss to the Factory.
- Signal-red dorsal spines and a compressed pose make `attack_tell` readable
  before the damaging pressure-lunge frames become active.
- `attack` extends a pale organic pressure lance and broadens the silhouette;
  the runtime also moves the body toward Cinderpaw so the attack is not a
  static sprite swap.
- `hurt` compresses the head and clamps. `death` settles the body flat and
  remains visible as a non-damaging arena corpse after victory.
- The arena backdrop cocoon remains environmental depth; the transparent boss
  sprite must remain legible against it at 1.25 runtime scale.

## Runtime Timing

| Animation | FPS | Loop |
|-----------|-----|------|
| `idle` | 4 | yes |
| `run` | 7 | yes |
| `attack_tell` | 8 | no |
| `attack` | 12 | no |
| `hurt` | 8 | no |
| `death` | 5 | no |

The gameplay controller, not animation completion, owns the deterministic
`18` startup, `6` active, and `18` recovery frame windows.

## Pipeline

The full prompt and processing record lives at
`assets/characters/sluice_matriarch/source/sluice_matriarch_sprite_sheet_imagegen_20260711.md`.
The retained built-in image-generation source was magenta-keyed to alpha,
split as a `3x6` sheet, normalized to one `192x192` canvas contract, and
imported through Godot 4.7.

## Validation

- Every runtime frame is RGBA `192x192`, has transparent corners, a non-empty
  subject, continuous naming, and no visible magenta fringe.
- All six gameplay states contain exactly three frames in the mounted
  `SpriteFrames` resource.
- The pressure-lunge startup uses `attack_tell` with no active hitbox; active
  frames use `attack`, move the body, and route `16` damage through shared
  Collision/Combat components.
- Godot MCP must verify the character/runtime scenes, animation names/counts,
  active and defeated arena states, clean current-run logs, and non-empty
  screenshots containing the frame-animated boss.
