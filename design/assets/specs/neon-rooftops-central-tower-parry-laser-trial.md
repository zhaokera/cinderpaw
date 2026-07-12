# Asset Spec: Neon Rooftops Central Tower Parry-Laser Trial

## Purpose

Story139 converts the exploration GDD's Central Tower laser-net prerequisite
into a readable ACT timing challenge. Generated art must distinguish the fourth
rooftop viewport from the relay gap, frame the tower as a future destination,
and keep telegraph, strike, reflected pulse, closed gate, and secured threshold
legible behind Cinderpaw and the HUD.

## Runtime Assets

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Tower exterior background | Opaque RGB `1280x720`; flat trial roof, open center lane, immense right-side tower facade, no baked interactive props | `res://assets/environment/neon_rooftops/env_neon_tower_parry_trial_1280x720.png` |
| Tower laser gate | Transparent RGBA `384x512`; cat-ear steel emitter frame, clear vertical collision silhouette, cyan/amber status lights | `res://assets/environment/neon_rooftops/prop_neon_tower_laser_gate_384x512.png` |
| Parry laser pulse | Transparent RGBA `512x128`; straight white/red strike core with cyan electric edge accents and readable reflected tint | `res://assets/environment/neon_rooftops/vfx_neon_tower_laser_pulse_512x128.png` |
| Threshold beacon | Transparent RGBA `256x384`; cat-paw pedestal, cyan state core, stable rooftop base | `res://assets/environment/neon_rooftops/prop_neon_tower_threshold_beacon_256x384.png` |

## Scene Use

- The background covers x `3840..5120`; authored collision owns the floor,
  top boundary, route seal, tower gate, trial Area2D, endpoint, and right wall.
- Story138's generated signal seal is reused at x `3860` until its endpoint
  state is complete. The laser gate sits near x `4740`; the threshold beacon
  sits near x `4970` and is hidden until the gate opens.
- `LaserPulseVisual` uses the generated pulse texture. Controller modulation
  differentiates telegraph, white/red strike, cyan reflection, and failed
  recovery without duplicating images.
- Cinderpaw reuses the existing three-frame `parry` animation through
  `AnimatedSprite2D + SpriteFrames`; no new character art is required.

## Acceptance

- Godot imports every source, alpha, runtime image, scene, and script without a
  current-run resource or parser error.
- Background is exact opaque `1280x720`; props/VFX retain transparent padding
  and exact `384x512`, `512x128`, and `256x384` dimensions.
- Closed gate, live strike, cyan reflection, Cinderpaw, objective, HP, weapon,
  and currency HUD remain readable in one `1278x718` gameplay capture.
- MCP real input must expose Cinderpaw's `parry` animation and advance the
  objective from `0/3` to `1/3`; file-only inspection is insufficient.
- No visible ColorRect, debug collision, primitive block, baked prompt, text,
  character placeholder, or opaque key-color background is accepted.
