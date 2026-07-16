# Asset Spec: Neon Rooftops Central Tower Parry-Laser Motion Readability

> **Story**: Player Abilities 170
> **Generation policy**: built-in image generation with the Story139 laser as
> reference, chroma-key alpha processing, Godot 4.7 import

## Runtime Contract

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Telegraph | Three transparent sRGBA `512x128` charge frames, looping at `5 FPS` | `res://assets/environment/neon_rooftops/tower_parry_laser/telegraph/tower_parry_laser_telegraph_000.png` through `_002.png` |
| Strike | Three transparent sRGBA `512x128` continuous danger frames, non-looping at `16.666667 FPS` | `res://assets/environment/neon_rooftops/tower_parry_laser/strike/tower_parry_laser_strike_000.png` through `_002.png` |
| Reflected recovery | Three transparent sRGBA `512x128` cyan/gold success frames, non-looping at `5.454545 FPS` | `res://assets/environment/neon_rooftops/tower_parry_laser/recovery_reflected/tower_parry_laser_recovery_reflected_000.png` through `_002.png` |
| Missed recovery | Three transparent sRGBA `512x128` red/orange decay frames, non-looping at `5.454545 FPS` | `res://assets/environment/neon_rooftops/tower_parry_laser/recovery_missed/tower_parry_laser_recovery_missed_000.png` through `_002.png` |
| Shared SpriteFrames | Four named animations mapped by the existing controller state | `res://assets/environment/neon_rooftops/tower_parry_laser/tower_parry_laser_sprite_frames.tres` |
| Retained source | Four RGB strips, alpha intermediates, preview and prompt record | `res://assets/environment/neon_rooftops/tower_parry_laser/source/` |

## Visual Direction

- Preserve the Story139 horizontal beam identity: white-hot core, signal-red
  threat envelope, cyan electrical arcs and symmetric endpoint bursts.
- Telegraph converges around an unsafe center gap; strike is continuous and
  brightest; reflected recovery uses cyan direction and one gold parry spark;
  missed recovery removes cyan success language and decays into red fragments.
- Every state uses the same center, scale and side-view camera. Presentation
  must never shift the gameplay anchor.

## Processing And Import

- Generate one strict three-cell strip per state on a uniform `#ff00ff`
  background using the legacy pulse as a reference.
- Remove the sampled border key with soft matte thresholds `28/90`, one-pixel
  edge contract and despill.
- Each generated strip is `2172x724` with exact `724x724` cells. Fixed-crop
  source rows `y=226..481`, resize each cell to `492x128`, and center it with
  ten transparent side pixels on an exact `512x128` canvas.
- Do not trim or independently recenter individual frames. All twelve runtime
  frames require transparent outer edges and alpha blend data.
- Import with Godot 4.7 and validate the shared SpriteFrames plus runtime
  AnimatedSprite2D through MCP.

## Performance Budget

- Twelve runtime PNGs total `380 KiB`; decoded RGBA texture budget is `3 MiB`.
- At most one `512x128` quad is visible; no extra draw call beyond replacing
  the legacy visible pulse.
- No particles, shader, material, `_process` loop or dynamic texture creation.
- Source/alpha/preview files are retained for traceability and are not
  preloaded by runtime code.
