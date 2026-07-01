# QA Evidence: Old Factory Lower Deck Skirmish Cache

Date: 2026-07-01
Story: `production/epics/player-abilities/story-053-old-factory-lower-deck-skirmish-cache.md`
Engine: Godot `4.7.stable.official.5b4e0cb0f`
MCP session: `cinderpaw@4400`, Godot MCP plugin/server `2.8.1`

## Scope

Story053 adds an optional lower-deck side skirmish after the Old Factory
checkpoint overdrive duo is cleared. It reuses the existing animated Factory
Spark Rat as the player-visible enemy actor, activates a local steam vent while
the side skirmish is active, and unlocks an independent generated gear cache.
The optional side content does not block the service lift once the main route is
already clear.

## Asset Evidence

- Built-in image generation source:
  `/Users/zhaok/.codex/generated_images/019ef041-d084-7212-b09b-7067e06fcf05/ig_0ca34adedf962f36016a448c72e7a4819189d742b5054c941a.png`.
- Project source:
  `assets/generated/source/old_factory_lower_deck_skirmish_cache_imagegen_20260701.png`.
- Alpha source:
  `assets/generated/source/old_factory_lower_deck_skirmish_cache_alpha_20260701.png`.
- Runtime PNG:
  `assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`.
- Metadata:
  `assets/generated/source/old_factory_lower_deck_skirmish_cache_imagegen_20260701.json`.
- Manifest:
  `design/assets/asset-manifest.md`.
- Processing:
  - Chroma key removed with `remove_chroma_key.py --auto-key border --soft-matte --transparent-threshold 12 --opaque-threshold 220 --despill`.
  - Runtime PNG resized to `256x256`.
  - Runtime alpha check: `RGBA`, transparent corners, `34142` non-transparent
    pixels.
  - Godot import completed and `.import` files exist for source, alpha, and
    runtime PNG.

## Automated Verification

Focused RED:

```text
reports/report_1029/
Exit: 100
Expected failure: lower-deck skirmish scene/API did not exist yet.
```

Focused GREEN:

```text
reports/report_1031/
Story053: 2/2 passed
Errors: 0
Failures: 0
Flaky: 0
Skipped: 0
Orphans: 0
```

Related regression:

```text
reports/report_1032/
Suites:
- old_factory_lower_deck_skirmish_cache_test.gd
- old_factory_checkpoint_overdrive_reward_cache_test.gd
- old_factory_cache_claim_feedback_test.gd
- old_factory_return_patrol_reward_cache_test.gd
- old_factory_checkpoint_overdrive_duo_test.gd
- factory_route_runtime_roundtrip_test.gd
- old_factory_service_lift_scene_manager_exit_test.gd

Result: 16/16 passed
Errors: 0
Failures: 0
Flaky: 0
Skipped: 0
Orphans: 0
```

Headless smoke:

```text
reports/old_factory_lower_deck_skirmish_cache_factory_scene_smoke.log
Scene: res://scenes/factory_route_transition_shell.tscn
Exit: 0
Keyword scan: no SCRIPT ERROR, Parse Error, Invalid call, Invalid access,
Failed to load, No loader found, referenced non-existent resource, or missing
entries in the log file.
```

The terminal still printed the known Godot cleanup-time ObjectDB/resource
messages at process exit; the smoke log did not contain project script/resource
errors.

## MCP Runtime Evidence

Steps:

1. Activated MCP session `cinderpaw@4400`.
2. Confirmed Godot `4.7-stable (official)` and Godot MCP plugin/server `2.8.1`.
3. Ran `res://scenes/factory_route_transition_shell.tscn` through MCP with
   `autosave=false`.
4. Set Old Factory local state to match the post-overdrive-duo clear contract.
5. Activated the lower-deck skirmish by moving the player past the activation
   boundary.
6. Applied fatal damage to entity `2108`.
7. Claimed the lower-deck cache once and attempted a duplicate claim.
8. Captured MCP game screenshot metadata and runtime node presence.

Observed:

- Before activation:
  - `present=true`.
  - `available=true`.
  - `cache_texture_path=res://assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`.
  - `cache_visible=false`.
  - `pressure_hazard_active=false`.
- Activated skirmish:
  - `activated=true`.
  - `active=true`.
  - `enemy_visible=true`.
  - `enemy_has_target=true`.
  - `entity_id=2108`.
  - `pressure_hazard_active=true`.
  - `cache_visible=false`.
  - `objective_id="clear_lower_deck_skirmish"`.
  - `route_label_text="Clear Lower Deck Skirmish"`.
  - Factory Spark Rat frame counts:
    `idle/run/attack_tell/attack/hurt/death=3`.
- Service lift during active optional skirmish:
  - `available=true`.
  - `prompt_text="Call lift"`.
- After defeating entity `2108`:
  - `defeated=true`.
  - `active=false`.
  - `enemy_visible=false`.
  - `pressure_hazard_active=false`.
  - `cache_visible=true`.
  - `cache_available=true`.
  - `cache_claim_available=true`.
- Cache claim:
  - first claim `true`.
  - duplicate claim `false`.
  - `cache_claimed=true`.
  - reward payload: `cache_id="old_factory_lower_deck_cache"`,
    `gears=10`, `source="old_factory_lower_deck_cache"`.
  - feedback text: `Lower Deck Cache Claimed +10 Gears`.
- Service lift after claim:
  - `available=true`.
  - `prompt_text="Call lift"`.
- Runtime scene node probe:
  - `Player` visible.
  - `FactoryLowerDeckSparkRat` present.
  - `FactoryLowerDeckRewardCache` present.
- Screenshot:
  - MCP game screenshot returned `960x539` from original `1278x718`.
- Logs:
  - After clearing the MCP log buffer, a minimal runtime probe returned
    successfully and `project_run` reported `recent_errors=[]`.

Verdict: PASS.
