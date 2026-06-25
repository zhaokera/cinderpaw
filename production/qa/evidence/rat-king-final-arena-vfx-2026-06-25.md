# QA Evidence: Rat King Final Arena VFX - 2026-06-25

## Scope

Verifies Scene Management Story011: Rat King phase 2/3 arena mutations now add
image-generated, texture-backed `Sprite2D` VFX layers. The slice covers debris
dust for `garbage_pile` and `overturned_trash_can`, plus electric hazard glow
and spark VFX for `electric_leak`.

This evidence does not claim shader distortion, camera choreography, particles,
music/SFX, reward presentation, or persistent arena mutation save-state.

## Asset Pipeline

- Generated source:
  `assets/generated/source/rat_king_arena_vfx_imagegen_20260625.png`.
- Alpha source:
  `assets/generated/source/rat_king_arena_vfx_alpha_20260625.png`.
- Runtime VFX:
  `assets/environment/rat_king_arena/vfx/arena_debris_dust.png`,
  `assets/environment/rat_king_arena/vfx/electric_leak_hazard_glow.png`,
  `assets/environment/rat_king_arena/vfx/electric_leak_spark.png`.
- Import status: all runtime and source PNGs imported by Godot and have
  `.import` metadata.
- Manifest entry: `rat_king_arena_vfx` in `design/assets/asset-manifest.md`.

Prompt summary:

```text
Pixel-art 2D side-scroller VFX sprite sheet for a wasteland cat action game,
three separated effects on pure green chroma key: rusty debris dust with trash
fragments, cyan-white electric hazard ground glow, and cyan-white electric spark
burst. No text or watermark, isolated game-ready transparent VFX.
```

## Runtime Contract

- `ArenaMutation_garbage_pile` keeps `StaticBody2D`, `CollisionShape2D`,
  `Visual`, and `Sprite`, and adds `Vfx/DebrisDust`.
- `ArenaMutation_overturned_trash_can` keeps `StaticBody2D`,
  `CollisionShape2D`, `Visual`, and `Sprite`, and adds `Vfx/DebrisDust`.
- `ArenaMutation_electric_leak` keeps `Area2D`, environment layer `16`, mask
  `12`, `monitoring=true`, `monitorable=false`, `CollisionShape2D`, `Visual`,
  and `Sprite`, and adds `Vfx/HazardGlow` plus `Vfx/ElectricSpark`.
- VFX metadata:
  `asset_source=image_generation`, `change_id`, and `vfx_role`.

## Automated Evidence

### RED

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_arena_vfx_polish_test.gd --ignoreHeadlessMode
```

Result: exit `100`, report `reports/report_530/`.

Summary: expected failure because existing arena mutation nodes did not have a
`Vfx` child container.

### GREEN Focused

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_arena_vfx_polish_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_531/`.

Summary: `4/4` passing, `0` errors, `0` failures. Coverage includes mutation
VFX containers, generated texture paths and dimensions, electric hazard
glow/spark roles, reapply idempotence, and cleanup/reapply.

### Related Regression

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_arena_vfx_polish_test.gd -a res://tests/unit/gameplay/rat_king_arena_mutation_runtime_test.gd -a res://tests/unit/gameplay/rat_king_electric_leak_contact_damage_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd -a res://tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_534/`.

Summary: `22/22` passing, `0` errors, `0` failures. Story008 arena mutation,
Story009 electric leak damage, MainScene visual, and Rat King runtime contracts
remain compatible.

## Headless Smoke

Command:

```bash
/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/rat_king_final_arena_vfx_headless_smoke.log
rg -n "ERROR|Error|SCRIPT ERROR|WARNING|Warning|Failed|failed|Parse Error|Invalid" reports/rat_king_final_arena_vfx_headless_smoke.log
```

Result: Godot exited `0`; `rg` returned no matches.

## Godot MCP Evidence

Session:

- Godot version: `4.6.3-stable (official)`.
- Runtime fixture:
  `res://tests/fixtures/gameplay/rat_king_final_arena_vfx_probe.tscn`.
- Runtime state: playing, game capture ready.

MCP node probe summary:

```json
{
  "before_reapply_count": 3,
  "after_reapply_count": 3,
  "before_counts": {
    "garbage_pile": 1,
    "overturned_trash_can": 1,
    "electric_leak": 2
  },
  "after_counts": {
    "garbage_pile": 1,
    "overturned_trash_can": 1,
    "electric_leak": 2
  },
  "after_cleanup_count": 0,
  "reapplied_change_id": "electric_leak",
  "reapplied_vfx_child_count": 2
}
```

Texture probe summary:

- `DebrisDust`: `res://assets/environment/rat_king_arena/vfx/arena_debris_dust.png`,
  `512x256`, `vfx_role=debris_dust`.
- `HazardGlow`:
  `res://assets/environment/rat_king_arena/vfx/electric_leak_hazard_glow.png`,
  `512x192`, `vfx_role=hazard_glow`.
- `ElectricSpark`:
  `res://assets/environment/rat_king_arena/vfx/electric_leak_spark.png`,
  `384x384`, `vfx_role=electric_spark`.

Logs:

- `logs_read(source="game", count=100)` returned only MCP helper registration
  and DataManager domain load lines.
- `logs_read(source="editor", count=100)` returned `0` lines after clearing
  eval-debugger warnings from exploratory probes.

Screenshot:

- Runtime screenshot saved at
  `reports/visual/cinderpaw-mcp-rat-king-final-arena-vfx-20260625.png`.
- Screenshot is nonblank and visibly shows Rat King, debris dust, overturned
  trash can, electric hazard glow, and electric sparks in the playable arena.

## Acceptance Verdict

| Criterion | Evidence | Status |
|-----------|----------|--------|
| Each mutation has visible `Vfx` container | Story011 GdUnit and MCP node probe | PASS |
| VFX sprites use generated PNGs under arena VFX path | GdUnit texture assertions, manifest, MCP texture probe | PASS |
| Obstacle mutations use debris/dust metadata | GdUnit role assertions and MCP probe | PASS |
| Electric leak has hazard glow and electric spark roles | GdUnit role assertions and MCP probe | PASS |
| Reapply does not duplicate VFX | GdUnit and MCP count probe | PASS |
| Cleanup and reapply restore VFX | GdUnit and MCP cleanup probe | PASS |
| Existing electric leak collision/damage contract preserved | Story009 regression in `reports/report_534/` | PASS |
| Runtime logs are clean | Headless smoke and MCP logs | PASS |
| Screenshot shows final arena VFX | MCP fixture screenshot | PASS |

## Final Status

PASS. Story011 is implemented and verified by TDD, related regression, Godot
headless smoke, and Godot MCP runtime node/log/screenshot evidence.
