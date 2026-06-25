# Visual Entity & Screen Inventory

> Generated: 2026-06-23
> Sources: design/gdd/systems-index.md, design/art/art-bible.md, design/gdd/feline-combat.md, design/gdd/weapon-styles.md, design/gdd/boss-config.md, design/gdd/exploration-ability-gating.md, design/gdd/health-death.md, design/gdd/hud-ui.md, design/gdd/map-system.md, design/gdd/scene-management.md, design/gdd/charm-equipment.md, design/gdd/status-effects.md, design/gdd/death-respawn.md, design/gdd/npc-dialogue.md

## Generation Policy

All new visual assets in this inventory should be produced from image2 / image generation prompts first, then imported through the Godot asset pipeline with Art Bible constraints:

- Character sprites: 64x64 base frames, pixel art, nearest filtering, AtlasTexture-friendly sheets.
- Boss sprites: up to 96x96 frames or modular larger assemblies when required.
- Tiles: 16x16 base tiles, PNG-32 where alpha is required.
- Props and pickups: 32x32 base art unless a GDD requires a smaller HUD icon.
- UI icons: 24x24 source icons with 16x16 HUD derivatives where needed.
- VFX: sprite strips or particle textures with semantic color usage from the Art Bible.

## Entities

| # | Name | Type | Description | Source | Status |
|---|------|------|-------------|--------|--------|
| 1 | Cat Warrior Player | Character / Protagonist | Main playable cat warrior with low ready stance, curved body language, sharp ears/claws, and cat-eye gold readability. Idle, run, attack, dodge, hurt, death, revive, jump, and fall frames are implemented through `AnimatedSprite2D + SpriteFrames`. | design/art/art-bible.md; design/gdd/feline-combat.md; design/gdd/player-abilities.md; production/epics/combat-presentation/story-003-cinderpaw-player-frame-animation.md; production/epics/combat-presentation/story-004-dodge-afterimage-cinderpaw-dodge-animation.md; production/epics/combat-presentation/story-005-cinderpaw-hurt-death-revive-animation.md; production/epics/combat-presentation/story-006-cinderpaw-jump-fall-animation.md | Implemented |
| 2 | Player Portrait | Character / Portrait | 64px dialogue/profile portrait with readable ears, eyes, and emotional variants for exploration, combat focus, hurt, and discovery. | design/art/art-bible.md; design/gdd/npc-dialogue.md | Needed |
| 3 | Shadow Beast / Mechanical Rat Prototype | Enemy | Runtime patrol enemy with Shadow Beast image-generated frame animation, red attack tell, bite attack, hurt, and death frames. Uses `AnimatedSprite2D + SpriteFrames` in `scenes/characters/shadow_beast.tscn`; chase and richer AI scheduling remain pending. | design/art/art-bible.md; design/gdd/ai-framework.md; scenes/main.tscn; production/epics/feline-combat/story-009-runtime-enemy-attack-animation.md | Partial |
| 4 | Mutated Creature | Enemy | Organic wasteland enemy with curved body and weak green mutation highlights. Needs small-enemy base sheet for later AI variants. | design/art/art-bible.md; design/gdd/status-effects.md | Needed |
| 5 | Rat King Boss | Boss | First boss visual slice has image-generated `AnimatedSprite2D + SpriteFrames` art for `idle`, `attack_tell`, `attack`, `hurt`, `death`, `phase_1_intro`, `phase_2_rebuild`, and `phase_3_overload`, with transparent 192x192 frames under `assets/characters/rat_king/`. `MainScene/Enemy` now instantiates a Rat King runtime shell with BossConfig identity, 300 HP, phase transition routing, visible Rat King animation, data-driven attack scheduling, specialized attack animations for `charge`, `claw_swipe`, `summon_minion`, `slam`, and `berserk_combo`, phase 2 live Rat Minion summon spawning and death cleanup, image-generated arena mutation prop sprites plus final VFX for debris dust, electric hazard glow, and electric spark layers, persistent active arena mutation save/load restoration, and no visible `Polygon2D`/`ColorRect` placeholder block under those mutation nodes. Rewards presentation and shader/camera polish remain pending. | design/gdd/boss-config.md; design/art/art-bible.md; production/epics/combat-presentation/story-014-rat-king-boss-frame-animation.md; production/epics/combat-presentation/story-015-rat-king-specialized-attack-animation-expansion.md; production/epics/boss-config/story-007-rat-king-runtime-main-scene-replacement.md; production/epics/boss-config/story-008-rat-king-ai-attack-scheduler-main-scene-runtime-integration.md; production/epics/boss-config/story-009-rat-king-live-phase-two-summon-runtime-integration.md; production/epics/scene-management/story-011-rat-king-final-arena-vfx.md; production/epics/scene-management/story-012-boss-arena-mutation-save-state-persistence.md; production/epics/scene-management/story-013-rat-king-arena-placeholder-visual-removal.md | Partial |
| 6 | Rat Minion | Enemy Summon | Rat King phase 2 summon enemy with image-generated `AnimatedSprite2D + SpriteFrames` art for `idle`, `run`, `attack`, `hurt`, and `death`. Runtime frames are transparent 96x96 PNGs under `assets/characters/rat_minion/`; `MainScene` spawns up to two live minions through the BossConfig summon timer, routes player damage to minion entity ids, and cleans active summons on boss death. | design/gdd/boss-config.md; design/art/art-bible.md; production/epics/boss-config/story-009-rat-king-live-phase-two-summon-runtime-integration.md | Implemented |
| 7 | Cat Elder | NPC | Hub mentor NPC with warm amber palette, soft safe-area silhouette, idle/talk/happy/sad poses. | design/gdd/npc-dialogue.md; design/art/art-bible.md | Needed |
| 8 | Cat Merchant | NPC | Shop NPC for charms and upgrades, asymmetrical tool bag, warm safe hub colors, idle/talk/sell poses. | design/gdd/charm-equipment.md; design/gdd/npc-dialogue.md | Needed |
| 9 | Mysterious Traveler | NPC | Hidden-route NPC with purple mystery accent, cloak silhouette, idle/talk/reveal poses. | design/gdd/npc-dialogue.md; design/art/art-bible.md | Needed |
| 10 | Cat Claw Weapon | Item / Weapon | Default claw weapon icon and held pose silhouette. | design/gdd/weapon-styles.md; data/combat/damage_params.json | Needed |
| 11 | Tail Blade Weapon | Item / Weapon | Long-tail blade weapon icon and attack pose support art. | design/gdd/weapon-styles.md | Needed |
| 12 | Fishbone Greatsword | Item / Weapon | Heavy fishbone sword icon and broad swing silhouette. | design/gdd/weapon-styles.md | Needed |
| 13 | Electromagnetic Bell | Item / Weapon | Bell weapon icon with slow/status-effect visual language. | design/gdd/weapon-styles.md; design/gdd/status-effects.md | Needed |
| 14 | Charm Icons | Item / Equipment | Power, crit, speed, shield, dash, and parry charm icons, 24x24 source with 16x16 HUD versions. | design/gdd/charm-equipment.md | Needed |
| 15 | Save Point Cat Nest | Structure / Interactive | Warm safe checkpoint nest, readable as healing and respawn anchor. | design/gdd/save-system.md; design/gdd/death-respawn.md; design/art/art-bible.md | Needed |
| 16 | Ability Gate Electric Fence | Structure / Gate | Dash-gated electric fence with readable locked/unlockable/unlocked states. | design/gdd/exploration-ability-gating.md; production/epics/player-abilities/story-002-dash-exploration-gate-runtime.md | Imported baseline |
| 17 | High Platform Gate | Environment / Gate | Double-jump route marker using high platform and cat claw marks; Story003 imports an image-generated transparent marker as `DoubleJumpExplorationGate` in `scenes/main.tscn`. | design/gdd/exploration-ability-gating.md; production/epics/player-abilities/story-003-double-jump-runtime-high-platform-gate.md | Imported baseline |
| 18 | Breakable Wall | Environment / Interactive | Cracked wall with escalating crack frames and debris particles. | design/gdd/exploration-ability-gating.md | Needed |
| 19 | Hidden Room Entrance | Environment / Interactive | Purple mystery outline, subtle discoverable edge glow, hidden-to-revealed transition. | design/gdd/exploration-ability-gating.md; design/art/art-bible.md | Needed |
| 20 | Hub Camp Tileset | Environment / Tileset | Warm amber cat-clan hub tiles, low-density safe props, cat paw wear marks. | design/art/art-bible.md; design/gdd/scene-management.md | Needed |
| 21 | Wasteland Street Tileset | Environment / Tileset | 16x16 abandoned commercial street tiles with old-world remnants and steel-gray wasteland structures. | design/art/art-bible.md; scenes/main.tscn | Needed |
| 22 | Boss Arena Gate | Structure / Environment | Heavy boss door with opening frames and camera-push transition support. | design/gdd/scene-management.md; design/gdd/boss-config.md | Needed |
| 23 | Fast Travel Pipe | Structure / Interactive | Glowing pipe for cat jump-in fast travel animation with particle swirl. | design/gdd/scene-management.md | Needed |
| 24 | Hidden Double Jump Reward Source | Environment / Interactive Reward | Hidden-boss echo relic with rusted vent pedestal, floating cat-eye gold wind core, pale upward air spiral, and purple hidden-route glow. Story005 imports the generated transparent PNG as `HiddenDoubleJumpRewardSource` in `scenes/main.tscn` and uses it to unlock `double_jump` once through the existing ability runtime. | design/gdd/player-abilities.md; design/gdd/exploration-ability-gating.md; production/epics/player-abilities/story-005-hidden-double-jump-reward-source.md | Implemented baseline |

