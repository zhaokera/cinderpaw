# QA Evidence: Sluice Matriarch Playable Boss3 Core -- 2026-07-11

## Scope

Story128 turns the Story127 destination into a bounded playable Boss3 fight.
The slice adds generated frame animation, shared combat components, one
telegraphed pressure-lunge family, a faster second phase, Boss HUD, room seals,
player-death retry, persistent defeat state, and the opened Factory return
route. The `aerial_attack` reward and post-Boss3 route remain Story129 scope.

## Automated Evidence

- Initial RED: `reports/report_1396/`
  - Story128 ran `2` tests and produced the expected six missing character,
    runtime, frame-resource, and arena contracts.
- First implementation GREEN: `reports/report_1398/`
  - The initial asset/runtime and combat/arena tests passed `2/2`. An
    intermediate `report_1397/` failure corrected only the direct-test boss
    start position to match its authored arena bounds.
- Arena evolution regression: `reports/report_1399/` -> `report_1400/`
  - The first related run exposed Story127 expectations that still assumed an
    always-open return route and no HUD ColorRects. Those assertions were
    updated to allow only HUD descendants and restore defeated state before
    requesting return. The bounded related set then passed `11/11`.
- Player-death retry RED/GREEN: `reports/report_1401/` -> `report_1402/`
  - MCP first exposed a zero-HP encounter deadlock. The new failing test showed
    Cinderpaw at `0` HP with a damaged/displaced boss; the fix respawns the
    player and resets the Matriarch to full HP, phase one, and `(930,540)`.
- Phase-HUD RED/GREEN: `reports/report_1404/` -> `report_1405/`
  - The new test proved phase two was active while the HUD still said Phase I.
    Wiring the boss phase signal to the arena HUD made Story128 pass `4/4`.
- First complete related run: `reports/report_1406/`
  - Story128, Story127, Boss2 HUD focus, and Boss2 room seals passed `13/13`.
- Respawn-hurtbox RED/GREEN: `reports/report_1407/` -> `report_1408/`
  - Final MCP inspection showed `respawn_at()` restored HP but left the shared
    player hurtbox `gone` and non-monitorable. The new assertion failed exactly
    on that state. Restoring the Core hurtbox to `normal` in the shared player
    respawn entry made Story128 pass `4/4` with zero failures.
- Respawn-related GREEN before ADR review: `reports/report_1409/`
  - Story128, Story127 handoff, player respawn feedback, and player
    hurt/death/revive animation passed `14/14`, zero failures/errors/orphans.
- SceneManager lock RED/GREEN: `reports/report_1410/` -> `report_1411/`
  - ADR-0007 review added an assertion that active Boss3 combat owns the
    SceneManager lock and defeat releases it. The RED failed on the missing
    lock; the ownership-aware arena implementation made Story127 pass `2/2`.
- ADR-reviewed related GREEN: `reports/report_1412/`
  - Story128, Story127 handoff/scene lock, player respawn feedback, and player
    hurt/death/revive animation passed `14/14`, zero failures/errors/orphans.
- Player attack-chain RED/GREEN: `reports/report_1413/` -> `report_1414/`
  - Submission review added a direct `cat_claw_light` hit against the Boss3
    CollisionComponent. RED showed the attack animation returned success but
    Boss HP stayed `120` because the arena had not mounted/injected the shared
    WeaponComponent. Reusing the MainScene/Factory binding pattern made the
    focused Story128 suite pass `4/4` and reduced Boss HP `120 -> 108`.
- Final bounded related GREEN: `reports/report_1415/`
  - Story128, Story127 handoff/scene lock, player respawn feedback, and player
    hurt/death/revive animation passed `14/14`, zero failures/errors/orphans.

## Asset Generation And Import

- Mode: built-in image generation followed by local magenta-key removal,
  slicing, and normalization.
- Prompt intent: one coherent giant mutated industrial leech in a strict `3x6`
  sheet, rows `idle`, `run`, `attack_tell`, `attack`, `hurt`, `death`; wet
  charcoal-purple body, steel clamps, cracked ceramic, rust hardware, cyan
  seams, red warning spines, flat `#ff00ff`, no rat anatomy, text, UI, or scene.
- Generation record:
  `assets/characters/sluice_matriarch/source/sluice_matriarch_sprite_sheet_imagegen_20260711.md`.
- Retained source: `1254x1254` opaque RGB; retained alpha source:
  `1254x1254` RGBA; transparent preview: `576x1152` RGBA.
- Processing sampled `#f703f7`, used soft matte/despill with thresholds
  `12/220`, split exact `418x209` cells, normalized each to `188x94`, and
  centered it on one transparent `192x192` runtime canvas.
- Eighteen imported frames live under
  `assets/characters/sluice_matriarch/<animation>/`; all six SpriteFrames
  animations contain exactly three continuous frames.
