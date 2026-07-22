# QA Evidence: Old Factory Runoff Exit Gate Production Input Outlet Handoff

**Story**: Player Abilities Story222

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify Story109's stale-input-safe production gate opening and readable lifted
state, Story110's real-movement hazard cycle and physical steam contact, then
cross into an available but inactive Story111 handoff that stays stable on
later stationary frames.

## TDD Evidence

- `reports/report_2344/results.xml`: canonical RED, `0/1`, ten expected
  failures across production input, gate presentation, movement, hazard and
  handoff.
- `reports/report_2345/results.xml`: initial focused GREEN, `1/1`.
- `reports/report_2348/results.xml`: boundary RED, `0/1`, two expected failures
  exposing stationary Story111 auto-activation after crossing.
- `reports/report_2349/results.xml`: final focused GREEN, `1/1`.
- `reports/report_2350/results.xml`: final seven-suite related GREEN, `11/11`,
  zero failure/error/flaky/skip/orphan.
- Full suite was intentionally not run.

The canonical test uses real `Input.interact` and `Input.move_right`. Direct
positioning only establishes deterministic boundaries; activation and crossing
still flow through Factory production `_process(delta)`. Damage uses the
connected outlet vent and normal hazard contact route.

## Smoke Evidence

`reports/old_factory_runoff_exit_gate_production_input_outlet_handoff_smoke.log`
completed `180` fixed-FPS Factory frames and exited `0`. Its targeted scan found
no parse/script, invalid-call/access, missing-resource, ObjectDB leak or
resource-in-use error.

## MCP Runtime Evidence

Accepted session: `cinderpaw@198e`; accepted run token/id:
`9` / `r165369444-9`.

- Held `interact` started outside the gate range and remained stale after
  entering range. Release/rearm plus fresh `interact` opened the gate once,
  disabled collision, hid the prompt and recorded unlock VFX spawn count `1`.
- The open visual was `(48,-136)`, `6deg`, effective z `23`; duct/player z were
  `22/26`. Story110 was available/visible but idle.
- No-input x `8484` stayed idle. Actual `move_right` advanced x
  `8475.334 -> 8482` and started Story110 in `grace`.
- Production time reached `warning`, `active` and `safe`. Physical active-phase
  contact changed HP `100 -> 92`; the last hazard record contained `8` damage
  and the exact Story110 source id.
- Actual `move_right` advanced x `9055.334 -> 9060.223`, persisted crossed and
  left Story111 available but inactive/hidden/non-processing/non-physical and
  untargeted.
- Inputs were released. A no-input x `9284` placement plus two later production
  frames kept Story111 in the same inactive state. Its six gameplay animations
  each reported three frames.
- Current-run game log contained only helper registration. Editor log after
  retained cursor `2` was empty. Playback stopped at readiness `ready`.
- A preliminary run was discarded because `move_right` remained held while
  real time advanced between MCP calls. The accepted run executed each
  press/wait/release sequence atomically; only token `9` is acceptance evidence.
- The two retained editor entries before cursor `2` belong to an older malformed
  screenshot import and predate this run; the accepted-run delta is empty.

## Visual Evidence

- Open gate, RGB `1278x718`:
  `reports/visual/cinderpaw-mcp-runoff-exit-gate-open-20260722.png`,
  SHA-256 `89c3346d72fabaae9ecae96588655a96e63a72d2a17975e465334d0752531c95`.
- Active outlet steam, RGB `1278x718`:
  `reports/visual/cinderpaw-mcp-runoff-outlet-active-20260722.png`,
  SHA-256 `27b16a5140e2f3fc3a8341e2c636dae823a662ca1ae72f5e832582a78e078317`.
- Crossed Story111 handoff, RGB `1278x718`:
  `reports/visual/cinderpaw-mcp-runoff-outlet-crossed-handoff-20260722.png`,
  SHA-256 `b2350aed5c747475fb95fa16d3dc14f2bb00f6e1a2483fff10236f3a3bc2d207`.

All captures are non-empty, show Cinderpaw and authored Factory art, and expose
the expected objective text without player-visible rectangle placeholders.

## Asset Review

No new image generation was needed. Existing registered/imported
image-generated gate, cooling duct, steam vent, Cinderpaw and Spark Rat
frame-animation assets cover the complete slice.
