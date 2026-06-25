# QA Evidence: Rat King Electric Leak Contact Damage - 2026-06-25

## Scope

Verifies Scene Management Story009: Rat King phase 3 `electric_leak` arena
mutation now acts as a real contact damage hazard in `MainScene`. The hazard
uses ADR-0004 environment collision, applies electric player damage through
`PlayerController.apply_damage()`, routes damage feedback to
CombatPresentation and AudioSystem, rate-limits hits per boss/change/target, and
clears cooldown state with arena mutation cleanup.

This evidence does not claim final arena VFX, boss music, persistent arena
mutation save state, or final boss completion.

## Asset Pipeline

- No new visual assets were generated for this story.
- Story009 reuses the image-generated `electric_leak` runtime prop from
  SceneManagement Story008:
  `assets/environment/rat_king_arena/electric_leak.png`.
- MCP screenshot evidence for this story was saved at
  `reports/visual/cinderpaw-mcp-electric-leak-contact-damage-20260625.png`.

## Design Contract

- Damage: `8`.
- Damage type metadata: `electric`.
- Cooldown: `1.0` second.
- Cooldown key: per `boss_id`, `change_id`, and `target_id`.
- Collision: damage zone layer `CollisionComponent.COLLISION_LAYER_ENVIRONMENT`
  (`16`), mask `CollisionComponent.COLLISION_MASK_ENVIRONMENT` (`12`), which
  covers player/enemy hurtbox layers.
- Runtime overlap path: ADR-0004 `CollisionComponent` hurtbox `Area2D` via
  `area_entered` and per-frame `get_overlapping_areas()` polling.
- Compatibility fallback: `body_entered` remains connected for future
  `PhysicsBody2D` hazards that share the hurtbox mask; the current Player body
  itself is not part of the damage-zone mask.
- Cooldown starts only after HP actually decreases, so iframe/dodge/death or
  other immunity paths do not consume the electric leak cooldown.

## Automated Evidence

### RED

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_electric_leak_contact_damage_test.gd --ignoreHeadlessMode
```

Result: exit `100`, report `reports/report_510/`.

Summary: expected failure because Story008's `electric_leak` still used
placeholder collision values (`layer=32`, `mask=1`) instead of the ADR-0004
environment collision contract.

### GREEN Focused

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_electric_leak_contact_damage_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_518/`.

Summary: `5/5` passing, `0` errors, `0` failures. Coverage includes
environment layer/mask, contact damage metadata/feedback, same-window cooldown,
cooldown expiry, sustained overlap tick, and cleanup reset.

### Related Regression

Command:

```bash
/opt/homebrew/bin/godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/rat_king_electric_leak_contact_damage_test.gd -a res://tests/unit/gameplay/rat_king_arena_mutation_runtime_test.gd -a res://tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd -a res://tests/unit/gameplay/main_scene_audio_event_adapter_test.gd -a res://tests/unit/gameplay/rat_king_boss_runtime_contract_test.gd -a res://tests/unit/gameplay/main_scene_visual_contract_test.gd --ignoreHeadlessMode
```

Result: exit `0`, report `reports/report_519/`.

Summary: `24/24` passing, `0` errors, `0` failures after final signal-connection
dedupe cleanup.

## Headless Smoke

Command:

```bash
/opt/homebrew/bin/godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/rat_king_electric_leak_contact_damage_main_scene_smoke.log
rg -n "ERROR|Error|SCRIPT ERROR|WARNING|Warning|Failed|failed|Parse Error|Invalid" reports/rat_king_electric_leak_contact_damage_main_scene_smoke.log
```

Result: Godot exited `0`; `rg` returned no matches.

## Godot MCP Evidence

Session:

- Godot version: `4.6.3-stable (official)`.
- Editor scene: `res://scenes/main.tscn`.
- Runtime state: playing, game capture ready.

Runtime probe after final script changes:

```json
{
  "ok": true,
  "layer": 16,
  "mask": 12,
  "area_connections": 1,
  "body_connections": 1,
  "start_hp": 100,
  "first_hit": true,
  "after_first": 92,
  "immediate_hit": false,
  "after_immediate": 92,
  "after_overlap": 84,
  "mutation_count_before_cleanup": 3,
  "mutation_count_after_cleanup": 0
}
```

Interpretation:

- Phase 3 spawned `ArenaMutation_electric_leak` as an ADR-0004 environment
  `Area2D`.
- First contact applied 8 damage through the player damage path.
- Immediate second contact was suppressed by cooldown.
- Sustained overlap after 1.0 second applied another 8 damage.
- Boss-specific cleanup removed active arena mutations.

Logs:

- `logs_read(source="game", count=80)` returned only MCP helper registration
  and DataManager domain load lines for `boss_configs` / `enemy_stats`.
- `logs_read(source="editor", count=80)` returned `0` lines.

Screenshot:

- Runtime screenshot saved at
  `reports/visual/cinderpaw-mcp-electric-leak-contact-damage-20260625.png`.
- Screenshot is nonblank and visibly shows the Rat King phase 3 electric leak
  hazard in the playable arena.

## Acceptance Verdict

| Criterion | Evidence | Status |
|-----------|----------|--------|
| `electric_leak` uses ADR-0004 environment layer/mask | GdUnit focused test and MCP runtime probe | PASS |
| Player contact applies electric hazard damage through `PlayerController.apply_damage()` | GdUnit focused test and MCP HP probe | PASS |
| Damage feedback routes to CombatPresentation and AudioSystem | GdUnit fake AudioSystem event and metadata assertions | PASS |
| Same-window contact is cooldown-gated | GdUnit focused test and MCP immediate-contact probe | PASS |
| Sustained or repeated contact after 1.0 second damages again | GdUnit sustained overlap test and MCP overlap probe | PASS |
| Boss death/reset/cleanup clears hazard and cooldown state | GdUnit cleanup test and MCP cleanup probe | PASS |
| Related boss/runtime/audio/visual contracts remain compatible | `reports/report_519/` | PASS |
| Runtime logs are clean | Headless smoke log scan and MCP logs | PASS |
| Screenshot shows the hazard | MCP saved screenshot | PASS |

## Final Status

PASS. Story009 is implemented and verified by TDD, related regression, Godot
headless smoke, and Godot MCP runtime/log/screenshot evidence.
