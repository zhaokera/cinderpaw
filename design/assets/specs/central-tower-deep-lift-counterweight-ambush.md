# Asset Spec: Central Tower Deep Lift Counterweight Ambush

> **Story**: 143
> **Generation policy**: built-in image generation, retained source, Godot import
> **Character budget note**: established Tower enemy `96x96` runtime exception

## Runtime Assets

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Deep Lift background | Opaque RGB `1280x720`; lower-left dock, deep central shaft, high-right landing, visible counterweight infrastructure; no baked actor, text, platform, props, VFX, or Boss composition | `res://assets/environment/central_tower/env_central_tower_deep_lift_1280x720.png` |
| Moving platform | Transparent RGBA `512x160`; broad readable top edge and undercarriage, no scenery | `res://assets/environment/central_tower/prop_central_tower_deep_lift_platform_512x160.png` |
| Counterweight carriage | Transparent RGBA `256x512`; tall guided mechanism, reused as moving visual balance | `res://assets/environment/central_tower/prop_central_tower_deep_lift_counterweight_256x512.png` |
| Entry shutter | Transparent RGBA `384x512`; vertical interlock with clear blocking silhouette | `res://assets/environment/central_tower/prop_central_tower_deep_lift_entry_shutter_384x512.png` |
| Sentry cradle | Transparent RGBA `256x256`; empty deployment rack, no baked enemy | `res://assets/environment/central_tower/prop_central_tower_counterweight_sentry_cradle_256x256.png` |
| Brake console | Transparent RGBA `256x384`; narrow amber/cyan upper endpoint control | `res://assets/environment/central_tower/prop_central_tower_deep_lift_brake_console_256x384.png` |
| Warning sweep | Transparent RGBA `512x128`; thin signal-red lock-stop sweep, never an opaque panel | `res://assets/environment/central_tower/vfx_central_tower_deep_lift_warning_sweep_512x128.png` |
| Counterweight Sentry frames | Eighteen transparent RGBA `96x96` frames; six gameplay states, three frames each, common bottom-center anchor | `res://assets/characters/central_tower_counterweight_sentry/central_tower_counterweight_sentry_sprite_frames.tres` |

## Image Generation Prompts

### Background

Create one full-bleed opaque 16:9 production background for a side-view 2D
action game, the fourth Central Tower viewport: Deep Lift counterweight bay.
Match the existing detailed industrial-fantasy game-art language. Lock the
composition: short safe lower dock on the left, very deep open lift shaft in the
middle, and narrow elevated landing on the right; asymmetrical machinery high
right, cables and lift infrastructure descending far below, unobstructed
gameplay silhouettes at lower y=576 and upper y=276. Dark steel-blue and
blackened iron dominate, restrained cyan machinery light and sparse amber
service lamps, no signal red. Continue Cooling Shaft architecture at the left
edge. Opaque RGB, no transparency or border. Exclude characters, enemies,
moving platform, counterweight prop, shutter, cradle, console, VFX, text, UI,
collision shapes, rewards, throne, giant core, Boss imagery, centered arena
symmetry, and foreground objects that hide gameplay.

### Strict Six-Cell Prop Sheet

Generate exactly one strict 3-column by 2-row keyed asset sheet on one perfectly
uniform flat `#FF00FF` background. Exactly six isolated assets, one per equal
cell, row-major: wide moving Deep Lift platform; tall guided counterweight
carriage; tall entry interlock shutter; empty Counterweight Sentry deployment
cradle; narrow Deep Lift brake console; thin horizontal lock-stop warning sweep.
Match Central Tower steel-blue industrial-fantasy game art with cyan mechanics
and restrained amber safety accents; signal red only in asset six. Keep every
silhouette inside a 12% cell safety margin. Exclude overlap, duplicates,
characters, floor, scenery, cast shadows, labels, text, UI, grid lines, magenta
inside subjects, translucent rectangular haze, and cropped extremities.

### Strict 3x6 Sentry Source Sheet

Generate exactly one portrait 1:2 sprite source sheet with 3 equal columns and
6 equal rows: exactly 18 isolated right-facing frames of the same ordinary
Central Tower Counterweight Sentry on perfectly uniform flat `#FF00FF`. Design:
compact top-heavy trapezoid automaton, hanging ballast abdomen, two short clawed
legs, one forward telescoping ram arm, dark steel-blue and black iron, small
cyan status slit, no gold, not Boss-sized, no rat or mantis anatomy. Rows in
exact order: idle weight sway; run heavy steps; attack_tell compression and red
warning; attack ram extension/impact/follow-through; hurt recoil/compression/
recovery; death stagger/kneel/collapse. Signal red only in attack_tell and
attack. Keep anatomy, scale, facing, lighting, and bottom-center registration
identical. Entire body and extended ram remain inside a 12% safety margin.
Exclude detached parts, particles, impact VFX, shadows, text, labels, grid
lines, extra poses, perspective changes, cropping, magenta inside the character,
and background variation.

## Processing

- Retain source PNGs and exact prompt records under `assets/generated/source/`
  and `assets/characters/central_tower_counterweight_sentry/source/`.
- Use proportional cell boundaries when source dimensions are not divisible by
  `3x2` or `3x6`; do not accumulate integer-step crop error.
- Sample border key, build a soft alpha matte, despill magenta, inspect thin ram
  and warning edges, then trim/fit without changing aspect ratio.
- Normalize all enemy poses with one global scale into transparent `96x96`
  canvases, anchor `(48,88)`, at least `4px` padding, and continuous
  `<character>_<animation>_000..002.png` names.
- Normalize the background to exact opaque RGB `1280x720`; normalize six props
  to the exact RGBA canvases above. Godot imports use nearest filtering and
  lossless compression.

## MCP Visual Acceptance

- Fourth viewport, platform, counterweight, shutter, cradle, console, Sentry,
  objective, player, and HUD are visible and coherent in one live run.
- Platform top stays readable during warning and combat. Warning VFX height is
  at most `128px` and does not cover the player's core silhouette.
- Live Sentry is an `AnimatedSprite2D` using the exact SpriteFrames path; MCP
  observes `attack_tell`, `attack`, and a readable death/defeat state.
- No magenta/gray fringe, opaque keyed rectangle, crop, baked actor/text,
  primitive placeholder, Boss composition, or incoherent HUD overlap.
