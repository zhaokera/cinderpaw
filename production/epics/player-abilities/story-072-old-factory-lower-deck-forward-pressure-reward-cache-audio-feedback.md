# Story 072: Old Factory Lower Deck Forward Pressure Reward Cache Audio Feedback

> **Epic**: Player Abilities
> **Status**: Complete
> **Layer**: Gameplay Runtime / Old Factory / Audio Feedback
> **Type**: Integration + Gameplay Runtime + Audio/Feel
> **Estimate**: XS
> **Manifest Version**: 2026-06-21
> **Last Updated**: 2026-07-03

## Context

**GDD**: `design/gdd/player-abilities.md`,
`design/gdd/exploration-ability-gating.md`,
`design/gdd/audio-system.md`, `design/gdd/scene-management.md`

**Requirements**: `TR-ability-005`, `TR-audio-003`, `TR-scene-004`

**ADR Governing Implementation**: ADR-0002 Presentation events; ADR-0007
Scene management; ADR-0010 Audio architecture; ADR-0018 Player abilities;
ADR-0021 Save system.

Story071 makes the forward-pressure reward cache visible and claimable after the
counter-ambush. This story gives that payoff an immediate spatial audio
confirmation so the combat-to-reward loop is not only visual/textual. The slice
reuses the existing imported door-unlock confirmation cue and stays local to the
Story071 cache.

## Acceptance Criteria

- [x] `AudioSystem` exposes `on_reward_cache_claimed(...)` and routes the event
  `reward_cache_claimed -> sfx_door_unlock` with spatial position, priority
  `90`, `stream_found=true`, and metadata for `cache_id`, `source`,
  `gears/reward_gears`, `scene_id`, `feedback_role`, and `world_position`.
- [x] `FactoryLowerDeckForwardPressureRewardCache` first successful claim
  requests exactly one spatial audio event at the cache global position and
  records deterministic diagnostics:
  `claim_audio_requested`, `claim_audio_request_count`, and `claim_audio_event`.
- [x] A second claim attempt returns `false` and does not increment
  `claim_audio_request_count`.
- [x] Restoring `factory_lower_deck_forward_pressure_reward_cache_claimed=true`
  keeps the cache claimed/non-claimable and does not replay the audio event.
- [x] Missing or unsupported `/root/AudioSystem` does not block the reward claim;
  the scene records the intended local audio event before attempting the
  autoload call.
- [x] Existing Story071 reward behavior remains unchanged: `+20 Gears`, route
  feedback, scene-local claim persistence, no Story068-070 replay, and service
  lift prompt `Call lift`.
- [x] No new audio or visual assets are generated; the reused
  `sfx_door_unlock_baseline_short.wav` usage is recorded in asset documentation
  and QA evidence.
- [x] Focused/related GdUnit, headless smoke, and Godot MCP runtime checks pass
  under Godot 4.7 / Godot AI MCP 2.8.3.

## Out of Scope

New WAV assets, final mixing/mastering, global reward-cache audio policy,
economy tuning, SaveSystem schema changes, service-lift routing, minimap or
fast-travel changes, new enemies, new room art, particles/shaders, Boss2 reward
audio, and DEATH/CUTSCENE audio state work.

## Implementation Notes

- Use a semantically correct generic event id: `reward_cache_claimed`. Reuse the
  `sfx_door_unlock` asset, but do not reuse `savepoint_activated` semantics.
- Keep the audio request inside the fresh claim signal path, not in
  `set_local_state()`, cache visibility sync, diagnostics, or route-label
  refresh.
- Follow the Story064 pattern: scene-level request count + last event
  diagnostics, then optional `AudioSystem` forwarding.

## Asset Pipeline

No new asset generation is required. Reuse:

- `res://assets/audio/sfx/sfx_door_unlock_baseline_short.wav`
- `res://src/presentation/audio_system.gd`

Record the new usage in `design/assets/asset-manifest.md`,
`design/assets/entity-inventory.md`, and QA evidence.

## Test Evidence

- Focused GdUnit:
  `tests/unit/presentation/audio_system_test.gd`
- Focused gameplay:
  `tests/unit/gameplay/old_factory_forward_pressure_reward_cache_audio_test.gd`
- Related regression:
  Story072 focused + Story071, Story070, Story069, Story068, Story066,
  Story064 relay audio, and service-lift suites.
- Runtime evidence:
  Headless smoke and Godot MCP runtime checks must confirm scene load, cache
  visibility/claimability, `reward_cache_claimed -> sfx_door_unlock`,
  `stream_found=true`, once-only request count, restored no-replay, service lift
  prompt, clean logs, and a non-empty screenshot.

## Verification Summary

- RED focused: `reports/report_1113/` failed as expected because
  `AudioSystem.on_reward_cache_claimed` and Story072 claim-audio diagnostics did
  not exist.
- Focused GREEN: `reports/report_1114/report_2/` passed AudioSystem and
  Story072 gameplay suites `26/26`.
- Related GREEN: `reports/report_1115/report_1/` passed Story072, Story071,
  Story070, Story069, Story068, Story066, Story064 relay audio, and
  service-lift suites `42/42`.
- Headless Factory smoke:
  `reports/old_factory_forward_pressure_reward_cache_audio_smoke.log` exited
  `0` with no project script/parse/invalid-call/access/missing-resource/
  resource-load errors by keyword scan, aside from the known Godot cleanup-time
  resource message.
- Godot AI MCP `2.8.3` runtime evidence confirmed helper live, reward cache
  visible/claimable, first claim audio event `reward_cache_claimed ->
  sfx_door_unlock`, `stream_found=true`, duplicate claim no replay, restored
  claimed state no replay, service lift `Call lift`, clean logs, and non-empty
  screenshot metadata `960x539`. Game log contained only helper registration
  and editor log was empty.
- Full evidence:
  `production/qa/evidence/old-factory-forward-pressure-reward-cache-audio-feedback-2026-07-03.md`.

**Status**: [x] Complete.