- Godot 4.7 headless import exited `0` and imported the source, alpha, preview,
  runtime frames, and SpriteFrames dependencies.

## Headless Runtime Smoke

- Script: `tests/smoke/sluice_matriarch_playable_boss3_core_smoke.gd`.
- Log: `reports/sluice_matriarch_playable_boss3_core_smoke.log`.
- Final result: exit `0` with marker
  `sluice_matriarch_playable_boss3_core_smoke=passed`.
- Coverage: active HUD/seals/locked route; startup and active pressure-lunge;
  body movement and shared `16`-damage collision path; phase-two pressure;
  defeat opens the route and hides seals/HUD; defeated state restores without
  a stale transition latch.

## Godot MCP Runtime Evidence

- Session: `cinderpaw@e40d`; Godot editor/runtime: `4.7-stable`; plugin and
  server: Godot AI MCP `2.9.1`.
- Filesystem scan and forced disk reload opened
  `res://scenes/bosses/sluice_matriarch_arena.tscn`. The authored hierarchy has
  `37` nodes, including the player and boss `AnimatedSprite2D` nodes, both room
  seals, HUD, return route, bounded floor/walls, and camera.
- The boss SpriteFrames resource resolved to
  `res://assets/characters/sluice_matriarch/sluice_matriarch_sprite_frames.tres`;
  `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` each reported
  exactly `3` frames.
- Pressure-lunge inspection reported startup animation `attack_tell`, no
  startup hitbox, then active animation `attack`, active shared hitbox, and
  movement x `930 -> 916`. Collision metadata resolved `final_damage=16`.
- Final run token `21` confirmed the arena-mounted WeaponComponent resolved
  current weapon `cat_claw`; Cinderpaw's request activated
  `cat_claw_light`, reduced Boss3 HP `120 -> 108`, and emitted player-hit
  metadata with `target_id=2300`, `weapon_id=cat_claw`, and `final_damage=12`.
- Player-death inspection showed the dead hurtbox as `gone`, then the retry
  callback restored HP `100/100`, position `(260,540)`, hurtbox `normal` and
  monitorable, boss HP `120/120`, phase one, and anchor `(930,540)`. After the
  designed 120 respawn invincibility frames were cleared for the probe, the
  same shared attack path reduced HP `100 -> 84`.
- Phase-two inspection reported boss HP `59/120`, phase `2`, lunge step `20`,
  cooldown `28`, and live HUD text `Sluice Matriarch  Phase II  59/120`.
  A non-empty `1278x718` screenshot showed Cinderpaw, generated boss frames,
  both seals, readable arena art, and the active Boss HUD without overlap.
- Defeat inspection reported HP `0`, animation `death`, hitbox inactive,
  `boss_03_sluice_matriarch_defeated=true`, both seals hidden/disabled, Boss
  HUD hidden, and return route available. A second non-empty `1278x718`
  screenshot showed the persistent corpse and `Return to Tailrace Spillway`.
- Final ADR-0007 lock inspection on run token `20` reported
  `scene_manager_locked=true` and `scene_manager_lock_owned=true` during active
  combat, then both false immediately after defeat. The ownership latch also
  releases the lock from `_exit_tree()` without unlocking locks owned elsewhere.
- After the lock change, a fresh non-empty `960x539` screenshot again showed
  the defeated boss, hidden room seals, visible return route, HUD, and arena.
- Final run token `21` reported `current_run_errors=[]`; the current game log
  contained only helper registration, and editor logs since cursor `3` had no
  new rows. Retained cursor rows predate Story128's final run.
- One earlier MCP verification snippet mixed spaces and tabs while attempting
  a manual frame loop and caused an eval-only debugger break. The project was
  stopped and relaunched; the equivalent probe used direct deterministic state
  control, and the final run/log/screenshots above were clean.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Six transparent three-frame Boss3 animations and required scenes | Asset audit; Story128 GdUnit; MCP SpriteFrames inspection | PASS |
| Shared entity/components, player WeaponComponent hit chain, and 120 HP | Story128 GdUnit; MCP `cat_claw_light` hit metadata | PASS |
| Pressure-lunge startup/active/recovery | Story128 GdUnit; smoke; MCP attack metadata | PASS |
| Faster phase two and synchronized Boss HUD | Story128 phase-HUD test; smoke; MCP eval/screenshot | PASS |
| Active room/SceneManager lock and defeat-open return | Story128/Story127 tests; smoke; MCP lock diagnostics/screenshots | PASS |
| Player death retries a fully combat-capable encounter | RED/GREEN reports 1401/1402 and 1407/1408; MCP retry/hit probes | PASS |
| Defeat persistence with transient latches clear | Story128 GdUnit; smoke; MCP local state | PASS |
| Godot 4.7 / MCP 2.9.1 clean final run | MCP session, logs, hierarchy, evals, screenshots | PASS |
