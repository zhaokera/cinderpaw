# QA Evidence: Old Factory Service Lift Frame Animation

> **Story**: Scene Management 028
> **Date**: 2026-07-19
> **Engine**: Godot 4.7 stable
> **Godot AI MCP**: 3.0.2
> **Result**: PASS

## Acceptance Surface

Story028 adds only the player-visible lift presentation. The original console,
shared endpoint, `96px` radius, Story026 input priority, SceneManager destination
and Story027 checkpoint selection remain authoritative.

## Asset Evidence

- Built-in image generation used the existing service-lift console for palette
  identity and the Deep Cistern ascender for structure.
- Exact prompt and processing record:
  `assets/environment/old_factory_service_lift/source/factory_service_lift_motion_sheet_imagegen_20260719.md`.
- Retained source is RGB `1254x1254`; the alpha intermediate contains exactly
  nine connected lift components.
- Runtime contains nine continuous-path, transparent sRGBA `384x384` PNGs.
  Components use shared scale `0.82`, center `x=192`, baseline `y=370` and
  nearest resampling. Transparent corners and dimensions were checked locally.
- `arrive_002`, `docked_idle_000` and `depart_000` intentionally share one
  docked image to remove transition jumps.
- Asset contract and manifest are recorded in
  `design/assets/specs/old-factory-service-lift-frame-animation.md` and
  `design/assets/asset-manifest.md`.

## Automated Evidence

| Run | Scope | Result |
|-----|-------|--------|
| `report_2040` | Intentional RED for missing `LiftAnimation` | Expected `1` failure, no parse error |
| `report_2041` | Initial lifecycle GREEN | `1/1` pass |
| `report_2042` | Animation, SceneManager, Story026 and Story027 related regression | `7/7` pass; GdUnit multi-suite process printed cleanup noise after successful exit |
| `report_2043` | Review regression for restored final departure frame | Expected failure exposed `stop()` resetting frame to `0` |
| `report_2044` | Focused post-fix lifecycle/restoration | `2/2` pass, clean exit |
| `report_2045` | Final animation + SceneManager + Story026 regression | `5/5` pass, zero errors/failures/flaky/skips/orphans, clean exit `0` |

Story027's three destination cases passed in `report_2042`; no Main route or
spawn-selection code changed after that run. No full suite was run.

## Godot MCP Runtime Evidence

Final accepted session/run: `cinderpaw@af5f` / `r364813803-125`.

1. MCP launched `res://scenes/factory_route_transition_shell.tscn` with
   `autosave=false`; helper became live with no launch errors.
2. The runtime node was `FactoryServiceLift/LiftAnimation` of class
   `AnimatedSprite2D`, with `texture_filter=1` and SpriteFrames path
   `res://assets/environment/old_factory_service_lift/factory_service_lift_sprite_frames.tres`.
3. First reveal reported `visual_state=arrive`, animation `arrive`, frame `0`,
   playing and visible. All three animation frame counts were `3`; loop modes
   were `arrive=false`, `docked_idle=true`, `depart=false`.
4. After the authored arrival duration, diagnostics reported looping
   `docked_idle`, frame `2`, playing, with the lift still activation-ready.
5. MCP confirmed `interact=false`, sent one real press and release from the
   actual floor interaction point `(1122,455)`, then observed in the same
   transition window: `activated=true`, `exit_requested=true`, pending
   `main/scrap_roost`, `visual_state=depart`, frame `1`, playing and activated
   tint.
6. Non-looping departure finished at frame `2` and stayed stopped. Godot saved
   a non-empty `1278x718` screenshot with error code `0`:
   `reports/visual/cinderpaw-mcp-old-factory-service-lift-frame-animation-20260719.png`.
   Visual inspection shows the actual riveted lift car, separate call console,
   readable prompt and visible player silhouette with no viewport clipping.
7. Current-run game logs contained one helper registration info line and no
   warning/error; editor logs contained `0` rows. MCP stop returned the editor
   to `ready`.

## Boundary Notes

- An earlier probe correctly rejected interaction as `provider_out_of_range`
  after gravity moved the player outside the existing radius; it did not start
  departure. Repositioning to the real floor interaction point passed without
  changing gameplay code.
- Restored `exit_requested=true` snapshots hold departure frame `2` stopped;
  repeated presentation sync cannot restart the non-looping departure.
- SceneManager still accepts the request before endpoint activation and
  departure animation; a rejected request remains docked and spawns no VFX.
