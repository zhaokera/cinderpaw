# Story 157: Main Scene Focus Mode Boss Windup Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core Signal / AI / Boss Runtime
> **Type**: Integration + Combat Readability
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/health-death.md`, `design/gdd/ai-framework.md`

**Requirements**: `TR-health-008`, `TR-ai-005`, Health & Death rule 8.

Story154 made the low-HP focus transition visible and audible, while the core
AI focus contract already defined a six-frame startup extension. The authored
Main Rat King and Echo Guardian encounters did not consume the real Player
Health signal, so entering focus mode had no effect on their actual attack
windups.

## Acceptance Criteria

- [x] Main routes the real Player `on_focus_mode_changed` signal to both the
  Rat King and Echo Guardian without creating a second focus-state owner.
- [x] Attacks started while focus is active add exactly six startup frames:
  Rat King `claw_swipe` changes from `15` to `21`, and Echo Guardian changes
  from `8` to `14`.
- [x] Focus changes affect only future attacks. Exiting focus during an active
  startup clears the future extension but does not shorten the in-flight
  `21`/`14` startup.
- [x] Active and recovery timing, attack selection, damage, thresholds,
  animation speed and the existing activation visual/audio remain unchanged.
- [x] Both Bosses expose bounded diagnostics for base startup, extension,
  current startup, phase and attack identity/sequence.
- [x] Focused RED/GREEN, bounded related regression, target smoke and one
  Godot MCP run verify real Main signal routing, three-frame attack animation,
  a non-empty screenshot and clean runtime/editor logs.

## Out Of Scope

- Applying focus perception changes to every enemy scene or authoring a new
  enemy/Boss.
- Expanding attack-tell area, changing background particles, crit windows,
  thresholds, hysteresis, damage or cooldown balance.
- New visual or audio assets. This Story reuses Story154's image-generated
  focus overlay and the existing three-frame Rat King/Echo Guardian attacks.

## Implementation Notes

- `HealthComponent` remains the sole focus state owner; Main only adapts its
  typed signal to encounter actors.
- `AIComponent` freezes base/effective startup when an attack starts so a
  later focus transition cannot mutate an in-flight attack.
- Echo Guardian mirrors the same future-only rule in its authored attack
  state machine, while Rat King delegates to `AIComponent`.

## Test Evidence

- `tests/unit/gameplay/main_scene_focus_mode_boss_windup_runtime_test.gd`
- `tests/smoke/main_scene_focus_mode_boss_windup_runtime_smoke.gd`
- `production/qa/evidence/main-scene-focus-mode-boss-windup-runtime-2026-07-14.md`
- `production/qa/evidence/main-scene-focus-mode-boss-windup-runtime-mcp-run32.json`

**Status**: [x] Complete.

- Initial RED: `reports/report_1656/results.xml`, one case with three expected
  missing-API failures.
- Focused GREEN: `reports/report_1657/results.xml`, `1/1` passed.
- Final bounded related GREEN: `reports/report_1659/results.xml`, `28/28`
  passed across Story157, Story154, AI focus, both Boss attack contracts and
  Main audio routing.
- Target smoke exited `0` with
  `main_scene_focus_mode_boss_windup_runtime_smoke=passed`.
- Godot `4.7-stable` / MCP `2.9.2` run `r26343036-32` verified focus entry,
  exact `21`/`14` startup values, future-only release behavior, both existing
  three-frame attacks, the generated focus overlay, a non-empty screenshot,
  three info-only game log entries, zero editor log entries and clean stop.
