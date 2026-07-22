# QA Evidence: Old Factory Aftershock Exhaust Pursuer Production Combat Reward Handoff -- 2026-07-21

## Scope

Player Abilities Story207 connects Story087 activation and combat to Story088's
production reward input, then leaves Story089 safely available but inactive.
It covers a fresh movement boundary, real player attack, live death
presentation, once-only reward interaction, HUD feedback and inactive next-
encounter collision safety. No new asset, economy rule, save schema or room was
introduced.

## TDD And Regression Evidence

- `reports/report_2245/results.xml`: canonical RED, `0/1`; production
  interaction could not claim the Story088 cache.
- `reports/report_2246/results.xml`: first focused GREEN, `1/1`.
- `reports/report_2247/results.xml`: first bounded run; its only failures were
  three stale Story089 assertions that hid a live defeated Spark Rat.
- `reports/report_2248/results.xml`: focused Story089 GREEN, `3/3`,
  covering visible live death and hidden restored completion.
- `reports/report_2249/results.xml`: refined boundary RED, `0/1`; it
  proved Story086 completion could activate Story087 in the same process frame.
- `reports/report_2250/results.xml`: focused boundary GREEN, `1/1`.
- `reports/report_2251/results.xml`: fresh final bounded related GREEN, eight
  suites and `14/14`, zero failure/error/flaky/skip/orphan. Coverage includes
  Stories 204, 206, 087, 088, 089, earlier reward-input arbitration, and the
  Factory service lift.
- Factory `180`-frame headless smoke exited `0`; log:
  `reports/old_factory_aftershock_exhaust_pursuer_production_combat_reward_handoff_smoke.log`.
  No project script, parse, invalid-call or resource-load error was found. The
  `4 ObjectDB / 2 resources` shutdown diagnostic matches the established
  Factory baseline.
- No full suite was run; verification stayed bounded to the changed path.

## Production Contract

- Story086 completion snapshots Story087 as unavailable for that process frame.
  Story087 requires a later fresh positive x movement across `2552`.
- Active entity `2131` has `24 HP`, target/process/physics enabled and hurtbox
  `normal`; all six gameplay animations use three-frame SpriteFrames.
- Real player attack routes through `cat_claw_light`. Live defeat sets HP `0`,
  disables target/physics/hurtbox, and preserves visible/process `death`.
- Story088 appears immediately after defeat with prompt `+20 Gears` and is
  included in nearest progression-cache arbitration.
- Real interaction grants one `20`-gear payload with source
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache`
  and feedback `Forward Pressure Exhaust Pursuer Cache Claimed +20 Gears`.
- Duplicate interaction cannot claim again. Story089 becomes available but its
  entity `2132` remains hidden/inactive, `24 HP`, and hurtbox `gone`.

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.4`.
- Accepted run `r135689461-59` (`run token 59`) launched
  `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`.
- Real `move_right` moved Cinderpaw from x `2528` to approximately x `2560`
  and activated entity `2131`: visible, process/physics enabled, player target,
  `24 HP`, hurtbox `normal`, HUD `Purge Aftershock Exhaust Pursuer`.
- Runtime SpriteFrames inspection confirmed `AnimatedSprite2D` and exactly
  three frames each for `idle`, `run`, `attack_tell`, `attack`, `hurt`, and
  `death`.
- A deterministic nonlethal setup changed HP `24 -> 12`; real `move_left`
  facing plus real `attack` finished `12 -> 0`. Last-hit metadata reported
  target `2131`, attack type `light`, hitbox `cat_claw_light`, and applied
  damage.
- Live defeat retained visible/process `death` at frame `2`, while physics,
  target and hurtbox were disabled. The cache became visible/available/
  claimable with `+20 Gears`.
- Real `interact` at cache position `(2664, 410)` claimed it once. Payload,
  source, feedback and HUD matched the production contract. A duplicate real
  interaction left the same single `20`-gear reward and claim unavailable.
- Story089 then reported available but inactive; entity `2132` stayed hidden,
  `24 HP`, hurtbox `gone`.
- The accepted game log contained one helper-registration info line and no
  warning/error. Editor log was empty. All driven inputs were released,
  `Engine.time_scale` restored to `1.0`, the project stopped, and editor
  readiness returned to `ready`.
- Exploratory run 58 was excluded after a temporary MCP eval probe mixed tab
  and space indentation and entered a debugger parse break. The run was
  stopped, logs cleared, and the complete acceptance repeated cleanly as run
  59; no production project file caused the probe error.

## Visual Evidence

- `reports/visual/cinderpaw-mcp-old-factory-aftershock-exhaust-pursuer-production-combat-reward-handoff-death-20260721.png`
  is a non-empty RGB `1278x718` capture showing the complete Factory art, HUD
  `Forward Pressure Exhaust Pursuer Cleared`, visible defeated character, and
  the `+20 Gears` cache.
- `reports/visual/cinderpaw-mcp-old-factory-aftershock-exhaust-pursuer-production-combat-reward-handoff-claimed-20260721.png`
  is a non-empty RGB `1278x718` capture showing the claimed-cache HUD and
  player-visible Factory route with the cache removed.

## Asset Use

No image generation was required. Existing registered image-generated
Cinderpaw, Factory Coil Rat, reward-cache and Factory environment assets were
reused. The character remains on `AnimatedSprite2D + SpriteFrames`; no asset
governance file changed.

## Residual Risks

- Factory cache payloads are currently local reward contracts; unified wallet
  crediting remains a separate economy slice.
- Story089 is only validated as a safe inactive handoff here. Its production
  movement activation, combat and hazard loop remain the next slice.
- Shared RatMinion death hold/fade timing remains broader presentation debt.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Same-frame Story086 to Story087 chaining is blocked | Canonical boundary RED/GREEN | PASS |
| Fresh real movement activates entity 2131 | Canonical; MCP real input | PASS |
| Real attack defeats the pursuer | Canonical; MCP hit metadata | PASS |
| Live death exposes the reward cache | Related tests; MCP state/screenshot | PASS |
| Real interaction grants +20 exactly once | Canonical; MCP real input | PASS |
| Story089 remains collision-safe and inactive | Canonical; MCP diagnostics | PASS |
| Godot 4.7 / MCP 3.0.4 logs are clean | Smoke; accepted run 59 | PASS |
