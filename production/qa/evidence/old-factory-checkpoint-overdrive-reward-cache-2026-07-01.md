# QA Evidence: Old Factory Checkpoint Overdrive Reward Cache

> **Story**: Player Abilities Story 051
> **Engine**: Godot 4.7
> **Date**: 2026-07-01

## Scope

Story051 adds a generated, scene-local reward cache after the Old Factory
checkpoint overdrive duo is cleared. The cache is optional payoff: it does not
block the service lift, does not add SaveSystem schema fields, and does not
connect to a global economy total.

## Asset Pipeline

- Source image:
  `assets/generated/source/old_factory_checkpoint_overdrive_reward_cache_imagegen_20260701.png`.
- Alpha image:
  `assets/generated/source/old_factory_checkpoint_overdrive_reward_cache_alpha_20260701.png`.
- Metadata:
  `assets/generated/source/old_factory_checkpoint_overdrive_reward_cache_imagegen_20260701.json`.
- Runtime PNG:
  `assets/environment/old_factory_checkpoint_overdrive_reward_cache/env_old_factory_checkpoint_overdrive_reward_cache_claimable_256.png`.
- Godot import:
  `assets/environment/old_factory_checkpoint_overdrive_reward_cache/env_old_factory_checkpoint_overdrive_reward_cache_claimable_256.png.import`.
- Validation: runtime PNG is `256x256` RGBA with transparent corner alpha
  `[0, 0, 0, 0]`; alpha bounding box is `[25, 18, 231, 237]`.
- Import settings: `compress/mode=0`, `mipmaps/generate=false`,
  `process/fix_alpha_border=true`, `process/premult_alpha=false`, and channel
  remap `0/1/2/3`.

## Automated Verification

- Focused RED: `reports/report_1022/` failed because
  `get_factory_checkpoint_overdrive_reward_cache_diagnostics()` and
  `try_claim_factory_checkpoint_overdrive_reward_cache()` did not exist.
- Import refinement: `reports/report_1023/` failed because the runtime PNG had
  not yet been imported as a Godot `Texture2D`.
- Focused GREEN: `reports/report_1024/` passed `2/2`, `0` errors, failures,
  flaky tests, skips, or orphans.
- Related regression: `reports/report_1025/` passed `16/16`, covering Story051,
  checkpoint overdrive duo, cache claim feedback, return-patrol reward cache,
  service-lift handoff/SceneManager exit, and Factory route roundtrip.
- Headless smoke:
  `reports/old_factory_checkpoint_overdrive_reward_cache_smoke.log` exited `0`;
  keyword scan found no project script, parse, invalid-call, invalid-access,
  missing-resource, or resource-load errors in the log file. Godot printed known
  cleanup-time ObjectDB/resource-at-exit noise to terminal after exit.

## Godot MCP Runtime

MCP session `cinderpaw@6787` connected to Godot `4.7-stable (official)` with
Godot AI plugin/server `2.8.1`. `project_run` launched
`res://scenes/factory_route_transition_shell.tscn` with `autosave=false`; the
startup response included retained editor parse rows marked
`recent_errors_may_predate_run=true`, so logs were cleared and current runtime
evidence was gathered through `game_eval`.

Runtime eval confirmed:

- `FactoryCheckpointOverdriveRewardCache` exists.
- `Visual.texture.resource_path` is
  `res://assets/environment/old_factory_checkpoint_overdrive_reward_cache/env_old_factory_checkpoint_overdrive_reward_cache_claimable_256.png`.
- Locked state: `available=false`, `claim_available=false`, `claimed=false`,
  `prompt_text="Clear overdrive duo"`, and direct claim returns `false`.
- Cleared state: `available=true`, `claim_available=true`,
  `prompt_text="+25 Gears"`, and `overdrive_duo_cleared=true`.
- Claim state: first claim returns `true`, duplicate claim returns `false`,
  `last_reward.cache_id/source="old_factory_checkpoint_overdrive_cache"`,
  `last_reward.gears=25`, and `last_claim_feedback.text` is
  `Overdrive Cache Claimed +25 Gears`.
- Route label after claim is `Overdrive Cache Claimed +25 Gears`.
- Service lift remains available after reward claim with prompt `Call lift`.
- `get_local_state()` persists
  `factory_checkpoint_overdrive_reward_cache_claimed=true`,
  `last_checkpoint_overdrive_reward_cache_reward`, and
  `last_checkpoint_overdrive_reward_cache_claim_feedback`.
- Game screenshot metadata: `640x359` from original `1278x718`.
- Post-clear MCP log read contained only plugin info rows, with no current
  error or warning rows.

## Verdict

PASS. Story051 meets acceptance criteria and preserves Story049/050 service-lift
and overdrive-duo behavior while adding a player-visible reward payoff.
