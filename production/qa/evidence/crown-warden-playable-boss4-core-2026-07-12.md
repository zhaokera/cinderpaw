# QA Evidence: Crown Warden Playable Boss4 Core -- 2026-07-13

## Scope

Story146 turns the generated Story145 observatory into a complete bounded Boss4
fight. It covers generated multi-frame character art, two real attack patterns,
chain-safe phase two, Boss HUD, room seals, scene lock, retry, persistent defeat
and return-route opening. Reward, ending and cinematic polish remain later work.

## Automated Evidence

- `report_1547`: expected RED for recursive schema items and injected damage.
- `report_1548`: schema plus Story146 GREEN, `19/19`.
- `report_1549`: expected RED for death-frame anchors and reachable `run`.
- `report_1551`: final focused Story146 GREEN, `6/6`.
- `report_1552`: shared collision/respawn regression GREEN, `6/6`.
- `report_1553`: final bounded related GREEN, `34/34`, zero errors, failures,
  skipped tests or orphans. Coverage includes schema, shared collision,
  Story145, Boss3 and Story146. No full suite was run.

## Asset Generation And Import

- Source and exact prompt/processing record:
  `assets/characters/crown_warden/source/crown_warden_sprite_sheet_imagegen_20260712.md`.
- Twenty-four transparent `192x192` frames cover `idle`, `run`, both attack
  tells, both attacks, `hurt` and `death`, three frames per state.
- Death canvases received deterministic transparent-only vertical shifts so
  every opaque bottom resolves to y `159`; no character pixels were repainted.
- SpriteFrames resource:
  `assets/characters/crown_warden/crown_warden_sprite_frames.tres`.
- Asset spec, manifest and entity inventory record prompt intent, source,
  runtime paths and integration ownership.

## Headless Runtime Smoke

- Script: `tests/smoke/crown_warden_playable_boss4_core_smoke.gd`.
- Log: `reports/crown_warden_playable_boss4_core_smoke.log`.
- Result: exit `0`, marker
  `crown_warden_playable_boss4_core_smoke=passed`.
- Coverage uses real physics overlap for Cinderpaw and both Boss attacks, then
  verifies phase pending/complete, collidable retry, defeat and fresh restore.

## Godot MCP Runtime Evidence

- Session `cinderpaw@13e3`; Godot `4.7-stable`; plugin/server `2.9.1`.
- Forced scene open resolved `37` authored nodes, including both
  `AnimatedSprite2D` actors, room seals, HUD and return route.
- Final run `r3362590-4` started with `current_run_errors=[]`.
- Real MCP `attack` input reduced Boss HP `160 -> 148`; metadata reported
  attacker `1`, target `2400`, `cat_claw_light`, `cat_claw` and damage `12`.
- Real runtime overlaps reduced player HP `100 -> 82` for `talon_dive` and
  `100 -> 86` for stationary `wing_sweep`; metadata reported `18` and `14`.
- Threshold damage during active sweep retained Phase I with
  `phase_two_pending=true`; recovery then produced Phase II, cooldown `30`,
  dive step `12`, unchanged abilities and live HUD `Phase II 80/160`.
- Lethal player damage restored HP `100/100`, hurtbox `normal` and monitorable,
  Boss HP `160/160`, Phase I, authored anchors, seals and scene lock.
- Boss defeat produced the visible three-frame `death` state, hidden HUD/seals,
  released lock, open return and durable
  `boss_04_crown_warden_defeated=true`. A fresh arena restore reproduced the
  open state without a transition latch.
- Screenshot evidence:
  `crown-warden-playable-boss4-phase2-mcp.png` and
  `crown-warden-playable-boss4-defeated-mcp.png`; both are non-empty `1278x718`
  generated-art gameplay frames with visible characters and readable state.
- Final game log contained only helper registration and DataManager loads.
  Editor cursor `4 -> 4` added no rows.
- Four retained editor rows referenced an obsolete Story137 temporary fixture
  and predated the final run. The stale fixture was removed; no cursor-scoped
  error was added by Story146. One discarded exploratory eval entered a parser
  break; the project was stopped, logs were cleared and final Run4 was clean.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Data/schema and shared component identity | GdUnit; MCP diagnostics | PASS |
| Generated 8x3 animations and required scenes | Asset records; GdUnit; MCP screenshots | PASS |
| Exact dive/sweep contracts | GdUnit; smoke; MCP real overlaps | PASS |
| Chain-safe Phase II and unchanged abilities | GdUnit; smoke; MCP Phase II evidence | PASS |
| Real player chain, HUD, seals and scene lock | Related suite; smoke; MCP real input | PASS |
| Fully collidable death retry | Shared regression; smoke; MCP lethal retry | PASS |
| Persistent defeat and fresh restore | GdUnit; smoke; MCP restore probe | PASS |
| Clean Godot 4.7 / MCP 2.9.1 final run | Run `r3362590-4`; cursor-scoped logs | PASS |
