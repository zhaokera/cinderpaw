# Story 032: Boss2 Phase II Runtime Pressure Mix

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Presentation / Audio
> **Type**: Integration + Gameplay Runtime + Combat Feel + Audio
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-06-30

## Context

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/boss-config.md`,
`design/gdd/ai-framework.md`, `design/gdd/combat-presentation.md`,
`design/gdd/audio-system.md`

**Requirements**: `TR-ability-005`, `TR-boss-002`, `TR-boss-004`,
`TR-ai-006`, `TR-combatfx-001`

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0004 AI
framework; ADR-0005 Combat state machine; ADR-0006 Boss configuration;
ADR-0007 Scene management; ADR-0010 Combat presentation; ADR-0018 Player
abilities; ADR-0021 Save system.

Stories021-031 made Boss2 visible, animated, threatening, bounded, camera
locked, room sealed, HUD-focused, and portrait-supported. Boss2 still behaved
as a single pressure state at low health. This story adds a minimal readable
Phase II runtime pressure mix: when Echo Guardian reaches half HP, it updates
the HUD phase, increases chase pressure, shortens attack cooldown, routes phase
feedback through CombatPresentation, and switches the boss music mix through
AudioSystem.

## Acceptance Criteria

- [x] Boss2 exposes deterministic phase diagnostics and starts in Phase I at
  full HP.
- [x] Damaging Boss2 from `36/36` to `18/36` enters Phase II, updates Boss HUD
  text to `Echo Guardian  Phase II  18/36`, and keeps Boss2 HUD focus.
- [x] Phase II increases runtime pressure without adding a new attack: chase
  step rises from `3.0` to `3.6` px and attack cooldown target drops from `28`
  to `24` frames.
- [x] If the HP threshold is crossed during `startup`, `active`, or `recovery`,
  the current attack chain is not interrupted; Phase II feedback is deferred
  until the attack returns to idle.
- [x] Boss2 Phase II emits `on_boss_phase_transition_started` metadata with
  `boss_id="boss_02_echo_guardian"`, `display_name="Echo Guardian"`,
  `previous_phase=1`, `phase=2`, `hp_percentage=0.5`, `chase_step_px=3.6`,
  `attack_cooldown_frames=24`, and `attack_speed_modifier=1.2`.
- [x] MainScene routes Boss2 phase transitions to CombatPresentation,
  AudioSystem, and the active Boss HUD without stealing Rat King-only phase
  behavior.
- [x] AudioSystem registers Boss2 Phase I/II boss music cues and routes Phase II
  transition to `mus_boss_rat_p2` plus `sfx_boss_phase`.
- [x] Existing Boss2 telegraph strike, autonomous pressure, arena bounds/reset,
  Double Jump payoff, camera lock, room seal, HUD focus, HUD hit flash, and HUD
  portrait behavior remain unchanged.
- [x] Focused RED/GREEN tests, related Boss2 regressions, headless smoke, and
  Godot MCP 2.8.1 runtime evidence are recorded.

## Out of Scope

- New Boss2 attacks, summons, Phase III, new visual assets, new audio assets,
  new autoloads, final authored boss music, final boss balancing, cutscenes,
  minimap markers, and deeper Old Factory route content.

## Implementation Notes

- Keep Phase II local to `Boss2EchoGuardian`; do not introduce a generic boss
  phase manager for this slice.
- Reuse existing CombatPresentation boss phase overlay/debris and existing boss
  music assets. This story changes routing and mix state only.
- Defer the phase transition while an attack chain is active so startup/active
  hitbox timing remains readable and stable.
- Preserve the Story021 Double Jump reward path and defeated-progress cleanup.

## Test Evidence

- Gameplay RED focused: `reports/report_863/` failed as expected before Boss2
  exposed Phase II runtime APIs.
- Attack-chain deferral RED: `reports/report_866/` failed as expected when the
  transition fired immediately during startup.
- Audio RED focused: `reports/report_869/` failed as expected before Boss2 music
  cues were registered.
- Audio GREEN focused: `reports/report_870/` passed `1/1`.
- Story032 focused GREEN: `reports/report_876/` passed `4/4` across Boss2
  gameplay Phase II and AudioSystem Boss2 phase mix tests.
- Boss2 autonomous pressure regression: `reports/report_878/` passed `6/6`.
- Related Boss2 regression: `reports/report_877/` passed `31/31`.
- Headless main-scene smoke:
  `reports/boss2_phase_two_runtime_pressure_mix_main_scene_smoke.log`; keyword
  scan found no script, parse, invalid-call, missing-resource, or resource-load
  errors; only Godot's known cleanup-time `resources still in use at exit`
  message appeared after exit.
- Godot MCP 2.8.1 runtime evidence:
  `production/qa/evidence/boss2-phase-two-runtime-pressure-mix-2026-06-30.md`.

**Status**: [x] Complete.
