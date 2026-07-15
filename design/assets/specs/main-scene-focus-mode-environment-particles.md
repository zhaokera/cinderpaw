# Asset Spec: Main Scene Focus Mode Environment Particle Clarity

> **Story**: Player Abilities 159
> **Generation policy**: built-in image generation, retained keyed source,
> deterministic alpha processing, Godot 4.7 import

## Runtime Contract

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Wasteland dust mote | Transparent `64x64` restrained steel-grey/amber pixel-art dust fleck with generous empty padding; used by one Main `CPUParticles2D` environment layer | `res://assets/generated/combat_focus_environment_dust_mote.png` |
| Retained source | Opaque chroma-key image-generation source, alpha intermediate and exact prompt/processing record | `res://assets/generated/source/` |

## Visual Direction

The normal Main arena gains sparse, slow atmospheric dust that reads as
environment depth rather than combat VFX. Motes remain behind characters,
interactive props, ground and HUD. They must not resemble signal-red attack
tells, cat-eye-gold focus activation, cyan ability feedback, smoke clouds or
impact debris.

## Focus Behavior

- `FocusEnvironmentParticles` is one continuously emitting `CPUParticles2D`
  with a fixed seed and no gameplay collision.
- Normal mode uses CanvasItem alpha `1.0`.
- Real Player focus entry changes only that particle layer to alpha `0.30`.
- Focus exit restores alpha `1.0`.
- Camera zoom, limits, viewport, background texture, character visibility and
  gameplay timing remain unchanged.
- Do not add a persistent vignette, screen mask, blur or field-of-view change.
  This resolves the GDD's conflicting wording in favor of its explicit
  "no vignette / unchanged view" visual requirement.

## Import And Evidence

- Generate one isolated mote on a perfectly flat removable chroma key and
  retain the source.
- Remove the key, trim the subject and fit it to an exact transparent `64x64`
  runtime canvas with nearest-neighbor scaling.
- Godot imports the PNG as a 2D texture used by the Main particles node.
- Focused tests inspect node type, texture, fixed seed, amount, alpha lifecycle
  and unchanged camera framing. MCP captures normal and focus states in one run
  and checks current-run logs.
