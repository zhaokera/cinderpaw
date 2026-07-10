# Asset Spec: Factory Sluice Leech

Date: 2026-07-10
Story: `production/epics/player-abilities/story-126-old-factory-tailrace-exit-spillway-sluice-leech-skirmish.md`
Status: Approved for production by the active Story126 scope

## Role

Factory Sluice Leech is the first small organic mutated-creature enemy in the
Old Factory route. Its low S-curve silhouette, wet body, and sparse mechanical
clamps must read differently from the repeated square-bodied Spark Rat and Coil
Rat families while still belonging to the same industrial biome.

## Visual Contract

| Field | Value |
|-------|-------|
| Runtime type | `AnimatedSprite2D + SpriteFrames` |
| Runtime canvas | `96x96` transparent RGBA PNG per frame |
| Animations | `idle`, `run`, `attack_tell`, `attack`, `hurt`, `death` |
| Frame count | Exactly 3 frames per animation, 18 frames total |
| Facing | Authored facing right; runtime uses `flip_h` |
| Anchor | Centered canvas, shared ground baseline, full silhouette inside safe padding |
| Naming | `factory_sluice_leech_<animation>_000.png` through `_002.png` |
| SpriteFrames | `assets/characters/factory_sluice_leech/factory_sluice_leech_sprite_frames.tres` |
| Character scene | `scenes/characters/factory_sluice_leech.tscn` |
| Runtime scene | `src/gameplay/factory_sluice_leech.tscn` |

## Art Direction

- Long curved body and low crawling posture communicate mobility; exposed red
  triangular spines communicate the attack tell.
- Wet charcoal-purple skin, steel-blue shadow, rust-orange clamps, cracked
  ceramic insulators, and restrained toxic-green mutation seams combine Old
  Factory hardware with organic invasion.
- Signal red appears only in `attack_tell`/attack threat frames. Cat-eye gold is
  excluded so the enemy cannot read as a safe/player-owned object.
- At 32x32 preview size, the silhouette must not be mistaken for a rat.

The Art Bible small-enemy baseline is `64x64`, while both existing Factory
Spark Rat and Factory Coil Rat runtime families use `96x96`. Story126 follows
the established Factory enemy contract so the new creature shares one runtime
scale and import path with its encounter peers. This is a documented project
consistency deviation, not a new global asset standard.

## Generation Prompt

Use case: stylized-concept
Asset type: Godot 4.7 2D side-scroller enemy sprite sheet
Primary request: Create one coherent Factory Sluice Leech character shown in a
strict 3-column by 6-row sprite-sheet grid. Rows in order are idle, crawl/run,
attack tell, forward lunge attack, hurt, death. Each row contains three distinct
animation frames of the same character, same scale, same right-facing direction,
same ground baseline, and same pivot.
Subject: small mutated factory sluice leech, low S-curve silhouette, wet rubbery
charcoal-purple body, rusted metal clamp rings, cracked ceramic insulators,
steel-blue shadows, rust-orange grime, restrained toxic-green mutation seams,
tiny signal-red triangular attack spines visible mainly during attack tell.
Style/medium: crisp authored pixel art for a polished 2D action platformer,
chunky readable silhouette, cute-danger contrast, no smoothing.
Composition/framing: exactly 18 isolated full-body sprites, generous padding in
every equal grid cell, no overlap, no crop, no labels, no separators; each frame
must remain readable after normalization to 96x96.
Scene/backdrop: perfectly flat solid #ff00ff chroma-key background, uniform edge
to edge, no floor plane, no shadow, no gradient, no texture, no reflection.
Constraints: same creature identity and proportions in every frame; fully opaque
character edges; do not use #ff00ff in the subject; no text, UI, watermark, or
environment.
Avoid: rat head, mouse ears, square body, large green areas, cat-eye gold,
photorealism, 3D render, painterly blur, antialiased vector look, extra limbs,
cropped tail/body, inconsistent scale, background props, cast shadow.

## Pipeline

1. Generate the 3x6 source sheet on flat `#ff00ff` chroma key and retain it at
   `assets/characters/factory_sluice_leech/source/`.
2. Remove chroma locally with the installed imagegen helper using auto-key,
   soft matte, despill, transparent threshold `12`, and opaque threshold `220`.
3. Slice the alpha source into three columns and six rows. Derive one scale
   factor from the full 18-frame set, apply it to every frame with high-quality
   offline downsampling, and center each sprite on a transparent `96x96`
   canvas with baseline y `88` (tolerance `87-89`) and center x `48`
   (tolerance `+/-2`).
4. Import through Godot 4.7 with nearest-neighbor sampling and no mipmaps, then
   bind the frames into one `SpriteFrames` resource.
5. Retain a transparent 3x6 preview plus prompt/processing metadata under the
   source folder.

## Runtime Timing

| Animation | FPS | Loop |
|-----------|-----|------|
| `idle` | 4 | yes |
| `run` | 9 | yes |
| `attack_tell` | 10 | no |
| `attack` | 10 | no |
| `hurt` | 8 | no |
| `death` | 6 | no |

## Validation

- Every runtime frame is RGBA `96x96`, has transparent corners, and contains a
  non-empty opaque subject with no chroma fringe.
- All frames share one ground baseline and similar subject scale; the six rows
  contain genuinely different poses rather than translated duplicates.
- Normal frames retain at least 2px transparent padding, use a visible bounding
  box approximately 76-90px wide and 28-46px high, and never touch the canvas
  edge during the lunge.
- `attack_tell` is readable within 0.3 seconds through compressed posture plus
  signal-red triangular spines.
- Godot MCP must verify the character scene, runtime `AnimatedSprite2D`, six
  animation names, three frames per animation, clean logs, and a non-empty game
  screenshot containing the enemy.
