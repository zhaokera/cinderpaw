# Cinderpaw Dedicated Dash Presentation Asset Spec

## Runtime Contract

- Trigger once from a successful `PlayerController.dash_started` signal.
- Spawn exactly two current-frame afterimages at 20 px and 40 px opposite the
  movement direction, alpha 0.45 and 0.25, lifetime `10.0 / 60.0` seconds.
- Spawn one authored world-space speed-line burst behind Cinderpaw, mirror it
  for left-facing Dash, and fade it over `6.0 / 60.0` seconds.
- Route one separate `dash / sfx_dash` request at the player sprite position.
- Missing character texture may skip the afterimages, but must not block the
  speed-line or audio event. All VFX remain Presentation-only and non-colliding.

## Speed-Line Asset

- Runtime output: transparent `192x64` PNG, hard alpha, Nearest filtering.
- Direction: authored moving right; runtime uses `flip_h` for left.
- Shape: 4-7 sparse horizontal tapered pixel streaks, concentrated behind the
  player with a clear empty leading edge.
- Palette: cool white and restrained moonlight cyan/blue. Do not use signal red
  or dominant cat-eye gold, which communicate threat and parry/player priority.
- No character, afterimage silhouette, scenery, floor, shadow, glow haze, text,
  UI, border, blur, antialiasing or soft alpha.

## Dash Wind SFX

- Runtime output: `44.1 kHz`, mono, PCM16 WAV, non-looping.
- Target duration: about `0.20s`, maximum `0.30s`.
- Fast air-only whoosh with a sharper attack and higher-speed tail than Dodge;
  no cloth flap, impact, alarm, tonal melody or long reverb.
- Stable cue id/path: `sfx_dash` / `res://assets/audio/sfx/sfx_dash.wav`.

## Out Of Scope

Dash movement, cooldown, collision, i-frame rules, camera, hitstop, Dodge,
Perfect Parry, gates, rewards, save data, HUD and non-Main scene integration.
