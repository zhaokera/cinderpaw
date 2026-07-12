# Asset Spec: Central Tower Inner Relay Skirmish

> **Story**: 141
> **Generation policy**: built-in image generation, retained source, Godot import

## Runtime Assets

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Service Spine background | Opaque RGB `1280x720`; left edge continues the threshold interior, broad readable combat lane, tall conduit spine, deep right shutter; no baked actors, text, cache, pulse, or collision props | `res://assets/environment/central_tower/env_central_tower_service_spine_1280x720.png` |
| Relay emitter | Transparent RGBA `256x512`; tall cyan diagnostic column with restrained amber service trim | `res://assets/environment/central_tower/prop_central_tower_service_relay_256x512.png` |
| Observation shutter | Transparent RGBA `384x512`; narrow Tower service gate, signal-red lock core, no translucent membrane | `res://assets/environment/central_tower/prop_central_tower_observation_shutter_384x512.png` |
| Mantis perch | Transparent RGBA `256x256`; light maintenance cradle distinct from the heavy Story140 guard dock | `res://assets/environment/central_tower/prop_central_tower_mantis_perch_256x256.png` |
| Relay cache | Transparent RGBA `256x256`; compact maintenance drawer with cyan seams and safe gold reward latch | `res://assets/environment/central_tower/prop_central_tower_relay_cache_256x256.png` |
| Relay pulse | Transparent RGBA `512x128`; horizontal red-white electrical strike with crisp lane edges and no text | `res://assets/environment/central_tower/vfx_central_tower_relay_pulse_512x128.png` |
| Relay Mantis | Six animations, exactly three transparent `96x96` frames each, common y=`88` baseline | `res://assets/characters/central_tower_relay_mantis/central_tower_relay_mantis_sprite_frames.tres` |

## Character Contract

- Animations: `idle`, `run`, `attack_tell`, `attack`, `hurt`, `death`.
- Frame names:
  `central_tower_relay_mantis_<animation>_000.png` through `_002.png`.
- Runtime folders:
  `assets/characters/central_tower_relay_mantis/<animation>/`.
- Required scene/script:
  `scenes/characters/central_tower_relay_mantis.tscn` and
  `src/characters/central_tower_relay_mantis.gd`.
- The full body remains within a four-pixel safety margin. All frames share
  bottom-center registration, scale, facing, materials, and lighting.

## Generation And Processing

- Generate one opaque environment source, one flat `#ff00ff` keyed prop sheet,
  and one strict keyed `3x6` Mantis sheet with built-in image generation.
- Retain source PNG and prompt metadata under `assets/generated/source/` or the
  character's `source/` folder.
- Remove chroma with the installed imagegen helper using border auto-key, soft
  matte, despill, and one-pixel edge contraction when needed.
- Normalize the background to exact opaque RGB `1280x720`; isolate, trim, fit,
  and center props and frames on their exact runtime canvases.
- Godot imports use nearest filtering and lossless compression.

## QA Contract

- Exact dimensions, alpha mode, transparent corners, continuous names, and
  common Mantis baseline.
- All six SpriteFrames animations exist with three frames each.
- MCP sees the second background, emitter, pulse, shutters, perch, cache, and a
  visible `AnimatedSprite2D` Mantis in the running scene.
- Final screenshot contains no blank textures, magenta key spill, baked text,
  visible primitive placeholder, or incoherent UI overlap.
