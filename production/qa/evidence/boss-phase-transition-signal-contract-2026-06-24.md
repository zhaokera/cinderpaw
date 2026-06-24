# Boss Phase Transition Signal Contract Evidence

Date: 2026-06-24
Story: `production/epics/combat-presentation/story-009-boss-phase-transition-signal-contract.md`

## Scope

This slice adds the presentation-facing Boss phase transition start contract.
It does not add new visual assets or VFX. Future boss phase feedback should
consume `BossConfigComponent.on_boss_phase_transition_started` so effects begin
only after AI attack completion and transition invulnerability starts.

## Automated Evidence

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/boss/story_007_phase_transition_start_signal_contract_test.gd \
  --ignoreHeadlessMode
```

- RED: `reports/report_358/` failed on missing
  `on_boss_phase_transition_started`.
- GREEN: `reports/report_359/` passed `3/3`.

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd \
  -a res://tests/unit/boss/story_001_boss_config_component_test.gd \
  -a res://tests/unit/boss/story_002_phase_transition_adapter_test.gd \
  -a res://tests/unit/boss/story_003_summon_scheduling_test.gd \
  -a res://tests/unit/boss/story_004_arena_change_adapter_test.gd \
  -a res://tests/unit/boss/story_005_desperation_reward_test.gd \
  -a res://tests/unit/boss/story_006_parry_immunity_test.gd \
  -a res://tests/unit/boss/story_007_phase_transition_start_signal_contract_test.gd \
  -a res://tests/unit/health/story_002_milestones_boss_phases_test.gd \
  -a res://tests/unit/ai/story_005_boss_phase_focus_mode_signal_integration_test.gd \
  --ignoreHeadlessMode
```

- Regression: `reports/report_360/` passed `39/39`.

## Runtime Evidence

```bash
godot --headless --path . --scene res://scenes/main.tscn \
  --fixed-fps 60 --quit-after 120 \
  --log-file reports/boss_phase_transition_signal_contract_main_scene_smoke.log

rg -n "ERROR|Error|error|WARNING|Warning|warning|Parse Error|SCRIPT ERROR|Invalid call|Failed|Cannot" \
  reports/boss_phase_transition_signal_contract_main_scene_smoke.log
```

- Headless smoke exited `0`.
- Log scan returned no matches.

## Godot MCP Evidence

- Session: `cinderpaw@c1b2`
- Engine: Godot `4.6.3-stable (official)`
- Scene: `res://scenes/main.tscn`
- Probe result:
  - `loaded=true`
  - `event_count=1`
  - `event_entity=42`
  - `event_phase=2`
  - `previous_phase=1`
  - `hp_threshold=0.66`
  - `trigger_hp_percentage=0.65`
  - `transition_duration_sec=2.5`
  - `transition_animation=phase_2_rebuild`
  - `transition_active=true`
  - `invulnerable=true`
  - `attack_pattern_count=3`
  - `arena_change_count=1`
- Final MCP logs:
  - Game log: helper registration and `boss_configs` load only.
  - Editor log: `0` lines.

## Asset Note

No new image or animation asset was generated for this story. This is a signal
contract prerequisite for later boss phase visual feedback.
