# QA Evidence: Underground Corrosion Channel Skirmish

## Scope

Story131 expands `area_04_underground_passage` from one empty viewport to a
`2560x720` traversal/combat slice with generated visuals, corrosive contact
damage, two frame-animated Sluice Leeches, combat seals, a one-shot salvage
reward, SceneManager persistence, sewer music/ambience requests, and the
existing Factory return contract.

## Automated Evidence

- RED: `reports/report_1426/results.xml` recorded all three missing Story131
  contracts before implementation (`28` expected assertion failures).
- Final focused GREEN: `reports/report_1432/results.xml` passed `3/3`, with zero
  errors, failures, flaky cases, skipped cases, or orphan nodes.
- Bounded related GREEN: `reports/report_1429/results.xml` passed `7/7` across
  Story131, Story130 Factory/Underground handoff, and Story126 Sluice Leech.
- Targeted SceneManager smoke:
  `reports/underground_corrosion_channel_skirmish_smoke.log` exited `0` with
  `underground_corrosion_channel_skirmish_smoke=passed`. It covered Factory
  aerial breach, Underground activation, a real Core light-attack hit, dual
  defeat, cache claim, Factory return, Underground re-entry, and restored claim.
- The smoke printed its pass marker before the known short-lived test-process
  cleanup report (`8` ObjectDB instances / `3` resources); no gameplay assertion
  or runtime parse error preceded the marker.

## Asset Evidence

- Built-in image generation produced one opaque background and three isolated
  magenta-keyed props. Source, retained alpha, prompt intent, processing, and
  runtime paths are recorded in the four generation records and asset spec.
- Runtime contracts verified by GdUnit and ImageMagick:
  - background `1280x720`, opaque RGB;
  - runoff `512x160`, transparent RGBA;
  - seal `256x384`, transparent RGBA;
  - salvage cache `256x256`, transparent RGBA.
- Godot 4.7 headless import exited `0` and created import metadata for all source,
  alpha, and runtime PNGs.

## Godot MCP Evidence

- Session: `cinderpaw@e40d`
- Engine: Godot `4.7-stable (official)`
- Plugin/server: Godot AI MCP `2.9.1`
- Disk authority: target scene force-reloaded with `reloaded_from_disk=true`.
- Editor hierarchy: `56` authored nodes, including both backgrounds, three
  stepping platforms, runoff Area2D, two seals, two Sluice Leech
  `AnimatedSprite2D` instances, salvage cache, Cinderpaw, HUD, and return route.
- Runtime hierarchy: `90` nodes, including dynamically mounted player
  Combat/Collision/Weapon components and enemy Health/Collision/Combat/Status
  components.
- Final run token `27` launched live with `current_run_errors=[]`.
- Real input moved Cinderpaw across the traversal to x `1510.93`; encounter
  activation closed the rear seal at x `1370`, safely behind the player, and
  kept both frame-animated enemies visible inside the arena.
- The locked cache prompt was `visible=false`; the final non-empty `1278x718`
  screenshot showed Cinderpaw, both generated seals, both Sluice Leeches, the
  generated channel background, objective, and HUD without overlap or clipped
  cache text.
- Current game log contained only the MCP helper registration. Editor log reads
  after cursor `3` returned no new rows.
- Three retained Old Factory parse rows were explicitly marked
  `recent_errors_may_predate_run=true`; they predated run token `27` and did not
  recur after cursor `3`.

## Verdict

PASS. Story131 is playable, player-visible, persistent, and verified at the
focused, related, SceneManager smoke, asset-import, and MCP runtime levels.
