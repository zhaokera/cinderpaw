# Story 009: Electric Leak Contact Damage

> **Epic**: Scene Management
> **Status**: Complete
> **Layer**: Feature
> **Type**: Integration
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-25

## Context

**GDD**: `design/gdd/boss-config.md`, `design/gdd/scene-management.md`,
`design/gdd/health-death.md`
**Requirements**: `TR-boss-004`, `TR-health-002`, `TR-scene-005`
*(Requirement text lives in `docs/architecture/tr-registry.yaml` — read fresh at
review time)*

**ADR Governing Implementation**: ADR-0007: Scene management architecture

**Related ADRs**: ADR-0004 Collision Detection, ADR-0019 HealthComponent

**ADR Decision Summary**: MainScene owns boss arena runtime mutations and routes
Feature-layer arena hazards into existing Core health damage APIs. Environment
damage uses ADR-0004 collision layering and must not introduce a new global
system or synchronous scene switch.

**Engine**: Godot 4.7 | **Risk**: LOW

**Control Manifest Rules (Feature layer)**:
- Required: boss battle scene lock prevents scene switching during boss fights.
- Required: scene-local state and boss arena reset paths remain deterministic.
- Required: runtime changes stay under Feature layer ownership.
- Forbidden: no synchronous scene switch and no extra Autoload for arena hazards.

---

## Acceptance Criteria

- [x] Phase 3 `electric_leak` damage-zone nodes use the ADR-0004 environment
  collision layer and mask player/enemy hurtboxes, not a private placeholder
  layer.
- [x] When the player contacts the active `electric_leak` damage zone, MainScene
  applies 8 electric hazard damage through `PlayerController.apply_damage()`.
- [x] Electric leak damage emits the same player-damage feedback route used by
  enemy hits: CombatPresentation hit feedback and AudioSystem
  `on_damage_taken_event` metadata.
- [x] Contact damage is rate-limited per boss/change/target with a 1.0 second
  cooldown so standing in the zone does not apply multiple hits in the same
  cooldown window.
- [x] After the contact cooldown elapses, continued or repeated contact can
  damage the player again.
- [x] Boss death, arena reset, and explicit arena mutation cleanup remove active
  hazard nodes and clear their contact cooldown state.

## Implementation Notes

- Extend Story008's `ArenaMutations` ownership model; do not create another
  manager/autoload.
- Use `Area2D.area_entered` and `get_overlapping_areas()` for ADR-0004
  `CollisionComponent` hurtboxes. `body_entered` remains a compatibility
  fallback for future `PhysicsBody2D` hazards on the same hurtbox mask; the
  current Player body itself is not part of the damage-zone mask.
- Keep damage deterministic and testable through a public MainScene contact
  adapter, so GdUnit can validate behavior without relying on headless physics
  event delivery.
- Use existing player health and damage feedback APIs. Do not bypass
  `PlayerController.apply_damage()` or `HealthComponent.apply_damage()`.
- Cooldown starts only after HP actually decreases; iframe/dodge/death/control
  lock immunity does not consume the electric leak cooldown.

## Out of Scope

- New electric leak VFX, particles, shader work, or additional generated visual
  assets.
- Persistent save serialization for destroyed or disabled hazard state.
- Hazard damage to Rat King or Rat Minions.
- New difficulty tuning UI or data-table balancing pass.

## QA Test Cases

- **AC-1**: Environment collision contract.
  - Given: Rat King reaches phase 3.
  - When: `electric_leak` is spawned.
  - Then: it is an `Area2D` on environment layer with player/enemy hurtbox mask.

- **AC-2**: Player contact damage feedback.
  - Given: player HP is full and `electric_leak` is active.
  - When: MainScene applies contact for the player.
  - Then: player HP decreases, damage metadata uses `electric_leak`, and audio
    damage feedback receives one event.

- **AC-3**: Cooldown prevents same-window repeat damage.
  - Given: player has just been damaged by `electric_leak`.
  - When: contact is applied again immediately.
  - Then: HP does not decrease a second time and no duplicate feedback event is
    emitted.

- **AC-4**: Cooldown expiry allows repeated hazard damage.
  - Given: player has been damaged by `electric_leak`.
  - When: arena hazard time advances past the cooldown.
  - Then: repeated contact damages the player again.

- **AC-5**: Cleanup clears cooldown state.
  - Given: contact cooldown is active.
  - When: arena mutations are cleaned up and reapplied.
  - Then: the same player can be damaged by the newly spawned leak immediately.

## Test Evidence

**Story Type**: Integration
**Required evidence**:
- Integration: `tests/unit/gameplay/rat_king_electric_leak_contact_damage_test.gd`
  must exist and pass.

**Status**: [x] Complete

**RED evidence**:
- `reports/report_510/`: expected RED, exit `100`, because Story008's
  `electric_leak` still used placeholder collision values (`layer=32`,
  `mask=1`) instead of ADR-0004 environment layer/mask.

**GREEN / regression evidence**:
- `reports/report_518/`: focused Story009 suite, `5/5` passing after adding
  sustained-overlap cooldown tick coverage.
- `reports/report_519/`: related gameplay/boss/audio/visual regression,
  `24/24` passing after final signal-connection cleanup.

**Runtime evidence**:
- Headless smoke log:
  `reports/rat_king_electric_leak_contact_damage_main_scene_smoke.log`, exit
  `0`, no error/warning matches.
- Godot MCP runtime probe: phase 3 spawned `ArenaMutation_electric_leak` with
  layer `16`, mask `12`, one `area_entered` and one `body_entered` connection;
  first contact reduced player HP `100 -> 92`, immediate contact was suppressed,
  sustained overlap after 1.0 second reduced HP `92 -> 84`, and cleanup reduced
  mutation count to `0`.
- Godot MCP logs: game log contained only MCP helper and DataManager load lines;
  editor log returned `0` lines.
- MCP screenshot:
  `reports/visual/cinderpaw-mcp-electric-leak-contact-damage-20260625.png`,
  nonblank and visibly showing the phase 3 electric leak hazard in the arena.

**QA evidence**:
- `production/qa/evidence/rat-king-electric-leak-contact-damage-2026-06-25.md`

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Environment layer/mask | `test_electric_leak_uses_environment_collision_contract`; MCP layer/mask probe | PASS |
| Contact damage + feedback | `test_electric_leak_contact_damages_player_and_routes_feedback`; MCP HP probe | PASS |
| Same-window cooldown | `test_electric_leak_contact_damages_player_and_routes_feedback`; MCP immediate-contact probe | PASS |
| Cooldown expiry | `test_electric_leak_contact_cooldown_allows_repeated_damage_after_elapsed_time` | PASS |
| Sustained overlap tick | `test_electric_leak_sustained_overlap_ticks_after_cooldown`; MCP overlap probe | PASS |
| Cleanup clears cooldown | `test_electric_leak_cleanup_clears_contact_cooldown_state`; MCP cleanup probe | PASS |

## Dependencies

- Depends on: Scene Management Story 008 Complete.
- Depends on: Boss Configuration Story 007 Complete.
- Unlocks: final arena VFX and boss arena mutation save-state persistence.
