# Rat King Phase-I Intro Image Generation Record

> **Date**: 2026-07-18
> **Generator**: built-in image generation
> **Story**: Combat Presentation Story035
> **Reference**: `rat_king_sprite_sheet_imagegen_20260625.png`

## Generation Prompt

Use case: stylized-concept.

Asset type: production three-frame sprite sheet for the existing Rat King boss
Phase-I entrance in a Godot 2D side-scrolling action game.

Input image: identity and rendering reference. Preserve the exact Rat King
identity from the reference: gigantic hunched mechanical rat, dark riveted
scrap armor, trash-can lower body, jagged metal crown, one red cybernetic
eye/core, exposed cables, dirty steel and rust, right-facing side profile,
high-contrast hand-painted pixel-art-like action-game rendering.

Primary request: Create exactly three sequential full-body Phase-I entrance
frames arranged in one strict horizontal row, left to right:

1. Shadowed anticipation: Rat King crouches lower with crown and head bowed,
   eye/core dim but visible, foreclaws braced.
2. Ignition: torso rises, red eye and chest/core flare clearly, crown begins
   lifting, cables tense.
3. Threat reveal: crown and head fully raised, shoulders expanded, one
   foreclaw reaches forward, mouth opens in a restrained roar, strong readable
   Boss silhouette ready to hand off to idle.

Animation consistency: same character scale, right-facing orientation, camera,
baseline, visual center, trash-can body placement, armor design, limb count,
and proportions in all three frames. Motion must read as one coherent
anticipation-to-threat sequence without jitter. Keep every complete character
fully inside its equal-width cell with generous identical padding. No overlap
between cells.

Background: perfectly flat uniform solid `#FF00FF` chroma key across the entire
image, with no gradient, texture, lighting variation, reflection, floor plane,
contact shadow, cast shadow, smoke, particles, or scenery. Do not use magenta
anywhere in the character.

Composition: exactly three equal columns and one row; one complete character
per column; no additional rows, duplicate characters, cropped limbs, extra
props, grid lines, labels, numbers, text, UI, border, watermark, or logos.

Output: one clean horizontal three-frame source sheet suitable for chroma-key
extraction and normalization to three transparent `192x192` Godot frames.

## Files And Hashes

| File | Contract | SHA-256 |
|------|----------|---------|
| `rat_king_phase_1_intro_sheet_imagegen_20260718.png` | Generated RGB source, `2172x724` | `9be3ac2005143c8dbfc4ffaeadb9b741518bd23f8a03149e5f015fa61db4b661` |
| `rat_king_phase_1_intro_sheet_alpha_20260718.png` | Chroma-keyed sRGBA intermediate, `2172x724` | `1a64a8c349d821782dc7259c313ec6bc396a2be84f83f33b79cb377d820aceb6` |
| `../phase_1_intro/rat_king_phase_1_intro_000.png` | Anticipation, transparent sRGBA `192x192` | `698644c6028ad41aea4ecb3ea6ea4cb28980973fd6c6f24d01a151db796a4e81` |
| `../phase_1_intro/rat_king_phase_1_intro_001.png` | Ignition, transparent sRGBA `192x192` | `12854a90ba4bd43be9c3db5e7f556c6c57ef633b7869e2d0bee7f5bc518994df` |
| `../phase_1_intro/rat_king_phase_1_intro_002.png` | Threat reveal, transparent sRGBA `192x192` | `a0debad81a6fac3e4795f20d448339caee6510f9cde237d07e044e1564a1a116` |

## Processing

- Removed the sampled border key `#fa02f9` with the project image-generation
  helper, soft-matte thresholds `12/220`, and despill.
- Split the source into three exact `724x724` cells at x offsets `0`, `724`,
  and `1448`; each complete cell was resized uniformly to `190x190`.
- Composited each resized cell at `(1,25)` on an exact transparent `192x192`
  canvas. This preserves one scale and anchor across the sequence while
  keeping the shared visible baseline at `y=191`.
- Final visible bounds are `164x115+7+77`, `170x142+3+50`, and
  `185x143+1+48`; all frames retain transparent edge padding and differ from
  the corresponding idle frame.

Godot 4.7 reimported all three runtime frames and loaded them through their
existing texture sidecars. The RGB source and alpha intermediate remain in the
source directory for traceability rather than runtime use. The existing
`phase_1_intro` SpriteFrames state remains non-looping with exactly three
frames.
