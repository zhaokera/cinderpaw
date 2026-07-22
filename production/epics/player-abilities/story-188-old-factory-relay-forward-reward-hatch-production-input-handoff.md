# Story 188: Old Factory Relay-Forward Reward/Hatch Production-Input Handoff

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Production Input
> **Type**: Integration + Gameplay Runtime + Production Input + Visual Readability
> **Estimate**: S
> **Manifest Version**: 2026-07-20
> **Last Updated**: 2026-07-20

## Context

Story066 implemented the relay-forward reward cache and hatch APIs, but normal
Factory interaction never selected either endpoint. After Story187's trial was
defeated, real `interact` input could fall through to the nearby service lift
instead of claiming the reward and opening the route.

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`, `design/gdd/scene-management.md`

**Governing ADRs**: ADR-0004 Collision Detection; ADR-0007 Scene Management;
ADR-0018 Player Abilities; ADR-0021 Save System.

## Acceptance Criteria

- [x] The first real `interact` rising edge after the post-relay trial claims
  the nearest relay-forward reward cache through production `_process()`.
- [x] The reward remains exactly `20` gears from
  `old_factory_lower_deck_relay_forward_cache`, with feedback
  `Relay Forward Cache Claimed +20 Gears`.
- [x] Holding that press cannot chain into the newly available hatch or nearby
  service lift. After release, the second rising edge opens only the hatch.
- [x] The three-way overlap fixture proves cache, hatch and lift are all in
  range; no SceneManager exit request is issued on either interaction.
- [x] Opening the hatch disables its blocking collision, reports
  `Lower Deck Forward Hatch Opened` and persists both existing Story066 flags.
- [x] Restoring a valid local snapshot keeps the cache claimed, hatch opened
  and collision disabled without replaying the reward or combat.
- [x] Completed relay, pressure-valve and shortcut endpoints hide their stale
  interaction prompts so the active hatch prompt remains readable.
- [x] Thin RED/GREEN, bounded related regressions, a 180-frame Factory smoke
  and Godot MCP 3.0.4 real-input acceptance pass under Godot 4.7.

## Out Of Scope

Forward-conduit activation, service-lift routing, reward rebalance, new save
schema, global interaction refactors, new audio or visual assets, and
Story181's externally blocked authored pressure-valve animation.

## Implementation Notes

- The relay-forward cache joins the existing nearest-reward candidate list.
- The forward hatch joins the existing nearest Lower Deck progression list
  after the Story058-060 endpoints. Existing distance and tie-order rules stay
  authoritative.
- The rising-edge latch and immediate return after a successful consumer keep
  one press to one action, even though claiming synchronously unlocks the hatch.
- Relay prompt visibility now requires both availability and an unactivated
  relay. Existing reusable valve/shortcut endpoint settings hide their prompts
  after activation.

## Asset Use

No image-generation request was needed. The slice reuses the existing imported
and manifest-listed Cinderpaw, reward-cache, forward-hatch, relay, lift and Old
Factory environment assets. No placeholder or static character was added.

## Verification Evidence

- Canonical production RED: `reports/report_2104/results.xml` failed because
  real input did not claim the relay-forward cache and fell through to the lift.
- Visual REDs: `report_2109`, `report_2113` and `report_2116` isolated the
  completed relay, pressure-valve and shortcut prompts respectively.
- Focused GREEN: `reports/report_2117/results.xml` passed `1/1`.
- Final related GREEN: `reports/report_2118/results.xml` passed six suites at
  `11/11`, with zero failures, errors, flaky cases, skips or orphans.
- Godot 4.7 loaded the Factory scene for `180` fixed frames and exited `0` with
  no project parse, script, invalid-call/access or missing-resource error.
- Godot AI MCP 3.0.4 accepted run `r26427122-28`: two real `interact` rising
  edges claimed the cache and opened the hatch; the held press did not chain,
  the lift remained idle, current-run game logs contained helper info only and
  editor logs were empty.
- Accepted screenshots:
  `reports/visual/cinderpaw-mcp-old-factory-relay-forward-cache-production-input-20260720.png`
  and
  `reports/visual/cinderpaw-mcp-old-factory-forward-hatch-production-input-20260720.png`.
- Full evidence:
  `production/qa/evidence/old-factory-relay-forward-reward-hatch-production-input-handoff-2026-07-20.md`.

**Status**: [x] Complete.
