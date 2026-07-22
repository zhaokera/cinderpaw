# Old Factory Pressure Valve Authored Motion

> **Status**: Approved for production; source generation pending
> **Owner**: Player Abilities Story181
> **Engine**: Godot 4.7
> **Generator**: built-in image generation / image2
> **Date**: 2026-07-20

## Purpose

Replace the generic cat-paw endpoint shown at
`FactoryLowerDeckPressureValve` with a dedicated pressure-valve mechanism. The
presentation must make the guarded, opening and opened route states readable
without changing the Story058 interaction, collision, persistence or route
progression contract.

## Runtime Contract

- Render through `AnimatedSprite2D + SpriteFrames` at
  `FactoryLowerDeckPressureValve/ValveAnimation`.
- Preserve the endpoint root position `(1220, 400)`, endpoint id
  `old_factory_lower_deck_pressure_valve` and `96px` activation radius.
- Keep the existing `Visual: Sprite2D` node for shared endpoint compatibility,
  but hide it after the dedicated animation is connected.
- Initial layout target: local position `(40, 8)`, scale `(0.8, 0.8)`, relative
  `z_index=1`, Nearest texture filtering. Final transform requires MCP screenshot
  review beside the service lift and Deep Bulkhead.
- Presentation derives state from existing scene flags. Animation completion
  must never activate the endpoint or write progression state.
- A restored `factory_lower_deck_pressure_valve_opened=true` snapshot starts in
  `opened_idle`; it does not replay `opening`.

## Production Exception

This Story-specific contract supersedes the older generic foreground-prop
limits in `design/art/art-bible.md` for this animated environment mechanism.
The valve intentionally uses image-generated sRGBA `256x256` standalone PNG
frames at `4/6/4` FPS and the exact file names below, matching the established
Old Factory service-lift pipeline. This exception does not change character
animation rules or permit per-frame pivot, scale or baseline drift.

## Frame Contract

| Animation | Frames | FPS | Loop | Purpose |
|-----------|--------|-----|------|---------|
| `closed_idle` | 3 | 4 | yes | Locked or available valve; endpoint tint/prompt distinguishes availability |
| `opening` | 3 | 6 | no | Accepted interaction rotates the wheel and lowers the gauge |
| `opened_idle` | 3 | 4 | yes | Persisted safe/open valve state |

- Runtime frames: nine transparent sRGBA `256x256` PNGs.
- Common pivot: `(128, 128)`; common mounting baseline: `y=240`.
- Recommended content bounds: `x=40..216`, `y=16..240`.
- Frame names are continuous `_000.._002`; no per-frame recentering.
- `opening_000` should visually match the closed pose and `opening_002` should
  match `opened_idle_000` to avoid transition jumps.

## File Layout

```text
assets/environment/old_factory_pressure_valve/
  closed_idle/factory_pressure_valve_closed_idle_000.png
  closed_idle/factory_pressure_valve_closed_idle_001.png
  closed_idle/factory_pressure_valve_closed_idle_002.png
  opening/factory_pressure_valve_opening_000.png
  opening/factory_pressure_valve_opening_001.png
  opening/factory_pressure_valve_opening_002.png
  opened_idle/factory_pressure_valve_opened_idle_000.png
  opened_idle/factory_pressure_valve_opened_idle_001.png
  opened_idle/factory_pressure_valve_opened_idle_002.png
  source/factory_pressure_valve_motion_sheet_imagegen_20260720.png
  source/factory_pressure_valve_motion_sheet_alpha_20260720.png
  source/factory_pressure_valve_motion_frames_preview_20260720.png
  source/factory_pressure_valve_motion_sheet_imagegen_20260720.md
  factory_pressure_valve_sprite_frames.tres
```

## Image2 Prompt

```text
Use case: stylized-concept
Asset type: production sprite contact sheet for a 2D side-view Godot action game named Cinderpaw.
Primary request: Create one strict 3-column by 3-row sprite contact sheet of the SAME compact Old Factory pressure valve manifold, with exactly nine equal cells and one animation frame per cell.
Subject: a narrow bolt-on industrial pressure-valve mechanism made from riveted charcoal-blue steel and oxidized copper pipework, with one large unmistakable circular brass handwheel with six spokes, a heavy yoke and locking dog, short flanged pipes, one small analog pressure gauge with no readable numbers, a restrained amber practical lamp, tiny cyan conduit accents, and a hard readable silhouette. It must immediately read as a pressure valve, not a call console, checkpoint, reward chest, door, pedestal, altar, shrine, fan, or cat-paw switch. No paw symbol.
Animation layout, left to right:
Row 1 CLOSED_IDLE: three closed-state idle frames on the exact same baseline, scale, body geometry, wheel angle and pipe connections. The gauge needle stays high while only a subtle needle tremor, pipe vibration and dim amber lamp pulse change.
Row 2 OPENING: frame 1 starts closed and high-pressure; frame 2 rotates the handwheel about 45 degrees clockwise, retracts the locking dog and lowers the gauge halfway; frame 3 completes about 90 degrees of rotation and lowers the gauge to safe pressure. Keep the body fixed.
Row 3 OPENED_IDLE: three opened-state idle frames with the wheel fixed at the final 90-degree angle and the gauge low; only a subtle settled gauge movement, tiny cyan conduit pulse and small safe amber lamp pulse change.
Style and medium: richly detailed hand-painted painterly pixel-art game sprite with crisp controlled hard edges and readable silhouette, suitable for nearest-neighbor downsampling. Match a moody side-view abandoned industrial factory using charcoal steel, dark blue-black shadows, dark rust, oxidized teal copper, muted brass, restrained cyan rim light and warm amber machinery lamps. No photorealism, smooth vector style or plastic 3D render appearance.
Composition: strict orthographic side view with a slight readable front face. Every mechanism has identical scale, facing, body proportions, wheel center, mount point and bottom baseline. Center each subject with generous padding and no clipping or cell crossing.
Backdrop: one perfectly uniform solid #FF00FF chroma-key background across the complete sheet. Do not use magenta anywhere on the subject.
Constraints: exactly 3 columns and 3 rows; exactly one complete valve in every cell; no gutters, grid lines, labels, text, letters, numbers, arrows, logos, UI, characters, enemies, floor, wall, lift car, separate console, scenery, steam cloud, smoke, shadow, reflection or watermark. No changing perspective, scale, pivot, baseline or body proportions. No bloom, antialias haze or background gradient.
```

## Processing And Import

1. Retain the RGB built-in output as the source artifact.
2. Remove the sampled magenta border key with the installed imagegen chroma
   helper, soft matte and despill. Retry once with `edge-contract=1` if needed.
3. Split the strict `3x3` sheet, compute one union alpha crop for all frames,
   and apply one shared scale and baseline to all nine canvases.
4. Validate exact dimensions, sRGBA alpha, transparent corners, common baseline,
   subject coverage and absence of magenta fringe.
5. Import losslessly in Godot with Nearest filtering and mipmaps disabled.
6. Record source/runtime SHA-256, sampled key, matte settings, crop, scale,
   pivot, baseline, frame paths, FPS and loops in the source record and asset
   manifest.

## Runtime Acceptance

- Locked/guarded and available screenshots show the dedicated valve beside the
  service lift without being hidden by the lift car.
- Opened and Deep Bulkhead states keep the valve wheel/status readable without
  covering the door, player or prompt.
- The old generic endpoint texture is not visible in gameplay.
- MCP reports all three animations at exactly three frames, loop modes
  `true/false/true`, Nearest filtering, clean logs and a non-empty screenshot.
