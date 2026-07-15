# Asset Spec: Central Tower Crown Warden Arena Handoff

> **Story**: 145
> **Generation policy**: built-in image generation, retained source, Godot import
> **Character note**: Crown Warden character art is intentionally deferred to
> Story146, where its complete frame-animation contract will land with combat

## Runtime Assets

| Asset | Contract | Runtime path |
|-------|----------|--------------|
| Crown Observatory background | Opaque RGB `1280x720`; readable side-view arena floor, mechanical orrery, moonlit skyline, cyan/violet machinery and restrained amber focal lighting; no baked player, Boss, UI, text, route gate or hitbox | `res://assets/environment/crown_warden_arena/env_crown_warden_observatory_1280x720.png` |
| Central Tower crown gate | Transparent RGBA `256x384`; crown-shaped steel/brass threshold with cyan lens, readable silhouette and no keyed-color rectangle | `res://assets/environment/central_tower/prop_central_tower_crown_gate_256x384.png` |

## Image Generation Prompts

Exact prompts are retained beside the generated sources:

- Background: `assets/generated/source/crown_warden_observatory_background_imagegen_20260712.prompt.md`
- Crown gate: `assets/generated/source/central_tower_crown_gate_imagegen_20260712.prompt.md`

The background prompt requests a full-frame side-view mechanical observatory
that can carry a future aerial Boss encounter while leaving the gameplay floor
clear. The gate prompt requests one isolated threshold prop over a uniform
magenta key. Both explicitly exclude characters, Boss silhouettes, text and UI.

## Processing

- Retain the original RGB `1672x941` background and `1024x1536` keyed gate
  source under `assets/generated/source/`.
- Normalize the background to exact opaque sRGB RGB `1280x720` without changing
  its composition or baking gameplay actors into it.
- Sample the gate border key (`#fb02f9`), create a soft alpha matte, despill the
  key color, trim the non-empty visual, preserve aspect ratio and center it on
  an exact transparent sRGBA `256x384` runtime canvas.
- Retain `central_tower_crown_gate_alpha_20260712.png` as the full-size alpha
  intermediate. The runtime gate keeps transparent corners and a non-empty
  `189x352` visual bound at offset `(33,16)`.
- Authored Godot nodes own collision, route availability, prompts and scene
  requests. Generated images provide presentation only.

## MCP Visual Acceptance

- The `1280x720` arena opens and runs through Godot MCP with generated
  background, crown gate, Cinderpaw and both labels visible.
- Cinderpaw remains an `AnimatedSprite2D`; Story145 must contain no Crown Warden
  actor, static Boss prop, Boss HUD, seals, attack or reward placeholder.
- The return prompt and objective stay fully inside the `1278x718` game frame
  without overlapping each other or clipping at the viewport edge.
- The frame contains no solid-color placeholder geometry, magenta key box,
  blank render or incoherent text overlap.
