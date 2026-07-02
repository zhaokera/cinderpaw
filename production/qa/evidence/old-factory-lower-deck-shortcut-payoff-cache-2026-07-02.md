# QA Evidence: Old Factory Lower Deck Shortcut Payoff Cache

Date: 2026-07-02
Story: `production/epics/player-abilities/story-056-old-factory-lower-deck-shortcut-payoff-cache.md`
Engine: Godot `4.7.stable.official.5b4e0cb0f`
MCP session: `cinderpaw@4400`, Godot MCP plugin/server `2.8.1`

## Scope

Story056 adds a once-only shortcut payoff cache after Story055 opens the
lower-deck shortcut seal. The cache is hidden before
`factory_lower_deck_shortcut_unlocked=true`; once open, it shows `+15 Gears`,
uses source `old_factory_lower_deck_shortcut_cache`, and keeps the service lift
available with prompt `Call lift`.

## Asset Evidence

No new visual assets were generated for this story.

- Reused existing image-generated lower-deck cache texture:
  `res://assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`.
- This story does not add or rework any player-visible character animation, so
  the `AnimatedSprite2D + SpriteFrames` character-frame rule is not newly
  triggered.

## Automated Verification

Focused RED:

```text
reports/report_1045/
Exit: 100
Expected failure: shortcut reward cache diagnostics and claim API did not exist.
Result: 2/2 failing
```

Focused GREEN:

```text
reports/report_1046/
Story056: 2/2 passed
Errors: 0
Failures: 0
Flaky: 0
Skipped: 0
Orphans: 0
```

Related regression:

```text
reports/report_1047/
Suites:
- old_factory_lower_deck_shortcut_reward_cache_test.gd
- old_factory_lower_deck_shortcut_seal_test.gd
- old_factory_lower_deck_exit_ambush_test.gd
- old_factory_lower_deck_skirmish_cache_test.gd
- old_factory_service_lift_scene_manager_exit_test.gd
- factory_route_runtime_roundtrip_test.gd

Result: 10/10 passed
Errors: 0
Failures: 0
Flaky: 0
Skipped: 0
Orphans: 0
```

Headless smoke:

```text
reports/old_factory_lower_deck_shortcut_payoff_cache_smoke.log
Scene: res://scenes/factory_route_transition_shell.tscn
Exit: 0
Keyword scan: no SCRIPT ERROR, Parse Error, Invalid call, Invalid access,
Resource file not found, Failed loading resource, ERROR, FATAL, or WARNING
entries in the log file.
```

The terminal still printed the known Godot cleanup-time ObjectDB/resource
messages at process exit; the smoke log did not contain project script/resource
errors.

## MCP Runtime Evidence

Steps:

1. Activated MCP session `cinderpaw@4400`.
2. Confirmed Godot `4.7-stable (official)`.
3. Cleared MCP game/editor logs.
4. Ran `res://scenes/factory_route_transition_shell.tscn` through MCP with
   `autosave=false`; `project_run` returned `recent_errors=[]`.
5. Set Old Factory local state to the post-Story055 contract:
   lower-deck exit ambush defeated, shortcut guard defeated, and lower-deck
   shortcut unlocked.
6. Read cache, shortcut, service-lift, claim, duplicate-claim, feedback, and
   local-state diagnostics.
7. Captured a non-empty game screenshot and read current game/editor logs.
8. Stopped the running project.

Observed unlocked shortcut payoff cache:

- `FactoryLowerDeckShortcutRewardCache` present and visible.
- `available=true`.
- `claim_available=true`.
- `claimed=false`.
- `cache_id="old_factory_lower_deck_shortcut_cache"`.
- Prompt text: `+15 Gears`.
- Texture:
  `res://assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`.
- Position: `(1188, 310)`.
- Shortcut state:
  `factory_lower_deck_shortcut_unlocked=true`,
  `factory_lower_deck_shortcut_guard_defeated=true`,
  `collision_blocking=false`.
- Service lift remained available with prompt `Call lift`.

Observed claim behavior:

- First claim: `true`.
- Duplicate claim: `false`.
- Reward payload:
  `cache_id="old_factory_lower_deck_shortcut_cache"`,
  `source="old_factory_lower_deck_shortcut_cache"`,
  `gears=15`.
- Feedback:
  `Shortcut Cache Claimed +15 Gears`.
- Route label:
  `Shortcut Cache Claimed +15 Gears`.
- Local state persisted:
  `factory_lower_deck_shortcut_reward_cache_claimed=true`.
- Existing lower-deck progression remained restored:
  `factory_lower_deck_exit_ambush_defeated=true`,
  `factory_lower_deck_shortcut_guard_defeated=true`.

Runtime logs:

- Game logs after the runtime probe contained only the MCP helper registration
  line.
- Editor logs after the runtime probe were empty.
- Final MCP state after stop: project not playing, editor readiness `ready`.
