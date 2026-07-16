# QA Evidence: Crown Observatory Wall-Climb Epilogue Ascent

> **Story**: Player Abilities 172
> **Date**: 2026-07-17
> **Engine**: Godot 4.7 stable
> **Godot AI MCP**: plugin/server 3.0.2

## Scope

- Boss4 reward-gated Crown Observatory epilogue route.
- Real `PlayerController.wall_climb_started` proof and durable checkpoint.
- Post-Boss fall/death recovery without Boss or reward reset.
- One-shot endpoint completion and delayed Scrap Roost Recall availability.
- Generated `1280x720` second viewport and `2560x720` camera/scene framing.

## Automated Evidence

- Initial RED: `reports/report_1878/results.xml`, `1/1` expected failure with
  four missing Story172 controller/asset artifacts.
- Focused GREEN: `reports/report_1881/results.xml`, `1/1` passed after the test
  established the physical `16px` post-respawn settling tolerance.
- Related Story147/148 regression: `reports/report_1884/results.xml`, `6/6`
  passed after replacing the old immediate-Recall expectation.
- Final pre-commit bounded gate: `reports/report_1886/report_1/results.xml`, `7/7`, zero errors,
  failures, flaky cases, skips or orphans; exit code `0`.
- Updated Story147/148 smoke scripts: Godot `--check-only --script` passed for
  both files; no additional runtime smoke was run because the MCP acceptance
  below covers the visible route.
- `git diff --check` passed for the complete Story172 file set.

## MCP Runtime Evidence

- Session: `cinderpaw@af5f`.
- Final run: `r191067492-57`; helper live, run state `live`, then clean stop to
  editor readiness `ready`.
- Runtime diagnostics:
  - generated background present at the expected imported path;
  - camera right limit `2560`;
  - route, checkpoint, completion area and fall zone present;
  - completion and wall-climb proof restored `true`;
  - objective `Recall to Scrap Roost`;
  - Recall visible and available only in completed state.
- Runtime tree contains `EntryWall`, `EntryPlatform`, `LowerLanding`,
  `MidPerch`, `SignalSpine`, `SignalPlatform`, `CompletionArea`, `FallZone`,
  endpoint and checkpoint markers under the Story172 controller.
- Cinderpaw runtime node is visible `AnimatedSprite2D` using
  `cinderpaw_sprite_frames.tres`; generated background is a visible `Sprite2D`
  using the exact Story172 texture.
- Final MCP game screenshot: non-empty `1278x718`; it visibly contains the
  generated Observatory extension, open shaft, staggered ledges, magnetic
  signal spine, Cinderpaw and upper Recall transmitter. Recall was moved left
  after the first screenshot exposed HUD overlap; the final frame has no HUD/
  prompt overlap, blank plate, magenta key or block-color placeholder art.
- Final run logs: three info-only game lines (MCP helper and two data domains),
  zero game warnings/errors, zero editor log entries, zero dropped lines.

## Asset Evidence

- Retained source:
  `assets/generated/source/crown_observatory_epilogue_ascent_imagegen_20260717.png`.
- Exact prompt, processing and hashes:
  `assets/generated/source/crown_observatory_epilogue_ascent_imagegen_20260717.md`.
- Runtime texture:
  `assets/environment/crown_warden_arena/env_crown_observatory_epilogue_ascent_1280x720.png`.
- Asset spec, manifest and entity inventory all record the imported route.

## Result

PASS. Story172 satisfies its generated-art, traversal, persistence, recovery,
Recall-gating and MCP runtime acceptance criteria.
