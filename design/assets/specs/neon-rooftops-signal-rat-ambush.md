# Asset Spec: Neon Rooftops Signal Rat Ambush

## Purpose

Story137 turns the safe Story136 high roof into a complete ACT beat: descend,
read a sealed ambush, evade a telegraphed Signal Rat lunge, clear the arena,
and claim a rooftop cache. Generated art must make the second viewport read as
a distinct signal relay roof while authored collision remains invisible.

## Runtime Assets

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Signal Roof background | Opaque RGB `1280x720`; upper-left descent, broad grounded arena, right exit, readable moonlit skyline | `res://assets/environment/neon_rooftops/env_neon_signal_roof_1280x720.png` |
| Signal seal | Transparent RGBA `256x384`; tall steel blocker, cyan conduits, signal-red lock core | `res://assets/environment/neon_rooftops/prop_neon_signal_seal_256x384.png` |
| Signal cache | Transparent RGBA `256x256`; compact reinforced reward box, violet/cyan relay language, cat-paw latch | `res://assets/environment/neon_rooftops/prop_neon_signal_cache_256x256.png` |
| Neon Signal Rat | Six animations with exactly three transparent `96x96` frames each; common bottom anchor and continuous naming | `res://assets/characters/neon_signal_rat/neon_signal_rat_sprite_frames.tres` |

## Scene Use

- The second background covers scene x `1280..2560`; descent platforms and the
  arena floor are real invisible collision aligned with its painted surfaces.
- Two authored StaticBody2D seals reuse the generated gate at x `1540/2440`.
  Their collision enables only while the encounter is active.
- The cache remains hidden until entity `2601` is defeated, then exposes one
  `+20 Gears` interaction near x `2320`.
- `NeonSignalRat/Sprite` uses `AnimatedSprite2D + SpriteFrames` and maps
  `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` to gameplay state.

## Acceptance

- Godot imports every source, alpha, runtime PNG, and SpriteFrames resource.
- Background is exact opaque `1280x720`; props preserve alpha and safe padding;
  all 18 character frames are transparent `96x96` with a shared anchor.
- MCP gameplay shows the generated arena, both seals, Cinderpaw, the animated
  Signal Rat, readable objective/HUD, and real input combat without overlap.
- No visible ColorRect, Polygon2D, debug collision, primitive block, baked text,
  or single-frame character substitute is accepted.
