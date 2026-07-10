# QA Evidence: Old Factory Tailrace Exit Spillway Sluice Leech Skirmish -- 2026-07-11

## Scope

Story126 adds one post-spillway Factory Sluice Leech to
`scenes/factory_route_transition_shell.tscn`. The encounter introduces a
distinct frame-animated enemy family, a deterministic attack tell and lunge,
scene-local persistence, and enough route support for the combat pocket. It
does not add rewards, a savepoint, a route transition, a new Autoload, or a
SaveSystem schema change.

## Automated Evidence

- RED focused: `reports/report_1385/`
  - Result: exit `100`; the two test cases executed and exposed five expected
    missing-contract failures before the character assets and route APIs
    existed.
- Intermediate focused: `reports/report_1386/`
  - The generated character contract passed; only the not-yet-implemented
    route APIs remained red.
- GREEN focused: `reports/report_1388/`
  - Result: exit `0`, Story126 `2/2` passed with no errors, failures, or
    warnings.
- Related GREEN: `reports/report_1390/`
  - Result: exit `0`, Story126, Story124 spillway traversal, Story125 spillway
    visual pass, and Story121 pincer suites passed `7/7`.
  - The Story124 texture assertion was updated to the Story125 dedicated
    spillway asset; no gameplay expectation was weakened.

## Asset Generation And Import

- Mode: built-in image generation followed by local chroma-key removal,
  slicing, normalization, and Godot import.
- Prompt intent: one coherent low S-curve mutated industrial leech in a strict
  `3x6` sheet, with rows for idle, crawl/run, attack tell, forward lunge,
  hurt, and death. The prompt requires a shared pivot/baseline, magenta
  background, wet charcoal-purple body, steel-blue shadows, rusted hardware,
  restrained toxic-green seams, and signal-red warning spines while excluding
  rat anatomy and environment props.
- Generation record:
  `assets/characters/factory_sluice_leech/source/factory_sluice_leech_sprite_sheet_imagegen_20260710.md`.
- RGB source:
  `assets/characters/factory_sluice_leech/source/factory_sluice_leech_sprite_sheet_imagegen_20260710.png`,
  `972x1619`.
- Alpha source:
  `assets/characters/factory_sluice_leech/source/factory_sluice_leech_sprite_sheet_alpha_20260710.png`,
  `972x1619` RGBA.
- Preview:
  `assets/characters/factory_sluice_leech/source/factory_sluice_leech_frames_preview_20260710.png`,
  `288x576` RGBA.
- Processing: border key `#fb03f9`, transparent/opaque thresholds `12/220`,
  common scale `0.302013`, x anchor `48`, and ground baseline y `88`.
- Runtime output: eighteen transparent `96x96` PNGs under
  `assets/characters/factory_sluice_leech/<animation>/`; each of `idle`,
  `run`, `attack_tell`, `attack`, `hurt`, and `death` has frames `_000` through
  `_002`.
- SpriteFrames:
  `assets/characters/factory_sluice_leech/factory_sluice_leech_sprite_frames.tres`.
- Godot 4.7 headless import exited `0`; runtime PNG imports use lossless mode,
  no mipmaps, alpha border fix, and nearest runtime filtering.

## Headless Runtime Smoke

- Script:
  `tests/smoke/old_factory_tailrace_exit_spillway_sluice_leech_skirmish_smoke.gd`.
- Log:
  `reports/old_factory_tailrace_exit_spillway_sluice_leech_skirmish_smoke.log`.
- Result: exit `0` with marker
  `old_factory_tailrace_exit_spillway_sluice_leech_skirmish_smoke=passed`.
- Coverage: Story124 gate, activation, objective label, 18-frame startup,
  active lunge, damage/defeat, cleared state, and restore contract.
- Log notes: only known Godot shutdown-time ObjectDB/resource cleanup messages
  appeared after the pass marker.

## Godot MCP Runtime Evidence

- Session: `cinderpaw@e40d`.
- Godot MCP: `2.9.1`; editor/runtime: Godot `4.7-stable`.
- A filesystem scan followed by a forced disk reload exposed the newly added
  node in the editor scene tree.
- Character scene inspection confirmed an `AnimatedSprite2D` root using
  `factory_sluice_leech_sprite_frames.tres` and
  `src/characters/factory_sluice_leech.gd`.
- Factory scene inspection confirmed:
  - node `FactoryTailraceExitSluiceLeech` at `(17760,482)`, initially hidden,
    z-index `20`;
  - entity id `2146` and family id `factory_sluice_leech`;
  - right wall `18120`, camera/background right `18140`, ground right edge
    `18240`, and `73` floor visuals.
- Typed live runtime evaluation after restoring Story124 and crossing x
  `17360` confirmed:
  - activation and active state were true;
  - route label was `Break Tailrace Sluice Leech`;
  - all six animation names existed with exactly three frames;
  - attack startup was `18` frames;
  - the active animation changed to `attack` and moved x by
    `-1.400390625` toward Cinderpaw;
  - hitbox id was `factory_sluice_leech_lunge` and the shared
    CollisionComponent path remained active.
- Typed defeat/restore evaluation confirmed damage succeeded, the enemy became
  hidden/inactive, the label changed to `Tailrace Sluice Leech Cleared`, all
  three Story126 state keys were true, Story124 crossed state was backfilled,
  and the Story119 Tailrace Relay checkpoint payload was unchanged.
- `project_run(mode=current, autosave=false)` reported
  `current_run_errors=[]`; the current game log contained only helper
  registration, and the cursor-scoped editor log had no new lines.
- MCP returned a non-empty `960x539` screenshot (original `1278x718`) showing
  Cinderpaw and the visible frame-animated Sluice Leech in the combat pocket.

## MCP Log Note

Three editor parse rows retained from an intermediate multi-step patch reported
that `_begin_factory_tailrace_exit_sluice_leech_pacing()` was missing before
that helper had been added. They predated the final filesystem scan and scene
reload. The final headless tests, smoke, current-run error set, game log, and
cursor-scoped editor log were clean; no current implementation error remained.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Entity, Story124 gate, activation threshold, labels, and route bounds | Focused GdUnit; MCP scene/eval | PASS |
| Distinct family, 18-frame tell, lunge, and CollisionComponent hit path | Focused GdUnit; smoke; MCP eval | PASS |
| Six three-frame transparent animations and required scenes/scripts | Image audit; import; focused GdUnit; MCP inspection | PASS |
| Defeat, persistence, backfill, and Tailrace Relay preservation | Focused GdUnit; smoke; MCP defeat/restore eval | PASS |
| Adjacent spillway and pincer behavior remains valid | `reports/report_1390/` | PASS |
| Current Godot run is clean and screenshot is non-empty | MCP logs and screenshot | PASS |
