# QA Evidence: Rat King Arena Mutation Runtime - 2026-06-25

## Scope

Verifies Scene Management Story008: Rat King phase transitions now route
BossConfig arena change requests into `MainScene` runtime nodes. Phase 2 creates
a `garbage_pile` obstacle; phase 3 creates an `overturned_trash_can` obstacle
and an `electric_leak` damage zone. Nodes expose deterministic metadata,
collision, generated visual sprites, and cleanup on boss death/reset.

This evidence does not claim final boss completion. Electric leak contact damage,
final arena VFX, persistent arena mutation save state, and boss room art polish
remain separate stories.

## Asset Pipeline

- Source: built-in image generation, saved at
  `/Users/zhaok/.codex/generated_images/019ef041-d084-7212-b09b-7067e06fcf05/ig_006fd98d543571f5016a3c931665cc8194b754993e8f4894b9.png`.
- Workspace source sheet:
  `assets/generated/source/rat_king_arena_mutations_imagegen_20260625.png`.
- Alpha-matted source:
  `assets/generated/source/rat_king_arena_mutations_alpha_20260625.png`.
- Runtime props:
  `assets/environment/rat_king_arena/garbage_pile.png`,
  `assets/environment/rat_king_arena/overturned_trash_can.png`,
  `assets/environment/rat_king_arena/electric_leak.png`.
- Import: Godot generated `.png.import` sidecars for all runtime props and
  source/alpha source files.
- Manifest: `design/assets/asset-manifest.md` entry
  `rat_king_arena_mutations`.

## Image Generation Prompt Summary

Built-in image generation created a horizontal 3-panel sprite sheet for Rat King
arena mutations. The prompt requested a painterly pixel-adjacent 2D
side-scroller prop sheet on a flat green chroma-key background: scrap garbage
pile, overturned dented trash can with debris, and blue electric leak puddle
hazard. Local chroma removal converted the sheet to alpha, then the panels were
cropped into transparent runtime PNG props.

## Automated Evidence

### RED

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_arena_mutation_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `100`, report `reports/report_501/`.

Summary: expected failure because `MainScene` did not expose
`apply_arena_changes`, `get_arena_mutation_nodes`, `cleanup_arena_mutations`, or
the `ArenaMutations` runtime container.

### RED Refinement

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_arena_mutation_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `100`, report `reports/report_505/`.

Summary: expected refinement failure after adding generated prop requirements;
runtime mutation nodes existed, but were missing `Sprite2D` children with the
generated texture resource paths.

### GREEN Focused

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_arena_mutation_runtime_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_506/`.

Summary: `4/4` passing, `0` errors, `0` failures.

### Related Regression

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_arena_mutation_runtime_test.gd -a res://tests/unit/boss/story_004_arena_change_adapter_test.gd -a res://tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd -a res://tests/unit/gameplay/rat_king_live_summon_runtime_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_509/`.

Summary: `24/24` passing, `0` errors, `0` failures.

## Headless Smoke

Command:

```bash
/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/rat_king_arena_mutation_main_scene_smoke.log
rg -n "ERROR|Error|SCRIPT ERROR|WARNING|Warning|Failed|failed|Parse Error|Invalid" reports/rat_king_arena_mutation_main_scene_smoke.log
```

Result: Godot exited `0`; `rg` returned no matches.

## Godot MCP Evidence

Session:

- Godot version: `4.6.3-stable (official)`.
- Editor scene: `res://scenes/main.tscn`.
- Editor readiness before runtime: ready.
- Runtime state: playing, game capture ready.

Runtime phase 2/3 mutation probe:

```json
{
  "mutation_count": 3,
  "records": [
    {
      "name": "ArenaMutation_garbage_pile",
      "class": "StaticBody2D",
      "visible": true,
      "boss_id": "boss_01_rat_king",
      "phase": 2,
      "change_id": "garbage_pile",
      "change_type": "obstacle",
      "has_collision": true,
      "has_visual": true,
      "has_sprite": true,
      "texture_path": "res://assets/environment/rat_king_arena/garbage_pile.png"
    },
    {
      "name": "ArenaMutation_overturned_trash_can",
      "class": "StaticBody2D",
      "visible": true,
      "boss_id": "boss_01_rat_king",
      "phase": 3,
      "change_id": "overturned_trash_can",
      "change_type": "obstacle",
      "has_collision": true,
      "has_visual": true,
      "has_sprite": true,
      "texture_path": "res://assets/environment/rat_king_arena/overturned_trash_can.png"
    },
    {
      "name": "ArenaMutation_electric_leak",
      "class": "Area2D",
      "visible": true,
      "boss_id": "boss_01_rat_king",
      "phase": 3,
      "change_id": "electric_leak",
      "change_type": "damage_zone",
      "has_collision": true,
      "has_visual": true,
      "has_sprite": true,
      "texture_path": "res://assets/environment/rat_king_arena/electric_leak.png"
    }
  ]
}
```

Runtime cleanup/reset probe:

```json
{
  "before": 3,
  "after_cleanup": 0,
  "after_reapply": 1,
  "after_reset": 0
}
```

Runtime tree probe:

- `/Main/ArenaMutations` exists.
- It contains three mutation roots:
  `ArenaMutation_garbage_pile`, `ArenaMutation_overturned_trash_can`, and
  `ArenaMutation_electric_leak`.
- Each mutation root contains `CollisionShape2D`, `Visual`, and `Sprite`.

Logs:

- `logs_read(source="game", count=100)` returned only MCP helper registration
  and DataManager domain load lines for `boss_configs` / `enemy_stats`.

Screenshot:

- Runtime screenshots were saved at:
  `reports/visual/cinderpaw-mcp-rat-king-arena-mutations-20260625.png`,
  `reports/visual/cinderpaw-mcp-rat-king-arena-mutations-20260625-refresh.png`,
  and
  `reports/visual/cinderpaw-mcp-rat-king-arena-mutations-20260625-forced.png`.
- These screenshots are nonblank and show the playable arena, Rat King, and HUD.
  They are weak visual evidence for the mutation props because the captured game
  framebuffer did not refresh to the mutation-rendered frame even after
  `RenderingServer.force_draw(false)`. Node-level MCP evidence above is the
  authoritative runtime proof for this story.

## Acceptance Verdict

| Criterion | Evidence | Status |
|-----------|----------|--------|
| RatKingBoss forwards scene adapter | GdUnit focused test and Story004 regression | PASS |
| Phase 2 creates `garbage_pile` obstacle | GdUnit focused test and MCP runtime probe | PASS |
| Phase 3 creates `overturned_trash_can` and `electric_leak` once | GdUnit focused test and MCP runtime probe | PASS |
| Mutation nodes expose metadata | GdUnit focused test and MCP runtime probe | PASS |
| Mutation nodes have collision, visual, and generated Sprite2D texture paths | GdUnit focused test and MCP runtime probe | PASS |
| Boss death/reset/cleanup clears mutation state | GdUnit focused test and MCP cleanup/reset probe | PASS |
| Related boss/runtime/visual contracts remain compatible | `reports/report_509/` | PASS |
| Runtime logs are clean | Headless smoke log scan and MCP game logs | PASS |
| Screenshot shows mutation props clearly | Saved screenshots are nonblank but weak for mutation visibility | CONCERNS |

## Final Status

PASS WITH VISUAL EVIDENCE CONCERN. The runtime integration is implemented and
verified by GdUnit plus Godot MCP node/log probes. A later visual-polish story
should capture a refreshed interactive screenshot or adjust arena prop staging
for stronger player-visible composition evidence.
