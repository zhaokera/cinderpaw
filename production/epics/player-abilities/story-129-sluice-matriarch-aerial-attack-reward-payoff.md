# Story 129: Sluice Matriarch Aerial Attack Reward Payoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Gameplay Runtime / Presentation
> **Type**: Integration + Gameplay Runtime + Frame Animation Contract
> **Estimate**: M
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-11

## Context

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/feline-combat.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/hud-ui.md`,
`design/art/art-bible.md`

**Requirements**: `TR-ability-003`, `TR-ability-004`, `TR-ability-005`,
`TR-combat-001`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0002 Signal Communication; ADR-0004
Collision Detection; ADR-0005 Combat State Machine; ADR-0007 Scene Management;
ADR-0018 Player Abilities; ADR-0021 Save System.

Story128 ends with Sluice Matriarch defeated and the arena route open, but the
GDD progression reward is intentionally absent. Story129 completes that
victory payoff: a visible ability core appears, Cinderpaw claims it once,
`aerial_attack` persists with the scene/progression handoff, and airborne
attack input immediately becomes a downward strike with real damage, cat
energy, bounce, and restored air-jump capacity.

## Acceptance Criteria

- [x] Boss3 defeat makes a dedicated `AbilityRewardSource` visible and
  claimable in the arena. It remains locked before defeat and cannot be claimed
  twice.
- [x] Claiming the source unlocks `aerial_attack`, shows a readable HUD
  notification, updates the arena objective, and records the claimed flag plus
  unlocked ability list in scene-local state.
- [x] Restoring claimed state keeps the source consumed, keeps
  `aerial_attack` unlocked, and never replays the one-shot unlock payoff.
- [x] Before returning to Factory, the arena merges the current unlocked
  ability list into both Factory and Main scene states held by SceneManager so
  the reward survives the immediate route handoff.
- [x] In the air, the existing `attack` input prefers `aerial_attack` when it
  is unlocked; locked or grounded direct aerial requests are rejected.
- [x] A successful aerial request activates `cat_claw_aerial`, drives
  Cinderpaw downward, uses a dedicated `aerial_attack` animation, and emits
  attack metadata with `attack_type=aerial`.
- [x] A confirmed aerial hit routes normal weapon damage, grants exactly `8`
  cat energy through CombatComponent, bounces Cinderpaw upward once, and
  restores one consumed air-jump use without falsely marking the player
  grounded.
- [x] Cinderpaw's `aerial_attack` animation uses `AnimatedSprite2D +
  SpriteFrames` with exactly three transparent, consistently anchored `96x96`
  frames under `assets/characters/cinderpaw/aerial_attack/`.
- [x] The reward art and aerial frames are generated through built-in image
  generation, retain their source/prompt records, and are imported through the
  Godot 4.7 asset pipeline.
- [x] Focused RED/GREEN, bounded related regression, one targeted headless
  smoke, and Godot MCP 2.9.1 runtime validation pass with clean current-run
  logs and non-empty screenshots.

## Out of Scope

- Factory-to-Underground route construction, breakable-floor level content,
  aerial-heavy shockwave, additional Boss3 attacks/phases, victory cutscene,
  currency or skill-point rewards, new save schema, or a new Autoload.
- Rebalancing all weapon damage, changing existing ground combo timings, or
  expanding every prior scene's progression handoff in this slice.

## Implementation Notes

- Reuse `AbilityRewardSource` and the Boss2 one-shot reward pattern. The arena
  owns reward availability, persistence, HUD text, and scene-state handoff.
- `AbilityComponent` continues to own unlock/prerequisite checks. The player
  controller owns downward velocity, animation, hitbox request, and bounce.
- Use the existing `CombatComponent` aerial energy mapping. Do not grant energy
  a second time from presentation code.
- The GDD leaves exact bounce height open. Use a conservative bounded velocity
  that clearly interrupts the dive without exceeding the normal jump apex.

## QA Test Cases

- **AC-1: Reward claim and restore**
  - Given: an active or defeated-state Boss3 arena.
  - When: the boss dies and Cinderpaw claims the reward source.
  - Then: the source becomes consumed once, HUD/objective feedback changes,
    `aerial_attack` is unlocked, and restored state retains both facts.
- **AC-2: Aerial hit payoff**
  - Given: airborne Cinderpaw with `aerial_attack` unlocked.
  - When: attack input starts the dive and `cat_claw_aerial` confirms a hit.
  - Then: normal damage lands, cat energy increases by eight, Cinderpaw
    bounces upward once, and one air-jump use is restored.
- **AC-3: Runtime presentation**
  - Given: the generated frames and reward source are imported.
  - When: the arena is run through MCP and its presentation nodes/resources are
    inspected, while the reward and aerial states run in the targeted smoke.
  - Then: the reward and three-frame downward strike resolve to imported art,
    scene/script errors remain empty, and screenshots contain gameplay pixels.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/sluice_matriarch_aerial_attack_reward_payoff_test.gd`
- `tests/smoke/sluice_matriarch_aerial_attack_reward_payoff_smoke.gd`
- `production/qa/evidence/sluice-matriarch-aerial-attack-reward-payoff-2026-07-11.md`

**Status**: [x] Complete.

- Expected RED: `reports/report_1416/` (`3` expected failures before the
  reward, animation, persistence, and aerial runtime contracts existed).
- Final focused GREEN: `reports/report_1419/` (`3/3`).
- Final bounded related GREEN: `reports/report_1420/` (`20/20`).
- Targeted smoke: `reports/sluice_matriarch_aerial_attack_reward_payoff_smoke.log`
  with marker `sluice_matriarch_aerial_attack_reward_payoff_smoke=passed`.
- Godot MCP: session `cinderpaw@e40d`, Godot `4.7-stable`, MCP `2.9.1`,
  final run token `22`; forced scene reload, editor/runtime hierarchy,
  resource-path inspection, clean current-run logs, and non-empty
  `1278x718` gameplay screenshot all passed.
- Full evidence:
  `production/qa/evidence/sluice-matriarch-aerial-attack-reward-payoff-2026-07-11.md`.

## Dependencies

- Depends on: Story128 Sluice Matriarch Playable Boss3 Core.
- Unlocks: Story130 post-Boss3 aerial-attack exploration gate and Underground
  route handoff.
