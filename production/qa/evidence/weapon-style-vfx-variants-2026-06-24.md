# QA Evidence: Weapon Style VFX Variants - 2026-06-24

## Scope

Combat Presentation Story 013 covers the remaining GDD weapon particle
families for normal weapon attack-start feedback:

- `long_tail`: silver `trail_blade`, count `1`, lifetime `0.5s`.
- `fish_bone`: white `wave_bone`, count `1`, lifetime `0.3s`.
- `electro_bell`: blue `arc_bell`, count `5-8`, lifetime `0.4s`.

This slice is Presentation-only. It consumes weapon attack metadata and does
not modify Core weapon rules, damage, hitboxes, shield break, slow status, HUD,
audio, GPUParticles2D, or character `SpriteFrames`.

## Story

- Story:
  `production/epics/combat-presentation/story-013-weapon-style-vfx-variants.md`
- Requirements: `TR-combatfx-003`, `TR-combatfx-007`
- Governing ADRs: ADR-0002, ADR-0016
- Runtime scope: `CombatPresentation` Presentation VFX only

## Asset Generation Record

All three source textures were produced through image generation, copied into
`assets/generated/source/`, processed into transparent 512x512 centered runtime
PNGs, and imported through the Godot asset pipeline. MCP `reimport` did not
create import metadata for the newly copied runtime PNGs, so final import was
verified by running Godot headless import and confirming each `.png.import`
file existed before tests and MCP runtime validation.

| Asset ID | Runtime Path | Source Image | Source | Intended Use | Import Status |
|----------|--------------|--------------|--------|--------------|---------------|
| combat_long_tail_arc | `res://assets/generated/combat_long_tail_arc_runtime.png` | `assets/generated/source/combat_long_tail_arc_imagegen_20260624.png` | image generation | Silver `trail_blade` arc for `long_tail` normal attack-start VFX; `1` particle, `0.5s` lifetime | Imported |
| combat_fish_bone_wave | `res://assets/generated/combat_fish_bone_wave_runtime.png` | `assets/generated/source/combat_fish_bone_wave_imagegen_20260624.png` | image generation | White `wave_bone` shockwave/ring for `fish_bone` normal attack-start VFX; `1` particle, `0.3s` lifetime | Imported |
| combat_electro_bell_arc | `res://assets/generated/combat_electro_bell_arc_runtime.png` | `assets/generated/source/combat_electro_bell_arc_imagegen_20260624.png` | image generation | Blue `arc_bell` electric arc for `electro_bell` normal attack-start VFX; `6` particles, `0.4s` lifetime | Imported |

## Automated Evidence

### RED

Command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd --ignoreHeadlessMode
```

Result: exit code `100`, report `reports/report_377`.

Observed failures:

- `CombatPresentation` did not expose `get_weapon_vfx_snapshot()`.
- `long_tail`, `fish_bone`, and `electro_bell` attack-start events spawned no
  Story013 weapon-style particles.
- Main scene runtime contract failed because weapon attack-start metadata was
  not yet visible through the presentation VFX snapshot.

### GREEN

Focused command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd --ignoreHeadlessMode
```

Result: exit code `0`, report `reports/report_381`, `35/35` passing.

Final related regression command:

```bash
godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/presentation/combat_presentation_test.gd -a res://tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_weapon_swap_runtime_test.gd -a res://tests/unit/weapon/story_006_long_tail_multi_target_test.gd -a res://tests/unit/weapon/story_007_fish_bone_shield_break_test.gd -a res://tests/unit/weapon/story_008_electro_bell_slow_test.gd --ignoreHeadlessMode
```

Result: exit code `0`, report `reports/report_383`, `47/47` passing.

Covered assertions:

- `long_tail` spawns exactly one textured silver `trail_blade` arc with
  `0.5s` lifetime.
- `fish_bone` spawns exactly one textured white `wave_bone` shockwave with
  `0.3s` lifetime.
- `electro_bell` spawns six textured blue `arc_bell` particles with `0.4s`
  lifetime, satisfying the GDD `5-8` count range.
