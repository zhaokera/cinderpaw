# QA Evidence: Particle Budget + Performance Guardrails — 2026-06-24

## Scope

Verifies Combat Presentation Story 012. The slice implements the 200 active
Sprite2D particle cap for existing combat VFX families and adds a diagnostic
performance budget sample for `TR-combatfx-007`. It does not add missing
long-tail, fish-bone, or electro-bell VFX families, and does not replace the
current Sprite2D VFX path with pooling or `GPUParticles2D`.

## Story

- Story:
  `production/epics/combat-presentation/story-012-particle-budget-performance-guardrails.md`
- Requirements: `TR-combatfx-003` cap portion, `TR-combatfx-007`
- Runtime assets: existing textured CombatPresentation VFX under
  `assets/generated/` and existing character frame animation assets under
  `assets/characters/`
- Image generation: no new visual asset was required for this slice; it uses
  existing image-generated combat VFX textures.

## Automated Evidence

### RED

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd --ignoreHeadlessMode
```

Result: exit `100`, `23` executed tests, `3` failures,
`reports/report_374/`.

Observed failure:

- `CombatPresentation` lacked `get_particle_cap()`,
  `get_active_particle_count()`, and `get_particle_eviction_count()`.

### GREEN

Focused command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd --ignoreHeadlessMode
```

Result: exit `0`, `27/27` passing, `reports/report_375/`.

Related regression command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_player_dodge_afterimage_test.gd -a res://tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd -a res://tests/unit/boss/story_007_phase_transition_start_signal_contract_test.gd --ignoreHeadlessMode
```

Result: exit `0`, `43/43` passing, `reports/report_376/`.

### Headless Main Scene Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/combat_presentation_tr003_007_main_scene_smoke.log
rg -n "ERROR|WARNING|SCRIPT ERROR|Parse Error|Invalid access|Invalid call|Failed|Cannot" reports/combat_presentation_tr003_007_main_scene_smoke.log
```

Result: Godot exited `0`; log scan returned no matches.

## Godot MCP Runtime Evidence

- Godot: `4.6.3-stable (official)`
- Scene: `res://scenes/main.tscn`
- Editor state: MCP connected, `game_capture_ready=true` during runtime probe
- Logs:
  - Game log contained only the MCP helper registration line.
  - Editor log returned zero error/warning lines.

Runtime probe inspected `/root/Main/CombatPresentation`,
`/root/Main/Player/Sprite`, and `/root/Main/Enemy/Sprite`, then spawned one
normal hit spark event plus seven Boss phase debris events. This created 230
candidate Sprite2D particles, which were capped to 200 by oldest-first
eviction.

```json
{
  "main_scene": "res://scenes/main.tscn",
  "combat_presentation_script": "res://src/presentation/combat_presentation.gd",
  "player_sprite_is_animated": true,
  "enemy_sprite_is_animated": true,
  "player_animation_names": [
    "attack",
    "death",
    "dodge",
    "fall",
    "hurt",
    "idle",
    "jump",
    "revive",
    "run"
  ],
  "enemy_animation_names": [
    "attack",
    "attack_tell",
    "death",
    "hurt",
    "idle",
    "patrol"
  ],
  "particle_cap": 200,
  "active_particle_count": 200,
  "active_spark_count": 0,
  "active_boss_phase_debris_count": 200,
  "particle_eviction_count": 30,
  "sprite_particle_children": 200,
  "sample": {
    "active_particle_count": 200,
    "particle_budget_ms": 2.0,
    "particle_cap": 200,
    "particle_frame_ms": 0.165908333333333,
    "sample_frames": 120,
    "sampled_particles": 24000,
    "sampled_shake_state": 1440,
    "shake_hitstop_budget_ms": 0.1,
    "shake_hitstop_frame_ms": 0.00025,
    "total_budget_ms": 3.0,
    "total_frame_ms": 0.166158333333333,
    "within_budget": true
  },
  "sample_preserved_particles": true,
  "sample_preserved_hitstop": true,
  "sample_preserved_shake": true,
  "sample_preserved_shake_frames": true
}
```

Screenshot:

- `reports/visual/cinderpaw-mcp-combatfx-particle-budget-20260624.png`

## Acceptance Mapping

| Criterion | Evidence | Status |
|-----------|----------|--------|
| 200 particle cap API exists and starts at zero | Focused GdUnit tests | PASS |
| Count includes hit sparks, kill debris, parry sparks, claw trails, dodge afterimages, and Boss phase debris | Focused GdUnit tests | PASS |
| Damage labels, flash overlays, and Boss overlays are excluded | Focused GdUnit tests | PASS |
| Oldest-first eviction caps 230 candidates to 200 and removes initial sparks | Focused GdUnit tests; MCP runtime probe | PASS |
| Under-cap event counts stay unchanged | Focused GdUnit tests | PASS |
| Performance sample reports GDD budgets and non-negative timings | Focused GdUnit tests; MCP runtime probe | PASS |
| Sampling does not mutate particles, hitstop, or shake | Focused GdUnit tests; MCP runtime probe | PASS |
| Main scene runs with clean logs and visible runtime evidence | Headless smoke; MCP logs and screenshot | PASS |
