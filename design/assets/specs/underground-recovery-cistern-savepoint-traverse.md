# Asset Spec: Underground Recovery Cistern Savepoint Traverse

## Scope

Story132 extends the Underground Passage into a third gameplay viewport with a
fair recovery relay before a lethal platform gap and a visible deep-route
endpoint on the far ledge. It reuses the completed Cinderpaw frame animation
and introduces no new character family.

## Runtime Assets

| Asset | Runtime path | Contract |
|-------|--------------|----------|
| Recovery cistern background | `assets/environment/underground_passage/env_underground_recovery_cistern_1280x720.png` | Opaque RGB, exact `1280x720`, side-view left ledge, central pit, and right ledge |
| Recovery relay | `assets/environment/underground_passage/prop_underground_recovery_relay_256x256.png` | Transparent RGBA, exact `256x256`, amber/cyan savepoint landmark |
| Deep-route endpoint | `assets/environment/underground_passage/prop_underground_deep_route_endpoint_256x384.png` | Transparent RGBA, exact `256x384`, tall open pressure-door frame |

## Visual Direction

- Continue charcoal masonry, corroded steel, oxidized copper, cyan mineral
  light, and amber work-light contrast from the first two Underground rooms.
- The background must communicate a real lethal drop without hiding authored
  collision or placing foreground art over Cinderpaw.
- The relay uses an amber recovery core and a compact paw-scale silhouette.
  The endpoint uses a taller cyan vertical read so the two interactions cannot
  be mistaken for one another.
- Toxic yellow-green remains below the playable surfaces. No baked UI, text,
  characters, enemies, cast shadows on keyed props, or collision placeholders.

## Scene Layout

- Third background center: `(3200,360)`; route bounds: `0..3840`.
- Recovery relay and respawn marker: `(2720,576)`.
- Gap: x `2860..3340`; stepping platforms: `(2940,520)`, `(3100,442)`,
  `(3260,520)`; fall zone center `(3100,672)`.
- Deep-route endpoint: `(3680,568)`; right wall: x `3820`.

## Godot Integration

- The background and both props use `Sprite2D` with nearest filtering.
- `RecoveryRelay` uses `SavepointRuntime`; the generated relay is visible after
  Story131 clear and its collision is disabled after one activation.
- `DeepRouteEndpoint` is controlled by
  `UndergroundRecoveryCisternController` and accepts the player only after the
  relay is active.
- Existing Cinderpaw remains `AnimatedSprite2D + SpriteFrames`; death, revive,
  jump, fall, and traversal states reuse the imported multi-frame animations.

## Generation Records

- `assets/generated/source/underground_recovery_cistern_imagegen_20260711.md`
- `assets/generated/source/underground_recovery_relay_imagegen_20260711.md`
- `assets/generated/source/underground_deep_route_endpoint_imagegen_20260711.md`
