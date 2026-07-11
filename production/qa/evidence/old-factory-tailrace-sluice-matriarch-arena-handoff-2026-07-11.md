# QA Evidence: Old Factory Tailrace Sluice Matriarch Arena Handoff -- 2026-07-11

## Scope

Story127 converts the Story126 Sluice Leech clear into a real asynchronous
SceneManager transition from `area_03_factory` to the dedicated
`boss_03_sluice_matriarch_arena`, then supports a deterministic return to the
Factory gate. It adds the authored arena environment and transition shell only.
Sluice Matriarch combat, boss frames, HUD, phases, seals, reward, and
`aerial_attack` unlock remain Story128 and later scope.

## GDD Convergence

- `exploration-ability-gating.md` places `aerial_attack` on the Factory to
  underground route.
- `player-abilities.md` grants `aerial_attack` only after Boss3.
- A dedicated Boss3 arena therefore advances the documented route more directly
  than another extension of the existing 18,140-pixel Factory corridor.

## Automated Evidence

- RED focused: `reports/report_1391/`
  - Exit `100`; Story127 executed `2` tests and exposed the expected missing
    arena script, scene, registry, route, and backdrop contracts.
- Test-contract correction: `reports/report_1392/`
  - The implementation loaded, but one test treated `Image.detect_alpha()` as
    a boolean. Godot 4.7 returns an enum integer; the assertion was corrected
    to compare with `Image.ALPHA_NONE` without changing production behavior.
- GREEN focused: `reports/report_1393/`
  - Exit `0`; Story127 passed `2/2` with zero failures.
- Initial related run: `reports/report_1394/`
  - Story127 and SceneManager suites passed. Two Story126 assertions still
    expected the previous terminal label `Tailrace Sluice Leech Cleared` after
    the new handoff became available.
- Final related GREEN: `reports/report_1395/`
  - Exit `0`; Story127, Story126, SceneManager Story001 registry API, and
    SceneManager Story005 runtime tree swap passed `17/17` with zero failures.
  - The two Story126 expectations now follow the new next objective
    `Enter Sluice Matriarch Lair`; no combat assertion was weakened.

## Asset Generation And Import

- Mode: built-in image generation followed by one local fixed-size resize.
- Prompt intent: a side-view pixel-art tailrace pressure cathedral with riveted
  steel, damp pipes, rust-orange pressure machinery, cyan entrance lighting, a
  broad readable floor, and a dormant giant leech cocoon behind cracked glass;
  no UI, text, active characters, or visible placeholder blocks.
- Generation record:
  `assets/generated/source/sluice_matriarch_arena_backdrop_imagegen_20260711.md`.
- Retained RGB source:
  `assets/generated/source/sluice_matriarch_arena_backdrop_imagegen_20260711.png`,
  `1672x941`, opaque.
- Runtime RGB output:
  `assets/environment/sluice_matriarch_arena/env_sluice_matriarch_arena_backdrop_1280x720.png`,
  `1280x720`, opaque.
- Processing: resized with `sips`; no alpha extraction or chroma-key removal was
  required for the full-screen background.
- Godot 4.7 headless import exited `0` and imported both source and runtime PNGs.

## Headless Runtime Smoke

- Script:
  `tests/smoke/old_factory_tailrace_sluice_matriarch_arena_handoff_smoke.gd`.
- Log:
  `reports/old_factory_tailrace_sluice_matriarch_arena_handoff_smoke.log`.
- Result: exit `0` with marker
  `old_factory_tailrace_sluice_matriarch_arena_handoff_smoke=passed`.
- Coverage: actual SceneManager runtime root, Factory Story126 clear, one-shot
  Factory-to-arena request, `boss_entry` spawn, one-shot return request,
  `tailrace_matriarch_gate_return` spawn, preserved leech clear, and cleared
  transient transition latches.
- Log note: only known shutdown-time `4 ObjectDB instances leaked` and
  `2 resources still in use` cleanup messages appeared after the pass marker.

## Godot MCP Runtime Evidence

- Session: `cinderpaw@e40d`.
- Godot MCP: `2.9.1`; editor/runtime: Godot `4.7-stable`.
- Filesystem scan and forced disk reload opened
  `res://scenes/bosses/sluice_matriarch_arena.tscn` and confirmed its 25-node
  hierarchy, including `Background`, bounded physics, `BossEntrySpawn`,
  Cinderpaw `AnimatedSprite2D`, player Camera2D, `FactoryReturnRoute`, and the
  arena objective label.
- Typed arena inspection confirmed the exact backdrop path, texture visibility,
  entry/player position `(260,540)`, return target
  `area_03_factory / tailrace_matriarch_gate_return`, available prompt
  `Return to Tailrace Spillway`, and no transition latched at rest.
- The first `960x539` screenshot exposed a left-edge prompt clip. The entry and
  route were moved inward, the scene was force-reloaded, and the final non-empty
  `960x539` screenshot showed the complete prompt, Cinderpaw, readable floor,
  industrial arena, and dormant cocoon. Player-to-route distance remained
  `134.164`, above the `112` automatic-contact threshold at spawn.
- Contact evaluation requested Factory exactly once. Advancing SceneManager
  loading produced `area_03_factory / tailrace_matriarch_gate_return` and placed
  Cinderpaw exactly on `FactoryTailraceSluiceMatriarchReturnSpawn` at
  `(17840,456)`.
- Restoring Story126 clear made the Factory gate available with prompt
  `Enter Sluice Matriarch Lair`, kept the leech hidden/cleared, and preserved
  the Tailrace Relay checkpoint. Factory gate contact requested
  `boss_03_sluice_matriarch_arena / boss_entry`; advancing loading returned to
  the actual arena runtime root.
- `project_run(mode=current, autosave=false)` reported
  `current_run_errors=[]`. The current game log contained only helper
  registration, and the final cursor-scoped editor log had no new rows.
- Retained editor parse rows visible in history came from an intermediate
  Story126 patch and predated this run; current-run and cursor-scoped evidence
  were clean.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Story126-gated Factory route and one-shot arena request | Focused GdUnit; smoke; MCP Factory eval | PASS |
| Registry/schema Boss3 arena contract | Focused/related GdUnit; MCP scene load | PASS |
| Authored bounded arena with generated opaque backdrop | Image audit; import; MCP hierarchy/screenshot | PASS |
| One-shot arena return and actual Factory spawn | Focused GdUnit; smoke; MCP transition eval | PASS |
| Leech clear and Tailrace Relay survive round trip | Story126 related GdUnit; smoke clear-state check; MCP restore eval | PASS |
| Godot 4.7 / MCP 2.9.1 clean current run | MCP logs and final screenshot | PASS |