## VFX / Particles

| # | Name | Description | Source | Status |
|---|------|-------------|--------|--------|
| 1 | Claw Slash Trail | Cat-eye gold/white slash arc for default attacks, clear direction and timing. | design/gdd/feline-combat.md; design/gdd/combat-presentation.md; design/art/art-bible.md; production/epics/combat-presentation/story-002-parry-flash-cat-claw-trail.md | Implemented |
| 2 | Hit Spark | White flash and red threat spark for confirmed hits. | design/gdd/combat-presentation.md; design/gdd/health-death.md | Implemented |
| 3 | Perfect Crit Spark | Cat-eye gold burst for perfect timing and rare reward feedback. | design/gdd/damage-calculation.md; design/art/art-bible.md | Needed |
| 4 | Parry Flash | Brief white/gold defensive flash with safe-color readability and radial parry spark burst. | design/gdd/feline-combat.md; design/gdd/combat-presentation.md; design/gdd/health-death.md; production/epics/combat-presentation/story-002-parry-flash-cat-claw-trail.md | Implemented |
| 5 | Dodge Afterimage | Player dodge now spawns three textured translucent afterimages at 50%/30%/10% alpha; gold perfect-dodge variant remains pending. | design/art/art-bible.md; design/gdd/feline-combat.md; production/epics/combat-presentation/story-004-dodge-afterimage-cinderpaw-dodge-animation.md | Partial |
| 6 | Enemy Telegraph Red Flash | Shadow Beast `attack_tell` frames now provide a signal-red pre-attack marker; broader enemy telegraph language and colorblind shape variants remain pending. | design/art/art-bible.md; design/gdd/health-death.md; production/epics/feline-combat/story-009-runtime-enemy-attack-animation.md | Partial |
| 7 | Door Dissolve Particles | Ability gate unlock dissolve, 0.5s effect. | design/gdd/exploration-ability-gating.md | Needed |
| 8 | Breakable Wall Debris | Small pixel debris burst as cracks expand and wall breaks. | design/gdd/exploration-ability-gating.md | Needed |
| 9 | Death Dissolve | Player shadow dissolution with gold particles rising. | design/gdd/death-respawn.md; design/art/art-bible.md | Needed |
| 10 | Revive Ring | Cat-eye gold ring expanding from respawn location. | design/gdd/death-respawn.md | Needed |
| 11 | Status Effect Particles | Poison, stun, slow, speed boost, damage boost, and invincible visual overlays. | design/gdd/status-effects.md | Needed |
| 12 | Damage Numbers | Pixel numeric popups with crit and normal variants. | design/gdd/damage-calculation.md; design/gdd/combat-presentation.md | Needed |
| 13 | Enemy Death Debris | Enemy-color fragment burst for kill feedback. | design/gdd/combat-presentation.md; design/art/art-bible.md | Implemented |
| 14 | Rat King Arena Mutation VFX | Image-generated debris dust, electric hazard glow, and electric spark Sprite2D VFX layers attached to Rat King phase 2/3 arena mutations; Story013 removes the remaining visible placeholder shape so generated prop sprites and VFX are the only player-facing arena mutation visuals. | design/gdd/boss-config.md; design/gdd/combat-presentation.md; design/art/art-bible.md; production/epics/scene-management/story-011-rat-king-final-arena-vfx.md; production/epics/scene-management/story-013-rat-king-arena-placeholder-visual-removal.md | Implemented |
| 15 | Double Jump Foot Vortex | Image-generated transparent 256x256 foot-level air vortex with cat-eye gold core, pale spiral, blue upward motion strokes, and sparklets. Story004 spawns three textured `Sprite2D` particles for successful Double Jump activation and routes the paired `sfx_double_jump` cue. | design/gdd/player-abilities.md; design/gdd/audio-system.md; production/epics/player-abilities/story-004-double-jump-activation-feedback.md | Implemented |

