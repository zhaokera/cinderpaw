# QA Evidence: Old Factory Service Sluice Tailrace Relay Production Contact Respawn Runoff Handoff

**Story**: Player Abilities Story230

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify real-movement Story119 contact activation, exact relay checkpoint
selection, live player death/respawn and a guarded visible-but-idle Story120
handoff. Story120 hazard traversal and global slot-0 persistence are excluded.

## TDD Evidence

- `reports/report_2381/report_1/results.xml`: canonical RED, `1` case with
  three expected failures for stale prompt visibility, missing Story120 reveal
  and no-input runoff activation.
- `reports/report_2382/report_1/results.xml`: focused GREEN, `1/1`.
- `reports/report_2383/report_1/results.xml`: final bounded related GREEN,
  six suites and `8/8`; zero errors, failures, flaky, skipped or orphaned tests.
- Full suite was intentionally not run.

## Smoke Evidence

`tests/smoke/old_factory_service_sluice_tailrace_relay_smoke.gd` now starts
outside the relay, uses real `move_right` contact, validates the one-shot
checkpoint/VFX and prompt removal, applies real lethal player damage, verifies
three-frame `death`/`revive`, 50% HP restoration and the Story120 no-input
guard, then runs 180 additional frames. It exited `0` and printed
`story119_production_smoke=passed frames=180`.

## MCP Runtime Evidence

Session `cinderpaw@198e`; accepted run `r190526212-29`, token `29`.

- Session metadata reported Godot `4.7-stable`, plugin `3.0.4` and server
  `3.0.4`; forced disk reload of the Factory scene succeeded and run start
  reported `current_run_errors=[]`.
- Waiting diagnostics placed Cinderpaw outside the relay at x `13304` while
  the relay at x `13480` was visible, available, monitoring, unactivated and
  showed `Repair Tailrace Relay`; Story120 was unavailable and hidden.
- Real MCP `move_right` advanced Cinderpaw `191.652px`. Relay diagnostics then
  recorded activated true, prompt hidden, contact/collision disabled, VFX
  spawn count `1`, `Tailrace Relay Secured` and the exact scene/spawn payload.
- Story120 became visible/available but stayed `idle`, inactive, uncrossed and
  non-contacting. With all input released, placement at x `13764`, four pixels
  beyond activation x, still left it idle.
- Real lethal `apply_damage(100)` produced HP `0`, player animation `death`,
  flow `dying` and locked control. The completed same-scene transition selected
  the exact relay spawn, restored `50/100` HP, displayed
  `Returned to Tailrace Relay`, and kept Story120 idle/non-contacting. Focused
  automation separately captures the transient `revive` animation and control
  lock before the transition settles back to `playing`.
- All driven inputs were false at acceptance. Current game log contained only
  helper registration; editor delta after baseline cursor `2` was empty.
  Playback stopped with editor readiness `ready`.

## Visual Evidence

- Relay secured: non-empty RGB `1278x718`, SHA-256
  `4c95cf60e76e95bd1f40ebd21b24a0edf117bfc794176a8a8f8567bcd8eb74bb`,
  `reports/visual/cinderpaw-mcp-story230-tailrace-relay-activated-20260722.png`.
- Post-respawn return: non-empty RGB `1278x718`, SHA-256
  `cf29c24f36518118f713ba657b4fe87ccaa3ae674ac298bf96aeae70cfd74105`,
  `reports/visual/cinderpaw-mcp-story230-tailrace-relay-revive-20260722.png`.

Both captures show Cinderpaw at the authored relay beside the revealed runoff
machinery, with clear route feedback and no placeholder blocks.

## Asset Review

Existing imported image-generated Factory, Cinderpaw, relay, runoff and VFX
assets fully cover this slice. No image generation or asset-manifest change
was required.

## QA Result

Accepted. Story119 now closes through production contact and respawn while
leaving Story120 as a deliberate next input beat.
