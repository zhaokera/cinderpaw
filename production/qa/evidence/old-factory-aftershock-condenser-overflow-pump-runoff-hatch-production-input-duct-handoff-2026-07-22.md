# QA Evidence: Old Factory Aftershock Condenser Overflow Pump Runoff Hatch Production Input Duct Handoff

**Story**: Player Abilities Story220

**Date**: 2026-07-22

**Status**: Accepted

**Engine / MCP**: Godot 4.7 / Godot AI MCP 3.0.4

## Scope

Verify Story106's production hatch-open input and readable silhouette,
Story107's movement-gated production hazard cycle and physical contact, then
cross into an available but inactive Story108 handoff.

## TDD Evidence

- `reports/report_2335/results.xml`: canonical RED, `0/1`, `23` expected
  failures across production input, visual state, timing and handoff.
- `reports/report_2337/results.xml`: focused GREEN, `1/1`.
- `reports/report_2340/results.xml`: completion spot-check, `1/1`, zero
  error/failure/flaky/skip/orphan.
- `reports/report_2339/results.xml`: final nine-suite related GREEN, `13/13`,
  zero failure/error/flaky/skip/orphan.
- Full suite was intentionally not run.

The integrated test uses real `Input.interact` and `Input.move_right`. Direct
positioning only frames deterministic boundaries; activation and completion
still flow through Factory production `_process(delta)`. Contact uses the
connected runoff vent and established damage route.

## Smoke Evidence

`reports/old_factory_aftershock_condenser_overflow_pump_runoff_hatch_production_input_duct_handoff_smoke.log`
completed `180` fixed-FPS Factory frames and exited `0`. Its targeted scan found
no parse/script, invalid-call/access, missing-resource, ObjectDB leak or
resource-in-use error.

## MCP Runtime Evidence

Accepted session: `cinderpaw@198e`; accepted final run: `r161548718-2`.

- A held `interact` remained stale after real movement entered hatch range.
  Release/rearm plus fresh `interact` opened once, removed collision, hid the
  prompt, moved/rotated the visual and recorded unlock VFX spawn count `1`.
- The open visual was `(48,-136)`, `6deg`, effective z `23`; duct/player z were
  `22/26`. Story107 was available/visible but idle.
- No-input x `7164` stayed idle. Real `move_right` advanced x
  `7154 -> 7195.33` and started the duct in `grace`.
- Controlled production time reached `warning`, `active` and `safe`. Physical
  active-phase overlap changed HP `100 -> 92`; the last hazard record contained
  steam type, `8` damage and the exact Story107 source id. Safe disabled
  contact.
- Real `move_right` advanced x `7554 -> 7586.33`, persisted crossed and left
  Story108 available but inactive/hidden/non-processing/non-physical.
- Final game log contained only helper registration; editor log after cursor
  `2` was empty. Inputs were released and playback stopped at readiness
  `ready`.
- A preliminary run was deliberately discarded and restarted after the MCP
  eval queried `get_overlapping_bodies()` while monitoring was disabled. The
  resulting diagnostic pointed only to generated eval code, not project code.

## Visual Evidence

- Open hatch, RGB `1278x718`:
  `reports/visual/cinderpaw-mcp-overflow-pump-runoff-hatch-production-input-open-20260722.png`,
  SHA-256 `59c9638125faa5b7560e7feac1d5218e7c5a6f8af3ddcfa258b1a95eeeda9c1a`.
- Active steam, RGB `1278x718`:
  `reports/visual/cinderpaw-mcp-overflow-pump-runoff-duct-production-hazard-active-20260722.png`,
  SHA-256 `3003ab9f5e3ce72808605490e4eea85139327466ac16f2b92b0f9e86c4fd7c1d`.
- Crossed handoff, RGB `1278x718`:
  `reports/visual/cinderpaw-mcp-overflow-pump-runoff-duct-production-handoff-crossed-20260722.png`,
  SHA-256 `8b303aee4ba7dada2e127bf8e9f37acf2c0ac933eeac524a548758084b699540`.

All captures are non-empty, show Cinderpaw and authored Factory art, and expose
the expected objective text without player-visible rectangle placeholders.

## Asset Review

No new image generation was needed. Existing registered/imported
image-generated hatch, cooling duct, steam vent, Cinderpaw and Factory assets
fully cover this production slice.