## UI Screens

| # | Screen Name | Description | Source | Status |
|---|-------------|-------------|--------|--------|
| 1 | Main Menu | Title screen with cat on warm/cold boundary, subtle idle motion, start/settings/load actions. | design/art/art-bible.md | Needed |
| 2 | Combat HUD | In-game HUD with HP, weapon, cooldown, charms, minimap, notifications. | design/gdd/hud-ui.md; design/gdd/health-death.md | Needed |
| 3 | Pause Menu | Safe-port UI with resume, inventory, map, settings, quit. | design/gdd/hud-ui.md | Needed |
| 4 | Settings Menu | Input, audio, accessibility, and display settings. | design/accessibility-requirements.md; design/gdd/input.md | Needed |
| 5 | Charm Equipment Menu | Three equipped slots and owned charm grid. | design/gdd/charm-equipment.md | Needed |
| 6 | Map Screen | Area map with fog, markers, save points, shortcuts, boss and hidden-room symbols. | design/gdd/map-system.md | Needed |
| 7 | Fast Travel Menu | Unlocked save-point list with thumbnails and locked-state icons. | design/gdd/scene-management.md | Needed |
| 8 | Dialogue Box | Cat-ear decorated dialogue frame with NPC portrait slot and response choices. | design/gdd/npc-dialogue.md; design/art/art-bible.md | Needed |
| 9 | Death Screen | Grayscale death panel, learning hint, recent save point name, optional combat summary. | design/gdd/death-respawn.md | Needed |
| 10 | Loading / Transition Screen | SceneManager-driven loading shell with image-generated tunnel overlay, transparent cat paw spinner, and dynamic scene label; fast travel and full scene-tree transition variants remain pending. | design/gdd/scene-management.md; production/epics/scene-management/story-004-transition-loading-ui-shell.md | Partial |
| 11 | Save / Load Screen | Save slot list and autosave indicator. | design/gdd/save-system.md | Needed |

