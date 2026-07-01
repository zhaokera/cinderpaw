# QA Evidence: Old Factory Overdrive Defeat Burst

Date: 2026-07-01
Story: `production/epics/player-abilities/story-052-old-factory-overdrive-defeat-burst.md`
Engine: Godot `4.7.stable.official.5b4e0cb0f`
MCP session: `cinderpaw@4400`, Godot MCP plugin/server `2.8.1`

## Scope

Story052 adds a small player-facing defeat VFX payoff for the Old Factory
checkpoint overdrive duo. The existing animated Factory Spark Rat enemies remain
the character actors; this story adds generated non-character `Sprite2D` burst
VFX nodes when entity `2106` or `2107` is defeated.

## Asset Evidence

- Built-in image generation source:
  `/Users/zhaok/.codex/generated_images/019ef041-d084-7212-b09b-7067e06fcf05/ig_05d5cda509778842016a4487b41fcc8191b43b9f2739263fde.png`.
- Project source:
  `assets/generated/source/old_factory_overdrive_defeat_burst_imagegen_20260701.png`.
- Alpha source:
  `assets/generated/source/old_factory_overdrive_defeat_burst_alpha_20260701.png`.
- Runtime PNG:
  `assets/environment/old_factory_overdrive_defeat_burst/vfx_old_factory_overdrive_defeat_burst_256.png`.
- Metadata:
  `assets/generated/source/old_factory_overdrive_defeat_burst_imagegen_20260701.json`.
- Manifest:
  `design/assets/asset-manifest.md`.
- Processing:
  - Chroma key removed with `remove_chroma_key.py --auto-key border --soft-matte --transparent-threshold 12 --opaque-threshold 220 --despill`.
  - Runtime PNG resized to `256x256`.
  - Godot import completed and `.import` files exist for source, alpha, and runtime PNG.

## Automated Verification

Focused RED:

```text
reports/report_1026/
Exit: 100
Expected failure: get_factory_checkpoint_overdrive_defeat_burst_diagnostics()
did not exist yet.
```

Focused GREEN:

```text
reports/report_1027/
Story052: 2/2 passed
Errors: 0
Failures: 0
Flaky: 0
Skipped: 0
Orphans: 0
```

Related regression:

```text
reports/report_1028/
Suites:
- old_factory_checkpoint_overdrive_defeat_burst_test.gd
- old_factory_checkpoint_overdrive_duo_test.gd
- old_factory_checkpoint_overdrive_reward_cache_test.gd
- old_factory_service_lift_scene_manager_exit_test.gd
- factory_route_runtime_roundtrip_test.gd

Result: 11/11 passed
Errors: 0
Failures: 0
Flaky: 0
Skipped: 0
Orphans: 0
```

Headless smoke:

```text
reports/old_factory_overdrive_defeat_burst_smoke.log
Scene: res://scenes/factory_route_transition_shell.tscn
Exit: 0
Keyword scan: no SCRIPT ERROR, Parse Error, Invalid call, Invalid access,
missing-resource, resource-load, or ERROR entries in the log file.
```

The terminal still printed the known Godot cleanup-time ObjectDB/resource
messages at process exit; the smoke log did not contain project script/resource
errors.

## MCP Runtime Evidence

Steps:

1. Cleared MCP/game/editor logs.
2. Ran `res://scenes/factory_route_transition_shell.tscn` through MCP with
   `autosave=false`.
3. Set Old Factory local state so the checkpoint rear ambush was cleared and
   the overdrive duo was available.
4. Activated the overdrive duo.
5. Applied fatal damage to entity `2106`, then entity `2107`.
6. Read `get_factory_checkpoint_overdrive_defeat_burst_diagnostics()`,
   `get_factory_checkpoint_overdrive_duo_diagnostics()`, and
   `get_factory_service_lift_diagnostics()`.

Observed:

- `has_burst_api=true`.
- Left defeat:
  - `left_damage=true`.
  - `last_side="left"`.
  - `left_visible=true`.
  - `right_visible=false`.
  - `left_position=(1064, 482)`.
  - `texture_path=res://assets/environment/old_factory_overdrive_defeat_burst/vfx_old_factory_overdrive_defeat_burst_256.png`.
- Right defeat:
  - `right_damage=true`.
  - `last_side="right"`.
  - `left_visible=true`.
  - `right_visible=true`.
  - `right_position=(1224, 482)`.
  - Same runtime texture path.
- Overdrive duo after both defeats:
  - `cleared=true`.
  - `active=false`.
  - both overdrive Spark Rats hidden/disabled.
  - both Spark Rats still report `factory_spark_rat_sprite_frames.tres` with
    `idle/run/attack_tell/attack/hurt/death=3`.
- Service lift after both defeats:
  - `available=true`.
  - `prompt_text="Call lift"`.
  - `overdrive_duo_active=false`.
  - `route_label_text="Factory Lift Secured"`.
- Screenshot:
  - MCP game screenshot returned `640x359` from original `1278x718`.
- Logs:
  - MCP game log contained only the Godot AI helper registration line.
  - MCP editor log returned no current rows.

Verdict: PASS.
