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
| 1 | Cat Warrior Player | Character / Protagonist | Main playable cat warrior with low ready stance, curved body language, sharp ears/claws, and cat-eye gold readability. Needs idle, run, jump, fall, attack, dodge, hurt, death, revive frames. | design/art/art-bible.md; design/gdd/feline-combat.md; design/gdd/player-abilities.md | Needed |
| 2 | Player Portrait | Character / Portrait | 64px dialogue/profile portrait with readable ears, eyes, and emotional variants for exploration, combat focus, hurt, and discovery. | design/art/art-bible.md; design/gdd/npc-dialogue.md | Needed |
| 3 | Mechanical Rat | Enemy | Basic patrol/chase enemy, square steel silhouette, red threat telegraphs, 3-hit prototype enemy behavior. Needs idle, patrol, chase, attack, hurt, death. | design/art/art-bible.md; design/gdd/ai-framework.md; scenes/main.tscn | Needed |
| 4 | Mutated Creature | Enemy | Organic wasteland enemy with curved body and weak green mutation highlights. Needs small-enemy base sheet for later AI variants. | design/art/art-bible.md; design/gdd/status-effects.md | Needed |
| 5 | Rat King Boss | Boss | First boss, 2-3x player size, mechanical rat king silhouette with phase posture changes, purple skill accents, red attack tells. | design/gdd/boss-config.md; design/art/art-bible.md | Needed |
| 6 | Cat Elder | NPC | Hub mentor NPC with warm amber palette, soft safe-area silhouette, idle/talk/happy/sad poses. | design/gdd/npc-dialogue.md; design/art/art-bible.md | Needed |
| 7 | Cat Merchant | NPC | Shop NPC for charms and upgrades, asymmetrical tool bag, warm safe hub colors, idle/talk/sell poses. | design/gdd/charm-equipment.md; design/gdd/npc-dialogue.md | Needed |
| 8 | Mysterious Traveler | NPC | Hidden-route NPC with purple mystery accent, cloak silhouette, idle/talk/reveal poses. | design/gdd/npc-dialogue.md; design/art/art-bible.md | Needed |
| 9 | Cat Claw Weapon | Item / Weapon | Default claw weapon icon and held pose silhouette. | design/gdd/weapon-styles.md; data/combat/damage_params.json | Needed |
| 10 | Tail Blade Weapon | Item / Weapon | Long-tail blade weapon icon and attack pose support art. | design/gdd/weapon-styles.md | Needed |
| 11 | Fishbone Greatsword | Item / Weapon | Heavy fishbone sword icon and broad swing silhouette. | design/gdd/weapon-styles.md | Needed |
| 12 | Electromagnetic Bell | Item / Weapon | Bell weapon icon with slow/status-effect visual language. | design/gdd/weapon-styles.md; design/gdd/status-effects.md | Needed |
| 13 | Charm Icons | Item / Equipment | Power, crit, speed, shield, dash, and parry charm icons, 24x24 source with 16x16 HUD versions. | design/gdd/charm-equipment.md | Needed |
| 14 | Save Point Cat Nest | Structure / Interactive | Warm safe checkpoint nest, readable as healing and respawn anchor. | design/gdd/save-system.md; design/gdd/death-respawn.md; design/art/art-bible.md | Needed |
| 15 | Ability Gate Electric Fence | Structure / Gate | Dash-gated electric fence with readable locked/unlockable/unlocked states. | design/gdd/exploration-ability-gating.md | Needed |
| 16 | High Platform Gate | Environment / Gate | Double-jump route marker using high platform and cat claw marks. | design/gdd/exploration-ability-gating.md | Needed |
| 17 | Breakable Wall | Environment / Interactive | Cracked wall with escalating crack frames and debris particles. | design/gdd/exploration-ability-gating.md | Needed |
| 18 | Hidden Room Entrance | Environment / Interactive | Purple mystery outline, subtle discoverable edge glow, hidden-to-revealed transition. | design/gdd/exploration-ability-gating.md; design/art/art-bible.md | Needed |
| 19 | Hub Camp Tileset | Environment / Tileset | Warm amber cat-clan hub tiles, low-density safe props, cat paw wear marks. | design/art/art-bible.md; design/gdd/scene-management.md | Needed |
| 20 | Wasteland Street Tileset | Environment / Tileset | 16x16 abandoned commercial street tiles with old-world remnants and steel-gray wasteland structures. | design/art/art-bible.md; scenes/main.tscn | Needed |
| 21 | Boss Arena Gate | Structure / Environment | Heavy boss door with opening frames and camera-push transition support. | design/gdd/scene-management.md; design/gdd/boss-config.md | Needed |
| 22 | Fast Travel Pipe | Structure / Interactive | Glowing pipe for cat jump-in fast travel animation with particle swirl. | design/gdd/scene-management.md | Needed |

## VFX / Particles

| # | Name | Description | Source | Status |
|---|------|-------------|--------|--------|
| 1 | Claw Slash Trail | Cat-eye gold/white slash arc for default attacks, clear direction and timing. | design/gdd/feline-combat.md; design/gdd/combat-presentation.md; design/art/art-bible.md; production/epics/combat-presentation/story-002-parry-flash-cat-claw-trail.md | Implemented |
| 2 | Hit Spark | White flash and red threat spark for confirmed hits. | design/gdd/combat-presentation.md; design/gdd/health-death.md | Implemented |
| 3 | Perfect Crit Spark | Cat-eye gold burst for perfect timing and rare reward feedback. | design/gdd/damage-calculation.md; design/art/art-bible.md | Needed |
| 4 | Parry Flash | Brief white/gold defensive flash with safe-color readability and radial parry spark burst. | design/gdd/feline-combat.md; design/gdd/combat-presentation.md; design/gdd/health-death.md; production/epics/combat-presentation/story-002-parry-flash-cat-claw-trail.md | Implemented |
| 5 | Dodge Afterimage | 2-3 frame translucent player afterimage, gold variant for perfect dodge. | design/art/art-bible.md; design/gdd/feline-combat.md | Needed |
| 6 | Enemy Telegraph Red Flash | Signal-red pre-attack marker with colorblind shape redundancy. | design/art/art-bible.md; design/gdd/health-death.md | Needed |
| 7 | Door Dissolve Particles | Ability gate unlock dissolve, 0.5s effect. | design/gdd/exploration-ability-gating.md | Needed |
| 8 | Breakable Wall Debris | Small pixel debris burst as cracks expand and wall breaks. | design/gdd/exploration-ability-gating.md | Needed |
| 9 | Death Dissolve | Player shadow dissolution with gold particles rising. | design/gdd/death-respawn.md; design/art/art-bible.md | Needed |
| 10 | Revive Ring | Cat-eye gold ring expanding from respawn location. | design/gdd/death-respawn.md | Needed |
| 11 | Status Effect Particles | Poison, stun, slow, speed boost, damage boost, and invincible visual overlays. | design/gdd/status-effects.md | Needed |
| 12 | Damage Numbers | Pixel numeric popups with crit and normal variants. | design/gdd/damage-calculation.md; design/gdd/combat-presentation.md | Needed |
| 13 | Enemy Death Debris | Enemy-color fragment burst for kill feedback. | design/gdd/combat-presentation.md; design/art/art-bible.md | Implemented |

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
| 10 | Loading / Transition Screen | Cat paw loading spinner and scene transition overlay. | design/gdd/scene-management.md | Needed |
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
