# QA Evidence: Rat King Live Phase Two Summon Runtime - 2026-06-25

## Scope

Verifies Boss Configuration Story009: Rat King phase 2 summon scheduling now
spawns live Rat Minion runtime enemies in `MainScene`, caps active minions at 2,
routes player damage to live summon entity ids, lets Rat Minions bite the player
through the combat/collision/damage pipeline, and cleans summons when the boss
dies.

This evidence does not claim final boss completion. Arena mutation, boss
music/SFX, reward presentation, advanced minion AI, and HUD phase polish remain
separate stories.

## Asset Pipeline

- Source: built-in image generation, saved under
  `/Users/zhaok/.codex/generated_images/019ef041-d084-7212-b09b-7067e06fcf05/ig_0226e1763b276422016a3c819396d48191b3b3658b078d46cb.png`.
- Workspace source sheet:
  `assets/characters/rat_minion/source/rat_minion_sprite_sheet_imagegen_20260625.png`.
- Alpha-matted source:
  `assets/characters/rat_minion/source/rat_minion_sprite_sheet_alpha_20260625.png`.
- Preview sheet:
  `assets/characters/rat_minion/source/rat_minion_frames_preview_20260625.png`.
- Runtime frames:
  `assets/characters/rat_minion/{idle,run,attack,hurt,death}/rat_minion_<animation>_000.png`
  through `_002.png`.
- Runtime SpriteFrames:
  `assets/characters/rat_minion/rat_minion_sprite_frames.tres`.
- Character scene/script:
  `scenes/characters/rat_minion.tscn`,
  `src/characters/rat_minion.gd`.
- Gameplay runtime scene/script:
  `src/gameplay/rat_minion.tscn`,
  `src/gameplay/rat_minion.gd`.
- Import: `godot --headless --path . --import --quit-after 1` imported the new
  Rat Minion PNG files and generated `.png.import` sidecars.

## Image Generation Prompt Summary

Built-in image generation created a 5-row by 3-column Godot 2D character sprite
sheet for a small Rat King summon minion. Rows specified `idle`, `run`, `attack`
bite, `hurt`, and `death`; columns specified three readable animation frames.
The prompt required a tiny scrap-armored sewer rat minion, side-view
readability, consistent lower-center anchor, no text/watermark, and a flat green
chroma-key background for local alpha removal.

## Frame Audit

| Animation | Runtime Path | Frame Count | Frame Size | Status |
|-----------|--------------|-------------|------------|--------|
| `idle` | `assets/characters/rat_minion/idle/` | 3 | 96x96 RGBA | PASS |
| `run` | `assets/characters/rat_minion/run/` | 3 | 96x96 RGBA | PASS |
| `attack` | `assets/characters/rat_minion/attack/` | 3 | 96x96 RGBA | PASS |
| `hurt` | `assets/characters/rat_minion/hurt/` | 3 | 96x96 RGBA | PASS |
| `death` | `assets/characters/rat_minion/death/` | 3 | 96x96 RGBA | PASS |

All runtime PNGs use transparent backgrounds, consistent 96x96 dimensions, and
continuous `_000` through `_002` naming.

## Automated Evidence

### RED

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_live_summon_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `100`, report `reports/report_485/`.

Summary: expected failure because Rat Minion character scene, runtime scene,
scripts, and `rat_minion_sprite_frames.tres` did not exist.

### GREEN Focused

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_live_summon_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_486/`.

Summary: `7/7` passing, `0` errors, `0` failures.

### Related Gameplay Regression

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_491/`.

Summary: `94/94` passing, `0` errors, `0` failures. Godot printed one ObjectDB
cleanup warning at process exit; no GdUnit test failed.

### Minimum Risk Regression After Full-Suite Triage

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/data/story_003_domain_cache_test.gd -a res://tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd -a res://tests/unit/gameplay/rat_king_live_summon_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_496/`.

Summary: `17/17` passing, `0` errors, `0` failures. This run replaces failed
full-suite report `reports/report_492/` for this story's commit evidence:
`report_492` exposed unrelated Save/Data isolation failures, while Rat King live
summon tests passed `7/7` inside that full run.

Final verification rerun after evidence updates: exit `0`, report
`reports/report_500/`, `17/17` passing, `0` errors, `0` failures.

