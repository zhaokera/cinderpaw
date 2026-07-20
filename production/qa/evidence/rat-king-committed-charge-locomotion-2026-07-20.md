# QA Evidence: Rat King Committed Charge Locomotion -- 2026-07-20

## Scope

Player Abilities Story178 turns Rat King's existing `charge` attack into a real
committed gap closer. It adds only data-driven acquisition and active-frame
locomotion; authored damage, hitbox, timing, phases, rewards and image-generated
SpriteFrames are unchanged.

## TDD Evidence

- Intentional RED `reports/report_2047/results.xml`: `1` test ran with `4`
  expected failures. At the Main opening distance the Boss selected no attack,
  advanced `0px`, retained `0` horizontal velocity and exposed no locomotion
  diagnostics. The existing charge hitbox still activated, isolating the defect
  to acquisition and motion.
- Focused GREEN `reports/report_2048/results.xml`: Story178 passed `1/1`, with
  zero failures, errors or orphans.
- Related GREEN `reports/report_2049/results.xml`: four Rat King suites passed
  `15/15`, with zero failures, errors, flaky cases, skips or orphans:
  `rat_king_committed_charge_locomotion_test.gd`,
  `rat_king_boss_runtime_contract_test.gd`,
  `rat_king_specialized_attack_animation_test.gd`, and
  `rat_king_phase_one_runtime_intro_test.gd`.
- Fresh pre-push gate `reports/report_2050/results.xml` repeated those four
  suites at `15/15`, with zero failures, errors, flaky cases, skips or orphans
  and exit code `0`.
- A Godot 4.7 Main headless smoke ran `180` frames and exited `0`. Startup and
  gameplay logs contained only DataManager/MCP info. Godot reported two leaked
  ObjectDB instances and one retained resource during shutdown cleanup; no
  parse, script, invalid call/access or missing-resource error was emitted.
- No full suite was run; the changed surface is one Boss attack pattern and its
  data entry.

## Runtime Contract

- `charge` keeps `20/8/24` startup/active/recovery frames, `14` physical damage
  and the existing `116x54` `rat_king_charge` hitbox.
- Data adds `lunge_speed=720` and `attack_range_px=320`.
- The default `260px` horizontal opening is eligible; targets at `110px` or less
  remain on normal close-range pattern selection.
- Facing is captured at startup. Active motion does not track a target that
  crosses behind the Boss.
- An unobstructed active window can travel `96px` at 60 Hz. Horizontal collision
  ends movement while attack timing and hitbox ownership remain with AIComponent.
- Death, respawn restore, progress defeat and phase transition clear motion.

## Godot MCP Runtime Evidence

- Session `cinderpaw@af5f`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.2`; accepted run `r367146508-130` (token `130`).
- Natural Main runtime moved Rat King from the authored `x=560` opening toward
  Cinderpaw at `x=300` through repeated charge attacks, then transitioned to
  close-range attacks. Unattended player damage confirmed the production attack
  chain remained live.
- A deterministic runtime probe restored player/boss HP and positions, paused
  automatic physics, requested `charge`, advanced the existing startup and two
  active calls, and observed:
  - Boss `x=560 -> 548.0005`, approximately `12px` committed left motion.
  - `pattern=charge`, `phase=active`, `animation=charge`.
  - `rat_king_charge` hitbox active and player HP still `100` at probe spacing.
  - config loaded from data, `speed=720`, `range=320`, locked direction `-1`,
    measured distance approximately `12px`, velocity `-720`, not blocked.
- The accepted screenshot is opaque RGB `1278x718`, non-empty, and visibly
  contains Cinderpaw, Rat King in its charge pose, Boss HUD and intact arena UI:
  `reports/visual/cinderpaw-mcp-rat-king-committed-charge-locomotion-20260720.png`.
- Accepted game logs contained only MCP helper and DataManager info lines;
  editor logs had zero rows. Stopping the run restored editor readiness.

## Discarded Probe

- Run token `129` used an invalid eval-only typed inference expression, causing
  a temporary parser warning in the MCP probe itself. It did not reference or
  modify project source. The run was stopped, logs were cleared, and accepted
  run `130` repeated the bounded checks with clean logs.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Default Main spacing starts charge | RED/GREEN; natural MCP runtime | PASS |
| Startup locks direction and active frames move | Focused/related GREEN; MCP probe | PASS |
| Existing hitbox, animation and damage chain remain active | Related GREEN; MCP diagnostics | PASS |
| Reset paths clear motion | Source contract; related Boss regression | PASS |
| Godot 4.7 scene is visible and logs are clean | MCP run `130`; saved screenshot | PASS |
