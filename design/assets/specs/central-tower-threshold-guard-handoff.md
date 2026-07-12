# Asset Spec: Central Tower Threshold Guard Handoff

## Purpose

Story140 turns the secured rooftop laser threshold into a playable first Tower
room: enter, activate a real savepoint, cross into a one-guard arena, survive a
telegraphed latch thrust, open the inner seal, and return to Neon Rooftops.

## Runtime Assets

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Threshold background | Opaque RGB `1280x720`; left exterior opening, broad arena floor, layered Tower machinery, right inner passage | `res://assets/environment/central_tower/env_central_tower_threshold_1280x720.png` |
| Inner security seal | Transparent RGBA `384x512`; heavy closed cat-ear frame with signal-red lock core | `res://assets/environment/central_tower/prop_central_tower_inner_seal_384x512.png` |
| Threshold Roost | Transparent RGBA `256x256`; cat-nest savepoint using safe gold and cyan semantics | `res://assets/environment/central_tower/prop_central_tower_threshold_roost_256x256.png` |
| Guard dock | Transparent RGBA `256x256`; low inactive maintenance plinth | `res://assets/environment/central_tower/prop_central_tower_guard_dock_256x256.png` |
| Threshold Guard | Six animations with exactly three transparent `96x96` frames each; common y=88 baseline and continuous naming | `res://assets/characters/central_tower_threshold_guard/central_tower_threshold_guard_sprite_frames.tres` |

## Scene Use

- The background covers one exact viewport and keeps all gameplay objects out of
  baked art. Authored bodies align the walkable floor and four boundaries.
- The same generated seal texture is mounted on rear and inner collision gates;
  the rear is horizontally mirrored for visual direction.
- Threshold Roost is a real `SavepointRuntime`, not decorative checkpoint text.
- The guard's dock sits beneath its idle start position without owning collision.
- The guard maps `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` to
  live gameplay state through `AnimatedSprite2D + SpriteFrames`.

## Acceptance

- Godot imports every source, alpha, runtime PNG, and SpriteFrames resource.
- Background is exact opaque `1280x720`; props preserve alpha and safe padding;
  all 18 frames are transparent `96x96` with a common bottom anchor.
- MCP gameplay shows Cinderpaw, generated room/props, the animated guard, HUD and
  objective; a real attack state is visible and current-run logs are clean.
- No visible ColorRect, Polygon2D, debug collision, primitive block, baked text,
  Boss substitute, or single-frame character is accepted.
