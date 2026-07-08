# QA Evidence: Old Factory Forward Pressure Aftershock Exit Skirmish

Date: 2026-07-09
Story: `production/epics/player-abilities/story-085-old-factory-lower-deck-forward-pressure-aftershock-exit-skirmish.md`
Engine: Godot 4.7
Godot AI MCP: 2.9.1

## Scope

Story085 adds a Story084-gated Spark Rat + Coil Rat exit skirmish after the
forward-pressure aftershock reward cache. The slice reuses existing imported,
image-generated character animation assets; no new visual or audio assets were
generated.

## Asset Evidence

- Spark Rat: `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- Coil Rat: `res://assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`
- Both enemies use `AnimatedSprite2D + SpriteFrames` with `idle`, `run`,
  `attack_tell`, `attack`, `hurt`, and `death`, each with 3 frames.
- Usage is recorded in `design/assets/asset-manifest.md`,
  `design/assets/entity-inventory.md`, and the Story085 file.

## Automated Verification

- RED focused: `reports/report_1181/` failed as expected before Story085 scene
  APIs existed.
- Transient implementation failure: `reports/report_1182/` caught a parse issue
  during implementation; it was fixed before acceptance.
- Focused GREEN: `reports/report_1183/` passed `3/3`.
- Final pre-commit focused rerun: `reports/report_1186/` passed `3/3`.
- Related GREEN: `reports/report_1184/` passed `20/20`.
- Expanded related GREEN: `reports/report_1185/` passed `36/36`.
- Headless smoke:
  `reports/old_factory_forward_pressure_aftershock_exit_skirmish_smoke.log`
  exited `0`; project error keyword scan found no script, parse, invalid-call,
  invalid-access, missing-resource, or resource-load errors.

## MCP Runtime Verification

Godot MCP launched `res://scenes/factory_route_transition_shell.tscn` with the
game helper live. Runtime probes confirmed:

- locked state keeps both Story085 enemies hidden/inactive and rejects manual
  activation before the Story084 cache claim;
- active state after cache claim and x `2288.0` exposes entity `2129` as
  `factory_spark_rat` and entity `2130` as `factory_coil_rat`;
- both enemies are visible, targeted at the player, processing, and physics
  enabled;
- SpriteFrames paths and `idle/run/attack_tell/attack/hurt/death` frame counts
  match the frame-animation rule;
- opening grace pacing is Spark `12` / Coil `24`;
- route feedback is `Break Aftershock Exit Skirmish` while active;
- partial defeat keeps the remaining enemy active; full defeat persists all
  Story085 clear flags and advances feedback to
  `Forward Pressure Aftershock Exit Skirmish Cleared`;
- restored completed state preserves Story084 cache claimed, Story083/082/081
  continuity, Story074 exit-relay savepoint contract, Story068 clear-burst
  no-replay, Story071 reward-cache audio no-replay, and `FactoryServiceLift`
  prompt `Call lift`;
- final MCP screenshot captured a non-empty `960x539` game frame with the
  active skirmish visible;
- final game log contained only the MCP helper registration line, and final
  editor log was empty after clearing one eval-probe warning unrelated to
  project files.

## Result

PASS. Story085 meets its acceptance criteria with focused, related, headless,
and MCP runtime evidence.
