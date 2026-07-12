# Asset Spec: Central Tower Apex Conduit Purge Run

> **Story**: 144
> **Generation policy**: built-in image generation, retained source, Godot import
> **Character note**: no new character or enemy asset is introduced by this story

## Runtime Assets

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Apex Conduit background | Opaque RGB `1280x720`; safe upper-left entry, lower catwalk, central magnetic spine, upper-right catwalk and compact endpoint deck; no baked actor, text, hazard, prop or Boss-arena composition | `res://assets/environment/central_tower/env_central_tower_apex_conduit_1280x720.png` |
| Apex Roost | Transparent RGBA `256x256`; compact mechanical cat-shaped savepoint with cyan-white core and amber activation ring | `res://assets/environment/central_tower/prop_central_tower_apex_roost_256x256.png` |
| Magnetic spine | Transparent RGBA `256x512`; tall climbable steel rail with cyan current strips and readable grip ridges | `res://assets/environment/central_tower/prop_central_tower_apex_magnetic_spine_256x512.png` |
| Purge emitter | Transparent RGBA `256x384`; wall-mounted ceramic-coil emitter with a restrained red warning lamp | `res://assets/environment/central_tower/prop_central_tower_apex_purge_emitter_256x384.png` |
| Apex Approach beacon | Transparent RGBA `256x384`; narrow cyan endpoint core with an amber completion halo | `res://assets/environment/central_tower/prop_central_tower_apex_beacon_256x384.png` |
| Purge wall | Transparent RGBA `192x640`; narrow vertical ionized wall with a red-orange leading edge and cyan-white interior | `res://assets/environment/central_tower/vfx_central_tower_apex_purge_wall_192x640.png` |

## Image Generation Prompts

The exact prompts and processing metadata are retained with the generated
sources:

- Background: `assets/generated/source/central_tower_apex_conduit_background_imagegen_20260712.prompt.md`
- Strict `3x2` prop sheet: `assets/generated/source/central_tower_apex_conduit_props_imagegen_20260712.prompt.md`

The background prompt locks the fifth viewport to an orthographic side-view ACT
route with readable platform silhouettes and excludes characters, enemies,
Boss imagery, UI, text and interactive props. The prop prompt requests exactly
six isolated assets over uniform `#ff00ff`; five cells feed runtime assets and
the warning-light cell remains source-only.

## Processing

- Retain the original `1672x941` background and exact `1536x1024` prop sheet,
  prompt records and the full alpha-matted prop source under
  `assets/generated/source/`.
- Normalize the background to exact opaque sRGB RGB `1280x720` without changing
  the route composition.
- Sample the keyed sheet border, build a soft alpha matte, despill magenta, trim
  each selected cell, preserve aspect ratio and center it on the exact RGBA
  runtime canvas listed above.
- Keep gameplay collision, Roost activation, warning timing, moving-wall damage
  and endpoint interaction in authored Godot nodes and scripts. Generated
  textures provide presentation only.
- Godot imports use lossless compression and nearest filtering. Transparent
  corners and non-empty alpha bounds are checked by the focused suite.

## MCP Visual Acceptance

- The fifth viewport, Apex Roost, purge emitter, moving purge wall, magnetic
  spine, endpoint beacon, Cinderpaw, objective and HUD are visible in one live
  run without primitive player-facing placeholders.
- Warning and pursuit states preserve the player's readable silhouette; the
  purge texture remains a narrow vertical wall rather than an opaque panel.
- Live Cinderpaw remains an `AnimatedSprite2D` using
  `res://assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`.
- The screenshot is non-empty and has no obvious magenta fringe, keyed
  rectangle, crop, baked actor/text, Boss composition or incoherent HUD overlap.
