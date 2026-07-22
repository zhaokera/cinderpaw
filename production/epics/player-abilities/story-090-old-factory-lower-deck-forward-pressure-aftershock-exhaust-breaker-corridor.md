# Story 090: Old Factory Lower Deck Forward Pressure Aftershock Exhaust Breaker Corridor

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Route Progression
> **Type**: Integration + Gameplay Runtime + Visual/Feel
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-22

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/feline-combat.md`, `design/gdd/scene-management.md`,
`design/gdd/death-respawn.md`

**Requirements**: `TR-scene-004`, `TR-explore-005`, `TR-combat-001`,
`TR-respawn-002`

**ADR Governing Implementation**: ADR-0004 Collision detection; ADR-0007 Scene
management; ADR-0018 Player abilities; ADR-0021 Save system.

Story089 cleared the aftershock exhaust flank at the far right of the lower
deck, but the authored route geometry still ended at x `2400.0`, behind the
Story086-089 content. Story090 makes that content physically reachable by
extending the corridor to x `3200.0`, then adds a new ACT pressure beat: after
the flank is cleared, crossing x `2928.0` activates a reused animated Factory
Coil Rat, a reused steam vent hazard, and a final aftershock exhaust breaker
console that can be cut once the guard is defeated.

## Acceptance Criteria

- [x] `factory_route_transition_shell.tscn` extends the playable route to x
  `3200.0`: ground width, background width, right wall, and `Player/Camera2D`
  right limit all cover the Story086-090 right-side content.
- [x] `FactoryLowerDeckForwardPressureAftershockExhaustBreakerCoilRat`,
  `FactoryLowerDeckForwardPressureAftershockExhaustBreakerVent`, and
  `FactoryLowerDeckForwardPressureAftershockExhaustBreaker` exist in
  `factory_route_transition_shell.tscn`.
- [x] The breaker corridor is unavailable until
  `factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush_cleared=true`;
  manual activation returns `false` while locked and does not reveal the Coil
  Rat, steam vent, or breaker console.
- [x] Once Story089 is cleared, crossing activation x `2928.0` activates entity
  `2133`, assigns Cinderpaw as target, enables process/physics, starts opening
  grace frame pacing `10`, starts the steam vent warning, and updates route
  feedback to `Secure Aftershock Exhaust Breaker`.
- [x] The vent warning lasts `21` physics frames with contact disabled and a
  four-frame warning animation before the hazard becomes active. Vent x
  `2880` and Coil Rat x `3008` provide a `128px` initial center gap.
- [x] Story089's lethal frame and restored-state teleport cannot auto-activate
  Story090. Availability must exist at frame start and a later positive x
  movement sample must cross `2928.0`; while inactive, entity `2133` remains
  hidden, non-processing, non-physical, `24 HP`, and hurtbox `gone`.
- [x] The enemy uses `AnimatedSprite2D + SpriteFrames` with `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death` animations, each with at least
  3 transparent PNG frames from `assets/characters/factory_coil_rat/`.
- [x] The vent uses hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker`, applies
  `8` steam damage to the player only, respects `1.0s` cooldown, and disables
  contact after the breaker guard is secured.
- [x] Defeating entity `2133` persists
  `factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_activated=true`,
  `factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_coil_rat_defeated=true`,
  and `factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_secured=true`,
  disables the Coil Rat's physics/target/hurtbox while preserving visible,
  processing three-frame `death`, hides the vent, reveals the breaker console,
  and updates route feedback to `Cut Aftershock Exhaust`. Restored completed
  state hides the defeated enemy.
- [x] Activating the breaker persists
  `factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut=true`,
  plays the existing unlock spark once, rejects duplicate activation, marks the
  route objective complete, and updates route feedback to
  `Aftershock Exhaust Pressure Cut`.
- [x] The breaker uses a `120px` radius in the production nearest-interaction
  chain. A real `interact` rising edge cuts it once; Story091 becomes
  available in that frame but remains inactive until a later fresh positive
  movement sample.
- [x] Restoring completed state keeps Story090 inactive/cut, keeps Story089
  cleared, keeps Story074 exit relay contract stable, does not replay Story068
  clear burst or Story071 reward-cache audio, and preserves
  `FactoryServiceLift` prompt `Call lift`.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.9.1, including scene load, target nodes,
  SpriteFrames frame counts, active runtime diagnostics, breaker cut state, and
  a non-empty screenshot showing the active right-side encounter.

## Out of Scope

New generated character art, new enemy family, new AI behavior tree, new reward
cache, new reward economy, new savepoint, SaveSystem schema changes,
service-lift route changes, minimap/fast travel UI, authored audio,
particles/shaders, Boss2, and broader lower-deck biome art replacement.

## Implementation Notes

- Reuse existing `FactoryCoilRat` gameplay scene and imported frame animation
  assets for entity `2133`.
- Reuse `FactorySteamVentHazard` and
  `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`.
- Reuse the generated forward-pressure breaker console texture for the
  aftershock exhaust breaker stand.
