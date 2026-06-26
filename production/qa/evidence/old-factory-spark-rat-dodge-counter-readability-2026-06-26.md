# QA Evidence: Old Factory Spark Rat Dodge-Counter Readability

> Story: `production/epics/player-abilities/story-015-old-factory-spark-rat-dodge-counter-readability.md`
> Date: 2026-06-26
> Result: PASS

## Scope

Story015 connects the existing Factory Spark Rat `attack_tell` readability slice
to the player's dodge i-frame and Cat Claw counter systems. The player can now
read the red Spark Rat tell, dodge the active bite without taking damage, finish
the dodge into the existing 30-frame counter window, and land a Cat Claw hit
that injects and consumes the existing `claw_counter_crit_window_bonus_frames`
metadata.

Post-review tightening made the scene bite resolver stricter: the Spark Rat bite
only resolves during the enemy's active attack frames, each attack sequence can
deal damage or be dodged once, and visible dodge damage immunity now follows the
Core `CombatComponent` i-frame window instead of treating the entire visible
dodge state as invincible. The visible player dodge duration was aligned with
the existing Core dodge total so presentation and combat state finish together;
the Core i-frame and counter-window tuning was not changed.

No new visual asset was generated for this story. It reuses the Story013/014
image-generated Factory Spark Rat character and `attack_tell` frame animation.

Out of scope remained unchanged: no patrol pacing, NavigationAgent2D, patrol
splines, new rooms, Boss2, hidden boss, savepoints, minimap, skill-tree UI, SFX,
shaders, loot/economy, or full enemy AI rewrite.

## Automated Tests

RED:

- `reports/report_691/`
- Command:
  `godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit/gameplay/old_factory_spark_rat_dodge_counter_readability_test.gd --ignoreHeadlessMode`
- Expected failure: `OldFactoryEntranceScene` did not yet expose
  `resolve_factory_spark_rat_bite_against_player()` or
  `get_factory_spark_rat_counter_diagnostics()`.
- Post-review refinement RED: `reports/report_698/` failed because duplicate
  same-sequence bite resolution preserved no damage but still overwrote the last
  valid bite diagnostics. The fix preserves the last valid diagnostics while
  marking `last_bite_already_resolved=true`.

GREEN focused:

- `reports/report_699/`
- Result: `5/5` passed.
- Coverage: Spark Rat bite resolved during player dodge i-frames applies no
  damage, finishing the dodge opens the 30-frame Cat Claw counter window, Cat
  Claw hit injects and consumes `claw_counter_crit_window_bonus_frames = 3`, and
  non-dodged Spark Rat bite applies the existing 9 damage contract. The suite
  also covers visible dodge frames before Core i-frames still taking damage,
  active-frame-only bite resolution, and one bite resolution per attack
  sequence.

Related combat / Spark Rat regression:

- `reports/report_700/`
- Result: `27/27` passed.
- Suites: Story015, Story014 attack tell feedback, Story013 Spark Rat patrol
  encounter, Combat dodge i-frames, Cat Claw counter crit, player dodge
  animation, and MainScene dodge afterimage routing.

Broader Old Factory scene regression:

- `reports/report_701/`
- Result: `37/37` passed.
- Suites: Story015, Story014, Story013, deep route unlock feedback, deep guard
  activation pacing, deep route micro-slice, entrance combat slice, room-clear
  cache, and steam vent hazard route.

## Godot Import and Headless Smoke

Import:

- Command: `godot --headless --path . --import --quit`
- Result: exit `0`.
- Note: headless editor reported `MCP | plugin disabled in headless mode`, which
  is expected for CLI import.

Headless smoke:

- Factory scene:
  `godot --headless --path . --scene res://scenes/factory_route_transition_shell.tscn --fixed-fps 60 --quit-after 3 --log-file reports/old_factory_spark_rat_dodge_counter_factory_scene_smoke.log`
- Main scene:
  `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 3 --log-file reports/old_factory_spark_rat_dodge_counter_main_scene_smoke.log`

Result:

- Both smoke commands exited `0`.
- Keyword scans found no script parse, invalid call, missing resource, or
  resource-load errors in either log.
- The shell output still included the known Godot cleanup-time ObjectDB/resource
  messages at process exit. The written log files were clean for runtime
  script/resource errors.

## Godot MCP Runtime Evidence

MCP connection:

- Session: `cinderpaw@c1b2`
- Godot: `4.6.3-stable`
- Scene: `res://scenes/factory_route_transition_shell.tscn`
- Run mode: current scene, `autosave=false`

Runtime probes:

- `FactorySparkRat/Sprite` is `AnimatedSprite2D`.
- SpriteFrames path:
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
- `attack_tell` has `3` frames and `loop=false`.
- `request_attack()` returned `true`.
- Startup animation immediately after request: `attack_tell`.
- Active-frame animation after `advance_attack_frames(7)`: `attack`.
- Deep route activation, endpoint open, and Spark Rat activation all returned
  `true`.
- Resolving during `attack_tell` returned `resolved=false` and applied no
  damage.
- Resolving during active bite without dodge applied exactly `9` damage
  (`100 -> 91`); repeated same-sequence resolution returned
  `already_resolved=true`, applied no additional damage, and preserved the last
  valid bite diagnostics with `last_bite_damage=9`,
  `last_bite_resolved=true`, and `last_bite_weapon_id=factory_spark_rat_bite`.
- Player dodge started and Core combat i-frame was active at frame 3.
- Spark Rat bite resolution returned `dodged=true`,
  `damage_applied=false`, `weapon_id=factory_spark_rat_bite`, `source=factory_spark_rat`,
  and kept player HP `100 -> 100`.
- Repeating the already resolved dodged bite did not apply damage and preserved
  the successful dodged-bite diagnostics.
- After finishing the dodge, counter diagnostics reported
  `counter_ready=true`, `counter_window_frames=30`,
  `last_bite_dodged=true`, and
  `last_bite_weapon_id=factory_spark_rat_bite`.
- Cat Claw hit during the counter window dealt Spark Rat HP `24 -> 12`, emitted
  `crit_window_bonus=3`, emitted
  `claw_counter_crit_window_bonus_frames=3`, and consumed the counter window to
  `0`.
- MCP game/editor logs had no runtime errors after the probe.

Screenshot:

`reports/visual/cinderpaw-mcp-old-factory-spark-rat-dodge-counter-readability-20260626.png`

The screenshot captures the Old Factory runtime with the generated Factory
Spark Rat art visible in the combat route, rather than an empty scene or
placeholder-only gameplay.
