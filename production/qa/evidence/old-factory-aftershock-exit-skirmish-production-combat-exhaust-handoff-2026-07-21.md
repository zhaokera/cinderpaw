# QA Evidence: Old Factory Aftershock Exit Skirmish Production Combat Exhaust Handoff -- 2026-07-21

## Scope

Player Abilities Story205 connects Story084 claim, Story085 production combat
and Story086 entry. It adds handoff barriers, fresh-movement gating, inactive
hurtbox safety and readable opening flanks. No new assets, shared AI steering,
economy system or SaveSystem schema were introduced.

## TDD And Regression Evidence

- `reports/report_2230/report_1/results.xml`: initial canonical RED, `0/1`, six
  expected failures.
- `reports/report_2231/report_1/results.xml`: refined RED, `0/1`, ten expected
  failures and zero errors, covering inactive hurtboxes, claim-frame chaining,
  real recross, opening spacing and Story086 clear-frame chaining.
- `reports/report_2232/report_1/results.xml`: initial focused GREEN, `1/1`.
- `reports/report_2234/report_1/results.xml`: readability RED, `0/1`; the only
  failure was actual center distance `224px` below the new `250px` threshold.
- `reports/report_2235/report_1/results.xml`: final focused GREEN, `1/1`.
- `reports/report_2237/report_1/results.xml`: final four-suite bounded related
  GREEN, `8/8`, zero failure/error/flaky/skip/orphan. Coverage includes
  Story205, Story204, Story085 and Story086.
- Factory `180`-frame headless smoke exited `0`; log:
  `reports/old_factory_aftershock_exit_skirmish_production_combat_exhaust_handoff_smoke.log`.
  No project script, parse, invalid-call or resource-load error was found. The
  `4 ObjectDB / 2 resources` shutdown diagnostic matches the established
  Factory baseline.
- No full suite was run; verification remained bounded to the changed path.

## Production Contract

- Inactive `2129/2130` cannot steal attacks because their hurtboxes are `gone`.
- Real Story084 interact creates Story085 availability without same-frame
  activation. A later positive movement crossing x `2288` is required.
- Opening staging is Spark `+144px`, Coil `-160px`, producing `304px` center
  separation and at least `48px` player flank clearance before normal pursuit.
- Each enemy starts at `24 HP`; canonical and MCP verification use direct damage
  only for nonlethal `24 -> 12`, then real attack input for `12 -> 0`.
- Partial/full deaths keep three-frame `death` visuals processing while physics,
  target and hurtbox are disabled for defeated actors.
- Story086 becomes visible/available on clear but does not borrow the lethal
  frame. Stationary input remains idle; fresh positive movement at x `2416`
  starts `grace` with contact disabled.

## Godot MCP Runtime Evidence

- Session `cinderpaw@1311`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `3.0.4`.
- Accepted run `r130447473-54` (`run token 54`) launched the custom Factory
  scene with `autosave=false`. Real `interact` claimed Story084 and left
  Story085 available/inactive. Real left movement moved x `2288 -> 2268`; a
  later real right crossing activated Story085.
- Activation reported both targets active with `24 HP`, `normal` hurtboxes,
  process/physics and six three-frame animations. Initial positions measured
  `304px` center-to-center with player flank distances above `143px`.
- Two directional real `Input.attack` sequences produced target ids `2129` and
  `2130`, hitbox `cat_claw_light`, damage `12` and HP `0`. Partial defeat kept
  one `death` visible/process and the survivor active; full clear kept both
  deaths visible/process and noncombat.
- Immediately after full clear Story086 was available/visible but inactive with
  contact off. A reset to the identical cleared state remained idle while
  stationary; real `move_right` advanced x `2416 -> 2429` and entered `grace`
  with HUD `Cross Aftershock Exhaust` and contact still off.
- RGB `1278x718` screenshots showed the opening flank composition, partial
  death and exhaust grace state. Accepted game log contained only helper
  registration; editor log had zero entries. All inputs were released,
  `Engine.time_scale` restored to `1.0`, and the editor returned to ready.
- Earlier exploratory runs containing temporary eval-probe mistakes were
  stopped, cleared and excluded before accepted run 54.

## Asset Use

No image generation was required. Existing registered image-generated assets
for Cinderpaw, Factory Spark Rat, Factory Coil Rat, the dynamic steam vent and
Factory environment were reused. No runtime asset or asset-governance file
changed.

## Residual Risks

- The `250px` contract covers initial staging only. Existing pursuit AI can
  close the enemies together later; persistent crowd steering remains out of
  scope.
- Story086 entry is production-connected, but its complete real traversal
  through warning/active/safe and x `2480` remains the next slice.
- Shared RatMinion death hold/fade timing remains a broader presentation concern.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Inactive hurtboxes cannot steal attacks | Canonical; MCP pre-claim probe | PASS |
| Cache claim does not chain Story085 | Canonical; MCP real interact | PASS |
| Fresh movement activates Story085 | Canonical; MCP real recross | PASS |
| Opening dual-enemy spacing is readable | 250px RED/GREEN; MCP 304px | PASS |
| Real attacks clear 2129/2130 | Canonical; MCP hit metadata | PASS |
| Partial/full death remains visible/noncombat | Related tests; MCP runtime | PASS |
| Story086 requires fresh movement | Canonical; MCP stationary/real move | PASS |
| Godot 4.7 / MCP 3.0.4 logs and screenshots | Smoke; accepted run 54 | PASS |