- Keep Story090 state scene-local through
  `OldFactoryEntranceScene.get_local_state()` / `set_local_state()`.
- Use breaker id
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker` and
  hazard id `old_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker`.
- Keep the Story074 relay as the active non-boss respawn anchor; Story090 does
  not write a new savepoint contract.

## Asset Pipeline

No new visual assets are required for this Story. It reuses imported,
image-generated assets already in the Godot pipeline:

- Factory Coil Rat SpriteFrames:
  `assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`
- Old Factory steam vent runtime texture:
  `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`
- Old Factory forward-pressure breaker console:
  `assets/environment/old_factory_forward_pressure_breaker/env_old_factory_forward_pressure_breaker_console_256.png`

Reuse is recorded in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, this story, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_corridor_test.gd`
  - Initial RED: `reports/report_1206/`
  - Final focused GREEN: `reports/report_1208/` (`2/2`)
- Related regression:
  Story090 plus Story089, Story088, Story087, Story086, Story085, Story084,
  Story083, Story074 exit relay, service-lift, no-loss respawn, Story068
  no-replay, Story071 reward-cache audio no-replay, forward conduit clear
  feedback, forward pressure reward-cache audio, and steam-vent hazard suites.
  - Diagnostic compatibility RED: `reports/report_1209/`
  - Final GREEN: `reports/report_1210/` (`35/35`)
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks confirm scene load, route geometry,
  target nodes, live Story089-cleared to Story090 activation, Coil Rat
  `AnimatedSprite2D + SpriteFrames` frame counts, active hazard id/damage/
  cooldown/texture, entity `2133` defeat, breaker cut, duplicate-cut rejection,
  local-state flags, service lift preservation, project-run recent errors
  empty, and a non-empty `960x539` game screenshot with the active breaker
  corridor.
  - Headless smoke:
    `reports/old_factory_forward_pressure_aftershock_exhaust_breaker_corridor_smoke.log`
  - QA evidence:
    `production/qa/evidence/old-factory-forward-pressure-aftershock-exhaust-breaker-corridor-2026-07-09.md`

## Dependencies

- Depends on: Story089 Old Factory Lower Deck Forward Pressure Aftershock Exhaust Flank Ambush
- Unlocks: deeper Old Factory route content after the aftershock exhaust breaker

## Verification Summary

- Initial focused RED `reports/report_1206/` failed before the route extension,
  Story090 scene nodes, diagnostics, activation APIs, and local-state fields
  existed.
- Focused GREEN `reports/report_1208/` passed `2/2`.
- Related RED `reports/report_1209/` exposed a Story089 diagnostics
  compatibility issue where a defeated Spark Rat could still report stale
  entity id `2132`; the diagnostics now return entity id `0` once Story089 is
  cleared without changing enemy lookup or damage routing.
- Final related GREEN `reports/report_1210/` passed `35/35`.
- Headless smoke exited `0`; the smoke log had no project script, parse,
  invalid-call, invalid-access, missing-resource, or resource-load errors by
  keyword scan. The Godot process still printed the existing cleanup-time
  ObjectDB/resource messages at process exit.
- Godot AI MCP `2.9.1` / Godot `4.7-stable` confirmed plugin/server version,
  helper live, scene nodes, active entity `2133`, Coil Rat SpriteFrames path and
  3-frame counts for `idle/run/attack_tell/attack/hurt/death`, active hazard
  id/damage/cooldown/texture, `apply_damage(2133, 999)=true`, secured and cut
  local flags, duplicate cut `false`, final route label
  `Aftershock Exhaust Pressure Cut`, runtime scene tree containing the new
  breaker and vent nodes, and a non-empty `960x539` game screenshot.
- The MCP tool surface in this session did not expose `logs_read`; runtime log
  evidence therefore comes from `project_run.recent_errors=[]`, fresh log clear
  before launch, and the headless smoke log scan.
- Story208 added fresh-movement/same-frame protection and inactive hurtbox
  safety before Story090 production combat. Its first bounded run
  `reports/report_2256/results.xml` exposed this Story's stale immediate-hide
  death assertion; focused `reports/report_2257/results.xml` passed `2/2` after
  aligning with the shared live-death contract. Final bounded
  `reports/report_2258/results.xml` passed five suites and `11/11`.
- Godot 4.7 / MCP 3.0.4 accepted run `r137556639-60` left Story090 available
  but inactive after Story089 clear: entity `2133` stayed hidden,
  process/physics off, `24 HP`, hurtbox `gone`, with vent and breaker hidden.
- Story209 completed Story090's production path. Final bounded
  `reports/report_2267/results.xml` passed five suites and `10/10`; focused
  `reports/report_2268/results.xml` and `reports/report_2269/results.xml`
  passed after the 21-frame warning and early-diagnostic null guard.
- Godot 4.7 / MCP 3.0.4 accepted run `r139679441-66` verified real movement,
  warning contact-off, real 8-damage steam overlap, the 10-damage Coil bite,
  two real attacks `24 -> 12 -> 0`, live death, real breaker interaction,
  clean logs and Story091 available/inactive handoff.
