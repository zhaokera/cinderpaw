# Skill Tree Long Tail T1-A Choice Evidence

> **Story**: 149
> **Date**: 2026-07-14
> **Verdict**: PASS

## Delivered Contract

- `long_tail_t1a` is a 1 SP Long Tail T1-A modifier for `light_attack_1`.
- The runtime Skill Tree menu exposes Cat Claw and Long Tail as two selectable
  nodes and preserves the selected node while purchase state refreshes.
- Learning Extended Sweep adds `0.3` tile (`9.6px`) only to Long Tail light
  attack 1, producing the authored total `2.3` tiles (`73.6px`).
- Save restoration retains the learned node; Long Tail stage 2 and Cat Claw
  keep their existing authored ranges.

## Automated Evidence

- RED: `reports/report_1568/report_1/results.xml` failed on the intentionally
  missing HUD selection API.
- Focused GREEN: `reports/report_1569/report_1/results.xml`, `3/3` passed.
- Related GREEN: `reports/report_1570/report_1/results.xml`, `8/8` passed across
  Story149, Story018 Cat Claw, and the Long Tail weapon contract.
- Fresh post-warning-fix focused GREEN: `reports/report_1571/results.xml`,
  `3/3` passed with exit code `0`.
- The related and final focused GdUnit processes emitted exit-time
  ObjectDB/resource leak warnings after all assertions passed; no
  gameplay/runtime error was reported and the bounded MCP launch below was
  clean.

## MCP Evidence

Godot `4.7-stable`, Godot AI MCP plugin/server `2.9.2`, session
`cinderpaw@d40a`:

- `project_run(mode=main)` launched `res://scenes/main.tscn` with the game helper
  live and `current_run_errors=[]`.
- Runtime evaluation opened the Skill Tree, confirmed the initial
  `cat_claw_t1a` selection, moved to `long_tail_t1a`, purchased it for exactly
  1 SP, and retained `SP 1 | Node 2/2` plus the learned presentation.
- A live Long Tail first attack returned `weapon=long_tail`, `combo_index=0`,
  `attack_range=2.3`, `skill_range_tiles=0.3`, `skill_range_px=9.6`, and a Core
  hitbox width of `73.5999984741211px` (float representation of `73.6px`).
- The first editor inspection exposed one shadowed-parameter warning in the new
  HUD navigation helper. The parameter was renamed, logs were cleared, and a
  fresh MCP launch (`r843635-2`) returned zero editor rows and three info-only
  game rows.
- `skill-tree-long-tail-t1a-choice-mcp.png` is a non-empty `1278x718` game
  capture showing Cinderpaw's running game, `Skill Tree`, `Node 2/2`, Long Tail
  T1 Extended Sweep, and its learned state.

Structured values are retained in
`skill-tree-long-tail-t1a-choice-mcp-run1.json`.

## Scope Note

No full suite was run. No new bitmap asset was needed: this bounded UI/gameplay
slice reuses the existing image-generated HUD and Cinderpaw assets. Final node
icon generation remains with the eventual graph-layout story.