- New weapon-style VFX are counted by the existing 200-particle cap path and
  keep Story012 performance-budget diagnostics passing.
- Core weapon behavior regressions for long-tail multi-target, fish-bone
  shield break, and electro-bell slow remain green.

### Headless Main Scene Smoke

Command:

```bash
godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 180 --log-file reports/combat_weapon_vfx_main_scene_smoke.log
rg -n "ERROR|WARNING|SCRIPT ERROR|Parse Error|Invalid access|Invalid call|Failed|Cannot" reports/combat_weapon_vfx_main_scene_smoke.log
```

Result: Godot exit code `0`; log scan exit code `1` with no matches. Smoke log:
`reports/combat_weapon_vfx_main_scene_smoke.log`.

## Godot MCP Runtime Evidence

- Godot: `4.6.3`
- Scene: `res://scenes/main.tscn`
- Editor state: ready; game capture ready during runtime validation
- Target nodes: `/Main/CombatPresentation`, `/Main/Player/Sprite`
  `AnimatedSprite2D`, `/Main/Enemy/Sprite` `AnimatedSprite2D`
- Logs: game helper registration only; editor log read returned no new errors

Runtime probe summary:

| Weapon | Hitbox | VFX Snapshot | Gameplay Metadata |
|--------|--------|--------------|-------------------|
| `long_tail` | `long_tail_light` active | count `1`, lifetime `0.5`, texture `res://assets/generated/combat_long_tail_arc_runtime.png`, active particles `1` | No Core metadata changes |
| `fish_bone` | `fish_bone_light` active | count `1`, lifetime `0.3`, texture `res://assets/generated/combat_fish_bone_wave_runtime.png`, active particles `1` | No shield-break call from Presentation |
| `electro_bell` | `electro_bell_light` active | count `6`, lifetime `0.4`, texture `res://assets/generated/combat_electro_bell_arc_runtime.png`, active particles `6` | Existing Core slow metadata still applied: `slow`, `2.0s`, `0.7` movement modifier |

Screenshot evidence:

- `reports/visual/cinderpaw-mcp-long-tail-vfx-20260624.png`
- `reports/visual/cinderpaw-mcp-fish-bone-vfx-20260624.png`
- `reports/visual/cinderpaw-mcp-electro-bell-vfx-20260624.png`

All three screenshots are nonblank 1280x720 captures from the running game and
visibly show the target weapon-style VFX.

## Acceptance Mapping

| Criterion | Evidence | Status |
|-----------|----------|--------|
| Long-tail normal attack-start spawns one silver `trail_blade` using generated texture for `0.5s` | `reports/report_381`; `reports/report_383`; MCP runtime probe and screenshot | PASS |
| Fish-bone normal attack-start spawns one white `wave_bone` using generated texture for `0.3s` | `reports/report_381`; `reports/report_383`; MCP runtime probe and screenshot | PASS |
| Electro-bell normal attack-start spawns `5-8` blue `arc_bell` particles using generated texture for `0.4s` | `reports/report_381`; `reports/report_383`; MCP runtime probe and screenshot | PASS |
| New weapon VFX families participate in the Story012 200-particle cap and oldest-first eviction | `test_weapon_specific_vfx_count_toward_particle_budget`; related regression `reports/report_383` | PASS |
| Performance diagnostics stay within GDD budgets | Story012 performance diagnostic tests still green in `reports/report_381` and `reports/report_383` | PASS |
| Presentation consumes event metadata only and does not call Core weapon, damage, hitbox, shield-break, slow-status, HUD, audio, or animation APIs | Code review of `CombatPresentation`; focused tests; Core weapon regressions still green | PASS |
| Main scene runs with clean logs and visible runtime evidence | Headless smoke; MCP logs; screenshots | PASS |

## Final Status

Story013 is complete. Combat Presentation now covers the GDD weapon particle
families for cat-claw, long-tail, fish-bone, and electro-bell without adding
player-visible block placeholders.
