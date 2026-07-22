# QA Evidence: Old Factory Aftershock Exhaust Production Traverse Pursuer Handoff -- 2026-07-21

## Scope

Player Abilities Story206 completes Story086 through the production Factory
process loop and hands off safely to Story087. It covers real movement entry,
timed phase progression, active-only physical overlap damage, real movement
completion and inactive pursuer collision safety. No new asset, economy rule,
save schema or room was introduced.

## TDD And Regression Evidence

- `reports/report_2238/report_1/results.xml`: canonical RED, `0/1`, fifteen
  expected failures and zero errors. It demonstrated that production did not
  advance the phase, apply active damage, complete at x `2480`, or disable the
  inactive Story087 hurtbox.
- `reports/report_2239/report_1/results.xml`: focused GREEN, `1/1`.
- `reports/report_2240/report_1/results.xml`: first four-suite bounded run. Its
  only regression was the old Story087 expectation that a live defeated enemy
  became hidden immediately.
- `reports/report_2241/report_1/results.xml`: excluded intermediate parse-error
  run caused by placing new assertions in the wrong test scope. The test was
  corrected before any further feature work.
- `reports/report_2242/report_1/results.xml`: focused Story087 GREEN, `2/2`,
  covering visible live death and hidden restored completion separately.
- `reports/report_2244/results.xml`: fresh final bounded related GREEN, four
  suites and `7/7`, zero failure/error/flaky/skip/orphan. Coverage includes
  Story206, Story086, Story205 and Story087.
- Factory `180`-frame headless smoke exited `0`; log:
  `reports/old_factory_aftershock_exhaust_production_traverse_pursuer_handoff_smoke.log`.
  No project script, parse, invalid-call or resource-load error was found. The
  `4 ObjectDB / 2 resources` shutdown diagnostic matches the established
  Factory baseline.
- No full suite was run; verification stayed bounded to the changed path.

## Production Contract

- Story086 only becomes active after a fresh positive player movement across x
  `2416`; availability alone cannot start it.
- The regular Factory `_process(delta)` calls the existing deterministic
  Story086 advance and completion APIs, so gameplay reaches warning, active,
  safe and crossed without test-only orchestration.
- Hazard contact is disabled in grace, warning and safe. Active uses the shared
  `FactorySteamVentHazard` physical overlap path, damage `8`, and source id
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust`.
- Crossing x `2480` hides/disables the vent and stops `SteamAnimation`.
- Story087 then becomes available only. Until x `2552`, entity `2131` retains
  `24 HP` while visual, process, physics, target and hurtbox stay inactive.
- Live Story087 defeat may finish its three-frame `death` animation while all
  combat surfaces are disabled; restored completed state stays hidden.

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.4`.
- Accepted run `r133380254-57` (`run token 57`) launched
  `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`.
- Restored Story085 clear made Story086 available/inactive at player x `2412`,
  HP `100`; Story087 was hidden with hurtbox `gone`. Real `move_right` advanced
  to x `2425` and started `grace` with contact off.
- Runtime phase probes reported `warning` with contact off and HP `100`, then
  `active` with a playing four-frame animation. The actual `Area2D` overlap
  changed HP `100 -> 92` and recorded the expected hazard source. `safe`
  disabled contact and held HP at `92`.
- A second real `move_right` crossed x `2480` and stopped at approximately x
  `2500`, below the Story087 activation boundary x `2552`. Story086 reported
  `crossed`, inactive, hidden and non-contact with HUD
  `Forward Pressure Aftershock Exhaust Crossed`; the vent animation stopped.
- Story087 reported available but inactive, hidden, process/physics disabled,
  `24 HP`, and hurtbox `gone`.
- RGB `1278x718` screenshots were non-empty. The active capture showed the
  four-frame steam plume and visible Cinderpaw; the crossed capture showed
  Cinderpaw beyond the hidden vent with the completion HUD.
- Accepted game log contained only MCP helper registration and the editor log
  contained zero entries. Movement was released, `Engine.time_scale` restored
  to `1.0`, the project stopped, and editor readiness returned to `ready`.
- Exploratory runs 55 and 56 were excluded. Run 56 entered a debugger break
  because a temporary MCP eval probe inferred a Variant while warnings were
  treated as errors; the probe was rewritten with explicit types, logs were
  cleared, and the complete acceptance was repeated cleanly in run 57.

## Asset Use

No image generation was required. Existing registered image-generated assets
were reused. `FactoryLowerDeckForwardPressureAftershockExhaustVent/SteamAnimation`
uses
`assets/environment/old_factory_steam_vent/factory_steam_vent_sprite_frames.tres`
with `safe`, `warning` and `active`, four transparent frames each. Cinderpaw and
Factory Coil Rat retain their existing `AnimatedSprite2D + SpriteFrames`
pipelines. No asset-governance file changed.

## Residual Risks

- Shared steam hazards can damage again on later active cycles according to
  their existing cooldown and overlap behavior. Global steam balance is outside
  this Story.
- Story087 is safely available after this handoff, but real activation, combat,
  defeat and its reward-cache transition remain the next production slice.
- Shared RatMinion death hold/fade timing remains a broader presentation issue.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Real movement starts Story086 | Canonical; MCP real input | PASS |
| Production loop advances all phases | Canonical `_process`; MCP probes | PASS |
| Only active physical overlap damages | Canonical gating; MCP `100 -> 92` | PASS |
| Real movement crosses x `2480` | Canonical; MCP real input | PASS |
| Story087 remains safely inactive | Canonical; MCP diagnostics | PASS |
| Vent/character frame animation remains valid | Related tests; MCP screenshots | PASS |
| Godot 4.7 / MCP 3.0.4 logs are clean | Smoke; accepted run 57 | PASS |
