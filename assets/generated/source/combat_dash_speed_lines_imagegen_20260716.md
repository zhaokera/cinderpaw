# Cinderpaw Dash Speed-Line Source

- Generated on: 2026-07-16
- Tool: built-in image generation
- Runtime path: `res://assets/generated/combat_dash_speed_lines.png`
- Purpose: dedicated world-space speed-line burst for Cinderpaw Dash

## Prompt Contract

Generate a right-facing 2D pixel-art dash effect on a flat magenta chroma key:
five to seven sparse, hard-edged horizontal tapered streaks using cool white,
pale moonlight cyan, and restrained light blue. Keep the far-right leading edge
clear. Do not include a character, environment, floor, shadow, glow haze, text,
UI, border, red, orange, gold, yellow, blur, or antialiasing.

## Pipeline

- Retained built-in source:
  `assets/generated/source/combat_dash_speed_lines_imagegen_20260716.png`
  (`1717x916`, opaque RGB).
- The imagegen chroma helper sampled border key `#f903f3`, applied a soft matte
  and despill, and wrote:
  `assets/generated/source/combat_dash_speed_lines_alpha_20260716.png`.
- The upper three line groups were cropped, the alpha was hard-thresholded,
  then Nearest-resized and centered on an exact transparent `192x64` canvas.
- Runtime visible bounds are `184x53+4+5`; alpha is strictly `0` or `1`.
- Runtime palette contains cool white/cyan/blue only. Horizontal mirroring for
  a left-facing Dash is performed by `CombatPresentation`.
