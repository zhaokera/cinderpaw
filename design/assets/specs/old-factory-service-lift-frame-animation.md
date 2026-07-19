# Asset Spec: Old Factory Service Lift Frame Animation

> **Story**: Scene Management 028
> **Generation policy**: built-in image generation with existing Factory
> references, local chroma-key alpha processing, Godot 4.7 import

## Runtime Contract

| State | Contract | Runtime path |
|-------|----------|--------------|
| `arrive` | Three transparent sRGBA `384x384` frames, non-looping at `4 FPS` | `res://assets/environment/old_factory_service_lift/arrive/factory_service_lift_arrive_000.png` through `_002.png` |
| `docked_idle` | Three transparent sRGBA `384x384` frames, looping at `4 FPS` | `res://assets/environment/old_factory_service_lift/docked_idle/factory_service_lift_docked_idle_000.png` through `_002.png` |
| `depart` | Three transparent sRGBA `384x384` frames, non-looping at `3 FPS` | `res://assets/environment/old_factory_service_lift/depart/factory_service_lift_depart_000.png` through `_002.png` |
| Shared SpriteFrames | One lossless, nearest-filtered `SpriteFrames` resource | `res://assets/environment/old_factory_service_lift/factory_service_lift_sprite_frames.tres` |
| Retained source | Generated RGB sheet, alpha intermediate, runtime preview and exact prompt | `res://assets/environment/old_factory_service_lift/source/factory_service_lift_motion_*_20260719.*` |

## Visual Direction

The prop must read as a real open-front freight lift rather than a blinking
console: dark riveted steel, worn brass braces, hydraulic pistons, chain guides,
amber cat-paw safety light and restrained cyan conduit accents. The existing
call console remains a separate visible interaction anchor.

The generated contact sheet uses telescoping structure for motion. All runtime
frames retain one horizontal center and one bottom anchor. The final arrival
frame and initial departure frame reuse the first docked frame exactly.

## Processing And Import

- Generate one strict `3x3` contact sheet against uniform magenta using the
  existing console for palette identity and Deep Cistern ascender for structure.
- Remove the sampled key with the installed imagegen helper, soft matte and
  despill. Retain both generated and alpha sheets.
- Segment the nine complete connected lift components before cutting; a simple
  equal-cell crop is invalid because the extended hydraulic frames cross row
  boundaries in the source.
- Normalize components with shared scale `0.82`, center `x=192`, baseline
  `y=370`, nearest-neighbor resampling and exact transparent `384x384` canvases.
- Godot imports the PNGs losslessly with mipmaps disabled. The runtime
  `AnimatedSprite2D` explicitly uses nearest filtering.
- This is a large environment-mechanism exception to the Art Bible's legacy
  `32x32` sprite guidance, matching the repository's current `256/384px` sRGBA
  environment asset pipeline. Nine decoded frames cost about `5.06 MiB`; the
  retained console brings the combined decoded surface to about `5.31 MiB`.

## Integration Contract

- `FactoryServiceLift/Visual` remains the existing console and fallback.
- `FactoryServiceLift/LiftAnimation` is the only new `AnimatedSprite2D`; its
  presentation script does not own input, collision, save or SceneManager state.
- First hidden-to-present reveal plays `arrive`, then loops `docked_idle`.
- Only an accepted SceneManager request starts `depart`; rejected requests stay
  docked. Restored exit snapshots hold the last departure frame without replay.
- Lock, available and activated tint mirrors the endpoint's existing semantic
  colors. Animation never delays the existing `1.5s` scene transition.
- MCP acceptance must show the runtime node, frame counts, visible lift,
  accepted `main/scrap_roost` departure, clean logs and a non-empty screenshot.