## HUD Elements

| # | Element | Description | Source | Status |
|---|---------|-------------|--------|--------|
| 1 | Player HP Bar | Pupil-shaped HP bar with gold-to-red semantic states. | design/gdd/health-death.md; design/art/art-bible.md | Needed |
| 2 | Boss HP Bar | Top-screen boss HP bar with boss name and phase markers. | design/gdd/health-death.md; design/gdd/boss-config.md | Needed |
| 3 | Enemy HP Bar | Small overhead enemy HP bar. | design/gdd/health-death.md | Needed |
| 4 | Weapon HUD | Current weapon icon and state. | design/gdd/weapon-styles.md; design/gdd/hud-ui.md | Needed |
| 5 | Special Move Cooldown | Hex icon with bottom-up cooldown fill and gold ready state. | design/art/art-bible.md; design/gdd/hud-ui.md | Needed |
| 6 | Charm HUD Icons | Three 16x16 equipped charm indicators. | design/gdd/charm-equipment.md | Needed |
| 7 | Status Effect Icons | 24x24 icons with countdown arc, maximum five visible. | design/gdd/status-effects.md | Needed |
| 8 | Gear Coin Counter | Currency counter for upgrades and merchant purchases. | design/gdd/charm-equipment.md; design/gdd/skill-tree.md | Needed |
| 9 | Minimap Frame | Compact minimap frame with current room and markers. | design/gdd/map-system.md; design/gdd/hud-ui.md | Needed |
| 10 | Notification Toast | Discovery, item pickup, ability unlock, and secret room notification frame. | design/gdd/exploration-ability-gating.md; design/gdd/hud-ui.md | Needed |

## Audio

| # | Name | Type | Description | Source | Status |
|---|------|------|-------------|--------|--------|
| 1 | Player Attack Hit | SFX | Sharp claw hit, short and readable. | design/gdd/feline-combat.md; design/gdd/audio-system.md | Needed |
| 2 | Parry Success | SFX | Bright defensive chime synced to parry flash. | design/gdd/feline-combat.md | Needed |
| 3 | Dodge | SFX | Soft whoosh with optional gold perfect-dodge accent. | design/gdd/feline-combat.md | Needed |
| 4 | Door Unlock | SFX | Ability-themed unlock sound. | design/gdd/exploration-ability-gating.md | Needed |
| 5 | Secret Found | SFX | Mysterious discovery tone plus cat vocal accent. | design/gdd/exploration-ability-gating.md | Needed |
| 6 | Menu Select / Confirm | SFX | Warm safe UI feedback. | design/gdd/hud-ui.md; design/art/art-bible.md | Needed |
| 7 | Boss Theme | Music | Cold, high-pressure boss music with phase escalation. | design/gdd/boss-config.md; design/art/art-bible.md | Needed |
| 8 | Hub Ambience | Ambient / Music | Warm safe hub ambience, layered light feeling. | design/art/art-bible.md | Needed |
| 9 | Death / Respawn | SFX | Heavy fall, dissolve, soft cat-call revive, ambience fade-in. | design/gdd/death-respawn.md | Needed |
| 10 | Double Jump Activation | SFX | Replaceable baseline bounce/vortex cue imported as `res://assets/audio/sfx/sfx_double_jump.wav` and routed by `AudioSystem.on_double_jump_event`. | design/gdd/player-abilities.md; design/gdd/audio-system.md; production/epics/player-abilities/story-004-double-jump-activation-feedback.md | Implemented baseline |
