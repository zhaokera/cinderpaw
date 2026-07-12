# Quick Design Spec: Central Tower Cooling Shaft Roost Traverse

> **Status**: Approved for bounded implementation
> **Story**: 142
> **Date**: 2026-07-12

## Problem

Story139-141 now create an outer parry trial, Threshold Guard, relay parry,
ordinary Mantis fight, and optional cache. A third consecutive combat beat would
flatten the Tower's rhythm and still leave deeper progress without a fair retry
anchor. Boss4 remains undefined and cannot be inferred from a route extension.

## Decision

Extend `area_05_central_tower` from two to three `1280x720` viewports. The new
Cooling Shaft is a short post-combat traversal:

1. Defeating the Story141 Relay Mantis opens the route. Claiming its cache stays
   optional and never gates mainline progress.
2. A generated Cooling Shaft Roost gives a new full-HP recovery anchor and
   slot-zero autosave before the gap.
3. Cinderpaw crosses a broken suspension conduit using established jump,
   double-jump, dash, fall, and wall-climb behavior while timing a cyclic arc.
4. Arc contact deals fixed non-lethal damage with per-target cooldown; falling
   into the shaft is lethal and revives at the new Roost through the existing
   Tower GameFlow.
5. A generated far-side beacon records a durable bounded endpoint. It does not
   request another scene and does not imply a Boss arena.

## Stable Contract

| Contract | Value |
|----------|-------|
| Scene id / path | `area_05_central_tower` / `res://scenes/areas/central_tower_threshold.tscn` |
| Expanded scene size | `3840x720` |
| Route prerequisite | `central_tower_relay_mantis_defeated` |
| Controller | `CentralTowerCoolingShaftController` |
| Roost id / spawn | `central_tower_cooling_shaft_roost` / `cooling_shaft_roost` |
| Roost state | `central_tower_cooling_shaft_roost_activated` |
| Route activation | `central_tower_cooling_shaft_activated` |
| Endpoint id | `central_tower_cooling_shaft_endpoint` |
| Endpoint state | `central_tower_cooling_shaft_traversed` |
| Arc id / damage / cooldown | `central_tower_cooling_shaft_arc` / `10` / `1.0s` |

## Authored Geometry

- Third background center: `(3200, 360)`.
- Cooling Shaft Roost / spawn: `(2740, 576)` / `(2740, 552)`.
- Approach floor: x `2540..2920`; exit floor: x `3480..3840`.
- Lethal shaft: x `2920..3480`; fall zone center `(3200, 680)`.
- Magnetic conduit spines: x `3060` and `3390`; mid perch center
  `(3225, 438)`.
- Cyclic arc center: `(3220, 430)`.
- Endpoint center: `(3690, 576)`; right boundary x `3860`.

## Hazard Timing

- Route activation starts `grace 0.75s -> warning 0.50s -> active 0.35s ->
  safe 0.70s`, then loops `warning -> active -> safe`.
- Only `active` contact can deal `10` electric damage. Repeated overlap from the
  same target is rejected for `1.0s`.
- The generated arc is low-alpha signal red during warning, bright white/cyan
  during active, faint cyan during safe, and hidden before route activation or
  after endpoint completion.

## Save, Death, And Persistence

- Roost activation succeeds once at close range, restores full HP through the
  public player path, records the latest savepoint, emits established
  savepoint audio/VFX, and requests one slot-zero autosave.
- A lethal fall uses the existing Tower `1.5s` death delay, revives Cinderpaw at
  the Cooling Shaft Roost with 50% HP and the existing 120-frame protection,
  and preserves Story140/141 clear, optional cache claim, Roost activation, and
  exact abilities.
- Hazard phase and contact cooldown are attempt-local. Death resets them to the
  route grace phase. Roost activation and endpoint completion are durable.
- Fresh restore backfills route activation when endpoint completion exists and
  never replays Roost, autosave, audio, VFX, or endpoint feedback.

## Visual Direction

- The background is an asymmetrical vertical maintenance shaft, not a centered
  arena: safe ledge at left, broken conduit crossing in the middle, narrow exit
  at right, visible depth below.
- Steel blue and blue-gray dominate structure; cyan marks traversable magnetic
  surfaces; sparse amber marks service safety; signal red appears only during
  hazard warning/active windows.
- Interactive props remain separate transparent sprites. No baked actor, text,
  reward, collision shape, visible primitive placeholder, throne, giant seal
  core, or Boss-facing symmetry is accepted.
- Existing Cinderpaw `run`, `jump`, `fall`, `wall_climb`, `hurt`, and `revive`
  frame animations provide the player-visible movement language. No character
  art is added in this Story.

## Out Of Scope

- Boss4 identity, data, arena, phases, reward, music, narrative, or ending.
- New scene id or handoff, fourth viewport, enemy, ability, reward cache, NPC,
  dialogue, minimap, fast travel, secret room, or global hazard framework.
- Rebalancing Story139-141 or changing shared PlayerController, GameFlow,
  SaveSystem, SceneManager, or animation resources.

## Verification Budget

- One three-case focused RED/GREEN suite.
- One Story141 adjacent regression and one savepoint-selection regression only;
  no Rooftops replay and no full suite.
- One target headless smoke starting from Story141 clear.
- One final Godot MCP run with real movement ability input, Roost/hazard/revive
  state, endpoint, non-empty screenshot, and current-run log review.
