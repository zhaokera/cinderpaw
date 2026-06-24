# Story 008: Runtime Player Attack Core Chain

> **Epic**: Feline Combat
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-24

## Context

**GDD**: `design/gdd/feline-combat.md`, `design/gdd/collision-detection.md`, `design/gdd/health-death.md`, `design/gdd/weapon-styles.md`
**Requirements**: `TR-combat-006`, `TR-combat-010`, `TR-collision-005`, `TR-collision-007`, `TR-health-001`, `TR-weapon-006`

**ADR Governing Implementation**: ADR-0002: Signal communication; ADR-0004: Collision detection architecture; ADR-0005: Combat state machine architecture; ADR-0016: Weapon styles architecture
**ADR Decision Summary**: Runtime player attacks should enter CombatComponent, activate weapon hitboxes through CollisionComponent, resolve damage through DamageCalculator into HealthComponent, and enrich confirmed hit metadata with WeaponComponent effects.

**Engine**: Godot 4.6.3 | **Risk**: LOW
**Engine Notes**: Runtime integration uses existing GDScript components and Godot signals. CollisionComponent now extends Node2D so managed Area2D hitboxes inherit entity transforms in live scenes.

**Control Manifest Rules (Feature/Core)**:
- Required: Core layer systems are scene components on entity nodes.
- Required: Hit confirmations use `on_hit_confirmed` and HitEvent metadata.
- Required: Presentation consumes signals; Core does not call Presentation directly.
- Forbidden: No direct prototype damage bypass for the player attack path.

---

## Acceptance Criteria

- [x] Player runtime light attack calls CombatComponent and activates the current WeaponComponent hitbox through CollisionComponent.
- [x] A confirmed player hit damages the runtime enemy through HealthComponent, not prototype `body.take_damage()`.
- [x] Duplicate-hit tracking prevents the same active player hitbox from damaging the same enemy twice.
- [x] Runtime hit metadata reaches MainScene/CombatPresentation with weapon id, attack type, target id, final damage, and battle-stat updates.
- [x] Switching to Electro Bell before a runtime hit applies `slow` to the enemy StatusEffectComponent with 2.0s duration and 0.7 movement modifier.
- [x] Godot MCP can launch `res://scenes/main.tscn`, execute runtime attack probes, read game logs, and capture a nonblank game screenshot.

## Implementation Notes

- PlayerController owns runtime CombatComponent and CollisionComponent children created at ready time if absent.
- MainScene injects the active WeaponComponent, target enemy adapter, and RuntimeDamageCalculatorAdapter into the player.
- SimpleEnemy now exposes HealthComponent, CollisionComponent, and StatusEffectComponent adapters while preserving the old `take_damage()` entry point as a HealthComponent proxy.
- CollisionComponent extends Node2D so hitboxes and hurtboxes inherit entity transforms in the live scene tree.

## Out of Scope

- Multi-enemy target registry and target-specific health routing beyond the current one-enemy vertical slice.
- New attack animations, hitstop, particles, audio, combo HUD, and animation-frame authored hitbox timing.
- Enemy attack execution.

---

## QA Test Cases

- **AC-1**: Player attack core chain
  - Given: `main.tscn` is instantiated
  - When: `Player.request_attack()` activates `cat_claw_light` and CollisionComponent confirms overlap with the enemy hurtbox
  - Then: enemy HP decreases, Combat stats record one hit, metadata contains weapon id, attack type, target id, and final damage
  - Edge cases: processing the same overlap again does not apply duplicate damage

- **AC-2**: Electro Bell runtime slow
  - Given: MainScene current weapon is `electro_bell`
  - When: the player confirms a runtime hit on the enemy
  - Then: enemy StatusEffectComponent has `slow`, remaining duration is 2.0s, and movement modifier is 0.7

- **AC-3**: MCP runtime verification
  - Given: Godot MCP session `cinderpaw@c4d7` is ready
  - When: MCP launches `res://scenes/main.tscn` and runs `game_eval`
  - Then: cat-claw and electro-bell attack probes return expected HP, damage, and slow-status values

---

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd` — must exist and pass

**Status**: [x] Created and passing

**Evidence 2026-06-24**:
- TDD RED: `reports/report_341/` — failed on missing runtime attack contract (`request_attack`, component getters, metadata hook).
- GREEN: `reports/report_342/` — `main_scene_player_attack_core_chain_test.gd` 2/2 passing.
- Focused regression: `reports/report_343/` — 29 suites, 134/134 passing across gameplay, combat, collision, health, status, and weapon.
- Headless runtime smoke: `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 120 --log-file reports/player_attack_core_chain_main_scene_smoke.log` exited 0; log scan found no ERROR/WARNING lines.
- MCP runtime:
  - `session_manage list` found active `cinderpaw@c4d7`, Godot `4.6.3-stable (official)`, ready.
  - `project_run` launched `res://scenes/main.tscn`.
  - Cat Claw `game_eval`: HP 30 -> 12, final damage 18, Combat `hits_landed = 1`.
  - Electro Bell fresh `game_eval`: HP 30 -> 18, final damage 12, `slow_status_applied = true`, `has_slow = true`, `slow_remaining = 2.0`, `movement_modifier = 0.7`.
  - `logs_read(source="game", count=80)` returned only the MCP helper registration line and no game errors.
  - Runtime screenshot: `reports/visual/cinderpaw-mcp-player-attack-core-chain-20260624.png`.

## Completion Notes

**Completed**: 2026-06-24
**Criteria**: 6/6 passing
**Deviations**: None
**Test Evidence**: `tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd`
**Runtime Evidence**: MCP `game_eval` probes plus screenshot under `reports/visual/`

**Traceability**:

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Player light attack calls Combat and activates Weapon/Collision hitbox | `test_player_light_attack_damages_enemy_through_core_chain_once` | COVERED |
| Confirmed hit damages enemy HealthComponent | `test_player_light_attack_damages_enemy_through_core_chain_once` | COVERED |
| Duplicate hitbox tracking prevents second damage | `test_player_light_attack_damages_enemy_through_core_chain_once` | COVERED |
| Runtime metadata reaches MainScene/Presentation path | `test_player_light_attack_damages_enemy_through_core_chain_once`; MCP cat-claw probe | COVERED |
| Electro Bell applies slow to runtime enemy StatusEffectComponent | `test_electro_bell_runtime_hit_applies_slow_to_enemy_status_component`; MCP electro-bell probe | COVERED |
| MCP launches, evaluates, logs, and screenshots game | `production/qa/evidence/player-attack-core-chain-2026-06-24.md` | COVERED |

---

## Dependencies

- Depends on: Feline Combat Story 007, Collision Detection Story 005, Weapon Styles Story 008, Health/Death Story 001, Status Effects Story 003.
- Unlocks: Combat feel/presentation, enemy attack execution, richer player animation hitbox timing, and multi-enemy combat integration.
