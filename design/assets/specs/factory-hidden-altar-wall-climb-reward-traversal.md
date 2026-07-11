# Asset Spec: Factory Hidden Altar Wall Climb Reward Traversal

## Purpose

Story135 converts the Story134 dormant landmark into a visible traversal reward.
The activated altar, magnetic wall, contact feedback, and Cinderpaw animation
must make the new movement readable as a deliberate Old Factory ability test,
not an invisible flag unlock or a placeholder collision exercise.

## Runtime Assets

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Cinderpaw wall-climb frames | Three transparent RGBA `96x96` frames with consistent cell pivot, scale, and right-facing identity | `res://assets/characters/cinderpaw/wall_climb/cinderpaw_wall_climb_000.png` through `_002.png` |
| Awakened feline altar | Transparent RGBA `384x384`; same altar silhouette as dormant state; cyan/violet energized core | `res://assets/environment/factory_upper_altar/prop_factory_hidden_altar_awakened_384x384.png` |
| Factory magnetic wall | Transparent RGBA `256x512`; tall climbable steel panel with cyan magnetic seams | `res://assets/environment/factory_upper_altar/prop_factory_magnetic_wall_256x512.png` |
| Wall-contact glow | Transparent RGBA `192x192`; cyan/violet claw-contact burst without baked wall or character | `res://assets/environment/factory_upper_altar/vfx_wall_climb_contact_glow_192x192.png` |

## Scene Use

- Claiming the discovered altar swaps the dormant sprite to the awakened sprite
  for the full restored lifetime of the scene.
- The generated magnetic-wall sprite is backed by authored StaticBody2D
  collision. The generated contact glow appears on valid wall-climb entry.
- `cinderpaw_sprite_frames.tres` exposes the three frames as looping
  `wall_climb`; PlayerController keeps higher-priority combat, damage, death,
  revive, dodge, dash, parry, and aerial-attack states authoritative.
- A collision-backed one-way proof perch and high Area2D complete the route, but
  no Neon Rooftops art or destination scene is implied by these assets.

## Acceptance

- Godot imports all four runtime asset groups without resource errors.
- Every runtime PNG has the exact dimensions above, and transparent assets do
  not carry visible magenta fringe or touch their canvas edge incoherently.
- MCP gameplay shows Cinderpaw, the awakened altar, magnetic wall, contact
  feedback, high perch, objective, and HUD in a non-empty frame.
- No ColorRect, flat rectangle, single-frame character substitute, text baked
  into art, or primitive placeholder is accepted as the visible reward proof.
