# QA Evidence: Old Factory Aftershock Exhaust Flank Production Combat Breaker Handoff -- 2026-07-21

## Scope

Player Abilities Story208 connects Story089 to production movement, steam
contact, enemy bite, player combat, live death and a collision-safe Story090
handoff. It adds no content asset, economy rule, save schema or room.

## TDD And Regression Evidence

- `reports/report_2252/results.xml`: canonical RED, `0/1`; stationary x beyond
  `2768` activated entity `2132`.
- `reports/report_2253/results.xml`: refined RED, `0/1`; restored-state
  teleport still counted as forward movement until runtime trackers were reset.
- `reports/report_2254/results.xml`: integration RED reached combat and exposed
  missing recovery from the player's steam `HIT_STUN`.
- `reports/report_2255/results.xml`: focused GREEN, `1/1`.
- `reports/report_2256/results.xml`: first bounded run, `10/11`; the only
  failure was Story090's stale immediate-hide death expectation.
- `reports/report_2257/results.xml`: Story090 focused GREEN, `2/2`.
- `reports/report_2258/results.xml`: final bounded related GREEN, five suites
  and `11/11`, zero failure/error/flaky/skip/orphan.
- Factory `180`-frame headless smoke exited `0`; log:
  `reports/old_factory_aftershock_exhaust_flank_production_combat_breaker_handoff_smoke.log`.
  No project script, parse, invalid-call or resource-load error was found. The
  `4 ObjectDB / 2 resources` shutdown diagnostic matches the Factory baseline.
- No full suite was run.

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.4`.
- Accepted run `r137556639-60` launched
  `res://scenes/factory_route_transition_shell.tscn` with `autosave=false` and
  helper live.
- Initial state at x `2756` kept Story089 available/inactive, entity `2132`
  hidden at `24 HP` with hurtbox `gone`, and entity `2133` hidden at `24 HP`
  with hurtbox `gone`.
- Real `move_right` crossed x `2768` and activated only Story089. Entity `2132`
  became visible, targeted, process/physics enabled, `24 HP`, hurtbox `normal`;
  all six gameplay animations reported three frames.
- The runtime vent contained `SteamAnimation`, hid static `Visual`, played the
  four-frame `active` animation, and reported real overlapping areas. That
  overlap changed player HP `100 -> 92` and recorded the exact Story089 hazard
  source.
- Spark Rat production bite metadata reported attacker `2132`, target `1`,
  weapon `factory_spark_rat_bite`, and final damage `9`.
- Two real player `attack` inputs through `cat_claw_light` changed entity
  `2132` from `24 -> 12 -> 0`; both hits recorded target `2132` and applied
  damage `12`.
- Live defeat reported `death`, visible/process on, physics/target/hurtbox off,
  and vent contact off. Story090 was available but inactive; entity `2133`
  stayed hidden, process/physics off, `24 HP`, hurtbox `gone`; its vent and
  breaker stayed hidden.
- Accepted game log contained one helper-registration info line and no
  warning/error. Editor log was empty. All driven inputs were released,
  `Engine.time_scale=1.0`, tree unpaused, project stopped, editor ready.

## Visual Evidence And Risk

- `reports/visual/cinderpaw-mcp-old-factory-aftershock-exhaust-flank-production-combat-breaker-handoff-active-20260721.png`
  is non-empty RGB `1278x718` and shows Cinderpaw, animated Spark Rat, dynamic
  steam, authored Factory environment and the active objective.
- `reports/visual/cinderpaw-mcp-old-factory-aftershock-exhaust-flank-production-combat-breaker-handoff-cleared-20260721.png`
  is non-empty RGB `1278x718` and shows the cleared objective with Story090
  still hidden.
- The active capture confirms a readability debt: the player, enemy and vent
  silhouettes overlap tightly at activation. Existing assets are valid and no
  image generation is needed; a later warning/staging pass should solve this
  through encounter timing or placement.

## Asset Use

No new visual asset was generated. Existing registered image-generated
Cinderpaw, Factory Spark Rat, Factory Coil Rat, dynamic steam and Factory
environment assets were reused without modifying asset governance files.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Fresh movement activates Story089 | Canonical; MCP real input | PASS |
| Real steam overlap deals 8 | Steam suite; MCP overlap and HP | PASS |
| Spark Rat production bite works | MCP attack metadata | PASS |
| Real player combat defeats 2132 | Canonical; MCP two real hits | PASS |
| Live death clears hazard | Related tests; MCP state | PASS |
| Story090 remains collision-safe | Canonical; MCP diagnostics | PASS |
| Godot 4.7 / MCP 3.0.4 logs clean | Smoke; accepted run 60 | PASS |
