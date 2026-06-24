# QA Evidence: Colorblind Combat VFX + Focus Shake Accessibility — 2026-06-24

## Scope

Verifies Combat Presentation Story 011. The slice implements
`TR-combatfx-008` colorblind particle remaps and `TR-combatfx-009` low-HP
focus shake reduction without changing particle counts, textures, lifetimes,
hitstop, combat formulas, or HealthComponent focus thresholds.

## Story

- Story:
  `production/epics/combat-presentation/story-011-colorblind-focus-accessibility.md`
- Requirements: `TR-combatfx-008`, `TR-combatfx-009`
- Runtime assets: existing textured CombatPresentation VFX under
  `assets/generated/`
- Image generation: no new visual asset was required for this slice; it remaps
  existing image-generated particle textures through `Sprite2D.modulate`.

## Accessibility Palette

| Particle Semantic | Default | `red_green` | `blue_yellow` |
|---|---:|---:|---:|
| Normal hit / neutral spark | `#FFF0C2` | `#4299E1` | `#FED7D7` |
| Crit / claw / gold emphasis | `#ECC94B` / `#FFE67A` | `#F6E05E` | `#F97316` |
| Perfect parry spark | `#FFF5B8` | `#F6E05E` | `#FFFFFF` |
| Kill / danger debris | `#C72E29` | `#D69E2E` | `#E53E3E` |
| Boss phase metal / overload debris | `#6B8A9E` / `#E53E3E` | `#2B6CB0` / `#F6E05E` | `#F97316` / `#FFFFFF` |

## Automated Evidence

### RED

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd -a res://tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `100`, `14` executed tests, `8` failures,
`reports/report_370/`.

Observed failure:

- `CombatPresentation` lacked colorblind mode APIs, focus-mode APIs, and VFX
  last-color diagnostics.
- `MainScene` did not yet sync HUD colorblind settings into combat particles.

### GREEN

Focused command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd -a res://tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `0`, `27/27` passing, `reports/report_372/`.

Related regression command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd -a res://tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd -a res://tests/unit/health/story_004_focus_mode_signals_test.gd -a res://tests/unit/boss/story_007_phase_transition_start_signal_contract_test.gd --ignoreHeadlessMode
```

Result: exit `0`, `44/44` passing, `reports/report_373/`.

### Headless Main Scene Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/combat_presentation_tr008_009_main_scene_smoke.log
rg -n "ERROR|WARNING|SCRIPT ERROR|Parse Error|Invalid access|Invalid call|Failed|Cannot" reports/combat_presentation_tr008_009_main_scene_smoke.log
```

Result: Godot exited `0`; log scan returned no matches.

## Godot MCP Runtime Evidence

- MCP session: `cinderpaw`
- Godot: `4.6.3-stable (official)`
- Scene: `res://scenes/main.tscn`
- Logs:
  - Game log contained only the MCP helper registration line.
  - Editor log returned zero error/warning lines.

Runtime probe toggled HUD colorblind modes, triggered hit/parry/kill/boss phase
VFX, emitted `Player/HealthComponent.on_focus_mode_changed`, inspected
`CombatPresentation`, and saved four framebuffer screenshots.

```json
{
  "default_spark_color": "fff0c2",
  "red_green_mode": "red_green",
  "red_green_spark_color": "4299e1",
  "red_green_parry_color": "f6e05e",
  "red_green_boss_color": "2b6cb0",
  "blue_yellow_mode": "blue_yellow",
  "blue_yellow_spark_color": "fed7d7",
  "blue_yellow_debris_color": "e53e3e",
  "blue_yellow_boss_color": "ffffff",
  "focus_active": true,
  "focus_shake": 1.4,
  "focus_frames": 3,
  "presentation_color_rect_count": 0,
  "player_animated_sprite_count": 1,
  "enemy_animated_sprite_count": 1,
  "player_animation_frame_counts": {
    "attack": 3,
    "death": 3,
    "dodge": 3,
    "fall": 3,
    "hurt": 3,
    "idle": 3,
    "jump": 3,
    "revive": 3,
    "run": 3
  },
  "enemy_animation_frame_counts": {
    "attack": 3,
    "attack_tell": 3,
    "death": 3,
    "hurt": 3,
    "idle": 3,
    "patrol": 3
  },
  "screenshot_errors": {
    "default": 0,
    "red_green": 0,
    "blue_yellow": 0,
    "focus": 0
  }
}
```

Screenshots:

- `reports/visual/cinderpaw-mcp-combatfx-default-hit-20260624.png`
- `reports/visual/cinderpaw-mcp-combatfx-red-green-20260624.png`
- `reports/visual/cinderpaw-mcp-combatfx-blue-yellow-20260624.png`
- `reports/visual/cinderpaw-mcp-combatfx-focus-hit-20260624.png`

## Acceptance Mapping

| Criterion | Evidence | Status |
|-----------|----------|--------|
| CombatPresentation colorblind API and invalid fallback | Focused GdUnit tests | PASS |
| New particles use current accessibility palette | Focused GdUnit tests; MCP color probes | PASS |
| Counts, textures, lifetimes, hitstop, duration unchanged | Existing regression tests plus new focus tests | PASS |
| HUD setting syncs into CombatPresentation | MainScene HUD settings runtime test; MCP HUD toggle probe | PASS |
| Health focus signal reduces shake by 30% | Focused GdUnit tests; MCP immediate focus probe | PASS |
| Presentation does not query Core/Feature nodes directly | MainScene signal routing implementation and tests | PASS |
| Main scene runtime logs/screenshots validated through MCP | MCP logs and screenshots | PASS |
