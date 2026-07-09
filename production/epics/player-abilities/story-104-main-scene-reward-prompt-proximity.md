# Story 104: Main Scene Reward Prompt Proximity

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Core / Feature / Gameplay Runtime / Presentation Integration
> **Type**: Integration + UI/Visual Feel
> **Estimate**: XS
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-10

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`

**Requirements**: `TR-ability-003`, `TR-explore-001`,
`TR-presentation-001`

**ADR Governing Implementation**: ADR-0004 Scene Tree Composition; ADR-0005
Combat State Machine; ADR-0007 Scene Management; ADR-0018 Player Abilities.

MainScene already contains generated reward-source visuals for hidden Double
Jump and Boss2 Double Jump payoff, but their prompt labels could be visible
from far away. In the running scene this made `Claim Double Jump` float over the
Boss2 arena while Boss2 was still alive, even though the player was not in
interaction range. Story104 separates prompt visibility from reward
availability: rewards can stay available, but their prompt text only appears
when Cinderpaw is near enough to intentionally read or claim them.

## Acceptance Criteria

- [x] `AbilityRewardSource` supports a prompt provider and finite prompt
  radius separate from claim radius.
- [x] Reward prompt labels are hidden when the provider is absent or outside
  prompt radius.
- [x] Hidden Double Jump reward remains claimable exactly once, but its
  `Claim Double Jump` prompt appears only when the player is near the source.
- [x] Boss2 Double Jump reward remains locked while Boss2 is alive; after
  defeat it becomes claimable, but the prompt appears only when the player
  approaches the reward source.
- [x] Existing hidden reward, Boss2 reward payoff, room seal, gate, save-state,
  and factory route handoff behavior remains green.
- [x] Godot MCP verifies `res://scenes/main.tscn` runs on Godot 4.7 with
  `project_run.current_run_errors=[]`, clean current game log, and a non-empty
  screenshot showing no far-away `Claim Double Jump` prompt.

## Out of Scope

- New reward art, new image-generation assets, reward placement changes, boss
  balance, camera framing, HUD redesign, or new input prompts.
- Character frame animation changes. This story only adjusts reward prompt
  behavior and does not add or modify player-visible character sprites.

## Implementation Notes

- `src/feature/ability_reward_source.gd` now has `prompt_radius_px` and
  `set_prompt_provider(provider)`.
- Prompt labels are visible only when `is_claim_available()` is true and the
  provider is inside `max(prompt_radius_px, claim_radius_px)`.
- `src/gameplay/main_scene.gd` passes the player as prompt provider while
  syncing/processing hidden and Boss2 reward sources.
- Claim radius remains unchanged, so save-state and idempotent unlock behavior
  are preserved.

## Test Evidence

**Required evidence**:

- `tests/unit/gameplay/hidden_double_jump_reward_source_runtime_test.gd`
- `tests/unit/gameplay/boss2_victory_route_handoff_test.gd`
- `tests/unit/gameplay/boss2_double_jump_payoff_runtime_test.gd`
- `tests/unit/gameplay/boss2_room_seal_runtime_test.gd`
- Godot MCP runtime evidence under
  `production/qa/evidence/main-scene-reward-prompt-proximity-2026-07-10.md`

**Status**: [x] RED/GREEN focused evidence, related regression, and MCP
runtime evidence complete.

- RED focused: `reports/report_1275/` failed as expected because hidden and
  Boss2 reward prompts were visible outside the intended proximity behavior.
- GREEN focused: `reports/report_1277/` passed the hidden reward and Boss2
  victory route prompt-proximity checks `3/3`.
- Related regression: `reports/report_1278/` passed Boss2 victory handoff,
  Boss2 Double Jump payoff, Boss2 room seal, and hidden Double Jump reward
  coverage `9/9`.
- Godot MCP evidence:
  `production/qa/evidence/main-scene-reward-prompt-proximity-2026-07-10.md`.

## Test-Criterion Traceability

| Criterion | Test / Evidence | Status |
|-----------|-----------------|--------|
| Prompt provider and finite prompt radius | `report_1275`, `report_1277` | COVERED |
| Hidden reward prompt hidden at distance and visible near source | `hidden_double_jump_reward_source_runtime_test` | COVERED |
| Boss2 reward locked/alive prompt hidden and post-defeat near-source prompt visible | `boss2_victory_route_handoff_test` | COVERED |
| Reward claim/save/gate behavior remains intact | `report_1278` | COVERED |
| Runtime scene screenshot no longer shows far-away `Claim Double Jump` | MCP evidence and screenshot | COVERED |

## Completion Notes

**Completed**: 2026-07-10
**Criteria**: 6/6 passing
**Deviations**: No new image-generation asset was required; this is a runtime
prompt behavior pass over existing generated reward visuals.
**QA Evidence**:
`production/qa/evidence/main-scene-reward-prompt-proximity-2026-07-10.md`
