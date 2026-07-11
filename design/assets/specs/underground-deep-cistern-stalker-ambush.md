# Asset Spec: Underground Deep Cistern Stalker Ambush

Date: 2026-07-11
Story: `production/epics/player-abilities/story-133-underground-deep-cistern-stalker-ambush.md`
Status: Approved by the active Story133 scope

## Role

Story133 needs a fourth Underground combat viewport and a genuinely new enemy
family. The Cistern Stalker is an amphibious elite whose broad launching
forelimbs, toxic throat, and committed leap distinguish it from Rat and Sluice
Leech silhouettes at gameplay scale.

## Runtime Assets

| Asset | Runtime path | Contract |
|-------|--------------|----------|
| Deep-cistern background | `assets/environment/underground_passage/env_underground_deep_cistern_1280x720.png` | Opaque RGB, exact `1280x720`, continuous side-view combat floor |
| Stalker SpriteFrames | `assets/characters/underground_cistern_stalker/underground_cistern_stalker_sprite_frames.tres` | Six named animations, exactly three frames each |
| Stalker frames | `assets/characters/underground_cistern_stalker/<animation>/underground_cistern_stalker_<animation>_000.png` through `_002.png` | Transparent RGBA, exact `96x96`, common center origin and edge padding |
| Character scene | `scenes/characters/underground_cistern_stalker.tscn` | `AnimatedSprite2D + SpriteFrames` visual owner |
| Gameplay scene | `src/gameplay/underground_cistern_stalker.tscn` | `CharacterBody2D`, body collision, visual child |

## Visual Contract

- The Stalker remains right-facing in source art; runtime direction changes use
  `AnimatedSprite2D.flip_h`.
- `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` each contain three
  distinct poses. Every frame uses the same transparent `96x96` canvas and
  center origin.
- Charcoal skin and rusted iron establish mass; cyan tubes link the creature to
  the Underground; the toxic-green throat is the stable weak-point read.
- Signal red is restricted to raised dorsal spines in the attack tell and
  committed leap poses. Normal locomotion does not use threat red.
- The silhouette must read as a broad amphibious launcher rather than a rat,
  leech, snake, crocodile, dragon, or humanoid.

## Scene Direction

- Fourth background center: `(4480,360)`; route bounds: `0..5120`.
- Continuous arena ground: x `3840..5120`, top y `600`.
- Rear seal: x `3980`; activation threshold: x `4050`; Stalker: `(4520,576)`;
  forward seal: x `4960`; right wall: x `5100`.
- The background may imply deep water behind grates but cannot draw a gap,
  staircase, foreground wall, or blocker across the authored playable floor.

## Runtime Timing

| Animation | FPS | Loop | Gameplay meaning |
|-----------|-----|------|------------------|
| `idle` | 4 | yes | breathing and throat pulse |
| `run` | 9 | yes | low stalking movement |
| `attack_tell` | 8 | no | 24-frame crouch, green throat, red spines |
| `attack` | 12 | no | 6-frame horizontal leap-lunge |
| `hurt` | 8 | no | hit-confirm recoil |
| `death` | 6 | no | collapse and route clear |

## Pipeline

1. Generate one opaque 16:9 arena and one flat-magenta strict `3x6` character
   sheet with built-in image generation.
2. Retain both generated sources. Remove magenta through the installed imagegen
   helper with soft matte/despill, then retain the full alpha sheet.
3. Slice equal cells, normalize each to `88x88` inside a transparent `96x96`
   canvas, and retain a checkerboard preview.
4. Import all source/runtime files through Godot 4.7 and wire the runtime frames
   into one `SpriteFrames` resource.
5. Verify dimensions, alpha corners, edge padding, scene loading, animation
   names/counts, live visibility, and screenshot through focused tests and MCP.

## Generation Records

- `assets/generated/source/underground_deep_cistern_imagegen_20260711.md`
- `assets/characters/underground_cistern_stalker/source/underground_cistern_stalker_sprite_sheet_imagegen_20260711.md`
