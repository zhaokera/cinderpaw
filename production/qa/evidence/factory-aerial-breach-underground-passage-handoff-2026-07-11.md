# QA Evidence: Factory Aerial Breach Underground Passage Handoff -- 2026-07-11

## Scope

Story130 adds the first post-Boss3 ability gate and destination. A real nearby
`aerial_attack` activation opens a generated cracked Factory floor once,
persists it, and swaps into a generated Underground Passage. The destination
preserves the ability and returns to the exact Factory breach marker. Enemies,
hazards, collectibles, savepoints, and further Underground rooms are Story131+
scope.

## Automated Evidence

- Expected RED: `reports/report_1421/`
  - The first discovered case produced the expected missing Underground scene,
    registry/schema, generated art, Factory gate, and diagnostics failures.
- First focused GREEN: `reports/report_1422/`
  - Both authored-contract and runtime/persistence tests passed `2/2`.
- Smoke-driven regressions:
  - The first route smoke exposed that Factory state preserved `aerial_attack`
    but the destination state did not receive it. The request now merges the
    current ability list into Underground state before swap.
  - The next smoke reached Factory return and exposed that SceneManager's cached
    Factory instance retained the original gate VFX. Local-state restore now
    finishes active feedback without incrementing its historical spawn count.
- Final focused GREEN: `reports/report_1423/`
  - Story130 passed `2/2`, including target-state ability handoff and same-node
    cached restore with no active/replayed VFX.
- Final bounded adjacent GREEN: `reports/report_1424/`
  - Story130, Story129 reward/aerial runtime, Story127 arena handoff, shared
    ExplorationGate feedback, and Factory route roundtrip passed `11/11` with
    zero failures/errors/flaky/skipped/orphans.

## Asset Generation And Import

- Built-in image generation produced an opaque `1672x941` Underground source
  and an isolated `1774x887` magenta-keyed cracked floor source.
- The Underground source became an opaque `1280x720` runtime background.
- The floor sampled key `#fb03f9`, used soft matte `12/220` plus despill, and
  became a transparent `384x160` runtime prop.
- Records:
  `assets/generated/source/underground_passage_entry_imagegen_20260711.md` and
  `assets/generated/source/factory_aerial_breach_floor_imagegen_20260711.md`.
- Spec: `design/assets/specs/factory-aerial-breach-underground-passage.md`.
- Godot 4.7 import exited `0`; all five source/alpha/runtime PNGs produced import
  metadata and loaded through their scene references.

## Headless Runtime Smoke

- Script: `tests/smoke/factory_aerial_breach_underground_passage_handoff_smoke.gd`.
- Log: `reports/factory_aerial_breach_underground_passage_handoff_smoke.log`.
- Final result: exit `0` with marker
  `factory_aerial_breach_underground_passage_handoff_smoke=passed`.
- Coverage: actual SceneManager runtime root; Factory unlockable gate; real
  airborne attack activation; one VFX; Factory -> Underground exact spawn;
  generated destination; ability preservation; Underground -> Factory exact
  return marker; open breach persistence; no stale transition latch/VFX.
- Final shutdown emitted only the project's known cleanup-time ObjectDB/resource
  messages after the pass marker.

## Godot MCP Runtime Evidence

- Session `cinderpaw@e40d`; Godot `4.7-stable (official)`; Godot AI MCP
  plugin/server `2.9.1`.
- MCP filesystem scan settled successfully. Factory was then opened twice so
  the already-open editor tab was explicitly reloaded from disk.
- Factory editor inspection found
  `FactoryTailraceUndergroundAerialBreach` and
  `FactoryTailraceUndergroundReturnSpawn`. Gate properties resolved script
  `exploration_gate.gd`, id `factory_tailrace_underground_aerial_breach`,
  required ability `aerial_attack`, target `area_04_underground_passage`,
  radii `104/208`, and the authored locked/unlockable prompts.
- Gate visual resolved the imported generated floor texture at
  `res://assets/environment/underground_passage/prop_factory_aerial_breach_floor_384x160.png`.
- Factory run token `23` reported `current_run_errors=[]`; runtime gate metadata
  reported `locked`, `aerial_attack`, and the Underground target. Its game log
  contained only helper registration.
- Underground editor hierarchy contained `26` nodes: generated background,
  bounded floor/walls, entry marker, Cinderpaw `AnimatedSprite2D`, Camera2D,
  return route, objective, and HUD. The background resolved the exact imported
  `1280x720` texture and return route resolved Factory spawn
  `tailrace_underground_return`.
- Underground run token `24` reported a `47`-node runtime tree after shared
  player/HUD components initialized. A non-empty `1278x718` screenshot showed
  Cinderpaw, the generated cracked return landmark, readable return prompt,
  objective, HUD, and the full generated Underground scene without overlap.
- Run token `24` reported `current_run_errors=[]`; game log contained only
  helper registration; editor logs after cursor `3` contained no new rows.
  Three retained Old Factory parse rows were explicitly marked pre-run and did
  not recur in Story130's current runs.

## Acceptance Mapping

| Acceptance | Evidence | Result |
|------------|----------|--------|
| Locked/unlockable aerial floor gate | Story130 focused test; MCP Factory properties/runtime metadata | PASS |
| Real aerial activation opens once with one VFX | Story130 focused test; bidirectional smoke; adjacent gate suite | PASS |
| Open state and abilities survive cached/new restores | Story130 focused test; smoke | PASS |
| Factory -> Underground -> Factory exact handoff | Focused fake-manager contract; real SceneManager smoke | PASS |
| Generated authored destination and route landmark | Asset records/spec/import; MCP hierarchy/screenshot | PASS |
| Godot 4.7 / MCP 2.9.1 current runs are clean | MCP run tokens 23/24; game/editor logs | PASS |
