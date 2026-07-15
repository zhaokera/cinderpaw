# Asset Spec: Main Scene Focus Mode Boss Attack Tell

> **Story**: Player Abilities 158
> **Generation policy**: built-in image generation, retained keyed source,
> deterministic alpha processing, Godot 4.7 import

## Runtime Contract

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Focus attack-tell VFX | Transparent `256x128` signal-red pixel-art warning aura with an open center; shared by Rat King and Echo Guardian as a `Sprite2D` behind the character | `res://assets/generated/combat_focus_mode_boss_attack_tell.png` |
| Retained source | Opaque chroma-key image-generation source, alpha intermediate and exact prompt/processing record | `res://assets/generated/source/` |

## Visual Direction

The effect is a hostile attack-warning field, not a character, hitbox or HUD
icon. A broken angular ellipse, short claw-like directional marks and restrained
red-orange sparks create a readable signal-red silhouette around a charging
Boss while leaving the center transparent so the existing multi-frame attack
animation remains visible. It must read against the steel, rust, violet and
gold Main arena without resembling the cat-eye-gold focus activation border.

## Runtime Behavior

- Every new Rat King or Echo Guardian attack shows one stable-named
  `FocusAttackTell` `Sprite2D` during the visual tell window.
- Normal area and duration multipliers are `1.0`.
- An attack started while Player focus is active freezes area multiplier
  `1.25` and duration multiplier `1.10` for that tell.
- Character scale, attack hitbox, damage, active/recovery timing and animation
  speed remain unchanged.
- The source art contains no character, environment, UI, text, shadow, opaque
  rectangle or full-screen treatment.

## Import And Evidence

- Generate on a perfectly flat removable `#00FF00` key and retain the source.
- Remove the key with the project imagegen helper, then fit the selected art to
  an exact transparent `256x128` runtime canvas using nearest-neighbor scaling.
- Godot imports the PNG as a 2D texture. Focused tests inspect alpha, node type,
  texture path, multipliers, lifecycle and unchanged character scale.
- MCP must verify both Bosses in startup, three-frame attack animation, visible
  warning fields, non-empty screenshot and clean current-run logs.
