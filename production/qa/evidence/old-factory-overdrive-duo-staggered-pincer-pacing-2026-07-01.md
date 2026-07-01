# QA Evidence: Old Factory Overdrive Duo Staggered Pincer Pacing

> **Story**: Player Abilities Story 050
> **Engine**: Godot `4.7.stable.official.5b4e0cb0f`
> **Date**: 2026-07-01

## Scope

Story050 changes the overdrive duo from synchronized wake-up timing to a
staggered pincer beat. The left Spark Rat pressures first after `12` opening
grace frames; the right Spark Rat delays with `30` opening grace frames.

No new visual assets were generated. The story reuses the existing
image-generated Factory Spark Rat frame animation set.

## Automated Verification

- Focused RED: `reports/report_1018/`
  - Failed on the new staggered pacing acceptance test because
    `advance_factory_checkpoint_overdrive_duo_pacing_frames()` was missing.
- Focused GREEN: `reports/report_1019/`
  - Passed `4/4`, `0` errors, `0` failures, `0` flaky, `0` skipped,
    `0` orphans.
- Related regression: `reports/report_1021/`
  - Passed `14/14`, `0` errors, `0` failures, `0` flaky, `0` skipped,
    `0` orphans.
  - Covered overdrive duo, Spark Rat pacing polish, rear ambush handoff, and
    service-lift SceneManager exit suites.

## Asset / Animation Evidence

- New visual assets: none.
- Reason: Story050 only changes duo pacing/stagger timing.
- Reused assets:
  - `res://src/gameplay/factory_spark_rat.tscn`
  - `res://scenes/characters/factory_spark_rat.tscn`
  - `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- MCP diagnostics confirmed both overdrive rats use:
  - `Sprite` type `AnimatedSprite2D`
  - SpriteFrames:
    `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
  - `idle=3`
  - `run=3`
  - `attack_tell=3`
  - `attack=3`
  - `hurt=3`
  - `death=3`

## Godot MCP Runtime Evidence

MCP session used Godot `4.7-stable (official)`.

Runtime probe:

- Target scene:
  `res://scenes/factory_route_transition_shell.tscn`
- Duo activated after restoring the Story049 prerequisite state:
  `factory_checkpoint_rear_ambush_defeated=true`.
- Activation diagnostics:
  - `activated_ok=true`
  - left `opening_grace_frames=12`
  - left `opening_grace_total_frames=12`
  - left `pacing_state=opening_grace`
  - right `opening_grace_frames=30`
  - right `opening_grace_total_frames=30`
  - right `pacing_state=opening_grace`
  - aggregate `opening_grace_total_frames=30`
- Stagger window diagnostics after advancing `left_grace + 2` frames with
  Cinderpaw in left melee range:
  - left `pacing_state=attack_tell`
  - left `current_animation=attack_tell`
  - left `attack_sequence_id=1`
  - left `opening_grace_frames=0`
  - right `pacing_state=opening_grace`
  - right `current_animation=idle`
  - right `attack_sequence_id=0`
  - right `attack_active=false`
  - right `opening_grace_frames=16`
- Local state after the stagger probe:
  - `factory_checkpoint_overdrive_left_opening_grace_frames=0`
  - `factory_checkpoint_overdrive_right_opening_grace_frames=16`

Logs and screenshot:

- MCP screenshot returned PNG metadata `640x359`, original framebuffer
  `1278x718`, confirming non-empty runtime capture.
- Reading `godot://logs/recent` after clearing logs returned only MCP/plugin
  `info` rows for eval, screenshot, and log read; no current `error` or
  `warning` rows were present.
- MCP `project_run` still surfaced stale retained editor parse rows marked
  `recent_errors_may_predate_run=true`; current Godot 4.7 GdUnit and post-clear
  MCP runtime evidence loaded and executed the scene successfully.

## Verdict

PASS. Story050 adds readable staggered pincer pacing to the existing overdrive
duo, preserves Story049 service-lift gate behavior, avoids new asset scope, and
passes focused, related, and MCP 4.7 runtime verification.
