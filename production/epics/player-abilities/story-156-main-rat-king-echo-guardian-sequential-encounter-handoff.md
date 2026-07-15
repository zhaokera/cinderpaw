# Story 156: Main Rat King to Echo Guardian Sequential Encounter Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Scene Management / HUD
> **Type**: Integration + ACT Pacing
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/player-abilities.md`

**Requirements**: `TR-ability-001`, Player Abilities rules 1 and 2,
Player Abilities Stories 021-033.

The GDD defines Rat King as the first mainline ability Boss (`dash`) and the
second Boss as the mainline `double_jump` source. Main currently authors Rat
King and Echo Guardian only 40 pixels apart and activates both at scene start.
Echo Guardian therefore chases during the Rat King fight while its HUD, camera
lock, room seals and arena frame incorrectly own the first encounter.

## Acceptance Criteria

- [x] A fresh Main scene presents Rat King as the only active Boss; Echo
  Guardian cannot move, attack, take routed damage or collide, and its arena
  frame, room seals, camera lock and Double Jump reward remain inactive.
- [x] Claiming the alternative hidden Double Jump path does not skip or activate
  the mainline Echo Guardian encounter.
- [x] Rat King death and the three-second victory presentation keep Echo
  Guardian inactive so the two Boss presentations never overlap.
- [x] Restoring Main with `boss_rat_king_defeated=true` and undefeated Boss2
  hides Rat King and atomically activates Echo Guardian AI/collision, its
  existing multi-frame sprite, arena frame, HUD focus, camera lock and room
  seals.
- [x] Existing Boss2 defeat, Double Jump reward, save/restore and Factory route
  handoff remain functional after activation.
- [x] One focused RED/GREEN acceptance test, bounded Boss2/Rat King regression,
  target smoke and one Godot MCP run verify the sequence, visible actors,
  non-empty screenshot and clean runtime/editor logs.

## Out Of Scope

- New Boss attacks, balance, rewards, rooms, transitions or world flags.
- Moving Boss2 into a new scene or redesigning the victory/main-menu flow.
- New visual/audio generation; this Story reuses the approved generated Echo
  Guardian character, arena, seal, reward and HUD assets.
- Changing the hidden Double Jump route or removing its non-linear reward.

## Test Evidence

- `tests/unit/gameplay/main_scene_sequential_boss_handoff_test.gd`
- `tests/smoke/main_scene_sequential_boss_handoff_smoke.gd`
- `production/qa/evidence/main-scene-sequential-boss-handoff-2026-07-14.md`

**Status**: [x] Complete.

- Initial RED: `reports/report_1640/results.xml`, `1` case with `1` expected
  failure before the sequential handoff API existed.
- Focused GREEN: `reports/report_1641/results.xml`, `1/1` passed.
- Bounded Boss2 related GREEN: `reports/report_1644/results.xml`, `21/21`
  passed across HUD, autonomous pressure, camera, seals, payoff and route.
- Bounded integration/visual/audio GREEN: `reports/report_1645/results.xml`,
  `28/28` passed across the focused Story, arena reset, telegraph, portrait,
  phase two, arena visual and Main audio routing.
- Target smoke exited `0` with
  `main_scene_sequential_boss_handoff_smoke=passed`.
- Godot `4.7-stable` / MCP `2.9.2` run `r22661784-28` verified the fresh Rat
  King encounter and the activated Echo Guardian encounter with two non-empty
  screenshots, three info-only game log entries, zero editor log entries and a
  clean stop to `ready`.