### Full Unit Triage

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit --ignoreHeadlessMode
```

Result: exit `100`, report `reports/report_497/`.

Summary: `522` executed unit test cases, `6` failures, all in
`tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd`
under full-suite order. `tests/unit/data/story_003_domain_cache_test.gd` passed
`7/7`, and `tests/unit/gameplay/rat_king_live_summon_runtime_test.gd` passed
`7/7` in the same full run. Focused Save Story004, Save Story003 -> Story004,
and Save Story005 -> Story004 order checks passed separately, so this remains a
pre-existing full-order Save isolation issue rather than a Rat Minion blocker.

## Headless Smoke

Command:

```bash
/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/rat_king_live_summon_main_scene_smoke.log
rg -n "ERROR|SCRIPT ERROR|WARNING|Invalid call|Parse Error|FAILED|Failed loading resource|Cannot" reports/rat_king_live_summon_main_scene_smoke.log
```

Result: Godot exited normally. `rg` returned no matches.

## Godot MCP Evidence

Session:

- Godot version: `4.6.3-stable (official)`.
- Editor scene: `res://scenes/main.tscn`.
- Editor readiness before runtime: ready.
- Runtime state: playing, game capture ready.

Runtime SpriteFrames probe:

```json
{
  "ok": true,
  "phase": 2,
  "active_count": 1,
  "summons_node_exists": true,
  "minions": [
    {
      "script": "res://src/gameplay/rat_minion.gd",
      "owner": "boss_01_rat_king",
      "hp": 24,
      "visible": true,
      "sprite_is_animated": true,
      "sprite_frames_path": "res://assets/characters/rat_minion/rat_minion_sprite_frames.tres",
      "animations": ["attack", "death", "hurt", "idle", "run"],
      "frame_counts": {
        "attack": 3,
        "death": 3,
        "hurt": 3,
        "idle": 3,
        "run": 3
      }
    }
  ]
}
```

Runtime cap / damage / cleanup probe:

```json
{
  "ok": true,
  "phase": 2,
  "first_spawn_count": 1,
  "count_after_cap": 2,
  "attack_started": true,
  "hp_before": 100,
  "hp_after_attack": 92,
  "damage_delta": 8,
  "attack_metadata": {
    "hitbox_id": "rat_minion_bite",
    "weapon_id": "rat_minion_bite",
    "final_damage": 8,
    "target_id": 1,
    "attacker_id": 2000
  },
  "count_after_cleanup": 0
}
```

Logs:

- `logs_read(source="game", count=120)` returned only MCP helper registration
  and DataManager domain load lines for `boss_configs` / `enemy_stats`.
- `logs_read(source="editor", count=120)` returned `0` lines.

Screenshot:

- MCP game screenshot returned a nonblank `960x540` image.
- Runtime screenshot saved at
  `reports/visual/cinderpaw-mcp-rat-king-live-summon-rat-minion-20260625.png`.
- Screenshot visibly shows Rat King and Rat Minion in the playable arena using
  image-generated character sprites, not ColorRect blocks or single-frame square
  placeholders.

## Acceptance Verdict

| Criterion | Evidence | Status |
|-----------|----------|--------|
| Rat Minion uses `AnimatedSprite2D + SpriteFrames` | GdUnit focused test and MCP SpriteFrames probe | PASS |
| Runtime frames are transparent, same-size, continuous PNGs | Frame audit and `test_rat_minion_animation_assets_follow_project_pipeline_paths` | PASS |
| MainScene spawns phase 2 live summons | GdUnit focused test and MCP runtime probe | PASS |
| Active summon cap is 2 | GdUnit focused test and MCP `count_after_cap=2` | PASS |
| Minion bite damages player through combat chain | MCP `damage_delta=8` and hit metadata | PASS |
| Boss death cleans summons | GdUnit focused test and MCP `count_after_cleanup=0` | PASS |
| Runtime logs are clean | Headless smoke log scan; MCP game/editor logs | PASS |
| Screenshot is nonblank and visible minion is not a block | MCP screenshot + saved visual evidence | PASS |

## Final Status

PASS. Rat King phase 2 live summon runtime is now implemented and verified. The
game still needs arena mutation, boss audio, reward presentation, HUD phase
polish, and richer minion AI to become a finished boss encounter.
