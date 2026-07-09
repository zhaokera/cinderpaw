# QA Evidence: Old Factory Forward Pressure Aftershock Exhaust Escape Skirmish

Date: 2026-07-09
Engine: Godot 4.7
Godot AI MCP: 2.9.1

## Scope

Story091 adds the Story090-gated aftershock exhaust escape skirmish: Spark Rat
entity `2134` and Coil Rat entity `2135` activate at x `3112.0` after the
aftershock exhaust breaker is cut, use existing frame-animation assets, persist
partial/full defeat, and preserve the Story074 exit relay savepoint contract.

## Automated Tests

- Initial focused RED:
  `reports/report_1212/`
  - Expected failures: Story091 diagnostics/APIs/local state and scene nodes did
    not exist.
- Focused GREEN:
  `reports/report_1213/`
  - `2/2` Story091 tests passed.
- MCP-discovered stale-reference RED:
  `reports/report_1215/`
  - `errors=4` after both enemies were defeated and local state was restored.
- Final focused GREEN:
  `reports/report_1216/`
  - `2/2` Story091 tests passed after valid-node diagnostics hardening.
- Related regression:
  `reports/report_1217/`
  - `39/39` related gameplay tests passed, covering Story091 plus the adjacent
    aftershock exhaust chain, Story074 service-lift/relay contracts, no-loss
    respawn, Story068 no-replay, Story071 audio no-replay, and steam hazard
    coverage.

## Headless Smoke

Command:

```bash
"/Applications/Godot 2.app/Contents/MacOS/Godot" --headless --path . --scene res://scenes/factory_route_transition_shell.tscn --fixed-fps 60 --quit-after 3 --log-file reports/old_factory_forward_pressure_aftershock_exhaust_escape_skirmish_smoke.log
```

Result: exit `0`. Keyword scan found no project script/parse/invalid-call/
invalid-access/missing-resource/resource-load/shadowed-variable errors in
`reports/old_factory_forward_pressure_aftershock_exhaust_escape_skirmish_smoke.log`.

## Godot MCP Runtime Evidence

- Godot AI MCP `2.9.1`, Godot `4.7-stable`, scene
  `res://scenes/factory_route_transition_shell.tscn`, helper live.
- MCP scene/property checks found
  `FactoryLowerDeckForwardPressureAftershockExhaustEscapeSkirmishSparkRat`
  and `FactoryLowerDeckForwardPressureAftershockExhaustEscapeSkirmishCoilRat`
  as hidden `CharacterBody2D` nodes with `AnimatedSprite2D` children wired to
  the Factory Spark Rat and Factory Coil Rat SpriteFrames resources.
- Runtime activation confirmed entities `2134/2135`, visible enemies,
  target/process/physics enabled, frame counts `3` for
  `idle/run/attack_tell/attack/hurt/death`, opening grace frames `10/22`, and
  route feedback `Break Aftershock Exhaust Escape`.
- MCP game screenshot returned non-empty image metadata `960x539` and showed the
  active escape skirmish on the Old Factory lower-deck backdrop.
- Runtime clear probe returned `apply_damage(2134, 999)=true` and
  `apply_damage(2135, 999)=true`; diagnostics then showed both enemies hidden,
  process/physics disabled, persisted
  `activated/spark_defeated/coil_defeated/cleared=true`, and resynced
  completed state after `set_local_state(get_local_state())`.
- Final MCP logs: game log contained only the helper registration line; editor
  log returned zero lines.

## Notes

No new visual or audio assets were generated. Story091 reuses imported,
image-generated Factory Spark Rat and Factory Coil Rat frame-animation assets,
including transparent 96x96 `idle`, `run`, `attack_tell`, `attack`, `hurt`,
and `death` frames.
