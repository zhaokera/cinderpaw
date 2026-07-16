# Asset Spec: Crown Observatory Wall-Climb Epilogue Ascent

> **Story**: 172
> **Generation policy**: built-in image generation, retained source, Godot 4.7 import

## Runtime Contract

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Observatory ascent background | Opaque RGB `1280x720`; visually continues the Boss4 arena with an upper-left entry, descending ledges, deep central fall, climbable brass/cyan signal spine and upper-right signal platform; no actors, UI, text or flat placeholder geometry | `res://assets/environment/crown_warden_arena/env_crown_observatory_epilogue_ascent_1280x720.png` |
| Retained generation record | Original opaque RGB `1672x941` output plus exact prompt, processing and hashes | `res://assets/generated/source/crown_observatory_epilogue_ascent_imagegen_20260717.*` |

## Scene Mapping

- The plate is centered at world `(1920,360)` and extends the original Arena to
  `2560x720` without changing the first Boss viewport.
- Invisible `StaticBody2D` collision follows the generated entry platform,
  lower landing, middle perch, signal spine and upper-right platform.
- `Area2D` nodes own completion and lethal fall behavior. The generated bitmap
  is presentation only and cannot grant progress by itself.
- The existing generated Recall transmitter moves to the upper-right platform
  and remains hidden until the ascent proof completes.

## Import And Acceptance

- Preserve the source under `assets/generated/source/`; normalize only the
  runtime copy to exact opaque RGB `1280x720`.
- Nearest filtering is authored on the scene `Sprite2D`.
- MCP acceptance must show a non-empty second viewport with Cinderpaw, readable
  collision alignment, the signal spine and the Recall transmitter after
  completion. No magenta key, blank plate, primitive block art or clipped UI is
  acceptable.

## Character Animation Impact

No character or gameplay animation is added. Existing Cinderpaw wall-climb
continues to use `AnimatedSprite2D + SpriteFrames` with at least three frames.
