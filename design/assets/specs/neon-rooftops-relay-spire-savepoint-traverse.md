# Asset Spec: Neon Rooftops Relay Spire Savepoint Traverse

## Purpose

Story138 follows the Signal Roof combat with a visible recovery anchor and an
ability-driven traversal payoff. Generated art must make the third viewport
read as a dangerous relay-spire gap while the safe roost, climb surface, and
arrival endpoint remain immediately distinguishable.

## Runtime Assets

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Relay Spire background | Opaque RGB `1280x720`; left approach, central climb spire over lethal gap, right exit roof, moonlit ruined skyline | `res://assets/environment/neon_rooftops/env_neon_relay_spire_1280x720.png` |
| Relay Spire Roost | Transparent RGBA `256x256`; low cat-nest silhouette, warm amber safe core, cyan/violet relay details | `res://assets/environment/neon_rooftops/prop_neon_relay_spire_roost_256x256.png` |
| Magnetic Relay Spire | Transparent RGBA `256x512`; tall vertical steel panel, repeated cyan climb bars, cat-ear crown | `res://assets/environment/neon_rooftops/prop_neon_magnetic_relay_spire_256x512.png` |
| Tower Approach Beacon | Transparent RGBA `256x384`; stable endpoint pedestal, moonlight-blue cat-eye core, cyan route line | `res://assets/environment/neon_rooftops/prop_neon_tower_approach_beacon_256x384.png` |

## Scene Use

- The background covers scene x `2560..3840`; invisible collision follows its
  left roof, central spire, upper/lower perches, right roof, and fall gap.
- Story137's generated signal seal is reused at x `2580` and opens only after
  `neon_rooftops_signal_cache_claimed=true`.
- `SavepointRuntime` mounts the roost near x `2760`; the generated spire overlays
  the climb collision at x `3180`; the endpoint sits near x `3690`.
- Cinderpaw reuses existing death, revive, and three-frame `wall_climb`
  `AnimatedSprite2D + SpriteFrames` animation. No new character art is needed.

## Acceptance

- Godot imports every source, alpha, and runtime image without resource errors.
- Background is exact opaque `1280x720`; props retain transparent padding and
  exact `256x256`, `256x512`, and `256x384` dimensions.
- MCP gameplay shows roost, magnetic spire, endpoint, HUD/objective, and
  Cinderpaw visibly playing `wall_climb` over the generated third viewport.
- No visible ColorRect, Polygon2D, debug collision, primitive block, baked text,
  or character placeholder is accepted.
