# Crown Warden Victory Recall To Scrap Roost Evidence

> **Story**: 148
> **Date**: 2026-07-13
> **Verdict**: PASS

## Delivered Contract

- Boss4 defeat plus Crown Core claim reveals one generated right-side recall
  transmitter while preserving the existing left Apex Approach return.
- Recall persists the exact Boss4 proof before requesting `main / scrap_roost`;
  rejected persistence or scene requests remove the proof.
- MainScene accepts only the complete proof at the exact target, places
  Cinderpaw at the existing Scrap Roost, discovers it, records the secured flag
  and shows one return acknowledgement. This is not an ending or credits flow.

## Automated Evidence

- RED: `reports/report_1560/results.xml`, three focused tests with nine expected
  missing-contract failures.
- Final bounded GREEN: `reports/report_1564/results.xml`, `16/16` passed across
  the Story148 suite and immediate Story147/146/145/Scrap Roost regressions.
- Persistence correction RED: `reports/report_1565/results.xml` reproduced the
  restored Rat King visibility, collisions and Boss HUD with four expected
  failures. Final related GREEN: `reports/report_1567/results.xml`, `13/13`
  passed across Story148, Rat King runtime/rewards and Boss2 HUD focus.
- Target smoke:
  `crown_warden_victory_recall_to_scrap_roost_smoke=passed`, exit `0`.
  The real SceneManager arrived at `main / scrap_roost`, preserved full proof,
  discovered the savepoint and emitted the victory-return notice.
- Godot 4.7 imported the retained source, alpha intermediate and transparent
  `256x384` runtime transmitter before final verification.

## MCP Evidence

Session `cinderpaw@13e3`, Godot `4.7-stable`, Godot AI MCP `2.9.1`, final Run
`r21750636-14`:

- the validation sequence force-reloaded the arena from disk and confirmed all
  47 authored nodes, including Cinderpaw/Crown Warden `AnimatedSprite2D`
  actors and the complete `CrownVictoryRecallRoute` subtree;
- restored post-victory state showed both route choices, the generated imported
  texture and objective `Choose Scrap Roost Recall or Apex Return`;
- a full prior-progression fixture retained all eight abilities plus Rat King
  and Echo Guardian defeat/reward flags before entering the Boss4 arena;
- Cinderpaw entered the authored 104px range at `(1122,536)`, 58px from the
  recall transmitter;
- physical `E` input triggered the project's `interact` mapping and completed
  the runtime swap to `main / scrap_roost`;
- Main diagnostics reported complete recall proof, secured flag, existing Scrap
  Roost savepoint and `Crown secured - returned to Scrap Roost`;
- restored Rat King and Echo Guardian actors were both hidden, Rat King
  collision layer/mask were `0/0`, and the Boss HUD stayed hidden;
- the arrival notification duration was extended only while capturing evidence
  so the MCP framebuffer delay could not hide the already-observed notice;
- current game logs contained only helper/DataManager info, launch reported
  `current_run_errors=[]`, and editor cursor `4 -> 4` added no rows;
- both captures are non-empty `1278x718` frames:
  `crown-warden-victory-recall-available-mcp.png` and
  `crown-warden-victory-recall-scrap-roost-arrival-mcp.png`.

Structured evidence is retained in
`crown-warden-victory-recall-to-scrap-roost-mcp-run14.json`.

## Scope Note

No full suite was run. Boss5, final-Boss language, ending, credits and new hub
content remain outside Story148.
