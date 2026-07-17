# Quick Design Spec: Old Factory Environment Cohesion

> **Date**: 2026-07-17
> **Story target**: Combat Presentation 034
> **Status**: Approved by active-goal standing direction
> **Scope**: replace stretched route backdrops with generated, unscaled plates

## Decision

Preserve the existing `30080px` Old Factory gameplay route and every authored
encounter, but cover its stretched legacy backgrounds with four generated
`1280x720` environment variants repeated as 24 unscaled `Sprite2D` plates.
This is a Presentation-only cohesion pass, not a route or balance change.

## Visual Contract

- Four opaque plates establish entry assembly, furnace pressure, condenser
  service and tailrace output identities in one blue-black/rust/brass style.
- Every plate keeps a continuous deck edge near runtime `y=500`, dark
  under-deck machinery, strict side view and readable combat space.
- Dark steel edge columns make adjacent plates tolerant of hard seams.
- Local amber, cyan and moonlight accents vary the route without full-frame
  color washes, blurred columns, placeholders, text or baked gameplay guides.
- Runtime plates remain exact `1280x720`, `scale = Vector2.ONE`, use nearest
  filtering and cover `30720px` from world `x=0`.

## Stable Gameplay Contract

| Contract | Preserved value |
|----------|-----------------|
| Ground collision width | `30080px` |
| Ground collision transform | Existing scene-authored value |
| Player and camera | Existing Old Factory runtime |
| Enemies and hazards | Existing instances, activation and timing |
| Route state | Existing flags, gates, rewards and save payload |
| Legacy diagnostics | Existing `Background` and floor/platform nodes retained |

## Out Of Scope

- Collision, platform, camera-limit, encounter, enemy, hazard, reward, save or
  audio changes.
- New parallax, shaders, weather, dynamic lights or gameplay landmarks.
- Replacing existing foreground floor, prop, VFX or character art.

## Acceptance

- [x] Four retained image-generation sources and four exact opaque
  `1280x720` runtime images exist with recorded prompts and SHA-256 hashes.
- [x] `EnvironmentCohesion` creates 24 unscaled plates and reports four unique
  runtime textures over `30720px` coverage.
- [x] Focused Story034 test passes with clean process-exit logs.
- [x] Related floor/platform and animated steam-vent regressions pass.
- [x] Godot AI MCP 3.0.2 shows a loaded scene, 24 runtime plates, clean logs
  and a non-empty gameplay screenshot.
