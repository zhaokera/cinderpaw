# Old Factory Service Lift Motion Sheet Generation Record

> **Date**: 2026-07-19
> **Mode**: built-in image generation
> **Use case**: `stylized-concept`
> **Runtime owner**: Scene Management Story028

## References

- Identity and palette reference:
  `res://assets/environment/old_factory_service_lift/factory_service_lift_console.png`
- Structural reference:
  `res://assets/environment/factory_upper_altar/prop_deep_cistern_ascender_384x512.png`

## Exact Prompt

```text
Use case: stylized-concept
Asset type: production sprite contact sheet for a 2D side-view Godot action game
Primary request: Create one strict 3-column by 3-row sprite contact sheet of the SAME Old Factory industrial freight lift car, with exactly nine cells and one animation frame per cell.
Input images: Image 1 is the exact existing Old Factory service-lift console palette and motif reference; Image 2 is the structural identity and side-view silhouette reference for the actual lift car. Do not redraw the console as the lift.
Subject: A compact open-front freight lift car made from dark riveted steel, worn brass braces, short hydraulic pistons, chain guides, a small amber cat-paw status lamp, and restrained cyan conduit accents. It must read clearly as a traversable lift car in a side-view action game.
Animation layout, left to right:
Row 1 ARRIVE: frame 1 car is high in the cell with lower chains/pistons extended; frame 2 halfway descending; frame 3 fully docked on a single shared baseline.
Row 2 DOCKED IDLE: all three frames stay on the exact same position, silhouette, scale, and baseline; only the amber paw lamp, a tiny piston vibration, and chain tension change subtly.
Row 3 DEPART: frame 1 fully docked on that same baseline; frame 2 halfway ascending; frame 3 high in the cell with lower chains/pistons extended.
Style/medium: hand-painted high-resolution 2D game sprite art, readable hard silhouettes, crisp controlled edges, matching the supplied Cinderpaw industrial assets, suitable for nearest-neighbor downsampling.
Composition/framing: orthographic side view, every cell equal size, every lift exactly the same scale and facing, centered horizontally, generous padding, no clipping. The docked baseline must be identical across row 1 frame 3, all row 2 frames, and row 3 frame 1.
Scene/backdrop: perfectly flat solid #ff00ff chroma-key background across the entire image.
Lighting/mood: cool cyan industrial rim light with warm amber functional lamp; worn but operational.
Color palette: charcoal steel, oxidized teal, muted brass, amber gold, small cyan accents. Do not use magenta anywhere on the subject.
Constraints: exactly 3 columns and exactly 3 rows; exactly one lift car in each cell; no gutters, no visible grid lines, no labels, no text, no numbers, no characters, no enemies, no separate control console, no floor, no wall, no rails continuing beyond the lift, no scenery, no shadow, no reflection, no watermark. Background must be one perfectly uniform #ff00ff with no gradient, texture, lighting variation, cast shadow, contact shadow, or antialias haze. Keep subject identity, perspective, proportions, pivot, and scale consistent across all nine cells.
```

## Processing Record

- Built-in output: `1254x1254` RGB PNG retained as
  `factory_service_lift_motion_sheet_imagegen_20260719.png`.
- The installed imagegen chroma helper sampled key `#f703f8`, used soft matte,
  thresholds `12/220`, and despill. The full transparent intermediate is
  retained as `factory_service_lift_motion_sheet_alpha_20260719.png`.
- The alpha sheet contained exactly nine connected lift components. Components
  were isolated, nearest-neighbor scaled by the shared factor `0.82`, centered
  on `384x384` transparent sRGBA canvases, and aligned to common baseline
  `y=370`.
- `arrive_002`, `docked_idle_000`, and `depart_000` intentionally share the
  same docked pixels so animation-state changes do not jump.
- All runtime frames have transparent corners and continuous filenames. The
  assembled runtime preview is
  `factory_service_lift_motion_frames_preview_20260719.png`.
