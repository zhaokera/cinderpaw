# QA Evidence: Old Factory Forward Pressure Reward Cache Audio Feedback

Date: 2026-07-03
Engine: Godot 4.7
MCP: Godot AI 2.8.3
Story: `production/epics/player-abilities/story-072-old-factory-lower-deck-forward-pressure-reward-cache-audio-feedback.md`

## Scope

Story072 adds once-only spatial audio feedback to the Story071 forward-pressure
reward cache claim. The first successful claim routes
`reward_cache_claimed -> sfx_door_unlock`; duplicate claims and restored claimed
state do not replay the sound.

## Asset Pipeline

No new visual or audio assets were generated for this story.

- SFX reuse:
  `res://assets/audio/sfx/sfx_door_unlock_baseline_short.wav`.
- Runtime routes:
  `AudioSystem.on_reward_cache_claimed(...)` and
  `OldFactoryEntranceScene._request_lower_deck_forward_pressure_reward_cache_claim_audio(...)`.

The reused cue is recorded in `design/assets/asset-manifest.md` and
`design/assets/entity-inventory.md`.

## Automated Verification

- RED focused: `reports/report_1113/` failed as expected before
  `on_reward_cache_claimed` and Story072 claim-audio diagnostics existed.
- Focused GREEN: `reports/report_1114/report_2/` passed AudioSystem and
  Story072 gameplay suites `26/26` with no errors, failures, skips, flaky
  cases, or orphans.
- Related regression: `reports/report_1115/report_1/` passed Story072,
  Story071, Story070, Story069, Story068, Story066, Story064 relay audio, and
  service-lift suites `42/42`.
- Headless scene smoke:
  `reports/old_factory_forward_pressure_reward_cache_audio_smoke.log` exited
  `0`. Keyword scan found no project script, parse, invalid-call,
  invalid-access, missing-resource, or resource-load errors, aside from the
  known Godot cleanup-time resource message.

## MCP Runtime Verification

Godot AI MCP `2.8.3` on Godot `4.7-stable` launched
`res://scenes/factory_route_transition_shell.tscn` with `autosave=false` and
confirmed helper live.

- Runtime scene tree contains `FactoryLowerDeckForwardPressureRewardCache`.
- Injecting Story070 defeated + cache unclaimed state made the cache visible and
  claimable.
- First claim returned `true`, kept Story071 reward payload `+20 Gears`, and
  recorded `claim_audio_request_count=1`.
- The audio event was `reward_cache_claimed -> sfx_door_unlock`, with
  `stream_found=true`, cache id
  `old_factory_lower_deck_forward_pressure_reward_cache`, `reward_gears=20`,
  `feedback_role=reward_cache_claim`, and world position at the cache.
- Second claim returned `false` and did not increment audio request count.
- Restored claimed state kept the cache non-claimable and did not replay audio.
- Service lift stayed optional with prompt `Call lift`.
- Game log contained only the helper registration line; editor log was empty.
- MCP game screenshot metadata was non-empty at `960x539` and showed the target
  Factory route state.
