# Story 165: Echo Guardian Attack Tell Frame Animation Runtime

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Boss Runtime / Visual Integration
> **Type**: Integration + Gameplay Runtime + Frame Animation Contract
> **Estimate**: S
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-14

## Context

**GDD**: `design/gdd/player-abilities.md`, `design/gdd/feline-combat.md`,
`design/gdd/ai-framework.md`, `design/gdd/boss-config.md`

**Requirements**: `TR-ability-005`, `TR-combat-001`, `TR-combat-004`,
`TR-ai-003`, `TR-ai-004`

**ADR Governing Implementation**: ADR-0002 Signal communication; ADR-0004
Collision detection; ADR-0005 Combat state machine; ADR-0006 AI behavior;
ADR-0010 Presentation; ADR-0018 Player abilities.

Stories022 and 025 used the existing strike frames during both startup and
active damage. The timing was playable, but the same silhouette made the
pre-hit warning visually ambiguous. This story adds a dedicated generated
three-frame coil-up tell while preserving the verified Boss2 combat contract.

This story supersedes only the startup animation mapping recorded by
Stories022 and 025. It does not reopen their timing, damage, collision,
metadata, AI, phase, save, reward, or audio behavior.

## Acceptance Criteria

- [x] Add exactly three continuously named transparent `160x128` PNG frames at
  `assets/characters/boss2_echo_guardian/attack_tell/` and retain the generated
  source, alpha source, prompt, processing metadata, and runtime paths.
- [x] Add a non-looping `attack_tell` animation to the existing Boss2
  `SpriteFrames` resource at `18 FPS`, without replacing any existing frame set.
- [x] `request_attack()` enters `startup`, plays `attack_tell`, and keeps
  `boss2_echo_swipe` inactive.
- [x] If Focus extends startup from `8` to `14` frames, the non-looping tell
  holds its last frame instead of restarting or falling back to frame zero.
- [x] The startup boundary switches to the existing `attack` animation exactly
  when the four-frame active phase begins and the hitbox becomes active.
- [x] Boss2 entity, HP, attack timing, cooldown, damage, hitbox, phase,
  presentation/audio routing, defeat, save flag, and Double Jump reward remain
  unchanged.
- [x] Thin RED/GREEN and bounded Boss2 regressions pass; Godot 4.7 imports the
  assets; Godot AI MCP 3.0.2 verifies the real Main encounter, clean logs, both
  animation states, hitbox boundaries, and non-empty screenshots.

## Preserved Gameplay Contract

| Contract | Preserved value |
| --- | --- |
| Entity / HP | `2200` / `36` |
| Startup | `8` frames; `14` under Focus |
| Active / recovery | `4` / `14` frames |
| Phase I / II cooldown | `28` / `24` frames |
| Damage | `14` |
| Hitbox | `72x34`, offset `(56,-38)` with facing applied |
| State order | startup -> active -> recovery -> cooldown |
| Defeat flag | `boss_02_echo_guardian_defeated` |
| Reward | Existing Double Jump reward path |

## Out of Scope

- New attack patterns, attack timing, damage, collision geometry, AI range,
  phase balance, reward flow, save schema, audio events, or camera behavior.
- Replacing `idle`, `run`, `attack`, `hurt`, or `death` art.
- Adding a second external warning effect; Story158's `FocusAttackTell` remains
  the focus-only area/duration amplifier.

## Implementation Notes

- `attack_tell` is entered once by `request_attack()`. Startup processing owns
  countdown only and must not replay the non-looping animation each frame.
- Active entry remains the sole owner of starting `attack` and activating
  `boss2_echo_swipe`.
- The generated poses show anticipation, deeper coil, and maximum stored
  tension. They contain no strike, slash, lunge, projectile, text, or scenery.

## Test Evidence

- Initial RED: `reports/report_1701/results.xml`, one expected missing-animation
  failure.
- Initial GREEN: `reports/report_1702/results.xml`, `1/1` passed before the
  extended-startup hold regression was added.
- Hold RED: `reports/report_1704/results.xml`, one case failed because the
  completed tell restarted at frame zero.
- Final focused GREEN: `reports/report_1705/results.xml`, `1/1` passed.
- Final bounded related GREEN: `reports/report_1708/results.xml`, `16/16`
  passed across tell, telegraph, autonomous pressure, payoff, Focus windup and
  Focus warning contracts.
- `reports/report_1706/` is rejected as a loop-sampling-sensitive assertion;
  isolated `reports/report_1707/` passed `6/6`, and the corrected related test
  records whether any run frame advances instead of sampling one wrap point.
- Godot 4.7 headless import exited `0` and imported all three runtime frames plus
  the retained generated/alpha source PNGs.
- Runtime evidence:
  `production/qa/evidence/boss2-echo-guardian-attack-tell-frame-animation-2026-07-14.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
| --- | --- | --- |
| Three transparent generated frames | Story165 test, asset metadata, PNG inspection | PASS |
| Non-looping SpriteFrames contract | Story165 test, MCP resource probe | PASS |
| Startup tell and inactive hitbox | Story165/Story022 tests, MCP startup probe | PASS |
| Last-frame hold under Focus | Story165 test, MCP deterministic advance | PASS |
| Active attack and active hitbox | Story165/Story022 tests, MCP active probe | PASS |
| Existing Boss2 contract preserved | Bounded 16-case regression | PASS |
| Clean real-scene runtime and screenshots | MCP run `r12850599-8` | PASS |

## Completion Notes

**Completed**: 2026-07-14

**Criteria**: 7/7 passing

**Deviation**: The frames keep the existing Boss2 `160x128` local contract even
though the Art Bible's generic Boss budget is smaller. Technical-art review
confirmed a shared `y=119` foot baseline and fixed canvas pivot; the authored
coil changes visible centroid by about 12px without moving the runtime node or
collision body. Rejected MCP runs and the corrected test-sampling issue remain
recorded in QA evidence and are not accepted as final runtime evidence.
