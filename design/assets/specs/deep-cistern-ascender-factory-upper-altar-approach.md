# Asset Spec: Deep Cistern Ascender And Factory Upper Altar Approach

## Purpose

Story134 turns the secured Story133 arena into a deliberate scene handoff and
lands Cinderpaw in the GDD-authored Old Factory hidden-altar route. The visual
slice must read as an upper industrial space opening toward the future neon
rooftops, not another underground tunnel or an empty transition room.

## Runtime Assets

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Upper-works background | Opaque RGB `1280x720`; readable floor and three ascending platform silhouettes; lift shaft left; dormant violet recess right | `res://assets/environment/factory_upper_altar/env_factory_upper_altar_approach_1280x720.png` |
| Cistern ascender | Transparent RGBA `384x512`; front-facing industrial doorway; cyan status seams; clean full-object bounds | `res://assets/environment/factory_upper_altar/prop_deep_cistern_ascender_384x512.png` |
| Dormant feline altar | Transparent RGBA `384x384`; cat/paw silhouette; violet mystery cue; inactive gold core | `res://assets/environment/factory_upper_altar/prop_factory_hidden_altar_dormant_384x384.png` |

## Scene Use

- Underground Passage places the ascender beyond the opened Story133 front seal.
- Factory Upper Altar Approach reuses the ascender as the return route and pairs
  authored collision with the platforms painted into the generated background.
- The altar is a real `Sprite2D` discovery target with a bounded interaction
  area and discovery pulse. Story134 does not unlock `wall_climb`.

## Acceptance

- Godot imports all three runtime PNGs without resource errors.
- Background is exact opaque `1280x720`; both props retain alpha and do not touch
  their canvas edges.
- MCP screenshot shows Cinderpaw, the actual generated upper-works scene,
  collision-backed platform route, ascender, dormant altar, objective and HUD.
- No ColorRect, flat primitive, placeholder block or text baked into the assets.
