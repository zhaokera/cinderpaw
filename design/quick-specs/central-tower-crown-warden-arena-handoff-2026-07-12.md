# Quick Design Spec: Central Tower Crown Warden Arena Handoff

**Type**: Addition
**System**: Boss Configuration + Scene Management
**GDD Reference**: `design/gdd/boss-config.md`,
`design/gdd/scene-management.md`, `design/gdd/player-abilities.md`
**Date**: 2026-07-12

## Change Summary

Story144 ends at a durable Central Tower Apex Approach but the project has no
authored Boss4 identity or destination. This addition names the fourth mainline
boss **Crown Warden**, establishes its dedicated Crown Observatory arena, and
adds a bidirectional handoff without implementing the fight prematurely.

## Motivation

The complete-game tier requires four bosses, while `wall_climb` already names
`boss_04` as one valid unlock source. A dedicated transition slice gives the
Tower route a visible destination and isolates later Boss implementation from
the five-viewport traversal scene. It also prevents a static Boss placeholder
or an inferred final encounter from becoming production content.

## Boss4 Content Contract

| Contract | Value |
|----------|-------|
| Boss id | `boss_04_crown_warden` |
| Display name | `Crown Warden` |
| Identity | Giant mechanical owl built as the Central Tower's crown-defense and observation sentinel |
| Silhouette | Broad crescent wings, rotating mask/optic crown, articulated talons; visually distinct from Rat King, Echo Guardian and Sluice Matriarch |
| Player fantasy | A small agile cat hunts the tower's apex aerial predator |
| Required abilities | Fight must remain completable with `dash`, `double_jump`, `aerial_attack` and `parry`; `wall_climb` is optional because Boss4 is one unlock source |
| Future reward | Idempotent `wall_climb` unlock plus authored victory payoff; no reward is granted by Story145 |
| Future phase rule | Full encounter targets three readable phases per Boss GDD; Story145 implements no Boss phase or attack |

## Story145 Handoff Rules

1. Register `boss_04_crown_warden_arena` as a non-preloaded `boss_arena` at
   `res://scenes/bosses/crown_warden_arena.tscn`, default spawn `boss_entry`.
2. Add `CrownWardenArenaRoute` at the Story144 endpoint. It remains locked until
   `central_tower_apex_approach_secured=true`, then shows
   `Enter Crown Observatory` and accepts one nearby interaction.
3. A valid request persists the complete Tower local state before asking the
   existing asynchronous SceneManager for
   `boss_04_crown_warden_arena / boss_entry`. Loading, locked, unknown-scene,
   out-of-range and rejected requests do not leave a latched transition.
4. Add `ApexApproachReturnSpawn` at `(6200,296)`. Returning from the arena uses
   `area_05_central_tower / apex_approach_return`, restores Story140-144 durable
   state and exact abilities, and leaves the arena route available.
5. The arena is a bounded `1280x720` side-view Crown Observatory with floor,
   walls, entry marker, Cinderpaw, camera, objective and return route. Story145
   contains no Boss node, silhouette prop, room seal, HUD or combat damage.
6. The arena backdrop is a new opaque image-generation asset. The Tower entry
   and arena return use one new transparent generated crown-gate prop. Source,
   exact prompts, alpha intermediate, runtime outputs, asset spec, manifest,
   inventory and QA evidence are retained.
7. Story145's arena objective is `Crown Warden Signal Detected`; this identifies
   the approved future encounter without claiming that combat is active.

## Stable Scene Contract

| Contract | Value |
|----------|-------|
| Source scene | `area_05_central_tower` |
| Source prerequisite | `central_tower_apex_approach_secured` |
| Source route | `central_tower_crown_warden_arena_route` |
| Arena scene | `boss_04_crown_warden_arena` |
| Arena spawn | `boss_entry` / `(220,536)` |
| Return target | `area_05_central_tower / apex_approach_return` |
| Return position | `(6200,296)` |

## Acceptance Criteria

- [x] Boss4 identity, scene ids, route ids, prompts and spawn coordinates match
  this spec exactly.
- [x] Story144 completion alone unlocks a one-shot asynchronous arena request;
  every invalid request stays retryable.
- [x] The generated arena and crown gate replace player-facing primitive
  placeholders and are imported through Godot 4.7.
- [x] Arena return preserves Story140-144 state and exact abilities without a
  stale transition latch.
- [x] Focused/related tests, target smoke and Godot MCP verify both scenes,
  actual transition requests, current-run logs and non-empty screenshots.

## GDD Update Required?

No system-rule replacement is required. This file is a content contract under
the existing Boss Configuration, Scene Management and Player Ability rules.
Future Story146 must reference this contract before generating Crown Warden
character frames or implementing combat.
