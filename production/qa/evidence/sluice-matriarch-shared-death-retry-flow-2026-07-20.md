# QA Evidence: Sluice Matriarch Shared Death and Retry Flow -- 2026-07-20

## Scope

Player Abilities Story180 replaces Boss3's immediate full-HP local reset with
the project's shared `GameFlowController` contract. The change covers the GDD
death hold, Boss-entry selection, 50% revive, two-second protection, Boss arena
snapshot reset and existing death/revive presentation. Boss balance, rewards,
persistence and route behavior remain unchanged.

## TDD Evidence

- Intentional RED `reports/report_2054/results.xml`: one Story180 test ran and
  produced two expected failures because the Boss3 arena did not expose shared
  retry diagnostics or deterministic flow advancement.
- `reports/report_2055/results.xml` was an intermediate mismatch, not accepted
  GREEN: the shared runtime contract worked, but two assertions still used
  presentation phase names that did not match the existing
  `death_fade_in/revive_fade_out` implementation.
- Focused GREEN `reports/report_2058/results.xml`: the Story180 suite passed
  `1/1`, with zero failures, errors, flaky cases, skips or orphans and exit code
  `0`.
- Post-upgrade focused verification `reports/report_2060/results.xml`: the same
  suite passed `1/1`, with zero failures, errors, flaky cases, skips or orphans
  and exit code `0` after upgrading the project-local MCP plugin/server to
  `3.0.4`.
- Related GREEN `reports/report_2059/results.xml`: five suites passed `14/14`,
  with zero failures, errors, flaky cases, skips or orphans and exit code `0`:
  `sluice_matriarch_shared_death_retry_flow_test.gd`,
  `sluice_matriarch_playable_boss3_core_test.gd`,
  `game_flow_controller_test.gd`, `player_respawn_visual_feedback_test.gd`, and
  `old_factory_tailrace_sluice_matriarch_arena_handoff_test.gd`.
- Godot 4.7 loaded `sluice_matriarch_arena.tscn` headlessly for `180` frames and
  exited `0`. Only normal shutdown cleanup diagnostics appeared; no parse,
  script, invalid-call or missing-resource error occurred.
- No full suite was run; the changed surface is one Boss3 arena integration of
  already-covered shared death/retry behavior.

## Runtime Contract

- Player death enters shared `dying` state, clears the Boss target, locks player
  control and routes the existing CombatPresentation grayscale/death-wisp path.
- At `1.49s`, Cinderpaw remains at the death position with `0/100` HP and the
  `death` animation. The active Sluice Matriarch remains at `59/120`, Phase II,
  pressure lunge active and hitbox enabled.
- Crossing `1.5s` restores the encounter snapshot before player revive. The
  Boss returns to `120/120`, Phase I, `(930, 540)`, idle, with no active attack
  hitbox.
- Cinderpaw respawns at exact `boss_entry` `(260, 540)`, with `50/100` HP,
  `revive`, one golden halo, `120` i-frame ticks and `2.0s` shared protection.
- At `0.01s` protection remaining, damage is rejected and HP stays `50`. After
  expiry, flow is `playing`, control is unlocked, protection is `0`, and a
  `10`-damage probe reduces HP to `40`.
- Room seals and SceneManager lock remain owned. Reward and Factory return route
  remain unavailable throughout retry.

## Godot MCP Runtime Evidence

- Session `cinderpaw@36ea`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.4`; accepted run `r4500195-2` (run token `2`).
- Runtime scene inspection found `GameFlowController`, Cinderpaw and Sluice
  Matriarch in the disk-loaded custom scene. Player and Boss sprites remained
  `AnimatedSprite2D`; the runtime root contained `17` scene children and `49`
  nodes in the bounded hierarchy query.
- Deterministic runtime probes confirmed an active Phase II pressure lunge
  (`59/120`, active hitbox), the exact `1.49s/1.50s` death boundary, Boss-entry
  respawn with zero position error, `50/100` HP, one revive halo, full Boss
  snapshot restoration and the exact protection expiry behavior above.
- The accepted run's game log contains only the Godot AI game-helper
  registration line. Editor logs contain zero rows. Stopping the run returned
  `readiness_after=ready`.
- A discarded diagnostic run `r4166121-1` was stopped after a temporary MCP
  eval probe mixed tabs and spaces and parked that run at a debugger parse
  break. The probe syntax was isolated with a minimal eval, corrected to tabs,
  and the entire runtime acceptance was repeated in the clean run above. No
  project file used the invalid probe code and no evidence from that run is
  accepted.
- Accepted screenshot:
  `reports/visual/cinderpaw-mcp-sluice-matriarch-shared-revive-protection-20260720.png`.
  It is a non-empty opaque RGB `1278x718` PNG showing Cinderpaw at `50/100` with
  the golden revive ring, sealed arena and Sluice Matriarch Phase I `120/120`.
  SHA-256:
  `eb5d20cf047eba2dd9fb5738411186e106a2f1267d6bb489b47ecc246cfb9d47`.

## Asset Use

- No new asset was needed. Story180 reuses Cinderpaw's existing multi-frame
  `death` and `revive` SpriteFrames, Sluice Matriarch's authored frames, and the
  shared CombatPresentation grayscale, death-wisp and revive-halo effects.
- The next pressure-valve presentation Story remains responsible for its own
  image-generation source, prompt, alpha processing, asset spec and manifest
  traceability.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Shared GameFlow and Boss-entry snapshot are mounted | Focused/related GREEN; MCP runtime tree | PASS |
| Death holds through 1.49s with existing presentation | Story180 test; MCP boundary probe | PASS |
| 50% Boss-entry revive and Boss reset occur at 1.5s | Story180 test; MCP state and screenshot | PASS |
| Two-second protection rejects damage then expires | Story180 test; MCP boundary probes | PASS |
| Seals remain and reward/return stay unavailable | Focused GREEN; MCP diagnostics | PASS |
| Godot 4.7 / MCP 3.0.4 visible runtime is clean | Run `r4500195-2`; logs; screenshot | PASS |
