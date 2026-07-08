# QA Evidence: Old Factory Forward Pressure Coil Rat Breakthrough

Date: 2026-07-08
Engine: Godot 4.7
MCP: Godot AI 2.9.1
Story: `production/epics/player-abilities/story-081-old-factory-lower-deck-forward-pressure-coil-rat-breakthrough.md`

## Scope

Story081 adds a post-relief forward-pressure ACT beat in the Old Factory lower
deck. The slice gates a newly animated Factory Coil Rat behind Story080 relief
ambush completion. Crossing x `1888.0` activates entity `2125`, targets
Cinderpaw, enables enemy process/physics, persists scene-local
activation/defeat state, and preserves the Story074 exit relay savepoint plus
optional service lift.

## Asset Pipeline

New visual assets were generated through image generation and imported through
Godot:

- SpriteFrames:
  `res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`
- Runtime frames:
  `assets/characters/factory_coil_rat/idle/`,
  `assets/characters/factory_coil_rat/run/`,
  `assets/characters/factory_coil_rat/attack_tell/`,
  `assets/characters/factory_coil_rat/attack/`,
  `assets/characters/factory_coil_rat/hurt/`, and
  `assets/characters/factory_coil_rat/death/`, each with
  `factory_coil_rat_<animation>_000.png` through `_002.png`.
- Source:
  `assets/characters/factory_coil_rat/source/factory_coil_rat_sprite_sheet_imagegen_20260708.png`
- Alpha-matted source:
  `assets/characters/factory_coil_rat/source/factory_coil_rat_sprite_sheet_alpha_20260708.png`
- Preview:
  `assets/characters/factory_coil_rat/source/factory_coil_rat_frames_preview_20260708.png`
- Prompt and processing metadata:
  `assets/characters/factory_coil_rat/source/factory_coil_rat_sprite_sheet_imagegen_20260708.md`

The generated source was produced on green chroma key, alpha-matted locally,
sliced into 3 columns x 6 rows, normalized into transparent 96x96 PNG frames,
and imported by Godot. Runtime usage is recorded in
`design/assets/asset-manifest.md` and `design/assets/entity-inventory.md`.

## Automated Verification

- RED focused: `reports/report_1154/` failed as expected after adding Story081
  tests, because the Coil Rat diagnostics and activation APIs did not exist.
- Focused + related GREEN: `reports/report_1161/` passed Story081, Story080,
  Story079, Story078, Story077, Story076, Story075, Story074, service-lift, and
  no-loss respawn suites `22/22` with no errors, failures, skips, flaky cases,
  or orphans.
- Headless scene smoke:
  `reports/old_factory_forward_pressure_coil_rat_breakthrough_smoke.log`
  exited `0`. Keyword scan found no project script, parse, invalid-call,
  invalid-access, missing-resource, or resource-load errors.

The headless terminal output still includes the known Godot cleanup-time
`ObjectDB` / `resources still in use at exit` messages; no current project
script/resource failure was reproduced.

## MCP Runtime Verification

Godot AI MCP `2.9.1` on Godot `4.7-stable` launched
`res://scenes/factory_route_transition_shell.tscn` with `autosave=false` and
confirmed helper live with no startup `recent_errors`.

- Ready state after Story080 completion: Coil Rat present, available, inactive,
  hidden, and route feedback remained `Forward Pressure Relief Ambush Cleared`.
- Activation state: manual activation after x `1888.0` returned `true`; entity
  `2125` became visible at `(1916, 482)`, had target, process/physics enabled,
  enemy family `factory_coil_rat`, route feedback
  `Face Coil Rat Breakthrough`, and SpriteFrames path
  `res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`.
- Runtime node inspection confirmed
  `/root/FactoryRouteTransitionShellScene/FactoryLowerDeckForwardPressureCoilRat`
  as visible `CharacterBody2D` with script
  `res://src/gameplay/factory_coil_rat.gd`.
- Runtime child inspection confirmed
  `/root/FactoryRouteTransitionShellScene/FactoryLowerDeckForwardPressureCoilRat/Sprite`
  as visible `AnimatedSprite2D` with script
  `res://src/characters/factory_coil_rat.gd`, animation `idle`, and
  `factory_coil_rat_sprite_frames.tres`.
- SpriteFrames probe confirmed `attack`, `attack_tell`, `death`, `hurt`,
  `idle`, and `run`, each with 3 frames.
- Defeat state: `apply_damage(2125, 999, ...)` returned `true`; enemy disabled;
  local flags
  `factory_lower_deck_forward_pressure_coil_rat_breakthrough_activated` and
  `factory_lower_deck_forward_pressure_coil_rat_breakthrough_defeated`
  persisted as `true`; route feedback became
  `Forward Pressure Coil Rat Breakthrough Cleared`; route objective reported
  complete.
- Fresh restored completed state kept Story081 inactive/defeated, kept Story080
  relief ambush defeated, kept Story079 breaker cut, preserved Story074 relay
  savepoint `old_factory_lower_deck_forward_pressure_exit_relay` and spawn
  point `lower_deck_forward_pressure_exit_relay`, kept Story071 cache claimed
  with `claim_audio_request_count=0`, kept Story068 clear feedback
  `spawn_count=0`, and preserved `FactoryServiceLift` prompt `Call lift`.
- MCP `editor_screenshot(source="game")` returned a non-empty `960x539`
  framebuffer showing the Coil Rat. The current runtime viewport was also saved
  to
  `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-coil-rat-breakthrough-20260708.png`
  for file-based visual evidence.
- Formal MCP logs after clearing discarded eval-probe warnings: game log
  contained only the helper registration line; editor log was empty.

## Result

PASS. Story081 adds a visible, playable post-relief ACT beat, introduces a new
image-generated Factory Coil Rat enemy family with compliant
`AnimatedSprite2D + SpriteFrames` animation, persists breakthrough completion,
avoids prerequisite replay on restore, preserves the existing exit relay and
service lift contracts, and passes focused, related, headless, MCP runtime, log,
and screenshot checks.
