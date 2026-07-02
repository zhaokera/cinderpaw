# QA Evidence: Old Factory Lower Deck Relay Forward Reward Hatch

Date: 2026-07-02
Engine: Godot 4.7-stable
MCP: Godot AI 2.8.3

## Story

`production/epics/player-abilities/story-066-old-factory-lower-deck-relay-forward-reward-hatch.md`

## Scope

Story066 adds a relay-forward payoff after Story065:

- `FactoryLowerDeckRelayForwardRewardCache`
- `FactoryLowerDeckForwardHatch`
- scene-local flags:
  - `factory_lower_deck_relay_forward_reward_cache_claimed`
  - `factory_lower_deck_forward_hatch_opened`

No new visual or audio assets were generated. The story reuses imported
image-generated lower-deck cache and deep bulkhead art.

## Automated Tests

- RED focused: `reports/report_1089/`
  - Expected failure before Story066 APIs and scene nodes existed.
- Focused GREEN: `reports/report_1090/`
  - `2/2` passed.
- Related regression: `reports/report_1091/`
  - `18/18` passed across Story066, Story065 post-relay trial, breach relay,
    lower-deck cache regressions, deep bulkhead, and service-lift exit.
- Story015 stale editor-row isolation: `reports/report_1092/`
  - `5/5` passed, confirming current files parse despite stale editor Debugger
    rows.

## Headless Smoke

Command wrote `reports/old_factory_lower_deck_relay_forward_reward_hatch_smoke.log`.

Result:

- Exit code `0`.
- Keyword scan found no project script, parse, invalid-call, invalid-access,
  missing-resource, or resource-load errors.
- Godot emitted only exit-time cleanup noise:
  `ERROR: 2 resources still in use at exit`.

## MCP Runtime Evidence

Godot MCP launched `res://scenes/factory_route_transition_shell.tscn` with
`autosave=false`.

Confirmed:

- `helper_live=true`, `game_capture_ready=true`.
- Runtime scene tree contains:
  - `FactoryLowerDeckRelayForwardRewardCache`
  - `FactoryLowerDeckForwardHatch`
- Reward cache runtime properties:
  - script `res://src/feature/factory_combat_cache.gd`
  - `cache_id=old_factory_lower_deck_relay_forward_cache`
  - `reward_source=old_factory_lower_deck_relay_forward_cache`
  - `reward_gears=20`
  - `available_prompt_text=+20 Gears`
- Forward hatch runtime properties:
  - script `res://src/feature/factory_deep_route_endpoint.gd`
  - `endpoint_id=old_factory_lower_deck_forward_hatch`
  - `available_prompt_text=Open forward hatch`
  - `locked_prompt_text=Claim relay cache`
  - unlock VFX texture loaded from Old Factory unlock spark asset.
- Runtime eval drove the Story066 interaction path:
  - cache visible after post-relay trial state
  - route label after hatch open: `Lower Deck Forward Hatch Opened`
  - service lift prompt stayed `Call lift`
  - relay audio and VFX replay counts stayed `0`
- Game log for the run contained only the Godot AI helper registration line.
- Game framebuffer screenshot metadata: `960x539`, source `game`, non-empty.

## Notes

The editor Debugger still displayed stale Story015 `CombatComponent` parse rows
with old line mappings. The fresh Story015 CLI run in `reports/report_1092/`
passed, so no current parse failure is reproduced.
