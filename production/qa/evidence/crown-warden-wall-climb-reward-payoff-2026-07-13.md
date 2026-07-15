# Crown Warden Wall Climb Reward Payoff Evidence

> **Story**: 147
> **Date**: 2026-07-13
> **Verdict**: PASS

## Delivered Contract

- Boss4 death reveals one generated Crown Core through the shared
  `AbilityRewardSource`; active combat keeps it hidden and unavailable.
- Grounded player contact claims once. Missing `wall_climb` emits one normal
  unlock event; an already-unlocked Story135 save receives confirmation only.
- Exact `1.5s` feedback locks control, pulses the core and updates HUD/objective
  before returning control. Claimed restore never replays transient feedback.
- Arena, Central Tower and Main state preserve unrelated keys while receiving
  the current unlocked ability list.

## Automated Evidence

- RED: `reports/report_1554/results.xml`, valid nine-failure missing-contract
  baseline across three tests.
- Focused GREEN: `reports/report_1559/results.xml`, `3/3` passed.
- Bounded Story146/Story135 GREEN: `reports/report_1558/results.xml`, `9/9`
  passed with no Godot errors after the physics-frame route-monitor fix.
- Target smoke:
  `crown_warden_wall_climb_reward_payoff_smoke=passed`, exit `0`; Cinderpaw
  remained at ground height for the contact claim.
- Godot 4.7 import completed for source, alpha and runtime PNG without errors.

## MCP Evidence

Session `cinderpaw@13e3`, Godot `4.7-stable`, MCP `2.9.1`, final Run
`r7762730-6`:

- forced disk reload exposed 42 authored and 84 runtime nodes;
- both Cinderpaw and Crown Warden were live `AnimatedSprite2D` actors;
- pre-defeat reward was hidden/unavailable; defeat produced one visible core
  and one reveal VFX with objective `Claim Wall Climb`;
- real `move_right` input moved grounded Cinderpaw from
  `(220,551.99)` to `(633.33,551.99)` and naturally triggered the 128px claim;
- runtime diagnostics reported one claim, `wall_climb=true`, exact `1.5s`,
  `Wall Climb Unlocked` in HUD/objective and the imported generated texture;
- game logs contained only helper/DataManager info, `current_run_errors=[]`,
  and editor cursor `4 -> 4` added no rows;
- both captures are non-empty `1278x718` frames:
  `crown-warden-wall-climb-reward-revealed-mcp.png` and
  `crown-warden-wall-climb-reward-claimed-mcp.png`.

Structured evidence is retained in
`crown-warden-wall-climb-reward-payoff-mcp-run6.json`.

## Notes

The first MCP pass found the authored reward center was 108px above the
grounded player origin while the claim radius was only 100px. Runtime contact
was therefore impossible despite direct-call tests passing. The final scene
uses one matching 128px interaction/claim radius, and both smoke and MCP real
movement prove the corrected player path.

No full suite was run. Ending, credits, cinematic presentation and the next
post-Boss4 route are outside Story147.
