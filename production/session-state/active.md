# Active Session State

## Current Task
- Save System、Death & Respawn、SceneManagement Story002 title/continue/load
  handoff、SceneManagement Story003 async load request lifecycle + timeout
  fallback、SceneManagement Story004 transition loading UI shell、
  SceneManagement Story005 runtime scene-tree swap ownership、
  SceneManagement Story006 deferred unload/cache eviction、
  SceneManagement Story007 fast travel preload/scene change、AudioSystem
  Story001 autoload bus/pool baseline、AudioSystem Story002 scene transition
  audio fades、AudioSystem Story003 combat/health event audio adapters、
  CombatPresentation Story014 Rat King boss frame animation slice、
  CombatPresentation Story015 Rat King specialized attack animation expansion、
  BossConfig Story007 RatKingBoss runtime scene/MainScene boss replacement、
  BossConfig Story008 Rat King AI attack scheduler runtime integration、
  BossConfig Story009 Rat King live phase 2 summon runtime integration、
  SceneManagement Story008 boss arena mutation runtime、
  SceneManagement Story009 electric leak contact damage、
  SceneManagement Story010 scene memory budget diagnostics、
  SceneManagement Story011 Rat King final arena VFX、
  SceneManagement Story012 boss arena mutation save-state persistence、AudioSystem
  Story004 Rat King boss music state transitions、AudioSystem Story005 core
  combat SFX asset import baseline、AudioSystem Story006 weapon-style SFX asset
  expansion、AudioSystem Story007 UI menu audio + same-SFX merge、AudioSystem
  Story008 music + ambience asset import baseline、AudioSystem Story010 low-HP
  focus damage final mix、BossConfig Story010 Rat King
  defeat reward runtime consumption、Player Abilities Story002
  ExplorationGate dash 门控、Player Abilities Story011 Old Factory deep guard
  activation pacing、Player Abilities Story017 Old Factory Spark Rat pacing
  polish、Player Abilities Story018 Skill Tree Cat Claw T1-A First Spend、
  Player Abilities Story019 Parry Laser Gate Runtime、Player Abilities
  Story020 Parry Success Feedback Runtime、Player Abilities Story027 Parry
  Laser Gate Authored Visual Replacement、Player Abilities Story028 Boss2 HUD
  Hit Feedback + Arena Visual Runtime、Player Abilities Story029 Boss2 Arena
  Camera Lock Runtime、Player Abilities Story030 Boss2 Room Seal Runtime、
  Player Abilities Story031 Boss2 HUD Portrait Runtime、Player Abilities
  Story032 Boss2 Phase II Runtime Pressure Mix、Player Abilities Story033
  Boss2 Victory Route Handoff、Player Abilities Story034 Factory Route Arrival
  Objective Handoff、Player Abilities Story035 Old Factory Service Lift Handoff、
  Player Abilities Story036 Old Factory Service Lift SceneManager Exit、
  Player Abilities Story037 Factory Route Runtime Roundtrip、Player Abilities
  Story038 Factory Route Return Prompt、Player Abilities Story039 Scrap Roost
  Return Hub Runtime、Player Abilities Story040 Old Factory Return Patrol
  Ambush、Player Abilities Story041 Old Factory Return Patrol Reward Cache、
  Player Abilities Story042 Old Factory Cache Claim Feedback、Player
  Abilities Story043 Old Factory Return Checkpoint、Player Abilities Story044
  Old Factory Return Checkpoint Respawn Runtime、Player Abilities Story045 Old
  Factory Runtime Death Integration、Player Abilities Story046 Old Factory
  Checkpoint-Forward Combat Route、Player Abilities Story047 Old Factory
  Checkpoint Steam Vent Gauntlet、Player Abilities Story048 Old Factory
  Checkpoint Rear Ambush、Player Abilities Story049 Old Factory Checkpoint
  Overdrive Duo、Player Abilities Story050 Old Factory Overdrive Duo
  Staggered Pincer Pacing、Player Abilities Story051 Old Factory Checkpoint
  Overdrive Reward Cache、Player Abilities Story052 Old Factory Overdrive
  Defeat Burst、Player Abilities Story053 Old Factory Lower Deck Skirmish
  Cache、Player Abilities Story054 Old Factory Lower Deck Parry-Laser Ambush
  Gate、Player Abilities Story055 Old Factory Lower Deck Shortcut Seal Combat
  Gate、Player Abilities Story056 Old Factory Lower Deck Shortcut Payoff Cache、
  Player Abilities Story057 Old Factory Lower Deck Shortcut Pursuer、Player
  Abilities Story058 Old Factory Lower Deck Pressure Valve Combat Gate、Player
  Abilities Story059 Old Factory Lower Deck Steam Sluice Ambush、Player
	  Abilities Story060 Old Factory Lower Deck Deep Bulkhead Combat Gate、
	  Player Abilities Story061 Old Factory Lower Deck Breach Corridor Ambush、
	  Player Abilities Story062 Old Factory Lower Deck Breach Relay Savepoint、
	  Player Abilities Story063 Old Factory Lower Deck Breach Relay Activation
	  Feedback、Player Abilities Story064 Old Factory Lower Deck Breach Relay
	  Audio Feedback、Player Abilities Story065 Old Factory Lower Deck
	  Post-Relay Combat Feedback、Player Abilities Story066 Old Factory Lower
	  Deck Relay Forward Reward Hatch、Player Abilities Story067 Old Factory
	  Lower Deck Forward Conduit Ambush、Player Abilities Story068 Old Factory
	  Lower Deck Forward Conduit Clear Feedback、Player Abilities Story069 Old
	  Factory Lower Deck Forward Pressure Traverse、Player Abilities Story070
	  Old Factory Lower Deck Forward Pressure Counter-Ambush、Player Abilities
	  Story071 Old Factory Lower Deck Forward Pressure Reward Cache、
	  Player Abilities Story072 Old Factory Lower Deck Forward Pressure
	  Reward Cache Audio Feedback、Player Abilities Story073 Old Factory Lower
	  Deck Forward Pressure Exit Guard、Player Abilities Story074 Old Factory
	  Lower Deck Forward Pressure Exit Relay Savepoint、Player Abilities Story075
	  Old Factory Lower Deck Forward Pressure Exit Gate Handoff、Player Abilities
	  Story076 Old Factory Lower Deck Forward Pressure Route Handoff Marker、
	  Player Abilities Story077 Old Factory Lower Deck Forward Pressure Beacon
	  Ambush、Player Abilities Story078 Old Factory Lower Deck Forward Pressure
	  Overrun、Player Abilities Story079 Old Factory Lower Deck Forward Pressure
	  Breaker、Player Abilities Story080 Old Factory Lower Deck Forward Pressure
	  Relief Ambush、Player Abilities Story081 Old Factory Lower Deck Forward
	  Pressure Coil Rat Breakthrough、Player Abilities Story082 Old Factory
	  Lower Deck Forward Pressure Coil Pincer、Player Abilities Story083 Old
	  Factory Lower Deck Forward Pressure Coil Aftershock、Player Abilities
	  Story084 Old Factory Lower Deck Forward Pressure Aftershock Reward Cache、
	  Player Abilities Story085 Old Factory Lower Deck Forward Pressure
	  Aftershock Exit Skirmish、Player Abilities Story086 Old Factory Lower Deck
	  Forward Pressure Aftershock Exhaust Traverse、Player Abilities Story087
	  Old Factory Lower Deck Forward Pressure Aftershock Exhaust Pursuer、
	  Player Abilities Story088 Old Factory Lower Deck Forward Pressure
	  Aftershock Exhaust Pursuer Reward Cache、Player Abilities Story089 Old
	  Factory Lower Deck Forward Pressure Aftershock Exhaust Flank Ambush、
	  Player Abilities Story090 Old Factory Lower Deck Forward Pressure
	  Aftershock Exhaust Breaker Corridor、Player Abilities Story091 Old Factory
	  Lower Deck Forward Pressure Aftershock Exhaust Escape Skirmish、
	  Player Abilities Story092 Old Factory Lower Deck Forward Pressure
	  Aftershock Exhaust Exit Hatch Handoff、Player Abilities Story093 Old
	  Factory Lower Deck Forward Pressure Aftershock Cooling Duct Traverse、
	  Player Abilities Story094 Old Factory Lower Deck Forward Pressure
	  Aftershock Condenser Valve Ambush、Player Abilities Story095 Old Factory
	  Lower Deck Forward Pressure Aftershock Condenser Savepoint、Player
	  Abilities Story096 Old Factory Lower Deck Forward Pressure Aftershock
	  Condenser Outlet Traverse、Player Abilities Story097 Old Factory Lower
	  Deck Forward Pressure Aftershock Condenser Outlet Clamp Ambush、Player
	  Abilities Story098 Old Factory Lower Deck Forward Pressure Aftershock
	  Condenser Outlet Drip Vent Traverse、Player Abilities Story099 Old Factory
	  Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Skirmish、
	  Player Abilities Story100 Main Scene Dash Gate Authored Visual Replacement、
	  Player Abilities Story101 Main Scene Player Hit Damage Number Runtime、
	  Player Abilities Story102 Old Factory Route Floor Platform Visual Pass、
	  Player Abilities Story103 Main Scene Boundary Wall Visual Pass、
	  Player Abilities Story104 Main Scene Reward Prompt Proximity、
	  Player Abilities Story105 Main Scene Gate Prompt Proximity、Player
	  Abilities Story106 Old Factory Lower Deck Forward Pressure Aftershock
	  Condenser Overflow Pump Reward Cache、Player Abilities Story107 Old
	  Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump
	  Runoff Duct Traverse、Player Abilities Story108 Old Factory Lower Deck
	  Forward Pressure Aftershock Condenser Overflow Pump Runoff Exit Skirmish、
	  Player Abilities Story109 Old Factory Lower Deck Forward Pressure
	  Aftershock Condenser Overflow Pump Runoff Exit Reward Cache、Player
	  Abilities Story110 Old Factory Lower Deck Forward Pressure Aftershock
	  Condenser Overflow Pump Runoff Outlet Traverse、Player Abilities Story111
	  Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump
	  Runoff Outlet Skirmish、Player Abilities Story112 Old Factory Lower Deck
	  Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Reward
	  Cache、Player Abilities Story113 Old Factory Lower Deck Forward Pressure
	  Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Traverse
	  、Player Abilities Story114 Old Factory Lower Deck Forward Pressure
	  Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Skirmish
	  、Player Abilities Story115 Old Factory Lower Deck Forward Pressure
	  Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Reward
	  Cache、Player Abilities Story116 Old Factory Lower Deck Forward Pressure
	  Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Exit Hatch
	  Handoff、Player Abilities Story117-139 的 Factory tailrace、Boss3、
	  Underground、Factory Upper Altar 与 Neon Rooftops 连续切片、Player
	  Abilities Story140-148 的 Central Tower 连续切片、Crown Observatory、
	  Crown Warden Boss4 core、`wall_climb` reward payoff 与 Scrap Roost
	  victory recall，以及 Story149-151 的 Long Tail、Fish Bone、Electro Bell
	  T1-A Skill Tree 选择已完成，连同既有 Cat Claw 形成四武器首层 Build
	  选择；Story152 已完成 Main 本地小地图、真实 Dash 门揭示与 world flag
	  恢复；Story153 已完成 Main 自动存档猫爪印、`1.5s` 淡出与 `ui_save`
	  路由；Story154 已完成 Main 低血专注激活猫眼金边缘闪光、`0.3s`
	  淡出与既有 `sfx_focus_mode_activate` 路由；Death & Respawn Story008
	  已完成 Main 死亡灰度、8 个猫眼金灵魂光点、真实 `1.5s` 复活、
	  `0.5s` 灰度淡出与 `1.0s` 金色复活光环，并修复 MCP 发现的 VFX
	  freed-instance 生命周期竞态；Combat Presentation Story016 已完成真实 Main
	  PERFECT 弹反猫眼金纯色残影，复用当前三帧 `parry` 纹理、反向偏移
	  `12px`、持续 `0.35s`，并通过 ShaderMaterial 保持剪影可读；Player
	  Abilities Story155 已完成 Crown Warden 真实攻击接触的弹反反击，玩家
	  `100 -> 100 HP`、Boss `160 -> 110 HP`，以当前武器基础伤害应用一次
	  `5.0x` 反击且不进入 STUN；Combat Presentation Story017 已完成 Rat King
	  真实死亡后三秒演出等待，奖励即时结算但全屏奖励菜单延迟到演出结束，并修复
	  致死跨阶段时 deferred phase animation 覆盖 `death` 的竞态；Player Abilities
	  Story156 已按 GDD 的 Rat King→Dash、Boss2→Double Jump 顺序收敛 Main
	  双 Boss 同时激活问题，Rat King 奖励交接前不启用 Echo Guardian、其
	  HUD/竞技场/房门/镜头/奖励，载入鼠王击败进度后再原子启用 Boss2；Scene
	  Management Story014 已完成 Rat King 阶段镜头编排，Phase I/II/III 分别
	  使用 `1.08`/`1.12`/`1.16` zoom，死亡后恢复默认 `1.0` zoom 与 `1280`
	  右边界，同时保持 CombatPresentation 的 camera offset 所有权并让 Boss2
	  竞技场镜头拥有优先级；Combat Presentation Story018 已让 Echo Guardian
	  真实死亡后三帧 `death` 保持可见 `2.0s`，期间锁定玩家并保留 Boss2 镜头/
	  房门，演出结束后再隐藏 Boss、释放竞技场并开放 Double Jump 奖励；Combat
	  Presentation Story019 已把 Boss 阶段覆盖层替换为 image-generated
	  边缘构图，中心 `50% x 50%` 完全透明，单层在 `0.40s` 淡出，既有 32 个
	  金属碎片继续到 `1.50s`，HUD 保持在上层且不改 Boss 阶段逻辑；Player
	  Abilities Story157 已把真实低血 focus 信号接入 Rat King 与 Echo Guardian，
	  focus 内新攻击 startup 分别从 `15 -> 21`、`8 -> 14` 帧；Story158 继续
	  落地规则8的攻击预警增强，两名 Boss 共用 image-generated 信号红开放中心
	  VFX，focus 内面积为 `1.25x`、持续时间为 `1.10x`，不改变角色缩放、hitbox、
	  damage 或 startup；Story159 新增 image-generated 稀疏废土尘粒
	  `CPUParticles2D`，真实 focus 只把该环境层 alpha 从 `1.0` 降到 `0.30`，
	  退出后恢复，并保持 camera/viewport 不变；AudioSystem Story010 已把
	  `sfx_damage_taken_lowhp` 替换为 0.38s 可追溯低频阻尼混响最终混音，
	  真实 25/100 focus 受击走 LOW_HP/SFX，35/100 后恢复普通 cue。规则8
	  四项实现已闭环，主观真人试听仍作为音频评审签收。
	  其他场景 minimap、其他 ExplorationGate、skill-tree branches、Boss polish、ending、
	  final audio replacement 与玩家可见帧动画审计继续保留在后续队列。
  继续执行 TDD + Godot MCP 运行态验证，
  玩家可见动作角色必须遵守 `AnimatedSprite2D + SpriteFrames` 规则。

## Technical Maintenance
- Godot AI MCP current baseline — the project-local plugin reports version
  `3.0.2`, Godot 4.7 editor settings use managed server version `3.0.2`, and
  live MCP session `cinderpaw@3736` reports plugin/server `3.0.2` with
  readiness `ready`. Current runtime validation should use Godot `4.7-stable`
  and Godot AI MCP `3.0.2`; older 2.8.x/2.9.x entries below are historical
  evidence from the stories validated at that time.

## Last Completed Task
- Audio System Story 010: Focus Damage Low-HP Final Mix -- 保持既有 cue id/
  path 与 Main/AudioSystem 接线不变，将 Story005 0.34s replaceable baseline
  替换为 0.38s 44.1kHz mono PCM16 最终混音；相对普通受击音 20-80Hz
  `+6.59dB`、2-6kHz `-4.06dB`、160ms 后尾音 `-19.39dBFS`、末 10ms
  `-71.09dBFS`。RED `report_1668`；focused GREEN `report_1669` `1/1`；
  bounded related GREEN `report_1670` `36/36`；final focused `report_1671`
  `1/1`；target smoke 通过。Godot
  `4.7-stable` / MCP `3.0.2` run `r3451721-2` 验证 normal -> 25/100
  LOW_HP -> 35/100 normal 路由、0.38s import、SFX bus 播放、1278x718 非空
  截图、3 条 info-only game log、0 条 editor log 与 clean stop `ready`。
  自动化不声明真人主观试听或商业母带完成。

- Player Abilities Story 159: Main Scene Focus Mode Environment Particle
  Clarity -- Main 新增 24 个 fixed-seed image-generated 废土尘粒；真实
  low-HP combat focus 将 `FocusEnvironmentParticles` alpha 从 `1.0` 降为
  `0.30`，治疗退出后恢复 `1.0`，Camera2D zoom/limits 始终不变且未添加
  vignette。Initial RED `report_1664`；focused GREEN `report_1665` `1/1`；
  bounded related GREEN `report_1666` `15/15`；MCP 3.0.2 升级后 focused
  `report_1667` `1/1` 与 target smoke 复验通过。Godot
  `4.7-stable` / MCP plugin `2.9.2` clean run `r29075015-35` 验证
  normal/focus/restored 生命周期、两张 `1278x718` 非空截图、3 条 info-only
  game log、0 条 editor log 与 clean stop `ready`。Story 完成后项目 MCP
  baseline 已升级并另行验证为 `3.0.2`。

- Godot AI MCP 3.0.2 Upgrade -- project-local `addons/godot_ai/` now exactly
  matches the supplied `godot-ai-3.0.2` plugin package; managed server process
  pins `uvx --from godot-ai==3.0.2`, executable `--version` returns `3.0.2`,
  editor settings record managed version `3.0.2`, and live session
  `cinderpaw@3736` reports plugin/server `3.0.2`. MCP run `r233874-1` launched
  Main with helper live, no current-run errors, three info-only game lines,
  zero editor lines and clean stop `ready`. Evidence:
  `production/qa/evidence/godot-ai-3-0-2-upgrade-2026-07-14.md`.

- Player Abilities Story 158: Main Scene Focus Mode Boss Attack Tell
  Amplification -- Rat King 与 Echo Guardian 新增共享 image-generated
  `FocusAttackTell` `Sprite2D`；focus 内面积 `1.25x`，持续时间分别为
  `15->17` 与 `8->9` 帧，结束后隐藏并恢复原始缩放，Story157 startup 仍为
  `21`/`14`。Initial RED `report_1660`；refinement RED `report_1661`；focused
  GREEN `report_1662` `1/1`；bounded related GREEN `report_1663` `12/12`，
  target smoke 通过。Godot `4.7-stable` / MCP plugin `2.9.2` run
  `r27682351-33` 验证两只三帧 Boss、两处预警、`1278x718` 非空截图、3 条
  info-only game log、0 条 editor log 与 clean stop `ready`。

- Player Abilities Story 157: Main Scene Focus Mode Boss Windup Runtime --
  Main 将 Player Health 的真实 focus transition 同步给 Rat King 与 Echo
  Guardian；focus 内新攻击 startup 为 `15+6=21` 与 `8+6=14`，focus 退出后
  future extension 归零，但当前 startup 保持不变。RED `report_1656`；focused
  GREEN `report_1657` `1/1`；final bounded related GREEN `report_1659`
  `28/28`，target smoke 通过。Godot `4.7-stable` / MCP `2.9.2` run
  `r26343036-32` 验证真实信号、两个三帧 attack、现有 image-generated focus
  overlay、`1278x718` 非空截图、3 条 info-only game log、0 条 editor log 与
  clean stop `ready`。

- Combat Presentation Story 018: Echo Guardian Death Presentation Hold --
  Main 在 durable Boss2 defeat flag 即时提交后保留 Echo Guardian 的三帧
  `death` `2.0s`；期间 hitbox 为 `0`、奖励不可领、玩家锁定、Boss2 镜头和
  双侧房门保持，结束后统一隐藏 Boss、恢复默认镜头、打开房门并开放 Double
  Jump 奖励。RED `report_1652`；focused GREEN `report_1653` `1/1`；
  final bounded related GREEN `report_1655` `17/17`，target smoke 通过。
  Godot `4.7-stable` / MCP
  `2.9.2` run `r24878458-30` 验证 exact timing、现有 image-generated
  death 帧、奖励/竞技场时序、`1278x718` 非空截图、3 条 info-only game
  log、0 条 editor log 与 clean stop `ready`。

- Scene Management Story 014: Rat King Arena Camera Choreography -- Main
  Rat King 战斗现在按 Phase I/II/III 应用 `1.08`/`1.12`/`1.16` zoom 与
  `1120` 右边界；死亡、奖励等待和非激活状态恢复共享默认镜头，Boss2 激活时
  保持其竞技场镜头优先级，且不覆盖 CombatPresentation 使用的 camera
  offset。RED `report_1646`；focused GREEN `report_1650` `1/1`；bounded
  related GREEN `report_1651` `12/12`，target smoke 通过。Godot
  `4.7-stable` / MCP `2.9.2` run `r23858246-29` 验证三个阶段、三帧
  `phase_3_overload`、致死释放、Boss2 隔离、`1278x718` 非空截图、3 条
  info-only game log、0 条 editor log 与 clean stop `ready`。

- Player Abilities Story 156: Main Rat King to Echo Guardian Sequential
  Encounter Handoff -- Fresh Main 现在只启用 Rat King；Echo Guardian
  无目标、无碰撞、不运行 AI，且其竞技场框、HUD、镜头锁和房门封锁关闭。
  隐藏二段跳路径不提前启用主线 Boss2；Rat King `victory_pending` 演出期间
  仍保持隔离，载入 `boss_rat_king_defeated=true` 的 playing Main 后才统一
  启用 Echo Guardian。RED `report_1640`，focused GREEN `report_1641`
  `1/1`；bounded related GREEN `report_1644` `21/21` 与 `report_1645`
  `28/28`，target smoke 通过。Godot `4.7-stable` / MCP `2.9.2` run
  `r22661784-28` 验证 fresh/交接两种可见状态、Boss2 三帧 `run`、两张
  `1278x718` 非空截图、3 条 info-only game log、0 条 editor log 与 clean
  stop `ready`。

- Combat Presentation Story 017: Rat King Victory Death Presentation Hold --
  真实 Main 击杀 Rat King 后先进入 `victory_pending` `3.0s`，锁定玩家并保持
  奖励菜单隐藏；现有 Dash/+50 Gears/+5 SP 奖励、defeat flag 与 autosave 仍
  即时提交。Rat King 致死跨阶段的 deferred phase callback 不再覆盖三帧
  `death` 动画。RED `report_1631` 与 refinement RED `report_1634`；原 related
  GREEN `report_1636` 通过 `47/47`。MCP 视觉检查暴露死亡等待错误显示 Boss2
  HUD，RED `report_1637`、最终 focused GREEN `report_1638` `1/1`、HUD/reward
  related GREEN `report_1639` `6/6`，target smoke 通过。Godot `4.7-stable` /
  MCP `2.9.2` 最终 run `r21623823-27` 验证 exact timing、collision shutdown、
  Boss HUD 隐藏、奖励与 delayed menu；两张 `1278x718` 截图非空，game log
  仅 3 条 info、editor log 0 行并 clean stop。

- Player Abilities Story 155: Crown Warden Parry Counter Runtime -- 真实
  `talon_dive` / `wing_sweep` 接触现在先由 Player 的 CombatComponent 消费
  PARRYING 窗口，阻止玩家伤害，再由 Crown Warden arena 按当前武器有效
  基础伤害执行一次 `5.0x` 反击；BossConfig 已统一为 no-STUN。初始 RED
  `report_1627`、runtime refinement RED `report_1628`；focused GREEN
  `report_1629` 通过 `2/2`，final bounded related `report_1630` 通过
  `24/24`，target smoke 通过。Godot `4.7-stable` / MCP `2.9.2` 最终 run
  `r19802568-24` 验证玩家 `100 -> 100 HP`、Boss `160 -> 110 HP`、一次
  `50` damage counter、无 STUN、三帧角色、现有金色残影与 clean logs。

- Combat Presentation Story 016: Perfect Parry Gold Afterimage Feedback --
  真实 Main PERFECT 弹反继续由 CombatComponent 判定；Main 只补充当前
  `AnimatedSprite2D` 帧、位置与朝向元数据，CombatPresentation 生成一个稳定
  `PerfectParryGoldAfterimage`，使用代码内 ShaderMaterial 输出 `#ECC94B`
  纯色猫形剪影，沿朝向反向偏移 `12px`，alpha `0.82`，`0.35s` 后释放。
  初始 RED `report_1621`；MCP 视觉修正 RED `report_1624`；focused GREEN
  `report_1625` 通过 `1/1`；final related `report_1626` 通过 `51/51`；target
  smoke 通过。Godot `4.7-stable` / MCP `2.9.2` 最终 run
  `r18602105-22` 验证三帧 parry、同帧纹理、ShaderMaterial、位置偏移、生命周期、
  非空 `1278x718` 截图、3 条 info-only game log、0 条 editor log 和 clean stop。

- Death & Respawn Story 008: Main Scene Death Greyout + Revive Halo Feedback --
  真实 Main lethal damage 继续由 GameFlowController 持有 `1.5s` 死亡计时，
  CombatPresentation 增加 `0.5s` 全屏灰度淡入、8 个 image-generated 猫眼金
  灵魂光点、复活后 `0.5s` 灰度淡出和 `1.0s` 金色光环；既有三帧
  `death/revive`、`50% HP` 与 2 秒无敌不变。RED `report_1611` 锁定合同；
  MCP 生命周期竞态 RED `report_1614`、保色层级 RED `report_1617` 均已修复；
  最终 bounded related `report_1620` 通过 `47/47`，target smoke 通过。
  Godot `4.7-stable` / MCP `2.9.2` 最终 run `r17306475-20` 重放
  `death_hold -> revive_fade_out -> revive_halo -> idle`，game log 仅 3 条
  info、editor log 0 行；两张 `1278x718` 截图可见灰色世界上的金色光点
  与复活光环。

- Player Abilities Story 154: Main Scene Low-HP Focus Activation Feedback --
  真实 Main 在 active enemy 存在且 Player 降至 `25/100 HP` 时显示 image-generated
  `FocusModeActivationOverlay`，读取 Health metadata 的 `#ECC94B` 与 `0.3s`，
  同时路由既有 `sfx_focus_mode_activate`。RED `report_1604` 产生 `2` 个预期
  failure；focused GREEN `report_1607` 通过 `1/1`，bounded related
  `report_1610` 通过 `75/75`，target smoke 通过。Godot `4.7-stable` / MCP
  `2.9.2` 最终 run `r15524895-16` 验证生成纹理、稳定 TextureRect、
  `1.0 -> 0.5 -> 0.0` alpha 生命周期、非空 `1278x718` 截图以及 clean logs。

- Player Abilities Story 153: Main Scene Autosave Paw Stamp Feedback -- Main
  接受 savepoint、Boss 或 ability autosave 后，在右上小地图下方显示稳定
  `AutosavePawStamp`；它通过 `AtlasTexture` 复用既有 image-generated 猫爪，
  前 `1.0s` 常亮、最后 `0.5s` 淡出，并只在保存成功时路由一次 `ui_save`。
  RED `report_1597` 产生 `3` 个预期失败；最终 focused GREEN `report_1603`
  通过 `2/2`，bounded related `report_1602` 通过 `41/41`，target smoke 通过。
  Godot `4.7-stable` / MCP `2.9.2` 最终 run `r14231021-14` 以临时存档目录
  验证真实 Main autosave、音效 metadata、稳定 TextureRect/AtlasTexture、
  `1.0 -> 0.5 -> 0.0` alpha 生命周期、最大 HUD 缩放不遮挡、非空
  `1278x718` 截图、3 条 info-only game log、0 条 editor log 和 clean stop。

- Player Abilities Story 152: Main Scene Local Minimap Discovery Runtime --
  added a stable `120x120` code-drawn route map below currency, with filled vs
  hollow region shapes, current diamond and player triangle. Main supplies four
  authored regions, clamps the player marker to `1280x720`, reveals the real
  Dash gate destination over exactly `1.0s`, emits `Sewer Access discovered`,
  and restores from existing world flags without duplicate save state or
  replay. RED `report_1592` captured `6` expected failures; clean focused GREEN
  `report_1595` passed `2/2`; bounded related `report_1596` passed `45/45`;
  target smoke passed. Godot `4.7-stable` / MCP `2.9.2` final run
  `r12582583-12` verified `0.0 -> 0.5 -> 1.0`, persisted sewer flag, duplicate
  suppression, four live regions, the real HUD nodes, a non-empty `1278x718`
  capture, three info-only game rows, zero editor rows and clean stop to ready.

- Player Abilities Story 151: Skill Tree Electro Bell T1-A Pulse Touch -- added
  the fourth 1 SP weapon Build node while preserving Bell's one-instance,
  refresh-only slow rule. Light attack 1 now front-loads one effect to `45%`
  for `0.5s`, then returns to the `30%` baseline for the rest of its `2s` total;
  other stages refresh without duplicating or cancelling an active pulse. The
  existing generated Bell arc supplies three brighter hit arcs. Complete RED
  `report_1588` captured `7` expected failures across `3/3` cases; focused
  GREEN `report_1589` passed `3/3`; bounded related GREEN `report_1590` passed
  `73/73`; SchemaValidator `report_1591` passed `13/13`; target smoke passed.
  Godot `4.7-stable` / MCP `2.9.2` final run `r10990678-10` returned `ok=true`,
  verified exact `0.45 -> 0.30` timing, one slow, nine VFX, three-frame player
  `attack` and enemy `hurt`, target HP `288`, a non-empty `1278x718` capture,
  three info-only game rows and zero editor rows.

- Player Abilities Story 150: Skill Tree Fish Bone T1-A Heavy Shock -- added
  the approved third 1 SP Build node and carries a data-driven `8px` reaction
  through grounded Fish Bone heavy metadata into the target's collision-safe
  movement. Duplicate detection applies it once, walls clip the distance, hit
  metadata reports requested/applied movement, and the existing generated Fish
  Bone wave provides the contact pulse. RED `report_1579` captured `16`
  expected failures; bounded related GREEN `report_1582` passed `60/60`; final
  focused GREEN `report_1585` passed `4/4`; SchemaValidator `report_1586`
  passed `13/13`; target smoke passed with exact `8px` displacement and a
  clean exit. Godot `4.7-stable` / MCP `2.9.2` final
  run `r8347138-8` returned `ok=true`, verified three-frame `heavy_charge`,
  `heavy_attack` and target `hurt`, exact once-only `8px` movement, two VFX and
  target HP `52`; both `1278x718` captures are non-empty, game logs contain
  three info rows and editor logs contain zero rows.

- Player Abilities Story 149: Skill Tree Long Tail T1-A Choice -- added the
  approved `long_tail_t1a` 1 SP node, two-node HUD navigation with persistent
  selection, and a data-driven `0.3 tile / 9.6px` Long Tail first-stage range
  bonus that reaches the live Core hitbox without changing later stages or Cat
  Claw. RED `report_1568` reproduced the missing HUD contract; focused GREEN
  `report_1569` passed `3/3`; related GREEN `report_1570` passed `8/8`; fresh
  post-warning-fix `report_1571` passed `3/3`. Godot
  `4.7-stable` / MCP `2.9.2` selected and learned the node in `main`, measured
  `2.3 tiles / 73.6px`, captured a non-empty `1278x718` frame, and the final
  post-warning-fix restart returned info-only game logs plus zero editor rows.

- Player Abilities Story 148: Crown Warden Victory Recall To Scrap Roost --
  added one generated optional recall route after the Crown Core claim, durable
  proof with rollback, and an exact `main / scrap_roost` runtime handoff. Main
  recognizes only complete Boss4 proof, discovers the existing savepoint and
  records one secured-return flag/notification. Persistent Main restoration now
  also keeps defeated Rat King/Echo Guardian actors, collisions and Boss HUD
  inactive. Original `report_1564` passed `16/16`; correction RED `report_1565`
  and related GREEN `report_1567` passed `13/13`; target smoke passed. Godot
  `4.7-stable` / MCP `2.9.1` Run `r21750636-14` used physical `E`, captured two
  non-empty `1278x718` frames, returned three info-only game rows and added no
  editor errors after cursor `4`.

- Player Abilities Story 147: Crown Warden Wall Climb Reward Payoff -- added
  one generated Crown Core through shared `AbilityRewardSource`; Boss4 death
  reveals it once, grounded contact unlocks missing `wall_climb` or confirms
  the Story135 alternate path, exact `1.5s` feedback restores control, and
  arena/Tower/Main persistence retains unrelated state. Final focused
  `report_1559` passed `3/3`; bounded Story146/135 `report_1558` passed `9/9`;
  grounded-contact smoke passed. Godot `4.7-stable` / MCP `2.9.1` Run
  `r7762730-6` used real movement `(220,551.99) -> (633.33,551.99)`, captured
  two non-empty `1278x718` screenshots, returned helper/data-only current logs
  and added no editor row after cursor `4`.

- Player Abilities Story 146: Crown Warden Playable Boss4 Core -- added entity
  `2400` with data/schema-backed `160` HP, two exact real-hitbox attacks,
  chain-safe Phase II, Boss HUD, room seals, SceneManager lock, retry and
  persistent defeat/open return. Twenty-four generated transparent `192x192`
  frames provide eight three-frame `AnimatedSprite2D + SpriteFrames` states.
  Final focused `report_1551` passed `6/6`; shared collision `report_1552`
  passed `6/6`; bounded related `report_1553` passed `34/34`; target smoke
  passed. Godot `4.7-stable` / MCP `2.9.1` Run `r3362590-4` used real input and
  real overlaps for exact `12/18/14` damage, verified phase/retry/defeat/restore,
  captured two non-empty `1278x718` screenshots, returned only helper/data game
  logs and added no editor rows after cursor `4`.

- Player Abilities Story 141: Central Tower Inner Relay Skirmish -- expanded
  `area_05_central_tower` to `2560x720` with a generated Service Spine,
  deterministic `0.55/0.18/0.55s` relay pulse, one real strike-window parry,
  dual generated shutters, and entity `2702`, a distinct frame-animated Relay
  Mantis with `40` HP and a data-driven `20/6/20`, 12-damage scythe dash.
  Defeat opens the room and exposes one persistent `+20 Gears` cache; death
  before clear resets the attempt at the Threshold Roost while death-window
  clear and cache claim remain durable. Verification: RED `report_1503`;
  focused GREEN `report_1507` (`3/3`); independent review `report_1508`
  (`3/3`); Story140 adjacent `report_1509` (`3/3`); target smoke marker
  `central_tower_inner_relay_skirmish_smoke=passed`; MCP 2.9.1 / Godot 4.7
  run `65` used real parry input, inspected the live Mantis `run` animation,
  captured a non-empty `1278x718` frame, returned `current_run_errors=[]`,
  helper/data-only game logs, and no new editor rows after cursor `3`.

- Player Abilities Story 140: Central Tower Threshold Guard Handoff -- secured
  Story139 state now exposes one explicit Rooftops route to
  `area_05_central_tower / neon_rooftops_threshold_arrival`, while
  `central_tower_threshold_return` restores the open rooftop gate without
  replay. The generated `1280x720` Tower vestibule contains a real Threshold
  Roost, dual generated security seals, and entity `2701`, a unique heavy guard
  with six three-frame `96x96` animations, `48` HP, a `24/6/24` latch thrust,
  and `14` shared-pipeline damage. Death revives at 50% HP and resets an
  uncleared attempt at the valid arrival standing position with immediate control
  plus 120 i-frame protection; defeat, including during the death window, opens
  both seals and persists durable clear.
  Verification: RED `report_1493`; import-gated attempt `report_1494`; focused
  GREEN `report_1495` (`3/3`); Story139 regression `report_1496` (`3/3`);
  post-review focused GREEN `report_1497` (`3/3`);
  final consolidated `report_1500` (`6/6`); real bidirectional SceneManager
  and review-closure focused `report_1501` (`3/3`); real bidirectional
  SceneManager smoke marker `central_tower_threshold_guard_handoff_smoke=passed`
  also proved cache-window reuse of the same cleared Tower instance;
  Godot MCP 2.9.1 run `62` on Godot 4.7 inspected `44` authored and `78`
  runtime nodes, drove real movement into the encounter, captured a non-empty
  `1278x718` frame with Cinderpaw, guard and both closed seals, and found no
  current-run game error or editor row after cursor `3`.

- Player Abilities Story 116: Old Factory Lower Deck Forward Pressure
  Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Exit Hatch
  Handoff -- after Story115 claims the service sluice reward cache, a reused
  image-generated deep-bulkhead hatch appears at `Vector2(11680, 392)`. The
  hatch is locked until
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_claimed=true`,
  uses endpoint id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch`,
  progresses prompts from `Claim service sluice cache` to `Open Service Exit`
  to `Service Exit Open`, opens once in range, plays one unlock VFX, clears
  collision blocking, and advances route feedback to
  `Service Sluice Exit Opened`. Restoring the opened state backfills the
  Story106-115 runoff/service-sluice chain so earlier traversal, hatch,
  skirmish, and reward states do not replay. Verification: RED
  `reports/report_1339/`; focused GREEN `reports/report_1340/report_2/`
  (`2/2`); related GREEN `reports/report_1342/report_1/` (`10/10`);
  headless smoke
  `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_exit_hatch_smoke.log`
  exit `0`; Godot MCP 2.9.1 on Godot 4.7 verified disk-reloaded hatch node,
  script, endpoint id, prompt text, texture/VFX assets, locked/available/opened
  runtime diagnostics, collision blocking before open and cleared after open,
  local-state persistence, current game log without errors, no new editor log
  rows after cursor `9`, and a non-empty game screenshot response.

- Player Abilities Story 115: Old Factory Lower Deck Forward Pressure
  Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Reward Cache
  -- after Story114 clears the service sluice Spark Rat, a reused
  image-generated lower-deck cache appears at `Vector2(11360, 410)`. The cache
  is locked until
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_cleared=true`,
  uses cache id/source
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache`,
  grants `20` gears once, rejects duplicate claims, and advances feedback from
  `Service Sluice Spark Rat Cleared` to
  `Service Sluice Cache Claimed +20 Gears`. Restoring the claimed state
  backfills the Story106-114 runoff/service-sluice chain so earlier traversal,
  hatch, sluice, and Spark Rat states do not replay. Verification: RED
  `reports/report_1336/`; focused GREEN `reports/report_1337/` (`2/2`);
  related GREEN `reports/report_1338/` (`8/8`); headless smoke
  `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_reward_cache_smoke.log`
  exit `0`; Godot MCP 2.9.1 on Godot 4.7 verified disk-reloaded cache node,
  script, texture, id/source, reward `20`, locked/available/claimed runtime
  diagnostics, duplicate claim rejection, route label update, current game log
  without errors, no new editor log rows after cursor `9`, and a non-empty
  game screenshot showing Cinderpaw and the service sluice reward cache.

- Player Abilities Story 114: Old Factory Lower Deck Forward Pressure
  Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Skirmish --
  after Story113 crosses the runoff outlet service sluice, a reused
  image-generated Factory Spark Rat appears at `Vector2(11120, 482)`.
  The skirmish is locked until
  `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_crossed=true`,
  activates at x `10920`, enables entity `2142`, assigns Cinderpaw as target,
  starts opening grace `12`, and advances route feedback to
  `Clear Service Sluice Spark Rat`. Defeating entity `2142` hides/disables the
  enemy, persists activated/defeated/cleared local state, advances feedback to
  `Service Sluice Spark Rat Cleared`, and backfills the Story106-113 runoff
  chain on restore. Verification: RED `reports/report_1330/`; final focused
  GREEN `reports/report_1334/` (`2/2`); final related GREEN
  `reports/report_1335/` (`12/12`); headless smoke
  `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_skirmish_smoke.log`
  exit `0`; Godot MCP 2.9.1 on Godot 4.7 verified disk-reloaded Spark Rat node,
  right wall x `11500`, camera/background `11520`, ground right edge x `11700`,
  entity `2142`, SpriteFrames path and `3` frames for
  `idle/run/attack_tell/attack/hurt/death`, runtime activation/defeat/restore
  contracts, current game log without errors, no new editor log rows after
  cursor `9`, and a non-empty game screenshot showing Cinderpaw with the active
  Spark Rat in the service sluice combat pocket.

- Player Abilities Story 113: Old Factory Lower Deck Forward Pressure
  Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Traverse --
  after Story112 opens the runoff outlet service hatch, a new image-generated
  service sluice landing appears at x `10480` with a reused steam vent hazard
  at x `10540`. The traverse activates at x `10160`, uses hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice`,
  cycles through the standard steam pressure timing, completes at x `10720`,
  extends route bounds to right wall x `10940` / camera limit `10960`, advances
  route feedback through `Runoff Outlet Service Hatch Open`,
  `Cross Runoff Outlet Service Sluice`, and
  `Runoff Outlet Service Sluice Crossed`, and persists active/crossed state
  while backfilling the Story106-112 runoff chain on restore. Verification:
  RED `reports/report_1323/`; focused GREEN `reports/report_1328/` (`2/2`);
  related GREEN `reports/report_1329/` (`10/10`); scripted headless smoke
  `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_script_smoke.log`
  exit `0` with `service_sluice_smoke=passed`; Godot MCP 2.9.1 on Godot 4.7
  verified disk-reloaded duct/steam-vent nodes, generated texture path, hazard
  id/damage/cooldown, runtime hatch-open/activation/active-contact/completion
  diagnostics, `current_run_errors=[]`, current-run game log without errors,
  no new editor log rows after cursor `9`, and a non-empty game screenshot
  showing the service hatch, generated service sluice landing, and steam vent.

- Player Abilities Story 112: Old Factory Lower Deck Forward Pressure
  Aftershock Condenser Overflow Pump Runoff Outlet Reward Cache -- after
  Story111 clears the runoff outlet Spark Rat, a reused factory cache appears
  at x `9520`, pays `20` gears once, and reveals a reused service hatch at
  x `9880`. Opening the hatch disables blocking collision, advances route
  feedback to `Runoff Outlet Service Hatch Open`, extends the right-side route
  bounds to right wall x `10220` / camera limit `10240`, and persists
  cache-claimed/service-hatch-opened state while backfilling the
  Story106/107/108/109/110/111 runoff chain on restore. Verification: RED
  `reports/report_1311/`; focused GREEN `reports/report_1319/` (`2/2`);
  related GREEN `reports/report_1320/` (`8/8`); final post-format focused
  rerun `reports/report_1321/` (`2/2`) and related rerun
  `reports/report_1322/` (`8/8`); headless smoke
  `reports/old_factory_overflow_pump_runoff_outlet_reward_cache_smoke.log`
  exit `0`; Godot MCP 2.9.1 on Godot 4.7 verified disk-reloaded cache/hatch
  nodes, scripts, prompts, ids, right wall and camera limits, runtime cache
  claim + hatch open diagnostics, `current_run_errors=[]`, current-run game log
  without errors, no new editor log rows after cursor `9`, and a non-empty
  `960x539` game screenshot showing the claimed cache and opened hatch. No new
  visual asset was generated; Story112 reuses imported image-generated factory
  cache, service hatch, unlock spark, and floor visuals.

- Player Abilities Story 111: Old Factory Lower Deck Forward Pressure
  Aftershock Condenser Overflow Pump Runoff Outlet Skirmish -- after Story110
  crosses the runoff outlet, a reused multi-frame Factory Spark Rat activates
  at x `9280` and forces a short skirmish in the newly extended right-side
  pocket. The encounter uses entity id `2141`, binds the existing
  `AnimatedSprite2D + SpriteFrames` Spark Rat animation resource, keeps
  `idle/run/attack_tell/attack/hurt/death` at `3` frames each, persists
  activated/defeated/cleared state, and backfills the Story106/107/108/109/110
  runoff chain on restore. Verification: RED `reports/report_1300/`; focused
  GREEN `reports/report_1309/` (`2/2`); related GREEN
  `reports/report_1310/` (`8/8`); headless smoke
  `reports/old_factory_overflow_pump_runoff_outlet_skirmish_smoke.log` exit
  `0`; Godot MCP 2.9.1 on Godot 4.7 verified disk-reloaded scene node,
  runtime activation diagnostics, SpriteFrames path/frame counts,
  `current_run_errors=[]`, helper live, and a non-empty `960x539` game
  screenshot showing the Spark Rat.

- Player Abilities Story 110: Old Factory Lower Deck Forward Pressure
  Aftershock Condenser Overflow Pump Runoff Outlet Traverse -- after Story109
  opens the runoff exit gate, the route extends to the right with reused
  generated floor/duct visuals and a reused steam vent hazard. The pocket
  activates at x `8480`, cycles through the standard steam timing window,
  completes at x `9060`, persists the crossed state, and backfills the
  Story106/107/108/109 runoff chain so prior cache/skirmish/duct states do not
  replay. Verification: RED `reports/report_1297/`; focused GREEN
  `reports/report_1298/` (`2/2`); related GREEN `reports/report_1299/`
  (`9/9`); headless smoke
  `reports/old_factory_overflow_pump_runoff_outlet_traverse_smoke.log` exit
  `0`; Godot MCP 2.9.1 on Godot 4.7 verified disk-reloaded scene nodes,
  runtime duct/steam vent nodes, texture/script/hazard bindings,
  `current_run_errors=[]`, clean current game/editor logs, and a non-empty
  `960x539` game screenshot response.

- Player Abilities Story 109: Old Factory Lower Deck Forward Pressure
  Aftershock Condenser Overflow Pump Runoff Exit Reward Cache -- after Story108
  clears the runoff exit skirmish, a reused image-generated cache appears,
  pays `20` gears once, then reveals a reused image-generated deep-bulkhead
  runoff exit gate. Opening the gate disables blocking collision and advances
  route feedback to `Overflow Pump Runoff Exit Gate Open`; restored state
  backfills the Story106/107/108 chain so the duct/skirmish/cache do not replay.
  Verification: RED `reports/report_1293/`; focused GREEN
  `reports/report_1294/` (`2/2`); related GREEN `reports/report_1295/`
  (`8/8`); pre-push focused rerun `reports/report_1296/` (`2/2`);
  headless smoke
  `reports/old_factory_overflow_pump_runoff_exit_reward_cache_smoke.log` exit
  `0`; Godot MCP 2.9.1 on Godot 4.7 verified disk-reloaded scene nodes,
  runtime cache/gate scripts, IDs, prompts, reused texture bindings,
  `current_run_errors=[]`, clean current game/editor logs, and a non-empty
  `960x539` game screenshot response.

- Player Abilities Story 108: Old Factory Lower Deck Forward Pressure
  Aftershock Condenser Overflow Pump Runoff Exit Skirmish -- after Story107
  crosses the overflow pump runoff duct, the route extends to right wall
  x `8300` / camera limit `8320` and arms a reused multi-frame Factory Coil Rat
  at x `7800`. The skirmish persists activated/defeated/cleared state, backfills
  the Story106/107 overflow pump chain on restore, and advances route feedback
  to `Clear Overflow Pump Runoff Exit` and `Overflow Pump Runoff Exit Cleared`.
  Verification: RED `reports/report_1289/`; focused GREEN
  `reports/report_1291/` (`2/2`); related GREEN `reports/report_1292/`
  (`11/11`); headless smoke
  `reports/old_factory_overflow_pump_runoff_exit_skirmish_smoke.log` exit `0`;
  Godot MCP 2.9.1 on Godot 4.7 verified disk-reloaded scene node, runtime
  target Coil Rat with `AnimatedSprite2D`, SpriteFrames binding, right wall
  x `8300`, camera limit right `8320`, far-right route floor texture,
  `current_run_errors=[]`, clean current game/editor logs, and a non-empty
  `960x539` game screenshot response.

- Player Abilities Story 107: Old Factory Lower Deck Forward Pressure
  Aftershock Condenser Overflow Pump Runoff Duct Traverse -- after Story106
  opens the overflow pump runoff hatch, a reused image-generated cooling duct
  becomes visible as the next horizontal traversal pocket and a reused
  image-generated steam vent cycles through `grace -> warning -> active ->
  safe`. Active contact applies `8` steam damage with source
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_duct`;
  crossing x `7560` persists activated/crossed flags and advances route feedback
  to `Overflow Pump Runoff Duct Crossed`. Verification: RED
  `reports/report_1286/`; focused GREEN `reports/report_1287/` (`2/2`);
  related GREEN `reports/report_1288/` (`9/9`); headless smoke
  `reports/old_factory_overflow_pump_runoff_duct_smoke.log` exit `0`; Godot MCP
  2.9.1 on Godot 4.7 verified disk-reloaded scene nodes, right wall x `7660`,
  camera limit right `7680`, runtime duct/vent diagnostics, active-window
  damage, crossed local-state persistence, clean current game log, empty
  current-run editor logger, and a non-empty `960x539` game screenshot response
  showing the runoff duct and steam vent.

- Player Abilities Story 106: Old Factory Lower Deck Forward Pressure
  Aftershock Condenser Overflow Pump Reward Cache -- after Story099 clears the
  overflow pump skirmish, a reused image-generated lower-deck cache becomes
  visible, pays `20` gears once, and unlocks a reused image-generated runoff
  hatch. Opening the hatch persists the new state, removes blocking collision,
  and advances route feedback to `Overflow Pump Runoff Hatch Open`.
  Verification: RED `reports/report_1282/`; focused GREEN
  `reports/report_1284/` (`2/2`); related GREEN `reports/report_1285/`
  (`15/15`); headless smoke
  `reports/old_factory_overflow_pump_reward_cache_smoke.log` exit `0`;
  Godot MCP 2.9.1 on Godot 4.7 verified disk-reloaded scene nodes, runtime
  cache/hatch diagnostics, claim/open calls, clean current game log, local-state
  persistence, and a non-empty `960x539` game screenshot response showing
  `Runoff Hatch Open`.

- Player Abilities Story 105: Main Scene Gate Prompt Proximity -- ability gate
  prompts now use a finite provider proximity radius separate from unlock
  radius. `ExplorationGate` exposes `prompt_radius_px`,
  `is_provider_in_prompt_range()`, `get_prompt_text()`, and
  `is_prompt_visible()`, and refreshes prompt visibility while a Node2D
  provider exists without changing Dash/DoubleJump/Parry unlock behavior.
  Verification: RED `reports/report_1279/`; focused GREEN
  `reports/report_1280/` (`5/5`); related GREEN `reports/report_1281/`
  (`18/18`); Godot MCP 2.9.1 on Godot 4.7 verified MainScene live with
  `current_run_errors=[]`, clean current game log, runtime gate diagnostics,
  and a non-empty screenshot at
  `reports/visual/cinderpaw-mcp-main-scene-gate-prompt-proximity-20260710.png`
  showing no far-away `Requires Double Jump` or `Requires Dash` prompt clutter.

- Player Abilities Story 104: Main Scene Reward Prompt Proximity -- reward
  prompts now use a finite provider proximity radius separate from claim radius.
  `AbilityRewardSource` exposes `prompt_radius_px` and
  `set_prompt_provider(provider)`, and MainScene passes the player into hidden
  and Boss2 Double Jump reward sources during sync/process. Far-away
  `Claim Double Jump` prompts are hidden while reward availability, once-only
  claim, save-state, Boss2 room seal, Double Jump gate, and factory route
  handoff behavior remain intact. Verification: RED `reports/report_1275/`;
  focused GREEN `reports/report_1277/` (`3/3`); related GREEN
  `reports/report_1278/` (`9/9`); Godot MCP 2.9.1 on Godot 4.7 verified
  MainScene live with `current_run_errors=[]`, clean current game log, runtime
  prompt diagnostics, and a non-empty screenshot at
  `reports/visual/cinderpaw-mcp-main-scene-reward-prompt-proximity-20260710.png`
  showing no far-away `Claim Double Jump` prompt over the Boss2 arena.

- Player Abilities Story 100: Main Scene Dash Gate Authored Visual Replacement
  -- `DashExplorationGate/Visual` in `scenes/main.tscn` now uses the dedicated
  image-generated transparent runtime texture
  `res://assets/environment/dash_gate/dash_gate_marker.png` instead of the
  reused Rat King arena electric leak. The generated source/alpha/runtime assets
  are recorded under `assets/generated/source/` and `assets/environment/dash_gate/`,
  imported through Godot, and documented in asset manifest plus QA evidence. The
  visual no longer needs the old `1.5708` rotation or non-uniform scaling, while
  Story002 Dash gate unlock/save behavior remains intact. Verification: RED
  `reports/report_1254/`; focused GREEN `reports/report_1255/` (`2/2`);
  related GREEN `reports/report_1256/` (`8/8`); headless smoke
  `reports/dash_gate_authored_visual_main_scene_smoke.log` exit `0`; Godot MCP
  2.9.1 on Godot 4.7 verified disk-reloaded MainScene, editor/runtime Dash gate
  texture, `current_run_errors=[]`, Cinderpaw `AnimatedSprite2D`, and a non-empty
  runtime screenshot showing the authored Dash gate.

- Player Abilities Story 099: Old Factory Lower Deck Forward Pressure
  Aftershock Condenser Overflow Pump Skirmish -- after Story098 crosses the
  aftershock condenser outlet drip vent, a newly image-generated transparent
  overflow pump becomes visible as
  `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPump`, the route
  extends to x `7040.0`, and a reused image-generated Factory Coil Rat
  `AnimatedSprite2D + SpriteFrames` scene activates as entity id `2139` at the
  runoff pocket. The skirmish stays locked until
  `factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent_crossed=true`,
  starts at x `6540.0`, assigns the player target, starts `10` opening-grace
  frames, advances feedback to `Clear Overflow Pump Skirmish`, then persists
  activated/defeated/cleared flags and advances route feedback to
  `Overflow Pump Cleared` after defeating entity `2139`. Verification: RED
  `reports/report_1250/`; focused GREEN `reports/report_1252/` (`2/2`);
  related GREEN `reports/report_1253/` (`10/10`); headless smoke
  `reports/old_factory_aftershock_condenser_overflow_pump_skirmish_smoke.log`
  exit `0`; Godot MCP 2.9.1 on Godot 4.7 verified scene reload, generated prop,
  active frame-animated Coil Rat, entity damage/clear persistence, clean
  current-run logs, and a non-empty runtime screenshot.

- Player Abilities Story 098: Old Factory Lower Deck Forward Pressure
  Aftershock Condenser Outlet Drip Vent Traverse -- after Story097 clears the
  aftershock condenser outlet clamp ambush, a newly image-generated transparent
  drain gantry becomes visible as
  `FactoryLowerDeckForwardPressureAftershockCondenserDrainGantry`, the route
  extends to x `6400.0`, and a reused image-generated Old Factory steam vent
  becomes
  `FactoryLowerDeckForwardPressureAftershockCondenserOutletDripVentHazard` with
  hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet_drip_vent`.
  The traverse stays locked until
  `factory_lower_deck_forward_pressure_aftershock_condenser_outlet_clamp_ambush_cleared=true`,
  activates at x `5840.0`, cycles deterministic `grace -> warning -> active ->
  safe` phases, applies `8` player contact damage only during the active phase,
  persists activated/crossed local-state flags at x `6260.0`, and advances route
  feedback to `Outlet Drip Vent Crossed`. MCP runtime validation also exposed a
  current-run collision-state mutation during player death; `PlayerController`
  and `CollisionComponent` now defer hitbox/hurtbox state changes when inside a
  physics frame. Verification: RED `reports/report_1244/`; focused GREEN
  `reports/report_1245/` (`2/2`); initial related GREEN `reports/report_1246/`
  (`20/20`); shared collision-state focused GREEN `reports/report_1247/`
  (`14/14`); final related GREEN `reports/report_1248/` (`32/32`);
  commit-prep focused GREEN `reports/report_1249/report_1/` (`2/2`); headless
  smoke
  `reports/old_factory_aftershock_condenser_outlet_drip_vent_traverse_smoke.log`
  exit `0`; Godot MCP 2.9.1 on Godot 4.7 verified scene reload, generated prop,
  active-only hazard damage, crossed-state persistence, death/respawn path
  without new physics-query state-change errors, clean current-run logs, and a
  non-empty runtime screenshot.

- Player Abilities Story 097: Old Factory Lower Deck Forward Pressure
  Aftershock Condenser Outlet Clamp Ambush -- after Story096 crosses the
  aftershock condenser outlet, a newly image-generated transparent clamp prop
  becomes visible as
  `FactoryLowerDeckForwardPressureAftershockCondenserOutletClamp`, the route
  extends to x `5760.0`, and a reused image-generated Factory Spark Rat
  `AnimatedSprite2D + SpriteFrames` scene activates as entity id `2138` at the
  outlet clamp pocket. The ambush stays locked until
  `factory_lower_deck_forward_pressure_aftershock_condenser_outlet_crossed=true`,
  starts at x `5220.0`, assigns the player target, advances feedback to
  `Clear Outlet Clamp Ambush`, then persists activated/defeated/cleared flags
  and advances route feedback to `Outlet Clamp Ambush Cleared` after defeating
  entity `2138`. Verification: RED `reports/report_1240/` and
  `reports/report_1241/`; focused GREEN `reports/report_1242/` (`2/2`);
  related GREEN `reports/report_1243/` (`18/18`); headless smoke
  `reports/old_factory_aftershock_condenser_outlet_clamp_ambush_smoke.log`
  exit `0`; Godot MCP 2.9.1 on Godot 4.7 verified scene reload, generated prop,
  active frame-animated Spark Rat, entity damage/clear persistence, clean
  current-run logs, and a non-empty runtime screenshot.

- Player Abilities Story 096: Old Factory Lower Deck Forward Pressure
  Aftershock Condenser Outlet Traverse -- after Story095 activates the
  aftershock condenser savepoint, `FactoryLowerDeckForwardPressureAftershockCondenserOutlet`
  becomes visible as a new image-generated transparent outlet duct/walkway prop
  at x `4740.0`, and the route extends to x `5120.0`. The outlet stays
  hidden/unavailable until
  `factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated=true`;
  crossing x `4560.0` starts a deterministic steam cycle, active phase enables
  the reused `FactoryLowerDeckForwardPressureAftershockCondenserOutletVent`
  hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_outlet` for
  `8` contact damage, and crossing x `5020.0` persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_outlet_activated=true`
  plus
  `factory_lower_deck_forward_pressure_aftershock_condenser_outlet_crossed=true`
  with route feedback `Aftershock Condenser Outlet Crossed`. Verification:
  initial RED `reports/report_1235/`; focused GREEN `reports/report_1237/`
  `2/2`; related GREEN `reports/report_1238/` `16/16`; final focused GREEN
  `reports/report_1239/` `2/2`; headless smoke
  `reports/old_factory_aftershock_condenser_outlet_traverse_smoke.log` exited
  `0` with no project script/parse/invalid-call/access/missing-resource/
  resource-load errors by keyword scan. Godot AI MCP `2.9.1` on Godot
  `4.7-stable` confirmed scene reload from disk, helper live, runtime outlet
  and vent nodes, generated outlet texture path, hazard active-phase hit
  `100 -> 92`, crossed persistence, current-run clean game/editor log evidence,
  and a non-empty `960x539` game screenshot showing the generated outlet duct,
  reused steam vent, and player.

- Player Abilities Story 095: Old Factory Lower Deck Forward Pressure
  Aftershock Condenser Savepoint -- after Story094 secures the aftershock
  condenser landing, `FactoryLowerDeckForwardPressureAftershockCondenserSavepoint`
  becomes visible as a new image-generated transparent repair relay prop at
  x `4380.0`. The relay stays hidden/non-interactive until
  `factory_lower_deck_forward_pressure_aftershock_condenser_valve_cleared=true`,
  activates through `SavepointRuntime`, records last savepoint id
  `old_factory_lower_deck_forward_pressure_aftershock_condenser_savepoint`,
  persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_savepoint_activated=true`,
  reconstructs its checkpoint snapshot on local-state restore when needed, and
  respawns SceneManager handoff point
  `lower_deck_forward_pressure_aftershock_condenser_savepoint` with route
  feedback `Returned to Aftershock Condenser Savepoint`. Verification: initial
  RED `reports/report_1232/`; focused GREEN `reports/report_1233/` `2/2`;
  related GREEN `reports/report_1234/` `19/19`; headless smoke
  `reports/old_factory_aftershock_condenser_savepoint_smoke.log` exited `0`
  with no project script/parse/invalid-call/access/missing-resource/
  resource-load errors by keyword scan. Godot AI MCP `2.9.1` on Godot
  `4.7-stable` confirmed scene reload from disk, helper live, runtime
  savepoint node and generated texture, Story094-clear gating, successful
  activation, persisted last savepoint snapshot, clean final game/editor logs,
  and a non-empty `960x539` game screenshot showing the generated savepoint
  relay and prompt `Repair Condenser Relay`.

- Player Abilities Story 094: Old Factory Lower Deck Forward Pressure
  Aftershock Condenser Valve Ambush -- after Story093 crosses the aftershock
  cooling duct, `FactoryLowerDeckForwardPressureAftershockCondenserValve`
  becomes visible as a new image-generated transparent condenser valve/fan prop
  and the route extends to x `4560.0`. The landing activates near x `3920.0`,
  starts a Spark Rat entity `2136` plus Coil Rat entity `2137` ambush using the
  existing image-generated `AnimatedSprite2D + SpriteFrames` character assets,
  assigns the player as target, enables process/physics for both enemies,
  persists
  `factory_lower_deck_forward_pressure_aftershock_condenser_valve_activated=true`,
  `..._spark_rat_defeated=true`, `..._coil_rat_defeated=true`, and
  `..._cleared=true`, and advances route feedback to
  `Aftershock Condenser Landing Secured`. Verification: initial RED
  `reports/report_1229/`; focused GREEN `reports/report_1230/` `2/2`;
  related GREEN `reports/report_1231/` `6/6`; headless smoke
  `reports/old_factory_aftershock_condenser_valve_ambush_smoke.log` exited `0`
  with no project script/parse/invalid-call/access/missing-resource/
  resource-load errors by keyword scan. Godot AI MCP `2.9.1` on Godot
  `4.7-stable` confirmed scene reload from disk, helper live, runtime valve,
  Spark Rat, and Coil Rat nodes, active enemies visible and targeted, clear/
  restore persistence, clean final game/editor logs, and a non-empty `960x539`
  game screenshot showing the generated valve with animated enemies.

- Player Abilities Story 093: Old Factory Lower Deck Forward Pressure
  Aftershock Cooling Duct Traverse -- after Story092 opens the aftershock
  exhaust exit hatch, `FactoryLowerDeckForwardPressureAftershockCoolingDuct`
  becomes visible as a new image-generated transparent duct prop at x `3500.0`
  and the route extends to x `3840.0`. The traverse activates near x `3240.0`,
  runs a timed steam hazard using hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_cooling_duct`, enables
  `8` contact damage only during the active phase, completes beyond x `3740.0`,
  persists
  `factory_lower_deck_forward_pressure_aftershock_cooling_duct_activated=true`
  and
  `factory_lower_deck_forward_pressure_aftershock_cooling_duct_crossed=true`,
  and advances route feedback to `Aftershock Cooling Duct Crossed`.
  Verification: initial RED `reports/report_1223/`; import RED
  `reports/report_1224/`; focused GREEN `reports/report_1225/` `2/2`;
  related GREEN `reports/report_1226/` `4/4`; post-warning-fix GREEN
  `reports/report_1227/` `4/4`; final auto-complete GREEN
  `reports/report_1228/` `4/4`; headless smoke
  `reports/old_factory_aftershock_cooling_duct_traverse_smoke.log` exited `0`
  with no project script/parse/invalid-call/access/missing-resource/
  resource-load/shadowed-variable errors by keyword scan. Godot AI MCP `2.9.1`
  on Godot `4.7-stable` confirmed scene reload from disk, helper live, runtime
  duct and vent nodes, generated duct texture path, route extension, locked/
  ready/active/crossed diagnostics, `_process` activation and automatic exit
  completion, persisted crossed state, clean final game/editor logs, and a
  non-empty `960x539` game screenshot showing the generated duct and steam vent.

- Player Abilities Story 092: Old Factory Lower Deck Forward Pressure
  Aftershock Exhaust Exit Hatch Handoff -- after Story091 clears the aftershock
  exhaust escape skirmish, `FactoryLowerDeckForwardPressureAftershockExhaustExitHatch`
  becomes visible near x `3160.0` using the imported image-generated deep
  bulkhead hatch prop and the existing image-generated unlock spark. The hatch
  starts hidden/locked, exposes `Open Exhaust Hatch` after Story091 is cleared,
  opens once for an in-range provider, disables its blocker, persists
  `factory_lower_deck_forward_pressure_aftershock_exhaust_exit_hatch_opened=true`,
  rejects duplicate activation, and advances route feedback to
  `Aftershock Exhaust Exit Opened`. Verification: initial focused RED
  `reports/report_1218/`; focused GREEN `reports/report_1219/` `2/2`;
  initial related RED `reports/report_1220/` captured outdated Story091 route
  expectations; final related GREEN `reports/report_1221/` `17/17`; headless
  smoke
  `reports/old_factory_forward_pressure_aftershock_exhaust_exit_hatch_smoke.log`
  exited `0` with no project script/parse/invalid-call/access/missing-resource/
  resource-load/shadowed-variable errors by keyword scan. Godot AI MCP `2.9.1`
  on Godot `4.7-stable` confirmed scene reload from disk, helper live, runtime
  hatch node/properties, locked/ready/opened/restored diagnostics, one-shot
  open with duplicate `false`, VFX spawn count `1`, clean final game/editor
  logs, and a non-empty `960x539` game screenshot showing the opened hatch.

- Player Abilities Story 091: Old Factory Lower Deck Forward Pressure
  Aftershock Exhaust Escape Skirmish -- after Story090 cuts the aftershock
  exhaust breaker, Cinderpaw can push to x `3112.0` to activate
  `FactoryLowerDeckForwardPressureAftershockExhaustEscapeSkirmishSparkRat` as
  entity `2134` and
  `FactoryLowerDeckForwardPressureAftershockExhaustEscapeSkirmishCoilRat` as
  entity `2135`. The slice reuses image-generated Factory Spark Rat and
  Factory Coil Rat `AnimatedSprite2D + SpriteFrames` assets with 3-frame
  `idle/run/attack_tell/attack/hurt/death` animations, assigns the player as
  target, enables process/physics for both enemies, staggers opening grace
  frames `10/22`, persists partial/full defeat through scene-local state, and
  advances route feedback from `Break Aftershock Exhaust Escape` to
  `Aftershock Exhaust Escape Secured`. MCP exposed a stale freed-node
  diagnostics bug after both enemies died and local state was restored; fixed
  by validating enemy references before diagnostics, pacing, and entity/family
  lookups. Verification: initial RED `reports/report_1212/`; first focused
  GREEN `reports/report_1213/` `2/2`; stale-reference RED
  `reports/report_1215/`; final focused GREEN `reports/report_1216/` `2/2`;
  related GREEN `reports/report_1217/` `39/39`; headless smoke
  `reports/old_factory_forward_pressure_aftershock_exhaust_escape_skirmish_smoke.log`
  exited `0` with no project script/parse/invalid-call/access/missing-resource/
  resource-load/shadowed-variable errors by keyword scan. Godot AI MCP `2.9.1`
  on Godot `4.7-stable` confirmed helper live, active entities `2134/2135`,
  frame counts, route labels, `apply_damage(2134/2135, 999)=true`, persisted
  and resynced clear flags, service lift `Call lift`, clean final game/editor
  logs, and a non-empty `960x539` game screenshot.

- Player Abilities Story 089: Old Factory Lower Deck Forward Pressure
  Aftershock Exhaust Flank Ambush -- after Story088 claims the aftershock
  exhaust pursuer reward cache, Cinderpaw can push to x `2768.0` to activate
  `FactoryLowerDeckForwardPressureAftershockExhaustFlankAmbushSparkRat` as
  entity `2132` plus
  `FactoryLowerDeckForwardPressureAftershockExhaustFlankAmbushVent` using
  hazard id
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust_flank_ambush`.
  The slice reuses image-generated Factory Spark Rat
  `AnimatedSprite2D + SpriteFrames` art and the Old Factory steam vent prop,
  starts `14` opening-grace frames, applies `8` steam damage on player contact,
  persists activated/defeated/cleared flags, advances route feedback to
  `Forward Pressure Exhaust Flank Cleared`, and preserves the Story074 relay,
  optional `FactoryServiceLift`, Story068 no-replay, and Story071 audio
  no-replay contracts. MCP exposed a stale freed-node diagnostics bug after the
  Spark Rat death tween; fixed by validating enemy references before diagnostics
  and lookup. Verification: initial RED `reports/report_1198/`; pre-MCP GREEN
  `reports/report_1200/` `3/3`; stale-reference RED `reports/report_1202/`;
  final focused GREEN `reports/report_1205/` `3/3`; related GREEN
  `reports/report_1204/` `33/33`; headless smoke
  `reports/old_factory_forward_pressure_aftershock_exhaust_flank_ambush_smoke.log`
  exited `0` with no project script/parse/invalid-call/access/missing-resource/
  resource-load/shadowed-variable errors by keyword scan. Godot AI MCP `2.9.1`
  on Godot `4.7-stable` confirmed helper live, live Story088 claim-to-flank
  activation, SpriteFrames frame counts, hazard damage `100 -> 92`, settled
  clear diagnostics without stale-reference runtime error, clean final
  game/editor logs, and non-empty `960x539` game screenshot metadata.

- Player Abilities Story 088: Old Factory Lower Deck Forward Pressure
  Aftershock Exhaust Pursuer Reward Cache -- after Story087 clears the
  aftershock exhaust pursuer, `FactoryLowerDeckForwardPressureAftershockExhaustPursuerRewardCache`
  becomes visible and claimable at x `2664.0`. The payoff cache reuses the
  image-generated lower-deck reward cache prop, grants `20` gears exactly once
  through cache id/source
  `old_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache`,
  persists
  `factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed=true`,
  and advances route feedback to
  `Forward Pressure Exhaust Pursuer Cache Claimed +20 Gears`. No new visual or
  audio assets, character animation, enemy family, hazard, savepoint,
  service-lift route change, or global save schema were added. Verification:
  RED `reports/report_1195/`; focused GREEN `reports/report_1196/` `3/3`;
  related GREEN `reports/report_1197/` `26/26`; headless smoke
  `reports/old_factory_forward_pressure_aftershock_exhaust_pursuer_reward_cache_smoke.log`
  exited `0` with no project script/parse/invalid-call/access/missing-resource/
  resource-load/shadowed-variable errors by keyword scan. Godot AI MCP `2.9.1`
  on Godot `4.7-stable` confirmed helper live, live Story087 defeat-to-cache
  unlock, cache node properties, runtime texture path, first claim `true`,
  duplicate claim `false`, restored claimed state, Story074 relay, service
  lift `Call lift`, Story068/071 no-replay sentinels, clean final game/editor
  logs, and non-empty `960x539` game screenshot metadata.

- Player Abilities Story 087: Old Factory Lower Deck Forward Pressure
  Aftershock Exhaust Pursuer -- after Story086 crosses the aftershock exhaust,
  Cinderpaw can push to x `2552.0` to activate
  `FactoryLowerDeckForwardPressureAftershockExhaustPursuerCoilRat` as entity
  `2131`. The slice reuses the image-generated Factory Coil Rat
  `AnimatedSprite2D + SpriteFrames` asset, assigns the player as target,
  enables process/physics, starts `10` opening-grace frames, persists
  activated/defeated/cleared scene-local flags, and advances route feedback to
  `Forward Pressure Exhaust Pursuer Cleared`. No new visual/audio assets,
  enemy family, reward cache, savepoint, service-lift route change, or global
  save schema were added. Verification: RED `reports/report_1191/`; focused
  GREEN `reports/report_1192/` `2/2`; related GREEN `reports/report_1193/`
  `23/23`; headless smoke
  `reports/old_factory_forward_pressure_aftershock_exhaust_pursuer_smoke.log`
  exited `0` with no project script/parse/invalid-call/access/missing-resource/
  resource-load/shadowed-variable errors by keyword scan. Godot AI MCP
  `2.9.1` on Godot `4.7-stable` confirmed helper live, active entity `2131`,
  frame counts `idle/run/attack_tell/attack/hurt/death=3`, target/process/
  physics enabled, route label `Purge Aftershock Exhaust Pursuer`, clean final
  game/editor logs, and non-empty `960x539` game screenshot metadata.

- Player Abilities Story 073: Old Factory Lower Deck Forward Pressure Exit Guard
  -- after the Story071/072 forward-pressure reward cache payoff, Cinderpaw can
  cross the next boundary to activate a short exit guard fight. The slice adds
  `FactoryLowerDeckForwardPressureExitGuardSparkRat` as entity `2120` and
  `FactoryLowerDeckForwardPressureExitGuardVent` in
  `factory_route_transition_shell.tscn`. It reuses the image-generated Factory
  Spark Rat `AnimatedSprite2D + SpriteFrames` asset and the existing Old Factory
  steam vent hazard prop. The guard stays unavailable until
  `factory_lower_deck_forward_pressure_reward_cache_claimed=true`; activation
  assigns Cinderpaw as target, starts Spark Rat pacing, enables hazard id
  `old_factory_lower_deck_forward_pressure_exit_guard`, and updates route
  feedback to `Clear Forward Pressure Exit Guard`. Defeating entity `2120`
  hides/disables the enemy and hazard, persists
  `factory_lower_deck_forward_pressure_exit_guard_activated=true` and
  `factory_lower_deck_forward_pressure_exit_guard_defeated=true`, and advances
  route feedback to `Forward Pressure Exit Secured`. No new enemy family art,
  new room art, audio assets, SaveSystem schema, service-lift route changes,
  minimap markers, particles/shaders, or global quest state were added.
  Verification: RED `reports/report_1116/`; focused GREEN
  `reports/report_1117/report_5/` `2/2`; related GREEN
  `reports/report_1118/report_1/` `14/14`; headless smoke
  `reports/old_factory_forward_pressure_exit_guard_smoke.log` exited `0` with
  no project script/parse/invalid-call/access/missing-resource/resource-load
  errors by keyword scan. Godot AI MCP `2.8.3` on Godot `4.7-stable`
  confirmed helper live, active entity `2120`, frame counts
  `idle/run/attack_tell/attack/hurt/death=3`, active hazard
  id/damage/cooldown, route labels `Clear Forward Pressure Exit Guard` and
  `Forward Pressure Exit Secured`, persisted Story073 flags, no prerequisite
  replay, service lift `Call lift`, game log containing only helper
  registration, empty editor log, and non-empty screenshot metadata `960x539`.

- Player Abilities Story 072: Old Factory Lower Deck Forward Pressure Reward
  Cache Audio Feedback -- the Story071 forward-pressure reward cache now
  requests once-only spatial audio on the first successful claim. `AudioSystem`
  exposes `on_reward_cache_claimed(...)` and routes
  `reward_cache_claimed -> sfx_door_unlock` at priority `90` with
  `stream_found=true` and deterministic metadata for cache id/source,
  `gears/reward_gears`, scene id, feedback role, and world position.
  `OldFactoryEntranceScene` records `claim_audio_requested`,
  `claim_audio_request_count`, and `claim_audio_event` diagnostics from the
  fresh claim path only; duplicate claim and restored claimed state do not
  replay audio. No new audio/visual assets, SaveSystem schema, service-lift
  route changes, minimap markers, particles/shaders, or global reward-cache
  policy were added. Verification: RED `reports/report_1113/report_1/`;
  focused GREEN `reports/report_1114/report_2/` `26/26`; related GREEN
  `reports/report_1115/report_1/` `42/42`; headless smoke
  `reports/old_factory_forward_pressure_reward_cache_audio_smoke.log` exited
  `0` with no project script/parse/invalid-call/access/missing-resource/
  resource-load errors by keyword scan, aside from the known Godot cleanup-time
  resource message. Godot AI MCP `2.8.3` on Godot `4.7-stable` confirmed helper
  live, cache visible/claimable, first claim `true`, duplicate claim `false`,
  `claim_audio_request_count=1`, `reward_cache_claimed -> sfx_door_unlock`,
  `stream_found=true`, restored claimed no-replay, service lift `Call lift`,
  game log containing only helper registration, empty editor log, and non-empty
  screenshot metadata `960x539`.

- Player Abilities Story 071: Old Factory Lower Deck Forward Pressure Reward
  Cache -- after Story070 clears the forward pressure counter-ambush,
  `FactoryLowerDeckForwardPressureRewardCache` now appears as a visible,
  scene-local once-only payoff using the existing image-generated lower-deck
  cache prop. The cache stays hidden and non-claimable until
  `factory_lower_deck_forward_pressure_counter_ambush_defeated=true`, then
  shows prompt `+20 Gears`, uses cache id/source
  `old_factory_lower_deck_forward_pressure_reward_cache`, grants `20` gears on
  the first claim, rejects a second claim, records
  `Forward Pressure Cache Claimed +20 Gears`, and persists
  `factory_lower_deck_forward_pressure_reward_cache_claimed=true`. No new
  visual/audio assets, SaveSystem schema, minimap markers, service-lift route
  changes, or global quest state were added. Verification: RED
  `reports/report_1110/`; focused GREEN `reports/report_1111/` `2/2`;
  related GREEN `reports/report_1112/` `12/12`; headless smoke
  `reports/old_factory_forward_pressure_reward_cache_smoke.log` exited `0`
  with no project script/parse/invalid-call/access/missing-resource/resource-load
  errors by keyword scan, aside from the known Godot cleanup-time resource
  message. Godot AI MCP `2.8.3` on Godot `4.7-stable` confirmed helper live,
  cache hidden before Story070 clear, visible/claimable after Story070 clear,
  image-generated texture path, once-only `+20 Gears` claim, local-state
  persistence, no Story068-070 prerequisite replay, service lift `Call lift`,
  game log containing only helper registration, empty editor log, and non-empty
  screenshot metadata `960x539`.

- Player Abilities Story 070: Old Factory Lower Deck Forward Pressure
  Counter-Ambush -- after Story069 crosses the forward pressure traverse,
  crossing x `1336.0` now activates `FactoryLowerDeckForwardCounterSparkRat`
  entity `2119` and `FactoryLowerDeckForwardCounterPressureVent`. The encounter
  reuses the existing image-generated Factory Spark Rat `AnimatedSprite2D +
  SpriteFrames` asset and Old Factory steam vent prop; no new visual/audio
  assets, SaveSystem schema, minimap markers, service-lift route changes, or
  global quest state were added. While active, route feedback is
  `Survive Forward Pressure Ambush`, the pressure vent uses hazard id
  `old_factory_lower_deck_forward_pressure_counter_ambush`, damage `8`, and
  cooldown `1.0`, and `FactoryServiceLift` remains optional with prompt
  `Call lift`. Defeating entity `2119` hides/disables the enemy and hazard,
  persists `factory_lower_deck_forward_pressure_counter_ambush_activated=true`
  and `factory_lower_deck_forward_pressure_counter_ambush_defeated=true`, and
  advances route feedback to `Forward Pressure Ambush Cleared`. Verification:
  RED `reports/report_1107/`; focused GREEN `reports/report_1108/` `2/2`;
  related GREEN `reports/report_1109/` `14/14`; headless smoke
  `reports/old_factory_forward_pressure_counter_ambush_smoke.log` exited `0`
  with no project script/parse/invalid-call/access/missing-resource/resource-load
  errors by keyword scan, aside from the known Godot cleanup-time resource
  message. Godot AI MCP `2.8.3` on Godot `4.7-stable` confirmed helper live,
  active entity `2119`, frame counts `idle/run/attack_tell/attack/hurt/death=3`,
  active hazard state, defeat persistence, no Story067-069 prerequisite replay,
  service lift `Call lift`, clean game/editor logs, and non-empty screenshot
  metadata `960x539`.

- Player Abilities Story 069: Old Factory Lower Deck Forward Pressure Traverse
  -- `factory_route_transition_shell.tscn` now contains
  `FactoryLowerDeckForwardPressureVent`, a hidden `Area2D` pressure hazard
  reusing the existing image-generated
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`.
  After `factory_lower_deck_forward_conduit_defeated=true`, the vent is visible
  but non-contacting while Story068 route feedback remains
  `Forward Conduit Secured`. Crossing x `1284.0` starts a deterministic
  grace/warning/active/safe pressure cycle and updates route feedback to
  `Cross Forward Pressure Leak`; only the active phase enables contact damage.
  Crossing x `1328.0` succeeds once, persists
  `factory_lower_deck_forward_pressure_traverse_crossed=true`, hides/disables
  the vent, and advances route feedback to `Forward Pressure Traverse Crossed`.
  `FactoryServiceLift` remains optional with prompt `Call lift`; no new assets,
  enemies, reward caches, SaveSystem schema, minimap, service-lift route, or
  global quest state were added. Verification: RED `reports/report_1103/`;
  focused GREEN `reports/report_1104/` `2/2`; related GREEN
  `reports/report_1105/` `16/16`; Story015 stale-row isolation
  `reports/report_1106/` `5/5`; headless smoke
  `reports/old_factory_forward_pressure_traverse_smoke.log` exited `0` with no
  project script/parse/invalid-call/access/missing-resource/resource-load errors
  by keyword scan. Godot AI MCP `2.8.3` runtime confirmed helper live, pressure
  vent present, phase diagnostics, active-window damage `100 -> 92`, safe-window
  contact disabled, crossed persistence, Story068 clear burst `spawn_count=0`,
  inactive entity `2118`, service lift `Call lift`, clean game log except helper
  registration, and non-empty screenshot metadata `960x539`. Editor Debugger
  still surfaced pre-existing Story015 `CombatComponent` stale rows; fresh CLI
  isolation passed in `reports/report_1106/`.

- Player Abilities Story 068: Old Factory Lower Deck Forward Conduit Clear
  Feedback -- `factory_route_transition_shell.tscn` now contains
  `FactoryLowerDeckForwardConduitClearBurst`, a hidden `Sprite2D` reusing the
  existing image-generated
  `res://assets/environment/old_factory_overdrive_defeat_burst/vfx_old_factory_overdrive_defeat_burst_256.png`.
  Freshly defeating forward conduit entity `2118` shows the burst once at the
  Spark Rat position `(1188, 482)`, records `played=true`,
  `spawn_count=1`, `asset_source="image_generation"`, `vfx_role="forward_conduit_clear_feedback"`,
  and keeps the Story067 clear state intact: enemy/hazard hidden, route label
  `Forward Conduit Secured`, and `FactoryServiceLift` optional with prompt
  `Call lift`. Restored completed state hides the feedback with `played=false`
  and `spawn_count=0`, so save/local-state restoration does not replay the
  burst. No new visual/audio assets, SaveSystem schema, minimap, service-lift
  route, reward cache, or enemy content were added. Verification: RED
  `reports/report_1097/`; focused GREEN `reports/report_1101/` `2/2`;
  related GREEN `reports/report_1102/` `15/15`; headless smoke
  `reports/old_factory_forward_conduit_clear_feedback_smoke.log` exited `0`
  with only known Godot cleanup-time `2 resources still in use` noise. Godot AI
  MCP `2.8.3` runtime confirmed helper live, fresh defeat VFX visible with the
  reused texture, restored no-replay state, service lift `Call lift`, clean game
  log except helper registration, and non-empty game framebuffer metadata
  `960x539`. Editor Debugger still showed pre-existing Story015
  `CombatComponent` stale rows; fresh related CLI `reports/report_1102/`
  passed Story015 isolation `5/5`.

- Player Abilities Story 067: Old Factory Lower Deck Forward Conduit Ambush
  -- `factory_route_transition_shell.tscn` now contains
  `FactoryLowerDeckForwardConduitSparkRat` and
  `FactoryLowerDeckForwardConduitSteamHazard`. After
  `factory_lower_deck_forward_hatch_opened=true`, Cinderpaw can cross x
  `1272.0` to activate entity `2118`, the reused animated Factory Spark Rat,
  with a live target, Spark Rat pacing, active steam hazard, and route feedback
  `Clear Forward Conduit Ambush`. Defeating entity `2118` disables the enemy
  and hazard, persists `factory_lower_deck_forward_conduit_activated=true` and
  `factory_lower_deck_forward_conduit_defeated=true`, and advances feedback to
  `Forward Conduit Secured`. `FactoryServiceLift` remains optional with prompt
  `Call lift`; no service-lift destination, SaveSystem schema, minimap, fast
  travel, reward cache, or global quest state changed. No new assets were
  generated; the story reuses the existing image-generated Factory Spark Rat
  SpriteFrames, Old Factory steam vent prop, and post-bulkhead backdrop.
  Verification: RED `reports/report_1093/`; focused GREEN
  `reports/report_1094/` `2/2`; related GREEN `reports/report_1095/` `26/26`;
  Story015 stale editor-row isolation `reports/report_1096/` `5/5`; headless
  smoke `reports/old_factory_lower_deck_forward_conduit_ambush_smoke.log`
  exited `0` with no project script/parse/invalid-call/access/missing-resource
  errors, retaining only known cleanup-time `2 resources still in use` noise.
  Godot AI MCP `2.8.3` runtime confirmed helper live, node presence, pre-active
  hidden hazard state, active entity `2118`, Spark Rat SpriteFrames frame
  counts `idle/run/attack_tell/attack/hurt/death=3`, active hazard id/damage/
  cooldown, service lift `Call lift`, breach relay replay counts `0`, defeat
  transition to `Forward Conduit Secured`, persisted local flags, clean game
  log, and non-empty game framebuffer metadata `960x539`. Editor Debugger still
  showed pre-existing stale Story015 rows; fresh Story015 CLI
  `reports/report_1096/` passed.

- Player Abilities Story 066: Old Factory Lower Deck Relay Forward Reward Hatch
  — `factory_route_transition_shell.tscn` now contains
  `FactoryLowerDeckRelayForwardRewardCache` and
  `FactoryLowerDeckForwardHatch`. After
  `factory_lower_deck_post_relay_trial_defeated=true`, the reused lower-deck
  cache art becomes visible/claimable with prompt `+20 Gears`, cache/source
  `old_factory_lower_deck_relay_forward_cache`, and deterministic `20` gears.
  Claiming succeeds once, persists
  `factory_lower_deck_relay_forward_reward_cache_claimed=true`, records
  `Relay Forward Cache Claimed +20 Gears`, and leaves adjacent cache flags
  independent. The reused deep-bulkhead hatch art then becomes activatable with
  `Open forward hatch`; opening succeeds once, disables local collision,
  persists `factory_lower_deck_forward_hatch_opened=true`, and updates route
  feedback to `Lower Deck Forward Hatch Opened`. `FactoryServiceLift` remains
  optional with prompt `Call lift`; no service-lift destination, SaveSystem
  schema, minimap, or global quest state changed. No new visual/audio assets
  were generated; Story066 reuses existing image-generated lower-deck cache,
  deep bulkhead, and unlock spark assets. Verification: RED
  `reports/report_1089/`; focused GREEN `reports/report_1090/` `2/2`;
  related GREEN `reports/report_1091/` `18/18`; headless smoke
  `reports/old_factory_lower_deck_relay_forward_reward_hatch_smoke.log` exited
  `0` with no project script/parse/invalid-call/access/missing-resource
  errors; Godot AI MCP `2.8.3` runtime confirmed helper live, cache/hatch
  runtime node properties, claim/open path, route label
  `Lower Deck Forward Hatch Opened`, service lift `Call lift`, no relay
  VFX/audio replay, clean game log, and non-empty `960x539` game framebuffer.
  Editor Debugger still showed pre-existing stale Story015 rows; fresh Story015
  CLI `reports/report_1092/` passed `5/5`.

- Player Abilities Story 065: Old Factory Lower Deck Post-Relay Combat Feedback
  — `factory_route_transition_shell.tscn` now contains
  `FactoryLowerDeckPostRelaySparkRat` and
  `FactoryLowerDeckPostRelaySteamHazard`. After
  `factory_lower_deck_breach_relay_activated=true`, Cinderpaw can cross x
  `1232.0` to activate entity `2117`, the reused animated Factory Spark Rat,
  with a live target, Spark Rat pacing, active steam hazard, and route feedback
  `Clear Relay Forward Trial`. Defeating entity `2117` disables the enemy and
  hazard, persists `factory_lower_deck_post_relay_trial_activated=true` and
  `factory_lower_deck_post_relay_trial_defeated=true`, and advances feedback to
  `Relay Forward Secured`. No new assets were generated; the story reuses the
  existing image-generated Factory Spark Rat SpriteFrames and Old Factory steam
  vent prop. Verification: RED `reports/report_1084/`; focused GREEN
  `reports/report_1086/` `2/2`; related GREEN `reports/report_1088/` `12/12`;
  headless smoke
  `reports/old_factory_lower_deck_post_relay_combat_feedback_smoke.log` exited
  `0`; Godot AI MCP `2.8.3` runtime confirmed active/defeated diagnostics,
  `AnimatedSprite2D + SpriteFrames` counts
  `idle/run/attack_tell/attack/hurt/death=3`, hazard state, persisted flags,
  clean game log, and non-empty game framebuffer capture.

- Player Abilities Story 062: Old Factory Lower Deck Breach Relay Savepoint
  — `factory_route_transition_shell.tscn` now contains
  `FactoryLowerDeckBreachRelaySavepoint`, a `SavepointRuntime` relay using new
  image-generated transparent relay art at
  `assets/environment/old_factory_lower_deck_breach_relay/env_old_factory_lower_deck_breach_relay_256.png`.
  The relay stays hidden and non-interactive until
  `factory_lower_deck_breach_corridor_secured=true`, then becomes visible with
  prompt `Repair Relay`. Activating it succeeds once, persists
  `factory_lower_deck_breach_relay_activated=true`, records savepoint contract
  `old_factory_lower_deck_breach_relay / area_03_factory /
  lower_deck_breach_relay`, updates feedback to `Lower Deck Relay Secured`,
  and routes later non-boss Factory respawn back to the relay with feedback
  `Returned to Lower Deck Relay`. `FactoryServiceLift` remains optional with
  prompt `Call lift`. Verification: RED `reports/report_1067/`; fresh focused
  GREEN `reports/report_1071/` `2/2`; fresh related regression
  `reports/report_1072/` `15/15`; headless smoke
  `reports/old_factory_lower_deck_breach_relay_savepoint_smoke.log` exited
  `0` with no project script/resource-load errors by keyword scan; Godot AI MCP
  `2.8.3` runtime launched the Factory scene, confirmed the relay `Sprite2D`
  texture path and size, activation/duplicate behavior, savepoint contract,
  persisted local flag, inactive breach enemies/hazard, and non-empty game
  framebuffer capture.

- Player Abilities Story 060: Old Factory Lower Deck Deep Bulkhead Combat Gate
  — `factory_route_transition_shell.tscn` now contains
  `FactoryLowerDeckDeepBulkheadSparkRat` and `FactoryLowerDeckDeepBulkhead`.
  After `factory_lower_deck_steam_sluice_defeated=true`, Cinderpaw can cross
  activation x `1252.0` to activate a deep bulkhead guard with entity `2114`.
  The guard reuses the existing Factory Spark Rat `AnimatedSprite2D +
  SpriteFrames` resource with
  `idle/run/attack_tell/attack/hurt/death=3` frames, targets the player, starts
  Spark Rat pacing, updates the route objective to
  `Clear Deep Bulkhead Guard`, and leaves the service lift optional with prompt
  `Call lift`. Defeating entity `2114` hides/disables the guard, persists
  `factory_lower_deck_deep_bulkhead_guard_activated=true` and
  `factory_lower_deck_deep_bulkhead_guard_defeated=true`, changes the route
  objective to `Open Deep Bulkhead`, and makes the bulkhead activatable with
  prompt `Open bulkhead`. Opening the bulkhead persists
  `factory_lower_deck_deep_bulkhead_opened=true`, disables local collision, and
  changes the objective to `Deep Bulkhead Opened` without replaying
  Stories054-059. New door art was generated through image generation, kept in
  source/alpha/runtime PNG paths, imported through Godot, and recorded in the
  asset manifest/entity inventory. Verification: focused RED
  `reports/report_1058/`; focused GREEN `reports/report_1060/` `2/2`; related
  regression `reports/report_1062/` `8/8`; headless Factory smoke
  `reports/old_factory_lower_deck_deep_bulkhead_smoke.log` exited `0` with no
  project script/resource-load errors by keyword scan, retaining only known
  cleanup-time ObjectDB/resource terminal noise. Godot MCP 4.7 runtime confirmed
  the deep bulkhead guard/door nodes, active guard `2114`, frame counts,
  service lift `Call lift`, guard defeat, door open persistence, clean
  game/editor logs, and non-empty screenshot metadata `960x539`. QA evidence:
  `production/qa/evidence/old-factory-lower-deck-deep-bulkhead-combat-gate-2026-07-02.md`。
- Player Abilities Story 058: Old Factory Lower Deck Pressure Valve Combat
  Gate — `factory_route_transition_shell.tscn` now contains
  `FactoryLowerDeckPressureValveSparkRat` and `FactoryLowerDeckPressureValve`.
  After Story057 shortcut pursuer state is defeated, Cinderpaw can cross
  activation x `1240.0` to activate a pressure-valve guard with entity `2112`.
  The guard reuses the existing Factory Spark Rat `AnimatedSprite2D +
  SpriteFrames` resource with
  `idle/run/attack_tell/attack/hurt/death=3` frames, targets the player, starts
  Spark Rat pacing, updates the route objective to
  `Clear Pressure Valve Guard`, and leaves the already available service lift
  optional with prompt `Call lift`. Defeating entity `2112` hides/disables the
  guard, persists `factory_lower_deck_pressure_guard_activated=true` and
  `factory_lower_deck_pressure_guard_defeated=true`, changes the route objective
  to `Open Pressure Valve`, and makes the pressure valve activatable with prompt
  `Open valve`. Opening the valve persists
  `factory_lower_deck_pressure_valve_opened=true` and changes the objective to
  `Pressure Valve Opened` without replaying Stories054-057. No new visual
  assets were generated; this story reuses the existing Factory Spark Rat
  frames and Old Factory endpoint/VFX assets already imported through Godot.
  Verification: focused RED `reports/report_1051/`; parse-fix RED
  `reports/report_1052/`; focused GREEN `reports/report_1053/` `2/2`; related
  regression `reports/report_1054/` `11/11`; headless Factory smoke
  `reports/old_factory_lower_deck_pressure_valve_smoke.log` exited `0` with no
  project script/resource-load errors by keyword scan, retaining only known
  cleanup-time ObjectDB/resource terminal noise. Godot MCP 4.7 runtime confirmed
  the pressure valve guard/valve nodes, active guard `2112`, frame counts,
  service lift `Call lift`, guard defeat, valve open persistence, clean
  game/editor logs, and non-empty screenshot metadata `960x539`. QA evidence:
  `production/qa/evidence/old-factory-lower-deck-pressure-valve-combat-gate-2026-07-02.md`。
- Player Abilities Story 057: Old Factory Lower Deck Shortcut Pursuer —
  `factory_route_transition_shell.tscn` now contains
  `FactoryLowerDeckShortcutPursuerSparkRat`, a reused animated Factory Spark
  Rat pressure beat after the Story056 shortcut payoff cache. The pursuer
  remains hidden, non-processing, non-physics, and untargeted until
  `factory_lower_deck_shortcut_reward_cache_claimed=true` and Cinderpaw crosses
  activation x `1218.0`. Activation assigns Cinderpaw as target, enables Spark
  Rat pacing, updates route feedback to `Clear Shortcut Pursuer`, and keeps
  `FactoryServiceLift` optional with prompt `Call lift`. Defeating entity
  `2111` hides/disables the pursuer, persists
  `factory_lower_deck_shortcut_pursuer_activated=true` and
  `factory_lower_deck_shortcut_pursuer_defeated=true`, and updates route
  feedback to `Shortcut Pursuer Cleared` without replaying the Story054 exit
  ambush, Story055 shortcut guard, or Story056 shortcut payoff cache. No new
  visual assets were generated; this story reuses the existing image-generated
  Factory Spark Rat `AnimatedSprite2D + SpriteFrames` asset with
  `idle/run/attack_tell/attack/hurt/death=3` frames. Verification: focused RED
  `reports/report_1048/`; focused GREEN `reports/report_1049/` `2/2`;
  related regression `reports/report_1050/` `12/12`; headless Factory smoke
  `reports/old_factory_lower_deck_shortcut_pursuer_smoke.log` exited `0` with
  no project script/resource errors by keyword scan. Godot MCP 4.7 runtime
  confirmed hidden-to-active diagnostics, entity `2111`, frame counts, service
  lift `Call lift`, defeat persistence, `Shortcut Pursuer Cleared`, clean
  game/editor logs, and non-empty screenshot metadata `960x539`. QA evidence:
  `production/qa/evidence/old-factory-lower-deck-shortcut-pursuer-2026-07-02.md`。
- Player Abilities Story 056: Old Factory Lower Deck Shortcut Payoff Cache —
  `factory_route_transition_shell.tscn` now contains
  `FactoryLowerDeckShortcutRewardCache`, a once-only payoff cache behind/near
  the Story055 lower-deck shortcut seal. The cache remains hidden/unclaimable
  until `factory_lower_deck_shortcut_unlocked=true`; once the shortcut is open,
  it becomes visible and claimable with prompt `+15 Gears`, cache/source
  `old_factory_lower_deck_shortcut_cache`, and deterministic `15` gears.
  Claiming the cache updates route feedback to
  `Shortcut Cache Claimed +15 Gears`, rejects duplicate claims, and persists
  `factory_lower_deck_shortcut_reward_cache_claimed=true` through scene-local
  state without replaying the Story054 exit ambush or Story055 shortcut guard.
  The already available `FactoryServiceLift` remains optional with prompt
  `Call lift`. No new visual assets were generated; this story reuses the
  existing image-generated lower-deck cache texture already imported through
  Godot. Verification: focused RED `reports/report_1045/`; focused GREEN
  `reports/report_1046/` `2/2`; related regression `reports/report_1047/`
  `10/10`; headless Factory smoke
  `reports/old_factory_lower_deck_shortcut_payoff_cache_smoke.log` exited `0`
  with no project script/resource errors by keyword scan, retaining only known
  cleanup-time ObjectDB/resource terminal noise. Godot MCP 4.7 runtime
  confirmed cache visibility/claimability after shortcut unlock, `+15 Gears`,
  duplicate claim rejection, persisted local state, service lift `Call lift`,
  clean game/editor logs, and non-empty screenshot metadata `960x539`. QA
  evidence:
  `production/qa/evidence/old-factory-lower-deck-shortcut-payoff-cache-2026-07-02.md`。
- Player Abilities Story 055: Old Factory Lower Deck Shortcut Seal Combat Gate —
  `factory_route_transition_shell.tscn` now contains
  `FactoryLowerDeckShortcutSparkRat` and `FactoryLowerDeckShortcutSeal`. After
  Story054 lower-deck exit ambush state is defeated, Cinderpaw can cross the
  shortcut activation boundary to activate an optional Spark Rat guard with
  entity `2110`. The guard reuses the existing Factory Spark Rat
  `AnimatedSprite2D + SpriteFrames` resource with
  `idle/run/attack_tell/attack/hurt/death=3` frames, targets the player, and
  updates the route objective to `Clear Shortcut Guard`. The already available
  service lift remains optional with prompt `Call lift`. Defeating entity
  `2110` hides/disables the guard, persists
  `factory_lower_deck_shortcut_guard_defeated=true`, and changes the objective
  to `Open Lower Deck Shortcut`; opening the seal persists
  `factory_lower_deck_shortcut_unlocked=true`, disables shortcut collision, and
  changes the route objective to `Lower Deck Shortcut Opened`. Restored
  scene-local state keeps the shortcut open, keeps the guard defeated, and does
  not replay the Story054 exit ambush. No new visual assets were generated;
  this story reuses existing Factory Spark Rat frames, Old Factory endpoint
  visual, and existing unlock VFX. Verification: focused RED
  `reports/report_1039/`; final focused GREEN `reports/report_1043/` `2/2`;
  related regression `reports/report_1044/` `14/14`; headless Factory smoke
  `reports/old_factory_lower_deck_shortcut_seal_smoke.log` exited `0` with no
  project script/resource errors by keyword scan, retaining only known
  cleanup-time ObjectDB/resource terminal noise. Godot MCP 4.7 runtime
  confirmed active guard `2110`, frame counts, service lift `Call lift`, guard
  defeat, seal open, collision disabled, local-state persistence, clean
  game/editor logs, and non-empty screenshot metadata `960x539`. QA evidence:
  `production/qa/evidence/old-factory-lower-deck-shortcut-seal-combat-gate-2026-07-02.md`。
- Player Abilities Story 054: Old Factory Lower Deck Parry-Laser Ambush Gate —
  `factory_route_transition_shell.tscn` now contains
  `FactoryLowerDeckParryLaserGate` and `FactoryLowerDeckExitSparkRat`. After
  Story053 lower-deck cache state is claimed, the reused Parry Laser
  `ExplorationGate` becomes visible/unlockable, blocks collision, and opens
  when Cinderpaw activates `parry` in range. Opening the gate persists
  `factory_lower_deck_parry_gate_unlocked=true` and triggers an optional exit
  Spark Rat ambush with entity `2109`. The ambush reuses the existing Factory
  Spark Rat `AnimatedSprite2D + SpriteFrames` resource with
  `idle/run/attack_tell/attack/hurt/death=3` frames, targets the player, updates
  the route objective to `Clear Lower Deck Exit`, and leaves the already
  available service lift at prompt `Call lift`. Defeating entity `2109` hides
  and disables the enemy, persists activated/defeated state, and updates the
  route objective to `Lower Deck Exit Cleared`. No new visual assets were
  generated; this story reuses the existing image-generated Parry Laser gate
  texture and Factory Spark Rat frames. Verification: focused RED
  `reports/report_1034/`; focused GREEN `reports/report_1037/` `1/1`;
  related regression `reports/report_1038/` `12/12`; headless Factory smoke
  `reports/old_factory_lower_deck_exit_ambush_smoke.log` exited `0` with no
  project script/resource errors by keyword scan, retaining only known
  cleanup-time ObjectDB/resource terminal noise. Godot MCP 4.7 runtime
  confirmed gate unlock, active exit ambush, frame counts, service lift still
  `Call lift`, player HP unchanged after gate activation, clean game/editor
  logs, and non-empty screenshot metadata `960x539`. QA evidence:
  `production/qa/evidence/old-factory-lower-deck-parry-laser-ambush-gate-2026-07-01.md`。
- Player Abilities Story 053: Old Factory Lower Deck Skirmish Cache —
  `factory_route_transition_shell.tscn` now contains
  `FactoryLowerDeckSparkRat`, `FactoryLowerDeckSteamVentHazard`, and
  `FactoryLowerDeckRewardCache`. The optional lower-deck skirmish unlocks only
  after the checkpoint overdrive duo is cleared, reuses the existing Factory
  Spark Rat `AnimatedSprite2D + SpriteFrames` enemy with
  `idle/run/attack_tell/attack/hurt/death=3` frames, activates a local steam
  vent hazard while active, and does not block the already available service
  lift. Defeating entity `2108` unlocks the independent generated lower-deck
  cache, granting deterministic `10` gears from
  `old_factory_lower_deck_cache`, rejecting duplicate claims, and persisting
  scene-local state without mutating the overdrive reward cache. New generated
  source, alpha, runtime PNG, import metadata, and imagegen metadata are
  recorded in `design/assets/asset-manifest.md`. Verification: RED
  `reports/report_1029/`; focused GREEN `reports/report_1031/` `2/2`;
  related regression `reports/report_1032/` `16/16`; headless Factory smoke
  `reports/old_factory_lower_deck_skirmish_cache_factory_scene_smoke.log`
  exited `0` with no project script/resource errors by keyword scan, retaining
  only known cleanup-time ObjectDB/resource terminal noise. Godot MCP 4.7
  runtime confirmed activation, frame counts, pressure hazard state, reward
  claim/duplicate rejection, service lift still `Call lift`, runtime node
  presence, and non-empty screenshot metadata `960x539`. QA evidence:
  `production/qa/evidence/old-factory-lower-deck-skirmish-cache-2026-07-01.md`。
- Player Abilities Story 052: Old Factory Overdrive Defeat Burst —
  `factory_route_transition_shell.tscn` now contains hidden
  `FactoryCheckpointOverdriveLeftDefeatBurst` and
  `FactoryCheckpointOverdriveRightDefeatBurst` `Sprite2D` nodes using the
  image-generated transparent runtime PNG
  `res://assets/environment/old_factory_overdrive_defeat_burst/vfx_old_factory_overdrive_defeat_burst_256.png`.
  `OldFactoryEntranceScene` now exposes
  `get_factory_checkpoint_overdrive_defeat_burst_diagnostics()` and shows the
  left/right burst at the corresponding overdrive Spark Rat position when
  entity `2106` or `2107` is defeated. Restored cleared state does not replay
  bursts, and existing overdrive duo, reward cache, service lift, and Factory
  route roundtrip behavior remain intact. New generated source, alpha, runtime
  PNG, import metadata, and imagegen metadata are recorded in
  `design/assets/asset-manifest.md`. Verification: RED `reports/report_1026/`;
  focused GREEN `reports/report_1027/` `2/2`; related regression
  `reports/report_1028/` `11/11`; headless Factory smoke
  `reports/old_factory_overdrive_defeat_burst_smoke.log` exited `0` with no
  project script/resource errors by keyword scan, retaining only known
  cleanup-time ObjectDB/resource terminal noise. Godot MCP 4.7 runtime confirmed
  left/right burst visibility and positions, texture path, overdrive duo
  cleared state, service lift still `Call lift`, current game/editor logs with
  no error/warning rows, and a non-empty screenshot metadata `640x359`. QA
  evidence:
  `production/qa/evidence/old-factory-overdrive-defeat-burst-2026-07-01.md`。
- Player Abilities Story 051: Old Factory Checkpoint Overdrive Reward Cache —
  `factory_route_transition_shell.tscn` now contains
  `FactoryCheckpointOverdriveRewardCache`, a generated 256x256 transparent
  reward cache that becomes claimable after the checkpoint overdrive duo is
  cleared. The cache uses independent scene-local state
  `old_factory_checkpoint_overdrive_cache`, grants deterministic `25` gears,
  rejects duplicate claims, and shows `Overdrive Cache Claimed +25 Gears` on
  `RouteLabel` without blocking the service lift. `OldFactoryEntranceScene`
  now exposes `try_claim_factory_checkpoint_overdrive_reward_cache()` and
  `get_factory_checkpoint_overdrive_reward_cache_diagnostics()`, persists
  claimed/reward/feedback state through `get_local_state()` / `set_local_state()`,
  and keeps SaveSystem/global economy out of scope. New generated asset source,
  alpha, runtime PNG, import metadata, and imagegen metadata are recorded in
  `design/assets/asset-manifest.md`. Verification: RED
  `reports/report_1022/`; import refinement `reports/report_1023/`; focused
  GREEN `reports/report_1024/` `2/2`; related regression
  `reports/report_1025/` `16/16`; headless Factory smoke
  `reports/old_factory_checkpoint_overdrive_reward_cache_smoke.log` exited `0`
  with no project script/resource errors by keyword scan, retaining only known
  cleanup-time ObjectDB/resource terminal noise. Godot MCP 4.7 runtime confirmed
  locked `Clear overdrive duo`, unlocked `+25 Gears`, successful first claim,
  duplicate claim rejection, route label feedback, service lift still
  `Call lift`, persisted local state, texture path, post-clear logs with no
  current error/warning rows, and a non-empty screenshot metadata `640x359`.
  QA evidence:
  `production/qa/evidence/old-factory-checkpoint-overdrive-reward-cache-2026-07-01.md`。
- Player Abilities Story 050: Old Factory Overdrive Duo Staggered Pincer
  Pacing — the Story049 overdrive duo now uses readable staggered pressure:
  left Spark Rat opening grace is `12` frames and right Spark Rat opening grace
  is `30` frames. `FactorySparkRat` diagnostics now report the configured
  `opening_grace_total_frames` for the current pacing instance, and
  `OldFactoryEntranceScene` exposes
  `advance_factory_checkpoint_overdrive_duo_pacing_frames()` for deterministic
  tests/MCP probes. Scene-local state now preserves
  `factory_checkpoint_overdrive_left_opening_grace_frames` and
  `factory_checkpoint_overdrive_right_opening_grace_frames`, while retaining the
  old aggregate duo grace field for compatibility. No new visual assets were
  generated; this story reuses the existing Factory Spark Rat
  `AnimatedSprite2D + SpriteFrames` asset. Verification: RED
  `reports/report_1018/`; focused GREEN `reports/report_1019/` `4/4`;
  related regression `reports/report_1021/` `14/14`; Godot MCP 4.7 runtime
  confirmed activation pacing left `12` / right `30`, aggregate total `30`,
  left `attack_tell` while right remained `opening_grace`, independent
  local-state grace values, existing Spark Rat SpriteFrames frame counts `3`
  for `idle/run/attack_tell/attack/hurt/death`, post-clear logs with no current
  error/warning rows, and a non-empty screenshot metadata `640x359`. QA
  evidence:
  `production/qa/evidence/old-factory-overdrive-duo-staggered-pincer-pacing-2026-07-01.md`。
- Player Abilities Story 049: Old Factory Checkpoint Overdrive Duo —
  `factory_route_transition_shell.tscn` now includes
  `FactoryCheckpointOverdriveSparkRatLeft` and
  `FactoryCheckpointOverdriveSparkRatRight`, a final service-lift overdrive
  pair that reuses the existing Factory Spark Rat `AnimatedSprite2D +
  SpriteFrames` asset. The duo stays hidden, non-processing, non-physics, and
  non-colliding until the checkpoint rear ambush is defeated and Cinderpaw
  crosses the final activation boundary. While either rat is uncleared, the
  route objective becomes `Clear Overdrive Duo`, `FactoryServiceLift` stays
  locked with prompt `Clear overdrive duo`, and lift activation records
  `overdrive_duo_active` without requesting SceneManager. Defeating only entity
  `2106` or `2107` hides that side and keeps the lift locked; defeating both
  persists `factory_checkpoint_overdrive_duo_cleared=true`, updates route
  objective `checkpoint_overdrive_duo_cleared`, restores prompt `Call lift`,
  and allows the service lift to request `main / scrap_roost`. No new visual
  assets were generated; this story reuses
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
  with `idle/run/attack_tell/attack/hurt/death=3` frames each. Verification:
  RED `reports/report_1011/`; focused GREEN `reports/report_1012/` `3/3`;
  related regression `reports/report_1015/` `15/15`; extended regression
  `reports/report_1016/` `23/23`; final pre-commit rerun
  `reports/report_1017/` `23/23`; headless Factory smoke
  `reports/old_factory_checkpoint_overdrive_duo_smoke.log` exited `0` with no
  script/parse/invalid/missing-resource/resource-load entries, retaining only
  cleanup-time resource warnings. Godot MCP 4.7 runtime confirmed both
  overdrive nodes, default hidden state, activation after rear ambush state,
  `AnimatedSprite2D + SpriteFrames` frame counts, single-kill lift lockout,
  double-kill service-lift unlock and `main / scrap_roost` request, current
  post-clear MCP logs without error/warning rows, and a non-empty game
  screenshot metadata `640x360`. QA evidence:
  `production/qa/evidence/old-factory-checkpoint-overdrive-duo-2026-07-01.md`。
- Player Abilities Story 048: Old Factory Checkpoint Rear Ambush —
  `factory_route_transition_shell.tscn` now includes
  `FactoryCheckpointRearSparkRat`, a post-vent Spark Rat ambush that reuses the
  existing Factory Spark Rat `AnimatedSprite2D + SpriteFrames` asset. The ambush
  stays hidden, non-processing, non-physics, and non-colliding until the
  checkpoint-forward patrol is defeated and Cinderpaw crosses the post-vent
  activation boundary. While uncleared, it becomes the current route objective
  `Clear Rear Ambush`, blocks `FactoryServiceLift` with prompt
  `Clear rear ambush`, and rejects lift exit with `rear_ambush_active`.
  Defeating entity `2105` hides/disables the ambush, persists
  `factory_checkpoint_rear_ambush_defeated`, updates the route label to
  `Vent Gauntlet Cleared`, and restores service-lift prompt `Call lift`.
  No new visual assets were generated; this story reuses
  `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`
  with `idle/run/attack_tell/attack/hurt/death=3` frames each. Verification:
  RED `reports/report_1006/`; focused GREEN `reports/report_1007/` `3/3`;
  related Old Factory regression `reports/report_1009/` `20/20`; headless
  Factory smoke `reports/old_factory_checkpoint_rear_ambush_smoke.log` exited
  `0` with no script/parse/invalid/missing-resource/resource-load entries,
  retaining only cleanup-time ObjectDB/resource warnings. Godot MCP 4.7 runtime
  confirmed default inactive state, activation after forward patrol state,
  `AnimatedSprite2D + SpriteFrames` frame counts, service-lift lockout, defeat
  route label `Vent Gauntlet Cleared`, service lift available after defeat,
  clean current game logs, no new editor errors after stale cursor `7`, and a
  non-empty game screenshot metadata `640x359`. QA evidence:
  `production/qa/evidence/old-factory-checkpoint-rear-ambush-2026-06-30.md`。
- Player Abilities Story 047: Old Factory Checkpoint Steam Vent Gauntlet —
  `factory_route_transition_shell.tscn` now includes
  `FactoryCheckpointSteamVentHazard`, a scene-authored checkpoint-adjacent
  `Area2D` that reuses the existing image-generated Old Factory steam vent art.
  `OldFactoryEntranceScene` keeps the vent hidden, non-monitoring, and
  non-colliding until `factory_checkpoint_forward_patrol_defeated`, then
  activates it with environment layer/mask, visible art, `damage=8`, and
  `contact_cooldown_sec=1.0`. Factory hazard processing now handles both steam
  vents through shared collection/cooldown/diagnostic logic. Return-checkpoint
  respawn and SceneManager handoff now grant a short hazard grace window and
  briefly pin/snap Cinderpaw to the checkpoint so the activated vent does not
  immediately overwrite respawn state. No new visual assets were generated;
  this story reuses
  `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`.
  Verification: RED `reports/report_985/`; focused GREEN `reports/report_991/`
  `3/3`; related Old Factory regression `reports/report_1002/` `21/21`;
  headless Factory smoke
  `reports/old_factory_checkpoint_steam_vent_gauntlet_smoke.log` exited `0`
  with no `ERROR`, `SCRIPT ERROR`, `Parse Error`, `FATAL`, or `WARNING` entries
  in the log file. Godot MCP 4.7 runtime confirmed
  `FactoryCheckpointSteamVentHazard` exists, default inactive state,
  activated visible/monitoring/collision state after patrol-clear local state,
  player `AnimatedSprite2D + SpriteFrames`, and non-empty game screenshot
  metadata `640x359`; MCP `project_run` retained stale pre-run editor
  parse-error rows marked `recent_errors_may_predate_run=true`, while runtime
  inspection and CLI/GdUnit verification succeeded. Validation cleanup
  `reports/report_1005/` passed `40/40` across Story047, CombatPresentation,
  and Rat King runtime contract tests after converting optional generated VFX
  textures and Rat King component scripts to runtime load. QA evidence:
  `production/qa/evidence/old-factory-checkpoint-steam-vent-gauntlet-2026-06-30.md`。
- Player Abilities Story 046: Old Factory Checkpoint-Forward Combat Route —
  `factory_route_transition_shell.tscn` now includes
  `FactoryCheckpointForwardSparkRat`, a reused animated Spark Rat patrol with
  entity id `2104`. `OldFactoryEntranceScene` keeps the patrol hidden until
  `FactoryReturnCheckpoint` is activated, then activates it at the forward
  trigger, binds Cinderpaw as target, locks `FactoryServiceLift` with
  `forward_patrol_active`, and opens the deeper route after the patrol is
  defeated. `apply_damage()` now synchronizes scene-owned enemy defeated state
  immediately when HP reaches `0`, so runtime route unlocks do not depend on a
  deferred frame. No new visual assets were generated; this story reuses the
  existing `FactorySparkRat` `AnimatedSprite2D + SpriteFrames` assets.
  Verification: RED `reports/report_976/`; focused GREEN `reports/report_981/`
  `4/4`; related Old Factory/respawn/service-lift regression
  `reports/report_984/` `24/24`; headless Factory smoke exited `0` with no
  project script/parse/invalid/missing-resource/resource-load errors by keyword
  scan. Godot MCP 4.7 runtime confirmed entity `2104`, AnimatedSprite2D frame
  counts `3` for idle/run/attack_tell/attack/hurt/death, service-lift lock and
  unlock, clean final logs, and non-empty game screenshot metadata `960x539`.
  QA evidence:
  `production/qa/evidence/old-factory-checkpoint-forward-combat-route-2026-06-30.md`。
- Player Abilities Story 043: Old Factory Return Checkpoint —
  `FactoryReturnCheckpoint` now mounts a visible image-generated repair
  savepoint in `factory_route_transition_shell.tscn` using `SavepointRuntime`.
  The checkpoint stays hidden and inactive until the return patrol is defeated,
  then becomes available with prompt `Repair Savepoint`, activates as
  `old_factory_return_checkpoint / area_03_factory / return_checkpoint`, records
  scene-local checkpoint state through `get_local_state()` / `set_local_state()`,
  updates `RouteLabel` to `Factory Savepoint Secured`, and exposes
  `get_last_discovered_savepoint()` so non-boss death through
  `GameFlowController` respawns to the Old Factory checkpoint instead of clan
  base. New image generation asset:
  `assets/environment/old_factory_return_checkpoint/old_factory_return_checkpoint.png`
  with source, alpha source, and metadata under `assets/generated/source/`.
  Verification: RED `reports/report_952/`; focused GREEN `reports/report_954/`
  `3/3`; related return patrol/savepoint/service-lift regressions
  `reports/report_955/`, `reports/report_956/`, `reports/report_957/` plus
  service-lift command logs; headless Factory smoke
  `reports/old_factory_return_checkpoint_factory_scene_smoke.log` exited `0`
  with no project script/parse/invalid/missing-resource/resource-load errors by
  keyword scan. Godot MCP 4.7 runtime launched the Factory scene, confirmed
  checkpoint node, generated texture, locked/available/activated transitions,
  route label feedback, clean final logs, and non-empty screenshot
  `reports/visual/cinderpaw-mcp-old-factory-return-checkpoint-20260630.png`.
  QA evidence:
  `production/qa/evidence/old-factory-return-checkpoint-2026-06-30.md`。
- Player Abilities Story 042: Old Factory Cache Claim Feedback —
  `OldFactoryEntranceScene` now records scene-local claim feedback for both
  Old Factory caches and keeps the success text visible on `RouteLabel` after a
  claim instead of immediately refreshing back to the route objective. Entrance
  cache claims show `Cache Claimed +10 Gears` with feedback payload
  `old_factory_entrance_cache` / `old_factory_combat_cache`; return patrol
  reward cache claims show `Return Cache Claimed +15 Gears` with feedback
  payload `old_factory_return_patrol_cache`. Duplicate claims return false and
  preserve the last successful feedback. Verification: RED `reports/report_934/`;
  focused GREEN `reports/report_935/` `2/2`; related Old Factory regression
  `reports/report_936/` through `reports/report_945/` `22/22`; post-refactor
  focused/high-risk regression `reports/report_946/` through `reports/report_950/`
  `13/13`; Godot MCP 4.7 runtime launched the Factory scene, confirmed target
  cache nodes, claim and duplicate-claim behavior for both cache paths, visible
  RouteLabel feedback, unchanged feedback after duplicate claims, clean
  game/editor logs, and a non-empty screenshot. QA evidence:
  `production/qa/evidence/old-factory-cache-claim-feedback-2026-06-30.md`。
- Player Abilities Story 041: Old Factory Return Patrol Reward Cache —
  `FactoryReturnPatrolRewardCache` now adds a generated transparent reward
  lockbox prop to `factory_route_transition_shell.tscn`, reusing
  `FactoryCombatCache` with independent `cache_id="old_factory_return_patrol_cache"`,
  `reward_source`, `+15 Gears`, prompt state, claim radius, and once-only
  local claim behavior. `OldFactoryEntranceScene` exposes
  `try_claim_factory_return_patrol_reward_cache()` plus deterministic
  diagnostics and persists `factory_return_patrol_reward_cache_claimed` /
  `last_return_patrol_reward_cache_reward` through scene-local state without
  SaveSystem schema or global quest fields. The image-generated source, alpha
  source, runtime PNG, metadata, manifest, and entity inventory were recorded.
  Verification: RED `reports/report_931/`; focused GREEN `reports/report_932/`
  `3/3`; related regression `reports/report_933/` `18/18`; Godot import on
  4.7; headless Factory smoke
  `reports/old_factory_return_patrol_reward_cache_factory_scene_smoke.log`
  exited `0` with no project script/resource errors by keyword scan. Godot MCP
  4.7 runtime launched the Factory scene, confirmed
  `FactoryReturnPatrolRewardCache` nodes, locked `Clear patrol` state during
  return patrol, claimable `+15 Gears` state after patrol-defeated restore,
  `claim_ok=true`, duplicate claim false, local state persistence, clean logs,
  and screenshot
  `reports/visual/cinderpaw-mcp-old-factory-return-patrol-reward-cache-20260630.png`.
  QA evidence:
  `production/qa/evidence/old-factory-return-patrol-reward-cache-2026-06-30.md`。
- Player Abilities Story 039: Scrap Roost Return Hub Runtime —
  `MainScene` now secures the Scrap Roost return hub when SceneManager reports
  current `main / scrap_roost`, Factory route is unlocked, and
  `area_03_factory` records the full service-lift return contract back to
  Scrap Roost. The story records `scrap_roost_return_hub_secured=true`,
  rediscovers the existing `ScrapRoostSavepoint` at `(210, 432)`, updates
  `last_savepoint` through `discover_savepoint()` without autosave, preserves
  Story038 `Return to Factory Route`, and shows one-time HUD feedback
  `Returned to Scrap Roost`. No new visual/audio assets or character animation
  states were generated; this story reuses the existing Scrap Roost savepoint
  prop and existing `AnimatedSprite2D + SpriteFrames` character assets.
  Verification: valid RED `reports/report_916/`; focused GREEN
  `reports/report_917/` `2/2`; related regressions
  `reports/report_918/` through `reports/report_923/` passed independently
  across Factory prompt, route roundtrip, savepoint runtime, Factory shell, and
  Old Factory service-lift suites; headless main-scene smoke
  `reports/scrap_roost_return_hub_main_scene_smoke.log` exited `0` with no
  script/parse/invalid/missing-resource/resource-load failures by keyword
  scan. Godot MCP 4.7 runtime launched main with `autosave=false`, confirmed
  `ScrapRoostSavepoint`, `FactoryRouteTransitionShell`, Cinderpaw
  `AnimatedSprite2D`, hub diagnostics secured with last savepoint
  `scrap_roost/main/scrap_roost` at `(210,432)`, HUD `Returned to Scrap Roost`,
  clean game logs, only unrelated `.uid` editor warnings, and non-empty game
  screenshot metadata. QA evidence:
  `production/qa/evidence/scrap-roost-return-hub-runtime-2026-06-30.md`。
- Player Abilities Story 038: Factory Route Return Prompt —
  `MainScene` now changes the existing main-scene `FactoryRouteTransitionShell`
  prompt from `Enter Factory Route` to `Return to Factory Route` when
  `SceneManager.get_scene_state(&"area_03_factory")` records the full service
  lift return contract back to `main / scrap_roost`. Locked routes remain
  locked, incomplete return state keeps the first-entry prompt, and activation
  still requests `area_03_factory / factory_gate_entry`. No new visual/audio
  assets or character animation states were generated; this story reuses the
  existing Factory route shell prompt, Cinderpaw/Boss2/Spark Rat animation
  assets, and Story037 route loop. Verification: RED focused
  `reports/report_908/`; initial GREEN `reports/report_909/` `1/1`;
  negative-coverage RED `reports/report_911/`; final focused GREEN
  `reports/report_912/` `2/2`; related regression `reports/report_913/`
  `7/7`; headless main-scene smoke
  `reports/factory_route_return_prompt_main_scene_smoke.log` exited `0` with
  no script/parse/invalid/missing-resource/resource-load errors by keyword
  scan. Godot MCP 4.7 runtime launched main with `autosave=false`, confirmed
  prompt/label `Return to Factory Route`, target `area_03_factory`,
  spawn `factory_gate_entry`, request success, clean game logs, only unrelated
  `.uid` editor warnings, and screenshot
  `reports/visual/cinderpaw-mcp-factory-route-return-prompt-20260630.png`.
  QA evidence:
  `production/qa/evidence/factory-route-return-prompt-2026-06-30.md`。
- Player Abilities Story 037: Factory Route Runtime Roundtrip —
  `SceneManager` runtime swaps now inject themselves into scenes that expose
  `configure_scene_manager_runtime(self)`, so cached scenes removed from and
  re-added to the tree reconnect their SceneManager signals. `MainScene` now
  implements the SceneManager local-state protocol through `get_local_state()`
  / `set_local_state()` aliases over the existing no-loss state snapshot and
  applies the `scrap_roost` spawn point to the visible `ScrapRoostSavepoint`
  when SceneManager returns to `main / scrap_roost`. The end-to-end loop
  `main -> area_03_factory -> main/scrap_roost` is now covered by a focused
  runtime-root test using real `scenes/main.tscn`, real
  `scenes/factory_route_transition_shell.tscn`, and real `SceneManager`.
  Verification: RED focused `reports/report_902/` failed because the returned
  player remained at the Factory route trigger `(970, 352)`; focused GREEN
  `reports/report_906/` passed `1/1` with `0` orphans; related regression
  `reports/report_905/` passed `17/17`; headless main-scene smoke
  `reports/factory_route_runtime_roundtrip_main_scene_smoke.log` exited `0`
  with no script/parse/invalid/missing-resource/resource-load errors by keyword
  scan. Pre-commit focused rerun `reports/report_907/` passed `1/1` with `0`
  orphans on Godot `4.7.stable.official.5b4e0cb0f`. Godot MCP 4.7 runtime launched main, unlocked and entered the Factory
  route, cleared the authored Factory route, activated the service lift, and
  confirmed `returned_main=true`, `spawn="scrap_roost"`, player near Scrap
  Roost after physics settle, clean game logs, and screenshot
  `reports/visual/cinderpaw-mcp-factory-route-runtime-roundtrip-20260630.png`.
  QA evidence:
  `production/qa/evidence/factory-route-runtime-roundtrip-2026-06-30.md`。
- Player Abilities Story 036: Old Factory Service Lift SceneManager Exit —
  `FactoryServiceLift` now requests `SceneManager.request_scene_change(&"main",
  &"scrap_roost")` after the authored Old Factory route is cleared and the
  player is in activation range. `OldFactoryEntranceScene` exposes
  `configure_scene_manager_runtime()` for tests/probes and production resolves
  `/root/SceneManager`; loading/locked/missing/unknown-scene rejections keep the
  lift unactivated, skip the one-shot VFX, and record deterministic rejection
  reasons. Local state now records `factory_service_lift_exit_requested`,
  `factory_service_lift_exit_scene_id`, `factory_service_lift_exit_spawn_point`,
  and the last exit request diagnostics. No new visual assets were generated;
  the story reuses the Story035 image-generated service lift console.
  Verification: RED `reports/report_893/`; focused GREEN
  `reports/report_894/` `2/2`; Story035+036 focused regression
  `reports/report_895/` `4/4`; related Old Factory/Boss2/SceneManager
  regression `reports/report_896/` `28/28`; headless Factory scene smoke
  `reports/old_factory_service_lift_scene_manager_exit_factory_scene_smoke.log`
  exited `0` with no script/parse/invalid/missing-resource/resource-load
  errors by keyword scan. Godot MCP 4.7 runtime launched
  `res://scenes/factory_route_transition_shell.tscn`, cleared the Factory route,
  activated the service lift, and confirmed `activation_result=true`,
  `exit_requested=true`, target `main`, spawn `scrap_roost`, route label
  `Service Lift Departing`, SceneManager pending scene `main`, pending spawn
  `scrap_roost`, clean game logs, and a nonblank screenshot showing the service
  lift. QA evidence:
  `production/qa/evidence/old-factory-service-lift-scene-manager-exit-2026-06-30.md`。
- Technical Maintenance: Godot 4.7 Engine Baseline Upgrade —
  项目基准已从 Godot 4.6.3 升级到 Godot 4.7。
  `project.godot` 现在 pin `config/features=PackedStringArray("4.7")`；
  `AGENTS.md`、`.claude/docs/technical-preferences.md` 和
  `docs/engine-reference/godot/` 已同步为 Godot 4.7。预升级扫描未在
  `src/` 中发现 4.7 高风险 migration watch-list API 需要迁移。验证：
  `/Applications/Godot 2.app/Contents/MacOS/Godot --version` 返回
  `4.7.stable.official.5b4e0cb0f`；Godot MCP `editor_state` 返回
  `godot_version="4.7-stable (official)"` 且 `readiness="ready"`；4.7
  project boot log `reports/godot_4_7_upgrade_project_boot.log`、main scene
  smoke log `reports/godot_4_7_upgrade_main_scene_smoke.log` 均退出 `0` 且
  无 script/parse/invalid/missing-resource 错误；focused GdUnit
  `reports/report_891/` 通过 SceneManager async request 与 Old Factory
  service lift `6/6`。QA evidence:
  `production/qa/evidence/godot-4-7-upgrade-2026-06-30.md`。
- Technical Maintenance: Godot 4.7 Baseline Recheck —
  用户确认项目应以 Godot 4.7 为当前基线，后续正式验证不得再切回
  4.6.3 CLI/headless。当前本机 Godot CLI
  `/Applications/Godot 2.app/Contents/MacOS/Godot --version` 返回
  `4.7.stable.official.5b4e0cb0f`；`AGENTS.md`、`.claude/docs/technical-preferences.md`、
  `docs/engine-reference/godot/VERSION.md` 与 `project.godot`
  均已指向 Godot 4.7。2026-07-02 headless boot
  `reports/godot_4_7_project_boot_recheck_20260702.log` 退出 `0`，
  启动阶段无 script/parse/invalid-call/missing-resource/resource-load 错误；
  仅保留已知退出清理期 ObjectDB/resource 提示。Godot MCP
  `session_activate("cinderpaw")` 选中 `cinderpaw@4400`，`editor_state`
  返回 Godot `4.7-stable (official)`、`readiness="ready"`、当前场景
  `res://scenes/factory_route_transition_shell.tscn`。QA evidence:
  `production/qa/evidence/godot-4-7-baseline-recheck-2026-07-02.md`。
- Player Abilities Story 035: Old Factory Service Lift Handoff —
  `FactoryServiceLift` now mounts a visible image-generated transparent
  service lift call console in `res://scenes/factory_route_transition_shell.tscn`
  using the existing `FactoryDeepRouteEndpoint` interactable component with
  endpoint id `old_factory_service_lift`. It starts locked with prompt
  `Clear patrol`, becomes available only after Factory Spark Rat defeat /
  `factory_route_cleared`, activates once with prompt `Lift online`, updates
  `RouteLabel` to `Service Lift Online`, and persists
  `factory_service_lift_activated` through `get_local_state()` /
  `set_local_state()` without adding a global quest system, new SaveSystem
  schema, real scene transition, or moving platform. New image generation asset:
  `assets/environment/old_factory_service_lift/factory_service_lift_console.png`
  with source/alpha/metadata under `assets/generated/source/`. Verification:
  RED `reports/report_886/`; focused GREEN `reports/report_889/` `2/2`;
  related Old Factory regression `reports/report_890/` `14/14`; headless
  Factory scene smoke
  `reports/old_factory_service_lift_handoff_factory_scene_smoke.log` exited
  `0` with no script/parse/invalid/missing-resource/resource-load errors and
  only Godot's cleanup-time `2 resources still in use at exit` message. Godot
  MCP runtime launched the Factory custom scene, confirmed
  `/FactoryRouteTransitionShellScene/FactoryServiceLift` exists with `Visual`,
  `PromptLabel`, `InteractionArea`, endpoint id `old_factory_service_lift`,
  prompt `Clear patrol`, texture path
  `res://assets/environment/old_factory_service_lift/factory_service_lift_console.png`,
  clean game logs, and a nonblank game screenshot showing the service lift
  console in the Old Factory scene. QA evidence:
  `production/qa/evidence/old-factory-service-lift-handoff-2026-06-30.md`。
- Player Abilities Story 034: Factory Route Arrival Objective Handoff —
  `OldFactoryEntranceScene` now exposes a scene-local Factory Route objective
  chain with `get_factory_route_objective_diagnostics()` and
  `is_factory_route_objective_complete()`. The visible `RouteLabel` starts on
  `Clear Factory Entrance`, advances to `Reach Deep Guard`, then
  `Open Deep Route Endpoint`, then `Defeat Spark Rat Patrol`, and finally
  `Factory Route Cleared` after Factory Spark Rat defeat. The objective is
  derived from existing entrance/deep-route/Spark Rat state and recorded in
  `get_local_state()` as `factory_route_objective_id` without adding a global
  quest system, new SaveSystem schema, new rooms, enemies, or assets. No new
  visual assets were generated; this story reuses existing image-generated Old
  Factory environment, endpoint/VFX, and Factory Spark Rat
  `AnimatedSprite2D + SpriteFrames` assets. Verification: RED
  `reports/report_883/`; focused GREEN `reports/report_884/` `2/2`; related
  Old Factory + Story033 regression `reports/report_885/` `21/21`; headless
  Factory scene smoke
  `reports/old_factory_route_objective_handoff_factory_scene_smoke.log` exited
  `0` with no script/parse/invalid/missing-resource/resource-load errors and
  only Godot's known cleanup-time `resources still in use at exit` message.
  Godot MCP 2.8.1 runtime with `autosave=false` confirmed target scene
  `res://scenes/factory_route_transition_shell.tscn`, objective progression
  through `factory_route_cleared`, visible `RouteLabel` text
  `Factory Route Cleared`, `is_factory_route_objective_complete()==true`,
  local state objective id `factory_route_cleared`, Player `idle/run/jump`
  frame counts `3`, Factory Spark Rat
  `idle/run/attack_tell/attack/hurt/death` frame counts `3`, clean editor logs,
  game logs with only helper info after cleanup, and screenshot
  `reports/visual/cinderpaw-mcp-old-factory-route-objective-handoff-20260630.png`.
  QA evidence:
  `production/qa/evidence/factory-route-arrival-objective-handoff-2026-06-30.md`。
- Player Abilities Story 033: Boss2 Victory Route Handoff —
  `MainScene` now exposes deterministic Boss2 victory handoff diagnostics that
  cover Boss2 defeat, reward prompt/claimability, room-seal release,
  `DoubleJumpExplorationGate`, `FactoryRouteTransitionShell`, and HUD
  notification state. Defeating `Boss2EchoGuardian` now immediately refreshes
  the Boss2 payoff state and shows `Echo Guardian defeated - Claim Double Jump`;
  claiming the reward unlocks Double Jump, using it at the high-platform gate
  unlocks `area_03_factory_unlocked`, and requesting the route transition
  targets `area_03_factory / factory_gate_entry` while rejecting duplicate
  requests during loading. No new visual or audio assets were generated; this
  slice reuses existing Boss2 reward, room-seal, gate, and Factory Route shell
  assets. Verification: RED `reports/report_879/`; focused GREEN
  `reports/report_880/` `1/1`; related Boss2/route regression
  `reports/report_881/` `14/14`; headless main-scene smoke
  `reports/boss2_victory_route_handoff_main_scene_smoke.log` exited `0` with
  no script/parse/invalid/missing-resource/resource-load errors and only
  Godot's known cleanup-time `resources still in use at exit` message. Godot
  MCP 2.8.1 clean runtime with `autosave=false` confirmed
  `defeat_ok=true`, `claim_ok=true`, `double_jump_ok=true`, `route_ok=true`,
  reward prompt `Claim Double Jump`, gate state `unlocked`, route prompt
  `Enter Factory Route`, `factory_route_transition_requested=true`, clean game
  logs, clean editor logs, and screenshot
  `reports/visual/cinderpaw-mcp-boss2-victory-route-handoff-20260630.png`.
  QA evidence:
  `production/qa/evidence/boss2-victory-route-handoff-2026-06-30.md`。
- Player Abilities Story 032: Boss2 Phase II Runtime Pressure Mix —
  `Boss2EchoGuardian` now enters Phase II at half HP (`18/36`), updates the Boss
  HUD to `Echo Guardian  Phase II  18/36`, raises chase pressure from `3.0` to
  `3.6` px, and lowers attack cooldown from `28` to `24` frames. If the
  threshold is crossed during `startup`, `active`, or `recovery`, the phase
  transition is deferred until the current attack chain returns to idle, so the
  readable `boss2_echo_swipe` timing is not interrupted. `MainScene` routes
  Boss2 phase transitions to CombatPresentation, AudioSystem, and the active
  Boss HUD; `AudioSystem` now registers Boss2 Phase I/II music cues using
  existing `mus_boss_rat_p1` / `mus_boss_rat_p2` and routes Phase II to
  `sfx_boss_phase`. No new visual or audio assets were generated. Verification:
  RED `reports/report_863/`, deferral RED `reports/report_866/`, audio RED
  `reports/report_869/`; audio GREEN `reports/report_870/` `1/1`; Story032
  focused GREEN `reports/report_876/` `4/4`; Boss2 autonomous regression
  `reports/report_878/` `6/6`; related Boss2 regression `reports/report_877/`
  `31/31`; headless main-scene smoke
  `reports/boss2_phase_two_runtime_pressure_mix_main_scene_smoke.log` exited
  `0` with no script/parse/invalid/missing-resource/resource-load errors and
  only Godot's known cleanup-time `resources still in use at exit` message.
  Godot MCP 2.8.1 runtime with `autosave=false` confirmed Boss2 HP `36 -> 18`,
  phase `1 -> 2`, HUD Phase II, pressure diagnostics
  `chase_step_px=3.6` / `attack_cooldown_target_frames=24`,
  CombatPresentation phase `2` with `32` debris, AudioSystem
  `boss_id="boss_02_echo_guardian"` / `music_id="mus_boss_rat_p2"` /
  `sfx_boss_phase`, visible Boss2 `AnimatedSprite2D + SpriteFrames` with
  `idle/run/attack/hurt/death` frame counts all `3`, MCP UI tree confirmed
  Boss HUD text `Echo Guardian  Phase II  18/36`, inline game screenshot
  `960x539` was non-empty with Boss2 arena/character/HUD visible, game logs
  had only helper/DataManager info, and editor logs were clean after fixing the
  MCP-reported ternary type warning in `src/gameplay/main_scene.gd`. QA evidence:
  `production/qa/evidence/boss2-phase-two-runtime-pressure-mix-2026-06-30.md`。
- Player Abilities Story 031: Boss2 HUD Portrait Runtime — `HUDManager` now
  shows a compact generated Boss2 Echo Guardian portrait in the existing Boss
  HUD while Echo Guardian owns HUD focus. The portrait is imported from
  `assets/ui/boss_portraits/boss2_echo_guardian_portrait.png`, sourced from
  `assets/generated/source/boss2_echo_guardian_portrait_imagegen_20260630.*`,
  and uses `TextureRect.EXPAND_IGNORE_SIZE` so the 128x128 texture renders as a
  48x48 HUD element instead of resizing the boss strip. When Boss2 is defeated
  or restored defeated, the portrait is hidden and cleared while the label hands
  back to Rat King. Verification: RED `reports/report_855/` failed on missing
  portrait diagnostics; RED refinement `reports/report_858/` caught the
  oversized 128x128 render; final GREEN focused `reports/report_862/` passed `2/2`;
  related HUD/Boss2 regression `reports/report_861/` passed `30/30`; headless
  main-scene smoke `reports/boss2_hud_portrait_runtime_main_scene_smoke.log`
  exited `0` and keyword scan found no script/parse/invalid/missing-resource or
  logged-error entries. Godot MCP runtime with `autosave=false` confirmed
  `BossPortrait` as a visible `TextureRect` with 48x48 display size and the
  generated portrait texture while Boss2 is active, confirmed defeated-state
  cleanup to `visible=false` and `texture=null`, clean game/editor logs, and
  nonblank screenshot
  `reports/visual/cinderpaw-mcp-boss2-hud-portrait-runtime-20260630.png`. QA
  evidence:
  `production/qa/evidence/boss2-hud-portrait-runtime-2026-06-30.md`。
- Player Abilities Story 030: Boss2 Room Seal Runtime — `scenes/main.tscn`
  now contains generated, visible Boss2 room-seal doors at the room edges:
  `Boss2LeftRoomSeal` and `Boss2RightRoomSeal`. `MainScene` exposes
  deterministic room-seal diagnostics, enables both `StaticBody2D` blockers on
  environment layer `16` while Boss2 is active and undefeated, and hides/disables
  both seals when `boss_02_echo_guardian_defeated` is set or restored, while
  keeping `Boss2DoubleJumpRewardSource` visible. New image-generated art was
  preserved at
  `assets/generated/source/boss2_echo_guardian_room_seal_imagegen_20260630.*`
  and imported as
  `assets/environment/boss2_arena/boss2_echo_guardian_room_seal.png`.
  Verification: RED `reports/report_848/`; GREEN focused `reports/report_849/`
  `3/3`; autonomous pressure related `reports/report_850/` `6/6`; final
  focused after placement/refactor refinement `reports/report_854/` `3/3`; final related
  Boss2 regression `reports/report_853/` `19/19`; headless main-scene smoke
  `reports/boss2_room_seal_runtime_main_scene_smoke.log` exited `0` and
  keyword scan found no script/parse/invalid/missing-resource/logged-error
  entries. Godot MCP runtime with `autosave=false` confirmed both seals visible
  and blocking before defeat, both hidden with `collision_layer=0` after setting
  Boss2 defeated, reward source still visible, clean game/editor logs, and
  nonblank screenshot
  `reports/visual/cinderpaw-mcp-boss2-room-seal-runtime-20260630.png`. QA
  evidence:
  `production/qa/evidence/boss2-room-seal-runtime-2026-06-30.md`。
- Player Abilities Story 027: Parry Laser Gate Authored Visual Replacement —
  `ParryLaserExplorationGate/Visual` now uses a dedicated image-generated
  transparent 256x256 marker at
  `assets/environment/parry_laser_gate/parry_laser_gate_marker.png` instead of
  reusing `assets/environment/rat_king_arena/electric_leak.png`. The authored
  gate art has scrap-metal emitters, cyan laser bars, a cat-eye gold parry core,
  and signal-red lock accents, with source PNG and metadata under
  `assets/generated/source/parry_laser_gate_marker_imagegen_20260630.*`.
  Story019 parry unlock behavior is preserved: the gate starts `unlockable`,
  blocks collision before use, unlocks when Cinderpaw parries in range, and
  records the gate/world flags in save snapshots. Verification: RED
  `reports/report_827/` failed as expected on old electric-leak texture reuse,
  missing new PNG/import, old texture size, and rotation. Godot import exited
  `0`. GREEN focused `reports/report_828/` passed `5/5`; related visual/parry
  regression `reports/report_829/` passed `9/9`; headless main-scene smoke
  `reports/parry_laser_gate_authored_visual_replacement_main_scene_smoke.log`
  exited `0` and keyword scan found no script/parse/invalid/resource-load
  errors. Godot MCP runtime with `autosave=false` confirmed the main scene,
  authored gate texture path and `256x256` size, rotation `0`, visible
  `Sprite2D`, Player `AnimatedSprite2D + SpriteFrames`, `parry` frame count `3`,
  `request_parry()` unlock flow, clean game/editor logs, and nonblank screenshot
  `reports/visual/cinderpaw-mcp-parry-laser-gate-authored-visual-replacement-20260630.png`.
  QA evidence:
  `production/qa/evidence/parry-laser-gate-authored-visual-replacement-2026-06-30.md`。
- Player Abilities Story 020: Parry Success Feedback Runtime —
  `MainScene` now connects the player's Core
  `CombatComponent.on_parry_resolved` signal and forwards enriched parry
  metadata to both `CombatPresentation.on_parry_event()` and
  `AudioSystem.on_parry_event()`. The bridge preserves Core fields such as
  `is_success`, `parry_type`, and `parry_frame`, adds the visible Cinderpaw
  sprite `position`, and marks `source="player_parry"` so VFX/SFX do not land
  at `(0,0)`. PERFECT parry now produces the existing GDD-tuned feedback in the
  main runtime scene: 8 frames hitstop, 8.0 shake, one flash overlay, 22 radial
  parry sparks, and `sfx_parry_perfect`; GOOD parry is forwarded without
  triggering PERFECT-only flash/sparks. No new visual/audio assets were
  generated; this story reuses the existing image-generated parry flash/spark
  assets, Story019 Cinderpaw `parry` SpriteFrames, and imported parry SFX.
  Verification: RED `reports/report_733/`; initial GREEN focused
  `reports/report_734/` `8/8`; final focused after GOOD-parry negative coverage
  `reports/report_736/` `9/9`; final related regression `reports/report_737/`
  `72/72`; headless smoke
  `reports/parry_success_feedback_runtime_main_scene_smoke.log` exited `0` and
  keyword scan found no script/parse/invalid/resource-load errors. Godot MCP
  runtime with `autosave=false` confirmed Player `AnimatedSprite2D +
  SpriteFrames`, `parry` frame count `3`, `request_parry()` true, PERFECT
  metadata, presentation flash/spark/hitstop/shake counts, `sfx_parry_perfect`
  with `stream_found=true` at the sprite position, clean game/editor logs, and
  screenshot
  `reports/visual/cinderpaw-mcp-parry-success-feedback-runtime-20260626.png`.
  QA evidence:
  `production/qa/evidence/parry-success-feedback-runtime-2026-06-26.md`。
- Player Abilities Story 019: Parry Laser Gate Runtime —
  新增 Cinderpaw `parry` 玩家可见帧动画，使用 image generation 生成
  source strip，保留
  `assets/characters/cinderpaw/source/cinderpaw_parry_strip_imagegen_20260626.png`
  和 alpha source，并切成
  `assets/characters/cinderpaw/parry/cinderpaw_parry_000.png` 至 `_002.png`
  三张透明 96x96 PNG，接入
  `assets/characters/cinderpaw/cinderpaw_sprite_frames.tres` 的 `parry`
  动画。`PlayerController.request_parry()` 现在通过 AbilityComponent 的
  初始 `parry` 能力和 0.3s 冷却，同时要求 Core `CombatComponent` 可以从
  IDLE 进入 `PARRYING`；如果 Core combat 正在 CHARGING 等阻塞状态，parry
  会失败且不会发出 `ability_activated` 或消耗冷却。`scenes/main.tscn`
  新增 `ParryLaserExplorationGate`，配置
  `gate_id="parry_laser_central_tower"`、
  `required_ability="parry"`、`target_area_id="area_05_central_tower"`，
  初始为 `unlockable`，玩家在范围内执行 parry 后变为 unlocked，关闭碰撞，
  并把 `exploration_gates.unlocked`、`gate_parry_laser_central_tower_unlocked`
  和 `area_05_central_tower_unlocked` 写入存档快照。Verification: RED
  `reports/report_726/`；RED import refinement `reports/report_727/`；
  initial GREEN focused `reports/report_728/` `3/3`；initial related
  `reports/report_729/` `25/25`；blocked-combat cooldown-order RED
  `reports/report_730/`；final focused `reports/report_731/` `4/4`；final
  related `reports/report_732/` `26/26`；headless main-scene smoke
  `reports/parry_laser_gate_runtime_main_scene_smoke.log` exited `0` and log
  keyword scan found no parse/invalid/missing-resource errors. Godot MCP
  runtime with `autosave=false` confirmed `/Main/ParryLaserExplorationGate`,
  Player `AnimatedSprite2D + SpriteFrames`, `parry` frame count `3`, runtime
  `request_parry()` unlocks the gate and save flags, clean game/editor logs,
  and screenshot
  `reports/visual/cinderpaw-mcp-parry-laser-gate-runtime-20260626.png`。
  QA evidence:
  `production/qa/evidence/parry-laser-gate-runtime-2026-06-26.md`。
- Player Abilities Story 018: Skill Tree Cat Claw T1-A First Spend —
  新增 `skill_tree` DataManager 域与 schema，创建场景级
  `SkillTreeManager`，并把 Rat King 奖励的 SP 接入最小可见技能树菜单。
  Cat Claw T1-A（GDD 名称 `疾步连爪`，当前 HUD 显示 `Quickstep Claws`）
  现在可消耗 1SP 解锁，记录到 `unlocked_skills`，随 runtime progress、
  no-loss state、save snapshot/restore 持久化，并向 `PlayerController`
  注入 `light_attack_2` 的 `dash_distance ADD 8.0` modifier。玩家第二段
  Cat Claw 轻攻击现在在 Core weapon hitbox 成功激活后前冲 8px，并把
  `skill_lunge_px` / `hitbox_offset_x` 写入攻击 metadata。`HUDManager`
  新增 Skill Tree 菜单入口、解锁按钮、技能树信号和诊断 API；`MainScene`
  负责 SP 消耗、HUD 刷新、音频事件分发和 skill modifier provider 注入。
  No new visual assets were generated; the story reuses existing
  image-generated Cinderpaw/environment/gate-feedback assets. Verification:
  RED `reports/report_719/`; GREEN focused before refactor `reports/report_720/`
  `2/2`; related before refactor `reports/report_723/` `42/42`; final
  focused `reports/report_724/` `2/2`; final related `reports/report_725/`
  `42/42`; headless main-scene smoke
  `reports/skill_tree_cat_claw_t1a_main_scene_smoke.log` exited `0` and log
  keyword scan found no parse/invalid/missing-resource errors; Godot MCP
  runtime confirmed `/Main/SkillTreeManager`, Player `AnimatedSprite2D` +
  `SpriteFrames`, Rat King reward `0 -> 5` SP, Skill Tree HUD, unlock `true`,
  SP `5 -> 4`, modifier payload, second attack `+8px` lunge and metadata,
  clean game/editor logs, and screenshot
  `reports/visual/cinderpaw-mcp-skill-tree-cat-claw-t1a-20260626.png`.
  QA evidence:
  `production/qa/evidence/skill-tree-cat-claw-t1a-first-spend-2026-06-26.md`。
- Player Abilities Story 017: Old Factory Spark Rat Pacing Polish —
  `FactorySparkRat` now has encounter pacing instead of behaving like an
  immediate bite check after the endpoint opens. `OldFactoryEntranceScene` adds
  `FACTORY_SPARK_RAT_ACTIVATION_X`, `advance_factory_spark_rat_pacing_frames()`,
  scene-local `factory_spark_rat_opening_grace_frames` persistence, and
  deterministic diagnostics for activation readiness, player distance, collision,
  target binding, current animation, attack sequence, alert radius, patrol bounds,
  and opening grace. `FactorySparkRat` now waits through an 18-frame opening
  grace, patrols between bounded points with the existing `run` animation while
  the player stays outside its 180px alert radius, and preserves the existing
  chase / `attack_tell -> attack` bite chain once alerted. `RatMinion` gained a
  small overridable `get_attack_startup_frames()` hook; Spark Rat overrides the
  startup to 12 frames without changing shared Rat Minion constants. Story015's
  9-damage `factory_spark_rat_bite` and dodge-counter contract remain intact. No
  new image asset was required; the story reuses the existing image-generated
  Factory Spark Rat `AnimatedSprite2D + SpriteFrames` assets. Verification:
  RED `reports/report_712/`, GREEN focused `reports/report_714/` `5/5`, Spark
  Rat/dodge-counter related regression `reports/report_715/` `32/32`, Old
  Factory route related regression `reports/report_716/` `32/32`, final
  pre-commit focused `reports/report_717/` `5/5`, `git diff --check`,
  headless Factory and main scene smoke logs, clean keyword scans, and
  Godot MCP runtime probe/log/screenshot evidence. MCP confirmed initial visible
  inactive state, pressure-line blocked activation, active collision `2/17`,
  opening grace `18`, startup `12`, `attack_tell.loop=false`, tell-phase no
  damage, active bite `100 -> 91`, clean game/editor logs, and nonblank
  screenshot
  `reports/visual/cinderpaw-mcp-old-factory-spark-rat-pacing-polish-20260626.png`.
  QA evidence:
  `production/qa/evidence/old-factory-spark-rat-pacing-polish-2026-06-26.md`。
- Player Abilities Story 011: Old Factory Deep Guard Activation Pacing —
  `FactoryDeepGuardRatMinion` now starts visible but inactive in the Old
  Factory deep route: no attack target, no physics/process ticking, and no
  blocking collision until the entrance guard is defeated and the player crosses
  `deep_guard_activation_x`. `OldFactoryEntranceScene` adds
  `try_activate_factory_deep_guard()`, `is_factory_deep_guard_activated()`,
  scene-local `factory_deep_guard_activated` persistence, and deterministic MCP
  diagnostics for target/process/physics state. Activation restores the Rat
  Minion target and layer/mask, duplicate activation is rejected, and defeating
  the activated guard still unlocks the generated endpoint once. No new image
  asset was required; the story reuses the Story010 generated endpoint prop and
  existing Rat Minion `AnimatedSprite2D + SpriteFrames`. Through RED
  `report_662`, GREEN focused `report_663` `4/4`, final related regression
  `report_665` `26/26`, headless smoke
  `reports/old_factory_deep_guard_activation_pacing_factory_scene_smoke.log`
  and `reports/old_factory_deep_guard_activation_pacing_main_scene_smoke.log`,
  plus Godot MCP runtime probe/log/screenshot evidence, the route now reads as
  two sequential ACT encounters instead of an immediate mixed brawl. QA
  evidence:
  `production/qa/evidence/old-factory-deep-guard-activation-pacing-2026-06-26.md`。
- Scene Management Story 013: Rat King Arena Placeholder Visual Removal —
  removed the remaining visible `Polygon2D` placeholder baseline from Rat King
  arena mutation runtime nodes while preserving Story008 collision/metadata,
  Story009 electric leak contact damage, Story011 generated `Sprite2D`/`Vfx`
  layers, and Story012 save/load restoration. `_add_arena_mutation_visual(...)`
  remains as a compatibility seam but no longer creates a visible shape; tests
  now assert no visible `Polygon2D`/`ColorRect` child exists under active
  mutations. Through RED `report_608`, initial GREEN `report_609` `14/14`,
  final focused + related regression `report_610` `23/23`, headless smoke
  `reports/rat_king_arena_placeholder_visual_removal_smoke.log`, Godot MCP
  runtime probe confirming `3` active mutations with generated sprites/VFX and
  `visible_placeholders=[]`, clean game/editor logs after the successful probe,
  and screenshot
  `reports/visual/cinderpaw-mcp-rat-king-arena-placeholder-visual-removal-20260626.png`.
  No new image-generated asset was needed; existing generated arena mutation
  prop and VFX assets were reused. QA evidence:
  `production/qa/evidence/rat-king-arena-placeholder-visual-removal-2026-06-26.md`。
- Player Abilities Story 002: Dash Exploration Gate Runtime —
  新增 `src/feature/exploration_gate.gd` 场景级能力门控组件，支持
  `locked` / `unlockable` / `unlocked` 三态、Player/AbilityComponent
  `has_ability("dash")` 查询、`ability_unlocked` 与 `ability_activated`
  监听、近距离 Dash 解锁、碰撞开关、提示文本与视觉 modulate 更新。
  `scenes/main.tscn` 新增 `DashExplorationGate`，复用现有 image-generated
  `assets/environment/rat_king_arena/electric_leak.png` 作为可替换 baseline
  电栅栏视觉；无 Dash 时阻挡并显示 `Requires Dash`，Rat King reward /
  `MainScene.unlock_ability("dash")` 后变 `unlockable` 并显示 `Dash through`，
  玩家在门旁执行 Dash 后变 `unlocked`、关闭碰撞并隐藏提示。`MainScene`
  现在同步 `exploration_gate` 组，记录 `world_state.exploration_gates.unlocked`
  与 `gate_dash_gate_commercial_street_unlocked`、`area_02_sewer_unlocked`
  world flags，并在 restore 时恢复已打开 gate。通过 RED `report_599`、
  GREEN focused `report_604` `2/2`、related regression `report_606` `12/12`、
  headless smoke `reports/exploration_gate_dash_main_scene_smoke.log`、Godot
  MCP runtime `locked -> unlockable -> unlocked` probe、clean runtime logs 和
  screenshot
  `reports/visual/cinderpaw-mcp-dash-exploration-gate-runtime-20260626.png`
  验证。GdUnit/headless process exit 仍出现既有 ObjectDB/resource cleanup
  warnings；focused/related test results 和 MCP runtime logs clean。QA
  evidence:
  `production/qa/evidence/dash-exploration-gate-runtime-2026-06-26.md`。
- Player Abilities Story 001: Dash Runtime Ability Gate —
  新增 `data/abilities.json` 与 `data/schemas/abilities.schema.json`，并在
  `data/manifest.json` 注册 `abilities` domain；新增
  `src/core/ability_component.gd` 作为 Player 子节点能力组件，支持
  初始能力、`dash` 锁定/解锁、重复解锁拒绝、`try_activate_ability()`、
  1.0 秒 Dash 冷却、能力事件、序列化接口与安全 fallback。`scenes/player.tscn`
  挂载 `AbilityComponent`；`PlayerController` 现在将能力查询/激活/冷却委托给
  组件，并在解锁后执行可见 Dash：播放 `dash` SpriteFrames animation、发出
  `dash_started` 与 `ability_activated`、施加向前 620px/s burst。新增
  `assets/characters/cinderpaw/dash/cinderpaw_dash_000.png` through `_002.png`
  及 `.import`，并将 `cinderpaw_sprite_frames.tres` 的 `dash` 动画改为引用
  dash 目录帧。Dash 帧为现有 image-generated Cinderpaw dodge strip 的派生复用，
  已记录到 asset manifest 和 QA evidence，后续可替换为 Dash-only authored
  generation。通过 RED 缺失 `AbilityComponent` / 早期 `report_596` 缺失 Dash
  animation，GREEN focused `report_597` `6/6`，related regression
  `report_598` `40/40`，headless smoke
  `reports/player_dash_runtime_main_scene_smoke.log`，以及 Godot MCP runtime
  probe 验证 `/Main/Player/AbilityComponent`、`AnimatedSprite2D` dash 三帧路径、
  locked request false、unlock 后 `request_dash()` true、`animation=dash`、
  `cooldown=1.0`、`velocity.x=620`、afterimage count 3、clean game/editor logs
  和 screenshot
  `reports/visual/cinderpaw-mcp-player-dash-ability-runtime-20260625.png`。
  QA evidence:
  `production/qa/evidence/player-dash-runtime-ability-gate-2026-06-25.md`。
- Boss Configuration Story 010: Rat King Defeat Reward Runtime Consumption —
  `BossConfigComponent` optionally brackets defeat reward dispatch with
  `begin_boss_defeat_rewards()` / `finish_boss_defeat_rewards()` adapter hooks;
  `RatKingBoss` forwards the reward adapter into its mounted BossConfig
  component; `MainScene` consumes configured Rat King defeat rewards into
  runtime progression (`dash`, `50` Gears, `5` skill points), removes the old
  hard-coded `25` Gears victory reward, displays the claimed reward in HUD
  notification/retry menu, and persists reward fields through no-loss state,
  save snapshots, and boss-defeat autosave. Through RED `report_588`, GREEN
  focused `report_589` `1/1`, final related regression `report_595` `13/13`,
  headless smoke, and Godot MCP runtime reward probe/log/screenshot evidence,
  the slice verifies `currency=50`, `skill_points=5`,
  `unlocked_abilities=["dash"]`, HUD `Gears 50`, reward menu text, save fields,
  clean game/editor logs, and screenshot
  `reports/visual/cinderpaw-mcp-rat-king-reward-runtime-20260625.png`.
  Residual ObjectDB/resource cleanup warnings still appear at process exit in
  GdUnit/headless runs; runtime logs are clean. QA evidence:
  `production/qa/evidence/rat-king-defeat-reward-runtime-2026-06-25.md`。
- Audio System Story 008: Music + Ambience Asset Import Baseline —
  新增 15 个程序化 baseline 音乐/环境音 WAV，覆盖 GDD 全量 baseline cue：
  `mus_hub`、`mus_street`、`mus_sewer`、`mus_factory`、`mus_rooftop`、
  `mus_tower`、`mus_boss_rat_p1`、`mus_boss_rat_p2`、`mus_boss_rat_p3`、
  `amb_hub`、`amb_street`、`amb_sewer`、`amb_factory`、`amb_rooftop`、
  `amb_tower`。资产放入 `assets/audio/music/` 与 `assets/audio/ambient/`，
  并通过 Godot import pipeline 生成 `.wav.import`。生成配方记录在
  `assets/audio/source/music_ambience_generation_20260625.json`。`AudioSystem`
  新增默认 music/ambient stream manifest 并在 `_ready()` 加载，现有 scene cue
  和 Rat King boss music cue 现在能返回真实 `AudioStream` 播放；unknown
  music/ambient cue 仍 silent-safe。通过 RED `report_585`、GREEN focused
  `report_586` `19/19`、related regression `report_587` `32/32`、Godot import、
  headless smoke `reports/audio_music_ambience_main_scene_smoke.log`、Godot MCP
  runtime 15 cue registration / scene `mus_street+amb_street` / Rat King
  `mus_boss_rat_p1/p2/p3` stream probe、clean game/editor logs 和
  `reports/visual/cinderpaw-mcp-music-ambience-baseline-20260625.png` 验证。
  `report_587` 在 Godot process exit 处仍出现既有 GdUnit resource cleanup
  warning；focused Story008、headless smoke 和 MCP logs clean。QA evidence:
  `production/qa/evidence/audio-music-ambience-asset-import-baseline-2026-06-25.md`。
- Audio System Story 007: UI Menu Audio + Same-SFX Merge —
  新增 7 个程序化 baseline UI WAV：`ui_menu_open`、`ui_menu_close`、
  `ui_navigate`、`ui_confirm`、`ui_cancel`、`ui_save`、`ui_load`，放入
  `assets/audio/ui/` 并通过 Godot import pipeline 生成 `.wav.import`。
  生成配方记录在
  `assets/audio/source/ui_menu_audio_generation_20260625.json`。`AudioSystem`
  现在默认加载 UI cue，新增 4 路非空间 `UIPlayer` pool、`play_ui_sfx()`、
  `on_menu_opened()` / `on_menu_closed()`、`on_ui_*()` helpers 和 MENU state
  diagnostics；菜单打开会捕获当前 Music volume 并 duck 到 50%，关闭时恢复
  上一 audio state 和音量。`play_sfx()` 新增 TR-audio-005 same-SFX merge：
  100ms 内同 cue 复用 active voice，线性音量乘 `1.2`，不新增 pool voice。
  `MainScene` 现在通过 runtime adapter 转发 pause/resume/menu navigation/
  save/load feedback，不让 HUD、SaveSystem 或 Core gameplay 依赖 AudioSystem。
  通过 RED `report_580`、GREEN focused `report_582` `25/25`、related
  regression `report_583` `36/36`、post-fix guard `report_584` `10/10`、
  Godot import、headless smoke
  `reports/audio_ui_menu_audio_main_scene_smoke.log`、Godot MCP runtime UI cue /
  MENU duck / save-load cue / same-SFX merge probe、clean game/editor logs 和
  `reports/visual/cinderpaw-mcp-ui-menu-audio-20260625.png` 验证。`report_583`
  在 Godot process exit 处仍出现既有 GdUnit resource cleanup warning；focused
  Story007、headless smoke 和 MCP logs clean。QA evidence:
  `production/qa/evidence/audio-ui-menu-audio-sfx-merge-2026-06-25.md`。
- Scene Management Story 012: Boss Arena Mutation Save-State Persistence —
  `MainScene.capture_save_snapshot()` 现在将 active Rat King arena mutations
  写入 `world_state.arena_mutations`，保存为 JSON-safe deterministic
  descriptors：`boss_id`、`phase`、`id`、`type`。`restore_save_snapshot()`
  会清理当前 arena mutation，再通过现有 `apply_arena_changes()` 重建
  Story008 collision/metadata、Story009 electric leak damage-zone wiring 和
  Story011 VFX children；重复 restore 或重复应用 BossConfig changes 不会复制
  mutation/VFX 节点。SaveSystem slot 1 runtime save/load 已覆盖该状态；boss
  defeat/autosave 与旧存档缺失 `arena_mutations` 时会记录或恢复为空，避免
  清场后 hazard 复活。通过 pre-implementation RED failure、GREEN focused `report_577`
  `6/6`、related regression `report_578` `26/26`、title/load handoff guard
  `report_579` `7/7`、headless smoke、Godot MCP runtime save/cleanup/load/
  reapply probe、clean game/editor logs 和
  `reports/visual/cinderpaw-mcp-arena-mutation-save-state-20260625.png`
  验证。`report_578` 仍在 Godot process exit 处出现既有 ObjectDB/resource
  cleanup warning；focused Story012 和 MCP logs clean。QA evidence:
  `production/qa/evidence/boss-arena-mutation-save-state-persistence-2026-06-25.md`。
- Audio System Story 006: Weapon Style SFX Asset Expansion —
  新增 4 个程序化 baseline WAV：`sfx_blade_attack`、`sfx_bone_attack`、
  `sfx_bell_attack`、`sfx_parry_good`，放入 `assets/audio/sfx/` 并通过
  Godot import pipeline 生成 `.wav.import`。生成配方记录在
  `assets/audio/source/weapon_style_sfx_generation_20260625.json`。
  `AudioSystem` 默认加载这批 weapon-style/GOOD parry stream，现有
  `long_tail`、`fish_bone`、`electro_bell` attack adapters 和
  `parry_type="good"` 现在返回真实播放成功并记录 `stream_found=true`；
  missing/unknown cue 仍 silent-safe 且不消耗 pool voice。通过 RED
  `report_545`、Godot import、GREEN focused `report_546` `16/16`、related
  regression `report_553` `25/25`、headless smoke、Godot MCP runtime
  stream/playback/weapon-route/good-parry/unknown-cue probe、clean logs 和
  `reports/visual/cinderpaw-mcp-weapon-style-sfx-20260625.png` 验证。QA
  evidence:
  `production/qa/evidence/audio-weapon-style-sfx-asset-expansion-2026-06-25.md`。
- Audio System Story 005: Core Combat SFX Asset Import Baseline —
  新增 10 个程序化 baseline WAV：`sfx_claw_attack`、`sfx_hit_normal`、
  `sfx_hit_crit`、`sfx_parry_perfect`、`sfx_dodge`、
  `sfx_damage_taken`、`sfx_damage_taken_lowhp`、`sfx_enemy_death`、
  `sfx_boss_phase`、`sfx_focus_mode_activate`，放入
  `assets/audio/sfx/` 并通过 Godot import pipeline 生成 `.import` /
  `.sample`。生成配方记录在
  `assets/audio/source/core_combat_sfx_generation_20260625.json`。
  `AudioSystem` 新增默认核心战斗 SFX stream manifest、`load_audio_streams_from_paths()`、
  `get_registered_audio_stream_ids()` 和 `get_audio_stream_path()`；
  `_ready()` 默认加载这批 stream。现有 hit/parry/dodge/damage/focus/death/boss phase
  adapters 对入批 cue 返回真实播放成功并记录 `stream_found=true`，missing cue
  仍 silent-safe 且不消耗 pool voice。通过 RED `report_539`、import failure
  checkpoint `report_540`、Godot import、GREEN focused `report_542` `15/15`、
  related `report_543` `20/20`、headless smoke、Godot MCP runtime stream/playback
  probe、clean logs 和 `reports/visual/cinderpaw-mcp-core-combat-sfx-20260625.png`
  验证。QA evidence:
  `production/qa/evidence/audio-core-combat-sfx-asset-import-2026-06-25.md`。
- Audio System Story 004: Rat King Boss Music State Transitions —
  `AudioSystem` 新增 Rat King boss music cue map 与
  `on_boss_encounter_started()`、`on_boss_encounter_ended()`、
  `get_boss_music_state()`；Boss start 进入 `BOSS_FIGHT` 并请求
  `mus_boss_rat_p1`/`1.0` hard-cut，phase 2/3 在保留 `sfx_boss_phase` 的同时请求
  `mus_boss_rat_p2`/`mus_boss_rat_p3`/`2.0` phase transition，defeat/end 清空
  boss music state 并 `3.0` fade-out 回到 `NORMAL`（focus active 时仍保留
  LOW_HP 逻辑）。`MainScene` 作为 runtime adapter 在配置 AudioSystem 时转发
  Rat King encounter start，在 `_on_enemy_defeated()` 转发 encounter end，并给
  phase transition metadata 补 `boss_id`，不让 RatKingBoss、BossConfig、
  AIComponent 或 GameFlow 依赖 AudioSystem。通过 RED `report_535`、GREEN
  focused `report_536` `19/19`、最终相关回归 `report_538` `24/24`、headless
  smoke、Godot MCP runtime boss music state probe、clean logs 和
  `reports/visual/cinderpaw-mcp-boss-music-state-20260625.png` 验证。QA evidence:
  `production/qa/evidence/audio-boss-music-state-transitions-2026-06-25.md`。
- Scene Management Story 011: Rat King Final Arena VFX — 使用 image generation
  生成 Rat King arena VFX 三段图，复制到
  `assets/generated/source/rat_king_arena_vfx_imagegen_20260625.png`，alpha
  处理为 `rat_king_arena_vfx_alpha_20260625.png`，并裁切导入
  `assets/environment/rat_king_arena/vfx/arena_debris_dust.png`、
  `electric_leak_hazard_glow.png`、`electric_leak_spark.png`。`MainScene`
  保留 Story008/009 的 mutation root、collision、Visual、Sprite、电击伤害和
  cooldown 契约，在每个 mutation 下新增 `Vfx` 容器与带 `change_id`、
  `asset_source=image_generation`、`vfx_role` metadata 的 `Sprite2D` VFX 子节点；
  `garbage_pile` 和 `overturned_trash_can` 使用 debris dust，
  `electric_leak` 使用 hazard glow + electric spark。新增
  `tests/unit/gameplay/rat_king_arena_vfx_polish_test.gd` 与 MCP visual fixture
  `tests/fixtures/gameplay/rat_king_final_arena_vfx_probe.tscn/.gd`。通过 RED
  `report_530`、GREEN focused `report_531` `4/4`、related regression
  `report_534` `22/22`、headless smoke、Godot MCP runtime node/reapply/cleanup
  probe、clean logs 和可见 final arena VFX screenshot 验证。QA evidence:
  `production/qa/evidence/rat-king-final-arena-vfx-2026-06-25.md`。
- Scene Management Story 010: Scene Memory Budget Diagnostics — `SceneManager`
  现在暴露 `get_memory_budget_diagnostics()`、`check_runtime_memory_budget()`
  和 `enforce_runtime_memory_budget()`，并新增
  `on_memory_budget_exceeded(diagnostics)`。诊断 payload 覆盖 mobile/pc/console
  十进制字节预算、unknown/empty -> pc fallback、resident runtime scene ids/roles/count、
  current/previous/pending-reused 估算、pass/fail flags 和 over-budget bytes；
  估算只通过可选 `get_estimated_memory_bytes()` seam，缺失或无效估算按 `0`。
  Enforcement 只驱逐非当前 deferred previous cache，保留 current runtime scene；
  warning latch 在同一超预算状态只 emit 一次，回到 in-budget 后可再次 emit。
  通过 RED `report_520`、GREEN focused `report_526` `7/7`、SceneManager
  regression `report_527` `34/34`、MainScene transition/title 回归
  `report_528` `2/2` 和 `report_529` `7/7`、headless smoke、Godot MCP
  autoload/runtime-root/warning-latch probes、clean logs 和非空截图验证。QA evidence:
  `production/qa/evidence/scene-memory-budget-diagnostics-2026-06-25.md`。
- Scene Management Story 009: Electric Leak Contact Damage — `MainScene`
  现在将 Rat King phase 3 `electric_leak` arena mutation 作为真实 contact
  damage hazard 处理：damage zone 使用 ADR-0004 environment layer/mask
  (`16/12`)，通过 `Area2D.area_entered` 与每帧 overlap polling 检测玩家
  hurtbox，命中后走 `PlayerController.apply_damage()` 造成 8 点 electric
  damage，并转发 CombatPresentation hit feedback 与 AudioSystem
  `on_damage_taken_event`。同一 boss/change/target 使用 1.0 秒 cooldown，持续
  overlap 到冷却边界后会再次扣血；arena cleanup、boss reset/death 和 exit tree
  会清理 cooldown。通过 RED `report_510`、GREEN focused `report_518` `5/5`、
  final related regression `report_519` `24/24`、headless smoke、Godot MCP
  runtime phase 3 contact/cooldown/cleanup probe、clean logs 和可见 electric leak
  screenshot 验证。QA evidence:
  `production/qa/evidence/rat-king-electric-leak-contact-damage-2026-06-25.md`。
- Scene Management Story 008: Boss Arena Mutation Runtime — `RatKingBoss`
  新增 scene adapter 转发，`MainScene` 新增 `ArenaMutations` 容器、
  `apply_arena_changes()`、`get_arena_mutation_nodes()`、
  `cleanup_arena_mutations()`、boss scene lock/unlock hooks 和 arena reset
  清理路径。使用 image generation 生成 Rat King arena mutation 三联图，
  保留 source/alpha source 于 `assets/generated/source/`，裁切导入
  `assets/environment/rat_king_arena/garbage_pile.png`、
  `overturned_trash_can.png`、`electric_leak.png`；phase 2 生成
  `garbage_pile` StaticBody2D，phase 3 生成 `overturned_trash_can`
  StaticBody2D 与 `electric_leak` Area2D，节点带 boss id、phase、change id、
  change type metadata，含 CollisionShape2D、Polygon2D Visual 和 Sprite2D。
  通过 RED `report_501`、GREEN focused `report_506` `4/4`、相关回归
  `report_509` `24/24`、headless smoke、Godot MCP runtime phase 2/3 mutation
  probe、cleanup/reapply/reset probe 和 clean game logs 验证。MCP 截图保存到
  `reports/visual/cinderpaw-mcp-rat-king-arena-mutations-20260625*.png`，但
  当前 game framebuffer 未刷新出 mutation 可见帧，QA evidence 已如实记录为弱
  视觉证据。QA evidence:
  `production/qa/evidence/rat-king-arena-mutation-runtime-2026-06-25.md`。
- Boss Configuration Story 009: Rat King Live Phase Two Summon Runtime
  Integration — 使用 image generation 生成 Rat Minion 5x3 sprite sheet，复制到
  `assets/characters/rat_minion/source/`，alpha-matted 后切成 `idle`、`run`、
  `attack`、`hurt`、`death` 五组 96x96 transparent runtime PNG 帧，并导入
  Godot asset pipeline。新增 `scenes/characters/rat_minion.tscn`、
  `src/characters/rat_minion.gd`、`assets/characters/rat_minion/rat_minion_sprite_frames.tres`、
  `src/gameplay/rat_minion.tscn` 和 `src/gameplay/rat_minion.gd`；`MainScene`
  现在实现 BossConfig summon adapter，Rat King phase 2 每 15 秒可召唤 live
  Rat Minion，active cap 为 2，玩家伤害可按 entity id 打到小怪，小怪 bite
  通过 Collision/Combat/DamageCalculator 对玩家造成 8 点伤害，boss death
  会清理 active summons。通过 RED `report_485`、GREEN `report_486` `7/7`、
  Gameplay regression `report_491` `94/94`、minimum risk regression
  `report_496` `17/17`、final verification `report_500` `17/17`、headless
  smoke、Godot MCP runtime SpriteFrames / summon cap / bite damage / cleanup
  probe、clean logs 和非空截图验证。Full
  unit `report_497` 仍有 Save Story004 full-order isolation failure；Rat Minion
  runtime 在同一 full run 中 `7/7` 通过，Data Story003 也已恢复 `7/7`。QA evidence:
  `production/qa/evidence/rat-king-live-phase-two-summon-runtime-2026-06-25.md`。
- Combat Presentation Story 015: Rat King Specialized Attack Animation
  Expansion — 使用 image generation 生成 5x3 Rat King 专用攻击 sheet，复制到
  `assets/characters/rat_king/source/`，alpha-matted 后切成
  `charge`、`claw_swipe`、`summon_minion`、`slam`、`berserk_combo` 五组
  192x192 transparent runtime PNG 帧，并导入 Godot asset pipeline。
  `assets/characters/rat_king/rat_king_sprite_frames.tres` 新增 5 个
  SpriteFrames animation；`RatKingBoss` 现在按 BossConfig/AI pattern id 映射
  对应动画，`charge`、`claw_swipe`、`slam`、`berserk_combo` 保持 hitbox
  metadata，`summon_minion` 提供 presentation hook，不混入 live summon scope。
  通过 RED `report_480`、GREEN focused `report_482` `15/15`、Boss/AI/Gameplay
  regression `report_484` `82/82`、headless smoke、Godot MCP runtime
  game_eval/log/screenshot 验证。QA evidence:
  `production/qa/evidence/rat-king-specialized-attack-animation-2026-06-25.md`。
- Boss Configuration Story 008: Rat King AI Attack Scheduler MainScene Runtime
  Integration — `AIComponent` 新增 BossConfig `apply_boss_phase()` 合同、
  当前 phase-filtered attack pattern ids、按 pattern id 启动攻击和
  BossConfig attack_speed_modifier timing；`data/combat/enemy_stats.json`
  新增 `boss_01_rat_king` 的 `charge`、`claw_swipe`、`slam`、
  `berserk_combo` attack profiles，Schema/DataManager 测试覆盖 BossConfig
  phase ids 与 AI pattern ids 对齐。`RatKingBoss` 现在运行时挂载
  `AIComponent`，关闭重复 physics 推进，由 RatKingBoss 单入口推进
  startup/active/recovery，并通过 `activate_hitbox()` adapter 合并 AI
  pattern metadata 和 Rat King Combat damage metadata。通过 RED
  `report_476`、GREEN focused `report_478` `18/18`、Boss/AI/Gameplay
  regression `report_479` `74/74`、headless smoke、Godot MCP runtime tree /
  game_eval / logs / screenshot 验证。QA evidence:
  `production/qa/evidence/rat-king-ai-attack-scheduler-2026-06-25.md`。
- Boss Configuration Story 007: Rat King Runtime MainScene Replacement —
  新增 `src/gameplay/rat_king_boss.gd` 和 `src/gameplay/rat_king_boss.tscn`，
  将 `scenes/main.tscn` 的 `/Main/Enemy` 从 Shadow Beast prototype 替换为
  Rat King runtime shell；`RatKingBoss` 挂载 Health、Collision、Combat、
  StatusEffect 和 BossConfig components，保持 MainScene 所需
  `enemy_health_changed`、`enemy_defeated`、`enemy_attack_landed`、
  attack/status/shield/respawn 方法契约，并使用
  `assets/characters/rat_king/rat_king_sprite_frames.tres` 作为可见
  `AnimatedSprite2D` 表面。MainScene 的 HUD、Audio、CombatPresentation、
  SaveSystem autosave 和 defeated boss state 已改用 `boss_01_rat_king` /
  `rat_king_claw`，并验证 66% HP 阈值会经 BossConfig 进入 phase 2、触发
  `phase_2_rebuild` 与 Presentation debris。通过 RED `report_468`、GREEN
  `report_469` `7/7`、visual/runtime regression `report_470` `28/28`、
  related boss/gameplay/save regression `report_475` `57/57`、MCP 修正编辑器
  stale Enemy cache 后 focused `report_474` `7/7`、headless smoke、Godot MCP
  runtime probe/log/screenshot 验证。QA evidence:
  `production/qa/evidence/rat-king-boss-runtime-main-scene-replacement-2026-06-25.md`。
- Combat Presentation Story 014: Rat King Boss Frame Animation Slice —
  新增 image-generated Rat King boss sprite sheet，复制到
  `assets/characters/rat_king/source/`，通过 chroma-key removal 生成 alpha
  source，再切成 192x192 transparent runtime PNG 帧；`RatKingCharacter`
  使用 `AnimatedSprite2D + SpriteFrames`，提供 `idle`、`attack_tell`、
  `attack`、`hurt`、`death`、`phase_1_intro`、`phase_2_rebuild` 和
  `phase_3_overload` 8 个动画状态，每个 3 帧。新增
  `scenes/characters/rat_king.tscn`、`src/characters/rat_king.gd`、
  `assets/characters/rat_king/rat_king_sprite_frames.tres` 和
  `tests/unit/gameplay/rat_king_character_animation_test.gd`；更新
  `design/assets/asset-manifest.md` 与 `design/assets/entity-inventory.md`，
  Rat King 状态从 Needed 推进到 Partial。通过 RED `report_463`、import
  correction `report_464`、GREEN `report_466` `2/2` 验证；MCP evidence 记录于
  `production/qa/evidence/rat-king-boss-frame-animation-2026-06-25.md`。
- Audio System Story 003: Combat + Health Event Audio Adapters —
  `AudioSystem` 现在提供 gameplay SFX event adapters：weapon attack
  (`sfx_claw_attack`/`sfx_blade_attack`/`sfx_bone_attack`/`sfx_bell_attack`)、
  hit (`sfx_hit_normal`/`sfx_hit_crit`)、parry
  (`sfx_parry_perfect`/`sfx_parry_good`)、dodge (`sfx_dodge`)、damage taken
  (`sfx_damage_taken`/focus active `sfx_damage_taken_lowhp`)、focus enter
  (`sfx_focus_mode_activate`)、enemy defeated (`sfx_enemy_death`) 和 boss phase
  (`sfx_boss_phase`)；缺失 stream 继续 silent-safe 并记录 position/priority/
  pitch metadata。`MainScene` 作为 runtime adapter 转发玩家攻击、敌人伤害、
  闪避、focus、敌人死亡和 Boss phase 事件，不让 Core/Player/Enemy/SceneManager
  直接依赖 AudioSystem。通过 RED `report_458`、GREEN `report_459` `16/16`、
  related regression `report_460` `90/90`、final focused `report_461` `27/27`、
  headless smoke、Godot MCP runtime probe/log/screenshot 验证；README 保持纯项目介绍。
  QA evidence:
  `production/qa/evidence/audio-combat-health-event-adapters-2026-06-25.md`。
- Audio System Story 002: Scene Transition Audio Fades —
  `AudioSystem` 现在消费场景过渡事件：load-start 会把当前 music/ambient
  记录为 2.0 秒强制淡出并标记 transition audio active；scene changed 会根据
  默认 cue map（`main -> mus_street + amb_street`，`hub -> mus_hub + amb_hub`）
  记录 3.0 秒场景音乐/环境声淡入；load failed 会清理 active 状态并记录 failure
  diagnostics，不启动新 cue。`MainScene` 新增 `configure_audio_system_runtime()`
  并在现有 SceneManager load-start/changed/failed 回调中转发给 AudioSystem，
  SceneManager 本身不依赖 AudioSystem。通过 RED `report_452`、GREEN focused
  `report_453`、focused regression `report_455` `19/19`、相关回归 `report_456`
  `122/122`、headless smoke、Godot MCP runtime probe/log/screenshot 验证。MCP
  期间发现并修复了编辑器内存态中 Enemy 仍显示旧 `Sprite2D`
  `shadow_beast_enemy.png` 的漂移：重新从 `src/gameplay/simple_enemy.tscn`
  实例化 `/Main/Enemy` 后保存，MCP 确认 Player/Enemy 都是
  `AnimatedSprite2D`。QA evidence:
  `production/qa/evidence/audio-scene-transition-fades-2026-06-25.md`。
- Scene Management Story 007: Fast Travel Preload + Scene Change —
  `SceneManager` 新增 `request_fast_travel_scene_change(scene_id, spawn_point)`
  一步式 fast-travel async 请求路径，沿用 Story003 `ResourceLoader` seam、
  Story005 runtime swap 和 Story006 deferred runtime cache；fast travel 使用
  2.0 秒 portal gate，metadata 包含 `fast_travel=true`、
  `transition_type="fast_travel"`、`portal_duration_sec=2.0`，并新增
  started/completed/failed fast-travel signals。已覆盖普通 async 仍保持 1.5 秒
  gate、deferred cache hit fast travel 不发新 loader request/get、runtime
  resident count 仍为 current + one cached、timeout retry once + hub fallback。
  通过 RED `report_439`（缺少 API/signals）、RED `report_441`（缺少
  `transition_type` metadata）、GREEN focused `report_443` `6/6`、
  SceneManagement 回归 `report_444` `18/18`、MainScene/HUD 回归
  `report_445` `35/35`、headless smoke、Godot MCP runtime probe（1.99 秒前不
  commit，2 秒后切到 `main/mcp_fast_travel_gate`，logs clean，screenshot
  nonblank，Player/Enemy 为 `AnimatedSprite2D`）验证。QA evidence:
  `production/qa/evidence/fast-travel-preload-scene-change-2026-06-25.md`。
- Scene Management Story 006: Deferred Unload + Runtime Cache Eviction —
  `SceneManager` 现在把成功 runtime swap 的 outgoing scene 从 runtime root
  detach 后保留为 3 秒 deferred cache，暴露 previous scene id、remaining
  seconds、resident runtime scene count 诊断；3 秒内返回 cached `scene_id`
  会复用同一个 Node，不再发起新的 threaded load request；连续第三场景切换会先
  evict 旧 cache，保证 SceneManager-owned resident runtime scene 始终不超过
  current + one cached。兼容 Story003 无 runtime root logical async contract
  与 Story005 invalid PackedScene failure/current attached contract。通过 RED
  `report_432`、GREEN focused `report_434` `4/4`、SceneManagement 回归
  `report_437` `12/12`、相关回归 `report_438` `59/59`、headless smoke、
  Godot MCP runtime probe（cache hit 复用同一 hub Node、resident count 2、
  deferred unload 清空 previous）、clean game/editor logs、非空截图与
  Player/Enemy `AnimatedSprite2D` runtime tree 验证。QA evidence:
  `production/qa/evidence/deferred-unload-cache-eviction-2026-06-25.md`。
- Scene Management Story 005: Runtime Scene-Tree Swap Ownership —
  `SceneManager` 现在可配置 runtime scene root，async load 完成且 1.5 秒
  transition gate 满足后会实例化 loaded `PackedScene` 并挂到该 root，先完成
  runtime tree swap 再发 `on_scene_loaded` / `on_scene_changed`；旧 runtime scene
  会从 root detach 并作为 previous reference 保留给后续 deferred-unload/cache
  Story；切换前通过 `get_local_state()` 保存当前 scene-local state，切换后通过
  `set_local_state()` 恢复目标缓存状态。invalid loaded resource 现在走
  `invalid_packed_scene` failure，不再逻辑回 hub，避免 runtime tree 与 logical
  scene/spawn 不一致。通过 RED `report_424`、行为 RED `report_425`、诊断 RED
  `report_429`、GREEN focused `report_430` `4/4`、相关回归 `report_431`
  `60/60`、headless smoke、Godot MCP success/failure runtime probes、clean logs
  与截图验证。QA evidence:
  `production/qa/evidence/runtime-scene-tree-swap-2026-06-25.md`。
- Scene Management Story 004: Transition Loading UI Shell — `SceneManager`
  现在在 async request accepted 后 emits
  `on_scene_load_started(scene_id, spawn_point, metadata)`；`HUDManager`
  新增 `SceneTransitionOverlay`，使用 image-generated
  `scene_transition_tunnel_overlay.png` 和透明 `scene_transition_paw_spinner.png`
  的 `TextureRect` 分层，显示动态 scene label 并旋转猫爪 spinner；
  `MainScene` 连接 SceneManager load-start/changed/failed 信号，菜单驱动路径优先
  `request_scene_change()`，失败时关闭过渡层并显示 `Load failed`。通过 RED
  `report_421`、GREEN focused `report_422` `28/28`；相关回归、headless smoke
  与 Godot MCP 证据记录在
  `production/qa/evidence/scene-transition-loading-ui-shell-2026-06-25.md`。
- Scene Management Story 003: Async Load Request Lifecycle + Timeout Fallback —
  `SceneManager` 新增 `request_scene_change()` async request API、loader
  adapter seam、`advance_loading()` 确定性推进、1.5 秒 transition gate、真实
  `ResourceLoader.load_threaded_request/get_status/get` 调用、10 秒 timeout
  retry once、`on_scene_load_failed(scene_id, reason)` 和 hub registry
  `default_spawn` fallback；保留 Story001/Story002 同步 `change_scene()` bool
  契约。通过 RED `report_414`、RED `report_418`、GREEN focused
  `report_419` `4/4`、相关回归 `report_420` `49/49`、headless smoke
  `reports/scene_story003_async_load_main_scene_smoke.log`、Godot MCP runtime
  success/timeout probe、clean logs 与非空 screenshot 验证。QA evidence:
  `production/qa/evidence/async-load-timeout-fallback-2026-06-25.md`。
- Scene Management Story 002: Title/Continue/Load Runtime Handoff —
  `MainScene` 的 New Game、Continue、Load Slot 现在先通过 root
  `SceneManager` 完成 logical scene/spawn handoff，再应用 SaveSystem
  runtime snapshot；Continue 使用确定性 slot 顺序 `0` then `1-3`，Load Slot
  使用所选 slot，目标 scene/spawn 解析顺序为 last savepoint、
  `world_state.scene_id`、`player_state.scene_id`、`main/default`。加载期间
  `main_scene` 与 `scene` registered systems 会临时从 SaveSystem
  反序列化列表移除，避免 SceneManager 拒绝时半恢复 HP/货币/settings。通过
  RED `report_408`、GREEN focused `report_412` `7/7`、相关回归
  `report_413` `47/47`、headless smoke
  `reports/scene_story002_title_load_handoff_main_scene_smoke.log`、Godot MCP
  New Game/Continue/Load Slot/failure-path runtime probe、clean logs 与非空
  screenshot 验证。QA evidence:
  `production/qa/evidence/title-continue-load-runtime-handoff-2026-06-25.md`。
- Death & Respawn Story 004: Savepoint Respawn Selection —
  `GameFlowController` 现在通过可注入 savepoint/SceneManager adapter 选择复活点：
  有效 last discovered savepoint 优先，无效/缺失 savepoint 回退 `hub/clan_base`，
  boss encounter 覆盖到独立 `main/boss_entrance`；`MainScene` 记录并随 SaveSystem
  runtime snapshot 保存/恢复最后发现的 savepoint，并把 root `SceneManager` 注入
  GameFlow。通过 RED `report_399`/`report_404`、GREEN `report_405` `4/4`、
  相关回归 `report_406` `24/24`、Godot headless smoke、Godot MCP runtime
  savepoint/fallback/boss probe、clean logs 与截图验证。截图：
  `reports/visual/cinderpaw-mcp-savepoint-respawn-selection-20260625.png`。
- Save System Story 005: Async Write Performance Budget —
  `SaveSystem` 默认启用异步 slot 写入，新增 pending/dispatch 诊断、
  `on_save_write_failed(slot, reason)`、单写入锁、主线程完成轮询、
  Web/deferred fallback、退出期 flush 收尾和同步 fallback；`MainScene`
  现在通过 `on_save_written`/`on_save_write_failed` 确认手动保存 UI，
  pending 期间第二次保存请求保持 `Saving...` 且不覆盖原 pending slot。
  通过 RED `report_384`、`report_388`、`report_392`，GREEN
  `report_386`、`report_393`，相关回归 `report_394` `42/42`、
  Godot headless smoke、Godot MCP runtime probe/log/screenshot 验证。
- Combat Presentation Story 013: Weapon Style VFX Variants —
  `CombatPresentation` 现在对普通 weapon attack-start 的 long-tail
  `trail_blade`、fish-bone `wave_bone`、electro-bell `arc_bell` 生成
  image-generated textured Sprite2D VFX；长尾为 1 个银色弧光、0.5s 生命周期，
  鱼骨为 1 个白色波纹、0.3s 生命周期，电铃为 6 个蓝色电弧、0.4s 生命周期，
  并全部进入 Story012 的 200 粒子 cap/FIFO eviction/性能诊断路径。
  通过 RED `report_377`、GREEN focused `report_381` `35/35`、相关回归
  `report_383` `47/47`、Godot headless smoke、Godot MCP 运行态三武器 probe、
  clean logs 与截图验证。截图：
  `reports/visual/cinderpaw-mcp-long-tail-vfx-20260624.png`,
  `reports/visual/cinderpaw-mcp-fish-bone-vfx-20260624.png`,
  `reports/visual/cinderpaw-mcp-electro-bell-vfx-20260624.png`。
- Combat Presentation Story 012: Particle Budget + Performance Guardrails —
  `CombatPresentation` 现在对 hit sparks、kill debris、perfect parry sparks、
  猫爪 trails、dodge afterimages、Boss phase debris 使用统一 FIFO 粒子注册表，
  暴露 `get_particle_cap() == 200`、`get_active_particle_count()`、
  `get_particle_eviction_count()`，超过 cap 时最旧粒子优先移除且 under-cap
  单事件粒子数量保持不变；`capture_performance_budget_sample(sample_frames)`
  返回 GDD 预算常量、平均采样耗时、`within_budget` 与状态保持结果，采样不会推进
  粒子生命周期、hitstop 或 shake。通过 RED `report_374`、GREEN focused
  `report_375` `27/27`、相关回归 `report_376` `43/43`、Godot headless
  smoke、Godot MCP 运行态 230->200 压力 probe/log/screenshot 验证。截图：
  `reports/visual/cinderpaw-mcp-combatfx-particle-budget-20260624.png`。
- Combat Presentation Story 011: Colorblind Combat VFX + Focus Shake
  Accessibility — `CombatPresentation` 现在支持 `none` / `red_green` /
  `blue_yellow` 粒子 palette remap，普通/暴击 hit sparks、PERFECT parry
  sparks、猫爪 trails、击杀 debris、Boss phase 2/3 debris 均按当前 HUD
  色盲模式生成；`HUDManager.colorblind_mode_changed` 由 `MainScene` 转发到
  presentation，保存/恢复 settings 后也会 resync；`Player/HealthComponent`
  的 `on_focus_mode_changed(entity_id, active, metadata)` 会路由到
  `CombatPresentation`，focus active 时后续 screen shake 强度乘 `0.7`，
  hitstop、duration、粒子数量和最大值聚合规则保持不变。通过 RED
  `report_370`、GREEN focused `report_372` `27/27`、相关回归 `report_373`
  `44/44`、Godot headless smoke、Godot MCP 运行态 palette/focus/日志/截图
  验证。截图：`reports/visual/cinderpaw-mcp-combatfx-default-hit-20260624.png`,
  `reports/visual/cinderpaw-mcp-combatfx-red-green-20260624.png`,
  `reports/visual/cinderpaw-mcp-combatfx-blue-yellow-20260624.png`,
  `reports/visual/cinderpaw-mcp-combatfx-focus-hit-20260624.png`。
- Combat Presentation Story 010: Boss Phase Visual Feedback — `CombatPresentation`
  现在消费 `on_boss_phase_transition_started(entity_id, phase, metadata)`，
  播放 4 帧 hitstop、phase shake、image-generated
  `combat_boss_phase_overlay.png` 全屏暗角/金属裂片 overlay，并生成 32 个
  textured Boss phase debris sprite，生命周期 1.5s；`MainScene` 新增
  BossConfig-style signal source registration 并转发 phase metadata 到
  presentation/HUD。通过 RED `report_361`、GREEN focused `report_368`
  `22/22`、相关回归 `report_369` `52/52`、Godot headless smoke、Godot MCP
  运行态 probe/log/screenshot 验证。截图：
  `reports/visual/cinderpaw-mcp-boss-phase-visual-feedback-20260624.png`。
- Combat Presentation Story 009: Boss Phase Transition Signal Contract —
  `BossConfigComponent` emits
  `on_boss_phase_transition_started(entity_id, phase, metadata)` when queued
  phase transitions actually start, maps Health threshold ordinals to actual
  Boss phase IDs, preserves trigger HP metadata, and filters foreign entity
  Health events. Verified by RED/GREEN focused tests, related regression,
  headless smoke, and Godot MCP runtime probe/log evidence.
- Combat Presentation Story 008: Damage Number Tier Polish — damage numbers now
  use all six GDD tiers (`12/16/20/28/36/48`), tier-specific colors, 151+
  cat-eye gold with white outline, 30px float distance, 1.5s lifetime, safe
  boundary handling, and `final_damage` metadata preference for the runtime Core
  hit chain. Verified by RED/GREEN focused tests, related runtime/presentation
  regression, headless main-scene smoke, and Godot MCP runtime probe/log/
  screenshot evidence. No new image asset was required because the polish uses
  Godot Label styling.
- Combat Presentation Story 007: Textured Parry Flash + Main Scene Visual Contract —
  PERFECT parry full-screen flash now uses image-generated
  `combat_parry_flash_overlay.png` through a `TextureRect` overlay instead of a
  visible `ColorRect`; `main_scene_visual_contract_test.gd` locks Player and
  Enemy runtime visuals to `AnimatedSprite2D + SpriteFrames` and verifies no
  visible gameplay `ColorRect` blocks at startup. Verified by RED/GREEN,
  focused Story007 14/14, related visual regression 39/39, Godot headless
  smoke, and Godot MCP runtime probe/log/screenshot evidence.
- HUD/UI Story 005: Main Menu + Save/Load Shell — `HUDManager` 现在提供
  main menu 与 save/load shell，按钮只发 typed signals；`MainScene` 作为薄
  adapter 收集 `SaveInfo` 风格槽位快照、调用既有 runtime save/load API，
  并在从 gameplay 回主菜单时释放 pause state 与焦点。SaveSystem
  Story001-004 已解除槽位/元数据阻塞；SceneManagement 真实切场景仍保持
  后续边界，不在本 Story 虚报完成。通过 RED/GREEN、HUD/MainScene/Save
  focused regression 37/37、Godot headless smoke 与 Godot MCP runtime
  eval/log/screenshot 验证。
- Save System Story 004: MainScene SaveSystem Runtime Handoff —
  `MainScene` 现在可配置 SaveSystem-like runtime service，注册 `main_scene`
  serializable payload，提供 JSON-safe `player_state/world_state/settings`
  快照，手动 slot 1-3 保存通过 `SaveSystem.manual_save()`，加载通过
  `SaveSystem.load_game()` + `get_last_loaded_data()` 回灌玩家 HP/位置、货币、
  武器、world flags 与 HUD settings；Boss 击败路径通过既有
  `SaveTriggerAdapter` 写 slot 0 autosave 并记录
  `autosave_reason="boss_defeat"` / `boss_id="shadow_beast"`；通过 Story004
  RED/GREEN、Save Story001-004 聚焦回归、MainScene gameplay 聚焦回归、
  Godot headless smoke 与 Godot MCP runtime game_eval 验证。`TR-save-007`
  已由 Save System Story005 完成
- Save System Story 003: Autosave Trigger Adapters —
  新增 `SaveTriggerAdapter` Feature 节点，将存档点、Boss 击败、关键事件、
  场景切换信号接到 `SaveSystem.auto_save()`；支持 snapshot provider、
  `autosave_reason`/`autosave_context` 写入 world_state、成功/失败信号，
  且不依赖具体 SavePoint/Boss/Quest/Ability/SceneManager/HUD/MainScene 类；
  通过 Story003 RED/GREEN、Save Story001-003 聚焦回归、Godot headless
  main-scene smoke 与 Godot MCP runtime game_eval 验证
- Save System Story 002: Version Migration + SaveInfo Metadata —
  新增 `SaveInfo` 元数据对象、`SaveSystem.get_save_info()`、
  `register_migration()` / `unregister_migration()`、`_meta.summary`
  UI 摘要、旧版本迁移写回、缺失迁移/未来版本安全失败；通过 Story002
  RED/GREEN、Save Story001+Story002 聚焦回归、Godot headless main-scene
  smoke 与 Godot MCP 运行态验证
- Save System Story 001: Save Slots + Backup JSON Pipeline —
  新增 `SaveSystem` Autoload，支持可配置存档目录、0 号自动存档槽、
  手动槽位保护、JSON `_meta/player_state/world_state/settings/systems`
  结构、注册系统确定性序列化/反序列化、覆盖写入 `.bak` 备份，以及
  主存档损坏时从备份恢复；通过 GdUnit RED/GREEN、最终 9/9 聚焦回归、
  Godot headless main-scene smoke 与 Godot MCP `/root/SaveSystem` 运行态验证
- HUD/UI Story 006: HUD Scale + Colorblind Mode — `HUDManager` 完成 HUD
  50%-150% 运行时缩放、菜单文本防重叠检查、红绿色盲蓝到黄 HP 映射、
  蓝黄色盲红到白 HP 映射、Boss Phase 罗马数字文本标记，以及
  SaveSystem-ready settings state handoff；`MainScene` no-loss snapshot 已包含
  HUD accessibility settings；通过 GdUnit 20/20、Focused regression 39/39、
  Godot headless smoke 与 Godot MCP 运行态验证
- AGENTS.md: 已补强并行 Agent 使用边界与 Godot 2D 帧动画/MCP 验收规则，
  包括 `AnimatedSprite2D + SpriteFrames`、`assets/characters/<character>/<animation>/`
  管线、MCP 场景/脚本/运行时日志/关键节点检查，以及禁止玩家可见角色只用方块或单帧占位验收
- Combat Presentation Story 006: Cinderpaw Jump and Fall Animation —
  Cinderpaw 新增 image-generated `jump`/`fall` 透明帧动画，接入
  `AnimatedSprite2D + SpriteFrames` 与 `PlayerController` 空中状态映射；
  起跳优先处理 Godot floor-contact 缓存边界；通过 GdUnit 32/32、
  Godot headless smoke 与 Godot MCP 运行态验证
- HUD/UI Story 004: Settings + Accessibility Controls — `HUDManager` 已提供
  Settings 菜单、audio/display/controls/gameplay 分组、battle summary 与
  damage number 运行时开关、HUD 50%-150% 缩放、红绿色盲 HP 调色，以及
  settings 返回 pause menu 的焦点恢复；`MainScene` 已接入运行时开关，
  `CombatPresentation` 支持 `show_damage_number=false` 且不抑制 hitstop/spark/shake；
  通过 GdUnit、Godot headless smoke 与 Godot MCP 运行态验证
- Feline Combat Story 009: Runtime Enemy Attack + Shadow Beast Frame Animation — `SimpleEnemy` 已接入 `AnimatedSprite2D + SpriteFrames`、Core enemy hitbox/Combat/Health 伤害链、MainScene 命中表现转发，并通过 GdUnit 与 Godot MCP 运行时验证
- /architecture-review: 提取185条TR，构建可追溯性矩阵，生成3个文件（审查报告+traceability index+TR registry）
- /gate-check pre-production: FAIL → 2 blocker（已修复），可重新提交

## Session Extract — /dev-story 2026-06-25

- Story: `production/epics/scene-management/story-003-async-load-timeout-fallback.md` — Async Load Request Lifecycle + Timeout Fallback
- Files changed: `src/feature/scene_manager.gd`, `tests/unit/scene/story_003_async_load_timeout_fallback_test.gd`, `production/epics/scene-management/story-003-async-load-timeout-fallback.md`, `production/epics/scene-management/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/async-load-timeout-fallback-2026-06-25.md`, `production/session-state/active.md`
- Test written: `tests/unit/scene/story_003_async_load_timeout_fallback_test.gd`
- Verification: RED `reports/report_414/`, RED `reports/report_418/`, GREEN `reports/report_419/` `4/4`, related regression `reports/report_420/` `49/49`, headless smoke `reports/scene_story003_async_load_main_scene_smoke.log`, Godot MCP runtime success/timeout probe, clean logs, non-empty `640x360` screenshot.
- Asset note: no image-generated visual asset was required for this logic/integration slice.
- Blockers: None
- Next: implement real scene-tree swap ownership, deferred unload/cache, fast travel, transition visuals/loading UI/audio, memory-budget verification, or continue player/enemy frame animation audit.

## Files Modified This Session
- `src/feature/save_system.gd` — Story005 async save write path：默认异步、
  pending/dispatch 诊断、单写入锁、`on_save_write_failed`、主线程 completion
  poll、Web/deferred fallback、退出期 flush 与同步 fallback。
- `src/gameplay/main_scene.gd` — 手动存档 UI 改为等待 SaveSystem 完成/失败信号；
  pending 期间第二次保存请求保持原 slot authoritative，不覆盖 pending。
- `tests/unit/save/story_005_async_write_performance_budget_test.gd` —
  TDD 覆盖异步 dispatch budget、single-write lock、backup preservation、
  sync fallback 和 async failure cleanup。
- `tests/unit/gameplay/main_scene_save_load_menu_runtime_test.gd` —
  TDD 覆盖异步完成前 `Saving...`、完成后槽位刷新、pending 重入 guard、
  失败反馈。
- `tests/unit/save/story_001_save_slots_backup_json_pipeline_test.gd`,
  `tests/unit/save/story_002_version_migration_save_info_metadata_test.gd`,
  `tests/unit/save/story_003_autosave_trigger_adapter_test.gd`,
  `tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd` —
  旧 SaveSystem 故事测试显式使用 sync fallback，保持即时文件断言稳定。
- `production/epics/save-system/story-005-async-write-performance-budget.md`,
  `production/epics/save-system/EPIC.md`, `production/epics/index.md`,
  `production/qa/evidence/async-write-performance-budget-2026-06-25.md`,
  `production/session-state/active.md` — Story005 状态、Epic/index 完成状态、
  QA/MCP 证据和下一步状态追踪。
- `reports/save_story005_async_write_smoke.log`, `reports/report_384/`,
  `reports/report_386/`, `reports/report_388/`, `reports/report_392/`,
  `reports/report_393/`, `reports/report_394/` — Story005 RED/GREEN、
  regression 和 headless smoke evidence。
- `production/epics/combat-presentation/story-013-weapon-style-vfx-variants.md`,
  `production/qa/evidence/weapon-style-vfx-variants-2026-06-24.md`,
  `design/assets/asset-manifest.md`, `production/epics/combat-presentation/EPIC.md`,
  `production/epics/index.md`, `production/session-state/active.md` — Story013
  生产文档、最终 QA/MCP 证据、image generation 素材来源/导入位置、Epic 完成状态和
  下一步状态追踪。
- `src/presentation/combat_presentation.gd` — Story013 weapon-style textured VFX：
  long-tail `trail_blade`、fish-bone `wave_bone`、electro-bell `arc_bell`，
  `get_weapon_vfx_snapshot()` 调试接口，以及 Story012 粒子 cap 集成。
- `tests/unit/presentation/combat_presentation_test.gd`,
  `tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd` — Story013
  TDD 覆盖三武器 VFX 数量、颜色、贴图、生命周期、粒子 cap 参与和 MainScene
  attack-start 转发。
- `assets/generated/combat_long_tail_arc_runtime.png`,
  `assets/generated/combat_fish_bone_wave_runtime.png`,
  `assets/generated/combat_electro_bell_arc_runtime.png`,
  `assets/generated/source/combat_long_tail_arc_imagegen_20260624.png`,
  `assets/generated/source/combat_fish_bone_wave_imagegen_20260624.png`,
  `assets/generated/source/combat_electro_bell_arc_imagegen_20260624.png` —
  Story013 image-generated 源图与 Godot runtime PNG。
- `reports/combat_weapon_vfx_main_scene_smoke.log`,
  `reports/visual/cinderpaw-mcp-long-tail-vfx-20260624.png`,
  `reports/visual/cinderpaw-mcp-fish-bone-vfx-20260624.png`,
  `reports/visual/cinderpaw-mcp-electro-bell-vfx-20260624.png` — Story013
  headless smoke 与 MCP runtime screenshot evidence。
- `production/epics/combat-presentation/story-012-particle-budget-performance-guardrails.md`,
  `production/epics/combat-presentation/EPIC.md`,
  `production/qa/evidence/particle-budget-performance-guardrails-2026-06-24.md` —
  Story/Epic 状态、TR003 cap 部分覆盖、TR007 预算证据和 QA/MCP 证据。
- `reports/combat_presentation_tr003_007_main_scene_smoke.log`,
  `reports/visual/cinderpaw-mcp-combatfx-particle-budget-20260624.png` —
  Story012 headless smoke 与 MCP runtime screenshot evidence。
- `src/presentation/combat_presentation.gd` — Story011 colorblind particle
  palette remap、focus-mode screen shake `0.7` scaling、diagnostic color/shake
  getters。
- `src/presentation/hud_manager.gd`, `src/gameplay/main_scene.gd` — Story011
  HUD colorblind signal、MainScene palette resync、Health focus signal routing。
- `tests/unit/presentation/combat_presentation_test.gd`,
  `tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd` — Story011 TDD
  覆盖 palette、invalid fallback、focus shake、HUD/MainScene integration。
- `production/epics/combat-presentation/story-011-colorblind-focus-accessibility.md`,
  `production/epics/combat-presentation/EPIC.md`,
  `production/qa/evidence/colorblind-focus-accessibility-2026-06-24.md` —
  Story/Epic 状态、palette 固定与 QA/MCP 证据。
- `reports/visual/cinderpaw-mcp-combatfx-default-hit-20260624.png`,
  `reports/visual/cinderpaw-mcp-combatfx-red-green-20260624.png`,
  `reports/visual/cinderpaw-mcp-combatfx-blue-yellow-20260624.png`,
  `reports/visual/cinderpaw-mcp-combatfx-focus-hit-20260624.png` — Story011
  MCP runtime screenshot evidence。
- `AGENTS.md` — 补强并行 Agent 早期只读审查/验收规划要求，以及玩家可见
  gameplay state 默认至少 3 帧的 Godot 2D 帧动画规则。
- `src/presentation/combat_presentation.gd` — Story010 Boss phase visual
  feedback，新增 phase API/getters、textured overlay、32 个 metal debris、
  1.5s 生命周期和 metadata 记录。
- `src/gameplay/main_scene.gd` — Story010 BossConfig-style transition source
  registration、signal disconnect 和 phase metadata/HUD 转发。
- `tests/unit/presentation/combat_presentation_test.gd`,
  `tests/unit/gameplay/main_scene_visual_contract_test.gd` — Story010 TDD 覆盖
  overlay/debris/hitstop/shake/lifetime、MainScene registration，以及角色动画
  至少 3 帧 contract。
- `assets/generated/combat_boss_phase_overlay.png`,
  `assets/generated/combat_boss_phase_overlay_alpha_raw.png`,
  `assets/generated/source/combat_boss_phase_overlay_imagegen_20260624.png` —
  image-generated Boss phase overlay 源图、alpha audit 和 Godot runtime PNG。
- `design/assets/asset-manifest.md`,
  `production/epics/combat-presentation/story-010-boss-phase-visual-feedback.md`,
  `production/epics/combat-presentation/EPIC.md`,
  `production/qa/evidence/boss-phase-visual-feedback-2026-06-24.md` —
  Story/Epic 状态、资产 manifest 和 QA/MCP 证据。
- `src/presentation/hud_manager.gd` — Story005 main menu/save-load shell、
  typed menu signals、slot label formatting、disabled reasons、focus fallback
  与内容驱动 menu sizing
- `src/gameplay/main_scene.gd` — Story005 HUD signal adapter，收集
  SaveSystem `SaveInfo` 风格槽位元数据，接入 runtime save/load，并在回主菜单
  时释放 pause state
- `tests/unit/presentation/hud_manager_test.gd`,
  `tests/unit/gameplay/main_scene_save_load_menu_runtime_test.gd` — Story005
  TDD 覆盖主菜单入口、save/load shell、禁用原因、slot signal 与 pause
  release/focus
- `production/epics/hud-ui/story-005-main-save-load-menu-shell.md`,
  `production/epics/hud-ui/EPIC.md`, `production/epics/index.md`,
  `production/qa/evidence/main-save-load-menu-shell-2026-06-24.md` —
  Story/Epic 状态、索引和 QA/MCP 证据
- `reports/hud_story005_main_scene_smoke.log` — Story005 headless main-scene
  smoke 日志
- `src/gameplay/main_scene.gd` — Story004 MainScene SaveSystem runtime
  handoff，新增 SaveSystem 注入、`main_scene` serializable 注册、
  JSON-safe save snapshot、manual save/load runtime APIs、player/world/settings
  restore，以及 boss defeat autosave adapter 接线
- `tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd` —
  TDD 覆盖手动 slot 1 save、MainScene snapshot、load runtime restore、
  boss defeat slot 0 autosave 与 `autosave_reason`/context metadata
- `production/epics/save-system/story-004-main-scene-save-system-runtime-handoff.md`,
  `production/epics/save-system/EPIC.md`,
  `production/qa/evidence/main-scene-save-system-runtime-handoff-2026-06-24.md` —
  Story004 状态、Epic 下一步与 QA/Godot MCP 证据
- `src/feature/save_trigger_adapter.gd` — Story003 autosave trigger adapter，
  支持 savepoint/boss/key-event/scene-change 信号绑定、直接 autosave trigger、
  snapshot provider、reason/context metadata 和成功/失败信号
- `tests/unit/save/story_003_autosave_trigger_adapter_test.gd` — TDD 覆盖
  savepoint slot 0 写入、boss/key/scene 共用 autosave path、失败降级与
  mock-only 解耦验证
- `production/epics/save-system/story-003-autosave-trigger-adapters.md`,
  `production/epics/save-system/EPIC.md`,
  `production/epics/index.md`,
  `production/qa/evidence/autosave-trigger-adapters-2026-06-24.md` —
  Story003 状态、Epic/索引追踪与 QA/MCP 证据
- `src/feature/save_info.gd` — `SaveInfo` 元数据对象，提供 slot、autosave、
  exists、timestamp、play time、save point、version、summary、file size 与
  JSON-safe `to_dictionary()`
- `src/feature/save_system.gd` — Story002 version migration pipeline、
  SaveInfo metadata read API、summary builder、migration registration and
  current-version write-back
- `tests/unit/save/story_002_version_migration_save_info_metadata_test.gd` —
  TDD 覆盖空/已保存槽位元数据、旧版本迁移、迁移写回、缺失迁移和未来版本失败
- `production/epics/save-system/story-002-version-migration-save-info-metadata.md`,
  `production/epics/save-system/EPIC.md`,
  `production/qa/evidence/version-migration-save-info-metadata-2026-06-24.md` —
  Story 状态、Epic 下一步与 QA/MCP 证据
- `src/feature/save_system.gd` — SaveSystem Autoload/testable Node，提供
  autosave/manual save/load、slot validation、registered system order、
  JSON read/write、backup fallback 和 runtime state inspection API
- `tests/unit/save/story_001_save_slots_backup_json_pipeline_test.gd` —
  SaveSystem Story 001 TDD 覆盖 autosave/manual slots、payload shape、
  deterministic system order、duplicate key rejection 和 corrupt-main backup
  fallback
- `project.godot` — 注册 `SaveSystem` Autoload
- `production/epics/save-system/EPIC.md`,
  `production/epics/save-system/story-001-save-slots-backup-json-pipeline.md`,
  `production/epics/index.md`,
  `production/qa/evidence/save-slots-backup-json-pipeline-2026-06-24.md` —
  新增 Save System Epic、Story 状态和 QA 证据
- `AGENTS.md` — 并行 Codex subagent 分工边界，以及 Godot 2D frame animation
  与 MCP runtime validation 验收规则
- `src/presentation/hud_manager.gd` — Story 006 HUD scale runtime relayout、
  menu overlap diagnostics、colorblind HP palettes、Boss Phase text marker、
  JSON-safe settings state capture/restore
- `src/gameplay/main_scene.gd` — no-loss runtime state handoff now includes
  HUD accessibility settings
- `tests/unit/presentation/hud_manager_test.gd`,
  `tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd` — Story 006
  TDD and runtime handoff coverage
- `production/epics/hud-ui/story-006-hud-scale-colorblind-mode.md`,
  `production/epics/hud-ui/EPIC.md`,
  `production/qa/evidence/hud-scale-colorblind-mode-2026-06-24.md`,
  `reports/visual/cinderpaw-mcp-hud-story006-*.png` — Story state, Epic
  tracking, QA evidence, and MCP screenshot artifacts
- `src/gameplay/player_controller.gd` — `jump`/`fall` 动画常量与空中
  locomotion 映射，保持 hurt/death/revive、attack、dodge 优先级
- `assets/characters/cinderpaw/jump/`,
  `assets/characters/cinderpaw/fall/`,
  `assets/characters/cinderpaw/source/`,
  `assets/characters/cinderpaw/cinderpaw_sprite_frames.tres` —
  image-generated jump/fall 源图、alpha 源图、96x96 透明帧与 SpriteFrames
  导入
- `tests/unit/gameplay/player_air_animation_test.gd` — Story 006 TDD 覆盖
  资源路径、帧数/尺寸、起跳/下落触发和高优先级动画不被覆盖
- `production/epics/combat-presentation/story-006-cinderpaw-jump-fall-animation.md`,
  `production/epics/combat-presentation/EPIC.md`,
  `production/qa/evidence/cinderpaw-jump-fall-animation-2026-06-24.md`,
  `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md` —
  Story 状态、Epic 追踪、资产 manifest、实体清单与 QA 证据
- `src/presentation/hud_manager.gd` — Settings 菜单、设置分组、运行时开关、
  HUD scale、colorblind HP palette、settings focus return
- `src/presentation/combat_presentation.gd` — `show_damage_number=false`
  gate，只关闭数字，不关闭 hitstop/spark/shake
- `src/gameplay/main_scene.gd` — battle summary 与 damage number 设置接入
  death route 和 player/enemy hit presentation metadata
- `tests/unit/presentation/hud_manager_test.gd`,
  `tests/unit/presentation/combat_presentation_test.gd`,
  `tests/unit/gameplay/main_scene_hud_settings_runtime_test.gd` — Story 004
  TDD 与运行时接线覆盖
- `production/epics/hud-ui/story-004-settings-accessibility-controls.md`,
  `production/epics/hud-ui/EPIC.md`,
  `production/qa/evidence/settings-accessibility-controls-2026-06-24.md` —
  Story 状态、Epic 下一步与 QA 证据
- `src/gameplay/simple_enemy.gd`, `src/gameplay/simple_enemy.tscn` — Shadow Beast 帧动画与敌人攻击状态机/Core hitbox
- `src/gameplay/player_controller.gd`, `src/gameplay/main_scene.gd`, `src/core/combat_component.gd` — 敌人命中玩家的 Core 伤害链与表现转发
- `assets/characters/shadow_beast/`, `scenes/characters/shadow_beast.tscn`, `src/characters/shadow_beast.gd` — image-generated Shadow Beast 角色资源管线
- `tests/unit/gameplay/simple_enemy_character_animation_test.gd`, `tests/unit/gameplay/main_scene_enemy_attack_core_chain_test.gd` — Story 009 TDD 覆盖
- `production/epics/feline-combat/story-009-runtime-enemy-attack-animation.md`, `production/qa/evidence/runtime-enemy-attack-shadow-beast-animation-2026-06-24.md` — Story 与 QA 证据
- `design/gdd/health-death.md` — Retrofit完成：Status→Designed(Retrofit 2026-06-20), 10条规则(+2), 3公式(+HD前缀+变量表), 10 Edge Cases(+4), 14 AC(+5), 10 Tuning Knobs(+3)
- `design/gdd/hud-ui.md` — 规则4低HP脉动→不脉动, 心跳音→不添加
- `design/gdd/ai-framework.md` — 新增on_focus_mode_changed监听 + set_global_windup_modifier接口

## Previous Session (preserved)
- Design Review #4 of damage-calculation.md → NEEDS REVISION → Revised → Approved
- Consistency check: found 1 conflict + 1 stale reference, both fixed

## Next Steps
1. SceneManager integration — 标准化 title/continue/load scene handoff 与
   runtime state restore 边界。
2. Visual/animation polish — 按 AGENTS Godot 2D 帧动画规则审计玩家可见
   方块/单帧占位，优先用 image generation 生成透明帧并接入
   `AnimatedSprite2D + SpriteFrames`。
3. Gameplay runtime gap — advanced combat input wiring and Rat King runtime boss encounter。

## Key Decisions Made (this session)
- HP恢复：存档点回满+道具回复，无被动回复（维持紧张感）
- i-frames：闪避12帧、弹反8帧、复活120帧
- 低HP专注模式：不脉动+不心跳音（CD-approved设计统一）
- 专注模式AI耦合：windup_modifier=0.9，仅影响动画播放速度
- on_hp_milestone阈值：75%/50%/25%/1%

## Open Warnings (non-blocking, carried from previous session)
- charm-equipment.md: charm_crit需改为"+N帧暴击窗口"
- feline-combat.md: attack_type_multiplier占位值需垂直切片细化
- 100ms PERFECT弹反窗口在移动端可行性（Playtest验证）
- skill-tree.md 仍在 In Review (Rev.5)
- skill_weapon_bonus_cap not in Tuning Knobs
- charm-equipment.md F4 formula still additive

<!-- RETROFIT: 2026-06-20 | health-death.md | 8 fixes applied | downstream sync: hud-ui.md, ai-framework.md -->
<!-- CONSISTENCY-CHECK: 2026-06-20 | GDDs checked: 22 | Conflicts found: 1 | Report: docs/consistency-failures.md -->
<!-- CONSISTENCY-CHECK: 2026-06-21 | GDDs checked: 6 | Conflicts found: 4 | Report: docs/consistency-failures.md -->

## Session Extract — /review-all-gdds 2026-06-22
- Verdict: FAIL → PASS (所有10个阻塞问题已修复)
- Review agents: Phase 2 (game-designer) + Phase 3 (creative-director)
- GDDs reviewed: 22 system GDDs
- Blocking issues found: 10 (3 consistency + 7 design theory)
- Blocking issues fixed: 10/10
  - B1: entities.yaml常量 (已修复-之前session)
  - B2: audio-system focus_mode (已修复-之前session)
  - B3: 20+处单向依赖 (修复8个GDD文件的依赖声明)
  - D1: 闪避滥用 (feline-combat.md添加设计说明)
  - D2: 技能树MVP不可玩 (skill-tree.md更新MVP SP来源5→22点)
  - D3: 线性能力路径 (player-abilities.md添加探索能力路径)
  - D4: Boss阶段转换矛盾 (boss-config.md统一规则)
  - D5: 电磁脉冲对Boss无效 (weapon-styles.md添加Boss专属效果)
  - D6: 武器差距5× (damage-calculation.md添加设计说明)
  - D7: 猫爪闪避后窗口无实现 (feline-combat.md添加实现机制)
- Warnings remaining: 11 (未修复，建议后续处理)
- Report: design/gdd/gdd-cross-review-2026-06-22.md
- Systems index: 11 GDDs updated from "Needs Revision" to "Approved"
- Files modified: feline-combat.md, damage-calculation.md, health-death.md, boss-config.md, scene-management.md, player-abilities.md, hud-ui.md, exploration-ability-gating.md, weapon-styles.md, skill-tree.md, systems-index.md, gdd-cross-review-2026-06-22.md

## Session Extract — /review-all-gdds 2026-06-21
- Verdict: FAIL → 4 Blocking 已全部修复 → 降级为 CONCERNS
- GDDs reviewed: 22 system GDDs + game-concept + systems-index = 24
- Flagged for revision: boss-config, weapon-styles, charm-equipment, feline-combat, damage-calculation, health-death, hud-ui, input, exploration-ability-gating, map-system, player-abilities
- Blocking issues: 4 — ALL FIXED (B-1 Boss弹反5.0×统一, B-2 疾风连爪80%统一, B-3 charm_crit改为窗口+1帧, B-4 专注模式暴击窗口+1帧)
- Warnings fixed: 7 — W-1 skill-tree依赖, W-2 active_enemies_count归属AI框架, W-3 weapon-styles猫气声明, W-4 完成度公式所有权, W-5 dodge_cooldown所有权, W-6 HP汇总公式, W-7 Space键映射
- Warnings remaining: 0 (all warnings addressed in this session)
- Design issues remaining: D-1 齿轮币Sink(需商店GDD), D-2 弹反支配(playtest验证), D-3 认知负荷(设计监控), D-4 专注进攻回报(已通过B-4部分缓解)
- Report: design/gdd/gdd-cross-review-2026-06-21.md
- Systems index: 11 GDDs updated to "Needs Revision"
- Files modified: boss-config.md, weapon-styles.md, charm-equipment.md, feline-combat.md, damage-calculation.md, health-death.md, hud-ui.md, input.md, skill-tree.md, map-system.md, player-abilities.md, ai-framework.md, systems-index.md, gdd-cross-review-2026-06-21.md, active.md

## Session Extract — /architecture-review 2026-06-21
- Verdict: CONCERNS
- Requirements: 185 total — 65 covered, 43 partial, 77 gaps
- New TR-IDs registered: 185 (all new — tr-registry.yaml was empty)
- GDD revision flags: None
- Top ADR gaps: 状态效果系统, 玩家能力系统, 战斗表现系统
- Report: docs/architecture/architecture-review-2026-06-21.md

## Session Extract — /architecture-review Round 3 (2026-06-22)
- Verdict: CONCERNS → 改善中（P0 ADR完成）
- Coverage: 83/185 TRs covered (44.9%) — improved from 28.1% in Round 2
- New P0 ADRs added: 3 (0019 health-component, 0020 collision-api, 0021 save-system)
- Coverage improvement: +31 TRs covered, -31 gaps
- **Core layer coverage: 76.2% ✅ (exceeded 70% gate-check threshold!)**
- Foundation layer coverage: 55.0% (needs 15% more to reach 70%)
- Feature layer coverage: 23.2%
- Presentation layer coverage: 0%
- Remaining gaps: 102 TRs (input:12, data:6, boss:7, combat:8, scene:8, skill:12, charm:6, respawn:7, explore:5, npc:5, hud:8, audio:9, combatfx:9)
- Next: Write input-system ADR (12 TRs) to push Foundation to 85%, then gate-check
- Report: docs/architecture/architecture-review-2026-06-22-round3.md (pending)

## Session Extract — /architecture-review Round 2 (2026-06-22)
- Verdict: CONCERNS → **所有冲突已修复**
- Coverage: 52/185 TRs covered (28.1%) — improved from 17.8% in Round 1
- New ADRs added: 3 (0016 weapon-styles, 0017 status-effects, 0018 player-abilities)
- Coverage improvement: +19 TRs covered, -19 gaps
- Core layer coverage: 52.4% (exceeded 50% target)
- **Conflicts fixed: 6/6 (3 critical + 3 medium)**
  - Critical #1: DamageCalculator接口签名 → ADR-0016添加Extends声明，ADR-0005更新接口
  - Critical #2: 状态效果施加路径 → ADR-0016改为使用StatusEffectComponent.apply_status()
  - Critical #3: CHARGING状态矛盾 → ADR-0016明确鱼骨大剑两阶段流程
  - Medium #4: get_stat_bonus()缺失 → ADR-0009已定义（第67行）
  - Medium #5: register_serializable()签名 → ADR-0018改为2参数版本
  - Medium #6: 场景注册表扩展 → ADR-0007添加requires_ability和accessible字段
- Top gaps: health (11 TRs), input (10 TRs), damage (8 TRs), combat (6 TRs)
- Next: Write P0 ADRs (health, collision, save)
- Report: docs/architecture/architecture-review-2026-06-22-round2.md
- Files modified: adr-0016.md, adr-0017.md, adr-0018.md, adr-0005.md, adr-0007.md, architecture-review-2026-06-22-round2.md

## Session Extract — /gate-check pre-production 2026-06-21
- Verdict: FAIL (2 blockers — now resolved by /architecture-review)
- Director panel: CD=READY, TD=READY, PR=CONCERNS, AD=READY
- Key findings: Architecture traceability + review report were missing (now created)
- AD found: 「钢青灰」色值不一致 Art Bible(#6B8A9E) vs Game Concept(#4A5568)
- QQ-02 (NavigationAgent2D) closed in architecture.md
- Next: Re-run /gate-check pre-production to advance stage

## Session Extract — /dev-story 2026-06-21
- Story: production/epics/data-manager/story-001-manifest-loader.md — ManifestLoader + 4 状态机 + 重试
- Files changed: src/foundation/data_manager.gd, tests/unit/data/story_001_manifest_test.gd, data/manifest.json, data/combat/damage_params.json, data/schemas/.gitkeep
- Test written: tests/unit/data/story_001_manifest_test.gd (6 test functions, 5 AC + 1 supplementary)
- Blockers: None
- Next: /code-review src/foundation/data_manager.gd tests/unit/data/story_001_manifest_test.gd then /story-done production/epics/data-manager/story-001-manifest-loader.md

## Session Extract — /story-done 2026-06-21
- Verdict: COMPLETE WITH NOTES
- Story: production/epics/data-manager/story-001-manifest-loader.md — ManifestLoader + 4 状态机 + 重试
- Tech debt logged: None (advisory only — preload domain failure graceful degradation)
- Next recommended: Story 002 (SchemaValidator) — production/epics/data-manager/story-002-schema-validator.md

## Session Extract — /story-done 2026-06-21 (story-002)
- Verdict: COMPLETE
- Story: production/epics/data-manager/story-002-schema-validator.md — SchemaValidator + 三级失败处理
- Tech debt logged: None
- Next recommended: Story 003 (DomainCache) — production/epics/data-manager/story-003-domain-cache.md

## Session Extract — /architecture-review 2026-06-22 (Round 2)
- Verdict: CONCERNS → 改善（所有阻塞性冲突已修复）
- ADR冲突修复: 5/5 完成
  - ADR-0001: 更新ISerializable接口签名（加version参数）
  - ADR-0009: CombatSystem→CombatComponent命名修正 + SkillTreeManager改为场景级组件
  - ADR-0012: 删除重复碰撞层定义，改为引用ADR-0004
- Remaining concerns: 3个Core层ADR待编写（weapon-styles, status-effects, player-abilities）
- Files modified: adr-0001.md, adr-0009.md, adr-0012.md, architecture-review-2026-06-22.md
- Next: 编写剩余3个Core层ADR（weapon-styles, status-effects, player-abilities）

## Session Extract — Story 003 Implementation 2026-06-22
- Story: production/epics/data-manager/story-003-domain-cache.md — DomainCache + 懒加载 + 查询接口
- Status: Done (implementation + test file created)
- Files changed: src/foundation/data_manager.gd, tests/unit/data/story_003_domain_cache_test.gd
- Implementation: get_entry() 懒加载、has_domain()、has_entry()、load_input_config() 完整实现
- Tests: 15 test functions covering AC-01~AC-05 + supplementary
- Note: GdUnit4 addon not installed — tests cannot run. Code review verified correctness.
- Next: /code-review src/foundation/data_manager.gd tests/unit/data/story_003_domain_cache_test.gd then /story-done production/epics/data-manager/story-003-domain-cache.md

## Session Extract — /dev-story 2026-06-23
- Story: production/epics/data-manager/story-004-hot-reloader.md — HotReloader 热重载机制
- Authorization: AGENTS.md updated with standing approval for local project writes, including destructive local filesystem writes needed for active tasks.
- Files changed: AGENTS.md, src/foundation/data_manager.gd, tests/unit/data/story_004_hot_reloader_test.gd, tests/unit/data/story_003_domain_cache_test.gd, production/epics/data-manager/story-004-hot-reloader.md, production/epics/data-manager/story-003-domain-cache.md, production/epics/data-manager/EPIC.md
- Implementation: Debug-only 1.0s Timer polling, file modified-time tracking, validation-before-cache-replace, atomic multi-domain reload, on_domain_changed signal, deleted-domain fallback, get_domain() ADR regression.
- Tests: tests/unit/data/story_004_hot_reloader_test.gd (6 functions covering AC-01~AC-06) plus Story 003 get_domain regression.
- Blockers: None
- Next: /code-review src/foundation/data_manager.gd tests/unit/data/story_004_hot_reloader_test.gd tests/unit/data/story_003_domain_cache_test.gd then /story-done production/epics/data-manager/story-004-hot-reloader.md

## Session Extract — /code-review + /story-done 2026-06-23
- Verdict: COMPLETE
- Story: production/epics/data-manager/story-004-hot-reloader.md — HotReloader 热重载机制
- Review: Local code review passed against ADR-0003, control manifest, GDD TR-data-003, and data-unit test evidence. No blocking deviations found. Full specialist subagent gates were not spawned because the active tool policy requires an explicit user request for subagents.
- Fixes during review: AC-01 test now exercises `_poll_hot_reload()` rather than only manual `reload_domain()`; `_read_domain_entries()` refactored to keep DataManager methods within review-size expectations.
- Tests: Story 004 6/6 passing; full `tests/unit/data` 31/31 passing; `godot --headless --path . --quit` passing; `git diff --check` passing.
- Tech debt logged: None
- Next recommended: Story 005 TuningKnobRegistry — production/epics/data-manager/story-005-tuning-knob.md

## Session Extract — /dev-story 2026-06-23 (story-005)
- Story: production/epics/data-manager/story-005-tuning-knob.md — TuningKnobRegistry 旋钮管理
- Authorization: Standing approval applies for local project writes, including destructive local filesystem changes needed for the active goal.
- Files changed: src/foundation/data_manager.gd, src/foundation/tuning_knob_entry.gd, tests/unit/data/story_005_tuning_knob_test.gd, data/manifest.json, data/tuning_knobs.json, data/schemas/tuning_knobs.schema.json, production/epics/data-manager/story-005-tuning-knob.md, production/epics/data-manager/EPIC.md
- Implementation: TuningKnobEntry model, register/get/set tuning API, numeric clamp, on_knob_changed signal, debug override > JSON > registered default priority, tuning_knobs domain hot-reload integration.
- TDD evidence: Red first failed on missing `DataManager.register_tuning()`; green Story 005 suite 6/6 passing.
- Regression evidence: full `tests/unit/data` 37/37 passing; `godot --headless --path . --quit` passing; `git diff --check` passing.
- Blockers: None
- Next: /code-review src/foundation/data_manager.gd src/foundation/tuning_knob_entry.gd tests/unit/data/story_005_tuning_knob_test.gd production/epics/data-manager/story-005-tuning-knob.md, then /story-done production/epics/data-manager/story-005-tuning-knob.md

## Session Extract — /story-done 2026-06-23 (story-005)
- Verdict: COMPLETE
- Story: production/epics/data-manager/story-005-tuning-knob.md — TuningKnobRegistry 旋钮管理
- Review: Local code review passed against ADR-0003, control manifest, GDD TR-data-005, and data-unit test evidence. No blocking deviations found. Full specialist subagent gates were not spawned because the active tool policy requires an explicit user request for subagents.
- Tests: Story 005 6/6 passing; full `tests/unit/data` 37/37 passing; `godot --headless --path . --quit` passing; `git diff --check` passing.
- Tech debt logged: None
- Next recommended: Story 006 VersionMigrator — production/epics/data-manager/story-006-version-migrator.md

## Session Extract — /dev-story 2026-06-23 (story-006)
- Story: production/epics/data-manager/story-006-version-migrator.md — VersionMigrator 版本迁移
- Files changed: src/foundation/data_manager.gd, tests/unit/data/story_006_version_migrator_test.gd, production/epics/data-manager/story-006-version-migrator.md, production/epics/data-manager/EPIC.md
- Implementation: DataManager VersionMigrator API with register_migration(), check_and_migrate(), get_version_flags(), MAJOR.MINOR compatibility formula, chained minor migrations, major mismatch rejection, rollback-on-step-failure, and domain-load pipeline integration.
- TDD evidence: Red first failed on missing `DataManager.check_and_migrate()`; green Story 006 suite 6/6 passing.
- Regression evidence: full `tests/unit/data` 43/43 passing; `godot --headless --path . --quit` passing; `git diff --check` passing.
- Blockers: None
- Next: /code-review src/foundation/data_manager.gd tests/unit/data/story_006_version_migrator_test.gd production/epics/data-manager/story-006-version-migrator.md, then /story-done production/epics/data-manager/story-006-version-migrator.md

## Session Extract — /story-done 2026-06-23 (story-006)
- Verdict: COMPLETE
- Story: production/epics/data-manager/story-006-version-migrator.md — VersionMigrator 版本迁移
- Review: Local code review passed against ADR-0003, control manifest, GDD TR-data-006, and data-unit test evidence. No blocking deviations found. Full specialist subagent gates were not spawned because the active tool policy requires an explicit user request for subagents.
- Tests: Story 006 6/6 passing; full `tests/unit/data` 43/43 passing; `godot --headless --path . --quit` passing; `git diff --check` passing.
- Tech debt logged: None
- Next recommended: Story 003 story-done close-out — production/epics/data-manager/story-003-domain-cache.md

## Session Extract — /story-done 2026-06-23 (story-003)
- Verdict: COMPLETE
- Story: production/epics/data-manager/story-003-domain-cache.md — DomainCache + 核心查询接口 + 懒加载
- Review: Local code review passed against ADR-0003, ADR-0001, control manifest, GDD TR-data-002/TR-data-007, and data-unit test evidence. No blocking deviations found. Full specialist subagent gates were not spawned because the active tool policy requires an explicit user request for subagents.
- Tests: Story 003 7/7 passing; full `tests/unit/data` 43/43 passing; `godot --headless --path . --quit` passing; `git diff --check` passing.

## Session Extract — Combat Presentation Textured VFX 2026-06-24
- Story: production/epics/combat-presentation/story-001-textured-hit-spark-enemy-debris.md — Textured Hit Spark + Enemy Debris Slice
- Status: Complete (implementation + tests + Godot MCP runtime evidence)
- Files changed: src/presentation/combat_presentation.gd, tests/unit/presentation/combat_presentation_test.gd, assets/generated/combat_hit_spark.png, assets/generated/combat_enemy_debris.png, design/assets/asset-manifest.md, combat-presentation epic/story/evidence docs
- Implementation: image-generated hit spark and enemy debris transparent PNGs imported through Godot; CombatPresentation now spawns textured Sprite2D VFX for hit sparks and kill debris instead of ColorRect blocks.
- TDD evidence: RED failed on missing textured Sprite2D VFX and existing ColorRect spark blocks; GREEN focused presentation suite 6/6 passing.
- Runtime evidence: Godot MCP `cinderpaw@c4d7` launched main.tscn, game_eval reported 30 textured Sprite2D VFX and 0 ColorRect VFX; screenshot saved at reports/visual/cinderpaw-mcp-textured-combat-vfx-20260624.png.
- Next: implement parry flash and claw slash trail VFX from combat-presentation GDD.
- Tech debt logged: None

## Session Extract — Weapon Story 004 2026-06-24
- Story: production/epics/weapon-styles/story-004-special-attack-cooldown-cat-energy-gate.md — Special Attack Cooldown + Cat Energy Gate
- Status: Complete
- Files changed: src/core/weapon_component.gd, tests/unit/weapon/story_004_special_attack_gates_test.gd, production/epics/weapon-styles/story-004-special-attack-cooldown-cat-energy-gate.md, production/epics/weapon-styles/EPIC.md, production/qa/evidence/special-attack-gates-2026-06-24.md, README.md
- Implementation: WeaponComponent exposes special attack params, gates active-weapon specials through CombatComponent cat energy/cooldown, emits insufficient-energy/cooldown/start signals, and leaves combat resources owned by CombatComponent.
- TDD evidence: Story 004 RED failed on missing special attack API/signals; GREEN Story 004 suite 4/4 passing; focused weapon/combat/gameplay regression 28/28 passing.
- Runtime evidence: `godot --headless --path . --quit-after 1` passes; Godot MCP session `cinderpaw@c4d7` runs `res://scenes/main.tscn`, screenshots runtime, and verifies insufficient -> success -> cooldown special gate sequence for `gale_claw`.
- Next recommended: Weapon Story 005 — production/epics/weapon-styles/story-005-cat-claw-dodge-counter-crit-bonus.md
- Tech debt logged: None

## Session Extract — Weapon Story 005 2026-06-24
- Story: production/epics/weapon-styles/story-005-cat-claw-dodge-counter-crit-bonus.md — Cat Claw Dodge-Counter Crit Bonus
- Status: Complete
- Files changed: src/core/combat_component.gd, src/core/weapon_component.gd, src/foundation/damage_calculator.gd, tests/unit/weapon/story_005_cat_claw_counter_crit_test.gd, production/epics/weapon-styles/story-005-cat-claw-dodge-counter-crit-bonus.md, production/epics/weapon-styles/EPIC.md, production/qa/evidence/cat-claw-counter-crit-2026-06-24.md
- Implementation: WeaponComponent syncs current weapon id into CombatComponent; CombatComponent opens and consumes the cat-claw dodge-counter window, injects one-shot +3 crit-window metadata, and DamageCalculator recognizes the claw counter modifier.
- TDD evidence: Story 005 RED failed on missing +3 modifier/consumption; GREEN Story 005 suite 4/4 passing; focused weapon/combat/damage/gameplay regression 37/37 passing.
- Runtime evidence: `godot --headless --path . --quit-after 1` passes; Godot MCP session `cinderpaw@c4d7` runs `res://scenes/main.tscn`, verifies Cat Claw +3 counter bonus and Long Tail no-bonus path, and saves runtime screenshot.
- Note: main scene still uses prototype PlayerController direct attack damage; full Core Combat wiring for actual player attacks remains future gameplay integration.
- Next recommended: Weapon Story 006 — production/epics/weapon-styles/story-006-long-tail-multi-target-range-contract.md

## Session Extract — /dev-story 2026-06-24 (weapon story-003)
- Story: production/epics/weapon-styles/story-003-weapon-swap-state-machine-combat-adapter.md — Weapon Swap State Machine + Combat Adapter
- Status: Complete
- Files changed: project.godot, src/gameplay/main_scene.gd, src/presentation/hud_manager.gd, tests/unit/gameplay/main_scene_weapon_swap_runtime_test.gd, production/epics/weapon-styles/story-003-weapon-swap-state-machine-combat-adapter.md, production/epics/weapon-styles/EPIC.md, production/qa/evidence/weapon-swap-runtime-2026-06-24.md, README.md
- Implementation: MainScene creates WeaponComponent, registers runtime `weapon_swap` input, exposes deterministic swap hooks, and syncs weapon changes to HUD plus no-loss progress state.
- Tests: runtime RED report_315; GREEN report_317; focused regression report_319 passed 10/10; `godot --headless --path . --quit-after 1` passed.
- MCP evidence: session `cinderpaw@c4d7` launched main scene; `game_eval` changed `cat_claw/猫爪` to `long_tail/长尾刃` after 0.5s; runtime screenshot saved under reports/visual.
- Next recommended: Weapon Story 004 — production/epics/weapon-styles/story-004-special-attack-cooldown-cat-energy-gate.md
- Next recommended: Data/Balance smoke-check — /smoke-check sprint

## Session Extract — /smoke-check 2026-06-23 (Data/Balance)
- Verdict: PASS WITH WARNINGS
- Report: production/qa/smoke-2026-06-23.md
- Automated tests: Effective GdUnit4 command passed for `res://tests/unit/data`: 43/43 passing, 0 errors, 0 failures, 0 skipped; report artifact `reports/report_36/results.xml`.
- Launch smoke: `godot --headless --path . --quit` exited 0; DataManager loaded manifest, `damage_params`, and `tuning_knobs`.
- Coverage: Data/Balance stories 001-006 all COVERED by unit test files. Story 001/002 stale Test Evidence statuses were corrected to match existing tests.
- Warnings: `tests/gdunit4_runner.gd` is deprecated and intentionally exits 1 when using the smoke-check skill default command; no QA plan found; interactive gameplay smoke checks (main menu, new game, input, movement/combat, save/load, performance) were not manually confirmed.
- Blockers: None for the Data/Balance slice.
- Next recommended: Generate a QA plan for broader manual verification, then pick the next implementation epic/story beyond Data/Balance.

## Session Extract — Runtime Player Attack Core Chain 2026-06-24
- Story: production/epics/feline-combat/story-008-runtime-player-attack-core-chain.md — Player attack runtime Core chain
- Status: Complete
- Files changed: src/core/collision_component.gd, src/gameplay/player_controller.gd, src/gameplay/simple_enemy.gd, src/gameplay/main_scene.gd, src/gameplay/runtime_damage_calculator_adapter.gd, tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd, production/epics/feline-combat/EPIC.md, production/qa/evidence/player-attack-core-chain-2026-06-24.md
- Implementation: PlayerController now creates/uses CombatComponent and CollisionComponent, MainScene injects WeaponComponent and RuntimeDamageCalculatorAdapter, SimpleEnemy exposes Health/Collision/Status adapters, and CollisionComponent extends Node2D so runtime hitboxes inherit entity transforms.
- TDD evidence: RED report_341 failed on missing runtime attack contract; GREEN report_342 2/2 passing.
- Regression evidence: focused gameplay/combat/collision/health/status/weapon regression report_343 passed 134/134.
- Runtime evidence: headless main scene smoke passed with clean log scan; Godot MCP launched main.tscn, verified Cat Claw HP 30→12 and Electro Bell slow status/movement modifier 0.7, captured reports/visual/cinderpaw-mcp-player-attack-core-chain-20260624.png, and game logs had no runtime errors.
- Next recommended: Enemy attack execution + combat presentation timing so live play has reciprocal combat pressure and clearer hit feedback.

## Session Extract — /create-stories 2026-06-23 (damage-calculator)
- Epic: production/epics/damage-calculator/EPIC.md — Damage Calculation
- Stories created: 4
  - story-001-formula-pipeline.md — FormulaPipeline + DamageResult 核心公式
  - story-002-crit-combo-parry.md — CritComboParry 倍率路径
  - story-003-special-modifiers.md — SpecialMoves + Skill/Window Modifiers
  - story-004-data-api-integration.md — DamageParams Data API Integration
- Index updated: production/epics/index.md damage-calculator row now lists 4 stories.
- Next: implement Story 001 first.

## Session Extract — /dev-story 2026-06-23 (damage story-001)
- Story: production/epics/damage-calculator/story-001-formula-pipeline.md — FormulaPipeline + DamageResult 核心公式
- Status: Done (implementation complete; pending code-review and story-done)
- Files changed: src/foundation/damage_result.gd, src/foundation/damage_calculator.gd, tests/unit/damage/story_001_formula_pipeline_test.gd, production/epics/damage-calculator/story-001-formula-pipeline.md, production/epics/damage-calculator/EPIC.md
- Implementation: Added typed DamageResult payload and stateless DamageCalculator helpers for DC-F1 base damage, DC-F3 reduction, DC-F4 floor/clamp/multiplier, baseline pipeline, and damage category classification.
- TDD evidence: Red first failed on missing DamageCalculator script; green Story 001 suite 6/6 passing.
- Regression evidence: combined `tests/unit/data` + `tests/unit/damage` 49/49 passing; `godot --headless --path . --quit` passing.
- Deviation: `calculate_basic_damage()` returns `RefCounted` instead of direct `DamageResult` type because headless GdUnit did not register newly added `class_name` types before parsing dependent scripts. Returned object is still from `damage_result.gd`.
- Blockers: None
- Next: /code-review src/foundation/damage_calculator.gd src/foundation/damage_result.gd tests/unit/damage/story_001_formula_pipeline_test.gd production/epics/damage-calculator/story-001-formula-pipeline.md, then /story-done production/epics/damage-calculator/story-001-formula-pipeline.md

## Session Extract — /dev-story 2026-06-23 (damage story-002)
- Story: production/epics/damage-calculator/story-002-crit-combo-parry.md — CritComboParry 倍率路径
- Status: Done (implementation complete; pending code-review and story-done)
- Files changed: src/foundation/damage_calculator.gd, tests/unit/damage/story_002_crit_combo_parry_test.gd, production/epics/damage-calculator/story-002-crit-combo-parry.md, production/epics/damage-calculator/EPIC.md
- Implementation: Added deterministic crit classification/multipliers, weapon combo multiplier table, parry half-open interval classification/multipliers, normal attack path, parry attack path, and DamageResult metadata population.
- TDD evidence: Red first failed on missing Story 002 static multiplier/API methods; green Story 002 suite 5/5 passing.
- Regression evidence: combined `tests/unit/data` + `tests/unit/damage` 54/54 passing; `godot --headless --path . --quit` passing.

## Session Extract — /create-epics + /create-stories 2026-06-23 (boss-config)
- Epic: production/epics/boss-config/EPIC.md — Boss Configuration
- Stories created: 5
  - story-001-boss-config-component-rat-king-data-domain.md — BossConfigComponent + Rat King Data Domain
  - story-002-phase-transition-adapter-invulnerability-window.md — Phase Transition Adapter + Invulnerability Window
  - story-003-phase-two-summon-scheduling-death-cleanup-hooks.md — Phase 2 Summon Scheduling + Death Cleanup Hooks
  - story-004-arena-change-adapter-scene-lock-hooks.md — Arena Change Adapter + Scene Lock Hooks
  - story-005-desperation-defense-defeat-reward-dispatch.md — Desperation Defense + Defeat Reward Dispatch
- Index updated: production/epics/index.md boss-config row now lists 5 stories.
- Next: implement Story 001 first.

## Session Extract — /story-done 2026-06-23 (boss story-001)
- Verdict: COMPLETE
- Story: production/epics/boss-config/story-001-boss-config-component-rat-king-data-domain.md — BossConfigComponent + Rat King Data Domain
- Files changed: src/core/boss_config_component.gd, tests/unit/boss/story_001_boss_config_component_test.gd, data/combat/boss_configs.json, data/schemas/boss_configs.schema.json, data/manifest.json, production/epics/boss-config/EPIC.md, production/epics/boss-config/story-001-boss-config-component-rat-king-data-domain.md
- Implementation: BossConfigComponent scene component with DataManager-compatible adapter loading, strict required-field validation, normalized phase queries, rewards, arena bounds, and safe empty fallback; Rat King `boss_configs` data domain and schema registered as lazy-loaded manifest domain.
- TDD evidence: RED first failed on missing `src/core/boss_config_component.gd` (`reports/report_215`); GREEN Story 001 suite 5/5 passing (`reports/report_219`).
- Regression evidence: full `tests/unit` 231/231 passing (`reports/report_220`); `git diff --check`, trailing whitespace scan, and method-length scan passed; `godot --headless --path . --quit` and main scene smoke both exited 0 with Godot AI MCP capture registration in logs.
- Tech debt logged: None
- Next recommended: Story 002 Phase Transition Adapter + Invulnerability Window — production/epics/boss-config/story-002-phase-transition-adapter-invulnerability-window.md

## Session Extract — /story-done 2026-06-23 (ai story-001)
- Verdict: COMPLETE
- Story: production/epics/ai-framework/story-001-ai-state-machine-active-enemy-count.md — AI State Machine + Active Enemy Count
- Files changed: src/core/ai_component.gd, tests/unit/ai/story_001_ai_state_machine_active_enemy_count_test.gd, production/epics/ai-framework/story-001-ai-state-machine-active-enemy-count.md, production/epics/ai-framework/EPIC.md
- Implementation: Added AIComponent as a Core scene component with six-state enum + match processing hooks, deterministic state transitions, active-enemy static count, duplicate-state signal suppression, and teardown cleanup.
- Tests: Story001 5/5 passing (`reports/report_184/`); AI suite 5/5 passing (`reports/report_185/`); full unit suite 202/202 passing (`reports/report_186/`).
- Runtime validation: `godot --headless --path . --quit` passed; `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 120 --log-file reports/ai_story001_main_scene_smoke.log` passed and logged Godot AI MCP capture registration.
- Review: Local review passed against ADR-0001, ADR-0002, ADR-0006, control manifest, TR-ai-001, and TR-ai-006. Full specialist subagent gates were not spawned because no explicit subagent delegation was requested in this turn.
- Warning carried forward: full unit run emits a non-blocking `enemy_stats` missing schema warning; address with AI Story003/data schema work.
- Next recommended: AI Story002 Perception Cone + Line-of-Sight Query — production/epics/ai-framework/story-002-perception-cone-line-of-sight-query.md

## Session Extract — /dev-story + /story-done 2026-06-23 (ai story-002)
- Verdict: COMPLETE
- Story: production/epics/ai-framework/story-002-perception-cone-line-of-sight-query.md — Perception Cone + Line-of-Sight Query
- Files changed: src/core/ai_component.gd, tests/unit/ai/story_002_perception_cone_line_of_sight_query_test.gd, production/epics/ai-framework/story-002-perception-cone-line-of-sight-query.md, production/epics/ai-framework/EPIC.md
- Implementation: Added configurable perception radius/angle, deterministic target detection result, injectable line-of-sight and perception providers, IDLE/PATROL → CHASE transition, CHASE → PATROL lost-target timer, and PhysicsRayQueryParameters2D fallback for environment line-of-sight.
- TDD evidence: RED `reports/report_187/` failed on missing perception APIs; GREEN Story002 suite 5/5 passing (`reports/report_188/`).
- Regression evidence: AI suite 10/10 passing (`reports/report_189/`); full unit suite 207/207 passing (`reports/report_190/`).
- Runtime validation: `godot --headless --path . --quit` passed; `godot --headless --path . --scene res://scenes/main.tscn --fixed-fps 60 --quit-after 120 --log-file reports/ai_story002_main_scene_smoke.log` passed and logged Godot AI MCP capture registration.
- Review: Local review passed against ADR-0006, control manifest, TR-ai-002, GDD F1, and Story002 unit evidence. No `NavigationAgent2D`, EventBus, string-based connect, PhysicsBody hit detection, or class-per-state pattern introduced.
- Warning carried forward: full unit run emits a non-blocking `enemy_stats` missing schema warning; address with AI Story003/data schema work.
- Next recommended: AI Story003 Data-Driven Attack Pattern Loading — production/epics/ai-framework/story-003-data-driven-attack-pattern-loading.md
- Deviation: Combo multiplier values are temporary constants until Story 004 moves DamageParams tables into JSON/schema integration.
- Blockers: None
- Next: /code-review src/foundation/damage_calculator.gd src/foundation/damage_result.gd tests/unit/damage/story_001_formula_pipeline_test.gd tests/unit/damage/story_002_crit_combo_parry_test.gd production/epics/damage-calculator/story-001-formula-pipeline.md production/epics/damage-calculator/story-002-crit-combo-parry.md, then /story-done for stories 001 and 002.

## Session Extract — /code-review + /story-done 2026-06-23 (damage story-001 + story-002)
- Verdict: COMPLETE WITH NOTES
- Story 001: production/epics/damage-calculator/story-001-formula-pipeline.md — FormulaPipeline + DamageResult 核心公式
- Story 002: production/epics/damage-calculator/story-002-crit-combo-parry.md — CritComboParry 倍率路径
- Review: Local code review passed against ADR-0001, ADR-0002, the Foundation control manifest, GDD TR-damage-001/002/003/004/005/006/008, and damage-unit test evidence. Specialist subagent gates were not spawned because the current tool surface did not expose the required Task tool.
- Fixes during review: Removed untyped `Array` exposure from combo multiplier handling and replaced it with typed scalar helper logic in `DamageCalculator`.
- Tests: Story 001 6/6 passing; Story 002 5/5 passing; combined `tests/unit/data` + `tests/unit/damage` 54/54 passing (report_45); `godot --headless --path . --quit` passing; `git diff --check` passing.
- Notes: Story 001 keeps the documented `RefCounted` return-type workaround for headless GdUnit class-name registration; Story 002 keeps combo constants until Story 004 externalizes DamageParams JSON/schema integration.
- Tech debt logged: None; remaining notes are covered by Story 004 or documented engine/test-environment behavior.
- Next recommended: Story 003 SpecialMoves + Skill/Window Modifiers — production/epics/damage-calculator/story-003-special-modifiers.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (damage story-003)
- Verdict: COMPLETE WITH NOTES
- Story: production/epics/damage-calculator/story-003-special-modifiers.md — SpecialMoves + Skill/Window Modifiers
- Implementation: Added injected skill modifier handling for `skill_weapon_bonus`, charm/focus PERFECT crit-window extension, DC-F9 special move calculation for cat_claw/long_tail, and heavy/aerial third-path attack damage that ignores combo/parry multipliers.
- TDD evidence: Red first failed on missing Story 003 API methods; green Story 003 suite 6/6 passing.
- Review: Local code review passed against ADR-0001, the Foundation control manifest, GDD TR-damage-007/009/010/011, and damage-unit test evidence. Specialist subagent gates were not spawned because the current tool surface did not expose the required Task tool.
- Tests: Story 003 6/6 passing; full `tests/unit/damage` 17/17 passing; combined `tests/unit/data` + `tests/unit/damage` 60/60 passing (report_48); `godot --headless --path . --quit` passing; `git diff --check` passing.
- Notes: Special move, hit-count, and attack-type multiplier tables intentionally remain local helpers until Story 004 externalizes DamageParams JSON/schema/DataManager integration.
- Tech debt logged: None; remaining notes are covered by Story 004.
- Next recommended: Story 004 DamageParams Data API Integration — production/epics/damage-calculator/story-004-data-api-integration.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (damage story-004)
- Verdict: COMPLETE
- Story: production/epics/damage-calculator/story-004-data-api-integration.md — DamageParams Data API Integration
- Authorization: Standing approval applies for local project writes, replacements, and destructive local project-file operations needed for the active goal.
- Implementation: Added public `DamageCalculator.calculate_damage(...)` integration, DataManager-backed `damage_params`, safe missing-weapon defaults, complete DamageResult metadata for normal/crit/parry/combo/special/clamp/category paths, and damage tuning knob registration/consumption.
- Data/schema: Expanded `data/combat/damage_params.json` for `_global`, `cat_claw`, `long_tail`, `fish_bone`, and placeholder `electro_bell`; added schema coverage for weapon_base, combo, crit, parry, special_move, attack_type, category thresholds, and damage tuning knobs.
- TDD evidence: Red first failed on missing public API/tuning integration; a nested schema regression then failed until `SchemaValidator` validated nested Dictionary requirements outside range-only checks.
- Review: Local code review passed against ADR-0001, ADR-0002, ADR-0003, Foundation control manifest, and GDD TR-damage-001 through TR-damage-011. Specialist subagent gates were not spawned because the current tool surface did not expose the required Task tool and user standing authorization directs local execution without approval pauses.
- Tests: Story 004 7/7 passing (report_56); full `tests/unit/damage` 24/24 passing (report_57); full `tests/unit/data` 43/43 passing (report_58).
- Tech debt logged: None.
- Epic status: Damage Calculation complete; next recommended target is Health/Death or Feline Combat integration.

## Session Extract — /create-stories 2026-06-23 (input-manager)
- Epic: production/epics/input-manager/EPIC.md — Input System
- Stories created: 7
  - story-001-action-abstraction.md — InputManager Action Abstraction + Query API
  - story-002-direct-dispatch-fsm.md — Direct Dispatch + FSM Signals
  - story-003-buffer-queue-preinput.md — Buffer Queue + Pre-input
  - story-004-combo-conflicts.md — Combo Chain + Conflict Resolution
  - story-005-coyote-jump-buffer.md — Coyote Time + Jump Buffer
  - story-006-device-switching.md — Device Detection + Debounced Switching
  - story-007-key-rebinding-deferred.md — Key Rebinding Persistence (Deferred to Polish)
- Index updated: production/epics/index.md input-manager row now lists 7 stories.
- Authorization: Standing approval applies for local project writes, so the normal create-stories write approval prompt was treated as already granted.
- Next: implement Story 001 first.

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (input story-001)
- Verdict: COMPLETE WITH NOTES
- Story: production/epics/input-manager/story-001-action-abstraction.md — InputManager Action Abstraction + Query API
- Implementation: Added `src/foundation/input_manager.gd`, registered InputManager as Autoload #2 after DataManager, normalized 12 GDD core actions, exposed typed query APIs, registered 8 input tuning knobs, and added input tuning JSON/schema entries.
- InputMap: Added `dash`, `heavy_attack`, and `parry`; aligned `dodge` with GDD default L key while keeping K/mouse-right for `heavy_attack`.
- TDD evidence: Red first failed on missing `res://src/foundation/input_manager.gd`; green Story 001 suite 5/5 passing.
- Review: Local code review passed against ADR-0001, ADR-0003, Foundation control manifest, and GDD TR-input-001/TR-input-011/TR-input-012. Specialist subagent gates were not spawned because the current tool surface did not expose the required Task tool and user standing authorization directs local execution without approval pauses.
- Tests: Story 001 5/5 passing (report_60); full `tests/unit/input` 5/5 passing (report_61); full `tests/unit/data` 43/43 passing (report_62); full `tests/unit/damage` 24/24 passing (report_63).
- Notes: `class_name InputManager` remains intentionally omitted because the same Autoload singleton naming collision must stay avoided under the current Godot 4.7 baseline.
- Tech debt logged: None.
- Next recommended: Story 002 Direct Dispatch + FSM Signals — production/epics/input-manager/story-002-direct-dispatch-fsm.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (input story-002)
- Verdict: COMPLETE
- Story: production/epics/input-manager/story-002-direct-dispatch-fsm.md — Direct Dispatch + FSM Signals
- Implementation: Added InputManager DIRECT/BUFFERING/TRANSITIONING state tracking, `accept_action()`, `notify_animation_lock()`, `notify_animation_unlock()`, same-frame direct dispatch, pause immediate dispatch, and deterministic `action_triggered` metadata.
- TDD evidence: Red first failed on missing Story 002 FSM/dispatch APIs; green Story 002 suite 5/5 passing.
- Review: Local code review passed against ADR-0001, ADR-0002, Foundation control manifest, and GDD TR-input-007/TR-input-008. Specialist subagent gates were not spawned because the current tool surface did not expose the required Task tool and user standing authorization directs local execution without approval pauses.
- Tests: Story 002 5/5 passing (report_65); full `tests/unit/input` 10/10 passing (report_66); full `tests/unit/data` 43/43 passing (report_67); full `tests/unit/damage` 24/24 passing (report_68).
- Tech debt logged: None.
- Next recommended: Story 003 Buffer Queue + Pre-input — production/epics/input-manager/story-003-buffer-queue-preinput.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (input story-003)
- Verdict: COMPLETE
- Story: production/epics/input-manager/story-003-buffer-queue-preinput.md — Buffer Queue + Pre-input
- Implementation: Added buffer queue storage during BUFFERING, queue-size cap with oldest-drop behavior, duplicate action timestamp refresh, buffer expiry pruning, pre-input priority bonus metadata, highest-priority unlock consumption, and clear_buffer consumption prevention.
- TDD evidence: Red first failed because BUFFERING `accept_action()` returned false and unlock did not consume a buffered action (report_69); green Story 003 suite 6/6 passing (report_70).
- Review: Local code review passed against ADR-0001, ADR-0003, Foundation control manifest, and GDD TR-input-002. Specialist subagent gates were not spawned because the current tool surface did not expose the required Task tool and user standing authorization directs local execution without approval pauses.
- Tests: full `tests/unit/input` 16/16 passing (report_71); full `tests/unit/data` 43/43 passing (report_72); full `tests/unit/damage` 24/24 passing (report_73); `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods under 50 lines.
- Tech debt logged: None.
- Next recommended: Story 004 Combo Chain + Conflict Resolution — production/epics/input-manager/story-004-combo-conflicts.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (input story-004)
- Verdict: COMPLETE
- Story: production/epics/input-manager/story-004-combo-conflicts.md — Combo Chain + Conflict Resolution
- Implementation: Added combo counter state, `combo_index` metadata for consumed attacks, combo timeout reset, frame-level `accept_actions()` conflict resolution, and highest-priority same-frame trigger selection for dodge/attack, parry/dodge, dash/jump, and pause.
- TDD evidence: Red first failed because attack `combo_index` stayed at 0 (report_74); green Story 004 suite 6/6 passing (report_76). An intermediate typed Array compatibility failure was fixed by accepting plain `Array` and converting entries internally.
- Review: Local code review passed against ADR-0001, ADR-0002, Foundation control manifest, and GDD TR-input-003/TR-input-006. Specialist subagent gates were not spawned because the current tool surface did not expose the required Task tool and user standing authorization directs local execution without approval pauses.
- Tests: full `tests/unit/input` 22/22 passing (report_77); full `tests/unit/data` 43/43 passing (report_78); full `tests/unit/damage` 24/24 passing (report_79); `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods under 50 lines.
- Tech debt logged: None.
- Next recommended: Story 005 Coyote Time + Jump Buffer — production/epics/input-manager/story-005-coyote-jump-buffer.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (input story-005)
- Verdict: COMPLETE
- Story: production/epics/input-manager/story-005-coyote-jump-buffer.md — Coyote Time + Jump Buffer
- Implementation: Added pure InputManager helpers `can_use_coyote_jump()` and `should_consume_jump_buffer()` with inclusive frame-window checks, negative-frame rejection, and DataManager tuning fallback to default 6-frame windows.
- TDD evidence: Red first failed on missing coyote/jump helper APIs (report_80); green Story 005 suite 5/5 passing (report_81).
- Review: Local code review passed against ADR-0001, ADR-0003, Foundation control manifest, and GDD TR-input-004. Specialist subagent gates were not spawned because the current tool surface did not expose the required Task tool and user standing authorization directs local execution without approval pauses.
- Tests: full `tests/unit/input` 27/27 passing (report_82); full `tests/unit/data` 43/43 passing (report_83); full `tests/unit/damage` 24/24 passing (report_84); `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods under 50 lines.
- Tech debt logged: None.
- Next recommended: Story 006 Device Detection + Debounced Switching — production/epics/input-manager/story-006-device-switching.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (input story-006)
- Verdict: COMPLETE
- Story: production/epics/input-manager/story-006-device-switching.md — Device Detection + Debounced Switching
- Implementation: Added headless-safe InputEvent classification, current-device query, debounced event ingestion, priority handling (`gamepad > kbm > touch`), combat input lock APIs, and explicit gamepad disconnect handling without references to combat, boss, HUD, or UI nodes.
- TDD evidence: Red first failed on missing device switching APIs (report_85); green Story 006 suite 7/7 passing (report_86).
- Review: Local code review passed against ADR-0001, ADR-0002, Foundation control manifest, and GDD TR-input-005/TR-input-009. Specialist subagent gates were not spawned because the current tool surface did not expose the required Task tool and user standing authorization directs local execution without approval pauses.
- Tests: full `tests/unit/input` 34/34 passing (report_88); full `tests/unit/data` 43/43 passing (report_89); full `tests/unit/damage` 24/24 passing (report_90); `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods under 50 lines.
- Tech debt logged: None.
- Epic status: Input System Foundation scope complete; Story 007 Key Rebinding Persistence remains deferred to Feature/Polish.
- Next recommended: Health/Death or Feline Combat integration, because InputManager and DamageCalculator Foundation APIs are now available.

## Session Extract — /create-epics + /create-stories + /dev-story 2026-06-23 (health story-001)
- Verdict: COMPLETE
- Epic/story: production/epics/health-death/EPIC.md — Health & Death Detection; production/epics/health-death/story-001-hp-damage-pipeline.md — HP State + Damage Pipeline
- Coordination: AGENTS.md now records the user's standing approval for local project writes, including necessary destructive project-file writes, while commits/pushes/external actions still require explicit instruction.
- Planning: Created the Health/Death epic and six story files mapping `design/gdd/health-death.md` and `docs/architecture/tr-registry.yaml` TR-health-001~015. ADR-0001 and ADR-0002 govern implementation; ADR-0019 remains Proposed and is used only as design reference.
- Implementation: Added `src/core/health_component.gd` as a Core entity Node component with local HP/max HP/shield state, alive/dying/dead queries, safe max_hp fallback, shield-first damage absorption, non-positive/dead damage guards, HP clamping, and typed `on_hp_changed`/`on_death` signals.
- TDD evidence: First red failed on missing HealthComponent script; second red failed on missing `configure()` and query/damage APIs (`reports/report_91/`); green Story 001 suite 7/7 passing (`reports/report_92/`).
- Tests: clean sequential health 7/7 passing (`reports/report_95/`); full `tests/unit/input` 34/34 passing (`reports/report_96/`); full `tests/unit/data` 43/43 passing (`reports/report_97/`); full `tests/unit/damage` 24/24 passing (`reports/report_98/`); `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods under 50 lines.
- Tech debt logged: None.
- Next recommended: Story 002 HP Milestones + Boss Phase Gates — production/epics/health-death/story-002-milestones-boss-phases.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (health story-002)
- Verdict: COMPLETE
- Story: production/epics/health-death/story-002-milestones-boss-phases.md — HP Milestones + Boss Phase Gates
- Implementation: Added typed `on_hp_milestone(entity_id, threshold)` and `on_boss_phase_change(entity_id, phase, hp_percentage)` signals, lifecycle milestone suppression, previous-to-current HP threshold crossing checks, `configure_boss_phases()`, and while-loop Boss phase emission with 1-based phase numbers.
- TDD evidence: First red failed on missing `on_hp_milestone` (`reports/report_99/`); second red caught over-broad low-HP milestone backfill (`reports/report_100/`); green Story 002 suite 4/4 passing (`reports/report_101/`).
- Review: Local code review passed against ADR-0001, ADR-0002, Core control manifest, GDD TR-health-004/TR-health-005/TR-health-011/TR-health-015, and health-unit test evidence. Specialist subagent gates were not spawned because the current tool surface did not expose the required Task tool and user standing authorization directs local execution without approval pauses.
- Tests: full `tests/unit/health` 11/11 passing (`reports/report_102/`); full `tests/unit/input` 34/34 passing (`reports/report_103/`); full `tests/unit/data` 43/43 passing (`reports/report_104/`); full `tests/unit/damage` 24/24 passing (`reports/report_105/`); `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods under 50 lines.
- Tech debt logged: None.
- Next recommended: Story 003 I-Frames + Healing + Revive — production/epics/health-death/story-003-iframes-healing-revive.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (health story-003)
- Verdict: COMPLETE WITH NOTES
- Story: production/epics/health-death/story-003-iframes-healing-revive.md — I-Frames + Healing + Revive
- Implementation: Added max-take i-frame grants, per-physics-frame i-frame ticking, damage immunity without HP/shield/signal mutation, HP healing clamp, save-point HP/shield full restore, and revive HP floor/state reset with per-life milestone and boss phase gate reset.
- TDD evidence: First red failed on missing `grant_iframes`, `heal`, `restore_at_savepoint`, and `revive` APIs (`reports/report_106/`); green Story 003 suite 6/6 passing (`reports/report_107/`).
- Review: Local code review passed against ADR-0001, ADR-0002, Core control manifest, GDD TR-health-009 and Story 003 acceptance criteria. Specialist subagent gates were not spawned because the current tool surface did not expose the required Task tool and user standing authorization directs local execution without approval pauses.
- Tests: full `tests/unit/health` 17/17 passing (`reports/report_108/`); full `tests/unit/input` 34/34 passing (`reports/report_110/`); full `tests/unit/data` 43/43 passing (`reports/report_111/`); full `tests/unit/damage` 24/24 passing (`reports/report_112/`); `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods under 50 lines; related files have no trailing whitespace.
- Notes: `TR-health-013` focus-mode reset remains deferred to Story 004 because Story 003 explicitly lists focus-mode reset as out of scope and the component has no focus state/signal yet.
- Tech debt logged: None; the focus reset note is covered by Story 004.
- Next recommended: Story 004 Focus Mode State + Signals — production/epics/health-death/story-004-focus-mode-signals.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (health story-004)
- Verdict: COMPLETE WITH NOTES
- Story: production/epics/health-death/story-004-focus-mode-signals.md — Focus Mode State + Signals
- Implementation: Added player-gated focus mode state, active enemy count injection, 25% activation threshold, strict >28% exit hysteresis, combat-ended exit, revive focus reset, and focus transition metadata for AI/Presentation consumers.
- TDD evidence: First red failed on missing `on_focus_mode_changed`, player configure flag, `set_active_enemy_count()`, and `is_focus_mode_active()` (`reports/report_113/`); green Story 004 suite 7/7 passing (`reports/report_114/`).
- Review: Local code review passed against ADR-0001, ADR-0002, ADR-0006, Core control manifest, GDD TR-health-006/TR-health-007/TR-health-008/TR-health-011/TR-health-013, and health-unit test evidence. Specialist subagent gates were not spawned because the current tool surface did not expose the required Task tool and user standing authorization directs local execution without approval pauses.
- Tests: full `tests/unit/health` 24/24 passing (`reports/report_115/`); full `tests/unit/input` 34/34 passing (`reports/report_116/`); full `tests/unit/data` 43/43 passing (`reports/report_117/`); full `tests/unit/damage` 24/24 passing (`reports/report_118/`); `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods under 50 lines; related files have no trailing whitespace.
- Notes: `on_focus_mode_changed` intentionally uses `(entity_id, active, metadata)` instead of the GDD/ADR bool-only sketch so AI and Presentation listeners receive the state required by Story 004 without querying back into Core. The payload still follows ADR-0002 because it has three direct fields.
- Tech debt logged: None.
- Next recommended: Story 005 Death Metadata + Zone Hooks — production/epics/health-death/story-005-death-metadata-zone-hooks.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (health story-005)
- Verdict: COMPLETE WITH NOTES
- Story: production/epics/health-death/story-005-death-metadata-zone-hooks.md — Death Metadata + Zone Hooks
- Implementation: Added structured `on_death` metadata with `last_hit`, `battle_stats`, and `context`; added `on_death_in_zone(entity_id, zone_id)`; added zone tracking, combat damage-dealt observation, battle duration/damage received stats, safe CombatComponent battle-stat lookup, and deep-copy isolation for nested battle stats.
- TDD evidence: Red first failed on missing `set_current_zone_id()` and missing structured death metadata (`reports/report_119/`); green Story 005 suite 4/4 passing (`reports/report_120/`).
- Review: Local code review passed against ADR-0001, ADR-0002, Core control manifest, GDD TR-health-010/TR-health-015, and health-unit test evidence. Specialist subagent gates were not spawned because the current tool surface did not expose the required Task tool and user standing authorization directs local execution without approval pauses.
- Tests: full `tests/unit/health` 28/28 passing (`reports/report_121/`); full `tests/unit/input` 34/34 passing (`reports/report_122/`); full `tests/unit/data` 43/43 passing (`reports/report_123/`); full `tests/unit/damage` 24/24 passing (`reports/report_124/`); `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods under 40 lines; related files have no trailing whitespace.
- Notes: `on_death_in_zone` emits before terminal `on_death` so TR-health-011 still ends with `on_death`; a top-level `source` compatibility field remains for existing Story 001 death consumers while new consumers use `metadata.last_hit.source`.
- Tech debt logged: None.
- Next recommended: Story 006 Max HP Aggregation + Serialization Prep — production/epics/health-death/story-006-max-hp-serialization-prep.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (health story-006)
- Verdict: COMPLETE
- Story: production/epics/health-death/story-006-max-hp-serialization-prep.md — Max HP Aggregation + Serialization Prep
- Implementation: Added HD-F0 max HP aggregation via `recalculate_max_hp(base_hp, skill_hp_flat, charm_hp_flat)`, safe invalid max HP fallback, percentage-preserving current HP resize, HD-F4 `get_injury_pitch_offset()`, and JSON-safe `serialize()` / `deserialize(data, version)` state round trip for future SaveSystem registration.
- TDD evidence: Red first failed on missing `recalculate_max_hp()`, `get_injury_pitch_offset()`, `serialize()`, and `deserialize()` (`reports/report_125/`); green Story 006 suite 5/5 passing (`reports/report_126/`).
- Review: Local code review passed against ADR-0001, ADR-0008, Core control manifest, GDD TR-health-012/TR-health-014, and health-unit test evidence. Specialist subagent gates were not spawned because current multi-agent tool rules only allow spawning when the user explicitly requests delegation.
- Tests: full `tests/unit/health` 33/33 passing (`reports/report_127/`); full `tests/unit/input` 34/34 passing (`reports/report_128/`); full `tests/unit/data` 43/43 passing (`reports/report_129/`); full `tests/unit/damage` 24/24 passing (`reports/report_130/`); `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods under 40 lines; related files have no trailing whitespace.
- Notes: `.Codex/docs/technical-preferences.md` was referenced by AGENTS.md but does not exist in the current worktree; implementation used the existing `.claude/docs/technical-preferences.md` plus `docs/architecture/control-manifest.md`.
- Tech debt logged: None.
- Epic status: Health & Death Detection scope complete; `production/epics/health-death/EPIC.md` and `production/epics/index.md` now mark the epic Complete.
- Next recommended: continue with the next Core/Feature integration epic that consumes HealthComponent signals, such as Feline Combat integration or Death & Respawn.

## Session Extract — /create-epics + /create-stories + /dev-story + /story-done 2026-06-23 (feline-combat story-001)
- Verdict: COMPLETE
- Epic/story: production/epics/feline-combat/EPIC.md — Feline Combat; production/epics/feline-combat/story-001-combat-state-machine-input-entry.md — Combat State Machine + Input Entry Points
- Planning: Created the Feline Combat epic and seven story files mapping `design/gdd/feline-combat.md` and `docs/architecture/tr-registry.yaml` TR-combat-001~012. Core visual/audio/UI requirements remain delegated to Combat Presentation, Audio, and HUD/UI epics.
- Implementation: Added `src/core/combat_component.gd` as a Core entity Node component with a 6-state enum FSM, `on_action_triggered()` input entry, state change signal, default battle stats, optional InputManager signal hookup, and safe defaults without requiring AnimationPlayer or a full Player scene.
- TDD evidence: Red first failed on missing `res://src/core/combat_component.gd`; after implementation, a headless GdUnit global `class_name` discovery issue was fixed by referencing the preloaded script enum in tests. Story 001 suite 5/5 passing (`reports/report_131/`).
- Tests: full `tests/unit` 139/139 passing (`reports/report_132/`). Expected DataManager error logs appear inside negative-path data migration tests and did not fail the run.
- Review: Local automated review passed against ADR-0001, ADR-0002, ADR-0005, Core control manifest, and GDD TR-combat-001/TR-combat-006. Specialist QA/LP gates were not spawned because current tool policy requires explicit user delegation for subagents.
- Tech debt logged: None.
- Epic status: Feline Combat is now In Progress; Story 001 is Complete.
- Next recommended: Story 002 Light Combo Chain + Cancel Windows — production/epics/feline-combat/story-002-light-combo-cancel-windows.md

## Session Extract — /dev-story + /story-done 2026-06-23 (feline-combat story-002)
- Verdict: COMPLETE
- Story: production/epics/feline-combat/story-002-light-combo-cancel-windows.md — Light Combo Chain + Cancel Windows
- Implementation: Extended `src/core/combat_component.gd` with light attack frame data (4+8, 6+12, 10+20), deterministic attack-frame and combo-time advancement APIs, attack recovery detection, `reset_combo()`, stage-specific light attack starts, recovery-only combo chaining, 300ms timeout reset, and dodge cancellation from attack recovery.
- TDD evidence: Red first failed on missing Story 002 APIs (`reports/report_133/`); green Story 002 suite 5/5 passing (`reports/report_135/`). One test assertion was corrected to match the story's "clamp or fall back safely" wording for invalid stage indexes; implementation clamps overlarge stages to stage 2.
- Tests: combat suite 10/10 passing (`reports/report_136/`); full `tests/unit` 144/144 passing (`reports/report_137/`); `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods under 40 lines; related files have no trailing whitespace.
- Review: Local automated review passed against ADR-0005, Core control manifest, and GDD TR-combat-002/TR-combat-005. Specialist QA/LP gates were not spawned because current tool policy requires explicit user delegation for subagents.
- Tech debt logged: None.
- Epic status: Feline Combat remains In Progress; Stories 001-002 are Complete.
- Next recommended: Story 003 Dodge I-Frames + Hurtbox Adapter — production/epics/feline-combat/story-003-dodge-iframes-hurtbox-adapter.md

## Session Extract — /dev-story + /story-done 2026-06-23 (feline-combat story-003)
- Verdict: COMPLETE
- Story: production/epics/feline-combat/story-003-dodge-iframes-hurtbox-adapter.md — Dodge I-Frames + Hurtbox Adapter
- Implementation: Extended `src/core/combat_component.gd` with dodge frame tracking, i-frame query APIs, injected hurtbox adapter calls, 0.5s cooldown, airborne metadata rejection, cat-claw 30-frame dodge counter window, and `on_dodge_counter_active(active)` signaling.
- TDD evidence: Red first failed on missing dodge i-frame, hurtbox adapter, cooldown, and dodge counter APIs (`reports/report_138/`); green Story 003 suite 6/6 passing (`reports/report_139/`).
- Tests: combat suite 16/16 passing (`reports/report_140/`); full `tests/unit` 150/150 passing (`reports/report_141/`); `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods under 80 lines; related files have no trailing whitespace.
- Review: Local automated review passed against ADR-0004, ADR-0005, Core control manifest, and GDD TR-combat-003. Specialist QA/LP gates were not spawned because current multi-agent tool rules only allow spawning when the user explicitly requests delegation.
- Tech debt logged: None.
- Epic status: Feline Combat remains In Progress; Stories 001-003 are Complete.
- Next recommended: Story 004 Parry Timing Windows + Counter Outcome — production/epics/feline-combat/story-004-parry-timing-counter-outcome.md

## Session Extract — /dev-story + /story-done 2026-06-23 (feline-combat story-004)
- Verdict: COMPLETE
- Story: production/epics/feline-combat/story-004-parry-timing-counter-outcome.md — Parry Timing Windows + Counter Outcome
- Implementation: Extended `src/core/combat_component.gd` with parry frame tracking, PERFECT/GOOD/LATE/MISS classification, deterministic frame advancement, PARRYING lifecycle exit after frame 18, `resolve_parry_result()` metadata, no-extra-punishment miss handling, `on_parry_resolved(metadata)`, and an automatic counter transition to ATTACKING on successful parry.
- TDD evidence: Red first failed on missing Story 004 parry APIs (`reports/report_142/`); green Story 004 suite 6/6 passing (`reports/report_144/`).
- Tests: combat suite 22/22 passing (`reports/report_145/`); full `tests/unit` 156/156 passing (`reports/report_146/`); `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods under 80 lines; related files have no trailing whitespace.
- Review: Local automated review passed against ADR-0004, ADR-0005, Core control manifest, and GDD TR-combat-004. Specialist QA/LP gates were not spawned because current multi-agent tool rules only allow spawning when the user explicitly requests delegation.
- Tech debt logged: None.
- Epic status: Feline Combat remains In Progress; Stories 001-004 are Complete.
- Next recommended: Story 005 Heavy Charge + Hit Stun + Aerial Hooks — production/epics/feline-combat/story-005-heavy-charge-hit-stun-aerial-hooks.md

## Session Extract — /dev-story + /story-done 2026-06-23 (feline-combat story-005)
- Verdict: COMPLETE
- Story: production/epics/feline-combat/story-005-heavy-charge-hit-stun-aerial-hooks.md — Heavy Charge + Hit Stun + Aerial Hooks
- Implementation: Extended `src/core/combat_component.gd` with heavy charge timing, `get_charge_ratio()`, min/max charge release behavior, auto full-charge release, `on_heavy_attack_released(metadata)`, CHARGING dodge cancellation, damage interruption into HIT_STUN, hit-stun stack clamping at three, and `on_aerial_bounce_requested(metadata)` for PlayerMovement integration.
- TDD evidence: Red first failed on missing Story 005 heavy charge, hit-stun, and aerial hook APIs/signals (`reports/report_147/`); green Story 005 suite 7/7 passing (`reports/report_148/`).
- Tests: combat suite 29/29 passing (`reports/report_149/`); full `tests/unit` 163/163 passing (`reports/report_150/`); `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods under 80 lines; related files have no trailing whitespace.
- Review: Local automated review passed against ADR-0005, Core control manifest, and GDD TR-combat-011/TR-combat-012. Specialist QA/LP gates were not spawned because current multi-agent tool rules only allow spawning when the user explicitly requests delegation.
- Notes: The full unit run logs an expected DataManager migration error inside `story_006_version_migrator_test.gd`; the test passes and the suite exits 0.
- Tech debt logged: None.
- Epic status: Feline Combat remains In Progress; Stories 001-005 are Complete.
- Next recommended: Story 006 Cat Energy + Special/Ultimate Gates — production/epics/feline-combat/story-006-cat-energy-special-ultimate-gates.md

## Session Extract — /dev-story + /story-done 2026-06-23 (feline-combat story-006)
- Verdict: COMPLETE
- Story: production/epics/feline-combat/story-006-cat-energy-special-ultimate-gates.md — Cat Energy + Special/Ultimate Gates
- Implementation: Extended `src/core/combat_component.gd` with 0-100 cat energy, explicit GDD gain table, out-of-combat reset timer, energy consumption helper, weapon-specific special energy/cooldown gates, duck-typed ultimate unlock provider, ultimate 80-energy gate, and deterministic cooldown/timer advancement APIs.
- Integration hooks: `on_damage_taken()` now grants `damage_taken` energy and resets the out-of-combat timer; `on_aerial_hit_confirmed()` grants `aerial`; successful PERFECT/GOOD parry results grant `perfect_parry`/`good_parry` while `parry_counter` remains reserved for future hit confirmation.
- TDD evidence: Red first failed on missing Story 006 cat-energy and special/ultimate gate APIs (`reports/report_151/`); green Story 006 suite 6/6 passing after implementation and parry-counter correction (`reports/report_153/`).
- Tests: combat suite 35/35 passing (`reports/report_154/`); full `tests/unit` 169/169 passing (`reports/report_155/`); `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods under 80 lines; related files have no trailing whitespace.
- Review: Local automated review passed against ADR-0005, proposed ADR-0016 reference, Core control manifest, and GDD TR-combat-007/TR-combat-008/TR-combat-009. Specialist QA/LP gates were not spawned because current multi-agent tool rules only allow spawning when the user explicitly requests delegation.
- Notes: TR-combat-007 says 12 gain behaviors, but the current GDD/story table explicitly lists 11 event ids. Implementation covers every listed id and does not invent a missing 12th event.
- Tech debt logged: None.
- Epic status: Feline Combat remains In Progress; Stories 001-006 are Complete.
- Next recommended: Story 007 Hit Confirmation + Focus Damage Metadata — production/epics/feline-combat/story-007-hit-confirmation-focus-damage-metadata.md

## Session Extract — /dev-story + /story-done 2026-06-23 (feline-combat story-007)
- Verdict: COMPLETE
- Story: production/epics/feline-combat/story-007-hit-confirmation-focus-damage-metadata.md — Hit Confirmation + Focus Damage Metadata
- Implementation: Extended `src/core/combat_component.gd` with provisional CollisionComponent `on_hit_confirmed(event)` adapter wiring, duck-typed Dictionary/object hit payload extraction, outgoing attack metadata assembly, focus-mode crit-window bonus handling, optional DamageCalculator and HealthComponent adapters, Health-compatible `apply_damage` dispatch, confirmed-hit cat-energy grants, and battle-stat updates for hits landed, total damage dealt, parries, dodges, and cat energy.
- TDD evidence: Red first failed on missing Story 007 adapter/focus/hit-confirmation APIs (`reports/report_156/`); green Story 007 suite 5/5 passing (`reports/report_157/`).
- Tests: combat suite 40/40 passing (`reports/report_158/`); full `tests/unit` 174/174 passing (`reports/report_159/`); `godot --headless --path . --quit` passing; `git diff --check` passing; changed GDScript methods under 80 lines; related files have no trailing whitespace.
- Review: Local automated review passed against ADR-0002, ADR-0004, ADR-0005, Core control manifest, and GDD TR-combat-006/TR-combat-010. Specialist QA/LP gates were not spawned because current multi-agent tool rules only allow spawning when the user explicitly requests delegation.
- Notes: DamageCalculator remains optional/injectable at this Core layer; metadata and `on_attack_hit` still emit safely when Collision, Damage, or Health adapters are absent.
- Tech debt logged: None.
- Epic status: Feline Combat Core scope complete; `production/epics/feline-combat/EPIC.md` and `production/epics/index.md` now mark the epic Complete.
- Next recommended: choose a downstream integration epic that consumes Combat signals and metadata, such as Weapon Styles, Combat Presentation, Audio, HUD/UI, or Death metadata integration.

## Session Extract — /create-epics + /create-stories 2026-06-23 (collision detection)
- Verdict: COMPLETE
- Epic: production/epics/collision-detection/EPIC.md — Collision Detection
- Planning: Created the Collision Detection epic and five story files mapping `design/gdd/collision-detection.md` and `docs/architecture/tr-registry.yaml` TR-collision-001~007.
- Governing ADRs: ADR-0001, ADR-0002, ADR-0004, and ADR-0005. Collision remains a Core entity component; Presentation, debug UI, VFX, and audio are deferred to downstream epics.
- Review: `production/review-mode.txt` is `full`, but producer/QA/LP subagent gates were skipped because current multi-agent tool rules only allow spawning when the user explicitly requests delegation.
- Epic status: Collision Detection is In Progress with Story 001 complete and Stories 002-005 ready.
- Next recommended: Story 002 Hurtbox States + Collision Layers — production/epics/collision-detection/story-002-hurtbox-states-collision-layers.md

## Session Extract — /dev-story + /story-done 2026-06-23 (collision story-001)
- Verdict: COMPLETE
- Story: production/epics/collision-detection/story-001-hitbox-area-activation-lifecycle.md — HitboxArea + Activation Lifecycle
- Implementation: Added `src/core/hitbox_area.gd` with inactive-by-default Area2D lifecycle state, minimum 4x4 rectangle shape, duplicate target tracking, activation metadata copying, frame countdown, and safe deactivation. Added `src/core/collision_component.gd` with deterministic hitbox creation/reuse, activation/deactivation, active hitbox tracking, and frame advancement.
- TDD evidence: First story run failed during discovery because `res://src/core/hitbox_area.gd` and `res://src/core/collision_component.gd` did not exist yet (exit 105); green Story 001 suite 5/5 passing (`reports/report_163/`).
- Tests: collision suite 5/5 passing (`reports/report_164/`); full `tests/unit` 179/179 passing (`reports/report_165/`); `godot --headless --path . --quit` passing with Godot MCP capture registration visible in startup logs; `git diff --check` passing; changed GDScript methods under 80 lines; related files have no trailing whitespace.
- Review: Local automated review passed against ADR-0001, ADR-0004, Core control manifest, and GDD TR-collision-002/TR-collision-005. Specialist QA/LP gates were not spawned because current multi-agent tool rules only allow spawning when the user explicitly requests delegation.
- Tech debt logged: None.
- Next recommended: Story 002 Hurtbox States + Collision Layers — production/epics/collision-detection/story-002-hurtbox-states-collision-layers.md

## Session Extract — /dev-story + /story-done 2026-06-23 (collision story-002)
- Verdict: COMPLETE
- Story: production/epics/collision-detection/story-002-hurtbox-states-collision-layers.md — Hurtbox States + Collision Layers
- Implementation: Extended `src/core/collision_component.gd` with one managed Hurtbox `Area2D`, normal/shrunk/gone hurtbox states, full-size hurtbox configuration, unknown-state fallback to normal, ADR-0004 player/enemy/environment layer and mask constants, entity identity/allegiance configuration, and layer/mask application for both existing and future hitboxes.
- TDD evidence: Red first failed on missing `configure_entity()` and collision layer constants (`reports/report_166/`); green Story 002 suite 5/5 passing (`reports/report_167/`).
- Tests: collision suite 10/10 passing (`reports/report_168/`); full `tests/unit` 184/184 passing (`reports/report_169/`); `godot --headless --path . --quit` passing with Godot MCP capture registration visible in startup logs; `git diff --check` passing; changed GDScript methods under 80 lines; related files have no trailing whitespace.
- Review: Local automated review passed against ADR-0004, Core control manifest, and GDD TR-collision-003/TR-collision-004. Specialist QA/LP gates were not spawned because current multi-agent tool rules only allow spawning when the user explicitly requests delegation.
- Tech debt logged: None.
- Next recommended: Story 003 Frame-Level Hit Detection + HitEvent Signal — production/epics/collision-detection/story-003-frame-level-hit-detection-hit-event-signal.md

## Session Extract — /dev-story + /story-done 2026-06-23 (collision story-003)
- Verdict: COMPLETE WITH NOTES
- Story: production/epics/collision-detection/story-003-frame-level-hit-detection-hit-event-signal.md — Frame-Level Hit Detection + HitEvent Signal
- Implementation: Added `src/core/events/hit_event.gd` as a typed RefCounted payload with attacker/target ids, hitbox id, hit position, hit frame, and deep-copied attack metadata. Extended `src/core/collision_component.gd` with `on_hit_confirmed`, frame-level detection from `_physics_process`, deterministic `process_detection_frame(overlaps_by_hitbox_id)` test hook, hurtbox group filtering, own-hurtbox/gone-hurtbox guards, layer/mask filtering, target id extraction, and hitbox lifetime decrement after detection.
- TDD evidence: Red first failed during discovery because `res://src/core/events/hit_event.gd` did not exist yet (exit 105); green Story 003 suite 5/5 passing (`reports/report_171/`).
- Tests: collision suite 15/15 passing (`reports/report_172/`); full `tests/unit` 189/189 passing (`reports/report_173/`); `godot --headless --path . --quit` passing with Godot MCP capture registration visible in startup logs; `git diff --check` passing; changed GDScript methods under 80 lines; related files have no trailing whitespace.
- Review: Local automated review passed against ADR-0002, ADR-0004, Core control manifest, and GDD TR-collision-001/TR-collision-005. Specialist QA/LP gates were not spawned because current multi-agent tool rules only allow spawning when the user explicitly requests delegation.
- Notes: `on_hit_confirmed` is annotated as `RefCounted` rather than `HitEvent` to avoid Godot/GdUnit class_name discovery-order failures for newly added scripts; runtime payloads are still created from `src/core/events/hit_event.gd`, and tests assert the emitted event's script.
- Tech debt logged: None.
- Next recommended: Story 004 Multi-Target Hits + Duplicate Suppression — production/epics/collision-detection/story-004-multi-target-hits-duplicate-suppression.md

## Session Extract — /dev-story + /story-done 2026-06-23 (collision story-004)
- Verdict: COMPLETE
- Story: production/epics/collision-detection/story-004-multi-target-hits-duplicate-suppression.md — Multi-Target Hits + Duplicate Suppression
- Implementation: No new production code was required; Story 003's `CollisionComponent` detection loop already emits one event per valid hurtbox and `HitboxArea` already tracks per-target duplicate suppression. Added Story 004 coverage for multi-target fan-out, consecutive-frame duplicate suppression, hitbox reactivation clearing, and simultaneous opposing attacks.
- TDD evidence: Story 004 suite passed immediately because existing Story 003 behavior satisfied the story; focused Story 004 suite 4/4 passing (`reports/report_174/`).
- Tests: collision suite 19/19 passing (`reports/report_175/`); full `tests/unit` 193/193 passing (`reports/report_176/`); `godot --headless --path . --quit` passing with Godot MCP capture registration visible in startup logs; `git diff --check` passing; Story 004 test/story files have no trailing whitespace and changed GDScript methods stayed under the configured length budget.
- Review: Local automated review passed against ADR-0004, Core control manifest, and GDD TR-collision-005/TR-collision-006. Specialist QA/LP gates were not spawned because current multi-agent tool rules only allow spawning when the user explicitly requests delegation.
- Tech debt logged: None.
- Next recommended: Story 005 Entity Death Cleanup + Combat Adapter Integration — production/epics/collision-detection/story-005-entity-death-cleanup-combat-adapter-integration.md

## Session Extract — /dev-story + /story-done 2026-06-23 (collision story-005)
- Verdict: COMPLETE
- Story: production/epics/collision-detection/story-005-entity-death-cleanup-combat-adapter-integration.md — Entity Death Cleanup + Combat Adapter Integration
- Implementation: Added HealthComponent-compatible death signal wiring to `CollisionComponent`, idempotent `deactivate_all_hitboxes()` cleanup, foreign-death filtering by entity id, and terminal hurtbox safety by switching the owning hurtbox to `gone`. Verified Combat can use the same CollisionComponent as both hurtbox adapter and `on_hit_confirmed` adapter through the existing Story 007 Combat path.
- TDD evidence: Red first failed on missing `CollisionComponent.set_health_adapter()` (`reports/report_177/`); green Story 005 suite 4/4 passing (`reports/report_178/`).
- Tests: collision suite 23/23 passing (`reports/report_179/`); full `tests/unit` 197/197 passing (`reports/report_180/`); `godot --headless --path . --quit` passing with Godot MCP capture registration visible in startup logs; `git diff --check` passing; changed GDScript methods under 80 lines; related files have no trailing whitespace.
- Review: Local automated review passed against ADR-0002, ADR-0004, ADR-0005, Core control manifest, and GDD TR-collision-007. Specialist QA/LP gates were not spawned because current multi-agent tool rules only allow spawning when the user explicitly requests delegation.
- Tech debt logged: None.
- Epic status: Collision Detection Core scope complete; `production/epics/collision-detection/EPIC.md` and `production/epics/index.md` now mark the epic Complete.
- Next recommended: choose a downstream consumer epic such as AI Framework, Combat Presentation, Weapon Styles, Audio, or HUD/UI.

## Session Extract — /create-epics + /create-stories 2026-06-23 (ai-framework)
- Verdict: COMPLETE
- Epic: production/epics/ai-framework/EPIC.md — AI Framework
- Planning: Created the AI Framework epic and six story files mapping `design/gdd/ai-framework.md` and `docs/architecture/tr-registry.yaml` TR-ai-001~010.
- Governing ADRs: ADR-0001, ADR-0002, ADR-0003, ADR-0004, and ADR-0006. AI remains a Core entity component; Boss-specific behavior, visual telegraphs, audio, and presentation feedback are deferred to downstream epics.
- Review: `production/review-mode.txt` is `full`, but producer/QA/LP subagent gates were skipped because current multi-agent tool rules only allow spawning when the user explicitly requests delegation.
- Epic status: AI Framework is Ready with six Ready stories.
- Next recommended: Story 001 AI State Machine + Active Enemy Count — production/epics/ai-framework/story-001-ai-state-machine-active-enemy-count.md

## Session Extract — /dev-story + /story-done 2026-06-23 (ai-framework story-003)
- Verdict: COMPLETE
- Story: production/epics/ai-framework/story-003-data-driven-attack-pattern-loading.md — Data-Driven Attack Pattern Loading
- Implementation: Extended `src/core/ai_component.gd` with DataManager-compatible adapter injection, `load_attack_patterns(enemy_id, data_adapter)`, sanitized attack pattern storage/query APIs, safe defaults for malformed frames/hitbox/vulnerability/weight fields, and empty-list no-attack behavior. Added `data/combat/enemy_stats.json` attack patterns and `data/schemas/enemy_stats.schema.json`; updated a DataManager lazy-loading fixture for the new schema field.
- TDD evidence: RED first failed on missing attack-pattern API/schema/data (`reports/report_191/`); GREEN Story003 suite 4/4 passing after implementation and test refactor (`reports/report_197/`).
- Tests: AI suite 14/14 passing (`reports/report_198/`); full `tests/unit` 211/211 passing (`reports/report_199/`); DataManager lazy-loading compatibility suite 7/7 passing (`reports/report_195/`).
- Runtime evidence: `godot --headless --path . --quit` passing; main scene smoke `reports/ai_story003_main_scene_smoke.log` passing with `[godot_ai game_helper] registered mcp capture` in logs.
- Static evidence: `git diff --check`, trailing-whitespace scan, and changed-method length scan passed.
- Review: Local review passed against ADR-0003, ADR-0006, Core control manifest, TR-ai-003, and Story003 test evidence. Specialist QA/LP gates were not spawned because no multi-agent delegation tool was exposed in this thread.
- Tech debt logged: None.
- Epic status: AI Framework remains In Progress; Stories 001-003 are Complete.
- Next recommended: Story 004 Attack Phase Execution + Collision Adapter — production/epics/ai-framework/story-004-attack-phase-execution-collision-adapter.md

## Session Extract — /dev-story + /story-done 2026-06-23 (ai-framework story-004)
- Verdict: COMPLETE
- Story: production/epics/ai-framework/story-004-attack-phase-execution-collision-adapter.md — Attack Phase Execution + Collision Adapter
- Implementation: Extended `src/core/ai_component.gd` with duck-typed Collision adapter injection, `start_attack()`, deterministic attack phase/frame query APIs, frame advancement, startup/active/recovery lifecycle execution, exact startup-boundary hitbox activation, attack metadata forwarding, safe missing-adapter behavior, and startup interruption into STUN without late activation.
- TDD evidence: RED first failed on missing attack execution and Collision adapter APIs (`reports/report_200/`); GREEN Story004 suite 5/5 passing (`reports/report_201/`).
- Tests: AI suite 19/19 passing (`reports/report_202/`); full `tests/unit` 216/216 passing (`reports/report_203/`).
- Runtime evidence: `godot --headless --path . --quit` passing; main scene smoke `reports/ai_story004_main_scene_smoke.log` passing with `[godot_ai game_helper] registered mcp capture` in logs.
- Static evidence: `git diff --check`, trailing-whitespace scan, and changed-method length scan passed.
- Review: Local review passed against ADR-0004, ADR-0006, Core control manifest, TR-ai-007, TR-ai-008, and Story004 test evidence. Specialist QA/LP gates were not spawned because no multi-agent delegation tool was exposed in this thread.
- Tech debt logged: None.
- Epic status: AI Framework remains In Progress; Stories 001-004 are Complete.
- Next recommended: Story 005 Boss Phase + Focus Mode Signal Integration — production/epics/ai-framework/story-005-boss-phase-focus-mode-signal-integration.md

## Session Extract — /dev-story + /story-done 2026-06-23 (ai-framework story-005)
- Verdict: COMPLETE
- Story: production/epics/ai-framework/story-005-boss-phase-focus-mode-signal-integration.md — Boss Phase + Focus Mode Signal Integration
- Implementation: Extended `src/core/ai_component.gd` with entity-id filtering, HealthComponent-compatible focus/boss signal adapter wiring, legacy bool-only focus signal compatibility, focus-mode windup extension state, per-attack effective startup freezing, boss phase tracking, and phase-specific future attack pattern set selection.
- TDD evidence: RED first failed on missing Story005 entity/signal/focus/boss APIs (`reports/report_204/`); GREEN Story005 suite 5/5 passing (`reports/report_205/`).
- Tests: AI suite 24/24 passing (`reports/report_206/`); full `tests/unit` 221/221 passing (`reports/report_207/`).
- Runtime evidence: `godot --headless --path . --quit` passing; main scene smoke `reports/ai_story005_main_scene_smoke.log` passing with `[godot_ai game_helper] registered mcp capture` in logs.
- Static evidence: `git diff --check`, trailing-whitespace scan, and changed-method length scan passed.
- Review: Local review passed against ADR-0002, ADR-0006, Core control manifest, TR-ai-004, TR-ai-005, and Story005 test evidence. Specialist QA/LP gates were not spawned because no multi-agent delegation tool was exposed in this thread.
- Tech debt logged: None.
- Epic status: AI Framework remains In Progress; Stories 001-005 are Complete.
- Next recommended: Story 006 Low-HP Adaptation + Weighted Attack Selection — production/epics/ai-framework/story-006-low-hp-adaptation-weighted-attack-selection.md

## Session Extract — /dev-story + /story-done 2026-06-23 (ai-framework story-006)
- Verdict: COMPLETE
- Story: production/epics/ai-framework/story-006-low-hp-adaptation-weighted-attack-selection.md — Low-HP Adaptation + Weighted Attack Selection
- Implementation: Extended `src/core/ai_component.gd` with HealthComponent-compatible HP percentage querying, configurable low-HP flee/berserk thresholds, FLEE transitions from combat states, berserk 1.2 attack-speed timing for future attacks, phase/hp attack weight modifiers, clamped selection weights, and deterministic roll-injected weighted pattern selection.
- TDD evidence: RED first failed on missing Story006 low-HP and weighted selection APIs (`reports/report_208/`); GREEN Story006 suite 5/5 passing (`reports/report_209/`).
- Tests: AI suite 29/29 passing (`reports/report_210/`); full `tests/unit` 226/226 passing (`reports/report_211/`).
- Runtime evidence: `godot --headless --path . --quit` passing; main scene smoke `reports/ai_story006_main_scene_smoke.log` passing with `[godot_ai game_helper] registered mcp capture` in logs.
- Static evidence: `git diff --check`, trailing-whitespace scan, and changed-method length scan passed.
- Review: Local review passed against ADR-0006, Core control manifest, TR-ai-009, TR-ai-010, and Story006 test evidence. Specialist QA/LP gates were not spawned because no multi-agent delegation tool was exposed in this thread.
- Tech debt logged: None.
- Epic status: AI Framework Core scope complete; `production/epics/ai-framework/EPIC.md` and `production/epics/index.md` now mark the epic Complete.
- Next recommended: choose a downstream integration epic that consumes AI behavior, such as Boss Configuration, Combat Presentation, Audio, HUD/UI, or enemy tuning integration.

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (boss-config story-002)
- Verdict: COMPLETE
- Story: production/epics/boss-config/story-002-phase-transition-adapter-invulnerability-window.md — Phase Transition Adapter + Invulnerability Window
- Implementation: Extended `src/core/boss_config_component.gd` with AIComponent-compatible adapter injection, HealthComponent-compatible `on_boss_phase_change` typed signal wiring, entity-id filtering, queued phase transitions, AI attack completion gating, 2.5 second transition invulnerability, current phase queries, and phase pattern/speed application to AI adapters. Story001 data-loading APIs remain intact and config reloads reset only transition runtime state, not injected adapters.
- TDD evidence: RED first failed on missing Story002 APIs (`set_ai_adapter`, `set_health_adapter`, `set_entity_id`, transition queries) in `reports/report_221/`; GREEN boss suite 10/10 passing in `reports/report_225/`.
- Tests: full `tests/unit` 236/236 passing (`reports/report_226/`); `git diff --check`, trailing-whitespace scan, changed-method length scan, and 100-character scan passed for the changed files.
- Runtime evidence: `godot --headless --path . --quit` passed; main scene smoke with `res://scenes/main.tscn` passed; both logs show `[godot_ai game_helper] registered mcp capture` and no error/warning matches in `reports/boss_story002_project_boot.log` or `reports/boss_story002_main_scene_smoke.log`.
- Review: Local lead-programmer review passed against ADR-0002, ADR-0006, Control Manifest, TR-boss-002, and Story002 traceability. Full specialist gates were not spawned because no Task gate was exposed in this thread.
- Tech debt logged: None.
- Epic status: Boss Configuration is In Progress; Stories 001-002 are Complete.
- Next recommended: Story 003 Phase 2 Summon Scheduling + Death Cleanup Hooks — production/epics/boss-config/story-003-phase-2-summon-scheduling-death-cleanup-hooks.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (boss-config story-003)
- Verdict: COMPLETE
- Story: production/epics/boss-config/story-003-phase-two-summon-scheduling-death-cleanup-hooks.md — Phase 2 Summon Scheduling + Death Cleanup Hooks
- Implementation: Extended `src/core/boss_config_component.gd` with a data-driven `summon_rules` runtime path, summon adapter injection, deterministic `advance_time()` scheduling, active-summon cap checks, phase-exit timer reset, and idempotent boss-death summon cleanup. Updated `data/combat/boss_configs.json` and `data/schemas/boss_configs.schema.json` so Rat King summon timing, summon id, phase id, and max active count are validated through the Boss config data pipeline.
- TDD evidence: RED first failed on missing `set_summon_adapter()` in `reports/report_227/`; RED data-driven refinement failed because the scheduler ignored custom `summon_rules` in `reports/report_233/`; GREEN Boss suite 15/15 passing in `reports/report_236/`.
- Tests: full `tests/unit` 241/241 passing (`reports/report_237/`); `git diff --check`, trailing-whitespace scan, and 100-character scan passed for related source, test, schema, and JSON files.
- Runtime evidence: `godot --headless --path . --quit` passed; main scene smoke with `res://scenes/main.tscn` passed. `reports/boss_story003_project_boot.log` and `reports/boss_story003_main_scene_smoke.log` show `[godot_ai game_helper] registered mcp capture` and no error/warning matches.
- Review: Local lead-programmer review passed against AGENTS.md, ADR-0006, Control Manifest, TR-boss-003, and Story003 traceability. Full specialist gates were not spawned because the active Codex multi-agent tool policy requires an explicit user request for delegation.
- Tech debt logged: None.
- Epic status: Boss Configuration is In Progress; Stories 001-003 are Complete.
- Next recommended: Story 004 Phase Arena Change Adapter + Scene Lock Hooks — production/epics/boss-config/story-004-arena-change-adapter-scene-lock-hooks.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (boss-config story-004)
- Verdict: COMPLETE
- Story: production/epics/boss-config/story-004-arena-change-adapter-scene-lock-hooks.md — Arena Change Adapter + Scene Lock Hooks
- Implementation: Extended `src/core/boss_config_component.gd` with a SceneManager-compatible scene adapter, idempotent `start_boss_encounter()` scene locking, phase-transition arena-change dispatch using configured `arena_changes`, and boss-death scene unlock. The component still does not instantiate obstacle or damage-zone scenes; it only forwards data to the adapter boundary required by ADR-0007.
- TDD evidence: RED first failed on missing Story004 scene adapter APIs (`reports/report_238/`); GREEN Boss suite 19/19 passing (`reports/report_239/`).
- Tests: full `tests/unit` 245/245 passing (`reports/report_240/`); static checks passed for diff formatting, trailing whitespace, and source/test 100-character limits.
- Runtime evidence: `godot --headless --path . --quit` passed; main scene smoke with `res://scenes/main.tscn` passed. `reports/boss_story004_project_boot.log` and `reports/boss_story004_main_scene_smoke.log` show `[godot_ai game_helper] registered mcp capture` and no error/warning matches. No direct Godot MCP run/screenshot tool is exposed in this Codex session, so validation used Godot CLI/headless fallback after confirming MCP capture registration.
- Review: Local review passed against AGENTS.md, ADR-0007, Control Manifest Core/SceneManager rules, TR-boss-004, and Story004 traceability. Full specialist gates were not spawned because the active Codex multi-agent tool policy requires an explicit user request for delegation.
- Tech debt logged: None.
- Epic status: Boss Configuration is In Progress; Stories 001-004 are Complete.
- Next recommended: Story 005 Desperation Defense + Defeat Reward Dispatch — production/epics/boss-config/story-005-desperation-defense-defeat-reward-dispatch.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (boss-config story-005)
- Verdict: COMPLETE
- Story: production/epics/boss-config/story-005-desperation-defense-defeat-reward-dispatch.md — Desperation Defense + Defeat Reward Dispatch
- Implementation: Extended `src/core/boss_config_component.gd` with data-driven `desperation_rules`, `get_defense_modifier()`, reward adapter injection, HP-percentage querying via HealthComponent-compatible adapters, and idempotent defeat reward dispatch for ability unlock, currency, and skill points. Updated `data/combat/boss_configs.json` and `data/schemas/boss_configs.schema.json` so the phase 3 threshold and defense modifier live in the Boss config data pipeline.
- TDD evidence: RED first failed on missing Story005 defense/reward adapter APIs (`reports/report_241/`); GREEN Boss suite 23/23 passing (`reports/report_242/`).
- Tests: full `tests/unit` 249/249 passing (`reports/report_243/`); static checks passed for diff formatting, trailing whitespace, and source/test/schema/JSON 100-character limits.
- Runtime evidence: `godot --headless --path . --quit` passed; main scene smoke with `res://scenes/main.tscn` passed. `reports/boss_story005_project_boot.log` and `reports/boss_story005_main_scene_smoke.log` show `[godot_ai game_helper] registered mcp capture` and no error/warning matches. No direct Godot MCP run/screenshot tool is exposed in this Codex session, so validation used Godot CLI/headless fallback after confirming MCP capture registration.
- Review: Local review passed against AGENTS.md, ADR-0002, ADR-0003, Control Manifest Core/Data rules, TR-boss-006, TR-boss-007, and Story005 traceability. Full specialist gates were not spawned because the active Codex multi-agent tool policy requires an explicit user request for delegation.
- Tech debt logged: None. Known remaining Boss epic gap: TR-boss-005 still needs Boss-specific parry immunity coverage.
- Epic status: Boss Configuration remains In Progress; Stories 001-005 are Complete, but TR-boss-005 is not covered by a Boss story.
- Next recommended: create a follow-up Boss story for TR-boss-005 — Boss parry outcome deals 5.0x damage without entering STUN.

## Session Extract — /create-stories + /dev-story + /code-review + /story-done 2026-06-23 (boss-config story-006)
- Verdict: COMPLETE
- Story: production/epics/boss-config/story-006-boss-parry-damage-stun-immunity.md — Boss Parry Damage + STUN Immunity
- Implementation: Added data-driven `parry_rules` to `data/combat/boss_configs.json` and `data/schemas/boss_configs.schema.json`, then extended `src/core/boss_config_component.gd` with `resolve_parry_outcome(parry_type)` so successful Boss parries expose a 5.0 damage multiplier while suppressing STUN entry. Missed and non-parry outcomes return neutral metadata.
- TDD evidence: RED first failed on missing `resolve_parry_outcome()` (`reports/report_244/`); GREEN Boss suite 27/27 passing (`reports/report_245/`).
- Tests: full `tests/unit` 253/253 passing (`reports/report_246/`); static checks passed for diff formatting, trailing whitespace, and source/test/schema/JSON 100-character limits.
- Runtime evidence: `godot --headless --path . --quit` passed; main scene smoke with `res://scenes/main.tscn` passed. `reports/boss_story006_project_boot.log` and `reports/boss_story006_main_scene_smoke.log` show `[godot_ai game_helper] registered mcp capture` and no error/warning matches. No direct Godot MCP run/screenshot tool is exposed in this Codex session, so validation used Godot CLI/headless fallback after confirming MCP capture registration.
- Review: Local review passed against AGENTS.md, ADR-0005, ADR-0003, Control Manifest Core/Data rules, TR-boss-005, and Story006 traceability. Full specialist gates were not spawned because the active Codex multi-agent tool policy requires an explicit user request for delegation.
- Tech debt logged: None.
- Epic status: Boss Configuration Core scope complete; `production/epics/boss-config/EPIC.md` and `production/epics/index.md` now mark the epic Complete.
- Next recommended: choose a downstream consumer epic for Boss parry metadata, such as StatusEffect/AI STUN integration, Combat Presentation, HUD/UI, Ability, Save, or progression reward consumption.

## Session Extract — /project-stage-detect + /create-epics + /create-stories 2026-06-23 (status-effects)
- Verdict: COMPLETE
- Epic: production/epics/status-effects/EPIC.md — Status Effects
- Planning: Scanned remaining GDD/Epic coverage after Boss Configuration completed. Existing production epics covered Foundation and early Core systems, while `design/gdd/status-effects.md` still lacked an epic despite downstream Boss STUN immunity needs.
- Created Status Effects epic plus six stories mapping TR-status-001 through TR-status-006: catalog, application/immunity, duration/tick/modifiers, i-frame immunity, priority/capacity, and death/scene cleanup.
- Governing ADRs: ADR-0001, ADR-0002, ADR-0003, ADR-0005, ADR-0017, and ADR-0019.
- Review: Producer/specialist gates were not spawned even though `production/review-mode.txt` is `full`, because the active Codex multi-agent tool policy requires an explicit user request for delegation.
- Epic status: Status Effects is Ready with six Ready stories.
- Next recommended: Story 001 StatusEffectComponent + Effect Catalog — production/epics/status-effects/story-001-status-effect-component-effect-catalog.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (status-effects story-001)
- Verdict: COMPLETE
- Story: production/epics/status-effects/story-001-status-effect-component-effect-catalog.md — StatusEffectComponent + Effect Catalog
- Implementation: Added `src/core/status_effect_component.gd` as a Core scene component with the seven GDD effect ids, effect category metadata, durations, priorities, DoT values, movement/damage modifiers, defensive active-effect queries, and default max effects of 5. Added status tuning entries to `data/tuning_knobs.json` and `data/schemas/tuning_knobs.schema.json`.
- TDD evidence: RED first failed on missing `StatusEffectComponent` (`reports/report_247/`); GREEN Story001 suite 5/5 passing (`reports/report_252/`).
- Tests: status suite 5/5 passing (`reports/report_250/`); full `tests/unit` 258/258 passing (`reports/report_253/`); static checks passed for diff formatting, trailing whitespace, and source/test/schema/JSON 100-character limits.
- Runtime evidence: `godot --headless --path . --quit` passed; main scene smoke with `res://scenes/main.tscn` passed. `reports/status_story001_project_boot.log` and `reports/status_story001_main_scene_smoke.log` show `[godot_ai game_helper] registered mcp capture` and no error/warning matches. No direct Godot MCP run/screenshot tool is exposed in this Codex session, so validation used Godot CLI/headless fallback after confirming MCP capture registration.
- Review: Local review passed against AGENTS.md, ADR-0001, ADR-0003, ADR-0017, Control Manifest Core rules, TR-status-001, and Story001 traceability. Full specialist gates were not spawned because the active Codex multi-agent tool policy requires an explicit user request for delegation.
- Tech debt logged: None.
- Epic status: Status Effects is In Progress; Story001 is Complete.
- Next recommended: Story 002 Status Application + Boss STUN Immunity — production/epics/status-effects/story-002-status-application-boss-stun-immunity.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (status-effects story-002)
- Verdict: COMPLETE
- Story: production/epics/status-effects/story-002-status-application-boss-stun-immunity.md — Status Application + Boss STUN Immunity
- Implementation: Extended `src/core/status_effect_component.gd` with `status_applied(target_id, effect_id)`, entity configuration, `apply_status()`, `has_status()`, `get_remaining_duration()`, active effect metadata, same-effect refresh without duplicates, and Boss immunity for `stun` while preserving non-Boss STUN application.
- TDD evidence: RED first failed on missing `status_applied` (`reports/report_254/`); GREEN Story002 suite 5/5 passing (`reports/report_255/`).
- Tests: status suite 10/10 passing (`reports/report_256/`); full `tests/unit` 263/263 passing (`reports/report_257/`); static checks passed for diff formatting, trailing whitespace, and source/test 100-character limits.
- Runtime evidence: `godot --headless --path . --quit` passed; main scene smoke with `res://scenes/main.tscn` passed. `reports/status_story002_project_boot.log` and `reports/status_story002_main_scene_smoke.log` show `[godot_ai game_helper] registered mcp capture` and no error/warning matches. No direct Godot MCP run/screenshot tool is exposed in this Codex session, so validation used Godot CLI/headless fallback after confirming MCP capture registration.
- Review: Local review passed against AGENTS.md, ADR-0002, ADR-0017, Control Manifest Core rules, TR-status-002, TR-boss-005, and Story002 traceability. Full specialist gates were not spawned because the active Codex multi-agent tool policy requires an explicit user request for delegation.
- Tech debt logged: None.
- Epic status: Status Effects is In Progress; Stories 001-002 are Complete.
- Next recommended: Story 003 Duration Tick + Modifier Queries — production/epics/status-effects/story-003-duration-tick-modifier-queries.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (status-effects story-003)
- Verdict: COMPLETE
- Story: production/epics/status-effects/story-003-duration-tick-modifier-queries.md — Duration Tick + Modifier Queries
- Implementation: Extended `src/core/status_effect_component.gd` with `status_expired(target_id, effect_id)`, HealthComponent-compatible `set_health_adapter()`, deterministic `advance_time(delta_seconds)`, 1.0-second DoT tick accumulation for poison and burn through `apply_damage()`, multiplicative movement/damage modifier queries, and refresh-time DoT tick reset.
- TDD evidence: RED first failed on missing Story003 duration/tick/modifier APIs (`reports/report_258/`); GREEN Story003 suite 5/5 passing (`reports/report_259/`).
- Tests: status suite 15/15 passing (`reports/report_260/`); full `tests/unit` 268/268 passing (`reports/report_261/`); static checks passed for diff formatting, trailing whitespace, and source/test 100-character limits.
- Runtime evidence: `godot --headless --path . --quit` passed; main scene smoke with `res://scenes/main.tscn` passed. `reports/status_story003_project_boot.log` and `reports/status_story003_main_scene_smoke.log` show `[godot_ai game_helper] registered mcp capture` and no error/warning matches. No direct Godot MCP run/screenshot tool is exposed in this Codex session, so validation used Godot CLI/headless fallback after confirming MCP capture registration.
- Review: Local review passed against AGENTS.md, ADR-0017, ADR-0019, Control Manifest Core rules, TR-status-003, and Story003 traceability. Full specialist sub-agent gates were not spawned because the active Codex multi-agent tool policy requires an explicit user request for delegation.
- Tech debt logged: None.
- Epic status: Status Effects is In Progress; Stories 001-003 are Complete.
- Next recommended: Story 004 I-frame + Invincible Debuff Immunity — production/epics/status-effects/story-004-iframe-invincible-debuff-immunity.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (status-effects story-004)
- Verdict: COMPLETE
- Story: production/epics/status-effects/story-004-iframe-invincible-debuff-immunity.md — I-frame + Invincible Debuff Immunity
- Implementation: Extended `src/core/status_effect_component.gd` so debuffs are rejected while a Health-compatible adapter reports invulnerability or active `invincible` is present. Buffs remain valid during i-frames. Adapter compatibility covers `is_invincible()`, `is_invulnerable()`, `is_invulnerable_to_damage()`, and `get_iframe_remaining()`. Applying `invincible` optionally dispatches 30 i-frames through `grant_iframes()`.
- TDD evidence: RED first failed because `poison` still applied during Health adapter i-frames (`reports/report_262/`); GREEN Story004 suite 4/4 passing (`reports/report_263/`).
- Tests: status suite 19/19 passing (`reports/report_264/`); full `tests/unit` 272/272 passing (`reports/report_265/`); static checks passed for diff formatting, trailing whitespace, and source/test 100-character limits.
- Runtime evidence: `godot --headless --path . --quit` passed; main scene smoke with `res://scenes/main.tscn` passed. `reports/status_story004_project_boot.log` and `reports/status_story004_main_scene_smoke.log` show `[godot_ai game_helper] registered mcp capture` and no error/warning matches. No direct Godot MCP run/screenshot tool is exposed in this Codex session, so validation used Godot CLI/headless fallback after confirming MCP capture registration.
- Review: Local review passed against AGENTS.md, ADR-0017, ADR-0019, Control Manifest Core rules, TR-status-004, and Story004 traceability. Full specialist sub-agent gates were not spawned because the active Codex multi-agent tool policy requires an explicit user request for delegation.
- Tech debt logged: None.
- Epic status: Status Effects is In Progress; Stories 001-004 are Complete.
- Next recommended: Story 005 Effect Priority + Capacity Eviction — production/epics/status-effects/story-005-effect-priority-capacity-eviction.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (status-effects story-005)
- Verdict: COMPLETE
- Story: production/epics/status-effects/story-005-effect-priority-capacity-eviction.md — Effect Priority + Capacity Eviction
- Implementation: Extended `src/core/status_effect_component.gd` so full status capacity evicts the oldest active effect instead of rejecting the sixth distinct effect. Eviction emits `status_expired(target_id, effect_id)`, then the new effect is appended, preserving deterministic insertion ordering. Priority metadata remains aligned with GDD order for consumers.
- TDD evidence: RED first failed because the sixth distinct effect returned false (`reports/report_266/`); GREEN Story005 suite 3/3 passing (`reports/report_267/`).
- Tests: status suite 22/22 passing (`reports/report_268/`); full `tests/unit` 275/275 passing (`reports/report_269/`); static checks passed for diff formatting, trailing whitespace, and source/test 100-character limits.
- Runtime evidence: `godot --headless --path . --quit` passed; main scene smoke with `res://scenes/main.tscn` passed. `reports/status_story005_project_boot.log` and `reports/status_story005_main_scene_smoke.log` show `[godot_ai game_helper] registered mcp capture` and no error/warning matches. No direct Godot MCP run/screenshot tool is exposed in this Codex session, so validation used Godot CLI/headless fallback after confirming MCP capture registration.
- Review: Local review passed against AGENTS.md, ADR-0017, Control Manifest Core rules, TR-status-005, and Story005 traceability. Full specialist sub-agent gates were not spawned because the active Codex multi-agent tool policy requires an explicit user request for delegation.
- Tech debt logged: None.
- Epic status: Status Effects is In Progress; Stories 001-005 are Complete.
- Next recommended: Story 006 Death + Scene Cleanup Hooks — production/epics/status-effects/story-006-death-scene-cleanup-hooks.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (status-effects story-006)
- Verdict: COMPLETE
- Story: production/epics/status-effects/story-006-death-scene-cleanup-hooks.md — Death + Scene Cleanup Hooks
- Implementation: Extended `src/core/status_effect_component.gd` with idempotent `clear_all_effects()`, HealthComponent-compatible `on_death` wiring through `set_health_adapter()`, owner-entity filtering for death cleanup, SceneManager-compatible `set_scene_adapter()` transition cleanup wiring, and public `handle_scene_transition_cleanup()` for explicit transition hooks.
- TDD evidence: RED first failed because owner death did not clear active effects (`reports/report_270/`); GREEN Story006 suite 4/4 passing (`reports/report_271/`).
- Tests: status suite 26/26 passing (`reports/report_272/`); full `tests/unit` 279/279 passing (`reports/report_273/`); static checks passed for diff formatting, trailing whitespace, and source/test 100-character limits.
- Runtime evidence: `godot --headless --path . --quit` passed; main scene smoke with `res://scenes/main.tscn` passed. `reports/status_story006_project_boot.log` and `reports/status_story006_main_scene_smoke.log` show `[godot_ai game_helper] registered mcp capture` and no error/warning matches. No direct Godot MCP run/screenshot tool is exposed in this Codex session, so validation used Godot CLI/headless fallback after confirming MCP capture registration.
- Review: Local review passed against AGENTS.md, ADR-0002, ADR-0007, ADR-0017, Control Manifest Core/SceneManager rules, TR-status-006, and Story006 traceability. Full specialist sub-agent gates were not spawned because the active Codex multi-agent tool policy requires an explicit user request for delegation.
- Tech debt logged: None.
- Epic status: Status Effects Core scope complete; `production/epics/status-effects/EPIC.md` and `production/epics/index.md` now mark the epic Complete.
- Next recommended: choose a downstream consumer epic, such as HUD/UI status icons, Weapon Styles status application, Combat/AI STUN consumption, SceneManager implementation, or combat presentation VFX/audio.

## Session Extract — /create-epics + /create-stories 2026-06-23 (weapon-styles)
- Verdict: IN PROGRESS
- Epic: production/epics/weapon-styles/EPIC.md — Weapon Styles
- Planning: Chose Weapon Styles as the next Core MVP system after Status Effects
  because it consumes Combat, DamageCalculator, Collision, Health, and Status
  boundaries already implemented in earlier epics.
- Created eight stories mapping TR-weapon-001 through TR-weapon-007: config
  catalog, upgrade serialization prep, swap state machine, special attack gates,
  Cat Claw crit bonus, Long Tail multi-target contract, Fish Bone shield break,
  and Electro Bell slow application.
- Governing ADRs: ADR-0001, ADR-0002, ADR-0003, ADR-0004, ADR-0005, ADR-0016,
  ADR-0017, and ADR-0019.
- Review: Producer/specialist gates were not spawned even though
  `production/review-mode.txt` is `full`, because the active Codex multi-agent
  tool policy requires an explicit user request for delegation.
- Next active story: Story 001 Weapon Config Catalog + Base Damage Query —
  production/epics/weapon-styles/story-001-weapon-config-catalog-base-damage-query.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (weapon-styles story-001)
- Verdict: COMPLETE
- Story: production/epics/weapon-styles/story-001-weapon-config-catalog-base-damage-query.md — Weapon Config Catalog + Base Damage Query
- Implementation: Added `src/core/weapon_config.gd` and `src/core/weapon_component.gd`
  with DataManager-backed weapon config loading, four canonical weapon ids,
  current weapon query, attack-parameter snapshot, level-indexed base damage, and
  Cat Claw level-3 damage query support. Added weapon config JSON/schema and
  registered the `weapon_configs` domain in `data/manifest.json`.
- TDD evidence: RED first failed on missing WeaponComponent and WeaponConfig
  (`reports/report_274/`); GREEN Story001 suite 5/5 passing (`reports/report_276/`).
- Tests: weapon suite 5/5 passing (`reports/report_277/`); full `tests/unit`
  284/284 passing (`reports/report_278/`).
- Runtime evidence: `godot --headless --path . --quit` passed; main scene smoke
  with `res://scenes/main.tscn` passed. `reports/weapon_story001_project_boot.log`
  and `reports/weapon_story001_main_scene_smoke.log` show `[godot_ai game_helper]
  registered mcp capture` and no error/warning matches. No direct Godot MCP
  run/screenshot tool is exposed in this Codex session, so validation used
  Godot CLI/headless fallback after confirming MCP capture registration.
- Static evidence: `git diff --check`, trailing-whitespace scan, and source/test
  100-character scan passed.
- Review: Local review passed against AGENTS.md, ADR-0003, ADR-0016, Control
  Manifest Core/Data rules, TR-weapon-001, TR-weapon-004, and Story001
  traceability. Full specialist gates were not spawned because the active Codex
  multi-agent tool policy requires an explicit user request for delegation.
- Tech debt logged: None.
- Epic status: Weapon Styles is In Progress; Story001 is Complete.
- Next recommended: Story 002 Weapon Upgrade State + Serialization Prep —
  production/epics/weapon-styles/story-002-weapon-upgrade-state-serialization-prep.md

## Session Extract — /dev-story + /code-review + /story-done 2026-06-23 (weapon-styles story-002)
- Verdict: COMPLETE
- Story: production/epics/weapon-styles/story-002-weapon-upgrade-state-serialization-prep.md — Weapon Upgrade State + Serialization Prep
- Implementation: Extended `src/core/weapon_component.gd` with weapon upgrade
  increments, next-level damage previews, player-facing upgrade signal levels,
  SaveSystem-compatible `serialize()` payloads, and defensive `deserialize()`
  handling for current weapon index, level clamps, unknown weapon ids, and missing
  level entries.
- TDD evidence: RED first failed on missing Story002 upgrade/serialization APIs
  (`reports/report_279/`); GREEN Story002 suite 5/5 passing (`reports/report_281/`).
- Tests: weapon suite 10/10 passing (`reports/report_282/`); full `tests/unit`
  289/289 passing (`reports/report_283/`).
- Runtime evidence: `godot --headless --path . --quit` passed; main scene smoke
  with `res://scenes/main.tscn` passed. `reports/weapon_story002_project_boot.log`
  and `reports/weapon_story002_main_scene_smoke.log` show `[godot_ai game_helper]
  registered mcp capture` and no error/warning matches. No direct Godot MCP
  run/screenshot tool is exposed in this Codex session, so validation used
  Godot CLI/headless fallback after confirming MCP capture registration.
- Static evidence: `git diff --check`, trailing-whitespace scan, and source/test
  100-character scan passed.
- Review: Local review passed against AGENTS.md, ADR-0016, Control Manifest Core
  rules, TR-weapon-004, and Story002 traceability. Full specialist gates were not
  spawned because the active Codex multi-agent tool policy requires an explicit
  user request for delegation.
- Tech debt logged: None.
- Epic status: Weapon Styles is In Progress; Stories 001-002 are Complete.
- Next recommended: Story 003 Weapon Swap State Machine + Combat Adapter —
  production/epics/weapon-styles/story-003-weapon-swap-state-machine-combat-adapter.md

## Session Extract — Runtime Visual Slice 2026-06-23
- Scope: Main scene presentation pass to move the current prototype from block
  visuals toward a playable game slice.
- Files changed: `src/presentation/hud_manager.gd`,
  `tests/unit/presentation/hud_manager_test.gd`, `src/gameplay/main_scene.gd`,
  `src/gameplay/player_controller.gd`, `src/gameplay/simple_enemy.gd`,
  `scenes/main.tscn`, `scenes/player.tscn`, generated visual assets under
  `assets/generated/`.
- Implementation: Runtime HUD with player HP, target HP, weapon status, gear
  count, and notifications; player HealthComponent hookup; enemy HP/defeat
  signals; contact damage cooldown.
- Evidence: HUD focused suite `reports/report_289/` 3/3 passing;
  `godot --headless --path . --quit` passed; Godot MCP screenshot
  `reports/visual/cinderpaw-mcp-hud-vertical-slice-20260623.png`.
- Next recommended: Combat Presentation vertical slice — hit particles, damage
  numbers, hitstop/screen shake, and clearer defeat/retry flow.

## Session Extract — Combat Presentation Slice + README 2026-06-23
- Scope: Add first runtime combat-feedback layer and rewrite README as a project
  introduction instead of workflow/template documentation.
- Files changed: `src/presentation/combat_presentation.gd`,
  `tests/unit/presentation/combat_presentation_test.gd`,
  `src/gameplay/main_scene.gd`, `src/gameplay/player_controller.gd`,
  `scenes/main.tscn`, `README.md`,
  `production/qa/evidence/hud-vertical-slice-2026-06-23.md`.
- Implementation: Normal/crit/kill feedback model with damage numbers, sparks,
  debris, hitstop counters, screen shake; player attack events now feed combat
  presentation; first enemy moved to a reachable ground position for the opening
  combat loop.
- Evidence: RED first failed on missing `CombatPresentation`; GREEN focused
  combat suite `reports/report_290/` 4/4 passing; presentation suite
  `reports/report_292/` 7/7 passing; `godot --headless --path . --quit`
  passed; Godot MCP input simulation captured
  `reports/visual/cinderpaw-mcp-combat-feedback-20260623.png`.
- Upload intent: User requested code upload and README cleanup; prepare commit
  and push to `origin/master` after validation.

## Session Extract — Game Flow Vertical Slice 2026-06-23
- Scope: Add the first runtime encounter loop on top of the visual/combat slice.
- Files changed: `src/gameplay/game_flow_controller.gd`,
  `tests/unit/gameplay/game_flow_controller_test.gd`,
  `src/gameplay/main_scene.gd`, `src/gameplay/player_controller.gd`,
  `scenes/main.tscn`, and QA evidence under `production/qa/evidence/`.
- Implementation: Added `GameFlowController` for `playing`, `dying`,
  `revived`, and `victory` states; death waits 1.5 seconds before half-HP
  respawn; revived state locks player control for 2 seconds; victory hides boss
  HP, grants 25 gears, and locks player input.
- Evidence: RED first failed on missing `GameFlowController`; GREEN focused
  game-flow suite `reports/report_295/` 3/3 passing; Godot startup parse check
  passed with `godot --headless --path . --quit`; Godot MCP runtime session
  `cinderpaw@c4d7` drove victory via keyboard input and verified death/respawn
  via runtime node calls.
- Visual evidence:
  `reports/visual/cinderpaw-mcp-game-flow-initial-20260623.png`,
  `reports/visual/cinderpaw-mcp-game-flow-victory-20260623.png`, and
  `reports/visual/cinderpaw-mcp-game-flow-respawn-20260623.png`.
- Runtime state evidence: victory reached `flow=victory`, enemy removed, boss HP
  hidden, gears `25`; respawn reached `flow=revived`, HP `50/100`, then
  returned to `flow=playing` with input unlocked.
- Next recommended: formal pause/retry/menu route plus final death/victory
  animation and audio beats.

## Session Extract — Pause/Retry Menu Vertical Slice 2026-06-24
- Scope: Add the first formal pause and retry route around the current playable
  scene, guided by `design/gdd/hud-ui.md`, `design/gdd/death-respawn.md`, and
  ADR-0011. No formal HUD/UI or death-respawn epic exists yet, so this is
  recorded as a vertical-slice implementation rather than a story close-out.
- Files changed: `src/presentation/hud_manager.gd`,
  `tests/unit/presentation/hud_manager_test.gd`, `src/gameplay/main_scene.gd`,
  `production/qa/evidence/hud-vertical-slice-2026-06-23.md`, and
  `production/qa/evidence/pause-retry-menu-vertical-slice-2026-06-24.md`.
- Implementation: HUDManager now exposes pause/resume/retry menu signals,
  builds a darkened focusable menu overlay, gives Resume/Continue keyboard focus,
  and supports pause and victory retry modes. Main scene listens to HUD signals
  to pause/resume `SceneTree` and reload the encounter on Retry.
- TDD evidence: RED first failed on missing HUD menu APIs/signals; presentation
  regression `reports/report_299/` 10/10 passing.
- Runtime evidence: Godot startup parse check passed; Godot MCP session
  `cinderpaw@c4d7` verified Esc pause (`paused=true`, menu mode `pause`,
  focused `Resume`), Esc resume, victory retry menu, and Retry scene reload.
- Visual evidence:
  `reports/visual/cinderpaw-mcp-pause-menu-20260624.png` and
  `reports/visual/cinderpaw-mcp-victory-retry-menu-20260624.png`.
- Next recommended: generate formal HUD/UI or death-respawn epics/stories, then
  add settings/save-load/main menu and final death-summary UI/audio.

## Session Extract — HUD/Death Formalization + Battle Summary 2026-06-24
- Scope: Convert the HUD/UI and Death & Respawn vertical slices into formal
  Epic/Story tracking, then close the first battle-summary lesson panel story.
- Files changed: `production/epics/index.md`,
  `production/epics/hud-ui/`, `production/epics/death-respawn/`,
  `src/presentation/hud_manager.gd`, `tests/unit/presentation/hud_manager_test.gd`,
  `src/gameplay/player_controller.gd`, `src/gameplay/main_scene.gd`, and
  QA evidence under `production/qa/evidence/`.
- Implementation: HUDManager now supports `show_battle_summary(summary)` with
  formatted duration/damage/dodge/parry data, default tip generation, and
  `Skip Lesson`/`Retry Encounter` actions. PlayerController forwards
  HealthComponent death metadata to MainScene; MainScene keeps battle summary
  default-off until settings controls are implemented.
- Epic status: Added HUD/UI Epic (6 stories, 3 complete) and Death & Respawn
  Epic (6 stories, 2 complete). Both are now indexed as In Progress.
- TDD evidence: RED first failed on missing battle-summary HUD APIs
  (`reports/report_300/`); GREEN HUD focused suite 8/8 passing
  (`reports/report_301/`).
- Regression evidence: presentation + gameplay focused suites 15/15 passing
  (`reports/report_302/`); `godot --headless --path . --quit` passing;
  `git diff --check` passing.
- Runtime evidence: Godot MCP session `cinderpaw@c4d7` ran
  `res://scenes/main.tscn`, reported a 54-node runtime tree, opened
  `battle_summary` via `game_eval`, and logged no game runtime errors.
- Visual evidence:
  `reports/visual/cinderpaw-mcp-battle-summary-20260624.png`.
- Next recommended: Death & Respawn Story 002 respawn invincibility visual
  feedback, or HUD/UI Story 004 settings/accessibility controls to enable the
  battle-summary toggle from UI.

## Session Extract — Respawn Invincibility Visual Feedback 2026-06-24
- Scope: Implement Death & Respawn Story 002, covering `TR-respawn-007`
  revive invincibility visual feedback.
- Files changed: `src/gameplay/player_controller.gd`,
  `tests/unit/gameplay/player_respawn_visual_feedback_test.gd`,
  `production/epics/death-respawn/EPIC.md`,
  `production/epics/death-respawn/story-002-respawn-invincibility-visual-feedback.md`,
  and QA evidence under `production/qa/evidence/`.
- Implementation: Player respawn now starts a 120-frame visual feedback window
  aligned with the existing 120 i-frame grant. The sprite alpha alternates
  between dim and bright semi-transparent states, then restores alpha only so
  later attack/dodge/damage colors are not overwritten.
- TDD evidence: RED first failed on missing PlayerController respawn visual APIs
  (`reports/report_303/`); GREEN story suite 3/3 passing
  (`reports/report_306/`).
- Regression evidence: gameplay suites 6/6 passing (`reports/report_305/`);
  `godot --headless --path . --quit`, `git diff --check`, and changed-code
  long-line checks passing.
- Runtime evidence: Godot MCP ran `res://scenes/main.tscn`, triggered
  `player.respawn_at(...)` via `game_eval`, and returned `visual_active=true`,
  `frames=120`, `alpha=0.42`, `hp=50/100`; game logs showed no runtime errors.
- Visual evidence:
  `reports/visual/cinderpaw-mcp-respawn-flash-20260624.png`.
- Epic status: Death & Respawn now has Stories 001, 002, and 005 complete.
- Next recommended: Death & Respawn Story 003 boss arena respawn reset, or
  HUD/UI Story 004 settings/accessibility controls.

## Session Extract — Boss Arena Respawn Reset 2026-06-24
- Scope: Implement Death & Respawn Story 003, covering `TR-respawn-002` boss
  entrance priority and `TR-respawn-003` boss arena-entry snapshot reset.
- Files changed: `src/gameplay/game_flow_controller.gd`,
  `src/gameplay/main_scene.gd`, `src/gameplay/simple_enemy.gd`,
  `tests/unit/gameplay/game_flow_controller_test.gd`,
  `tests/unit/gameplay/simple_enemy_respawn_reset_test.gd`,
  `production/epics/death-respawn/EPIC.md`,
  `production/epics/death-respawn/story-003-boss-arena-respawn-reset.md`,
  `README.md`, and QA evidence under `production/qa/evidence/`.
- Implementation: GameFlowController now supports `start_boss_encounter()`,
  captures an arena-entry adapter snapshot, and calls summon cleanup, arena lock
  clearing, combat adapter clearing, and boss reset before respawn. The current
  main scene treats Shadow Beast as the boss encounter and restores
  SimpleEnemy HP/position/collision from its entry snapshot.
- TDD evidence: RED first failed on missing GameFlow boss API
  (`reports/report_307/`) and missing SimpleEnemy snapshot APIs
  (`reports/report_309/`); GREEN focused gameplay suites passed 6/6
  (`reports/report_311/`).
- Runtime evidence: Godot MCP session `cinderpaw@c4d7` ran
  `res://scenes/main.tscn`; runtime `game_eval` damaged Shadow Beast from 3 HP
  to 1 HP, killed the player, advanced respawn, and returned restored boss HP
  3/3, player HP 50/100, and GameFlow state `revived`.
- Visual evidence:
  `reports/visual/cinderpaw-mcp-boss-respawn-reset-20260624.png`.
- Epic status: Death & Respawn now has Stories 001, 002, 003, and 005 complete.
- Next recommended: Death & Respawn Story 006 no-loss respawn state contract, or
  HUD/UI Story 004 settings/accessibility controls.

## Session Extract — No-Loss Respawn State Contract 2026-06-24
- Scope: Implement Death & Respawn Story 006, covering `TR-respawn-005` no
  currency, inventory, acquired weapon, or world progress loss after death and
  respawn.
- Files changed: `src/gameplay/game_flow_controller.gd`,
  `src/gameplay/main_scene.gd`,
  `tests/unit/gameplay/no_loss_respawn_state_contract_test.gd`,
  `production/epics/death-respawn/EPIC.md`,
  `production/epics/death-respawn/story-006-no-loss-respawn-state-contract.md`,
  and QA evidence under `production/qa/evidence/`.
- Implementation: GameFlowController now accepts a no-loss state adapter,
  captures protected progression state when death begins, and restores it before
  respawn. MainScene now owns runtime currency, inventory, acquired/current
  weapon, and world flag state behind the same adapter boundary; victory rewards
  update stored currency rather than only the HUD.
- TDD evidence: RED first failed on missing GameFlow no-loss adapter API
  (`reports/report_312/`); GREEN no-loss story suite passed 2/2
  (`reports/report_313/`).
- Regression evidence: GameFlow/no-loss/boss respawn suites passed 8/8
  (`reports/report_314/`); `godot --headless --path . --quit-after 1` passed.
- Runtime evidence: Godot MCP session `cinderpaw@c4d7` ran
  `res://scenes/main.tscn`; runtime `game_eval` captured `currency=42`,
  inventory items, Long Tail weapon state, and world flags, corrupted them
  during `dying`, then advanced respawn and returned the original protected
  state restored with player HP 50/100 and GameFlow state `revived`.
- Visual evidence:
  `reports/visual/cinderpaw-mcp-no-loss-respawn-state-20260624.png`.
- Dependency note: full SaveSystem is still pending; this story completed the
  runtime adapter contract and SaveSystem-compatible snapshot shape.
- Epic status: Death & Respawn now has Stories 001, 002, 003, 005, and 006
  complete.
- Next recommended: HUD/UI Story 004 settings/accessibility controls, or Death
  & Respawn Story 004 after SaveSystem/SceneManagement are ready.

## Session Extract — Long Tail Multi-Target Range Contract 2026-06-24
- Scope: Implement Weapon Styles Story 006, covering `TR-weapon-001` Long Tail
  range and multi-target collision contract.
- Files changed: `src/core/weapon_component.gd`,
  `tests/unit/weapon/story_006_long_tail_multi_target_test.gd`,
  `production/epics/weapon-styles/EPIC.md`,
  `production/epics/weapon-styles/story-006-long-tail-multi-target-range-contract.md`,
  `README.md`, and QA evidence under `production/qa/evidence/`.
- Implementation: WeaponComponent now accepts a CollisionComponent-compatible
  adapter and activates the current weapon hitbox through it. Long Tail attack
  metadata exposes `multi_target`, `targeting_type=multi_target`,
  `max_targets=5`, and `attack_range=2.0`; non-multi-target weapons remain
  single-target metadata.
- TDD evidence: RED first failed on missing collision adapter/current-hitbox API
  (`reports/report_328/`); GREEN story suite passed 3/3
  (`reports/report_329/`).
- Regression evidence: weapon stories 001-006 plus collision duplicate
  suppression and main-scene weapon swap suites passed 33/33
  (`reports/report_330/`); final verification passed 33/33
  (`reports/report_331/`); `godot --headless --path . --quit-after 1` passed.
- Runtime evidence: Godot MCP session `cinderpaw@c4d7` ran
  `res://scenes/main.tscn`; runtime `game_eval` activated `long_tail_light`,
  returned multi-target metadata with range 2.0 and max targets 5, emitted hits
  for target IDs 201/202/203, and suppressed the duplicate second-frame hit.
- Visual evidence:
  `reports/visual/cinderpaw-mcp-long-tail-multi-target-runtime-20260624.png`.
- Epic status: Weapon Styles now has Stories 001-006 complete.
- Next recommended: Weapon Styles Story 007 Fish Bone charged shield break, or
  a dedicated player attack integration story to wire the playable attack chain
  into Core Combat/Collision.

## Session Extract — Fish Bone Charged Shield Break 2026-06-24
- Scope: Implement Weapon Styles Story 007, covering `TR-weapon-007` Fish Bone
  full-charge shield break through HealthComponent-compatible adapters.
- Files changed: `src/core/weapon_component.gd`, `src/core/health_component.gd`,
  `tests/unit/weapon/story_007_fish_bone_shield_break_test.gd`,
  `production/epics/weapon-styles/EPIC.md`,
  `production/epics/weapon-styles/story-007-fish-bone-charged-shield-break.md`,
  and QA evidence under `production/qa/evidence/`.
- Implementation: HealthComponent now exposes `break_shield()`. WeaponComponent
  now exposes `apply_confirmed_hit_effects(target_adapter, hit_metadata)`, reads
  charge ratio from its CombatComponent-compatible adapter, and only calls
  target `break_shield()` for Fish Bone heavy/charged hits at full charge.
  Partial charge and missing shield APIs return metadata without errors.
- TDD evidence: RED first failed on missing shield-break contract APIs
  (`reports/report_332/`); GREEN story suite passed 3/3
  (`reports/report_333/`).
- Regression evidence: weapon stories 001-007 plus health shield pipeline,
  combat heavy charge, collision duplicate suppression, and main-scene weapon
  swap suites passed 50/50 (`reports/report_334/`);
  `godot --headless --path . --quit-after 1` passed.
- Runtime evidence: Godot MCP session `cinderpaw@c4d7` ran
  `res://scenes/main.tscn`; runtime `game_eval` switched to Fish Bone, cleared a
  target shield from 35 to 0 at full charge, preserved shield at partial charge,
  and degraded safely for a target without `break_shield()`.
- Visual evidence:
  `reports/visual/cinderpaw-mcp-fish-bone-shield-break-runtime-20260624.png`.
- Epic status: Weapon Styles now has Stories 001-007 complete.
- Next recommended: Weapon Styles Story 008 Electro Bell slow status
  application, then a dedicated player attack integration story to wire the
  playable attack chain into Core Combat/Collision/Health.

## Session Extract — Electro Bell Slow Status Application 2026-06-24
- Scope: Implement Weapon Styles Story 008, covering `TR-weapon-006` Electro
  Bell slow status application through StatusEffectComponent-compatible
  adapters.
- Files changed: `src/core/weapon_component.gd`,
  `tests/unit/weapon/story_008_electro_bell_slow_test.gd`,
  `production/epics/weapon-styles/EPIC.md`,
  `production/epics/weapon-styles/story-008-electro-bell-slow-status-application.md`,
  and QA evidence under `production/qa/evidence/`.
- Implementation: WeaponComponent's confirmed-hit effect hook now handles
  `slow_on_hit`, calls target `apply_status(target_id, slow, source_id)`, and
  returns slow metadata for duration, percentage, movement modifier, application
  result, and safe missing-API degradation.
- TDD evidence: RED first failed because Electro Bell did not apply slow status
  (`reports/report_337/`); GREEN story suite passed 4/4
  (`reports/report_338/`).
- Regression evidence: weapon stories 001-008, status stories 001-006, health
  shield pipeline, combat heavy charge, collision duplicate suppression, and
  main-scene weapon swap suites passed 80/80 (`reports/report_340/`);
  `godot --headless --path . --quit-after 1` passed.
- Runtime evidence: Godot MCP session `cinderpaw@c4d7` ran
  `res://scenes/main.tscn`; runtime `game_eval` switched to Electro Bell,
  applied `slow` for 2 seconds at -30% movement, refreshed repeated hits to 2.0
  seconds without duplication, and degraded safely for a target without
  `apply_status()`.
- Visual evidence:
  `reports/visual/cinderpaw-mcp-electro-bell-slow-runtime-20260624.png`.
- Epic status: Weapon Styles now has Stories 001-008 complete.
- Next recommended: create/implement a player attack integration story to wire
  the playable attack chain into Core Combat/Collision/Health/Weapon callbacks.

## Session Extract — Combat Presentation Parry Flash + Cat Claw Trail 2026-06-24
- Scope: Implement Combat Presentation Story 002, covering `TR-combatfx-003`
  and `TR-combatfx-004` for PERFECT parry flash/radial sparks and Cat Claw
  attack-start slash trails.
- Files changed: `src/presentation/combat_presentation.gd`,
  `src/gameplay/player_controller.gd`, `src/gameplay/main_scene.gd`,
  `src/foundation/data_manager.gd`, `tests/unit/presentation/combat_presentation_test.gd`,
  `tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd`,
  generated VFX assets under `assets/generated/`, `AGENTS.md`, asset tracking,
  Combat Presentation epic/story docs, and QA evidence.
- Implementation: CombatPresentation now handles `on_parry_event()` and
  `on_weapon_attack_event()`, spawning an 80% white flash, 22 textured radial
  parry sparks, and exactly 3 textured Cat Claw trail sprites. PlayerController
  emits `attack_started` metadata for light attacks, and MainScene routes that
  signal into CombatPresentation.
- Asset pipeline: generated `combat_parry_spark` and `combat_claw_trail` with
  image generation, removed chroma-key backgrounds to alpha, resized runtime
  PNGs to 96x96, imported through Godot, and recorded them in
  `design/assets/asset-manifest.md`.
- TDD evidence: RED first failed on missing CombatPresentation parry/weapon
  attack APIs and missing MainScene trail runtime contract; GREEN focus suites
  passed `9/9` and `2/2` (`reports/report_348/`, `reports/report_349/`).
- Runtime evidence: headless main scene smoke passed with no error/warning
  log matches. Godot MCP session `cinderpaw@c1b2` ran
  `res://scenes/main.tscn`; runtime `game_eval` returned `trails=3`,
  `parry_sparks=22`, `flashes=1`, `last_flash_alpha=0.8`, `hitstop=8`,
  `shake=8`, and clean game/editor logs.
- Visual evidence:
  `reports/visual/cinderpaw-mcp-parry-claw-trail-runtime-20260624.png`.
- MCP gate note: an old editor error for `get_slide_count()` persisted after
  log clearing despite the editor and filesystem both reading clean source.
  Reloading the Godot AI plugin, reopening/reimporting the scene/scripts, and
  restarting the project cleared the stale editor log; final MCP editor log had
  `0` lines.
- Epic status: Combat Presentation Stories 001-002 are complete; Epic remains
  In Progress for dodge afterimages, boss phase feedback, and remaining
  damage-number/weapon presentation polish.
- Next recommended: implement dodge afterimage feedback using image-generated
  sprite assets and then start converting the player/enemy from static sprites
  to `AnimatedSprite2D` + `SpriteFrames` per `AGENTS.md`.

## Session Extract — Cinderpaw Player Frame Animation 2026-06-24
- Scope: Implement Combat Presentation Story 003, covering `TR-combatfx-010`
  and the AGENTS.md Godot 2D frame-animation rule for the playable Cinderpaw
  character.
- Files changed: `src/characters/cinderpaw.gd`,
  `scenes/characters/cinderpaw.tscn`, `scenes/player.tscn`,
  `src/gameplay/player_controller.gd`,
  `tests/unit/gameplay/player_character_animation_test.gd`,
  `tests/unit/gameplay/player_respawn_visual_feedback_test.gd`, Cinderpaw
  animation frames under `assets/characters/cinderpaw/`, Combat Presentation
  GDD/TR/Epic/story docs, asset tracking, and QA evidence.
- Implementation: Replaced the player visual from static `Sprite2D` art with a
  `Sprite` child instance of `scenes/characters/cinderpaw.tscn`, backed by
  `AnimatedSprite2D + SpriteFrames`. PlayerController now plays idle/run/attack
  animations while preserving flip, tint, dodge transparency, damage flash, and
  respawn invincibility alpha feedback.
- Asset pipeline: Generated a 3x3 Cinderpaw sprite sheet with image generation,
  copied the source into `assets/characters/cinderpaw/source/`, removed
  chroma-key background locally, sliced 9 transparent 96x96 PNG runtime frames
  into `idle`, `run`, and `attack` folders, and imported them through Godot.
- TDD evidence: RED first failed because `$Sprite` was not `AnimatedSprite2D`
  (`reports/report_345/`); GREEN player animation suite passed 3/3
  (`reports/report_346/`).
- Regression evidence: final focused gameplay/presentation regression passed
  17/17 (`reports/report_344/`); headless main-scene smoke exited 0 and log
  scan found no error/warning lines.
- Runtime evidence: Godot MCP session `cinderpaw@c1b2` ran
  `res://scenes/main.tscn`; runtime probe returned `$Player/Sprite`
  `AnimatedSprite2D`, script class `CinderpawCharacter`, animations
  `attack/idle/run`, 3 frames each, 96x96 frame size, and attack request
  switching animation to `attack`.
- Visual evidence:
  `reports/visual/cinderpaw-mcp-player-frame-animation-runtime-20260624.png`.
- Epic status: Combat Presentation Stories 001-003 are complete; Epic remains
  In Progress for dodge afterimages, boss phase feedback, damage numbers, and
  remaining weapon presentation polish.
- Next recommended: implement dodge afterimages and then expand Cinderpaw to
  jump/fall/dodge/hurt/death/revive frame sets under the same asset pipeline.

## 2026-06-24 — Combat Presentation Story 004 Complete

- Completed `production/epics/combat-presentation/story-004-dodge-afterimage-cinderpaw-dodge-animation.md`.
- Player animation: Added `dodge` to
  `assets/characters/cinderpaw/cinderpaw_sprite_frames.tres` with three
  generated transparent 96x96 frames under `assets/characters/cinderpaw/dodge/`.
- Asset pipeline: Generated a Cinderpaw dodge strip through image generation,
  preserved the source at
  `assets/characters/cinderpaw/source/cinderpaw_dodge_strip_imagegen_20260624.png`,
  removed chroma-key background locally, exported
  `cinderpaw_dodge_000.png` through `_002.png`, and imported them through Godot.
- Runtime implementation: `PlayerController.request_dodge()` now plays `dodge`
  and emits `dodge_started(texture, world_position, facing)`; MainScene routes
  that signal to `CombatPresentation.on_dodge_event(texture, world_position,
  facing)`.
- Presentation implementation: CombatPresentation spawns three textured dodge
  afterimages at 50%/30%/10% alpha and keeps the logic Presentation-only; Core
  CombatComponent dodge iframe behavior was not changed.
- TDD evidence: RED failed cleanly with missing dodge animation/API/afterimage
  methods (`reports/report_346/`); GREEN passed 14/14
  (`reports/report_347/`).
- Regression evidence: focused dodge/player-animation/core-dodge/presentation
  suite passed 23/23 (`reports/report_348/`).
- Runtime evidence: Godot MCP session `cinderpaw@c1b2` ran
  `res://scenes/main.tscn`; runtime probe confirmed `$Player/Sprite`
  `AnimatedSprite2D`, `dodge` frame count 3, 96x96 texture size,
  `request_dodge() == true`, afterimage count 3, alpha values
  `[0.5, 0.3, 0.1]`, and first afterimage aligned to the sprite global
  position.
- Visual evidence:
  `reports/visual/cinderpaw-mcp-dodge-afterimage-runtime-20260624.png`.
- QA evidence:
  `production/qa/evidence/dodge-afterimage-cinderpaw-dodge-animation-2026-06-24.md`.
- Epic status: Combat Presentation Stories 001-004 are complete; Epic remains
  In Progress for boss phase feedback, damage-number polish, colorblind remaps,
  performance-budget checks, remaining weapon presentation variants, and
  perfect-dodge gold afterimage styling.
- Next recommended: implement boss phase presentation or damage-number polish;
  expand Cinderpaw later with jump/fall/hurt/death/revive frame sets under the
  same `AnimatedSprite2D + SpriteFrames` pipeline.

## Session Extract — /dev-story 2026-06-24

- Story: `production/epics/combat-presentation/story-007-textured-parry-flash-visual-contract.md` — Textured Parry Flash + Main Scene Visual Contract
- Files changed: `src/presentation/combat_presentation.gd`, `tests/unit/presentation/combat_presentation_test.gd`, `tests/unit/gameplay/main_scene_visual_contract_test.gd`, `assets/generated/combat_parry_flash_overlay.png`, `design/assets/asset-manifest.md`, `production/epics/combat-presentation/EPIC.md`, `production/epics/combat-presentation/story-007-textured-parry-flash-visual-contract.md`, `production/epics/index.md`, `production/qa/evidence/textured-parry-flash-visual-contract-2026-06-24.md`, `AGENTS.md`
- Test written: `tests/unit/gameplay/main_scene_visual_contract_test.gd`; `tests/unit/presentation/combat_presentation_test.gd` extended with textured parry flash regression
- Verification: RED failed on `ColorRect` parry flash (`reports/report_350/`); GREEN focused Story007 `14/14` (`reports/report_353/`); related visual regression `39/39` (`reports/report_354/`); headless main scene smoke clean; Godot MCP runtime probe/log/screenshot evidence captured
- Blockers: None
- Next: /code-review changed files then continue Combat Presentation boss phase feedback, damage-number polish, colorblind remaps, performance-budget checks, or Save System TR-save-007 async write hardening

## Session Extract — /dev-story 2026-06-24

- Story: `production/epics/combat-presentation/story-008-damage-number-tier-polish.md` — Damage Number Tier Polish
- Files changed: `src/presentation/combat_presentation.gd`, `tests/unit/presentation/combat_presentation_test.gd`, `production/epics/combat-presentation/EPIC.md`, `production/epics/combat-presentation/story-008-damage-number-tier-polish.md`, `production/epics/index.md`, `production/qa/evidence/damage-number-tier-polish-2026-06-24.md`, `production/session-state/active.md`
- Test written: `tests/unit/presentation/combat_presentation_test.gd` extended with six-tier damage-number style, lifetime, boundary, final-damage, and rapid-cleanup regressions
- Verification: RED failed on incomplete `31/61/151` tier styling (`reports/report_355/`); GREEN focused presentation `17/17` (`reports/report_356/`); related runtime/presentation regression `26/26` (`reports/report_357/`); headless main-scene smoke clean; Godot MCP runtime probe/log/screenshot evidence captured
- Asset note: no new project image asset was required for Story008; Label styling covers the visual requirement
- Blockers: None
- Next: /code-review changed files then continue Combat Presentation boss phase feedback, colorblind remaps, performance-budget checks, low-HP focus shake reduction, or Save System TR-save-007 async write hardening

## Session Extract — /dev-story 2026-06-24

- Story: `production/epics/combat-presentation/story-009-boss-phase-transition-signal-contract.md` — Boss Phase Transition Signal Contract
- Files changed: `src/core/boss_config_component.gd`, `tests/unit/boss/story_007_phase_transition_start_signal_contract_test.gd`, `production/epics/combat-presentation/EPIC.md`, `production/epics/combat-presentation/story-009-boss-phase-transition-signal-contract.md`, `production/epics/index.md`, `production/qa/evidence/boss-phase-transition-signal-contract-2026-06-24.md`, `production/session-state/active.md`
- Implementation: Added `on_boss_phase_transition_started(entity_id, phase, metadata)` from BossConfigComponent's actual transition-start point, preserves Health trigger HP percentage, maps Health threshold ordinals to actual Rat King phase IDs, and emits metadata before AI/arena adapters are applied.
- Test written: `tests/unit/boss/story_007_phase_transition_start_signal_contract_test.gd`
- Verification: RED failed on missing transition-start signal (`reports/report_358/`); GREEN focused Story009 `3/3` (`reports/report_359/`); related Boss/Health/AI regression `39/39` (`reports/report_360/`); headless main-scene smoke clean; Godot MCP runtime probe/log evidence captured.
- Asset note: no image-generated visual asset was required for this signal contract slice.
- Blockers: None
- Next: implement Combat Presentation boss phase visual/audio feedback using this BossConfig signal, or continue colorblind remaps/performance-budget checks.

## Session Extract — /dev-story 2026-06-24

- Story: `production/epics/combat-presentation/story-010-boss-phase-visual-feedback.md` — Boss Phase Visual Feedback
- Files changed: `AGENTS.md`, `src/presentation/combat_presentation.gd`, `src/gameplay/main_scene.gd`, `tests/unit/presentation/combat_presentation_test.gd`, `tests/unit/gameplay/main_scene_visual_contract_test.gd`, `assets/generated/combat_boss_phase_overlay.png`, `assets/generated/combat_boss_phase_overlay_alpha_raw.png`, `assets/generated/source/combat_boss_phase_overlay_imagegen_20260624.png`, `design/assets/asset-manifest.md`, `production/epics/combat-presentation/EPIC.md`, `production/epics/index.md`, `production/epics/combat-presentation/story-010-boss-phase-visual-feedback.md`, `production/qa/evidence/boss-phase-visual-feedback-2026-06-24.md`, `production/session-state/active.md`
- Implementation: `CombatPresentation.on_boss_phase_transition_started(entity_id, phase, metadata)` now records metadata, plays 4-frame hitstop, phase shake, an image-generated textured overlay, and 32 textured metal debris sprites for 1.5s; `MainScene` can register a BossConfig-style signal source and forwards transition metadata to presentation/HUD.
- Test written: `tests/unit/presentation/combat_presentation_test.gd` and `tests/unit/gameplay/main_scene_visual_contract_test.gd`
- Verification: RED failed on missing presentation/MainScene phase API (`reports/report_361/`); GREEN focused Story010 `22/22` (`reports/report_368/`); related presentation/Boss/MainScene/animation regression `52/52` (`reports/report_369/`); headless main-scene smoke clean; Godot MCP runtime probe/log/screenshot evidence captured.
- Asset note: generated `combat_boss_phase_overlay.png` through image generation, copied source into `assets/generated/source/`, removed `#00FF00` chroma key to alpha, and imported through Godot.
- Blockers: None
- Next: continue Combat Presentation colorblind remaps, performance-budget checks, low-HP focus shake reduction, boss phase audio/HUD follow-up, or real BossConfig scene integration.

## Session Extract — /dev-story 2026-06-25

- Story: `production/epics/audio-system/story-001-autoload-bus-pool-baseline.md` — AudioSystem Autoload Bus + Pool Baseline
- Files changed: `src/presentation/audio_system.gd`, `project.godot`, `tests/unit/presentation/audio_system_test.gd`, `production/epics/audio-system/EPIC.md`, `production/epics/audio-system/story-001-autoload-bus-pool-baseline.md`, `production/epics/index.md`, `production/qa/evidence/audio-system-autoload-bus-pool-baseline-2026-06-25.md`, `production/session-state/active.md`
- Implementation: Added AudioSystem as Autoload #3 after InputManager and before SaveSystem, created runtime Master/Music/SFX/Ambient/UI bus setup with linear percentage volumes, added a 16-player `AudioStreamPlayer2D` SFX pool, and exposed silent-safe `play_sfx`, `play_music`, `stop_music`, `play_ambient`, `stop_ambient`, `set_bus_volume`, and stream registration APIs.
- Test written: `tests/unit/presentation/audio_system_test.gd`
- Verification: RED failed on missing AudioSystem script/autoload (`reports/report_446/`); RED refinement failed on SFX max distance/bus send coverage (`reports/report_448/`); GREEN focused AudioSystem `6/6` (`reports/report_449/`); related Presentation/Input/Save/Scene regression `109/109` (`reports/report_451/`); headless project smoke exited 0.
- Runtime evidence: Godot MCP ran `res://scenes/main.tscn`; runtime probe confirmed `/root/AudioSystem`, five buses with default volume percentages, SFX pool size 16, missing audio calls safely returning false, pitch metadata recorded, clean game logs, and capturable 1280x720 game frame.
- Asset note: no image-generated visual asset was required for this audio infrastructure slice; real SFX/music/ambience asset generation/import is deferred to later audio content stories.
- Blockers: None
- Next: implement Audio System Story 002 scene-transition audio fades by wiring SceneManager transition events to AudioSystem-owned fade APIs, then add real generated/imported audio content and combat event adapters.

## Session Extract — /dev-story 2026-06-25

- Story: `production/epics/audio-system/story-004-boss-music-state-transitions.md` — Rat King Boss Music State Transitions
- Files changed: `src/presentation/audio_system.gd`, `src/gameplay/main_scene.gd`, `tests/unit/presentation/audio_system_test.gd`, `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd`, `production/epics/audio-system/EPIC.md`, `production/epics/index.md`, `production/epics/audio-system/story-004-boss-music-state-transitions.md`, `production/qa/evidence/audio-boss-music-state-transitions-2026-06-25.md`, `production/session-state/active.md`
- Implementation: `AudioSystem` now owns Rat King boss music cue diagnostics for encounter start, phase 2/3 transition, and encounter end. `MainScene` forwards Rat King encounter start and defeat/end events to AudioSystem and enriches phase transition metadata with `boss_id` without coupling RatKingBoss, BossConfig, AIComponent, or GameFlow to Presentation.
- Test written: `tests/unit/presentation/audio_system_test.gd` extended with boss music state regression; `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd` extended with Rat King boss music start/end forwarding.
- Verification: RED failed on missing boss music API/MainScene start forwarding (`reports/report_535/`); GREEN focused AudioSystem/MainScene adapter `19/19` (`reports/report_536/`); final related regression after Godot warning cleanup `24/24` (`reports/report_538/`); headless main-scene smoke clean; Godot MCP runtime boss music state probe/log/screenshot evidence captured.
- Asset note: no image-generated visual asset was required for this audio state slice.
- Blockers: None
- Next: continue UI menu audio, same-SFX merge, real audio asset import, boss arena persistence, platform profiler evidence, or player-visible frame animation audit slices.

## Session Extract — /dev-story 2026-06-25

- Story: `production/epics/audio-system/story-008-music-ambience-asset-import-baseline.md` — Music + Ambience Asset Import Baseline
- Files changed: `src/presentation/audio_system.gd`, `tests/unit/presentation/audio_system_test.gd`, `assets/audio/music/*.wav`, `assets/audio/music/*.wav.import`, `assets/audio/ambient/*.wav`, `assets/audio/ambient/*.wav.import`, `assets/audio/source/music_ambience_generation_20260625.json`, `production/epics/audio-system/EPIC.md`, `production/epics/index.md`, `production/epics/audio-system/story-008-music-ambience-asset-import-baseline.md`, `production/qa/evidence/audio-music-ambience-asset-import-baseline-2026-06-25.md`, `production/session-state/active.md`
- Implementation: Generated 15 replaceable procedural baseline WAVs for all GDD music/ambience cues, imported them through Godot, and added `DEFAULT_MUSIC_AMBIENT_STREAMS` so AudioSystem registers them on `_ready()`. Scene cues now play real `mus_street` / `amb_street` streams, and Rat King boss start/phase 2/phase 3 music now returns true with `mus_boss_rat_p1/p2/p3` stream playback while unknown music/ambient ids remain silent-safe.
- Test written: `tests/unit/presentation/audio_system_test.gd` extended with full 15-cue registration/path checks, music/ambient player stream assertions, unknown cue safety, scene cue playback, and boss music `stream_found=true` checks.
- Verification: RED failed on missing music/ambience assets/default registration (`reports/report_585/`); GREEN focused AudioSystem `19/19` (`reports/report_586/`); related AudioSystem/MainScene scene/boss regression `32/32` (`reports/report_587/`); Godot import; headless main-scene smoke clean; Godot MCP runtime cue registration/scene playback/boss music probe, clean logs, and screenshot evidence captured.
- Asset note: no image-generated visual asset was required for this audio-only slice. Audio source recipes are recorded in `assets/audio/source/music_ambience_generation_20260625.json`.
- Blockers: None
- Next: continue authored/final audio replacement, DEATH/CUTSCENE audio states, area cue expansion for sewer/factory/rooftop/tower scene ids, broader audio mix polish, platform profiler evidence, low-memory UI prompt routing, or a player-visible ACT frame animation slice.

## Session Extract — /dev-story 2026-06-25

- Story: `production/epics/boss-config/story-010-rat-king-defeat-reward-runtime-consumption.md` — Rat King Defeat Reward Runtime Consumption
- Files changed: `src/core/boss_config_component.gd`, `src/gameplay/main_scene.gd`, `src/gameplay/rat_king_boss.gd`, `tests/unit/gameplay/rat_king_defeat_reward_runtime_test.gd`, `tests/unit/save/story_004_main_scene_save_system_runtime_handoff_test.gd`, `production/epics/boss-config/EPIC.md`, `production/epics/index.md`, `production/epics/boss-config/story-010-rat-king-defeat-reward-runtime-consumption.md`, `production/qa/evidence/rat-king-defeat-reward-runtime-2026-06-25.md`, `production/session-state/active.md`
- Implementation: `BossConfigComponent` now optionally brackets defeat reward dispatch with `begin_boss_defeat_rewards()` / `finish_boss_defeat_rewards()` reward-adapter hooks; `RatKingBoss` forwards a reward adapter to `BossConfigComponent`; `MainScene` consumes Rat King defeat rewards into runtime progression (`dash`, `50` Gears, `5` skill points), removes the old hard-coded `25` Gears victory reward, displays only the claimed boss reward in HUD victory notification/retry menu, and persists reward fields through runtime progress, no-loss state, save snapshots, and boss-defeat autosave. Health death signal ordering now dispatches BossConfig rewards before `enemy_defeated`, so autosave captures the claimed reward state.
- Test written: `tests/unit/gameplay/rat_king_defeat_reward_runtime_test.gd`; SaveSystem Story004 autosave assertions updated for configured reward persistence.
- Verification: RED focused reward runtime failed as expected (`reports/report_588/`); GREEN focused reward runtime passed `1/1` (`reports/report_589/`); related reward/BossConfig/RatKingBoss/SaveSystem regression passed `13/13` (`reports/report_595/`); headless main-scene smoke log had no script-error/warning/resource-load matches; Godot MCP runtime defeated Rat King and verified `currency=50`, `skill_points=5`, `unlocked_abilities=["dash"]`, reward HUD text, save snapshot reward fields, clean game/editor logs, and nonblank screenshot `reports/visual/cinderpaw-mcp-rat-king-reward-runtime-20260625.png`.
- Asset note: no new image-generated visual asset was required for this reward-runtime slice.
- Blockers: None. Residual Godot cleanup-time ObjectDB/resource warnings still appear at process exit in mixed GdUnit/headless runs; runtime logs and tests are clean.
- Next: continue remaining ACT-visible slices: player ability gating/skill-tree spending UI, boss cutscene/death polish, authored/final audio replacement, DEATH/CUTSCENE audio states, broader encounter polish, or frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-003-double-jump-runtime-high-platform-gate.md` — Double Jump Runtime + High Platform Gate
- Files changed: `src/gameplay/player_controller.gd`, `scenes/main.tscn`, `tests/unit/gameplay/player_double_jump_gate_runtime_test.gd`, `assets/generated/source/high_platform_gate_marker_imagegen_20260626.png`, `assets/generated/source/high_platform_gate_marker_imagegen_20260626.png.import`, `assets/environment/high_platform_gate/high_platform_gate_marker.png`, `assets/environment/high_platform_gate/high_platform_gate_marker.png.import`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/epics/player-abilities/story-003-double-jump-runtime-high-platform-gate.md`, `production/qa/evidence/double-jump-high-platform-gate-runtime-2026-06-26.md`, `production/session-state/active.md`
- Implementation: `PlayerController` now exposes `request_double_jump()`, `set_airborne()`, `reset_air_abilities()`, and `double_jump_started`, delegates air-count checks to `AbilityComponent`, plays the existing imported `jump` SpriteFrames animation, applies upward velocity, resets air-count usage on landing and respawn, and keeps ground jump/coyote behavior intact. `scenes/main.tscn` now contains `DoubleJumpExplorationGate` using `required_ability="double_jump"` and `target_area_id="area_03_factory"`, while preserving the existing Dash gate. The gate unlocks after a Double Jump activation in range and persists through `world_state.exploration_gates`, `gate_double_jump_high_platform_unlocked`, and `area_03_factory_unlocked`.
- Asset pipeline: Generated a high-platform Double Jump route marker through image generation, preserved the source at `assets/generated/source/high_platform_gate_marker_imagegen_20260626.png`, removed chroma-key background to transparent RGBA at `assets/environment/high_platform_gate/high_platform_gate_marker.png`, and imported it through Godot.
- Test written: `tests/unit/gameplay/player_double_jump_gate_runtime_test.gd` with three tests covering imported jump frames, Double Jump activation/air-count reset, and MainScene gate unlock/save restore.
- Verification: RED failed on missing Double Jump signal/API (`reports/report_611/`); GREEN focused Double Jump test passed `3/3` (`reports/report_613/`); final scene sanity passed `5/5` across Double Jump and Dash gates (`reports/report_616/`); related regression passed `19/19` (`reports/report_618/`); headless main-scene smoke log had no script-error/resource-load keyword matches; Godot MCP runtime confirmed `AnimatedSprite2D` jump frames, both gates present, Double Jump gate unlocked/persisted, clean game/editor logs, and nonblank screenshot `reports/visual/cinderpaw-mcp-double-jump-high-platform-gate-20260626.png`.
- Blockers: None. Residual Godot cleanup-time ObjectDB/resource messages still appear at process exit in mixed GdUnit/headless runs; runtime MCP logs and test results are clean.
- Next: implement an ACT-visible follow-up such as a real Double Jump reward source, skill-tree spending UI, gate unlock SFX/VFX, factory route transition shell, or another player-visible ability consumer.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-004-double-jump-activation-feedback.md` — Double Jump Activation Feedback
- Files changed: `src/presentation/combat_presentation.gd`, `src/gameplay/main_scene.gd`, `src/presentation/audio_system.gd`, `tests/unit/presentation/combat_presentation_test.gd`, `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd`, `tests/unit/presentation/audio_system_test.gd`, `assets/generated/source/player_double_jump_vortex_imagegen_20260626.png`, `assets/generated/player_double_jump_vortex_alpha_raw.png`, `assets/generated/player_double_jump_vortex_runtime.png`, `assets/audio/sfx/sfx_double_jump.wav`, `assets/audio/source/core_combat_sfx_generation_20260625.json`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/epics/player-abilities/story-004-double-jump-activation-feedback.md`, `production/qa/evidence/double-jump-activation-feedback-2026-06-26.md`, `production/session-state/active.md`
- Implementation: `CombatPresentation.on_double_jump_event(texture, world_position, facing)` now spawns three short-lived textured `Sprite2D` foot-vortex particles using `res://assets/generated/player_double_jump_vortex_runtime.png`, includes them in particle count/cap cleanup, and exposes focused diagnostics for tests. `MainScene` connects `Player.double_jump_started` to `CombatPresentation` and `AudioSystem`. `AudioSystem.on_double_jump_event(...)` routes successful activations to imported `sfx_double_jump` with spatial metadata and silent-safe behavior.
- Asset pipeline: Generated a Double Jump foot-vortex VFX through image generation, preserved the source at `assets/generated/source/player_double_jump_vortex_imagegen_20260626.png`, chroma-keyed to transparent RGBA, resized to `assets/generated/player_double_jump_vortex_runtime.png`, and imported through Godot. Generated replaceable procedural baseline audio at `assets/audio/sfx/sfx_double_jump.wav` and recorded it in `assets/audio/source/core_combat_sfx_generation_20260625.json`.
- Test written: `tests/unit/presentation/combat_presentation_test.gd`, `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd`, and `tests/unit/presentation/audio_system_test.gd` were extended for textured Double Jump VFX, MainScene event forwarding, and `sfx_double_jump` routing.
- Verification: RED focused run failed as expected with missing presentation/audio/MainScene behavior (`reports/report_619/`, `59` tests, `11` failures); GREEN focused run passed `59/59` (`reports/report_622/`); related ability/presentation/audio regression passed `67/67` (`reports/report_623/`); headless main-scene smoke exited `0` with no script/resource-load errors but retained known cleanup-time ObjectDB/resource messages; Godot MCP runtime confirmed `activation_ok=true`, `AnimatedSprite2D` player jump frames, `vfx_count=3`, all VFX sprites using `res://assets/generated/player_double_jump_vortex_runtime.png`, `sfx_double_jump stream_found=true`, clean game/editor logs, and nonblank screenshot `reports/visual/cinderpaw-mcp-double-jump-activation-feedback-20260626.png`.
- Blockers: None. Residual Godot cleanup-time ObjectDB/resource messages still appear at process exit in mixed GdUnit/headless runs; runtime MCP logs and focused/related test reports are clean.
- Next: continue another ACT-visible slice such as skill-tree spending UI, real Double Jump reward source, gate unlock SFX/VFX, factory route transition shell, boss death/cutscene polish, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-005-hidden-double-jump-reward-source.md` — Hidden Double Jump Reward Source
- Files changed: `src/feature/ability_reward_source.gd`, `src/gameplay/main_scene.gd`, `scenes/main.tscn`, `tests/unit/gameplay/hidden_double_jump_reward_source_runtime_test.gd`, `assets/generated/source/hidden_double_jump_reward_source_imagegen_20260626.png`, `assets/generated/source/hidden_double_jump_reward_source_imagegen_20260626.png.import`, `assets/generated/source/hidden_double_jump_reward_source_alpha_20260626.png`, `assets/generated/source/hidden_double_jump_reward_source_alpha_20260626.png.import`, `assets/environment/double_jump_reward/hidden_double_jump_reward_source.png`, `assets/environment/double_jump_reward/hidden_double_jump_reward_source.png.import`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/epics/player-abilities/story-005-hidden-double-jump-reward-source.md`, `production/qa/evidence/hidden-double-jump-reward-source-2026-06-26.md`, `production/session-state/active.md`
- Implementation: Added `AbilityRewardSource` as a scene-local one-shot reward source with deterministic diagnostics, range checks, visible/dimmed claim state, and texture path reporting. `scenes/main.tscn` now contains `HiddenDoubleJumpRewardSource` using the generated cat-eye wind-core relic prop. `MainScene.claim_hidden_double_jump_reward_source()` claims it once, writes `hidden_boss_echo_double_jump_claimed`, calls existing `unlock_ability(&"double_jump")`, updates HUD notification, syncs Player/ExplorationGate runtime, triggers autosave, and restores the claimed visual state from save snapshots.
- Asset pipeline: Generated a hidden Double Jump reward relic through image generation, preserved the source at `assets/generated/source/hidden_double_jump_reward_source_imagegen_20260626.png`, chroma-keyed it to `assets/generated/source/hidden_double_jump_reward_source_alpha_20260626.png`, cropped/resized it to `assets/environment/double_jump_reward/hidden_double_jump_reward_source.png`, and imported it through Godot.
- Test written: `tests/unit/gameplay/hidden_double_jump_reward_source_runtime_test.gd` with two tests covering once-only claim/runtime sync and save/restore playability.
- Verification: RED focused run failed on missing `HiddenDoubleJumpRewardSource` (`reports/report_624/`); GREEN focused Story005 passed `2/2` (`reports/report_626/`); related regression passed `8/8` across Story005, Double Jump gate, Rat King reward, and Dash gate (`reports/report_627/`); headless main-scene smoke exited `0` with only the known cleanup-time ObjectDB/resource warning; Godot MCP runtime confirmed the generated reward source is visible, Player uses `AnimatedSprite2D`, claim unlocks `double_jump` once, gate becomes `unlockable` then `unlocked` only after Double Jump activation, world flags persist, game/editor logs are clean, and screenshot `reports/visual/cinderpaw-mcp-hidden-double-jump-reward-source-20260626.png` is nonblank.
- Blockers: None. Residual Godot cleanup-time ObjectDB/resource messages still appear at process exit in mixed GdUnit/headless runs; runtime MCP logs and focused/related test reports are clean.
- Next: continue another ACT-visible slice such as gate unlock SFX/VFX, factory route transition shell, skill-tree spending UI, mainline Boss2 Double Jump reward source, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-006-factory-route-transition-shell.md` — Factory Route Transition Shell
- Files changed: `src/feature/route_transition_shell.gd`, `src/feature/scene_manager.gd`, `src/gameplay/main_scene.gd`, `scenes/main.tscn`, `scenes/factory_route_transition_shell.tscn`, `data/scene_registry.json`, `data/schemas/scene_registry.schema.json`, `tests/unit/gameplay/factory_route_transition_shell_runtime_test.gd`, `assets/generated/source/factory_route_transition_shell_imagegen_20260626.png`, `assets/generated/source/factory_route_transition_shell_imagegen_20260626.png.import`, `assets/generated/source/factory_route_transition_shell_alpha_20260626.png`, `assets/generated/source/factory_route_transition_shell_alpha_20260626.png.import`, `assets/environment/factory_route_transition/factory_route_transition_shell.png`, `assets/environment/factory_route_transition/factory_route_transition_shell.png.import`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/epics/player-abilities/story-006-factory-route-transition-shell.md`, `production/qa/evidence/factory-route-transition-shell-2026-06-26.md`, `reports/factory_route_transition_shell_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-factory-route-transition-shell-20260626.png`, `production/session-state/active.md`
- Implementation: Added `RouteTransitionShell` as a scene-local route entrance trigger, wired `MainScene.request_factory_route_transition()` to require the Double Jump high-platform unlock flag, configure SceneManager's runtime scene root, request `area_03_factory` / `factory_gate_entry`, and prevent duplicate requests. `SceneManager` now preserves `display_name` from the scene registry so the existing HUD transition shell shows `Factory Route`. Added a minimal loadable `factory_route_transition_shell.tscn` destination with generated route doorway prop art and `FactoryGateEntrySpawn`.
- Asset pipeline: Generated the Factory Route transition shell prop through image generation, preserved source and alpha source PNGs, cropped/resized to `assets/environment/factory_route_transition/factory_route_transition_shell.png`, imported it through Godot, and recorded the asset in the manifest and entity inventory.
- Test written: `tests/unit/gameplay/factory_route_transition_shell_runtime_test.gd` with three tests covering registry/destination loading, Double Jump gate to route-shell availability, SceneManager runtime-root setup/request/HUD label, duplicate request blocking, and minimal visible destination content.
- Verification: RED focused failed on missing registry/scene/route shell (`reports/report_630/`); RED refinement failed on missing runtime scene-root setup (`reports/report_634/`); GREEN focused Story006 passed `3/3` (`reports/report_635/`); related regression passed `40/40` across route shell, Double Jump reward/gate, SceneManager swap/preload, transition UI, and title/load handoff (`reports/report_636/`); headless main-scene smoke exited `0` with only known cleanup-time ObjectDB/resource messages; Godot MCP runtime confirmed `Player/Sprite` is `AnimatedSprite2D`, Double Jump unlocks the high-platform gate and `area_03_factory_unlocked`, the generated route shell becomes available, HUD transition label is `Factory Route`, SceneManager reaches `area_03_factory` at `factory_gate_entry`, destination visual uses `res://assets/environment/factory_route_transition/factory_route_transition_shell.png`, final game/editor logs are clean, and screenshot `reports/visual/cinderpaw-mcp-factory-route-transition-shell-20260626.png` is nonblank.
- Blockers: None. Full Old Factory gameplay remains out of scope; this story lands only the route entrance/transition shell.
- Next: continue another ACT-visible slice such as gate unlock SFX/VFX, skill-tree spending UI, mainline Boss2 Double Jump reward source, real Old Factory content, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-007-old-factory-entrance-combat-slice.md` — Old Factory Entrance Combat Slice
- Files changed: `scenes/factory_route_transition_shell.tscn`, `src/gameplay/old_factory_entrance_scene.gd`, `src/gameplay/old_factory_entrance_scene.gd.uid`, `src/presentation/audio_system.gd`, `tests/unit/gameplay/old_factory_entrance_combat_slice_runtime_test.gd`, `tests/unit/presentation/audio_system_test.gd`, `assets/generated/source/old_factory_entrance_room_backdrop_imagegen_20260626.png`, `assets/generated/source/old_factory_entrance_room_backdrop_imagegen_20260626.png.import`, `assets/environment/old_factory_entrance_combat/old_factory_entrance_room_backdrop.png`, `assets/environment/old_factory_entrance_combat/old_factory_entrance_room_backdrop.png.import`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/epics/player-abilities/story-007-old-factory-entrance-combat-slice.md`, `production/qa/evidence/old-factory-entrance-combat-slice-2026-06-26.md`, `reports/old_factory_entrance_combat_slice_factory_scene_smoke.log`, `reports/old_factory_entrance_combat_slice_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-old-factory-entrance-combat-slice-20260626.png`, `production/session-state/active.md`
- Implementation: Upgraded `res://scenes/factory_route_transition_shell.tscn` from a gray route shell into the first playable Old Factory entrance combat slice. The scene now uses `OldFactoryEntranceScene`, an image-generated 1280x720 factory backdrop, safe ground/wall/platform collision, `FactoryGateEntrySpawn`, the existing Story006 route shell prop, a playable `Player` instance, and a visible `FactoryRatMinion` combat object. `OldFactoryEntranceScene` aligns the player to the factory spawn, wires a scene-local `WeaponComponent`, adapts player attack damage into the Factory Rat Minion, exposes hit metadata diagnostics, and requests `mus_factory` / `amb_factory` through `AudioSystem`.
- Asset pipeline: Generated the Old Factory entrance backdrop through image generation, preserved the source at `assets/generated/source/old_factory_entrance_room_backdrop_imagegen_20260626.png`, cropped/resized it to `assets/environment/old_factory_entrance_combat/old_factory_entrance_room_backdrop.png`, imported it through Godot, and recorded the asset in the manifest and entity inventory.
- Test written: `tests/unit/gameplay/old_factory_entrance_combat_slice_runtime_test.gd` with four focused tests covering backdrop/spawn/collision, visible animated Rat Minion contract, player attack damage against the room combat object, and SceneManager runtime swap into the Old Factory slice. `tests/unit/presentation/audio_system_test.gd` now covers the default `area_03_factory` music/ambient cue mapping.
- Verification: RED focused failed on missing backdrop/player/collision/combat object (`reports/report_637/`); damage regression RED failed before the scene-local WeaponComponent/adapter fix (`reports/report_644/`, `reports/report_645/`); GREEN focused Story007 passed `4/4` (`reports/report_646/`); related regression passed `55/55` across Old Factory, route shell, scene swap/preload, Double Jump reward/gate, attack chain, Rat King summon runtime, transition UI, and AudioSystem (`reports/report_647/`); headless Factory and main-scene smoke logs exited `0` with only known cleanup-time ObjectDB/resource messages; Godot MCP runtime confirmed route transition to `area_03_factory` / `factory_gate_entry`, Factory scene metadata, generated backdrop, player/enemy `AnimatedSprite2D`, Rat Minion 3-frame animation states, `mus_factory` / `amb_factory`, clean game/editor logs, fresh Factory attack HP `24 -> 12`, and screenshot `reports/visual/cinderpaw-mcp-old-factory-entrance-combat-slice-20260626.png`.
- Blockers: None. Full Old Factory layout, Boss2, hidden boss, savepoints, minimap, and new enemy family remain out of scope.
- Next: continue another ACT-visible slice such as gate unlock SFX/VFX, skill-tree spending UI, mainline Boss2 Double Jump reward source, deeper Old Factory combat/traversal content, or broader player-visible frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-008-old-factory-double-jump-combat-cache.md` — Old Factory Double Jump Combat Cache
- Files changed: `src/feature/factory_combat_cache.gd`, `src/feature/factory_combat_cache.gd.uid`, `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_entrance_room_clear_runtime_test.gd`, `assets/generated/source/factory_combat_cache_imagegen_20260626.png`, `assets/generated/source/factory_combat_cache_imagegen_20260626.png.import`, `assets/generated/source/factory_combat_cache_alpha_20260626.png`, `assets/generated/source/factory_combat_cache_alpha_20260626.png.import`, `assets/environment/old_factory_combat_cache/factory_combat_cache.png`, `assets/environment/old_factory_combat_cache/factory_combat_cache.png.import`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/epics/player-abilities/story-008-old-factory-double-jump-combat-cache.md`, `production/qa/evidence/old-factory-double-jump-combat-cache-2026-06-26.md`, `reports/old_factory_double_jump_combat_cache_factory_scene_smoke.log`, `reports/old_factory_double_jump_combat_cache_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-old-factory-double-jump-combat-cache-20260626.png`, `README.md`, `production/session-state/active.md`
- Implementation: Added `FactoryCombatCache` as a scene-local one-shot room-clear reward component with locked/available/claimed states, deterministic `+10 Gears` payload, range-gated once-only claim, prompt/visual dimming, texture diagnostics, and `cache_claimed` signal. Extended `OldFactoryEntranceScene` to connect `FactoryRatMinion.enemy_defeated`, expose `is_encounter_cleared()`, `try_claim_factory_cache()`, `get_factory_room_clear_diagnostics()`, and `get_local_state()` / `set_local_state()`. Updated `factory_route_transition_shell.tscn` with an upper `FactoryCachePlatform`, visible generated cache prop, prompt label, and interaction area while preserving the existing player, Rat Minion, spawn, route shell, and Old Factory backdrop.
- Asset pipeline: Generated the Factory combat cache prop through image generation, preserved source at `assets/generated/source/factory_combat_cache_imagegen_20260626.png`, removed chroma key to `assets/generated/source/factory_combat_cache_alpha_20260626.png`, cropped/resized to `assets/environment/old_factory_combat_cache/factory_combat_cache.png`, imported it through Godot, and recorded it in the asset manifest and entity inventory.
- Test written: `tests/unit/gameplay/old_factory_entrance_room_clear_runtime_test.gd` with three focused tests covering the upper cache platform/generated prop contract, locked → cleared → once-claimed cache behavior, deterministic reward payload, and local state restore.
- Verification: RED focused failed on missing cache asset/platform/node/API/local state (`reports/report_648/`); GREEN focused passed `3/3` (`reports/report_650/`); related regression passed `23/23` across Old Factory room clear cache, Old Factory entrance combat, Factory route shell, SceneManager runtime tree swap, Double Jump gate, hidden Double Jump reward source, and MainScene player attack chain (`reports/report_651/`); Godot import registered `FactoryCombatCache`; headless Factory and main-scene smoke logs exited `0` and keyword scans found no parse/invalid/missing-resource errors; Godot MCP runtime confirmed initial cache locked, enemy defeat unlocks cache, claim succeeds once with `+10 Gears`, duplicate claim fails, local state persists, player/enemy `AnimatedSprite2D`, Rat Minion `idle/run/attack` 3-frame animations, clean logs, and screenshot `reports/visual/cinderpaw-mcp-old-factory-double-jump-combat-cache-20260626.png`.
- Blockers: None. Full deeper Old Factory layout, Boss2, savepoints, minimap, and new enemy family remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory hazards/route room, gate unlock SFX/VFX, skill-tree spending UI, mainline Boss2 Double Jump reward source, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-009-old-factory-steam-vent-hazard-route.md` — Old Factory Steam Vent Hazard Route
- Files changed: `src/feature/factory_steam_vent_hazard.gd`, `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_steam_vent_hazard_runtime_test.gd`, `assets/generated/source/old_factory_steam_vent_hazard_imagegen_20260626.png`, `assets/generated/source/old_factory_steam_vent_hazard_imagegen_20260626.png.import`, `assets/generated/source/old_factory_steam_vent_hazard_alpha_20260626.png`, `assets/generated/source/old_factory_steam_vent_hazard_alpha_20260626.png.import`, `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`, `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png.import`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/index.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/player-abilities/story-009-old-factory-steam-vent-hazard-route.md`, `production/qa/evidence/old-factory-steam-vent-hazard-route-2026-06-26.md`, `reports/old_factory_steam_vent_hazard_factory_scene_smoke.log`, `reports/old_factory_steam_vent_hazard_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-old-factory-steam-vent-hazard-20260626.png`, `production/session-state/active.md`
- Implementation: Added `FactorySteamVentHazard` as a scene-local `Area2D` contact hazard component with deterministic hazard id, damage, cooldown, environment collision contract, visible generated sprite, and texture diagnostics. Extended `OldFactoryEntranceScene` with `advance_factory_hazard_time()`, `apply_factory_steam_vent_contact()`, sustained overlap polling, player-only target resolution, cooldown state, `last_hazard_damage`, and `get_factory_hazard_diagnostics()`. Updated `factory_route_transition_shell.tscn` with the visible steam vent hazard while preserving `area_03_factory`, `FactoryGateEntrySpawn`, player, Rat Minion, room cache, and Old Factory backdrop.
- Asset pipeline: Generated the Old Factory steam vent prop through image generation, preserved source at `assets/generated/source/old_factory_steam_vent_hazard_imagegen_20260626.png`, removed chroma key to `assets/generated/source/old_factory_steam_vent_hazard_alpha_20260626.png`, cropped/resized to `assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`, imported it through Godot, and recorded it in the asset manifest and entity inventory.
- Test written: `tests/unit/gameplay/old_factory_steam_vent_hazard_runtime_test.gd` with four focused tests covering generated vent asset/no-placeholder contract, ADR-0004 environment Area2D contact contract, deterministic player steam damage/cooldown, sustained overlap, enemy ignore behavior, diagnostics, and visible character frame-animation rules.
- Verification: RED focused failed on missing vent PNG/node/API (`reports/report_652/`); GREEN focused Story009 passed `4/4` (`reports/report_653/`); related regression passed `19/19` across Old Factory steam vent hazard, Old Factory entrance combat, room-clear cache, Factory route shell, and Rat King electric leak contact damage (`reports/report_654/`); Godot import registered `FactorySteamVentHazard`; headless Factory and main-scene smoke logs exited `0` and keyword scans found no parse/invalid/missing-resource errors; Godot MCP runtime with `autosave=false` confirmed runtime tree nodes, steam vent layer/mask `16/12`, monitoring enabled, HP `100 -> 92 -> 92 -> 84`, contact results `[true,false,true]`, enemy ignored at `24 -> 24`, player/enemy `AnimatedSprite2D`, required frame counts of `3`, clean game/editor logs, and screenshot `reports/visual/cinderpaw-mcp-old-factory-steam-vent-hazard-20260626.png`.
- Blockers: None. Full deeper Old Factory route, Boss2, hidden boss, savepoints, minimap, new enemy family, and skill-tree UI remain out of scope.
- Next: continue a larger ACT-visible follow-up such as Old Factory shock-belt/deep route micro-slice with a second guard and endpoint, gate unlock SFX/VFX, skill-tree spending UI, mainline Boss2 Double Jump reward source, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-010-old-factory-deep-route-micro-slice.md` — Old Factory Deep Route Micro-Slice
- Files changed: `src/feature/factory_deep_route_endpoint.gd`, `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_deep_route_micro_slice_runtime_test.gd`, `assets/generated/source/factory_deep_route_endpoint_imagegen_20260626.png`, `assets/generated/source/factory_deep_route_endpoint_imagegen_20260626.png.import`, `assets/generated/source/factory_deep_route_endpoint_alpha_20260626.png`, `assets/generated/source/factory_deep_route_endpoint_alpha_20260626.png.import`, `assets/environment/old_factory_deep_route/factory_deep_route_endpoint.png`, `assets/environment/old_factory_deep_route/factory_deep_route_endpoint.png.import`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/index.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/player-abilities/story-010-old-factory-deep-route-micro-slice.md`, `production/qa/evidence/old-factory-deep-route-micro-slice-2026-06-26.md`, `reports/old_factory_deep_route_micro_slice_factory_scene_smoke.log`, `reports/old_factory_deep_route_micro_slice_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-old-factory-deep-route-micro-slice-20260626.png`, `production/session-state/active.md`
- Implementation: Added `FactoryDeepRouteEndpoint` as a scene-local once-only route objective with deterministic endpoint id, generated texture diagnostics, available/activated state, interaction radius, prompt text, and `endpoint_activated` signal. Extended `OldFactoryEntranceScene` to bind both the entrance Rat Minion (`2100`) and the deep-route Rat Minion (`2101`), route player damage by entity id, expose `is_factory_deep_route_cleared()`, `try_activate_factory_deep_route_endpoint()`, and `get_factory_deep_route_diagnostics()`, and persist `factory_deep_guard_defeated` / `factory_deep_route_cleared` through `get_local_state()` / `set_local_state()`. Updated `factory_route_transition_shell.tscn` with `FactoryDeepGuardRatMinion` and the visible generated endpoint while preserving player, entrance Rat Minion, combat cache, steam vent hazard, factory backdrop, and route spawn.
- Asset pipeline: Generated the deep-route endpoint prop through image generation, preserved source at `assets/generated/source/factory_deep_route_endpoint_imagegen_20260626.png`, removed chroma key to `assets/generated/source/factory_deep_route_endpoint_alpha_20260626.png`, cropped/resized it to `assets/environment/old_factory_deep_route/factory_deep_route_endpoint.png`, imported it through Godot, and recorded it in the asset manifest and entity inventory.
- Test written: `tests/unit/gameplay/old_factory_deep_route_micro_slice_runtime_test.gd` with four focused tests covering generated endpoint/no-placeholder contract, unique second Rat guard animation contract, guard-defeat gated endpoint activation, once-only activation, deterministic diagnostics, and local state restoration.
- Verification: RED focused failed on missing endpoint PNG/node/API (`reports/report_655/`), then RED refinement failed on missing PNG import metadata before import (`reports/report_656/`); GREEN focused Story010 passed `4/4` (`reports/report_657/`); related regression passed `11/11` across Old Factory entrance combat, room-clear cache, and steam vent hazard (`reports/report_658/`, `reports/report_659/`, `reports/report_660/`); Godot import registered `FactoryDeepRouteEndpoint`; headless Factory and main-scene smoke logs exited `0` and keyword scans found no parse/invalid/missing-resource errors; Godot MCP runtime with `autosave=false` confirmed runtime tree nodes, clean initial endpoint lock, `before=false`, guard defeat `after=true`, duplicate activation `false`, local state flags true, endpoint texture path, Player `idle/run/jump` frames `3`, deep guard `idle/run/attack/hurt/death` frames `3`, clean game/editor logs, and screenshot `reports/visual/cinderpaw-mcp-old-factory-deep-route-micro-slice-20260626.png`.
- Blockers: None. Full Old Factory multi-room layout, Boss2, hidden boss, savepoints, minimap, new enemy family, and skill-tree UI remain out of scope.
- Next: continue another ACT-visible slice such as stronger Old Factory room pacing/patrol polish, gate unlock SFX/VFX, skill-tree spending UI, mainline Boss2 Double Jump reward source, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-012-old-factory-deep-route-unlock-feedback.md` — Old Factory Deep Route Unlock Feedback
- Files changed: `src/feature/factory_deep_route_endpoint.gd`, `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_deep_route_unlock_feedback_test.gd`, `assets/generated/source/factory_deep_route_unlock_spark_imagegen_20260626.png`, `assets/generated/source/factory_deep_route_unlock_spark_imagegen_20260626.png.import`, `assets/generated/source/factory_deep_route_unlock_spark_alpha_20260626.png`, `assets/generated/source/factory_deep_route_unlock_spark_alpha_20260626.png.import`, `assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`, `assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png.import`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/index.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/player-abilities/story-012-old-factory-deep-route-unlock-feedback.md`, `production/qa/evidence/old-factory-deep-route-unlock-feedback-2026-06-26.md`, `reports/old_factory_deep_route_unlock_feedback_factory_scene_smoke.log`, `reports/old_factory_deep_route_unlock_feedback_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-old-factory-deep-route-unlock-feedback-20260626.png`, `production/session-state/active.md`
- Implementation: Extended `FactoryDeepRouteEndpoint` with an image-generated one-shot unlock VFX texture, deterministic diagnostics (`get_unlock_vfx_texture_path()`, `get_unlock_vfx_snapshot()`), a test hook (`advance_unlock_vfx_time()`), and duplicate/replay guards. Successful endpoint activation now spawns exactly one short-lived `Sprite2D` named `UnlockVfx`; `set_activated(true)` restores endpoint state without replaying feedback. `OldFactoryEntranceScene.get_factory_deep_route_diagnostics()` now exposes unlock feedback texture, active/playback state, and spawn count for tests and MCP probes. `factory_route_transition_shell.tscn` explicitly references the imported unlock VFX texture.
- Asset pipeline: Generated the Old Factory deep-route unlock spark through image generation, preserved source at `assets/generated/source/factory_deep_route_unlock_spark_imagegen_20260626.png`, removed chroma key to `assets/generated/source/factory_deep_route_unlock_spark_alpha_20260626.png`, cropped/resized to `assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`, imported it through Godot, and recorded it in the asset manifest and entity inventory.
- Test written: `tests/unit/gameplay/old_factory_deep_route_unlock_feedback_test.gd` with five focused tests covering imported generated VFX texture/no-placeholder contract, one-shot activation spawn metadata, duplicate activation suppression, deterministic expiry, and restore-without-replay.
- Verification: RED focused failed on missing endpoint unlock VFX API/behavior (`reports/report_667/`); GREEN focused Story012 passed `5/5` (`reports/report_668/`); Story010-011 regression passed `8/8` (`reports/report_669/`); broader Old Factory scene regression passed `14/14` (`reports/report_670/`); final combined focused/related submission regression passed `27/27` (`reports/report_671/`); Godot import registered updated endpoint scripts and PNG imports; headless Factory and main-scene smoke logs exited `0`, keyword scans found no parse/invalid/missing-resource errors, and the main-scene smoke only retained known cleanup-time ObjectDB/resource messages already seen in earlier logs. Godot MCP runtime with `autosave=false` confirmed the saved custom Factory scene contains cache, steam vent, deep guard, and endpoint nodes; endpoint activation returned `true`, duplicate activation returned `false`, `UnlockVfx` existed with active_count `1`, texture path `res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png`, source metadata `image_generation`, clean game/editor logs, and screenshot `reports/visual/cinderpaw-mcp-old-factory-deep-route-unlock-feedback-20260626.png`.
- Blockers: None. Full Old Factory multi-room layout, Boss2, hidden boss, savepoints, minimap, new enemy family, full gate dissolve system, and SFX expansion remain out of scope.
- Next: continue another ACT-visible slice such as broader gate unlock SFX/VFX, skill-tree spending UI, mainline Boss2 Double Jump reward source, deeper Old Factory route/combat content, savepoint/minimap gameplay, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-013-old-factory-spark-rat-patrol-encounter.md` — Old Factory Spark Rat Patrol Encounter
- Files changed: `src/characters/factory_spark_rat.gd`, `src/characters/factory_spark_rat.gd.uid`, `src/gameplay/factory_spark_rat.gd`, `src/gameplay/factory_spark_rat.gd.uid`, `src/gameplay/factory_spark_rat.tscn`, `scenes/characters/factory_spark_rat.tscn`, `scenes/factory_route_transition_shell.tscn`, `src/gameplay/old_factory_entrance_scene.gd`, `tests/unit/gameplay/old_factory_spark_rat_patrol_encounter_test.gd`, `tests/unit/gameplay/old_factory_spark_rat_patrol_encounter_test.gd.uid`, `assets/characters/factory_spark_rat/**`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/index.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/player-abilities/story-013-old-factory-spark-rat-patrol-encounter.md`, `production/qa/evidence/old-factory-spark-rat-patrol-encounter-2026-06-26.md`, `reports/old_factory_spark_rat_patrol_factory_scene_smoke.log`, `reports/old_factory_spark_rat_patrol_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-old-factory-spark-rat-patrol-encounter-20260626.png`, `production/session-state/active.md`
- Implementation: Added a distinct `FactorySparkRat` enemy family for the Old Factory route. The visible character scene uses `AnimatedSprite2D + SpriteFrames` and is mounted through a gameplay `CharacterBody2D` scene that reuses the Rat Minion combat loop with spark-rat-specific attack metadata. `OldFactoryEntranceScene` now owns deterministic entity id `2102`, exposes `try_activate_factory_spark_rat()`, `is_factory_spark_rat_defeated()`, and `get_factory_spark_rat_diagnostics()`, gates activation behind deep-route endpoint completion, routes player damage to the spark rat, disables it on defeat, and persists `factory_spark_rat_activated` / `factory_spark_rat_defeated` in scene-local state. `factory_route_transition_shell.tscn` now mounts the spark rat near the deep route while preserving the existing entrance guard, cache, steam vent, deep guard, endpoint, VFX, player, and backdrop.
- Asset pipeline: Generated the spark rat sprite sheet through image generation, preserved source at `assets/characters/factory_spark_rat/source/factory_spark_rat_sprite_sheet_imagegen_20260626.png`, removed chroma key to `assets/characters/factory_spark_rat/source/factory_spark_rat_sprite_sheet_alpha_20260626.png`, sliced it into transparent 96x96 PNG frames under `assets/characters/factory_spark_rat/{idle,run,attack,hurt,death}/`, imported those PNGs through Godot, and assembled `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres` with five 3-frame gameplay animations. Source prompt, runtime paths, and import status are recorded in the asset manifest and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_spark_rat_patrol_encounter_test.gd` with four focused tests covering the character asset/frame-animation contract, initial inactive but visible route mount, endpoint-gated activation with target/collision/process restoration, damage/defeat routing, and local state restore without endpoint VFX replay.
- Verification: RED focused failed as expected on missing spark-rat scene/script/SpriteFrames/runtime API (`reports/report_672/`); GREEN focused Story013 passed `4/4` (`reports/report_681/`); related Old Factory regression passed `24/24` across unlock feedback, deep guard activation pacing, deep route micro-slice, entrance combat, room-clear cache, and steam vent hazard (`reports/report_675/` through `reports/report_680/`); Godot import exited `0`; headless Factory and main-scene smoke logs exited `0` with no parse/invalid/missing-resource/resource-load failures; Godot MCP runtime with `autosave=false` confirmed `FactorySparkRat/Sprite` is `AnimatedSprite2D`, SpriteFrames path `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`, `idle/run/attack/hurt/death` frame counts all `3`, activation changes collision from `0/0` to `2/17`, player damage defeats entity `2102`, defeated local state disables and hides it, game/editor logs are clean, and screenshot `reports/visual/cinderpaw-mcp-old-factory-spark-rat-patrol-encounter-20260626.png` shows generated character art rather than a placeholder block.
- Blockers: None. Full Old Factory multi-room layout, Boss2, hidden boss, savepoints, minimap, skill-tree UI, complex pathfinding, patrol spline tooling, shaders, SFX expansion, and final authored art replacement remain out of scope.
- Next: continue another ACT-visible slice such as Old Factory patrol/room pacing polish, gate unlock SFX, skill-tree spending UI, mainline Boss2 Double Jump reward source, savepoint/minimap gameplay, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-014-old-factory-spark-rat-attack-tell-feedback.md` — Old Factory Spark Rat Attack Tell Feedback
- Files changed: `src/gameplay/rat_minion.gd`, `src/gameplay/factory_spark_rat.gd`, `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`, `assets/characters/factory_spark_rat/attack_tell/*.png`, `assets/characters/factory_spark_rat/source/factory_spark_rat_attack_tell_*_20260626.png`, `tests/unit/gameplay/old_factory_spark_rat_attack_tell_feedback_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/index.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/player-abilities/story-014-old-factory-spark-rat-attack-tell-feedback.md`, `production/qa/evidence/old-factory-spark-rat-attack-tell-feedback-2026-06-26.md`, `reports/old_factory_spark_rat_attack_tell_factory_scene_smoke.log`, `reports/old_factory_spark_rat_attack_tell_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-old-factory-spark-rat-attack-tell-feedback-20260626.png`, `production/session-state/active.md`
- Implementation: Added a generated non-looping `attack_tell` animation to `FactorySparkRat` so attack startup has a distinct red warning/overcharge tell before the existing active bite `attack` animation. The shared `RatMinion` combat loop now asks `_get_attack_tell_animation()` during startup, defaulting to `attack`; `FactorySparkRat` overrides it to `attack_tell`, preserving its `factory_spark_rat_bite` metadata, `factory_spark_rat` source, and `9` base damage contract.
- Asset pipeline: Generated a 3-frame spark-rat warning strip through image generation, preserved the source at `assets/characters/factory_spark_rat/source/factory_spark_rat_attack_tell_sheet_imagegen_20260626.png`, removed chroma key to `assets/characters/factory_spark_rat/source/factory_spark_rat_attack_tell_sheet_alpha_20260626.png`, sliced it into transparent 96x96 PNG frames under `assets/characters/factory_spark_rat/attack_tell/`, imported those PNGs through Godot, and recorded the asset in the manifest and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_spark_rat_attack_tell_feedback_test.gd` with four focused tests covering generated transparent attack-tell frames, non-looping SpriteFrames registration, startup-to-active animation handoff, unchanged attack metadata/damage contract, and no visible placeholder nodes.
- Verification: RED focused failed as expected on missing `attack_tell` animation (`reports/report_684/`); GREEN focused passed `4/4` (`reports/report_686/`); final focused/related Old Factory regression passed `28/28` (`reports/report_689/`); Godot import exited `0`; headless Factory and main-scene smoke logs exited `0` with no parse/invalid/missing-resource/resource-load failures and only known cleanup-time resource messages. Godot MCP runtime with `autosave=false` confirmed `FactorySparkRat/Sprite` is `AnimatedSprite2D`, SpriteFrames path `res://assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`, `attack_tell` exists with `3` frames and `loop=false`, `request_attack()` starts on `attack_tell`, `advance_attack_frames(7)` switches to `attack`, metadata remains source `factory_spark_rat`, weapon id `factory_spark_rat_bite`, base damage `9`, game/editor logs are clean, and screenshot `reports/visual/cinderpaw-mcp-old-factory-spark-rat-attack-tell-feedback-20260626.png` shows generated character art rather than a placeholder block.
- Blockers: None. Endpoint activation, patrol spline tooling, dodge-counter windows, Boss2, hidden boss, new rooms, savepoints, minimap, SFX, shaders, and final authored art replacement remain out of scope.
- Next: continue another ACT-visible slice such as Spark Rat patrol/room pacing polish, dodge-counter readability, gate unlock SFX, skill-tree spending UI, mainline Boss2 Double Jump reward source, savepoint/minimap gameplay, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-015-old-factory-spark-rat-dodge-counter-readability.md` — Old Factory Spark Rat Dodge-Counter Readability
- Files changed: `src/gameplay/player_controller.gd`, `src/gameplay/rat_minion.gd`, `src/gameplay/old_factory_entrance_scene.gd`, `tests/unit/gameplay/old_factory_spark_rat_dodge_counter_readability_test.gd`, `production/epics/index.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/player-abilities/story-015-old-factory-spark-rat-dodge-counter-readability.md`, `production/qa/evidence/old-factory-spark-rat-dodge-counter-readability-2026-06-26.md`, `reports/old_factory_spark_rat_dodge_counter_factory_scene_smoke.log`, `reports/old_factory_spark_rat_dodge_counter_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-old-factory-spark-rat-dodge-counter-readability-20260626.png`, `production/session-state/active.md`
- Implementation: `PlayerController.request_dodge()` now starts the Core `CombatComponent` dodge state alongside the visible player dodge, preserves existing dodge animation/afterimage behavior, aligns visible dodge duration with the existing Core dodge total, and exposes `is_dodge_iframe_active()` plus `get_dodge_counter_window()` for runtime integration. `PlayerController.apply_damage()` now uses Core i-frames rather than the whole visible dodge state for dodge invulnerability. `RatMinion` exposes `get_current_enemy_attack_metadata()`, active-frame state, and attack sequence ids for deterministic scene probes. `OldFactoryEntranceScene` now resolves the active Factory Spark Rat bite against the player's Core dodge i-frame state, rejects inactive-frame and duplicate same-sequence bite resolution, records deterministic counter diagnostics, preserves the 9-damage `factory_spark_rat_bite` contract, and exposes those diagnostics through `get_factory_spark_rat_counter_diagnostics()` and the existing Spark Rat diagnostics payload.
- Asset pipeline: No new visual assets were generated in this story. The implementation reuses the Story013/Story014 image-generated Factory Spark Rat `AnimatedSprite2D + SpriteFrames` assets and `attack_tell` animation. A new MCP runtime screenshot was saved to `reports/visual/cinderpaw-mcp-old-factory-spark-rat-dodge-counter-readability-20260626.png`.
- Test written: `tests/unit/gameplay/old_factory_spark_rat_dodge_counter_readability_test.gd` with five focused tests covering bite dodged during player i-frames, visible dodge before Core i-frames still taking damage, active-frame-only bite resolution, one bite resolution per attack sequence, 30-frame Cat Claw counter window opening, Cat Claw counter bonus injection/one-shot consumption, and non-dodged Spark Rat bite damage.
- Verification: RED focused failed as expected on missing Story015 scene APIs (`reports/report_691/`); post-review RED refinement failed on duplicate same-sequence resolution overwriting last valid bite diagnostics (`reports/report_698/`); GREEN focused Story015 passed `5/5` (`reports/report_699/`); related combat/Spark Rat regression passed `27/27` (`reports/report_700/`); broader Old Factory regression passed `37/37` (`reports/report_701/`); `git diff --check` passed; Godot import exited `0`; headless Factory and main-scene smoke logs exited `0` and keyword scans found no parse/invalid/missing-resource errors. Godot MCP runtime with `autosave=false` confirmed `FactorySparkRat/Sprite` is `AnimatedSprite2D`, `attack_tell` has `3` frames and `loop=false`, Spark Rat attack transitions `attack_tell -> attack`, attack-tell resolution applies no damage, active bite applies exactly `9` damage once, repeated same-sequence resolution applies no further damage and preserves last valid bite diagnostics, player dodge i-frame negates `factory_spark_rat_bite` damage (`100 -> 100`), counter diagnostics report `counter_ready=true`, `counter_window_frames=30`, and `last_bite_weapon_id=factory_spark_rat_bite`, Cat Claw hit applies `claw_counter_crit_window_bonus_frames=3`, Spark Rat HP changes `24 -> 12`, counter window is consumed to `0`, game/editor logs are clean, and screenshot `reports/visual/cinderpaw-mcp-old-factory-spark-rat-dodge-counter-readability-20260626.png` is nonblank with visible generated Old Factory/Spark Rat runtime art.
- Blockers: None. Spark Rat patrol pacing, NavigationAgent2D, patrol splines, new rooms, Boss2, hidden boss, savepoints, minimap, skill-tree UI, SFX, shaders, loot/economy, and full enemy AI rewrite remain out of scope.
- Next: continue another ACT-visible slice such as Spark Rat pacing polish, skill-tree spending UI, mainline Boss2 Double Jump reward source, additional ExplorationGate ability doors, broader gate unlock SFX/VFX, deeper Old Factory route/combat content, savepoint/minimap gameplay, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-016-ability-gate-unlock-feedback.md` — Ability Gate Unlock Feedback
- Files changed: `src/feature/exploration_gate.gd`, `src/gameplay/main_scene.gd`, `src/presentation/audio_system.gd`, `tests/unit/gameplay/exploration_gate_unlock_feedback_test.gd`, `tests/unit/presentation/audio_system_test.gd`, `assets/environment/ability_gate/vfx/vfx_ability_gate_unlock_dissolve_burst_256.png`, `assets/generated/source/vfx_ability_gate_unlock_dissolve_burst_*_20260626.png`, `assets/audio/sfx/sfx_door_unlock_baseline_short.wav`, `assets/audio/source/ability_gate_unlock_sfx_generation_20260626.json`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/index.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/player-abilities/story-016-ability-gate-unlock-feedback.md`, `production/qa/evidence/ability-gate-unlock-feedback-2026-06-26.md`, `reports/ability_gate_unlock_feedback_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-ability-gate-unlock-feedback-20260626.png`, `production/session-state/active.md`
- Implementation: `ExplorationGate` now exposes deterministic unlock-feedback diagnostics, spawns one generated `Sprite2D` dissolve burst on a fresh `unlockable -> unlocked` transition, expires the VFX through a testable timer, and suppresses replay on duplicate unlock, `refresh_gate_state()`, and `set_gate_unlocked(true)` restore. `MainScene` forwards fresh gate unlocks to `AudioSystem.on_exploration_gate_unlocked(...)` with gate id, required ability, target area, and world position. `AudioSystem` maps the event to imported `sfx_door_unlock` playback while preserving silent-safe stream behavior.
- Asset pipeline: Generated the shared ability-gate unlock burst through image generation, preserved source and alpha-matted source PNGs, cropped/resized to `assets/environment/ability_gate/vfx/vfx_ability_gate_unlock_dissolve_burst_256.png`, imported it through Godot, and recorded it in the asset manifest and QA evidence. Generated a replaceable 0.52s mono PCM `sfx_door_unlock_baseline_short.wav` with source recipe `assets/audio/source/ability_gate_unlock_sfx_generation_20260626.json`.
- Test written: `tests/unit/gameplay/exploration_gate_unlock_feedback_test.gd` with three focused tests covering Dash gate VFX/audio once, Double Jump gate shared feedback contract, duplicate/refresh suppression, deterministic VFX expiry, and save-restore no-replay. `tests/unit/presentation/audio_system_test.gd` now covers `sfx_door_unlock` registration and exploration-gate unlock routing.
- Verification: RED focused failed as expected for missing gate feedback/API (`reports/report_702/`) and missing AudioSystem door-unlock cue/adapter (`reports/report_703/`); GREEN focused gate feedback passed `3/3` (`reports/report_705/`); GREEN focused AudioSystem passed `21/21` (`reports/report_706/`); related split regressions passed `7/7`, `21/21`, and `28/28` (`reports/report_708/`, `reports/report_709/`, `reports/report_710/`); pre-commit focused verification passed `24/24` across Story016 gate feedback and AudioSystem (`reports/report_711/`); Godot import exited `0`; headless main-scene smoke exited `0` with no parse/invalid/missing-resource/resource-load failures and only known cleanup-time ObjectDB/resource messages. Godot MCP runtime confirmed restore no-replay, Dash and Double Jump ability-triggered gate VFX as generated `Sprite2D` nodes, MainScene-to-AudioSystem `exploration_gate_unlocked -> sfx_door_unlock` events with `stream_found=true` and correct metadata for both gates, clean game/editor logs, and nonblank screenshot `reports/visual/cinderpaw-mcp-ability-gate-unlock-feedback-20260626.png`.
- Blockers: None. New ability gates, ability acquisition feedback, minimap/fast travel, save schema changes, shader polish, final mastered audio, and Dash/Double Jump movement-feel changes remain out of scope.
- Next: continue another ACT-visible slice such as Spark Rat pacing polish, skill-tree spending UI, mainline Boss2 Double Jump reward source, additional ExplorationGate ability doors, deeper Old Factory route/combat content, savepoint/minimap gameplay, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-018-skill-tree-cat-claw-t1a-first-spend.md` — Skill Tree Cat Claw T1-A First Spend
- Files changed: `data/manifest.json`, `data/skill_tree.json`, `data/schemas/skill_tree.schema.json`, `src/feature/skill_tree_manager.gd`, `src/gameplay/main_scene.gd`, `src/gameplay/player_controller.gd`, `src/core/weapon_component.gd`, `src/presentation/hud_manager.gd`, `tests/unit/gameplay/skill_tree_spending_ui_runtime_test.gd`, `production/epics/index.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/player-abilities/story-018-skill-tree-cat-claw-t1a-first-spend.md`, `production/qa/evidence/skill-tree-cat-claw-t1a-first-spend-2026-06-26.md`, `reports/skill_tree_cat_claw_t1a_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-skill-tree-cat-claw-t1a-20260626.png`, `production/session-state/active.md`
- Implementation: Added the `skill_tree` DataManager domain and a scene-local `SkillTreeManager` for unlocked skill state and modifier queries. `MainScene` now wires the manager, exposes Skill Tree runtime APIs, spends Rat King SP on Cat Claw T1-A once, persists `unlocked_skills`, refreshes HUD state, and forwards menu audio. `HUDManager` adds the minimal Skill Tree menu, signals, unlock button, and diagnostics. `PlayerController` consumes `light_attack_2` skill modifiers for Cat Claw and applies the 8px lunge only after the Core weapon hitbox activates; `WeaponComponent` carries the lunge metadata and hitbox offset into the collision chain.
- Asset pipeline: No new visual assets were generated. This story reuses existing image-generated Cinderpaw, environment, and gate feedback assets; MCP evidence confirms the player remains `AnimatedSprite2D + SpriteFrames`.
- Test written: `tests/unit/gameplay/skill_tree_spending_ui_runtime_test.gd` with two focused tests covering Rat King SP spend into Cat Claw T1-A, HUD state, modifier payload, attack lunge metadata, hitbox offset, runtime progress, save snapshot, and restore.
- Verification: RED `reports/report_719/`; GREEN focused before refactor `reports/report_720/` `2/2`; related before refactor `reports/report_723/` `42/42`; final focused after refactor `reports/report_724/` `2/2`; final related `reports/report_725/` `42/42`; headless main-scene smoke `reports/skill_tree_cat_claw_t1a_main_scene_smoke.log` exited `0` and keyword scan found no parse/invalid/missing-resource errors. Godot MCP runtime with `autosave=false` confirmed `/Main/SkillTreeManager`, Player `AnimatedSprite2D + SpriteFrames`, Rat King reward `0 -> 5` SP, Skill Tree HUD, unlock `true`, SP `5 -> 4`, modifier payload, second Cat Claw attack `+8px` lunge and metadata, clean game/editor logs, and screenshot `reports/visual/cinderpaw-mcp-skill-tree-cat-claw-t1a-20260626.png`.
- Blockers: None. Full 65-node skill tree, reset economy, graph UI, NPC mentor flow, other weapon branches, charm F8 combined bonus, Boss2, additional ability gates, savepoint/minimap gameplay, and final localization remain out of scope.
- Next: continue another ACT-visible slice such as mainline Boss2 Double Jump reward source, additional ExplorationGate ability doors, deeper Old Factory route/combat content, savepoint/minimap gameplay, more skill-tree branches, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-019-parry-laser-gate-runtime.md` — Parry Laser Gate Runtime
- Files changed: `src/gameplay/player_controller.gd`, `scenes/main.tscn`, `assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`, `assets/characters/cinderpaw/parry/cinderpaw_parry_000.png`, `assets/characters/cinderpaw/parry/cinderpaw_parry_001.png`, `assets/characters/cinderpaw/parry/cinderpaw_parry_002.png`, `assets/characters/cinderpaw/source/cinderpaw_parry_strip_imagegen_20260626.png`, `assets/characters/cinderpaw/source/cinderpaw_parry_strip_alpha_20260626.png`, `tests/unit/gameplay/player_parry_laser_gate_runtime_test.gd`, `design/assets/asset-manifest.md`, `production/epics/index.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/player-abilities/story-019-parry-laser-gate-runtime.md`, `production/qa/evidence/parry-laser-gate-runtime-2026-06-26.md`, `reports/parry_laser_gate_runtime_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-parry-laser-gate-runtime-20260626.png`, `production/session-state/active.md`
- Implementation: Added a generated three-frame Cinderpaw `parry` animation to the player SpriteFrames resource and connected `PlayerController.request_parry()` to AbilityComponent's initial `parry` ability plus Core CombatComponent `PARRYING`. The method now checks Core combat readiness before consuming the 0.3s ability cooldown, so blocked states such as CHARGING reject parry without emitting `ability_activated`. `scenes/main.tscn` now includes `ParryLaserExplorationGate` with `gate_id="parry_laser_central_tower"`, `required_ability="parry"`, and `target_area_id="area_05_central_tower"`; runtime parry in range unlocks it, disables collision, and persists the gate and area flags into the save snapshot.
- Asset pipeline: Generated the Cinderpaw parry strip through image generation, preserved source at `assets/characters/cinderpaw/source/cinderpaw_parry_strip_imagegen_20260626.png`, removed chroma key to `assets/characters/cinderpaw/source/cinderpaw_parry_strip_alpha_20260626.png`, sliced it into transparent 96x96 PNG frames under `assets/characters/cinderpaw/parry/`, imported those PNGs through Godot, and recorded the asset in the manifest and QA evidence.
- Test written: `tests/unit/gameplay/player_parry_laser_gate_runtime_test.gd` with four focused tests covering generated parry frames, parry activation/cooldown/combat state, blocked-combat cooldown ordering, MainScene parry laser gate unlock, collision state, and save/restore persistence.
- Verification: RED `reports/report_726/`; RED import refinement `reports/report_727/`; GREEN focused before cooldown-order refinement `reports/report_728/` `3/3`; related before refinement `reports/report_729/` `25/25`; blocked-combat cooldown-order RED `reports/report_730/`; final focused `reports/report_731/` `4/4`; final related `reports/report_732/` `26/26`; Godot import exited `0`; headless main-scene smoke `reports/parry_laser_gate_runtime_main_scene_smoke.log` exited `0` and keyword scan found no parse/invalid/missing-resource/resource-load failures. Godot MCP runtime with `autosave=false` confirmed `/Main/ParryLaserExplorationGate`, Player `AnimatedSprite2D`, SpriteFrames path `res://assets/characters/cinderpaw/cinderpaw_sprite_frames.tres`, `parry` has `3` frames from `assets/characters/cinderpaw/parry/`, `request_parry()` returns `true`, gate state changes `unlockable -> unlocked`, collision blocking changes `true -> false`, save flags are written, game/editor logs are clean, and screenshot `reports/visual/cinderpaw-mcp-parry-laser-gate-runtime-20260626.png` is nonblank.
- Blockers: None. Full Central Tower scene, final laser-gate art replacement, full parry success/counterattack presentation, parry SFX, aerial attack gate, wall-climb gate, Boss2, minimap/fast travel, and parry skill-tree modifiers remain out of scope.
- Next: continue another ACT-visible slice such as mainline Boss2 Double Jump reward source, another ExplorationGate ability door, deeper Old Factory route/combat content, savepoint/minimap gameplay, more skill-tree branches, parry success presentation/audio, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-020-parry-success-feedback-runtime.md` — Parry Success Feedback Runtime
- Files changed: `src/gameplay/main_scene.gd`, `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd`, `production/epics/index.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/player-abilities/story-020-parry-success-feedback-runtime.md`, `production/qa/evidence/parry-success-feedback-runtime-2026-06-26.md`, `reports/parry_success_feedback_runtime_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-parry-success-feedback-runtime-20260626.png`, `production/session-state/active.md`
- Implementation: `MainScene` now connects the player's Core `CombatComponent.on_parry_resolved` signal and forwards enriched parry metadata to `CombatPresentation.on_parry_event()` and `AudioSystem.on_parry_event()`. The bridge preserves Core `is_success`, `parry_type`, and `parry_frame` fields, adds the visible Cinderpaw sprite `position`, and marks `source="player_parry"` so VFX/SFX land at the character instead of `(0,0)`. PERFECT parry now produces the existing GDD-tuned feedback in the main runtime scene: 8 frames hitstop, 8.0 shake, one flash overlay, 22 radial parry sparks, and `sfx_parry_perfect`; GOOD parry is forwarded without triggering PERFECT-only flash/sparks.
- Asset pipeline: No new visual/audio assets were generated. This story reuses existing image-generated parry flash/spark assets, Story019 Cinderpaw `parry` SpriteFrames, and imported `sfx_parry_perfect` / `sfx_parry_good` cues.
- Test written: `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd` now covers PERFECT parry feedback bridge and GOOD parry no-perfect-visual behavior through the main-scene runtime player flow.
- Verification: RED `reports/report_733/`; initial GREEN focused `reports/report_734/` `8/8`; final focused after GOOD-parry negative coverage `reports/report_736/` `9/9`; final related regression `reports/report_737/` `72/72`; headless main-scene smoke `reports/parry_success_feedback_runtime_main_scene_smoke.log` exited `0` and keyword scan found no script/parse/invalid/resource-load errors. Godot MCP runtime with `autosave=false` confirmed Player `AnimatedSprite2D + SpriteFrames`, `parry` frame count `3`, `request_parry()` true, PERFECT metadata, presentation flash/spark/hitstop/shake counts, `sfx_parry_perfect` with `stream_found=true` at the sprite position, clean game/editor logs, and screenshot `reports/visual/cinderpaw-mcp-parry-success-feedback-runtime-20260626.png`.
- Blockers: None. New parry VFX/SFX assets, enemy stun/counter damage expansion, parry skill-tree modifiers, late-parry feedback, full performance profiling, global hitstop refactors, Central Tower route content, and laser-gate art replacement remain out of scope.
- Next: continue another ACT-visible slice such as mainline Boss2 Double Jump reward source, additional ExplorationGate ability doors, deeper Old Factory route/combat content, savepoint/minimap gameplay, more skill-tree branches, broader frame-animation audit, or late-parry feedback design if prioritized.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/death-respawn/story-007-main-scene-savepoint-runtime.md` — Main Scene Savepoint Runtime
- Files changed: `src/feature/savepoint_runtime.gd`, `src/feature/savepoint_runtime.gd.uid`, `src/gameplay/main_scene.gd`, `scenes/main.tscn`, `tests/unit/gameplay/main_scene_savepoint_runtime_test.gd`, `tests/unit/gameplay/main_scene_savepoint_runtime_test.gd.uid`, `assets/generated/source/scrap_roost_savepoint_imagegen_20260626.png`, `assets/generated/source/scrap_roost_savepoint_imagegen_20260626.png.import`, `assets/generated/source/scrap_roost_savepoint_alpha_20260626.png`, `assets/generated/source/scrap_roost_savepoint_alpha_20260626.png.import`, `assets/environment/savepoints/scrap_roost_savepoint.png`, `assets/environment/savepoints/scrap_roost_savepoint.png.import`, `design/assets/asset-manifest.md`, `production/epics/death-respawn/EPIC.md`, `production/epics/death-respawn/story-007-main-scene-savepoint-runtime.md`, `production/epics/index.md`, `production/qa/evidence/main-scene-savepoint-runtime-2026-06-26.md`, `reports/visual/cinderpaw-mcp-main-scene-savepoint-runtime-20260626.png`, `README.md`, `production/session-state/active.md`
- Implementation: Added `SavepointRuntime` as a scene-local savepoint trigger component and mounted `ScrapRoostSavepoint` in `res://scenes/main.tscn` with generated transparent PNG art, prompt text, `Area2D`, enabled `CollisionShape2D`, and stable IDs `scrap_roost/main/scrap_roost`. `MainScene` now discovers runtime savepoints, handles `savepoint_activated`, records the last discovered savepoint, sends a savepoint autosave through the existing SaveSystem trigger adapter, and keeps same-main-scene load restore stable when the root `SceneManager` still has a stale pending `main` async request from earlier test/runtime handoff.
- Asset pipeline: Generated the Scrap Roost savepoint prop through image generation, preserved source at `assets/generated/source/scrap_roost_savepoint_imagegen_20260626.png`, removed chroma key to `assets/generated/source/scrap_roost_savepoint_alpha_20260626.png`, cropped/resized to `assets/environment/savepoints/scrap_roost_savepoint.png`, imported it through Godot, and recorded it in the asset manifest and QA evidence.
- Test written: `tests/unit/gameplay/main_scene_savepoint_runtime_test.gd` with three focused tests covering visible generated savepoint contract, player contact discovery/autosave slot `0`, and non-boss death respawn at `main/scrap_roost`.
- Verification: RED focused failed on missing main-scene savepoint (`reports/report_739/`); import RED caught missing Godot import metadata before import (`reports/report_740/`); GREEN focused Story007 passed `3/3` (`reports/report_752/`); related save/respawn/title regression passed `29/29` (`reports/report_755/`); Godot import exited `0`; headless main-scene smoke exited `0` with no script/parse/invalid/missing-resource failures and only known cleanup-time ObjectDB/resource messages. Godot MCP runtime with `autosave=false` confirmed `/Main/ScrapRoostSavepoint`, generated texture path, area/collision, SaveSystem sync autosave under `user://cinderpaw_mcp_main_scene_savepoint_runtime/`, `autosave_reason=savepoint`, `last_savepoint.id=scrap_roost`, non-boss respawn source `savepoint`, player position `(210, 432)`, clean game/editor logs after clearing eval-only warning, and screenshot `reports/visual/cinderpaw-mcp-main-scene-savepoint-runtime-20260626.png`.
- Blockers: None. Full savepoint network, savepoint UI polish, minimap icons, fast travel, hub scene, and broader route savepoint placement remain out of scope.
- Next: continue another ACT-visible slice such as Boss2/hidden-boss Double Jump payoff, additional savepoint network/minimap integration, deeper Old Factory combat content, more skill-tree branches, parry follow-up feedback, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-021-mainline-boss2-double-jump-payoff-shell.md` — Mainline Boss2 Double Jump Payoff Shell
- Files changed: `src/feature/ability_reward_source.gd`, `src/gameplay/main_scene.gd`, `src/gameplay/boss2_echo_guardian.gd`, `src/gameplay/boss2_echo_guardian.tscn`, `src/characters/boss2_echo_guardian.gd`, `scenes/characters/boss2_echo_guardian.tscn`, `scenes/main.tscn`, `assets/characters/boss2_echo_guardian/**`, `assets/environment/double_jump_reward/boss2_double_jump_reward_source.png`, `assets/generated/source/boss2_double_jump_reward_source_*_20260626.png`, `tests/unit/gameplay/boss2_double_jump_payoff_runtime_test.gd`, `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/index.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/player-abilities/story-021-mainline-boss2-double-jump-payoff-shell.md`, `production/qa/evidence/mainline-boss2-double-jump-payoff-shell-2026-06-26.md`, `reports/visual/cinderpaw-mcp-mainline-boss2-double-jump-payoff-shell-20260626.png`, `production/session-state/active.md`
- Implementation: Added a mainline Boss2 payoff shell in `res://scenes/main.tscn`. `Boss2EchoGuardian` is a scene-local `CharacterBody2D` with entity id `2200`, deterministic damage routing through `MainScene.apply_damage(2200, ...)`, and generated `AnimatedSprite2D + SpriteFrames` art for `idle`, `attack`, `hurt`, and `death`. `Boss2DoubleJumpRewardSource` starts unavailable, becomes claimable on Boss2 defeat, unlocks `double_jump` through the existing `MainScene.unlock_ability()` path, remains idempotent with the hidden Double Jump path, and persists `boss_02_echo_guardian_defeated` / `boss_02_double_jump_claimed` plus high-platform gate unlock flags.
- Asset pipeline: Generated the Boss2 Echo Guardian sprite sheet and Boss2 Double Jump reward relic through image generation, preserved sources and alpha-matted sources, sliced Boss2 into transparent 160x128 PNG frames under `assets/characters/boss2_echo_guardian/<animation>/`, imported all PNGs through Godot, created `boss2_echo_guardian_sprite_frames.tres`, and recorded the runtime assets in the asset manifest and QA evidence.
- Test written: `tests/unit/gameplay/boss2_double_jump_payoff_runtime_test.gd` with three focused tests covering Boss2 frame-animation rules, Boss2 defeat to reward availability, reward claim to Double Jump and gate/save sync, and hidden-path/Boss2 idempotent restore playability. `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd` gained one regression test for stale root SceneManager pending-load pollution during MainScene menu load restore.
- Verification: RED focused `reports/report_756/`; intermediate idempotence RED `reports/report_757/`; GREEN focused `reports/report_758/` `3/3`; related regression RED `reports/report_762/` exposed stale SceneManager pending pollution; focused stale-pending RED `reports/report_768/`; focused GREEN after local MainScene restore fix `reports/report_769/` `10/10`; final related regression `reports/report_771/` `22/22`; headless main-scene smoke `reports/mainline_boss2_double_jump_payoff_shell_main_scene_smoke.log` exited `0` and keyword scan found no script/parse/invalid/resource-load errors. Godot MCP runtime with `autosave=false` confirmed `/Main/Boss2EchoGuardian`, `/Main/Boss2EchoGuardian/Sprite` as `AnimatedSprite2D`, SpriteFrames path `res://assets/characters/boss2_echo_guardian/boss2_echo_guardian_sprite_frames.tres`, `idle/attack/hurt/death` frame counts all `3`, initial reward unavailable, Boss2 HP `36`, `apply_damage(2200, 36)` true, reward claim true, Player gains `double_jump`, `request_double_jump()` true, `DoubleJumpExplorationGate` changes to `unlocked`, save snapshot records ability and world flags, game/editor logs are clean, and screenshot `reports/visual/cinderpaw-mcp-mainline-boss2-double-jump-payoff-shell-20260626.png` is nonblank.
- Blockers: None. Final Boss2 arena layout, multi-phase AI, authored boss music, cutscene/camera polish, minimap route updates, and full factory route content remain out of scope.
- Next: continue another ACT-visible slice such as final Boss2 arena AI/feel, additional ExplorationGate ability doors, deeper Old Factory route/combat content, savepoint/minimap gameplay, more skill-tree branches, authored audio replacement, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-022-boss2-echo-guardian-telegraph-strike.md` — Boss2 Echo Guardian Telegraph Strike
- Files changed: `src/gameplay/boss2_echo_guardian.gd`, `src/gameplay/main_scene.gd`, `tests/unit/gameplay/boss2_echo_guardian_telegraph_strike_test.gd`, `production/epics/player-abilities/EPIC.md`, `production/epics/player-abilities/story-022-boss2-echo-guardian-telegraph-strike.md`, `production/epics/index.md`, `production/qa/evidence/boss2-echo-guardian-telegraph-strike-2026-06-26.md`, `reports/visual/cinderpaw-mcp-boss2-echo-guardian-telegraph-strike-20260626.png`, `production/session-state/active.md`
- Implementation: Upgraded `Boss2EchoGuardian` from a defeat/reward shell into a minimal readable combat threat. Boss2 now owns scene-local `HealthComponent`, `CollisionComponent`, `CombatComponent`, and `StatusEffectComponent` instances, exposes deterministic attack APIs, starts `boss2_echo_swipe` through `startup -> active -> recovery`, activates a fixed-frame hitbox only during active frames, resolves `14` damage through the existing Core Collision/Combat path, records attack metadata, rejects re-entry during active attack windows, disables threat on defeat, and preserves the Story021 Double Jump reward flow. `MainScene` now injects the runtime damage calculator and Player attack target into Boss2, routes Boss2 hits to CombatPresentation and AudioSystem damage-taken feedback, and resolves player weapon hit effects to Boss2 when `target_id=2200` instead of defaulting to Rat King.
- Asset pipeline: No new visual assets were generated. This story reuses Story021 image-generated Boss2 `AnimatedSprite2D + SpriteFrames` assets under `assets/characters/boss2_echo_guardian/<animation>/` and produced a new MCP evidence screenshot only.
- Test written: `tests/unit/gameplay/boss2_echo_guardian_telegraph_strike_test.gd` with four focused tests covering startup with inactive hitbox, active `boss2_echo_swipe` damage once, metadata/presentation damage-number contract, re-entry/recovery/defeat cleanup, restored-defeated flag threat cleanup, reward reveal compatibility, and MainScene target resolution for Boss2 player-hit effects.
- Verification: RED focused `reports/report_772/`; metadata refinement RED `reports/report_773/` and `reports/report_774/`; intermediate GREEN focused `reports/report_775/` before restored-defeated cleanup coverage; final focused/related regression `reports/report_777/` passed Story022 `4/4` and total `13/13` across Story022, Boss2 payoff, MainScene enemy attack Core chain, and MainScene player attack Core chain. Headless main-scene smoke `reports/boss2_echo_guardian_telegraph_strike_main_scene_smoke.log` exited `0`; keyword scan found no script/parse/invalid-call/missing-resource/resource-load errors and only the known cleanup-time ObjectDB/resource message. Godot MCP runtime with `autosave=false` confirmed `/Main/Boss2EchoGuardian`, `Sprite` as `AnimatedSprite2D`, SpriteFrames path `res://assets/characters/boss2_echo_guardian/boss2_echo_guardian_sprite_frames.tres`, `idle/attack/hurt/death` frame counts all `3`, startup phase with inactive hitbox, active phase with active `boss2_echo_swipe`, Player HP `100 -> 86`, duplicate hit check preserving HP `86`, damage number count `1`, metadata source/hitbox/weapon/target/final damage, Boss2 defeat, attack-after-defeat rejected, reward availability, in-range reward claim, Player `has_ability("double_jump")=true`, restored-defeated flag making Boss2 invisible/defeated with `hurtbox_state=gone`, inactive hitbox, zero body collision, clean game/editor logs, and screenshot `reports/visual/cinderpaw-mcp-boss2-echo-guardian-telegraph-strike-20260626.png`.
- Blockers: None. Multi-phase Boss2 AI, final arena layout, HP bar polish, authored boss music/SFX replacement, cutscene/camera polish, minimap route updates, and full factory route content remain out of scope.
- Next: continue another ACT-visible slice such as Boss2 arena polish/HP bar, authored Boss2 audio feedback, deeper Old Factory combat content, savepoint/minimap gameplay, more skill-tree branches, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-023-boss2-hud-focus-runtime.md` — Boss2 HUD Focus Runtime
- Files changed: `src/gameplay/main_scene.gd`, `tests/unit/gameplay/boss2_hud_focus_runtime_test.gd`, `production/epics/player-abilities/EPIC.md`, `production/epics/player-abilities/story-023-boss2-hud-focus-runtime.md`, `production/epics/index.md`, `production/qa/evidence/boss2-hud-focus-runtime-2026-06-26.md`, `reports/boss2_hud_focus_runtime_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-boss2-hud-focus-runtime-20260626.png`, `production/session-state/active.md`
- Implementation: Added a scene-local Boss2 HUD focus selector in `MainScene`. The existing boss HUD now prefers visible, undefeated `Boss2EchoGuardian` over Rat King while Boss2 is active, refreshes from Boss2 `boss_health_changed`, keeps Rat King HP and phase updates from stealing the HUD focus, and falls back to the existing Rat King HUD when Boss2 is defeated or restored as defeated. Story021 Double Jump payoff and Story022 Boss2 telegraph strike behavior remain unchanged.
- Asset pipeline: No new visual assets were generated. This story reuses the existing HUD and Story021 image-generated Boss2 `AnimatedSprite2D + SpriteFrames` assets under `assets/characters/boss2_echo_guardian/<animation>/`.
- Test written: `tests/unit/gameplay/boss2_hud_focus_runtime_test.gd` with four focused tests covering initial Boss2 HUD focus, Boss2 damage changing the HUD from `36/36` to `22/36`, Rat King health updates not overriding active Boss2 focus, Boss2 defeat fallback, and direct restored defeated flag fallback from active Boss2 focus.
- Verification: RED focused `reports/report_778/` failed as expected on the old `垃圾桶鼠王  Phase I  300/300` HUD label; GREEN focused `reports/report_782/` passed Story023 `4/4`; final related regression `reports/report_783/` passed `11/11` across Story023, Story022 Boss2 telegraph strike, and Story021 Boss2 Double Jump payoff. `git diff --check` passed. Headless main-scene smoke `reports/boss2_hud_focus_runtime_main_scene_smoke.log` exited `0`; keyword scan found no script/parse/invalid-call/missing-resource/resource-load errors. Godot MCP runtime with `autosave=false` confirmed initial HUD `Echo Guardian  Phase I  36/36`, Boss2 damage HUD `Echo Guardian  Phase I  22/36`, Rat King health and phase transition callbacks preserving Boss2 focus, Boss2 defeat fallback to `垃圾桶鼠王  Phase I  300/300`, clean game/editor logs, and screenshot `reports/visual/cinderpaw-mcp-boss2-hud-focus-runtime-20260626.png`.
- Blockers: None. Full Boss2 encounter reset/save-restore semantics, HP bar art/polish, boss portrait, final arena layout, multi-phase Boss2 UI, authored music/SFX, and a generic boss target manager remain out of scope.
- Next: continue another ACT-visible slice such as Boss2 arena AI/feel and reset semantics, authored Boss2 audio feedback, deeper Old Factory combat content, savepoint/minimap gameplay, more skill-tree branches, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-26

- Story: `production/epics/player-abilities/story-024-boss2-autonomous-pressure-runtime.md` — Boss2 Autonomous Pressure Runtime
- Files changed: `src/gameplay/boss2_echo_guardian.gd`, `tests/unit/gameplay/boss2_autonomous_pressure_runtime_test.gd`, `production/epics/player-abilities/EPIC.md`, `production/epics/player-abilities/story-024-boss2-autonomous-pressure-runtime.md`, `production/epics/index.md`, `production/qa/evidence/boss2-autonomous-pressure-runtime-2026-06-26.md`, `reports/boss2_autonomous_pressure_runtime_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-boss2-autonomous-pressure-runtime-20260626.png`, `production/session-state/active.md`
- Implementation: `Boss2EchoGuardian` now has a scene-local autonomous pressure loop. While visible, undefeated, targeted at the Player, outside `boss2_echo_swipe` range, and inside a 360px aggro window, Boss2 closes horizontal distance by a deterministic 3px frame step, reports `behavior_phase="chase"`, and then enters the existing `startup -> active -> recovery` attack chain when it reaches 108px attack range. The existing active `boss2_echo_swipe` hitbox, Core Collision/Combat damage path, duplicate-hit suppression, Story021 Double Jump reward, and Story023 HUD fallback are preserved. The story adds `advance_behavior_frames(frames)` and `get_auto_pressure_diagnostics()` for deterministic test/MCP probes and guards target validity before auto-attacking.
- Asset pipeline: No new visual assets were generated. This story reuses Story021 image-generated Boss2 `AnimatedSprite2D + SpriteFrames` assets under `assets/characters/boss2_echo_guardian/<animation>/`. Temporary chase presentation stays on the existing `idle` animation; a dedicated Boss2 run/chase animation is future polish.
- Test written: `tests/unit/gameplay/boss2_autonomous_pressure_runtime_test.gd` with five focused tests covering main-scene start-distance chase, deterministic pressure diagnostics hooks, autonomous startup without direct `request_attack()`, inactive startup hitbox, active hit damage once through Core Collision/Combat, restored defeated flag stopping chase/pressure, and released stale attack targets rejecting manual/auto pressure.
- Verification: Initial RED focused `reports/report_784/` failed as expected on missing pressure hooks; post-review RED `reports/report_787/` failed as expected on stale released target validity/manual startup; final GREEN focused `reports/report_788/` passed Story024 `5/5`; final related regression `reports/report_789/` passed `16/16` across Story024, Story022 Boss2 telegraph strike, Story023 Boss2 HUD focus, and Story021 Boss2 Double Jump payoff. Headless main-scene smoke `reports/boss2_autonomous_pressure_runtime_main_scene_smoke.log` exited `0`; keyword scan found no script/parse/invalid-call/missing-resource/resource-load errors. Godot MCP runtime with `autosave=false` confirmed `/Main/Boss2EchoGuardian`, Player, HUD, Boss2 `AnimatedSprite2D + SpriteFrames` frame counts `idle/attack/hurt/death=3`, start distance `220 -> 217` after one behavior frame with `behavior_phase="chase"`, automatic startup at `target_distance_x=108` with inactive hitbox, active hitbox damage `100 -> 86`, duplicate hit preserving `86`, metadata source/weapon/hitbox/target/final damage, stale released target rejected (`valid_after_release=false`, `request_attack=false`, `behavior_phase="idle"`), defeated flag stopping movement and hitboxes, HUD fallback to `垃圾桶鼠王  Phase I  300/300`, reward available/claimable, clean game/editor logs, and screenshot `reports/visual/cinderpaw-mcp-boss2-autonomous-pressure-runtime-20260626.png`.
- Blockers: None. Boss2 run/chase animation, arena bounds, multi-phase AI, final balancing, boss portrait/HP bar polish, authored Boss2 SFX/music, cutscene/camera polish, and full route content remain out of scope.
- Next: continue another ACT-visible slice such as Boss2 run/chase frame animation, Boss2 arena bounds/reset semantics, authored Boss2 audio feedback, deeper Old Factory combat content, savepoint/minimap gameplay, more skill-tree branches, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-30

- Story: `production/epics/player-abilities/story-025-boss2-run-frame-animation-runtime.md` — Boss2 Run Frame Animation Runtime
- Files changed: `src/gameplay/boss2_echo_guardian.gd`, `assets/characters/boss2_echo_guardian/boss2_echo_guardian_sprite_frames.tres`, `assets/characters/boss2_echo_guardian/run/boss2_echo_guardian_run_000.png`, `assets/characters/boss2_echo_guardian/run/boss2_echo_guardian_run_001.png`, `assets/characters/boss2_echo_guardian/run/boss2_echo_guardian_run_002.png`, `assets/characters/boss2_echo_guardian/source/boss2_echo_guardian_run_sheet_imagegen_20260626.png`, `assets/characters/boss2_echo_guardian/source/boss2_echo_guardian_run_sheet_alpha_20260626.png`, `tests/unit/gameplay/boss2_autonomous_pressure_runtime_test.gd`, `tests/unit/gameplay/boss2_double_jump_payoff_runtime_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/index.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/player-abilities/story-025-boss2-run-frame-animation-runtime.md`, `production/qa/evidence/boss2-run-frame-animation-runtime-2026-06-30.md`, `reports/boss2_run_frame_animation_runtime_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-boss2-run-frame-animation-runtime-20260626.png`, `production/session-state/active.md`
- Implementation: Generated and imported a three-frame Boss2 Echo Guardian `run` animation so the Story024 autonomous chase no longer slides on `idle`. The run source strip is preserved under `assets/characters/boss2_echo_guardian/source/`, alpha-matted, sliced into transparent 160x128 PNGs under `assets/characters/boss2_echo_guardian/run/`, and connected to `boss2_echo_guardian_sprite_frames.tres` as a looped `run` animation. `Boss2EchoGuardian` now plays `run` while `behavior_phase="chase"` and returns to `attack` for startup/active frames; `_play_animation()` avoids restarting an already-playing animation so `run` can advance during sustained chase.
- Asset pipeline: Used built-in image generation with green chroma key, kept the generated source and alpha source, cleared visible green-edge residue from the sliced frames, ran Godot import, and recorded the generated frame paths in the asset manifest, entity inventory, Story025, and QA evidence.
- Test written: `tests/unit/gameplay/boss2_autonomous_pressure_runtime_test.gd` now asserts chase plays `run`, startup switches back to `attack`, and defeated/stale-target paths do not remain in `run`; `tests/unit/gameplay/boss2_double_jump_payoff_runtime_test.gd` now requires Boss2 `run` frame-animation rules and sequential paths.
- Verification: RED `reports/report_791/` failed as expected because chase still played `idle` and `run` was missing; GREEN focused `reports/report_796/` passed Story024/025 autonomous pressure `6/6`, including sustained chase frame advancement; Boss2 asset/payoff regression `reports/report_798/` passed `3/3`; HUD regression `reports/report_797/` passed `4/4`; telegraph regression rerun `reports/report_799/` passed `4/4`. Godot import exited `0`; headless main-scene smoke `reports/boss2_run_frame_animation_runtime_main_scene_smoke.log` exited `0` and keyword scan found no script/parse/invalid/missing-resource errors. Godot MCP runtime confirmed `/Main/Boss2EchoGuardian/Sprite` as `AnimatedSprite2D`, `run` frame count `3` with 160x128 textures from the run folder, chase `behavior_phase="chase"` with `sprite.animation="run"`, an already advanced run frame (`frame=1`, `frame_progress=0.25`) preserved through 25 deterministic chase frames instead of resetting to frame `0`, startup `attack` with inactive hitbox, active damage `100 -> 86` once, defeated flag stopping chase and leaving animation on `death`, game log with only helper/DataManager info, empty editor log, and screenshot `reports/visual/cinderpaw-mcp-boss2-run-frame-animation-runtime-20260626.png`.
- Blockers: None. Boss2 arena bounds/reset semantics, multi-phase AI, final balancing, boss portrait/HP bar polish, authored Boss2 SFX/music, cutscene/camera polish, and full route content remain out of scope.
- Next: continue another ACT-visible slice such as Boss2 arena bounds/reset semantics, authored Boss2 audio feedback, deeper Old Factory combat content, savepoint/minimap gameplay, more skill-tree branches, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-30

- Story: `production/epics/player-abilities/story-026-boss2-arena-bounds-reset-runtime.md` — Boss2 Arena Bounds Reset Runtime
- Files changed: `src/gameplay/boss2_echo_guardian.gd`, `src/gameplay/main_scene.gd`, `tests/unit/gameplay/boss2_arena_bounds_reset_runtime_test.gd`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/epics/player-abilities/story-026-boss2-arena-bounds-reset-runtime.md`, `production/qa/evidence/boss2-arena-bounds-reset-runtime-2026-06-30.md`, `reports/boss2_arena_bounds_reset_runtime_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-boss2-arena-bounds-reset-runtime-20260630.png`, `production/session-state/active.md`
- Implementation: `Boss2EchoGuardian` now records a scene-local arena anchor and exposes `arena_anchor_position`, `arena_min_x`, `arena_max_x`, `is_returning_to_anchor`, and `is_at_anchor` through pressure diagnostics. Autonomous chase clamps Boss2 inside a fixed 320px-wide local arena centered on the anchor. When the target leashes outside pressure range, undefeated Boss2 returns toward the anchor using the existing Story025 `run` animation and settles back to `idle` at the anchor. `reset_encounter()` restores Boss2 to the anchor and clears movement pressure. Boss2 now supports `capture_respawn_snapshot()` / `restore_respawn_snapshot()` so `MainScene` arena reset restores Boss2 HP, collision, hitbox, hurtbox, status, sprite, facing, and anchor state. Defeated world progress still keeps Boss2 hidden, non-threatening, and out of HUD focus after reset.
- Asset pipeline: No new visual assets were generated. This story reuses the existing image-generated Boss2 Echo Guardian `AnimatedSprite2D + SpriteFrames` assets, including the Story025 three-frame `run` animation under `assets/characters/boss2_echo_guardian/run/`.
- Test written: `tests/unit/gameplay/boss2_arena_bounds_reset_runtime_test.gd` covers chase clamping, leash return to anchor and idle, `reset_encounter()` anchor restoration, MainScene Boss2 arena snapshot reset, active hitbox/hurtbox cleanup, and defeated-progress preservation with HUD fallback.
- Verification: RED `reports/report_800/` failed `3/3` before arena diagnostics/clamp behavior existed; RED `reports/report_804/` failed the MainScene Boss2 snapshot case before `capture_boss_arena_snapshot()` included Boss2 state; final focused `reports/report_808/` passed Story026 `5/5`. Related regressions passed: Boss2 autonomous pressure `reports/report_810/` `6/6`, Boss2 HUD focus `reports/report_811/` `4/4`, Boss2 Double Jump payoff `reports/report_812/` `3/3`, Boss2 telegraph strike `reports/report_813/` `4/4`, GameFlow boss respawn reset `reports/report_814/` `5/5`, simple enemy respawn reset `reports/report_815/` `1/1`, and no-loss respawn contract `reports/report_816/` `2/2`. Headless main-scene smoke `reports/boss2_arena_bounds_reset_runtime_main_scene_smoke.log` exited `0`; keyword scan found no script/parse/invalid-call/missing-resource/resource-load errors. Godot MCP runtime with `autosave=false` confirmed `res://scenes/main.tscn`, `/root/Main/Boss2EchoGuardian`, `AnimatedSprite2D + SpriteFrames`, `run` frame count `3`, arena anchor `(520, 482)`, arena x bounds `360..680`, chase clamp with `sprite.animation="run"`, leash return settling `behavior_phase="idle"`, MainScene Boss2 snapshot reset restoring HP `36/36` and idle/normal collision state, defeated progress keeping Boss2 hidden and non-focused, MCP logs with only helper/DataManager info, game screenshot metadata, and nonblank screenshot `reports/visual/cinderpaw-mcp-boss2-arena-bounds-reset-runtime-20260630.png`.
- Blockers: None. Final Boss2 arena art, camera lock, room doors, boss portrait/HP bar polish, authored Boss2 SFX/music, multi-phase AI, final balancing, cutscene polish, and full route content remain out of scope.
- Next: continue another ACT-visible slice such as authored Boss2 audio feedback, Boss2 arena polish/HP bar, deeper Old Factory combat content, savepoint/minimap gameplay, more skill-tree branches, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-30

- Story: `production/epics/audio-system/story-009-boss2-authored-audio-feedback-runtime.md` — Boss2 Authored Audio Feedback Runtime
- Files changed: `src/presentation/audio_system.gd`, `src/gameplay/boss2_echo_guardian.gd`, `src/gameplay/main_scene.gd`, `tests/unit/presentation/audio_system_test.gd`, `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd`, `assets/audio/sfx/sfx_boss2_chase_start.wav`, `assets/audio/sfx/sfx_boss2_attack_startup.wav`, `assets/audio/sfx/sfx_boss2_attack_active.wav`, `assets/audio/sfx/sfx_boss2_hurt.wav`, `assets/audio/sfx/sfx_boss2_defeat.wav`, `assets/audio/sfx/sfx_boss2_reward_claim.wav`, `assets/audio/sfx/sfx_boss2_*.wav.import`, `assets/audio/source/boss2_authored_audio_feedback_generation_20260630.json`, `production/epics/audio-system/EPIC.md`, `production/epics/index.md`, `production/epics/audio-system/story-009-boss2-authored-audio-feedback-runtime.md`, `production/qa/evidence/boss2-authored-audio-feedback-runtime-2026-06-30.md`, `reports/report_817/`, `reports/report_818/`, `reports/report_823/`, `reports/report_824/`, `reports/report_825/`, `reports/report_826/`, `reports/boss2_authored_audio_feedback_runtime_main_scene_smoke.log`, `production/session-state/active.md`
- Implementation: Added a six-cue Boss2 SFX pack and default AudioSystem stream registration for `sfx_boss2_chase_start`, `sfx_boss2_attack_startup`, `sfx_boss2_attack_active`, `sfx_boss2_hurt`, `sfx_boss2_defeat`, and `sfx_boss2_reward_claim`. `AudioSystem.on_boss2_audio_event(event_id, metadata)` safely maps Boss2 runtime events to spatial SFX with priority metadata. `Boss2EchoGuardian` now emits audio-domain events for first chase entry, attack startup, attack active, hurt, and defeat without per-frame chase spam. `MainScene` forwards Boss2 audio events and routes Boss2 reward claim through the same API.
- Asset pipeline: Generated procedural 44.1 kHz mono WAV baseline cues, recorded source/generation details in `assets/audio/source/boss2_authored_audio_feedback_generation_20260630.json`, and imported all six WAVs through Godot to produce `.wav.import` sidecars. No new visual assets were generated.
- Test written: `tests/unit/presentation/audio_system_test.gd` covers Boss2 asset existence/import/load and event-to-SFX mapping. `tests/unit/gameplay/main_scene_audio_event_adapter_test.gd` covers chase/startup/active/hurt/defeated/reward event forwarding through MainScene to AudioSystem.
- Verification: RED `reports/report_817/` failed as expected before Boss2 audio router/forwarding existed; focused GREEN `reports/report_818/` passed `33/33`. Related regressions passed independently: Boss2 arena `reports/report_823/` `5/5`, Boss2 autonomous pressure `reports/report_824/` `6/6`, Boss2 telegraph `reports/report_825/` `4/4`, Boss2 payoff `reports/report_826/` `3/3`. Combined related command `reports/report_819/` / `reports/report_821/` reproduced an order-sensitive autonomous animation-frame assertion after the arena suite, so those failed combined reports are not acceptance evidence; the individual suite reports above are clean. Headless main-scene smoke `reports/boss2_authored_audio_feedback_runtime_main_scene_smoke.log` exited `0` and keyword scan found no script/parse/invalid-call/missing-resource/resource-load errors. Godot MCP runtime with `autosave=false` confirmed `res://scenes/main.tscn`, `/Main/Boss2EchoGuardian`, `/Main/Boss2EchoGuardian/Sprite` as `AnimatedSprite2D`, `/root/AudioSystem`, visible Boss2 and HUD in a non-empty `960x540` game screenshot capture, game logs with only helper/DataManager info, empty editor logs, and editor returned to ready after stop.
- Blockers: None. Final mastered Boss2 SFX, Boss2 music/phase mix, arena ambience, subtitles, audio accessibility visualization, final Boss2 arena art, camera lock, boss portrait/HP bar polish, multi-phase AI, final balancing, cutscene polish, and full route content remain out of scope.
- Next: continue another ACT-visible slice such as Boss2 arena polish/HP bar, Boss2 music/phase mix, deeper Old Factory combat content, savepoint/minimap gameplay, more skill-tree branches, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-30

- Story: `production/epics/player-abilities/story-028-boss2-hud-hit-feedback-arena-visual-runtime.md` — Boss2 HUD Hit Feedback + Arena Visual Runtime
- Files changed: `src/presentation/hud_manager.gd`, `scenes/main.tscn`, `tests/unit/gameplay/boss2_hud_hit_feedback_arena_visual_runtime_test.gd`, `assets/environment/boss2_arena/boss2_echo_guardian_arena_frame.png`, `assets/environment/boss2_arena/boss2_echo_guardian_arena_frame.png.import`, `assets/generated/source/boss2_echo_guardian_arena_frame_imagegen_20260630.png`, `assets/generated/source/boss2_echo_guardian_arena_frame_alpha_20260630.png`, `assets/generated/source/boss2_echo_guardian_arena_frame_imagegen_20260630.json`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/epics/player-abilities/story-028-boss2-hud-hit-feedback-arena-visual-runtime.md`, `production/qa/evidence/boss2-hud-hit-feedback-arena-visual-runtime-2026-06-30.md`, `reports/report_831/`, `reports/report_832/`, `reports/report_833/`, `reports/report_834/`, `reports/report_835/`, `reports/report_836/`, `reports/report_837/`, `reports/report_838/`, `reports/boss2_hud_hit_feedback_arena_visual_runtime_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-boss2-hud-hit-feedback-arena-visual-20260630.png`, `production/session-state/active.md`
- Implementation: Added a visual-only `Boss2ArenaFrame` `Sprite2D` behind Boss2 in `res://scenes/main.tscn`, using a dedicated image-generated transparent 640x256 arena frame at `assets/environment/boss2_arena/boss2_echo_guardian_arena_frame.png`. `HUDManager` now detects Boss HP decreases and triggers a short white `BossHitFlashOverlay` on the existing Boss HUD panel without changing the existing Boss2 focus bridge. Deterministic diagnostics expose hit-flash visibility, remaining seconds, and color for tests and MCP probes.
- Asset pipeline: Generated a Boss2 Echo Guardian arena frame through image generation on green chroma key, preserved the source PNG, alpha-matted source, prompt metadata JSON, imported the runtime PNG through Godot, and recorded the asset in `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, Story028, and QA evidence. The asset is a non-collision environment visual only; Boss2 bounds/reset/reward behavior remains unchanged.
- Test written: `tests/unit/gameplay/boss2_hud_hit_feedback_arena_visual_runtime_test.gd` covers the arena frame node/texture/import contract and Boss2 damage triggering a short HUD hit flash while retaining `Echo Guardian` focus.
- Verification: RED focused `reports/report_831/` failed as expected on missing `Boss2ArenaFrame`; GREEN focused `reports/report_832/` passed Story028 `2/2`; final focused after MCP warning cleanup `reports/report_838/` passed `2/2`. Related regressions passed independently: Boss2 HUD focus `reports/report_833/` `4/4`, Boss2 arena bounds/reset `reports/report_834/` `5/5`, Boss2 autonomous pressure `reports/report_835/` `6/6`, Boss2 telegraph strike `reports/report_836/` `4/4`, and Boss2 Double Jump payoff `reports/report_837/` `3/3`. Godot import exited `0`. Headless main-scene smoke `reports/boss2_hud_hit_feedback_arena_visual_runtime_main_scene_smoke.log` exited `0`; keyword scan found no script/parse/invalid-call/missing-resource/resource-load or shadowed-variable issues, with only Godot cleanup-time `resources still in use` after exit. Godot MCP runtime with `autosave=false` confirmed `res://scenes/main.tscn`, visible `/Main/Boss2ArenaFrame` `Sprite2D`, texture path `res://assets/environment/boss2_arena/boss2_echo_guardian_arena_frame.png`, texture size `640x256`, z-index `31`, Boss2 `AnimatedSprite2D + SpriteFrames` with `idle/run/attack` frame counts `3`, Boss2 damage `36 -> 27`, HUD label `Echo Guardian  Phase I  27/36`, flash color `ffffff`, flash remaining `0.22 -> 0.11 -> 0.0`, empty editor logs after clearing temporary eval warning, game logs with only helper/DataManager info, and nonblank screenshot `reports/visual/cinderpaw-mcp-boss2-hud-hit-feedback-arena-visual-20260630.png`.
- Blockers: None. Boss2 room/camera polish, boss doors, boss portrait, multi-phase AI, final balancing, cutscene polish, final music/mix, minimap updates, and full route content remain out of scope.
- Next: continue another ACT-visible slice such as Boss2 room/camera polish, Boss2 music/phase mix, deeper Old Factory combat content, savepoint/minimap gameplay, more skill-tree branches, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-30

- Story: `production/epics/player-abilities/story-029-boss2-arena-camera-lock-runtime.md` — Boss2 Arena Camera Lock Runtime
- Files changed: `src/gameplay/main_scene.gd`, `tests/unit/gameplay/boss2_arena_camera_lock_runtime_test.gd`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/epics/player-abilities/story-029-boss2-arena-camera-lock-runtime.md`, `production/qa/evidence/boss2-arena-camera-lock-runtime-2026-06-30.md`, `reports/report_839/`, `reports/report_840/`, `reports/report_841/`, `reports/report_842/`, `reports/report_843/`, `reports/report_844/`, `reports/report_845/`, `reports/report_846/`, `reports/report_847/`, `reports/boss2_arena_camera_lock_runtime_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-boss2-arena-camera-lock-runtime-20260630.png`, `production/session-state/active.md`
- Implementation: `MainScene` now captures the default `Player/Camera2D` state and exposes `refresh_boss2_camera_lock()` plus `get_boss2_camera_lock_diagnostics()` for deterministic tests and MCP probes. While visible, undefeated Boss2 is active, the camera applies Boss2 room framing with `limit_right=1040`, `zoom=(1.15, 1.15)`, smoothing enabled at `10.0`, and `offset=(0,0)` so `CombatPresentation` screen shake remains the only owner of camera offset. When Boss2 is defeated, restored from defeated progress, reward-claimed, arena-reset, or arena locks are cleared, the camera returns to the default main-scene framing (`0..1280`, `zoom=(1,1)`, smoothing speed `8.0`). Boss2 AI, arena bounds/reset, HUD focus, collision, and Double Jump reward behavior remain unchanged.
- Asset pipeline: No new visual assets were generated. This story reuses the existing image-generated Boss2 arena frame and existing Boss2/Cinderpaw `AnimatedSprite2D + SpriteFrames` assets.
- Test written: `tests/unit/gameplay/boss2_arena_camera_lock_runtime_test.gd` covers active Boss2 camera lock diagnostics/framing, defeated progress release, defeated save-restore release, and CombatPresentation `Camera2D.offset` ownership preservation.
- Verification: RED focused `reports/report_839/` failed as expected because camera lock APIs did not exist; initial GREEN focused `reports/report_840/` passed Story029 `2/2`; review RED `reports/report_844/` failed before defeated save-restore release and camera offset ownership were fixed; final GREEN focused `reports/report_845/` passed Story029 `4/4`; final related regression `reports/report_846/` passed Story029, Boss2 HUD focus, Boss2 arena bounds/reset, Boss2 telegraph strike, and Boss2 Double Jump payoff `20/20`; Boss2 autonomous pressure passed independently in `reports/report_847/` `6/6`. Combined related command `reports/report_841/` reproduced the known order-sensitive Boss2 autonomous run-frame assertion and is not acceptance evidence. Headless main-scene smoke `reports/boss2_arena_camera_lock_runtime_main_scene_smoke.log` exited `0`; keyword scan found no script/parse/invalid-call/missing-resource/resource-load errors. Godot MCP runtime with `autosave=false` confirmed `res://scenes/main.tscn`, active `/root/Main/Player/Camera2D` `limit_right=1040`, `zoom=(1.15,1.15)`, smoothing enabled, `offset=(0,0)`, visible Boss2 `AnimatedSprite2D + SpriteFrames`, visible Boss2 arena frame, defeated-progress release restoring `limit_right=1280` and `zoom=(1,1)`, Boss2 hidden, reward source still present, game logs with only helper/DataManager info, empty editor logs, and nonblank `1280x720` screenshot `reports/visual/cinderpaw-mcp-boss2-arena-camera-lock-runtime-20260630.png`.
- Blockers: None. Boss2 room doors, boss portrait/HP polish, minimap markers, dynamic camera rails/curves, Boss2 music/phase mix, multi-phase AI, final balancing, deeper Old Factory content, and broader frame-animation audit remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory combat content, savepoint/minimap gameplay, more skill-tree branches, Boss2 music/phase mix, Boss2 room doors/portrait polish, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-30

- Story: `production/epics/player-abilities/story-040-old-factory-return-patrol-ambush.md` — Old Factory Return Patrol Ambush
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_return_patrol_ambush_test.gd`, `production/epics/player-abilities/story-040-old-factory-return-patrol-ambush.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-return-patrol-ambush-2026-06-30.md`, `reports/report_928/`, `reports/report_929/`, `reports/report_930/`, `reports/old_factory_return_patrol_ambush_factory_scene_smoke.log`, `reports/visual/cinderpaw-mcp-old-factory-return-patrol-ambush-20260630.png`, `production/session-state/active.md`
- Implementation: Added a one-time return patrol ambush to the existing Old Factory route. `FactoryReturnSparkRat` is authored in `res://scenes/factory_route_transition_shell.tscn`, reuses the existing Factory Spark Rat `AnimatedSprite2D + SpriteFrames` asset, and remains hidden/disabled until `OldFactoryEntranceScene.set_local_state()` receives the full service-lift return contract back to `main / scrap_roost`. While active, the route objective becomes `Clear Return Patrol`, `FactoryServiceLift` stays locked with prompt `Clear patrol`, and lift activation records `return_patrol_active` without requesting SceneManager. Defeating entity `2103` sets `factory_return_patrol_defeated=true`, marks objective `Return Patrol Cleared` with `complete=true`, restores lift prompt `Call lift`, and allows the service lift to request `main / scrap_roost` again. Return patrol state remains scene-local via `get_local_state()` / `set_local_state()` without SaveSystem schema or global quest changes.
- Asset pipeline: No new visual assets were generated. This story reuses the existing image-generated Factory Spark Rat frames and existing image-generated service-lift console/VFX assets.
- Test written: `tests/unit/gameplay/old_factory_return_patrol_ambush_test.gd` with three focused tests covering first-clear inactive patrol semantics, return-contract patrol activation/lift lockout/frame-animation contract, and defeat persistence/service-lift reactivation/restore without respawn.
- Verification: RED focused `reports/report_928/` failed on the new objective `complete=true` assertion after patrol defeat; GREEN focused `reports/report_929/` passed `3/3`; related Old Factory/Scrap Roost route regression `reports/report_930/` passed `14/14`; headless Factory scene smoke `reports/old_factory_return_patrol_ambush_factory_scene_smoke.log` exited `0` and keyword scan found no script/parse/invalid/missing-resource/resource-load errors. Godot MCP 4.7 runtime with `autosave=false` confirmed `FactoryReturnSparkRat` in the runtime scene tree, `AnimatedSprite2D + SpriteFrames` frame counts `idle/run/attack_tell/attack/hurt/death=3`, active return contract showing `Clear Return Patrol`, lift rejection `return_patrol_active`, patrol defeat setting objective `return_patrol_cleared` with `complete=true`, lift prompt `Call lift`, post-clear lift request `main / scrap_roost`, clean game/editor logs, and nonblank screenshot `reports/visual/cinderpaw-mcp-old-factory-return-patrol-ambush-20260630.png`.
- Blockers: None. Additional Old Factory rooms, minimap/savepoint gameplay, new enemy families, Spark Rat stat tuning, new abilities, global quest/objective manager, new audio, service-lift movement animation, and new visual assets remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory combat content, savepoint/minimap gameplay, more skill-tree branches, Boss2 music/phase mix, Boss2 room doors/portrait polish, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-30

- Story: `production/epics/player-abilities/story-037-factory-route-runtime-roundtrip.md` — Factory Route Runtime Roundtrip
- Files changed: `src/feature/scene_manager.gd`, `src/gameplay/main_scene.gd`, `tests/unit/gameplay/factory_route_runtime_roundtrip_test.gd`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/epics/player-abilities/story-037-factory-route-runtime-roundtrip.md`, `production/qa/evidence/factory-route-runtime-roundtrip-2026-06-30.md`, `reports/factory_route_runtime_roundtrip_main_scene_smoke.log`, `reports/visual/cinderpaw-mcp-factory-route-runtime-roundtrip-20260630.png`, `production/session-state/active.md`
- Implementation: `SceneManager._swap_runtime_scene()` now injects itself into runtime scenes that expose `configure_scene_manager_runtime(self)`, fixing cached scenes that disconnect signals during `_exit_tree()` and later re-enter the runtime root. `MainScene` now exposes `get_local_state()` / `set_local_state()` for SceneManager state capture/restore, and applies `scrap_roost` spawn to the visible `ScrapRoostSavepoint` when SceneManager returns to `main / scrap_roost`.
- Asset pipeline: No new visual assets were generated. This story reuses existing Cinderpaw, Boss2, Factory route, Old Factory, Spark Rat, and service lift assets.
- Test written: `tests/unit/gameplay/factory_route_runtime_roundtrip_test.gd` covers the real main scene, real Factory route scene, real SceneManager runtime root swap, authored Factory route clear helper path, service lift exit, saved Factory exit state, returned main scene, `scrap_roost` spawn, and player proximity to Scrap Roost.
- Verification: RED focused `reports/report_902/` failed as expected because returning to `main/scrap_roost` left the player at Factory route trigger `(970, 352)`; GREEN focused `reports/report_906/` passed `1/1` with `0` orphans; pre-commit focused rerun `reports/report_907/` passed `1/1` with `0` orphans on Godot `4.7.stable.official.5b4e0cb0f`; related regression `reports/report_905/` passed `17/17`; headless main-scene smoke `reports/factory_route_runtime_roundtrip_main_scene_smoke.log` exited `0` and keyword scan found no script/parse/invalid-call/invalid-access/missing-resource/resource-load/`ERROR:` entries. Godot MCP runtime with `autosave=false` confirmed route request, Factory arrival, Factory route clear, service lift activation, return to `main`, spawn `scrap_roost`, player near Scrap Roost after physics settle, clean game logs, only unrelated editor `.uid` warnings after clearing temporary eval warning, and nonblank screenshot `reports/visual/cinderpaw-mcp-factory-route-runtime-roundtrip-20260630.png`.
- Blockers: None. Deeper Old Factory combat content, savepoint/minimap gameplay, more skill-tree branches, Boss2 music/phase mix, Boss2 room doors/portrait polish, and broader frame-animation audit remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory combat content, savepoint/minimap gameplay, more skill-tree branches, Boss2 music/phase mix, Boss2 room doors/portrait polish, or broader frame-animation audit.

## Session Extract — /dev-story 2026-06-30

- Story: `production/epics/player-abilities/story-044-old-factory-return-checkpoint-respawn-runtime.md` — Old Factory Return Checkpoint Respawn Runtime
- Files changed: `src/gameplay/game_flow_controller.gd`, `src/feature/scene_manager.gd`, `src/gameplay/old_factory_entrance_scene.gd`, `tests/unit/gameplay/old_factory_return_checkpoint_test.gd`, `production/epics/player-abilities/story-044-old-factory-return-checkpoint-respawn-runtime.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-return-checkpoint-respawn-runtime-2026-06-30.md`, `reports/old_factory_return_checkpoint_runtime_swap_red.log`, `reports/report_960/`, `reports/old_factory_return_checkpoint_respawn_runtime_green.log`, `reports/report_965/`, `reports/old_factory_return_checkpoint_respawn_related.log`, `reports/report_964/`, `reports/old_factory_return_checkpoint_respawn_project_boot.log`, `reports/visual/cinderpaw-mcp-old-factory-return-checkpoint-respawn-runtime-20260630.png`, `production/session-state/active.md`
- Implementation: Story043 already let non-boss death select the Old Factory return checkpoint; Story044 makes that selection land in the real runtime scene tree. `GameFlowController._apply_scene_transition()` now prefers `request_scene_change(scene_id, spawn_point)` when the scene-transition adapter supports it, falling back to `change_scene()` for existing lightweight fakes. `SceneManager._finish_pending_load()` refreshes the loaded runtime scene's `configure_scene_manager_runtime(self)` after committing the final current scene/spawn pair. `OldFactoryEntranceScene` now applies SceneManager's `area_03_factory` spawn points: `factory_gate_entry` uses the existing gate marker and `return_checkpoint` moves `Player` to `FactoryReturnCheckpoint` and updates `RouteLabel` to `Returned to Factory Savepoint`.
- Asset pipeline: No new visual assets were generated. This story reuses the Story043 image-generated return checkpoint asset and existing Cinderpaw/Factory route assets.
- Test written: `tests/unit/gameplay/old_factory_return_checkpoint_test.gd` now covers SceneManager current-spawn application, the full non-boss death runtime-root swap from Main to `FactoryRouteTransitionShellScene`, and a same-Factory runtime respawn that saves/restores activated checkpoint, return-patrol, and service-lift scene-local state before applying `return_checkpoint`. Tests assert pending scene/spawn, final current scene/spawn, player distance to checkpoint, route label, selected savepoint source, restored checkpoint diagnostics, and restored local state. The runtime tests explicitly advance deferred unload and wait one frame so swapped-out runtime scenes do not leak orphans.
- Verification: RED runtime-swap test `reports/old_factory_return_checkpoint_runtime_swap_red.log` / `reports/report_960/` failed as expected because the old flow only called logical `change_scene()` and the runtime root stayed on Main. Focused GREEN `reports/old_factory_return_checkpoint_respawn_runtime_green.log` / `reports/report_965/` passed `6/6` with `0` orphans. Related regression `reports/old_factory_return_checkpoint_respawn_related.log` / `reports/report_964/` passed savepoint selection, Factory route roundtrip, service-lift SceneManager exit, and respawn visual feedback `10/10` with `0` orphans. Headless project boot `reports/old_factory_return_checkpoint_respawn_project_boot.log` exited `0`; keyword scan found no script/parse/invalid-call/invalid-access/missing-resource/resource-load errors, with only known Godot cleanup-time ObjectDB/resource messages. Godot MCP 4.7 runtime launched `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`, confirmed `Player`, `Player/Sprite` `AnimatedSprite2D`, `FactoryReturnCheckpoint`, and Factory enemy animation nodes in the runtime tree; eval probe confirmed `changed=true`, `configured=true`, current scene/spawn `area_03_factory / return_checkpoint`, player/checkpoint positions `(704, 380)`, distance `0.0`, route label `Returned to Factory Savepoint`, checkpoint visible/available/activated, clean game logs, empty editor logs after clearing a temporary eval warning, and nonblank screenshot `reports/visual/cinderpaw-mcp-old-factory-return-checkpoint-respawn-runtime-20260630.png`.
- Blockers: None. New checkpoint art, SaveSystem schema changes, minimap markers, fast travel UI, deeper Factory rooms, new enemies, new audio, Factory-owned production death-signal wiring, and broader respawn redesign remain out of scope.
- Next: continue another ACT-visible slice such as Factory runtime death integration, deeper Old Factory combat content, savepoint/minimap gameplay, additional player-visible frame-animation replacement, Boss2 music/phase mix, Boss2 room doors/portrait polish, or broader frame-animation audit.

## Session Extract — /dev-story 2026-07-02

- Story: `production/epics/player-abilities/story-059-old-factory-lower-deck-steam-sluice-ambush.md` — Old Factory Lower Deck Steam Sluice Ambush
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_steam_sluice_ambush_test.gd`, `production/epics/player-abilities/story-059-old-factory-lower-deck-steam-sluice-ambush.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-lower-deck-steam-sluice-ambush-2026-07-02.md`, `reports/report_1055/`, `reports/report_1056/`, `reports/report_1057/`, `reports/old_factory_lower_deck_steam_sluice_smoke.log`, `production/session-state/active.md`
- Implementation: Added a one-time lower-deck steam sluice ambush after the pressure valve chain. `FactoryLowerDeckSteamSluiceSparkRat` and `FactoryLowerDeckSteamSluiceHazard` are authored in `res://scenes/factory_route_transition_shell.tscn` and stay hidden/disabled until `factory_lower_deck_pressure_valve_opened=true`. Activation exposes route objective `Clear Steam Sluice Ambush`, enables a live Spark Rat target and steam hazard, keeps the service lift optional with prompt `Call lift`, and records scene-local activation/defeat flags through `get_local_state()` / `set_local_state()`. Defeating entity `2113` clears the ambush, disables the hazard, records `factory_lower_deck_steam_sluice_defeated=true`, and advances the route label/objective to `Steam Sluice Cleared` without replaying Story054-058 pressure-valve prerequisites.
- Asset pipeline: No new visual assets were generated. This story reuses the existing image-generated Factory Spark Rat `AnimatedSprite2D + SpriteFrames` asset and the existing Old Factory steam vent hazard texture/import pipeline.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_steam_sluice_ambush_test.gd` covers pressure-valve gating, activation diagnostics, Spark Rat animation frame counts for `idle/run/attack_tell/attack/hurt/death`, active steam hazard semantics, optional service-lift prompt preservation, route objective/label transitions, defeat persistence, and restore without replaying the lower-deck prerequisite chain.
- Verification: RED focused `reports/report_1055/` failed as expected before the Story059 diagnostics/activation APIs existed. GREEN focused `reports/report_1056/` passed Story059 `2/2`. Related lower-deck/service-lift regression `reports/report_1057/` passed pressure valve, shortcut pursuer, shortcut reward cache, shortcut seal, exit ambush, and service-lift SceneManager exit suites `11/11`. Headless Factory scene smoke `reports/old_factory_lower_deck_steam_sluice_smoke.log` exited `0`; keyword scan found no script/parse/invalid-call/missing-resource/resource-load errors. Godot MCP 4.7 runtime launched `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`, confirmed entity `2113`, `AnimatedSprite2D + SpriteFrames` frame counts `idle/run/attack_tell/attack/hurt/death=3`, active objective `Clear Steam Sluice Ambush`, active steam hazard id `old_factory_lower_deck_steam_sluice`, service lift prompt `Call lift`, defeat transition to `Steam Sluice Cleared`, clean game/editor logs, and a non-empty `960x539` game screenshot capture.
- Blockers: None. New lower-deck room art, new enemy families, authored steam SFX, minimap markers, global quest-objective persistence, balancing, and broader Factory route content remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory lower-deck combat, minimap/savepoint gameplay, Factory-owned runtime death integration, authored hazard/audio feedback, additional player-visible frame-animation replacement, or broader frame-animation audit.

## Session Extract — /dev-story 2026-07-02

- Story: `production/epics/player-abilities/story-061-old-factory-lower-deck-breach-corridor-ambush.md` — Old Factory Lower Deck Breach Corridor Ambush
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_bulkhead_breach_ambush_test.gd`, `assets/environment/old_factory_lower_deck_post_bulkhead/env_old_factory_lower_deck_post_bulkhead_backdrop_1280x720.png`, `assets/generated/source/old_factory_lower_deck_post_bulkhead_backdrop_imagegen_20260702.png`, `assets/generated/source/old_factory_lower_deck_post_bulkhead_backdrop_imagegen_20260702.json`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-061-old-factory-lower-deck-breach-corridor-ambush.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-lower-deck-breach-corridor-ambush-2026-07-02.md`, `reports/report_1064/`, `reports/report_1065/`, `reports/report_1066/`, `reports/old_factory_lower_deck_bulkhead_breach_ambush_smoke.log`, `reports/visual/cinderpaw-mcp-old-factory-lower-deck-breach-corridor-ambush-20260702.png`, `production/session-state/active.md`
- Implementation: Added a one-time post-bulkhead breach corridor ambush after the Story060 deep bulkhead opens. `PostBulkheadBackground`, `FactoryLowerDeckBreachFrontSparkRat`, `FactoryLowerDeckBreachRearSparkRat`, and `FactoryLowerDeckBreachSteamHazard` are authored in `res://scenes/factory_route_transition_shell.tscn`. The breach is unavailable until `factory_lower_deck_deep_bulkhead_opened=true`; crossing the activation boundary enables front entity `2115`, target assignment, pacing, and route feedback `Clear Breach Corridor Ambush`; crossing the midpoint enables rear entity `2116` and route feedback `Survive Breach Pincer`. Defeating both entities disables both enemies and hazard, persists the breach flags, and advances route feedback to `Breach Corridor Secured`. `FactoryServiceLift` remains optional with prompt `Call lift`.
- Asset pipeline: Generated a new opaque 1280x720 post-bulkhead lower-deck backdrop through image generation, preserved source and metadata under `assets/generated/source/`, resized/imported the runtime PNG under `assets/environment/old_factory_lower_deck_post_bulkhead/`, and recorded it in the asset manifest plus entity inventory. Enemy visuals reuse the existing image-generated Factory Spark Rat `AnimatedSprite2D + SpriteFrames` asset with `idle/run/attack_tell/attack/hurt/death=3`.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_bulkhead_breach_ambush_test.gd` covers deep-bulkhead gating, activation, pincer escalation, route labels, service-lift prompt preservation, frame-animation counts for both enemies, defeat persistence, hazard disabling, restored state, and no replay of the lower-deck prerequisite chain.
- Verification: RED focused `reports/report_1064/` failed as expected before Story061 diagnostics and activation APIs existed. GREEN focused `reports/report_1065/` passed Story061 `2/2` with `0` orphans. Related lower-deck/service-lift regression `reports/report_1066/` passed pressure valve, steam sluice, deep bulkhead, breach corridor, and service-lift SceneManager exit suites `10/10` with `0` orphans. Headless Factory scene smoke `reports/old_factory_lower_deck_bulkhead_breach_ambush_smoke.log` exited `0`; keyword scan found no script/parse/invalid-call/missing-resource/resource-load errors, only the known cleanup-time resource message. Godot MCP 4.7 runtime launched `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`, confirmed `PostBulkheadBackground`, breach steam hazard, entities `2115` and `2116`, `AnimatedSprite2D + SpriteFrames` frame counts `idle/run/attack_tell/attack/hurt/death=3` on both enemies, activation feedback `Clear Breach Corridor Ambush`, pincer feedback `Survive Breach Pincer`, service lift prompt `Call lift`, defeat feedback `Breach Corridor Secured`, persisted breach flags, clean game/editor logs, and nonblank screenshot `reports/visual/cinderpaw-mcp-old-factory-lower-deck-breach-corridor-ambush-20260702.png`.
- Blockers: None. New enemy families, authored steam SFX, minimap markers, global quest state, service-lift route changes, broader lower-deck rooms, and boss content remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory lower-deck combat, authored hazard/audio feedback, minimap/savepoint gameplay, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract — /dev-story 2026-07-02

- Story: `production/epics/player-abilities/story-062-old-factory-lower-deck-breach-relay-savepoint.md` — Old Factory Lower Deck Breach Relay Savepoint
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_breach_reward_route_test.gd`, `assets/environment/old_factory_lower_deck_breach_relay/env_old_factory_lower_deck_breach_relay_256.png`, `assets/environment/old_factory_lower_deck_breach_relay/env_old_factory_lower_deck_breach_relay_256.png.import`, `assets/generated/source/old_factory_lower_deck_breach_relay_imagegen_20260702.png`, `assets/generated/source/old_factory_lower_deck_breach_relay_imagegen_20260702.png.import`, `assets/generated/source/old_factory_lower_deck_breach_relay_alpha_20260702.png`, `assets/generated/source/old_factory_lower_deck_breach_relay_alpha_20260702.png.import`, `assets/generated/source/old_factory_lower_deck_breach_relay_imagegen_20260702.json`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-062-old-factory-lower-deck-breach-relay-savepoint.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-lower-deck-breach-relay-savepoint-2026-07-02.md`, `reports/report_1067/`, `reports/report_1071/`, `reports/report_1072/`, `reports/old_factory_lower_deck_breach_relay_savepoint_smoke.log`, `production/session-state/active.md`
- Implementation: Added `FactoryLowerDeckBreachRelaySavepoint` as a post-Story061 lower-deck relay savepoint. It uses `SavepointRuntime`, new image-generated transparent relay art, prompt `Repair Relay`, and savepoint contract `old_factory_lower_deck_breach_relay / area_03_factory / lower_deck_breach_relay`. The relay stays hidden and non-interactive until `factory_lower_deck_breach_corridor_secured=true`; activation succeeds once, persists `factory_lower_deck_breach_relay_activated=true`, records the last return checkpoint snapshot, updates route feedback to `Lower Deck Relay Secured`, and later non-boss Factory death respawns Cinderpaw at the relay with feedback `Returned to Lower Deck Relay`. Story054-061 enemies/hazards do not replay after restore, and `FactoryServiceLift` remains optional with prompt `Call lift`.
- Asset pipeline: Generated the relay prop through image generation, preserved source, alpha source, runtime transparent 256x256 PNG, import files, and metadata under `assets/generated/source/` plus `assets/environment/old_factory_lower_deck_breach_relay/`. Recorded the asset in `design/assets/asset-manifest.md` and `design/assets/entity-inventory.md`. This is an environment savepoint prop, not a character animation asset.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_breach_reward_route_test.gd` covers locked/available relay gating, prompt/texture/savepoint contract, service-lift independence, one-shot activation, scene-local persistence, restored breach cleanup, non-boss death respawn selection, player repositioning, and return route label.
- Verification: RED focused `reports/report_1067/` failed as expected before Story062 diagnostics and activation APIs existed. Fresh focused GREEN `reports/report_1071/` passed Story062 `2/2` with `0` orphans. Fresh related lower-deck/respawn/service-lift regression `reports/report_1072/` passed `15/15` with `0` orphans. Headless Factory scene smoke `reports/old_factory_lower_deck_breach_relay_savepoint_smoke.log` exited `0`; keyword scan found no script/parse/invalid-call/access/missing-resource/resource-load errors, only known Godot cleanup-time ObjectDB/resource messages. Godot AI MCP `2.8.3` runtime launched `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`, confirmed helper live, relay present/visible, `Sprite2D` visual, texture path and `256x256` size, activation `true`, duplicate activation `false`, route label `Lower Deck Relay Secured`, persisted local relay flag, savepoint contract, inactive breach enemies/hazard, and a non-empty `960x539` game framebuffer capture.
- Blockers: None. Minimap markers, fast travel, SaveSystem schema expansion, authored relay SFX, broader lower-deck rooms, and boss content remain out of scope.
- Next: continue another ACT-visible slice such as minimap/savepoint feedback, authored relay/audio feedback, deeper Old Factory lower-deck combat, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-02

- Story: `production/epics/player-abilities/story-063-old-factory-lower-deck-breach-relay-activation-feedback.md` -- Old Factory Lower Deck Breach Relay Activation Feedback
- Files changed: `src/feature/savepoint_runtime.gd`, `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_breach_relay_feedback_test.gd`, `tests/unit/gameplay/old_factory_spark_rat_dodge_counter_readability_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-063-old-factory-lower-deck-breach-relay-activation-feedback.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-lower-deck-breach-relay-activation-feedback-2026-07-02.md`, `reports/report_1073/`, `reports/report_1076/`, `reports/report_1077/`, `reports/report_1079/`, `reports/old_factory_lower_deck_breach_relay_feedback_smoke.log`, `production/session-state/active.md`
- Implementation: Added optional one-shot activation feedback support to `SavepointRuntime`. Savepoints can now assign `activation_vfx_texture` and `activation_vfx_duration_sec`; a fresh valid activation spawns one `Sprite2D` named `ActivationVfx`, records deterministic diagnostics (`texture_path`, `active_count`, `duration_sec`, `elapsed_sec`, `played`, `spawn_count`, `last_spawn`), fades/scales out through `advance_activation_vfx_time()`, and suppresses duplicate/restored-state replay. `FactoryLowerDeckBreachRelaySavepoint` now reuses `res://assets/environment/old_factory_deep_route/vfx/factory_deep_route_unlock_spark.png` as its generated activation spark. `OldFactoryEntranceScene.get_factory_lower_deck_breach_relay_diagnostics()` exposes activation feedback texture/active/played/spawn-count fields while preserving Story062 activation, route feedback, respawn contract, and optional service lift behavior.
- Asset pipeline: No new visual asset was generated. Story063 intentionally reuses the existing Story012 image-generated Old Factory unlock spark VFX (`assets/generated/source/factory_deep_route_unlock_spark_imagegen_20260626.png`, alpha source, and imported runtime PNG) and records the new relay activation usage in `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, and QA evidence. This is environment/savepoint feedback, not a character frame-animation asset.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_breach_relay_feedback_test.gd` covers the generated activation VFX texture contract, one-shot activation spawn metadata, duplicate activation suppression, deterministic expiry, relay diagnostics, and restored activated relay state without replaying feedback. Also cleaned Story015 test type annotations after MCP Debugger retained stale `CombatComponent` global-class rows; `reports/report_1079/` proves that existing dodge-counter coverage still passes.
- Verification: RED focused `reports/report_1073/` failed as expected before activation VFX APIs existed. Fresh focused Story063 rerun `reports/report_1076/` passed `3/3` with `0` errors/failures/skipped/flaky/orphans. Fresh related rerun `reports/report_1077/` passed relay feedback, Story062 relay savepoint, Story012 unlock feedback, and return checkpoint suites `17/17` with `0` errors/failures/skipped/flaky/orphans. Story015 MCP stale-row cleanup check `reports/report_1079/` passed `5/5`. Headless Factory scene smoke `reports/old_factory_lower_deck_breach_relay_feedback_smoke.log` exited `0`; keyword scan found no script/parse/invalid-call/access/missing-resource/resource-load errors, only known Godot cleanup-time ObjectDB/resource messages. Godot AI MCP `2.8.3` runtime launched `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`, confirmed helper live, relay visible after secured breach, activation feedback texture path, activation `true`, duplicate activation `false`, VFX `active_count=1`, `spawn_count=1`, `played=true`, metadata `asset_source=image_generation`, `vfx_role=savepoint_activation`, savepoint id `old_factory_lower_deck_breach_relay`, deterministic expiry to `active_count=0`, route label `Lower Deck Relay Secured`, service lift prompt `Call lift`, local relay flag persisted, game log contained only the MCP helper registration line, and MCP screenshot captured a non-empty `960x539` game framebuffer. Editor Debugger still displayed pre-existing stale Story015 rows with old line mappings after clear; current CLI `--check-only` for `src/core/combat_component.gd` and Story015 `report_1079` passed.
- Blockers: None. New relay art, new VFX generation, authored relay SFX, minimap markers, fast travel, SaveSystem schema expansion, service-lift route changes, broader lower-deck rooms, and boss content remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory lower-deck combat, savepoint/minimap feedback, authored relay/audio feedback, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-02

- Story: `production/epics/player-abilities/story-064-old-factory-lower-deck-breach-relay-audio-feedback.md` -- Old Factory Lower Deck Breach Relay Audio Feedback
- Files changed: `src/presentation/audio_system.gd`, `src/gameplay/old_factory_entrance_scene.gd`, `tests/unit/presentation/audio_system_test.gd`, `tests/unit/gameplay/old_factory_lower_deck_breach_relay_feedback_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-064-old-factory-lower-deck-breach-relay-audio-feedback.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-lower-deck-breach-relay-audio-feedback-2026-07-02.md`, `reports/report_1080/`, `reports/report_1081/`, `reports/report_1082/`, `reports/report_1083/`, `reports/old_factory_lower_deck_breach_relay_audio_feedback_smoke.log`, `production/session-state/active.md`
- Implementation: Added `AudioSystem.on_savepoint_activated(...)`, routing fresh savepoint activation events to the existing imported `sfx_door_unlock` cue with deterministic metadata. `OldFactoryEntranceScene` now calls that route only from the lower-deck breach relay's fresh activation handler, records `activation_audio_requested`, `activation_audio_request_count`, and `activation_audio_event` diagnostics, suppresses duplicate/restored replay, and preserves Story062 savepoint behavior plus Story063 VFX feedback.
- Asset pipeline: No new audio or visual asset was generated. Story064 intentionally reuses `assets/audio/sfx/sfx_door_unlock_baseline_short.wav` and records the new lower-deck relay usage in `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, and QA evidence.
- Test written: `tests/unit/presentation/audio_system_test.gd` now covers `on_savepoint_activated -> sfx_door_unlock` metadata and stream routing. `tests/unit/gameplay/old_factory_lower_deck_breach_relay_feedback_test.gd` now covers fresh relay activation audio, duplicate suppression, restored no-replay, runtime AudioSystem event, and relay diagnostics.
- Verification: RED focused `reports/report_1080/` failed as expected before the savepoint audio API/diagnostics existed. Focused GREEN `reports/report_1081/` passed `27/27`. Related GREEN `reports/report_1082/` passed relay feedback, breach reward route, and AudioSystem suites `29/29`. Story015 stale editor-row isolation `reports/report_1083/` passed `5/5`. Headless Factory smoke `reports/old_factory_lower_deck_breach_relay_audio_feedback_smoke.log` exited `0`; keyword scan found no project script/parse/invalid-call/access/missing-resource/resource-load errors. Godot AI MCP `2.8.3` runtime launched `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`, confirmed helper live, activation `true`, duplicate activation `false`, `activation_audio_request_count=1`, `savepoint_activated -> sfx_door_unlock`, relay position `(1218, 382)`, `stream_found=true`, metadata fields, route label `Lower Deck Relay Secured`, VFX spawn count `1`, clean game log, and non-empty game screenshot. Editor Debugger still displayed pre-existing stale Story015 rows with old line mappings after clear; current Story015 CLI verification passed in `reports/report_1083/`.
- Blockers: None. New authored relay WAV, final mix/bus tuning, global savepoint audio policy, minimap markers, fast travel, SaveSystem schema expansion, service-lift route changes, broader lower-deck rooms, and boss content remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory lower-deck combat, minimap/savepoint feedback, authored/final audio replacement, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-02

- Story: `production/epics/player-abilities/story-065-old-factory-lower-deck-post-relay-combat-feedback.md` -- Old Factory Lower Deck Post-Relay Combat Feedback
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_post_relay_combat_feedback_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-065-old-factory-lower-deck-post-relay-combat-feedback.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-lower-deck-post-relay-combat-feedback-2026-07-02.md`, `reports/report_1084/`, `reports/report_1086/`, `reports/report_1088/`, `reports/old_factory_lower_deck_post_relay_combat_feedback_smoke.log`, `production/session-state/active.md`
- Implementation: Added a relay-forward combat trial after the lower-deck breach relay repair. `FactoryLowerDeckPostRelaySparkRat` and `FactoryLowerDeckPostRelaySteamHazard` stay hidden/disabled until `factory_lower_deck_breach_relay_activated=true`; crossing activation x `1232.0` enables entity `2117`, target assignment, Spark Rat pacing, steam contact pressure, and route feedback `Clear Relay Forward Trial`. Defeating entity `2117` disables enemy/hazard state, persists trial activation/defeat flags, and advances route feedback to `Relay Forward Secured` without replaying Story061-064 prerequisites. `FactoryServiceLift` remains optional with prompt `Call lift`.
- Asset pipeline: No new visual or audio asset was generated. Story065 reuses the existing image-generated Factory Spark Rat `AnimatedSprite2D + SpriteFrames` asset, the existing Old Factory steam vent hazard prop, and the post-bulkhead backdrop. New usage is recorded in the asset manifest, entity inventory, story, and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_post_relay_combat_feedback_test.gd` covers relay-gated activation, Spark Rat frame counts for `idle/run/attack_tell/attack/hurt/death`, hazard activation semantics, route feedback, service-lift prompt preservation, defeat persistence, restored defeated state, and no prerequisite replay.
- Verification: RED focused `reports/report_1084/` failed as expected before Story065 APIs existed. Focused GREEN `reports/report_1086/` passed Story065 `2/2`. Related lower-deck/service-lift regression `reports/report_1088/` passed `12/12`. Headless Factory scene smoke `reports/old_factory_lower_deck_post_relay_combat_feedback_smoke.log` exited `0`; keyword scan found no project script/parse/invalid-call/access/missing-resource/resource-load errors. Godot MCP `2.8.3` runtime confirmed helper live, active trial diagnostics, entity `2117`, Spark Rat SpriteFrames frame counts `idle/run/attack_tell/attack/hurt/death=3`, active hazard id `old_factory_lower_deck_post_relay_trial`, route label `Clear Relay Forward Trial`, service lift prompt `Call lift`, defeat transition to `Relay Forward Secured`, persisted local flags, clean game log, and non-empty `960x539` game framebuffer capture. Editor log still returned pre-existing Story015 `CombatComponent` cache rows; Story015 CLI `reports/report_1083/` passes, so no current project failure is reproduced.
- Blockers: None. New enemy family art, authored steam/combat SFX, minimap markers, global quest state, service-lift route changes, broader lower-deck rooms, and boss content remain out of scope.
- Next: continue another ACT-visible slice such as deeper lower-deck combat content, minimap/savepoint feedback, authored/final audio replacement, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-03

- Story: `production/epics/player-abilities/story-069-old-factory-lower-deck-forward-pressure-traverse.md` -- Old Factory Lower Deck Forward Pressure Traverse
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_traverse_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-069-old-factory-lower-deck-forward-pressure-traverse.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-traverse-2026-07-03.md`, `reports/report_1103/`, `reports/report_1104/`, `reports/report_1105/`, `reports/report_1106/`, `reports/old_factory_forward_pressure_traverse_smoke.log`, `production/session-state/active.md`
- Implementation: Added a short forward pressure traversal after the lower-deck forward conduit is cleared. `FactoryLowerDeckForwardPressureVent` stays hidden/non-contacting before the conduit is defeated; after defeat it becomes visible, then crossing x `1284.0` starts a deterministic grace/warning/active/safe cycle. Only active phase enables `apply_factory_steam_vent_contact` damage. Crossing x `1328.0` persists `factory_lower_deck_forward_pressure_traverse_crossed=true`, disables the vent, and advances route feedback to `Forward Pressure Traverse Crossed`.
- Asset pipeline: No new visual/audio asset was generated. Story069 reuses the existing image-generated Old Factory steam vent hazard texture and records the new usage in the asset manifest, entity inventory, story, and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_traverse_test.gd` covers conduit-clear gating, route-label compatibility with Story068, phase diagnostics, active-window damage, safe-window disablement, one-shot completion, crossed-state persistence, Story068 no-replay, entity `2118` inactive, and service-lift prompt preservation.
- Verification: RED focused `reports/report_1103/` failed as expected before Story069 APIs existed. Focused GREEN `reports/report_1104/` passed `2/2`. Related GREEN `reports/report_1105/` passed `16/16`. Story015 stale-row isolation `reports/report_1106/` passed `5/5`. Headless Factory smoke `reports/old_factory_forward_pressure_traverse_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan. Godot AI MCP `2.8.3` runtime launched `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`, confirmed helper live, pressure vent present, phase diagnostics, active-window damage `100 -> 92`, safe-window contact disabled, crossed persistence, Story068 clear burst `spawn_count=0`, inactive entity `2118`, service lift `Call lift`, game log containing only helper registration, and non-empty screenshot metadata `960x539`. Editor Debugger still surfaced pre-existing Story015 stale `CombatComponent` rows; current Story015 CLI verification passed in `reports/report_1106/`.
- Blockers: None. New enemy families, new lower-deck rooms, reward caches, new audio events, particles/shaders, minimap markers, fast travel, SaveSystem schema expansion, global quest state, service-lift route changes, boss content, and new generated visual assets remain out of scope.
- Next: continue another ACT-visible slice such as a deeper Old Factory route objective, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-03

- Story: `production/epics/player-abilities/story-070-old-factory-lower-deck-forward-pressure-counter-ambush.md` -- Old Factory Lower Deck Forward Pressure Counter-Ambush
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_counter_ambush_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-070-old-factory-lower-deck-forward-pressure-counter-ambush.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-counter-ambush-2026-07-03.md`, `reports/report_1107/`, `reports/report_1108/`, `reports/report_1109/`, `reports/old_factory_forward_pressure_counter_ambush_smoke.log`, `production/session-state/active.md`
- Implementation: Added a one-shot counter-ambush after Story069's forward pressure traverse is crossed. `FactoryLowerDeckForwardCounterSparkRat` and `FactoryLowerDeckForwardCounterPressureVent` stay hidden/disabled until `factory_lower_deck_forward_pressure_traverse_crossed=true` and Cinderpaw crosses x `1336.0`; activation enables entity `2119`, Spark Rat pacing/targeting, steam contact pressure, and route feedback `Survive Forward Pressure Ambush`. Defeating entity `2119` disables the enemy/hazard, persists Story070 activation/defeat flags, and advances route feedback to `Forward Pressure Ambush Cleared` without replaying Story067-069 prerequisite content. `FactoryServiceLift` remains optional with prompt `Call lift`.
- Asset pipeline: No new visual or audio asset was generated. Story070 reuses the existing image-generated Factory Spark Rat `AnimatedSprite2D + SpriteFrames` asset, the existing Old Factory steam vent hazard prop, and the post-bulkhead backdrop. New usage is recorded in the asset manifest, entity inventory, story, and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_counter_ambush_test.gd` covers Story069 crossed gating, activation boundary, active enemy/hazard diagnostics, Spark Rat frame counts for `idle/run/attack_tell/attack/hurt/death`, route feedback, service-lift prompt preservation, defeat persistence, and restored completed state without prerequisite replay.
- Verification: RED focused `reports/report_1107/` failed as expected before Story070 APIs existed. Focused GREEN `reports/report_1108/` passed Story070 `2/2`. Related GREEN `reports/report_1109/` passed Story070, Story069, Story068, Story067, Story009, and service-lift SceneManager exit suites `14/14`. Headless Factory smoke `reports/old_factory_forward_pressure_counter_ambush_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan, aside from the known Godot cleanup-time resource message. Godot AI MCP `2.8.3` runtime launched `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`, confirmed helper live, active entity `2119`, Spark Rat SpriteFrames frame counts `idle/run/attack_tell/attack/hurt/death=3`, active hazard id `old_factory_lower_deck_forward_pressure_counter_ambush`, damage `8`, cooldown `1.0`, route label `Survive Forward Pressure Ambush`, defeat transition `Forward Pressure Ambush Cleared`, persisted Story070 flags, no Story067-069 prerequisite replay, service lift `Call lift`, clean game/editor logs, and non-empty `960x539` game screenshot metadata.
- Blockers: None. New enemy families, new lower-deck rooms, reward caches, authored combat/hazard audio, particles/shaders, minimap markers, fast travel, SaveSystem schema expansion, global quest state, service-lift route changes, boss content, and new generated visual assets remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory route combat, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-03

- Story: `production/epics/player-abilities/story-071-old-factory-lower-deck-forward-pressure-reward-cache.md` -- Old Factory Lower Deck Forward Pressure Reward Cache
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_reward_cache_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-071-old-factory-lower-deck-forward-pressure-reward-cache.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-reward-cache-2026-07-03.md`, `reports/report_1110/`, `reports/report_1111/`, `reports/report_1112/`, `reports/old_factory_forward_pressure_reward_cache_smoke.log`, `production/session-state/active.md`
- Implementation: Added a once-only reward cache payoff after Story070's forward pressure counter-ambush is cleared. `FactoryLowerDeckForwardPressureRewardCache` stays hidden and non-claimable until `factory_lower_deck_forward_pressure_counter_ambush_defeated=true`; then it becomes visible, shows prompt `+20 Gears`, and claims through `FactoryCombatCache`. The first claim grants `20` gears with source/cache id `old_factory_lower_deck_forward_pressure_reward_cache`, records route feedback `Forward Pressure Cache Claimed +20 Gears`, persists `factory_lower_deck_forward_pressure_reward_cache_claimed=true`, and rejects duplicate claims.
- Asset pipeline: No new visual or audio asset was generated. Story071 reuses the existing image-generated lower-deck reward cache texture `res://assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png` and records the new forward-pressure cache usage in the asset manifest, entity inventory, story, and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_reward_cache_test.gd` covers Story070 clear gating, cache id/texture/prompt contract, once-only claim payload/feedback, scene-local persistence, Story068-070 no-replay restore semantics, relay-forward cache continuity, and service-lift prompt preservation.
- Verification: RED focused `reports/report_1110/` failed as expected before Story071 APIs and diagnostics existed. Focused GREEN `reports/report_1111/` passed Story071 `2/2`. Related GREEN `reports/report_1112/` passed Story071, Story070, Story069, Story068, Story066, and service-lift SceneManager exit suites `12/12`. Headless Factory smoke `reports/old_factory_forward_pressure_reward_cache_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan, aside from the known Godot cleanup-time resource message. Godot AI MCP `2.8.3` runtime launched `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`, confirmed helper live, cache hidden before Story070 clear, visible/claimable after Story070 clear, image-generated texture path, once-only `+20 Gears` claim, local-state persistence, no Story068-070 prerequisite replay, service lift `Call lift`, game log containing only helper registration, empty editor log, and non-empty screenshot metadata `960x539`.
- Blockers: None. New enemy families, new room art, SaveSystem schema changes, minimap markers, global quest state, service-lift route changes, new audio, particles/shaders, new generated visual assets, and broader reward economy balancing remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory route combat/reward content, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-03

- Story: `production/epics/player-abilities/story-072-old-factory-lower-deck-forward-pressure-reward-cache-audio-feedback.md` -- Old Factory Lower Deck Forward Pressure Reward Cache Audio Feedback
- Files changed: `src/presentation/audio_system.gd`, `src/gameplay/old_factory_entrance_scene.gd`, `tests/unit/presentation/audio_system_test.gd`, `tests/unit/gameplay/old_factory_forward_pressure_reward_cache_audio_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-072-old-factory-lower-deck-forward-pressure-reward-cache-audio-feedback.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-reward-cache-audio-feedback-2026-07-03.md`, `reports/report_1113/`, `reports/report_1114/`, `reports/report_1115/`, `reports/old_factory_forward_pressure_reward_cache_audio_smoke.log`, `production/session-state/active.md`
- Implementation: Added a generic reward-cache claim audio route. `AudioSystem.on_reward_cache_claimed(...)` maps `reward_cache_claimed` to the existing imported `sfx_door_unlock` cue with spatial position, priority `90`, stream-found diagnostics, and metadata for cache id/source, `gears/reward_gears`, scene id, feedback role, route label, and world position. `OldFactoryEntranceScene` now calls that route only from the Story071 forward-pressure reward cache's fresh claim handler, records deterministic claim-audio diagnostics, preserves the `+20 Gears` reward payload/route feedback/local persistence, suppresses duplicate replay, and does not replay on restored claimed state.
- Asset pipeline: No new visual or audio asset was generated. Story072 reuses `res://assets/audio/sfx/sfx_door_unlock_baseline_short.wav`; the new usage is recorded in `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, story, and QA evidence.
- Test written: `tests/unit/presentation/audio_system_test.gd` covers `on_reward_cache_claimed -> sfx_door_unlock` metadata and stream routing. `tests/unit/gameplay/old_factory_forward_pressure_reward_cache_audio_test.gd` covers first-claim spatial audio, runtime AudioSystem event, duplicate suppression, restored no-replay, and deterministic scene diagnostics.
- Verification: RED focused `reports/report_1113/report_1/` failed as expected before `AudioSystem.on_reward_cache_claimed` and Story072 claim-audio diagnostics existed. Focused GREEN `reports/report_1114/report_2/` passed AudioSystem and Story072 gameplay suites `26/26`. Related GREEN `reports/report_1115/report_1/` passed Story072, Story071, Story070, Story069, Story068, Story066, Story064 relay audio, and service-lift suites `42/42`. Headless Factory smoke `reports/old_factory_forward_pressure_reward_cache_audio_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan, aside from the known Godot cleanup-time resource message. Godot AI MCP `2.8.3` runtime launched `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`, confirmed helper live, cache visible/claimable, first claim `true`, duplicate claim `false`, `claim_audio_request_count=1`, `reward_cache_claimed -> sfx_door_unlock`, `stream_found=true`, restored claimed state no-replay, route label `Forward Pressure Cache Claimed +20 Gears`, service lift `Call lift`, game log containing only helper registration, empty editor log, and non-empty `960x539` game screenshot metadata.
- Blockers: None. New WAV assets, final mixing/mastering, global reward-cache audio policy, economy tuning, SaveSystem schema changes, service-lift routing, minimap or fast-travel changes, new enemies, new room art, particles/shaders, Boss2 reward audio, and DEATH/CUTSCENE audio state work remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory route combat/reward content, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-06

- Story: `production/epics/player-abilities/story-074-old-factory-lower-deck-forward-pressure-exit-relay-savepoint.md` -- Old Factory Lower Deck Forward Pressure Exit Relay Savepoint
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_exit_relay_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-074-old-factory-lower-deck-forward-pressure-exit-relay-savepoint.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-exit-relay-savepoint-2026-07-06.md`, `reports/report_1122/`, `reports/report_1123/`, `reports/report_1124/`, `reports/old_factory_forward_pressure_exit_relay_smoke.log`, `production/session-state/active.md`
- Implementation: Added `FactoryLowerDeckForwardPressureExitRelaySavepoint` to `factory_route_transition_shell.tscn` using `SavepointRuntime`, reusing the image-generated lower-deck breach relay prop and existing unlock spark VFX. `OldFactoryEntranceScene` now gates it behind `factory_lower_deck_forward_pressure_exit_guard_defeated=true`, activates it once with prompt `Repair Exit Relay`, persists `factory_lower_deck_forward_pressure_exit_relay_activated=true`, records the stable `old_factory_lower_deck_forward_pressure_exit_relay / area_03_factory / lower_deck_forward_pressure_exit_relay` savepoint contract, and routes non-boss death back to the relay at 50% HP with respawn visual feedback and route label `Returned to Forward Pressure Exit Relay`. Restored completed state now normalizes an older breach-relay checkpoint to the exit relay when the exit relay flag is active.
- Asset pipeline: No new visual or audio assets were generated. Story074 reuses the image-generated lower-deck breach relay PNG and the existing Old Factory unlock spark VFX; reuse is recorded in the asset manifest, entity inventory, story, and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_exit_relay_test.gd` covers exit-guard defeat gating, hidden/non-monitoring locked state, prompt/texture/contract, once-only activation, local-state persistence, service-lift preservation, non-boss respawn to the new relay, restored completed-state no-replay, and restored old-checkpoint normalization back to the exit relay.
- Verification: RED restored-checkpoint regression `reports/report_1122/` failed as expected before restored completed state normalized to the exit relay. Focused GREEN `reports/report_1123/` passed Story074 `2/2`. Related GREEN `reports/report_1124/` passed Story074, Story073, Story072, Story071, Story070, Story069, breach relay, return checkpoint/respawn, service-lift, factory route roundtrip, player respawn visual feedback, and no-loss respawn state suites `31/31`. Headless Factory smoke `reports/old_factory_forward_pressure_exit_relay_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan, aside from the known Godot cleanup-time resource message. Godot AI MCP `2.8.3` runtime launched `res://scenes/factory_route_transition_shell.tscn` with `autosave=false`, confirmed helper live, relay node/children present, once-only activation, stable savepoint contract, non-boss death to exit relay at `50/100` HP with respawn visual feedback, restored old-checkpoint state normalized to the exit relay, service lift `Call lift`, game log containing only helper registration, empty editor log, and non-empty screenshot metadata `960x539`.
- Blockers: None. New enemies/combat encounters, new room art, new visual/audio generation, SaveSystem schema changes, service-lift route changes, minimap/fast travel UI, boss content, particles/shaders, authored relay SFX, and character frame-animation changes remain out of scope.
- Next: continue another ACT-visible slice such as a minimap/savepoint feedback pass, deeper Old Factory route content after the exit relay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-06

- Story: `production/epics/player-abilities/story-075-old-factory-lower-deck-forward-pressure-exit-gate-handoff.md` -- Old Factory Lower Deck Forward Pressure Exit Gate Handoff
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_exit_gate_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-075-old-factory-lower-deck-forward-pressure-exit-gate-handoff.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-exit-gate-handoff-2026-07-06.md`, `reports/report_1125/`, `reports/report_1127/`, `reports/report_1128/`, `reports/old_factory_forward_pressure_exit_gate_smoke.log`, `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-exit-gate-20260706.png`, `production/session-state/active.md`
- Implementation: Added `FactoryLowerDeckForwardPressureExitGate` after the Story074 forward-pressure exit relay. The gate reuses `FactoryDeepRouteEndpoint`, the image-generated lower-deck deep-bulkhead door texture, and the existing Old Factory unlock spark VFX. It stays hidden, non-interactable, and non-blocking until `factory_lower_deck_forward_pressure_exit_relay_activated=true`; after relay repair it becomes visible with prompt `Open Exit Gate`, opens once from player range, disables its local blocker, persists `factory_lower_deck_forward_pressure_exit_gate_opened=true`, and advances route feedback to `Forward Pressure Exit Gate Opened` without changing the Story074 savepoint contract or service-lift routing.
- Asset pipeline: No new visual or audio assets were generated. Story075 reuses the existing image-generated deep-bulkhead door and unlock spark VFX, records the reuse in the asset manifest, entity inventory, story, and QA evidence, and captures visual evidence at `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-exit-gate-20260706.png`.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_exit_gate_test.gd` covers relay-gated availability, hidden/non-blocking locked state, prompt/texture/id contract, once-only opening, persisted local state, restored completed state, Story074 relay savepoint preservation, Story068/071/073 no-replay checks, and `FactoryServiceLift` prompt preservation.
- Verification: RED focused `reports/report_1125/` failed as expected before Story075 diagnostics/open APIs existed. Focused GREEN `reports/report_1127/` passed Story075 `2/2`. Related GREEN `reports/report_1128/` passed Story075 plus Story074-069, service-lift, factory route roundtrip, and no-loss respawn suites `21/21`. Headless Factory smoke `reports/old_factory_forward_pressure_exit_gate_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan, aside from the known Godot cleanup-time resource message in terminal output. Godot AI MCP `2.8.4` runtime launched the factory scene with helper live, confirmed the gate node/children, locked/ready/opened/restored diagnostics, first open `true`, duplicate open `false`, persisted gate-open flag, stable exit-relay savepoint contract, Story068/071/073 no-replay, service lift `Call lift`, and clean game/editor logs. MCP screenshot helper timed out, so final visual evidence was captured through a temporary Godot 4.7 render script that was removed after use.
- Blockers: None. New lower-deck room scene, service-lift route changes, SaveSystem schema changes, new visual/audio assets, minimap/fast-travel UI, new enemies, boss content, and character frame-animation changes remain out of scope.
- Next: continue another ACT-visible slice such as deeper route content beyond the exit gate, minimap/savepoint feedback, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-06

- Story: `production/epics/player-abilities/story-076-old-factory-lower-deck-forward-pressure-route-handoff-marker.md` -- Old Factory Lower Deck Forward Pressure Route Handoff Marker
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_route_handoff_marker_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-076-old-factory-lower-deck-forward-pressure-route-handoff-marker.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-route-handoff-marker-2026-07-06.md`, `reports/report_1129/`, `reports/report_1130/`, `reports/report_1131/`, `reports/old_factory_forward_pressure_route_handoff_marker_smoke.log`, `production/session-state/active.md`
- Implementation: Added `FactoryLowerDeckForwardPressureRouteHandoffMarker` after the Story075 forward-pressure exit gate. The marker reuses `FactoryDeepRouteEndpoint`, the image-generated Old Factory deep-route endpoint prop, and the existing unlock spark VFX. It stays hidden and non-interactable until `factory_lower_deck_forward_pressure_exit_gate_opened=true`; after the gate opens it becomes visible with prompt `Light Route Beacon`, lights once from player range, persists `factory_lower_deck_forward_pressure_route_handoff_marker_lit=true`, and advances route feedback to `Forward Pressure Route Beacon Lit` without changing the Story074 savepoint contract or service-lift routing.
- Asset pipeline: No new visual or audio assets were generated. Story076 reuses the existing image-generated deep-route endpoint prop and unlock spark VFX, and records the reuse in the asset manifest, entity inventory, story, and QA evidence. MCP returned a non-empty `960x539` game screenshot showing the lit marker and route label.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_route_handoff_marker_test.gd` covers gate-open-gated marker visibility/interactivity, prompt/texture/id contract, once-only activation, persisted local state, restored completed state, Story074 relay savepoint preservation, Story068/071/073 no-replay checks, and `FactoryServiceLift` prompt preservation.
- Verification: RED focused `reports/report_1129/` failed as expected before Story076 diagnostics/activation APIs existed. Focused GREEN `reports/report_1130/` passed Story076 `2/2`. Related GREEN `reports/report_1131/` passed Story076 plus Story075-069, service-lift, factory route roundtrip, and no-loss respawn suites `23/23`. Headless Factory smoke `reports/old_factory_forward_pressure_route_handoff_marker_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan. Godot AI MCP `2.9.1` runtime launched the factory scene with helper live, confirmed the marker node/children, locked/ready/lit/restored diagnostics, first activation `true`, duplicate activation `false`, persisted marker-lit flag, stable exit-relay savepoint contract, Story068/071/073 no-replay, service lift `Call lift`, clean game/editor logs after clearing eval probe noise, and a non-empty `960x539` game screenshot.
- Blockers: None. New lower-deck room scene, service-lift route changes, SaveSystem schema changes, new visual/audio assets, minimap/fast-travel UI, new enemies, boss content, and character frame-animation changes remain out of scope.
- Next: continue another ACT-visible slice such as deeper route content beyond the route marker, minimap/savepoint feedback, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-06

- Story: `production/epics/player-abilities/story-077-old-factory-lower-deck-forward-pressure-beacon-ambush.md` -- Old Factory Lower Deck Forward Pressure Beacon Ambush
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_beacon_ambush_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-077-old-factory-lower-deck-forward-pressure-beacon-ambush.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-beacon-ambush-2026-07-06.md`, `reports/report_1132/`, `reports/report_1137/`, `reports/report_1138/`, `reports/old_factory_forward_pressure_beacon_ambush_smoke.log`, `production/session-state/active.md`
- Implementation: Added a marker-gated forward-pressure beacon ambush beyond Story076. `FactoryLowerDeckForwardPressureBeaconAmbushSparkRat` and `FactoryLowerDeckForwardPressureBeaconAmbushVent` stay hidden/inactive until `factory_lower_deck_forward_pressure_route_handoff_marker_lit=true`; crossing activation x `1560.0` activates entity `2121`, assigns Cinderpaw as target, enables Spark Rat process/physics, enables the pressure vent hazard `old_factory_lower_deck_forward_pressure_beacon_ambush`, and shows route feedback `Clear Forward Pressure Beacon Ambush`. Defeating entity `2121` disables the enemy/hazard, persists activation and defeat flags, marks the route objective complete, and advances feedback to `Forward Pressure Beacon Ambush Cleared` without changing the Story074 relay savepoint or service-lift routing.
- Asset pipeline: No new visual or audio assets were generated. Story077 reuses the image-generated Factory Spark Rat `AnimatedSprite2D + SpriteFrames` asset, the generated `attack_tell` strip, the Old Factory steam vent hazard prop, and the post-bulkhead backdrop. Reuse is recorded in the asset manifest, entity inventory, story, and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_beacon_ambush_test.gd` covers route-marker gating, activation range, Spark Rat frame counts for `idle/run/attack_tell/attack/hurt/death`, hazard activation semantics, route feedback, service-lift prompt preservation, defeat persistence, restored completed state, route objective completion, Story074 savepoint contract, and Story068/071/073 no-replay checks.
- Verification: RED focused `reports/report_1132/` failed as expected before Story077 APIs existed. Focused GREEN `reports/report_1137/` passed Story077 `2/2`. Related GREEN `reports/report_1138/` passed Story077, Story076, Story075, Story074, Story073, Story070, service-lift, and no-loss respawn suites `16/16`. Headless Factory smoke `reports/old_factory_forward_pressure_beacon_ambush_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan, aside from known Godot cleanup-time ObjectDB/resource messages in terminal output. Godot AI MCP `2.9.1` on Godot `4.7-stable` launched the factory scene with `autosave=false`, confirmed helper live, runtime nodes, Spark Rat SpriteFrames frame counts `3` for all required animations, locked/ready/active/defeated/restored diagnostics, entity `2121`, active hazard id and texture, persisted local flags, stable Story074 savepoint contract, Story068/071/073 no-replay, service lift `Call lift`, game log containing only helper registration, and a non-empty `960x539` game screenshot. An earlier eval probe caused an eval-script parser break and was discarded; the formal MCP evidence came from a fresh restarted run.
- Blockers: None. New room art, new enemy family art, authored combat/hazard SFX, minimap/fast travel UI, SaveSystem schema expansion, service-lift route changes, reward economy changes, particles/shaders, and boss content remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory route combat after the beacon ambush, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-08

- Story: `production/epics/player-abilities/story-078-old-factory-lower-deck-forward-pressure-overrun.md` -- Old Factory Lower Deck Forward Pressure Overrun
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_overrun_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-078-old-factory-lower-deck-forward-pressure-overrun.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-overrun-2026-07-08.md`, `reports/report_1139/`, `reports/report_1142/`, `reports/report_1143/`, `reports/old_factory_forward_pressure_overrun_smoke.log`, `production/session-state/active.md`
- Implementation: Added a Story077-gated forward-pressure overrun beyond the beacon ambush. `FactoryLowerDeckForwardPressureOverrunSparkRat` and `FactoryLowerDeckForwardPressureOverrunVent` stay hidden/inactive until `factory_lower_deck_forward_pressure_beacon_ambush_defeated=true`; crossing activation x `1620.0` activates entity `2122`, assigns Cinderpaw as target, enables Spark Rat process/physics, enables pressure vent hazard `old_factory_lower_deck_forward_pressure_overrun`, and shows route feedback `Survive Forward Pressure Overrun`. Defeating entity `2122` disables the enemy/hazard, persists activation and defeat flags, marks the route objective complete, and advances feedback to `Forward Pressure Overrun Cleared` without changing the Story074 relay savepoint or service-lift routing.
- Asset pipeline: No new visual or audio assets were generated. Story078 reuses the image-generated Factory Spark Rat `AnimatedSprite2D + SpriteFrames` asset, the generated `attack_tell` strip, the Old Factory steam vent hazard prop, and the post-bulkhead backdrop. Reuse is recorded in the asset manifest, entity inventory, story, and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_overrun_test.gd` covers beacon-ambush-clear gating, activation range, Spark Rat frame counts for `idle/run/attack_tell/attack/hurt/death`, hazard activation semantics, route feedback, service-lift prompt preservation, defeat persistence, restored completed state, route objective completion, Story074 savepoint contract, and Story068/071/073/077 no-replay checks.
- Verification: RED focused `reports/report_1139/` failed as expected before Story078 APIs existed. Focused GREEN `reports/report_1142/` passed Story078 `2/2`. Related GREEN `reports/report_1143/` passed Story078, Story077, Story076, Story075, Story074, Story073, Story070, service-lift, and no-loss respawn suites `18/18`. Headless Factory smoke `reports/old_factory_forward_pressure_overrun_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan, aside from known Godot cleanup-time ObjectDB/resource messages in terminal output. Godot AI MCP `2.9.1` on Godot `4.7-stable` launched the factory scene with `autosave=false`, confirmed helper live, locked/ready/active/defeated/restored diagnostics, Spark Rat SpriteFrames frame counts `3` for all required animations, entity `2122`, active hazard id/damage/cooldown/texture, persisted local flags, stable Story074 savepoint contract, Story068/071/073/077 no-replay, service lift `Call lift`, game log containing only helper registration, empty editor log, and a non-empty `960x539` game screenshot.
- Blockers: None. New room art, new enemy family art, authored combat/hazard SFX, minimap/fast travel UI, SaveSystem schema expansion, service-lift route changes, reward economy changes, particles/shaders, and boss content remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory route combat after the overrun, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-08

- Story: `production/epics/player-abilities/story-079-old-factory-lower-deck-forward-pressure-breaker.md` -- Old Factory Lower Deck Forward Pressure Breaker
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_breaker_test.gd`, `assets/environment/old_factory_forward_pressure_breaker/env_old_factory_forward_pressure_breaker_console_256.png`, `assets/generated/source/old_factory_forward_pressure_breaker_console_imagegen_20260708.png`, `assets/generated/source/old_factory_forward_pressure_breaker_console_alpha_20260708.png`, `assets/generated/source/old_factory_forward_pressure_breaker_console_imagegen_20260708.md`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-079-old-factory-lower-deck-forward-pressure-breaker.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-breaker-2026-07-08.md`, `reports/report_1144/`, `reports/report_1147/`, `reports/report_1148/`, `reports/old_factory_forward_pressure_breaker_smoke.log`, `production/session-state/active.md`
- Implementation: Added a Story078-gated forward-pressure breaker stand. `FactoryLowerDeckForwardPressureBreakerSparkRat`, `FactoryLowerDeckForwardPressureBreakerVent`, and `FactoryLowerDeckForwardPressureBreaker` stay hidden/inactive until `factory_lower_deck_forward_pressure_overrun_defeated=true`; crossing activation x `1668.0` activates entity `2123`, targets Cinderpaw, enables Spark Rat process/physics, enables pressure vent hazard `old_factory_lower_deck_forward_pressure_breaker`, and shows route feedback `Secure Forward Pressure Breaker`. Defeating entity `2123` disables the enemy/hazard, persists activation/secured flags, reveals the breaker console, and allows a one-shot pressure cut that persists `factory_lower_deck_forward_pressure_breaker_cut=true`, plays existing unlock VFX once, rejects duplicate cuts, and advances feedback to `Forward Pressure Breaker Cut`.
- Asset pipeline: Generated a new breaker console PNG through image generation, preserved chroma-key and alpha-matted sources, processed it to a transparent `256x256` RGBA runtime prop, imported it through Godot, and recorded the prompt/source in `assets/generated/source/old_factory_forward_pressure_breaker_console_imagegen_20260708.md`, the asset manifest, entity inventory, story, and QA evidence. Story079 reuses Factory Spark Rat `AnimatedSprite2D + SpriteFrames`, the Old Factory steam vent prop, post-bulkhead backdrop, and unlock spark VFX.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_breaker_test.gd` covers overrun-clear gating, activation range, entity `2123`, Spark Rat frame counts for `idle/run/attack_tell/attack/hurt/death`, hazard activation semantics, generated breaker texture path, one-shot cut activation, local-state persistence, restored no-replay, Story078 overrun inactive/defeated continuity, route objective completion, Story074 savepoint contract, and service-lift prompt preservation.
- Verification: RED focused `reports/report_1144/` failed as expected before Story079 diagnostics/APIs existed. Focused GREEN `reports/report_1147/` passed Story079 `2/2`. Related GREEN `reports/report_1148/` passed Story079, Story078, Story077, Story076, Story075, Story074, Story073, service-lift, and no-loss respawn suites `18/18`. Headless Factory smoke `reports/old_factory_forward_pressure_breaker_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan, aside from known Godot cleanup-time ObjectDB/resource messages in terminal output. Godot AI MCP `2.9.1` on Godot `4.7-stable` launched the factory scene with `autosave=false`, confirmed helper live, locked/ready/active/secured/cut/restored diagnostics, Spark Rat SpriteFrames frame counts `3`, entity `2123`, generated breaker texture, active hazard id/damage/cooldown, cut activation true, duplicate cut false, persisted local flags, restored unlock VFX no-replay `spawn_count=0`, service lift `Call lift`, game log containing only helper registration, empty editor log, and non-empty `960x539` MCP game screenshots for active and secured states.
- Blockers: None. New enemy family art, new room scene, SaveSystem schema changes, service-lift route changes, minimap/fast-travel UI, authored audio, particles/shaders, boss content, and broader lower-deck layout work remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory route content after the breaker, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-08

- Story: `production/epics/player-abilities/story-080-old-factory-lower-deck-forward-pressure-relief-ambush.md` -- Old Factory Lower Deck Forward Pressure Relief Ambush
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_relief_ambush_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-080-old-factory-lower-deck-forward-pressure-relief-ambush.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-relief-ambush-2026-07-08.md`, `reports/report_1150/`, `reports/report_1151/`, `reports/report_1152/`, `reports/old_factory_forward_pressure_relief_ambush_smoke.log`, `production/session-state/active.md`
- Implementation: Added a Story079-gated post-breaker relief ambush. `FactoryLowerDeckForwardPressureReliefSparkRat` and `FactoryLowerDeckForwardPressureReliefVent` stay hidden/inactive until `factory_lower_deck_forward_pressure_breaker_cut=true`; crossing activation x `1804.0` activates entity `2124`, assigns Cinderpaw as target, enables Spark Rat process/physics, enables pressure vent hazard `old_factory_lower_deck_forward_pressure_relief_ambush`, and shows route feedback `Survive Forward Pressure Relief Ambush`. Defeating entity `2124` disables the enemy/hazard, persists activation and defeat flags, marks the route objective complete, and advances feedback to `Forward Pressure Relief Ambush Cleared` without changing the Story074 relay savepoint or service-lift routing.
- Asset pipeline: No new visual or audio assets were generated. Story080 reuses the image-generated Factory Spark Rat `AnimatedSprite2D + SpriteFrames` asset, the generated `attack_tell` strip, the Old Factory steam vent hazard prop, and the post-bulkhead backdrop. Reuse is recorded in the asset manifest, entity inventory, story, and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_relief_ambush_test.gd` covers breaker-cut gating, activation range, Spark Rat frame counts for `idle/run/attack_tell/attack/hurt/death`, hazard activation semantics, route feedback, service-lift prompt preservation, defeat persistence, restored completed state, route objective completion, Story074 savepoint contract, and Story068/071 no-replay checks.
- Verification: RED focused `reports/report_1150/` failed as expected before Story080 APIs existed. Focused GREEN `reports/report_1151/` passed Story080 `2/2`. Related GREEN `reports/report_1152/` passed Story080, Story079, Story078, Story077, Story076, Story075, Story074, service-lift, and no-loss respawn suites `20/20`. Headless Factory smoke `reports/old_factory_forward_pressure_relief_ambush_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan, aside from known Godot cleanup-time ObjectDB/resource messages in terminal output. Godot AI MCP `2.9.1` on Godot `4.7-stable` launched the factory scene with `autosave=false`, confirmed helper live, found relief Spark Rat and vent nodes, verified locked/ready/active/defeated/restored diagnostics, Spark Rat SpriteFrames frame counts `3`, entity `2124`, active hazard id/damage/cooldown/texture, persisted local flags, stable Story074 savepoint contract, Story068/071 no-replay, service lift `Call lift`, game log containing only helper registration, empty editor log, and a non-empty `960x539` MCP game screenshot for the active relief ambush.
- Blockers: None. New room art, new enemy family art, authored combat/hazard SFX, minimap/fast travel UI, SaveSystem schema expansion, service-lift route changes, reward economy changes, particles/shaders, and boss content remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory route combat after the relief ambush, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-08

- Story: `production/epics/player-abilities/story-081-old-factory-lower-deck-forward-pressure-coil-rat-breakthrough.md` -- Old Factory Lower Deck Forward Pressure Coil Rat Breakthrough
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_coil_rat_breakthrough_test.gd`, `assets/characters/factory_coil_rat/`, `scenes/characters/factory_coil_rat.tscn`, `src/characters/factory_coil_rat.gd`, `src/gameplay/factory_coil_rat.gd`, `src/gameplay/factory_coil_rat.tscn`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-081-old-factory-lower-deck-forward-pressure-coil-rat-breakthrough.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-coil-rat-breakthrough-2026-07-08.md`, `reports/report_1154/`, `reports/report_1161/`, `reports/old_factory_forward_pressure_coil_rat_breakthrough_smoke.log`, `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-coil-rat-breakthrough-20260708.png`, `production/session-state/active.md`
- Implementation: Added a Story080-gated forward-pressure Coil Rat breakthrough after the relief ambush. `FactoryLowerDeckForwardPressureCoilRat` stays hidden/inactive until `factory_lower_deck_forward_pressure_relief_ambush_defeated=true`; crossing activation x `1888.0` activates entity `2125`, assigns Cinderpaw as target, enables process/physics, and shows route feedback `Face Coil Rat Breakthrough`. Defeating entity `2125` disables the enemy, persists activation/defeat flags, marks the route objective complete, and advances feedback to `Forward Pressure Coil Rat Breakthrough Cleared` without changing the Story074 exit relay savepoint or service-lift routing.
- Asset pipeline: Generated a new Factory Coil Rat sprite sheet through image generation, retained source, alpha source, preview, and prompt metadata under `assets/characters/factory_coil_rat/source/`, sliced it into transparent 96x96 runtime PNG frames under `assets/characters/factory_coil_rat/<animation>/`, and imported a SpriteFrames resource covering `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death`, each with 3 frames. Added the AGENTS-required character scene/script and gameplay wrapper scene/script, and recorded usage in the asset manifest, entity inventory, story, and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_coil_rat_breakthrough_test.gd` covers Story080 relief-clear gating, manual activation range, entity `2125`, target/process/physics, `factory_coil_rat` family id, SpriteFrames path and six animation frame counts, route feedback, defeat persistence, restored completed state, Story080/079/074 continuity, Story068/071 no-replay, and `FactoryServiceLift` prompt preservation.
- Verification: RED focused `reports/report_1154/` failed as expected before Story081 diagnostics/APIs existed. Fresh focused+related GREEN `reports/report_1161/` passed Story081, Story080, Story079, Story078, Story077, Story076, Story075, Story074, service-lift, and no-loss respawn suites `22/22`. Headless Factory smoke `reports/old_factory_forward_pressure_coil_rat_breakthrough_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan, aside from known Godot cleanup-time ObjectDB/resource messages in terminal output. Godot AI MCP `2.9.1` on Godot `4.7-stable` launched the factory scene with `autosave=false`, confirmed helper live, active Coil Rat diagnostics, entity `2125`, visible `CharacterBody2D`, child `AnimatedSprite2D`, SpriteFrames path and 3-frame counts for `idle/run/attack_tell/attack/hurt/death`, route label `Face Coil Rat Breakthrough`, defeat and restored completed-state contracts, Story080/079/074 preservation, Story068/071 no-replay, service lift `Call lift`, game log containing only helper registration, empty editor log after clearing eval-probe noise, and non-empty MCP game screenshot. Runtime viewport evidence was saved to `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-coil-rat-breakthrough-20260708.png`.
- Blockers: None. New AI behavior tree, new discharge attack mode, steam vent/hazard, reward economy changes, SaveSystem schema changes, service-lift route changes, minimap/fast-travel UI, authored audio, particles/shaders, Boss2, and broader lower-deck layout work remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory route combat after the Coil Rat breakthrough, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-09

- Story: `production/epics/player-abilities/story-082-old-factory-lower-deck-forward-pressure-coil-pincer.md` -- Old Factory Lower Deck Forward Pressure Coil Pincer
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_coil_pincer_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-082-old-factory-lower-deck-forward-pressure-coil-pincer.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-coil-pincer-2026-07-09.md`, `reports/report_1162/`, `reports/report_1166/`, `reports/report_1167/`, `reports/old_factory_forward_pressure_coil_pincer_smoke.log`, `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-coil-pincer-20260709.png`, `production/session-state/active.md`
- Implementation: Added a Story081-gated forward-pressure Coil Pincer after the Coil Rat breakthrough. `FactoryLowerDeckForwardPressureCoilPincerSparkRat` and `FactoryLowerDeckForwardPressureCoilPincerCoilRat` stay hidden/inactive until `factory_lower_deck_forward_pressure_coil_rat_breakthrough_defeated=true`; crossing activation x `2016.0` activates entity `2126` as the Spark Rat side and entity `2127` as the Coil Rat side, assigns Cinderpaw as target for both, enables process/physics for both, starts staggered opening grace frames `10/26`, and shows route feedback `Break Coil Pincer`. Defeating both enemies disables them, persists the activation/spark-defeated/coil-defeated/cleared flags, marks the route objective complete, and advances feedback to `Forward Pressure Coil Pincer Cleared` without changing the Story074 exit relay savepoint or service-lift routing.
- Asset pipeline: No new visual or audio assets were generated. Story082 reuses the image-generated Factory Spark Rat and Factory Coil Rat `AnimatedSprite2D + SpriteFrames` assets, including transparent 96x96 `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` frames. Reuse is recorded in the asset manifest, entity inventory, story, and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_coil_pincer_test.gd` covers Story081-clear gating, manual activation range, entity ids `2126/2127`, target/process/physics, enemy family ids, SpriteFrames paths and six animation frame counts for both enemies, staggered pacing `10/26`, route feedback, partial vs full defeat persistence, restored completed state, Story081/080/079/074 continuity, Story068/071 no-replay, and `FactoryServiceLift` prompt preservation.
- Verification: RED focused `reports/report_1162/` failed as expected before Story082 diagnostics/APIs existed. Focused GREEN `reports/report_1166/` passed Story082 `2/2`. Related GREEN `reports/report_1167/` passed Story082, Story081, Story080, Story079, Story078, Story077, Story076, Story075, Story074, service-lift, and no-loss respawn suites `24/24`. Headless Factory smoke `reports/old_factory_forward_pressure_coil_pincer_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan, aside from known Godot cleanup-time ObjectDB/resource messages in terminal output. Godot AI MCP `2.9.1` on Godot `4.7-stable` launched the factory scene with `autosave=false`, confirmed helper live, active pincer diagnostics, entities `2126/2127`, visible `AnimatedSprite2D` enemies, SpriteFrames path and 3-frame counts for `idle/run/attack_tell/attack/hurt/death`, opening grace frames `10/26`, route label `Break Coil Pincer`, partial and full defeat contracts, restored completed-state contracts, Story081/080/079/074 preservation, Story068/071 no-replay, service lift `Call lift`, game log containing only helper registration, empty editor log after clearing eval-probe noise, and non-empty MCP game screenshot saved to `reports/visual/cinderpaw-mcp-old-factory-forward-pressure-coil-pincer-20260709.png`.
- Blockers: None. New generated character art, new enemy family, new AI behavior tree, new hazard, reward economy changes, SaveSystem schema changes, service-lift route changes, minimap/fast-travel UI, authored audio, particles/shaders, Boss2, and broader lower-deck layout work remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory route combat after the Coil Pincer, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-09

- Story: `production/epics/player-abilities/story-083-old-factory-lower-deck-forward-pressure-coil-aftershock.md` -- Old Factory Lower Deck Forward Pressure Coil Aftershock
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_coil_aftershock_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-083-old-factory-lower-deck-forward-pressure-coil-aftershock.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-coil-aftershock-2026-07-09.md`, `reports/report_1169/`, `reports/report_1170/`, `reports/report_1171/`, `reports/old_factory_forward_pressure_coil_aftershock_smoke.log`, `production/session-state/active.md`
- Implementation: Added a Story082-gated forward-pressure Coil Aftershock after the Coil Pincer. `FactoryLowerDeckForwardPressureCoilAftershockCoilRat` stays hidden/inactive until `factory_lower_deck_forward_pressure_coil_pincer_cleared=true`; crossing activation x `2144.0` activates entity `2128`, assigns Cinderpaw as target, enables process/physics, starts opening grace frames `8`, and shows route feedback `Contain Coil Aftershock`. Defeating entity `2128` disables the enemy, persists activation/defeat/cleared flags, marks the route objective complete, and advances feedback to `Forward Pressure Coil Aftershock Cleared` without changing the Story074 exit relay savepoint or service-lift routing.
- Asset pipeline: No new visual or audio assets were generated. Story083 reuses the image-generated Factory Coil Rat `AnimatedSprite2D + SpriteFrames` asset, including transparent 96x96 `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` frames. Reuse is recorded in the asset manifest, entity inventory, story, and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_coil_aftershock_test.gd` covers Story082-clear gating, manual activation range, entity `2128`, target/process/physics, `factory_coil_rat` family id, SpriteFrames path and six animation frame counts, opening grace frame `8`, route feedback, defeat persistence, restored completed state, Story082/081/074 continuity, Story068/071 no-replay, and `FactoryServiceLift` prompt preservation.
- Verification: RED focused `reports/report_1169/` failed as expected before Story083 diagnostics/APIs existed. Focused GREEN `reports/report_1170/` passed Story083 `2/2`. Related GREEN `reports/report_1171/` passed Story083, Story082, Story081, Story080, Story079, Story078, Story077, Story076, Story075, Story074, service-lift, and no-loss respawn suites `24/24`. Headless Factory smoke `reports/old_factory_forward_pressure_coil_aftershock_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan. Godot AI MCP `2.9.1` on Godot `4.7-stable` launched the factory scene with `autosave=false`, confirmed helper live, locked/ready/active/defeated/restored diagnostics, entity `2128`, visible `AnimatedSprite2D` enemy, SpriteFrames path and 3-frame counts for `idle/run/attack_tell/attack/hurt/death`, opening grace frames `8`, route label `Contain Coil Aftershock`, defeat and restored completed-state contracts, Story074 exit-relay savepoint contract, Story068/071 no-replay, service lift `Call lift`, game log containing only helper registration, empty editor log after clearing eval-probe noise, and a non-empty `960x539` MCP game screenshot showing the active aftershock Coil Rat.
- Blockers: None. New generated character art, new enemy family, new AI behavior tree, new hazard, reward economy changes, SaveSystem schema changes, service-lift route changes, minimap/fast-travel UI, authored audio, particles/shaders, Boss2, and broader lower-deck layout work remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory route content after the Coil Aftershock, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-09

- Story: `production/epics/player-abilities/story-084-old-factory-lower-deck-forward-pressure-aftershock-reward-cache.md` -- Old Factory Lower Deck Forward Pressure Aftershock Reward Cache
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_reward_cache_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-084-old-factory-lower-deck-forward-pressure-aftershock-reward-cache.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-aftershock-reward-cache-2026-07-09.md`, `reports/report_1172/`, `reports/report_1176/`, `reports/report_1178/`, `reports/report_1179/`, `reports/report_1180/`, `reports/old_factory_forward_pressure_aftershock_reward_cache_smoke.log`, `production/session-state/active.md`
- Implementation: Added a Story083-gated once-only aftershock reward cache. `FactoryLowerDeckForwardPressureAftershockRewardCache` stays hidden/non-claimable until `factory_lower_deck_forward_pressure_coil_aftershock_cleared=true`; once available it shows `+20 Gears`, uses cache id/source `old_factory_lower_deck_forward_pressure_aftershock_reward_cache`, grants `20` gears on the first claim, rejects duplicate claims, persists `factory_lower_deck_forward_pressure_aftershock_reward_cache_claimed=true`, and advances route feedback to `Forward Pressure Aftershock Cache Claimed +20 Gears` without changing the Story074 exit relay savepoint or service-lift routing.
- Asset pipeline: No new visual or audio assets were generated. Story084 reuses the imported image-generated lower-deck reward cache prop `res://assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`; its original image-generation source, alpha source, and metadata remain under `assets/generated/source/old_factory_lower_deck_skirmish_cache_*`. Reuse is recorded in the asset manifest, entity inventory, story, and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_reward_cache_test.gd` covers Story083-clear gating, hidden/non-claimable locked state, live Story083 Coil Aftershock defeat unlocking the cache, cache id/source, texture path, `+20 Gears` prompt, once-only claim payload and feedback, local-state persistence, restored claimed state, Story083/082/081 continuity, Story074 exit-relay savepoint contract, Story068 clear-feedback no-replay, Story071 reward-cache audio no-replay, and `FactoryServiceLift` prompt preservation.
- Verification: RED focused `reports/report_1172/` failed as expected before Story084 diagnostics/APIs existed. Live-path RED `reports/report_1178/` failed after adding the real Story083 defeat coverage because the cache stayed locked until `_on_factory_lower_deck_forward_pressure_coil_aftershock_defeated()` synchronized the Story084 cache state. Focused GREEN `reports/report_1179/` passed Story084 `3/3`. Initial related GREEN `reports/report_1176/` passed Story084, Story083, Story071 audio no-replay, service-lift, and no-loss respawn suites `10/10`. Expanded related GREEN `reports/report_1180/` passed Story084, Story083 through Story074, Story071 audio no-replay, service-lift, and no-loss respawn suites `29/29`. Headless Factory smoke `reports/old_factory_forward_pressure_aftershock_reward_cache_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan. Godot AI MCP `2.9.1` on Godot `4.7-stable` launched the factory scene with helper live, confirmed live aftershock activation `true`, damage to entity `2128` `true`, cache visible/available/claimable after the defeat, runtime texture path, `+20 Gears` prompt, first claim `true`, duplicate claim `false`, `20` gear payload, route label `Forward Pressure Aftershock Cache Claimed +20 Gears`, Story074 exit-relay savepoint contract, service lift `Call lift`, game log containing only helper registration, empty editor log, and a non-empty `960x539` game screenshot with the cache visible.
- Blockers: None. New generated character art, new character animation, new enemy family, new AI behavior tree, new hazard, new reward economy, SaveSystem schema changes, service-lift route changes, minimap/fast-travel UI, authored audio, particles/shaders, Boss2, and broader lower-deck layout work remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory route content after the aftershock payoff cache, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-09

- Story: `production/epics/player-abilities/story-085-old-factory-lower-deck-forward-pressure-aftershock-exit-skirmish.md` -- Old Factory Lower Deck Forward Pressure Aftershock Exit Skirmish
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exit_skirmish_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-085-old-factory-lower-deck-forward-pressure-aftershock-exit-skirmish.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-aftershock-exit-skirmish-2026-07-09.md`, `reports/report_1181/`, `reports/report_1182/`, `reports/report_1183/`, `reports/report_1184/`, `reports/report_1185/`, `reports/report_1186/`, `reports/old_factory_forward_pressure_aftershock_exit_skirmish_smoke.log`, `production/session-state/active.md`
- Implementation: Added a Story084-gated aftershock exit skirmish beyond the payoff cache. `FactoryLowerDeckForwardPressureAftershockExitSkirmishSparkRat` and `FactoryLowerDeckForwardPressureAftershockExitSkirmishCoilRat` stay hidden/inactive until `factory_lower_deck_forward_pressure_aftershock_reward_cache_claimed=true`; crossing activation x `2288.0` activates entity `2129` as the Spark Rat side and entity `2130` as the Coil Rat side, assigns Cinderpaw as target for both, enables process/physics for both, starts staggered opening grace frames `12/24`, and shows route feedback `Break Aftershock Exit Skirmish`. Defeating both enemies disables them, persists activation/spark-defeated/coil-defeated/cleared flags, marks the route objective complete, and advances feedback to `Forward Pressure Aftershock Exit Skirmish Cleared`.
- Asset pipeline: No new visual or audio assets were generated. Story085 reuses the image-generated Factory Spark Rat and Factory Coil Rat `AnimatedSprite2D + SpriteFrames` assets, including transparent 96x96 `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` frames. Reuse is recorded in the asset manifest, entity inventory, story, and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exit_skirmish_test.gd` covers Story084-cache-claim gating, manual activation range, entity ids `2129/2130`, target/process/physics, enemy family ids, SpriteFrames paths and six animation frame counts for both enemies, staggered pacing `12/24`, route feedback, partial vs full defeat persistence, restored completed state, Story084/083/082/081 continuity, Story074 exit-relay savepoint contract, Story068/071 no-replay, and `FactoryServiceLift` prompt preservation.
- Verification: RED focused `reports/report_1181/` failed as expected before Story085 diagnostics/APIs existed. Transient implementation parse failure `reports/report_1182/` was fixed before acceptance. Focused GREEN `reports/report_1183/` passed Story085 `3/3`, and final pre-commit focused rerun `reports/report_1186/` passed Story085 `3/3`. Related GREEN `reports/report_1184/` passed Story085 through Story080 plus Story074/service-lift/no-loss coverage `20/20`. Expanded related GREEN `reports/report_1185/` passed Story085, Story084, Story083 through Story074, Story071 audio no-replay, service-lift, and no-loss respawn suites `36/36`. Headless Factory smoke `reports/old_factory_forward_pressure_aftershock_exit_skirmish_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan. Godot AI MCP `2.9.1` on Godot `4.7-stable` launched the factory scene with helper live, confirmed active skirmish diagnostics, entities `2129/2130`, visible `AnimatedSprite2D` enemies, SpriteFrames path and 3-frame counts for `idle/run/attack_tell/attack/hurt/death`, opening grace frames `12/24`, route label `Break Aftershock Exit Skirmish`, partial and full defeat contracts, restored completed-state contracts, Story084/083/082/081/074 preservation, Story068/071 no-replay, service lift `Call lift`, game log containing only helper registration, empty editor log after clearing eval-probe noise, and a non-empty `960x539` MCP game screenshot showing the active exit skirmish.
- Blockers: None. New generated character art, new enemy family, new AI behavior tree, new hazard, new reward economy, SaveSystem schema changes, service-lift route changes, minimap/fast-travel UI, authored audio, particles/shaders, Boss2, and broader lower-deck layout work remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory route content after the aftershock exit skirmish, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-09

- Story: `production/epics/player-abilities/story-086-old-factory-lower-deck-forward-pressure-aftershock-exhaust-traverse.md` -- Old Factory Lower Deck Forward Pressure Aftershock Exhaust Traverse
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exhaust_traverse_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-086-old-factory-lower-deck-forward-pressure-aftershock-exhaust-traverse.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-aftershock-exhaust-traverse-2026-07-09.md`, `reports/report_1187/`, `reports/report_1188/`, `reports/report_1190/`, `reports/old_factory_forward_pressure_aftershock_exhaust_traverse_smoke.log`, `production/session-state/active.md`
- Implementation: Added a Story085-gated aftershock exhaust traversal beat beyond the exit skirmish. `FactoryLowerDeckForwardPressureAftershockExhaustVent` stays hidden/non-contacting until `factory_lower_deck_forward_pressure_aftershock_exit_skirmish_cleared=true`; crossing activation x `2416.0` activates the vent, shows route feedback `Cross Aftershock Exhaust`, and cycles deterministic `grace -> warning -> active -> safe` phases. Only the active phase enables existing steam contact damage, non-player contact is ignored, and crossing completion x `2480.0` persists activated/crossed flags, disables the vent, marks the route objective complete, and advances feedback to `Forward Pressure Aftershock Exhaust Crossed`.
- Asset pipeline: No new visual or audio assets were generated. Story086 reuses the imported image-generated Old Factory steam vent hazard prop `res://assets/environment/old_factory_steam_vent/factory_steam_vent_hazard.png`; its original image-generation source and alpha source remain under `assets/generated/source/old_factory_steam_vent_hazard_*`. Reuse is recorded in the asset manifest, entity inventory, story, and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exhaust_traverse_test.gd` covers Story085-clear gating, manual activation range, phase timing, active-only steam contact damage, non-player contact rejection, completion persistence, restored completed state, Story085/084/074 continuity, Story068/071 no-replay, and `FactoryServiceLift` prompt preservation.
- Verification: RED focused `reports/report_1187/` failed as expected before Story086 diagnostics/APIs existed. Focused GREEN `reports/report_1188/` passed Story086 `3/3`. Final related GREEN `reports/report_1190/` passed Story086 plus Story085, Story084, Story083, Story069 steam traversal, Story074 relay, service-lift, audio no-replay, and no-loss respawn coverage `25/25`. Headless Factory smoke `reports/old_factory_forward_pressure_aftershock_exhaust_traverse_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan. Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed helper live, the exhaust vent node/script/texture/hazard id/damage/cooldown, locked/ready/grace/warning/active/safe/crossed/restored diagnostics, active-only player damage, Story074 exit-relay savepoint contract, Story068/071 no-replay, service lift `Call lift`, clean final game/editor logs, and a non-empty `960x539` MCP game screenshot showing the active exhaust vent.
- Blockers: None for Story086. ADR-0018 and ADR-0021 are still marked `Proposed` in project documentation; this is an existing governance/documentation risk rather than a Story086 runtime blocker.
- Next: continue another ACT-visible slice after the aftershock exhaust traverse, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-09

- Story: `production/epics/player-abilities/story-088-old-factory-lower-deck-forward-pressure-aftershock-exhaust-pursuer-reward-cache.md` -- Old Factory Lower Deck Forward Pressure Aftershock Exhaust Pursuer Reward Cache
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-088-old-factory-lower-deck-forward-pressure-aftershock-exhaust-pursuer-reward-cache.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-aftershock-exhaust-pursuer-reward-cache-2026-07-09.md`, `reports/report_1195/`, `reports/report_1196/`, `reports/report_1197/`, `reports/old_factory_forward_pressure_aftershock_exhaust_pursuer_reward_cache_smoke.log`, `production/session-state/active.md`
- Implementation: Added a Story087-gated once-only aftershock exhaust pursuer reward cache. `FactoryLowerDeckForwardPressureAftershockExhaustPursuerRewardCache` stays hidden/non-claimable until `factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_cleared=true`; once available it shows `+20 Gears`, uses cache id/source `old_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache`, grants `20` gears on the first claim, rejects duplicate claims, persists `factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_claimed=true`, and advances route feedback to `Forward Pressure Exhaust Pursuer Cache Claimed +20 Gears` without changing the Story074 exit relay savepoint or service-lift routing.
- Asset pipeline: No new visual or audio assets were generated. Story088 reuses the imported image-generated lower-deck reward cache prop `res://assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png`; its original image-generation source, alpha source, and metadata remain under `assets/generated/source/old_factory_lower_deck_skirmish_cache_*`. Reuse is recorded in the asset manifest, entity inventory, story, and QA evidence. The AGENTS 2D frame animation rule is not triggered because Story088 adds an environment reward prop, not a player-visible character.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exhaust_pursuer_reward_cache_test.gd` covers Story087-clear gating, hidden/non-claimable locked state, live Story087 Exhaust Pursuer defeat unlocking the cache, cache id/source, texture path, `+20 Gears` prompt, once-only claim payload and feedback, local-state persistence, restored claimed state, Story087/086/085/084 continuity, Story074 exit-relay savepoint contract, Story068 clear-feedback no-replay, Story071 reward-cache audio no-replay, and `FactoryServiceLift` prompt preservation.
- Verification: RED focused `reports/report_1195/` failed as expected before Story088 diagnostics/APIs existed. Focused GREEN `reports/report_1196/` passed Story088 `3/3`. Related GREEN `reports/report_1197/` passed Story088, Story087, Story086, Story085, Story084, Story083, Story074 exit relay, service-lift, no-loss respawn, Story068 no-replay, and Story071 reward-cache audio no-replay suites `26/26`. Headless Factory smoke `reports/old_factory_forward_pressure_aftershock_exhaust_pursuer_reward_cache_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load/shadowed-variable errors by keyword scan. Godot AI MCP `2.9.1` on Godot `4.7-stable` launched the factory scene with helper live, confirmed live Story087 activation `true`, damage to entity `2131` `true`, cache visible/available/claimable after the defeat, node `reward_gears=20`, runtime texture path, `+20 Gears` prompt, first claim `true`, duplicate claim `false`, `20` gear payload, route label `Forward Pressure Exhaust Pursuer Cache Claimed +20 Gears`, restored claimed-state contract, Story074 exit-relay savepoint contract, service lift `Call lift`, Story068/071 no-replay sentinels, game log containing only helper registration, empty editor log, and a non-empty `960x539` game screenshot with the cache visible.
- Blockers: None. New generated character art, new character animation, new enemy family, new AI behavior tree, new hazard, new reward economy, SaveSystem schema changes, service-lift route changes, minimap/fast-travel UI, authored audio, particles/shaders, Boss2, and broader lower-deck layout work remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory route content after the aftershock exhaust pursuer payoff, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-09

- Story: `production/epics/player-abilities/story-090-old-factory-lower-deck-forward-pressure-aftershock-exhaust-breaker-corridor.md` -- Old Factory Lower Deck Forward Pressure Aftershock Exhaust Breaker Corridor
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_corridor_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-090-old-factory-lower-deck-forward-pressure-aftershock-exhaust-breaker-corridor.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-aftershock-exhaust-breaker-corridor-2026-07-09.md`, `reports/report_1206/`, `reports/report_1208/`, `reports/report_1209/`, `reports/report_1210/`, `reports/old_factory_forward_pressure_aftershock_exhaust_breaker_corridor_smoke.log`, `production/session-state/active.md`
- Implementation: Extended `factory_route_transition_shell.tscn` route geometry from x `2400.0` to x `3200.0` so the Story086-090 right-side content is physically reachable. Added a Story089-gated breaker corridor: `FactoryLowerDeckForwardPressureAftershockExhaustBreakerCoilRat` uses reused Factory Coil Rat frame animation as entity `2133`, `FactoryLowerDeckForwardPressureAftershockExhaustBreakerVent` uses reused Old Factory steam vent art and hazard id `old_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker`, and `FactoryLowerDeckForwardPressureAftershockExhaustBreaker` reuses the generated forward-pressure breaker console. Crossing x `2928.0` activates the encounter; defeating entity `2133` secures the breaker and reveals the console; cutting it persists `factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut=true`, plays unlock feedback once, rejects duplicate cuts, and advances route feedback to `Aftershock Exhaust Pressure Cut`.
- Asset pipeline: No new visual or audio assets were generated. Story090 reuses imported image-generated Factory Coil Rat `AnimatedSprite2D + SpriteFrames`, the Old Factory steam vent hazard prop, and the forward-pressure breaker console. Reuse is recorded in the asset manifest, entity inventory, story, and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_corridor_test.gd` covers route extension, Story089-clear gating, activation range, entity `2133`, Coil Rat frame counts for `idle/run/attack_tell/attack/hurt/death`, hazard semantics, breaker texture/prompt, one-shot cut activation, local-state persistence, restored no-replay, Story089/Story088/Story087 continuity, Story074 savepoint contract, Story068/071 no-replay checks, and `FactoryServiceLift` prompt preservation.
- Verification: RED focused `reports/report_1206/` failed as expected before route geometry and Story090 APIs/nodes/state existed. Focused GREEN `reports/report_1208/` passed Story090 `2/2`. Related RED `reports/report_1209/` found a Story089 settled-diagnostics compatibility issue where a defeated Spark Rat still returned stale entity id `2132`; Story089 diagnostics now return `0` after cleared without changing runtime enemy lookup. Final related GREEN `reports/report_1210/` passed `35/35`. Headless Factory smoke `reports/old_factory_forward_pressure_aftershock_exhaust_breaker_corridor_smoke.log` exited `0` and its log scan had no project script/parse/invalid-call/access/missing-resource/resource-load errors. Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed plugin/server version, helper live, scene nodes, active entity `2133`, Coil Rat SpriteFrames path and 3-frame counts for all required animations, active hazard id/damage/cooldown/texture, `apply_damage(2133, 999)=true`, secured/cut local flags, duplicate cut `false`, route label `Aftershock Exhaust Pressure Cut`, runtime scene tree containing the new breaker and vent nodes, and a non-empty `960x539` game screenshot. The MCP tool schema in this session did not expose `logs_read`; log evidence came from `project_run.recent_errors=[]`, fresh log clear before launch, and the headless smoke log scan.
- Blockers: None. New generated character art, new enemy family, new AI behavior tree, new reward cache, new reward economy, new savepoint, SaveSystem schema changes, service-lift route changes, minimap/fast-travel UI, authored audio, particles/shaders, Boss2, and broader lower-deck biome art replacement remain out of scope.
- Next: continue another ACT-visible slice after the aftershock exhaust breaker corridor, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-09

- Story: `production/epics/player-abilities/story-091-old-factory-lower-deck-forward-pressure-aftershock-exhaust-escape-skirmish.md` -- Old Factory Lower Deck Forward Pressure Aftershock Exhaust Escape Skirmish
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_test.gd`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-091-old-factory-lower-deck-forward-pressure-aftershock-exhaust-escape-skirmish.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-forward-pressure-aftershock-exhaust-escape-skirmish-2026-07-09.md`, `reports/report_1212/`, `reports/report_1213/`, `reports/report_1215/`, `reports/report_1216/`, `reports/report_1217/`, `reports/old_factory_forward_pressure_aftershock_exhaust_escape_skirmish_smoke.log`, `production/session-state/active.md`
- Implementation: Added a Story090-gated aftershock exhaust escape skirmish beyond the pressure-cut breaker. `FactoryLowerDeckForwardPressureAftershockExhaustEscapeSkirmishSparkRat` and `FactoryLowerDeckForwardPressureAftershockExhaustEscapeSkirmishCoilRat` stay hidden/inactive until `factory_lower_deck_forward_pressure_aftershock_exhaust_breaker_cut=true`; crossing activation x `3112.0` activates entity `2134` as the Spark Rat side and entity `2135` as the Coil Rat side, assigns Cinderpaw as target for both, enables process/physics for both, starts staggered opening grace frames `10/22`, and shows route feedback `Break Aftershock Exhaust Escape`. Defeating both enemies disables them and persists activation/spark-defeated/coil-defeated/cleared flags; Story092 later extends this clear state into the aftershock exhaust exit hatch handoff.
- Asset pipeline: No new visual or audio assets were generated. Story091 reuses the image-generated Factory Spark Rat and Factory Coil Rat `AnimatedSprite2D + SpriteFrames` assets, including transparent 96x96 `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` frames. Reuse is recorded in the asset manifest, entity inventory, story, and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_exhaust_escape_skirmish_test.gd` covers Story090-breaker-cut gating, manual activation range, entity ids `2134/2135`, target/process/physics, enemy family ids, SpriteFrames paths and six animation frame counts for both enemies, staggered pacing `10/22`, route feedback, partial vs full defeat persistence, restored completed state, Story090/089/074 continuity, Story068/071 no-replay, `FactoryServiceLift` prompt preservation, and a regression for restoring local state after defeated enemies have been freed.
- Verification: Initial focused RED `reports/report_1212/` failed as expected before Story091 diagnostics/APIs/local state and scene nodes existed. First focused GREEN `reports/report_1213/` passed Story091 `2/2`. MCP runtime probing exposed a stale freed-reference issue after both enemies died and local state was restored; regression RED `reports/report_1215/` recorded `errors=4`. Final focused GREEN `reports/report_1216/` passed Story091 `2/2` after diagnostics and enemy lookup helpers were hardened with valid-node checks. Final related GREEN `reports/report_1217/` passed Story091 plus adjacent aftershock exhaust chain, Story074/service-lift, no-loss respawn, Story068 no-replay, Story071 audio no-replay, and steam hazard suites `39/39`. Headless Factory smoke `reports/old_factory_forward_pressure_aftershock_exhaust_escape_skirmish_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load/shadowed-variable errors by keyword scan. Godot AI MCP `2.9.1` on Godot `4.7-stable` launched the factory scene with helper live, confirmed active skirmish diagnostics, entities `2134/2135`, visible `AnimatedSprite2D` enemies, SpriteFrames paths and 3-frame counts for `idle/run/attack_tell/attack/hurt/death`, opening grace frames `10/22`, route label `Break Aftershock Exhaust Escape`, full defeat and restored completed-state contracts, Story090/089/074 preservation, service lift `Call lift`, game log containing only helper registration, empty editor log, and a non-empty `960x539` MCP game screenshot showing the active escape skirmish.
- Blockers: None. New generated character art, new enemy family, new AI behavior tree, new hazard, new reward cache, new reward economy, new savepoint, SaveSystem schema changes, service-lift route changes, minimap/fast-travel UI, authored audio, particles/shaders, Boss2, and broader lower-deck biome art replacement remain out of scope.
- Next: continue another ACT-visible slice after the aftershock exhaust escape skirmish, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-09

- Story: `production/epics/player-abilities/story-101-main-scene-player-hit-damage-number-runtime.md` -- Main Scene Player Hit Damage Number Runtime
- Files changed: `src/presentation/combat_presentation.gd`, `tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-101-main-scene-player-hit-damage-number-runtime.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/main-scene-player-hit-damage-number-runtime-2026-07-09.md`, `reports/report_1257/`, `reports/report_1258/`, `reports/report_1261/`, `reports/report_1262/`, `reports/main_scene_damage_number_runtime_smoke.log`, `reports/visual/cinderpaw-mcp-main-scene-damage-number-runtime-20260709.png`, `production/session-state/active.md`
- Implementation: Closed the MainScene player-hit damage-number integration gap. The existing player attack chain now has focused runtime coverage proving `Player.attack_landed -> MainScene._on_player_attack_landed -> CombatPresentation.on_hit_event` spawns exactly one active damage number, that its text equals the hit `final_damage`, that duplicate hitbox detection does not duplicate damage or labels, and that the active label cleans up after its lifetime. `CombatPresentation` now exposes `get_last_damage_number_snapshot()` for tests/MCP, including text, visibility, z index, position, font/outline, 1px black shadow, 30px float distance, 1.5s lifetime, and active count. The damage-number label also receives a subtle black shadow for readability over dense boss sprites.
- Asset pipeline: No new visual assets were generated. Story101 uses text `Label` damage numbers from the existing Combat Presentation Story008 renderer, not bitmap character/environment art. `design/assets/entity-inventory.md` now marks Damage Numbers as an implemented baseline tied to Story008 and Story101.
- Test written: `tests/unit/gameplay/main_scene_player_attack_core_chain_test.gd` now asserts pre-hit active count, post-hit active count, final-damage text, visible snapshot, shadow metadata, float distance, lifetime, duplicate-detection no-replay, and cleanup after `advance_time(1.6)`.
- Verification: RED focused `reports/report_1257/` failed as expected before `get_last_damage_number_snapshot()` existed. Initial GREEN focused `reports/report_1258/` passed `4/4`; final focused `reports/report_1262/` passed `4/4` after the shadow readability enhancement and final formatting. Related GREEN `reports/report_1261/` passed player attack, enemy attack, and CombatPresentation suites `38/38`. Headless MainScene smoke `reports/main_scene_damage_number_runtime_smoke.log` exited `0`; keyword scan found no project script/parse/invalid-call/access/missing-resource/resource-load errors. Godot AI MCP `2.9.1` on Godot `4.7-stable` opened and ran `res://scenes/main.tscn` with helper live and `current_run_errors=[]`; runtime `game_eval` confirmed Player/Enemy/HUD/CombatPresentation, a player light attack hit reduced Enemy HP `300 -> 290`, `final_damage=10`, active damage numbers `0 -> 1`, snapshot text `10`, visible `true`, z index `90`, black shadow alpha `0.82`, shadow offset `(1, 1)`, float distance `30.0`, lifetime `1.5`, and screenshot save success to `reports/visual/cinderpaw-mcp-main-scene-damage-number-runtime-20260709.png` (`1278x718`). Current game log contained only helper/DataManager info lines.
- Notes: MCP editor log still displayed retained old Factory parse rows naming helper symbols that are absent from the current `src/gameplay/old_factory_entrance_scene.gd`; local `rg` confirmed the stale symbols are not present, headless parsing/tests passed, and the Story101 current run had no current-run errors. This is recorded in QA evidence as retained editor-cache noise, not a Story101 runtime error.
- Blockers: None for Story101. New damage formulas, enemy AI/HP tuning, crit/parry special number effects, HUD settings expansion, authored SFX, particle/shader work, and bitmap asset generation remain out of scope.
- Next: continue another ACT-visible slice such as deeper Old Factory route content after the condenser overflow pump, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-09

- Story: `production/epics/player-abilities/story-102-old-factory-route-floor-platform-visual-pass.md` -- Old Factory Route Floor Platform Visual Pass
- Files changed: `scenes/factory_route_transition_shell.tscn`, `src/gameplay/old_factory_entrance_scene.gd`, `tests/unit/gameplay/old_factory_route_floor_platform_visual_pass_test.gd`, `tests/unit/gameplay/old_factory_entrance_combat_slice_runtime_test.gd`, `assets/environment/old_factory_route_floor/env_old_factory_route_floor_tile_256x96.png`, `assets/environment/old_factory_route_platform/env_old_factory_route_entry_platform_320x96.png`, `assets/environment/old_factory_route_platform/env_old_factory_route_cache_platform_320x96.png`, `assets/generated/source/old_factory_route_floor_platform_sheet_imagegen_20260709.png`, `assets/generated/source/old_factory_route_floor_platform_sheet_alpha_20260709.png`, `assets/generated/source/old_factory_route_floor_platform_sheet_imagegen_20260709.json`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-102-old-factory-route-floor-platform-visual-pass.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-route-floor-platform-visual-pass-2026-07-09.md`, `reports/report_1264/`, `reports/report_1265/`, `reports/report_1267/`, `reports/old_factory_route_floor_platform_visual_pass_smoke.log`, `reports/visual/cinderpaw-mcp-old-factory-route-floor-platform-visual-pass-20260709.png`, `production/session-state/active.md`
- Implementation: Added image-generated route floor/platform visuals to `factory_route_transition_shell.tscn`. `Ground` now has 28 repeated `Sprite2D` floor tiles covering `7168px` across the `7040px` collision span. `EntryPlatform` and `FactoryCachePlatform` now have distinct transparent generated metal platform sprites. Existing collisions, player spawn, room-clear cache, service lift, route state, and save contracts were preserved.
- Asset pipeline: Generated a magenta-keyed Old Factory route floor/platform source sheet through image generation, alpha-matted it locally, cropped it into one 256x96 repeatable floor tile plus two 320x96 platform sprites, imported the runtime/source PNGs through Godot 4.7, and recorded source/alpha/runtime paths in the asset manifest, metadata JSON, story, and QA evidence.
- Test written: `tests/unit/gameplay/old_factory_route_floor_platform_visual_pass_test.gd` covers the floor/platform generated texture paths, Godot resource import/size contracts, floor tile count/width, entry/cache platform dimensions, 7040px collision width, and absence of visible placeholder `ColorRect`/`Polygon2D` art.
- Verification: RED focused `reports/report_1264/` failed as expected before Story102 diagnostics existed. Focused GREEN `reports/report_1265/` passed Story102 `1/1`. Related GREEN `reports/report_1267/` passed Story102 plus factory route, entrance combat, room-clear cache, and route roundtrip coverage `12/12`. Headless Factory smoke `reports/old_factory_route_floor_platform_visual_pass_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan. Godot AI MCP `2.9.1` on Godot `4.7-stable` launched the factory scene with helper live and `current_run_errors=[]`, confirmed the generated floor and platform nodes/textures/sizes, `Ground` collision `7040x40`, floor coverage `7168x96`, `uses_placeholder_color_rect=false`, current game log containing only helper registration, and a non-empty `1278x718` screenshot showing Cinderpaw on the generated metal route floor with generated platform visuals visible.
- Notes: MCP editor hierarchy briefly showed a stale in-memory scene tree, so no MCP `scene_save` was used. Disk reads, headless tests, headless smoke, and MCP runtime `game_eval` confirmed the actual submitted scene. Retained editor-cache parse rows for old helper names were again treated as stale because local `rg`, headless parsing/tests, and current-run MCP checks passed.
- Blockers: None for Story102. New route gameplay, new enemy behavior, new character animation, save schema changes, minimap/fast-travel UI, authored audio, particles/shaders, full tileset replacement, and Boss2 polish remain out of scope.
- Next: continue another ACT-visible slice such as additional Old Factory route art replacement, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-09

- Story: `production/epics/player-abilities/story-103-main-scene-boundary-wall-visual-pass.md` -- Main Scene Boundary Wall Visual Pass
- Files changed: `scenes/main.tscn`, `tests/unit/gameplay/main_scene_boundary_wall_visual_pass_test.gd`, `assets/environment/main_scene_boundary_wall/main_scene_boundary_wall_96x720.png`, `assets/generated/source/main_scene_boundary_wall_imagegen_20260709.png`, `assets/generated/source/main_scene_boundary_wall_alpha_20260709.png`, `assets/generated/source/main_scene_boundary_wall_imagegen_20260709.json`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `production/epics/player-abilities/story-103-main-scene-boundary-wall-visual-pass.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/main-scene-boundary-wall-visual-pass-2026-07-09.md`, `reports/report_1268/`, `reports/report_1269/`, `reports/report_1270/`, `reports/main_scene_boundary_wall_visual_pass_smoke.log`, `reports/visual/cinderpaw-mcp-main-scene-boundary-wall-visual-pass-20260709.png`, `production/session-state/active.md`
- Implementation: Replaced the main scene's old left/right wall `ColorRect` presentation nodes with visible generated `Sprite2D` boundary wall art. `LeftWall/BoundaryWallVisual` and `RightWall/BoundaryWallVisual` both use the same 96x720 transparent texture, with the right wall mirrored via `flip_h=true`. Existing `RectangleShape2D_wall` collisions, ground/platform visuals, player spawn, Dash/Double Jump gates, Boss2, HUD, and save/runtime behavior were preserved.
- Asset pipeline: Generated a green-keyed vertical wasteland wall strip through image generation, alpha-matted it locally, cropped/resized it into `assets/environment/main_scene_boundary_wall/main_scene_boundary_wall_96x720.png`, imported runtime/source PNGs through Godot 4.7, and recorded source/alpha/runtime paths in the asset manifest, metadata JSON, story, and QA evidence.
- Test written: `tests/unit/gameplay/main_scene_boundary_wall_visual_pass_test.gd` covers left/right `Sprite2D` presence, visibility, generated texture path, 96x720 texture size, right-side flip, z-order, world coverage, and absence of old `WallVisual` ColorRects under both wall bodies.
- Verification: RED focused `reports/report_1268/` failed as expected before BoundaryWall sprites existed. Focused GREEN `reports/report_1269/` passed Story103 `1/1`. Related GREEN `reports/report_1270/` passed Story103, main-scene visual contract, authored Dash gate, and Dash gate runtime suites `9/9`. Headless MainScene smoke `reports/main_scene_boundary_wall_visual_pass_smoke.log` exited `0` with no project script/parse/invalid-call/access/missing-resource/resource-load errors by keyword scan. Godot AI MCP `2.9.1` on Godot `4.7-stable` launched `res://scenes/main.tscn` with helper live and `current_run_errors=[]`, confirmed both wall sprites, texture path/size, flip/z-order contracts, no old ColorRect wall nodes, current game log containing only helper/DataManager info, and a non-empty `1278x718` screenshot showing the authored left boundary wall.
- Notes: One initial MCP eval probe used unsupported eval syntax and was cleared by stopping/relaunching the project before final evidence. MCP editor log still retained old Factory parse rows from earlier cache state; final Story103 acceptance uses clean current-run status, game log, focused/related tests, headless smoke, and runtime MCP node/screenshot checks.
- Blockers: None for Story103. Full MainScene tileset replacement, right-edge camera framing, Boss2 scale/framing, prompt label layout, HUD redesign, new gameplay routes, authored audio, and save schema changes remain out of scope.
- Next: continue another ACT-visible slice such as broader MainScene art/prompt cleanup, minimap/savepoint gameplay, authored/final hazard audio, additional player-visible frame-animation replacement, or Boss2 polish.

## Session Extract -- /dev-story 2026-07-10

- Story: `production/epics/player-abilities/story-114-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-skirmish.md` -- Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Skirmish
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_test.gd`, `production/epics/player-abilities/story-114-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-skirmish.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-overflow-pump-runoff-outlet-service-sluice-skirmish-2026-07-10.md`, `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_skirmish_smoke.log`, `production/session-state/active.md`
- Implementation: Added a Story113-gated service sluice Spark Rat skirmish after the runoff outlet service sluice traverse. `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceSparkRat` stays hidden/inactive until the service sluice has been crossed; crossing activation x `10920.0` activates entity `2142`, assigns Cinderpaw as target, enables process/physics, starts opening grace `12`, and shows route feedback `Clear Service Sluice Spark Rat`. Defeating the enemy disables it, persists activated/defeated/cleared local state, marks the route objective complete, and advances feedback to `Service Sluice Spark Rat Cleared`.
- Asset pipeline: No new visual or audio assets were generated. Story114 reuses the image-generated Factory Spark Rat `AnimatedSprite2D + SpriteFrames` asset with transparent frames under `assets/characters/factory_spark_rat/<animation>/` and SpriteFrames resource `assets/characters/factory_spark_rat/factory_spark_rat_sprite_frames.tres`.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_skirmish_test.gd` covers service-sluice-crossed gating, manual activation range, entity `2142`, target/process/physics, Spark Rat family id, SpriteFrames path and six animation frame counts, opening grace `12`, route feedback, ground coverage through x `11520`, defeat persistence, restored completed state, and Story106-113 runoff-chain backfill.
- Verification: RED focused `reports/report_1330/` failed as expected before Story114 diagnostics/API/scene node existed. Focused GREEN `reports/report_1334/` passed Story114 `2/2`; related GREEN `reports/report_1335/` passed Story114 plus adjacent runoff outlet/service sluice suites `12/12`. Headless Factory smoke `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_skirmish_smoke.log` exited `0` with only known Godot cleanup-time ObjectDB/resource messages after shutdown. Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed the disk-reloaded Spark Rat node, right wall x `11500`, camera/background `11520`, ground right edge x `11700`, activation/defeat/restore contracts, entity `2142`, SpriteFrames path and 3-frame counts for `idle/run/attack_tell/attack/hurt/death`, current game log without errors, empty editor log after cursor `9`, and a non-empty `960x539` game screenshot showing Cinderpaw and the active Spark Rat.
- Notes: MCP runtime probing found the previous ground collision ended before the new far-right combat pocket, so the route collision was extended and the focused test now asserts `ground_right_edge_x >= 11520.0`.
- Blockers: None. New generated enemy art, new enemy family, reward economy changes, savepoint, SaveSystem schema changes, service-lift route changes, minimap/fast-travel UI, authored audio, particles/shaders, Boss2, and broader lower-deck biome art replacement remain out of scope.
- Next: continue another ACT-visible slice beyond the service sluice skirmish, preferably a short route handoff or combat/reward beat that keeps replacing placeholder-feeling gameplay with frame-animated enemies and visible authored environment support.

## Session Extract -- /dev-story 2026-07-10

- Story: `production/epics/player-abilities/story-115-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-reward-cache.md` -- Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Reward Cache
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_test.gd`, `production/epics/player-abilities/story-115-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-reward-cache.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-overflow-pump-runoff-outlet-service-sluice-reward-cache-2026-07-10.md`, `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_reward_cache_smoke.log`, `production/session-state/active.md`
- Implementation: Added a Story114-gated service sluice reward cache. `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceRewardCache` stays hidden/inactive until the service sluice Spark Rat is cleared; once available it shows `+20 Gears`, uses cache id/source `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache`, grants `20` gears on the first claim, rejects duplicate claims, persists the claimed flag, and advances route feedback to `Service Sluice Cache Claimed +20 Gears`.
- Asset pipeline: No new visual or audio assets were generated. Story115 reuses the existing image-generated lower-deck reward cache texture, the generated service sluice landing context, and the generated route floor visuals.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_test.gd` covers Story114 clear gating, hidden/unavailable locked state, cache id/source, texture path, prompt, reward payload, once-only claim, route label update, local-state persistence, restored completed state, and Story106-114 runoff-chain backfill.
- Verification: RED focused `reports/report_1336/` failed as expected before Story115 diagnostics/API existed. Focused GREEN `reports/report_1337/` passed Story115 `2/2`; related GREEN `reports/report_1338/` passed Story115, Story114, Story113, and Story112 suites `8/8`. Headless Factory smoke `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_reward_cache_smoke.log` exited `0` with only known Godot cleanup-time ObjectDB/resource messages after shutdown. Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed the disk-reloaded cache node, script, texture, cache id/source, reward `20`, locked/available/claimed diagnostics, duplicate claim rejection, route label update, local-state persistence, current game log without errors, empty editor log after cursor `9`, and a non-empty `960x539` screenshot showing Cinderpaw and the service sluice reward cache.
- Notes: `project_run` still surfaced retained historical editor parse rows marked as pre-run; current-run game log, cursor-scoped editor log, focused/related tests, and headless smoke were clean.
- Blockers: None. New route gate, new savepoint, new enemy family, new generated art, reward economy expansion, SaveSystem schema changes, minimap/fast-travel UI, authored audio, particles/shaders, Boss2, and broader lower-deck biome art replacement remain out of scope.
- Next: continue another ACT-visible slice beyond the service sluice payoff, preferably a short route handoff, traversal pocket, or combat beat that keeps the Old Factory moving right without over-testing.

## Session Extract -- /dev-story 2026-07-10

- Story: `production/epics/player-abilities/story-116-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-exit-hatch-handoff.md` -- Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Exit Hatch Handoff
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_test.gd`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_reward_cache_test.gd`, `tests/smoke/old_factory_service_sluice_exit_hatch_smoke.gd`, `production/epics/player-abilities/story-116-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-exit-hatch-handoff.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-overflow-pump-runoff-outlet-service-sluice-exit-hatch-2026-07-10.md`, `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_exit_hatch_smoke.log`, `production/session-state/active.md`
- Implementation: Added a Story115-gated service sluice exit hatch. `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceExitHatch` stays hidden/inactive until the service sluice reward cache is claimed; once available it uses endpoint id `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch`, shows `Open Service Exit`, blocks collision before opening, opens once in range, plays one unlock spark, clears collision, persists the opened flag, and advances route feedback to `Service Sluice Exit Opened`. The scene now extends right wall x `11900`, camera/background right `11920`, ground collision to x `12000`, and adds two reused floor tiles under the new hatch pocket.
- Asset pipeline: No new visual or audio assets were generated. Story116 reuses the image-generated old-factory deep bulkhead hatch texture, the generated deep-route unlock spark VFX, the generated service sluice landing context, and generated route floor tile.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_exit_hatch_test.gd` covers cache-claim gating, node/script/texture/VFX contracts, prompt state, route bounds, collision blocking before open, one-shot open, VFX spawn count, local-state persistence, restored completed state, and Story106-115 runoff-chain backfill. Story115 restore expectations were updated so restored cache claim now points to `Open Service Sluice Exit`, while immediate claim feedback still remains `Service Sluice Cache Claimed +20 Gears`.
- Verification: RED focused `reports/report_1339/` failed as expected before Story116 diagnostics/API existed. Focused GREEN `reports/report_1340/report_2/` passed Story116 `2/2`; final related GREEN `reports/report_1342/report_1/` passed Story116, Story115, Story114, Story113, and Story112 suites `10/10`. Headless Factory smoke `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_exit_hatch_smoke.log` exited `0` and printed `service_sluice_exit_hatch_smoke=passed`, with only known Godot cleanup-time ObjectDB/resource messages after shutdown. Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed the disk-reloaded hatch node, script, endpoint id, prompts, texture/VFX assets, runtime available/opened diagnostics, collision blocking before open and cleared after open, VFX spawn count `1`, local-state persistence, current game log without errors, empty editor log after cursor `9`, and a non-empty `960x539` screenshot response.
- Notes: `project_run` continued to surface retained historical editor parse rows marked as pre-run; compatibility wrappers were added for the old condenser-outlet helper names, and final current-run game log plus cursor-scoped editor log were clean.
- Blockers: None. New route traversal hazards, new enemy family, new generated art, new reward economy, savepoint, SaveSystem schema changes, minimap/fast-travel UI, authored audio, particles/shaders, Boss2, and broader lower-deck biome art replacement remain out of scope.
- Next: continue another ACT-visible slice beyond the service sluice exit hatch, preferably a short traversal or combat beat that introduces more authored environment support without bloating verification.

## Session Extract -- /dev-story 2026-07-10

- Story: `production/epics/player-abilities/story-117-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-traverse.md` -- Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Traverse
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_traverse_test.gd`, `tests/smoke/old_factory_service_sluice_tailrace_smoke.gd`, `production/epics/player-abilities/story-117-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-traverse.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-overflow-pump-runoff-outlet-service-sluice-tailrace-2026-07-10.md`, `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_smoke.log`, `production/session-state/active.md`
- Implementation: Added a Story116-gated service sluice tailrace traversal. `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceDuct` and `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceVent` stay hidden/non-contacting until the service sluice exit hatch is opened; crossing activation x `12020.0` activates the timed steam window, shows route feedback `Cross Service Sluice Tailrace`, and cycles deterministic `grace -> warning -> active -> safe` phases. Only the active phase enables contact/collision damage. Crossing exit x `12480.0` persists activated/crossed flags, disables contact, marks the objective complete, and advances feedback to `Service Sluice Tailrace Crossed`. The scene now extends right wall x `12700`, camera/background right `12720`, ground support through x `12800`, and route floor visuals to 53 tiles.
- Asset pipeline: No new visual or audio assets were generated. Story117 reuses the image-generated/imported service sluice landing texture, old factory steam vent hazard texture, and generated route floor tile. The AGENTS frame-animation rule is not triggered because Story117 adds an environment traversal hazard, not a new visible character.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_traverse_test.gd` covers Story116 hatch gating, node/texture/hazard contracts, activation/completion x thresholds, active-only contact window, route bounds, local-state persistence, restored completed state, and Story106-116 runoff/service-sluice backfill.
- Verification: RED focused `reports/report_1344/` failed as expected before Story117 diagnostics/API existed. Focused GREEN `reports/report_1345/` passed Story117 `2/2`; related GREEN `reports/report_1346/` passed Story117, Story116, Story115, Story114, Story113, and Story112 suites `12/12`. Headless Factory smoke `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_smoke.log` exited `0` and printed `service_sluice_tailrace_smoke=passed`, with only known Godot cleanup-time ObjectDB/resource messages after shutdown. Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed the disk-reloaded tailrace nodes, hazard id, active-only contact, route bounds, locked/ready/active/crossed diagnostics, local-state persistence, current game log without errors, empty editor log after cursor `9`, and a non-empty `960x539` screenshot response.
- Notes: One MCP eval probe using untyped Variant inference tripped a debugger warning-as-error; the game was stopped/relaunched, then typed eval, current-run game log, cursor-scoped editor log, and screenshot checks passed. `project_run` still surfaced retained historical editor parse rows marked as pre-run; no new current-run Story117 editor errors were present.
- Blockers: None. New enemies, new enemy family, reward cache, savepoint, SaveSystem schema changes, service-lift route changes, minimap/fast-travel UI, authored audio, particles/shaders, new generated art, Boss2, and broader lower-deck biome art replacement remain out of scope.
- Next: continue another ACT-visible slice beyond the service sluice tailrace, preferably a short combat beat or route handoff that uses frame-animated enemies or authored environment support without widening verification to a full suite.

## Session Extract -- /dev-story 2026-07-10

- Story: `production/epics/player-abilities/story-118-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-ambush.md` -- Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Ambush
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_test.gd`, `tests/smoke/old_factory_service_sluice_tailrace_ambush_smoke.gd`, `production/epics/player-abilities/story-118-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-ambush.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-overflow-pump-runoff-outlet-service-sluice-tailrace-ambush-2026-07-10.md`, `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_smoke.log`, `production/session-state/active.md`
- Implementation: Added a Story117-gated service-sluice tailrace Coil Rat ambush. `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceCoilRat` stays hidden/inactive until the tailrace is crossed; reaching x `12620.0` activates entity `2143`, assigns Cinderpaw as target, enables process/physics/collision, starts opening grace `10`, and shows route feedback `Clear Tailrace Coil Rat`. Defeating the Coil Rat disables it, persists activated/defeated/cleared state, marks the route objective complete, and advances feedback to `Tailrace Coil Rat Cleared`. The scene now extends right wall x `13200`, camera/background right `13220`, ground support through x `13300`, and route floor visuals to 55 tiles.
- Asset pipeline: No new visual or audio assets were generated. Story118 reuses the existing image-generated/imported Factory Coil Rat `AnimatedSprite2D + SpriteFrames` asset with transparent frames under `assets/characters/factory_coil_rat/<animation>/` and SpriteFrames resource `assets/characters/factory_coil_rat/factory_coil_rat_sprite_frames.tres`.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_test.gd` covers tailrace-crossed gating, activation x, entity `2143`, target/process/physics, Coil Rat family id, SpriteFrames path and six animation frame counts, opening grace `10`, route feedback, bounds, defeat persistence, restored completed state, and Story106-117 runoff/service-sluice backfill.
- Verification: RED focused `reports/report_1347/` failed as expected before Story118 diagnostics/API existed. Focused GREEN `reports/report_1348/` passed Story118 `2/2`; related GREEN `reports/report_1349/` passed Story118 plus adjacent service-sluice suites `12/12`. Headless Factory smoke `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_smoke.log` exited `0` and printed `service_sluice_tailrace_ambush_smoke=passed`, with only known Godot cleanup-time ObjectDB/resource messages after shutdown. Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed the disk-reloaded Coil Rat node, `AnimatedSprite2D` SpriteFrames path, activation/defeat/restore contracts, entity `2143`, 3-frame counts for `idle/run/attack_tell/attack/hurt/death`, right wall/camera/ground/floor bounds, current game log without errors, empty editor log after cursor `9`, and a non-empty `960x539` screenshot showing Cinderpaw and the active Coil Rat.
- Notes: `project_run` returned retained historical editor parse rows marked as pre-run; current-run game log, cursor-scoped editor log, focused/related tests, headless smoke, and typed MCP runtime eval were clean.
- Blockers: None. New generated art, new enemy family, reward cache, savepoint, SaveSystem schema changes, minimap/fast-travel UI, authored audio, particles/shaders, Boss2, and broader lower-deck biome art replacement remain out of scope.
- Next: continue another ACT-visible slice beyond the tailrace ambush, preferably a short route handoff, payoff, savepoint/minimap beat, or another combat/environment beat with frame-animated enemies and tight verification.

## Session Extract -- /dev-story 2026-07-10

- Story: `production/epics/player-abilities/story-119-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-relay.md` -- Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Relay
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_test.gd`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_ambush_test.gd`, `tests/smoke/old_factory_service_sluice_tailrace_relay_smoke.gd`, `tests/smoke/critical-paths.md`, `production/epics/player-abilities/story-119-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-relay.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-overflow-pump-runoff-outlet-service-sluice-tailrace-relay-2026-07-10.md`, `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_smoke.log`, `production/session-state/active.md`
- Implementation: Added a Story118-gated Tailrace Relay savepoint after the service-sluice tailrace ambush. `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelaySavepoint` stays hidden and non-interactive until the Coil Rat ambush is cleared, then shows `Repair Tailrace Relay`, activates once in range, writes last-discovered savepoint id/scene/spawn, spawns one unlock VFX, persists `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_activated=true`, and advances route feedback to `Tailrace Relay Secured`. The SceneManager spawn map now supports direct entry at the Story119 relay spawn and updates respawn feedback to `Returned to Tailrace Relay`. The route was extended to right wall x `13720`, camera/background right `13740`, ground right edge x `13840`, and 58 floor visuals.
- Asset pipeline: No new visual or audio assets were generated. Story119 reuses the image-generated/imported lower-deck relay texture, generated deep-route unlock spark VFX, and generated route floor tile.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_test.gd` covers Story118-clear gating, relay node/script/texture/VFX contracts, once-only activation, VFX count, savepoint payload, local-state persistence, restored no-replay backfill through Story106-118, direct SceneManager spawn landing at the relay, death/respawn routing, and route bounds. Story118 ambush expectations now assert the new post-clear route handoff to `Repair Tailrace Relay`.
- Verification: Focused RED `reports/report_1350/` failed as expected before Story119 diagnostics/API/scene/state existed. Spawn regression RED `reports/report_1359/` exposed the missing Story119 SceneManager spawn mapping. Focused GREEN `reports/report_1360/` passed Story119 `2/2`; related GREEN `reports/report_1361/` passed service-sluice/tailrace + savepoint/respawn sentinel suites `21/21`. Headless Factory smoke `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_smoke.log` exited `0` and printed `service_sluice_tailrace_relay_smoke=passed`, with only known Godot cleanup-time ObjectDB/resource messages after shutdown. Godot AI MCP `2.9.1` on Godot `4.7-stable` confirmed the disk-reloaded relay node/properties, savepoint group, runtime activation diagnostics, VFX count `1`, last-savepoint payload, 58 route floor visuals, helper-live current scene run with `current_run_errors=[]`, typed runtime eval success, and a non-empty `960x539` screenshot showing the Tailrace Relay.
- Notes: `project_run` continued to return retained historical editor parse rows marked as pre-run; current-run errors were empty, the helper was live, typed eval and screenshot passed, `--check-only --script res://src/gameplay/old_factory_entrance_scene.gd` passed, and local `rg` confirmed the named helper functions exist. One untyped MCP eval probe caused a temporary eval-only debugger break due Variant type inference; the game was stopped/relaunched before final typed eval and screenshot checks.
- Blockers: None. New generated art, new enemies, new character frame animations, new hazards, reward economy changes, SaveSystem schema changes, minimap/fast-travel UI, authored audio, particles/shaders, Boss2, and broader lower-deck biome art replacement remain out of scope.
- Next: continue deeper Old Factory route content after the tailrace relay, preferably a compact ACT-visible beat with either frame-animated combat or authored traversal support and focused verification.

## Session Extract -- /dev-story 2026-07-10

- Story: `production/epics/player-abilities/story-120-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-relay-runoff.md` -- Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Relay Runoff
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_test.gd`, `tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_smoke.gd`, `production/epics/player-abilities/story-120-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-relay-runoff.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-service-sluice-tailrace-relay-runoff-2026-07-10.md`, `production/session-state/active.md`
- Implementation: Added a Story119-gated Tailrace Relay runoff traversal. `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffDuct` and `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffVent` stay hidden/non-contacting until the Tailrace Relay is activated. Crossing x `13760.0` activates the deterministic steam window and route feedback `Cross Tailrace Relay Runoff`; only the `active` phase enables contact/collision damage. Crossing x `14320.0` persists activated/crossed flags, disables contact, keeps the Story119 Tailrace Relay savepoint payload intact, and advances feedback to `Tailrace Relay Runoff Crossed`. The route now extends to right wall x `14500`, camera/background right `14520`, ground support through x `14600`, and 61 floor visuals.
- Asset pipeline: No new visual or audio assets were generated. Story120 reuses the existing image-generated/imported service-sluice landing texture, old factory steam vent hazard texture, and generated route floor tile. The AGENTS frame-animation rule is not triggered because Story120 adds an environment traversal hazard, not a new visible character.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_test.gd` covers Story119 relay gating, node/texture/hazard contracts, activation/completion thresholds, active-only contact window, route bounds, local-state persistence, restored completed state, and Story106-119 backfill without replaying relay VFX.
- Verification: Focused RED `reports/report_1362/` failed as expected before Story120 diagnostics/API/scene/state existed. Focused GREEN `reports/report_1364/` passed Story120 `2/2`; related GREEN `reports/report_1365/` passed Story120 plus adjacent service-sluice/tailrace suites `10/10`. Headless Factory smoke `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_smoke.log` exited `0` and printed `service_sluice_tailrace_relay_runoff_smoke=passed`, with only known Godot cleanup-time ObjectDB/resource messages after shutdown. Godot AI MCP `2.9.1` on Godot `4.7-stable` opened and ran the factory scene with helper live and `current_run_errors=[]`, confirmed Story120 duct/vent edited-scene nodes, runtime vent node under `factory_hazard`, script/hazard id/damage/cooldown/locked collision state, clean current-run game/editor logs, and a non-empty `640x359` game screenshot response.
- Notes: The level-design sidecar recommended this short traversal beat to avoid stacking another enemy encounter immediately after Story118's Tailrace Coil Rat and Story119's relay. The QA sidecar's Spark Rat + Coil Rat recommendation is a good next post-runoff combat slice.
- Blockers: None. New enemies, new generated art, reward cache, savepoint, SaveSystem schema changes, minimap/fast-travel UI, authored audio, particles/shaders, Boss2, and broader lower-deck biome art replacement remain out of scope.
- Next: commit and push Story120, then continue with the next post-runoff ACT-visible slice.

## Session Extract -- /dev-story 2026-07-10

- Story: `production/epics/player-abilities/story-121-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-relay-runoff-pincer.md` -- Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Relay Runoff Pincer
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_test.gd`, `tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_smoke.gd`, `tests/smoke/critical-paths.md`, `production/epics/player-abilities/story-121-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-relay-runoff-pincer.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-service-sluice-tailrace-relay-runoff-pincer-2026-07-10.md`, `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_smoke.log`, `production/session-state/active.md`
- Implementation: Added a Story120-gated post-runoff Spark Rat + Coil Rat pincer. Crossing x `14640.0` after Tailrace Relay Runoff activates entity `2144` at `Vector2(14760, 482)` and entity `2145` at `Vector2(15280, 482)`, assigns Cinderpaw as target for both, enables process/physics, starts staggered opening grace frames `10/24`, and shows route feedback `Break Tailrace Runoff Pincer`. Defeating both enemies disables them, persists activated/spark-defeated/coil-defeated/cleared state, keeps the Story119 Tailrace Relay savepoint payload intact, and advances feedback to `Tailrace Runoff Pincer Cleared`. The route now extends to right wall x `15580`, camera/background right `15600`, ground support through x `15700`, and 63 floor visuals.
- Asset pipeline: No new visual or audio assets were generated. Story121 reuses the existing image-generated/imported Factory Spark Rat and Factory Coil Rat `AnimatedSprite2D + SpriteFrames` assets, including transparent frames under `assets/characters/factory_spark_rat/<animation>/` and `assets/characters/factory_coil_rat/<animation>/`.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_test.gd` covers Story120-crossed gating, activation x, entity ids `2144/2145`, target/process/physics, enemy family ids, SpriteFrames paths and six animation frame counts for both enemies, staggered pacing `10/24`, route feedback, bounds, partial vs full defeat persistence, restored completed state, Story106-120 chain backfill, and Tailrace Relay savepoint preservation.
- Verification: Focused RED `reports/report_1366/` failed as expected before Story121 diagnostics/API/scene/state existed. Intermediate RED `reports/report_1367/` exposed the missing pincer entity lookup for `apply_damage(2144/2145)`. Focused GREEN `reports/report_1368/` passed Story121 `2/2`; related GREEN `reports/report_1369/` passed Story121 plus adjacent service-sluice/tailrace suites `8/8`. Headless Factory smoke `reports/old_factory_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_smoke.log` exited `0` and printed `service_sluice_tailrace_relay_runoff_pincer_smoke=passed`, with only known Godot cleanup-time ObjectDB/resource messages after shutdown. Godot AI MCP `2.9.1` on Godot `4.7-stable` reloaded and ran the factory scene with helper live, found both edited-scene pincer enemies and their `AnimatedSprite2D` children, confirmed SpriteFrames paths and 3-frame counts for `idle/run/attack_tell/attack/hurt/death`, activated the encounter via typed runtime eval, confirmed visible/targeted enemies, opening grace `10/24`, route label `Break Tailrace Runoff Pincer`, clean current-run game/editor logs, and a non-empty `640x359` screenshot showing the active pincer.
- Notes: One untyped MCP eval probe caused a temporary eval-only debugger break due Variant type inference; the project was stopped/relaunched, then typed eval, current-run logs, and screenshot checks passed cleanly.
- Blockers: None. New generated art, new enemy family, reward cache, savepoint, SaveSystem schema changes, minimap/fast-travel UI, authored audio, particles/shaders, Boss2, and broader lower-deck biome art replacement remain out of scope.
- Next: continue deeper Old Factory route content after the tailrace relay runoff pincer, preferably a tight ACT-visible beat with either frame-animated combat, a small route reward, or authored traversal support.

## Session Extract -- /dev-story 2026-07-10

- Story: `production/epics/player-abilities/story-122-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-relay-runoff-pincer-reward-cache.md` -- Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Relay Runoff Pincer Reward Cache
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_test.gd`, `tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_reward_cache_smoke.gd`, `tests/smoke/critical-paths.md`, `production/epics/player-abilities/story-122-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-relay-runoff-pincer-reward-cache.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-service-sluice-tailrace-relay-runoff-pincer-reward-cache-2026-07-10.md`, `reports/old_factory_service_sluice_tailrace_relay_runoff_pincer_reward_cache_smoke.log`, `production/session-state/active.md`
- Implementation: Completed the Story122 payoff cache after the Story121 Tailrace Relay Runoff Pincer. The cache stays hidden/unavailable during locked, active, and half-cleared pincer states; once both pincer enemies are defeated, the cache at `Vector2(15460, 410)` becomes visible and claimable with `+20 Gears`. Claiming succeeds once, rejects duplicate claims, persists `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_claimed=true`, records reward/feedback payloads, and advances route feedback to `Tailrace Runoff Pincer Cache Claimed +20 Gears`. Restoring only the new claimed key backfills the Story106-121 chain, hides both pincer enemies, and preserves the Story119 Tailrace Relay savepoint.
- Asset pipeline: No new visual or audio assets were generated. Story122 reuses the existing image-generated/imported lower-deck cache texture `assets/environment/old_factory_lower_deck_skirmish_cache/env_old_factory_lower_deck_skirmish_cache_claimable_256.png` and the existing `factory_combat_cache.gd` pipeline.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_test.gd` covers locked, active, half-cleared, available, once-only claim, reward/feedback payload, local-state persistence, restored claimed-state backfill, pincer hidden state, and Tailrace Relay savepoint preservation.
- Verification: Focused RED `reports/report_1370/` failed as expected before Story122 diagnostics/API/state were complete. Focused GREEN `reports/report_1371/` passed Story122 `2/2`; related GREEN `reports/report_1372/` passed Story122 plus Story121, Story120, and Story115 suites `8/8`. Headless smoke `reports/old_factory_service_sluice_tailrace_relay_runoff_pincer_reward_cache_smoke.log` exited `0` and printed `service_sluice_tailrace_relay_runoff_pincer_reward_cache_smoke=passed`, with only known Godot cleanup-time ObjectDB/resource messages after shutdown. Godot AI MCP `2.9.1` on Godot `4.7-stable` reloaded and ran the factory scene with helper live, confirmed the cache node/script/id/source/reward/prompt, runtime visible/claimable state after pincer clear, once-only claim, route feedback, persisted local state, current-run game log containing only helper registration, empty editor log, and a non-empty `960x539` game screenshot.
- Notes: QA and level-design sidecars both recommended keeping Story122 as a pure payoff cache: no new enemies, hazards, gates, savepoint, generated art, or route-bound expansion. The existing Story121 bounds remain sufficient.
- Blockers: None. New traversal, new combat, new generated art, authored audio, minimap/fast-travel UI, SaveSystem schema changes, Boss2, and broader biome art replacement remain out of scope.
- Next: continue deeper Old Factory route content after the pincer reward cache, preferably a compact ACT-visible handoff, traversal support beat, or another short frame-animated combat slice.

## Session Extract -- /dev-story 2026-07-10

- Story: `production/epics/player-abilities/story-123-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-relay-runoff-pincer-exit-hatch-handoff.md` -- Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Relay Runoff Pincer Exit Hatch Handoff
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_test.gd`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_reward_cache_test.gd`, `tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_smoke.gd`, `tests/smoke/critical-paths.md`, `production/epics/player-abilities/story-123-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-relay-runoff-pincer-exit-hatch-handoff.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-service-sluice-tailrace-relay-runoff-pincer-exit-hatch-2026-07-10.md`, `reports/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_smoke.log`, `production/session-state/active.md`
- Implementation: Added a Story122-gated Tailrace Runoff Pincer exit hatch handoff. `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerExitHatch` stays hidden/unavailable/non-blocking until the pincer reward cache is claimed. Once available, the hatch appears at `Vector2(16080, 392)`, uses endpoint id `old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch`, shows `Open Tailrace Exit`, blocks collision before opening, opens once in range, plays one unlock spark, clears collision, persists `factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_opened=true`, and advances route feedback to `Tailrace Runoff Exit Opened`. The route extends to right wall x `16480`, camera/background right `16500`, ground right edge x `16600`, and 66 floor visuals.
- Asset pipeline: No new visual or audio assets were generated. Story123 reuses the existing image-generated/imported deep-bulkhead hatch texture, deep-route unlock spark VFX, and route floor tile asset already in the Godot import pipeline.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_test.gd` covers Story122 cache-claim gating, node/script/texture/VFX contracts, prompt state, route bounds, collision blocking before open, one-shot open, VFX spawn count, local-state persistence, restored completed state, Story106-122 backfill, pincer hidden state, and Tailrace Relay savepoint preservation. Story122 restore expectations now assert the new post-cache handoff label `Open Tailrace Runoff Exit`, while immediate claim feedback remains `Tailrace Runoff Pincer Cache Claimed +20 Gears`.
- Verification: Focused RED `reports/report_1373/` failed as expected before Story123 diagnostics/API existed. Final focused GREEN `reports/report_1377/` passed Story123 `2/2`; final related GREEN `reports/report_1378/` passed Story123, Story122, Story121, Story120, Story119, and Story116 suites `12/12`. Headless Factory smoke `reports/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_hatch_smoke.log` exited `0` and printed `service_sluice_tailrace_relay_runoff_pincer_exit_hatch_smoke=passed`, with only known Godot cleanup-time ObjectDB/resource messages after shutdown. Godot AI MCP `2.9.1` on Godot `4.7-stable` force-reloaded the clean scene from disk, confirmed hatch node/script/id/prompts/VFX and right-wall/camera bounds, ran the scene helper live with `current_run_errors=[]`, confirmed runtime visible/available/blocking state after cache claim, first open `true`, duplicate open `false`, collision cleared, VFX spawn count `1`, local-state persistence, game log containing only helper registration, empty editor log, and a non-empty `960x539` screenshot.
- Notes: The level-design sidecar recommended `Vector2(16080, 392)` and short handoff pacing. The QA sidecar recommended a similar reward-exit hatch scope; final implementation keeps the shorter `pincer_exit_hatch` naming while preserving the gating, one-shot open, restore backfill, and no-new-content boundaries.
- Blockers: None. New enemies, hazards, reward caches, savepoints, generated art, authored audio, minimap/fast-travel UI, SaveSystem schema changes, SceneManager transition, Boss2, and broader biome art replacement remain out of scope.
- Next: continue deeper Old Factory content after the pincer exit hatch, preferably a compact playable traversal or ACT combat beat that avoids broad verification and keeps player-visible enemies on `AnimatedSprite2D + SpriteFrames`.

## Session Extract -- /dev-story 2026-07-10

- Story: `production/epics/player-abilities/story-124-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-relay-runoff-pincer-exit-spillway-traverse.md` -- Old Factory Lower Deck Forward Pressure Aftershock Condenser Overflow Pump Runoff Outlet Service Sluice Tailrace Relay Runoff Pincer Exit Spillway Traverse
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_test.gd`, `tests/smoke/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke.gd`, `tests/smoke/critical-paths.md`, `production/epics/player-abilities/story-124-old-factory-lower-deck-forward-pressure-aftershock-condenser-overflow-pump-runoff-outlet-service-sluice-tailrace-relay-runoff-pincer-exit-spillway-traverse.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-service-sluice-tailrace-relay-runoff-pincer-exit-spillway-2026-07-10.md`, `reports/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke.log`, `production/session-state/active.md`
- Implementation: Added a Story123-gated Tailrace Exit Spillway traversal. `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerExitSpillwayDuct` and `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerExitSpillwayVent` stay hidden/non-contacting until the pincer exit hatch is opened; reaching x `16560.0` activates the deterministic steam window and route feedback `Cross Tailrace Exit Spillway`. Only the `active` phase enables contact/collision damage. Crossing x `17040.0` persists activated/crossed flags, disables contact, keeps the Story119 Tailrace Relay savepoint payload intact, and advances feedback to `Tailrace Exit Spillway Crossed`. The route now extends to right wall x `17280`, camera/background right `17300`, ground support through x `17400`, and 69 floor visuals.
- Asset pipeline: No new visual or audio assets were generated. Story124 reuses the existing image-generated/imported service-sluice landing texture, old factory steam vent hazard texture, and generated route floor tile. The AGENTS frame-animation rule is not triggered because Story124 adds an environment traversal hazard, not a new visible character.
- Test written: `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_test.gd` covers Story123 hatch gating, node/texture/hazard contracts, activation/completion thresholds, active-only contact window, route bounds, local-state persistence, restored completed state, and Story106-123 backfill without replaying hatch VFX or pincer enemies.
- Verification: Focused RED `reports/report_1379/` failed as expected before Story124 diagnostics/API/scene/state existed. Focused GREEN `reports/report_1380/` passed Story124 `2/2`; related GREEN `reports/report_1381/` passed Story124 plus Story123, Story122, Story121, Story120, and Story119 suites `12/12`. Headless Factory smoke `reports/old_factory_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke.log` exited `0` and printed `service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke=passed`, with only known Godot cleanup-time ObjectDB/resource messages after shutdown. Godot AI MCP `2.9.1` on Godot `4.7-stable` force-reloaded and ran the factory scene with helper live, confirmed the edited-scene spillway duct/vent, hazard id, texture, bounds, ready/active/contact/crossed runtime diagnostics, local-state persistence, clean current-run game/editor logs, and a non-empty `640x359` screenshot.
- Notes: The level-design sidecar recommended a short spillway traversal instead of another enemy immediately after Story121's dual-rat pincer, and the QA sidecar recommended limiting verification to focused plus adjacent suites. A first related GdUnit command used comma-separated paths and found no tests; it was discarded and rerun correctly with six `-a` arguments before recording `reports/report_1381/`.
- Blockers: None. New enemies, reward caches, savepoints, generated art, authored audio, minimap/fast-travel UI, SaveSystem schema changes, SceneManager transition, Boss2, and broader biome art replacement remain out of scope.
- Next: continue deeper Old Factory route content after the spillway, preferably a compact ACT-visible beat with either frame-animated combat or another short authored traversal support piece while keeping verification bounded.

## Session Extract -- /dev-story 2026-07-10

- Story: `production/epics/player-abilities/story-125-old-factory-tailrace-exit-spillway-visual-pass.md` -- Old Factory Tailrace Exit Spillway Visual Pass
- Files changed: `scenes/factory_route_transition_shell.tscn`, `tests/unit/gameplay/old_factory_tailrace_exit_spillway_visual_pass_test.gd`, `assets/environment/old_factory_tailrace_exit_spillway/env_old_factory_tailrace_exit_spillway_768.png`, `assets/generated/source/old_factory_tailrace_exit_spillway_imagegen_20260710.png`, `assets/generated/source/old_factory_tailrace_exit_spillway_alpha_20260710.png`, `assets/generated/source/old_factory_tailrace_exit_spillway_imagegen_20260710.json`, `design/assets/asset-manifest.md`, `production/epics/player-abilities/story-125-old-factory-tailrace-exit-spillway-visual-pass.md`, `production/epics/player-abilities/EPIC.md`, `production/epics/index.md`, `production/qa/evidence/old-factory-tailrace-exit-spillway-visual-pass-2026-07-10.md`, `reports/old_factory_tailrace_exit_spillway_visual_pass_smoke.log`, `production/session-state/active.md`
- Implementation: Replaced the Story124 spillway duct's reused service-sluice landing texture with a dedicated image-generated Tailrace Exit Spillway prop. The new runtime asset is a transparent `768x320` PNG at `assets/environment/old_factory_tailrace_exit_spillway/env_old_factory_tailrace_exit_spillway_768.png`, mounted on `FactoryLowerDeckForwardPressureAftershockCondenserOverflowPumpRunoffOutletServiceSluiceTailraceRelayRunoffPincerExitSpillwayDuct` while preserving its position `Vector2(16720,392)`, scale `0.78`, `z_index=12`, and Story124 traversal/hazard behavior. No route geometry, collision, enemy, reward, savepoint, or state key changed.
- Asset pipeline: Generated a new Old Factory tailrace exit spillway image on flat green chroma key, alpha-matted it to `assets/generated/source/old_factory_tailrace_exit_spillway_alpha_20260710.png`, cropped/centered it into `env_old_factory_tailrace_exit_spillway_768.png`, imported it through Godot 4.7, and recorded source/alpha/runtime/metadata paths in `design/assets/asset-manifest.md`.
- Test written: `tests/unit/gameplay/old_factory_tailrace_exit_spillway_visual_pass_test.gd` covers hatch-open ready state, dedicated texture path, rejection of the previous reused landing texture, runtime texture size `768x320`, duct transform/z-order, unchanged steam vent texture/hazard id/damage/cooldown/contact state, and Story124 route bounds/floor tile count.
- Verification: Focused RED `reports/report_1383/` failed as expected because the duct still used `env_old_factory_runoff_service_hatch_landing_768.png`; Godot import exited `0`; focused GREEN `reports/report_1384/` passed Story125 `1/1`; existing Story124 targeted smoke was reused and wrote `reports/old_factory_tailrace_exit_spillway_visual_pass_smoke.log` with marker `service_sluice_tailrace_relay_runoff_pincer_exit_spillway_smoke=passed`; Godot AI MCP `2.9.1` on Godot `4.7-stable` force-reloaded the scene from disk, confirmed the new texture path, `768x320` runtime texture size, duct transform, unchanged steam vent hazard parameters, ready visible runtime diagnostics, right-wall/camera/background/ground/floor bounds, clean current-run game/editor logs, and a non-empty `640x359` game screenshot.
- Notes: One initial MCP eval probe used untyped `var diagnostics` and caused an eval-only debugger break after returning a result. The run was stopped, relaunched, and rechecked with explicit `Dictionary`/`Sprite2D` types; the typed eval, logs, and screenshot passed cleanly. Story125 intentionally adds no new smoke script because the existing Story124 targeted smoke covers the same runtime node and traversal chain.
- Blockers: None. New route content, enemies, rewards, savepoints, SaveSystem schema changes, minimap/fast-travel UI, authored audio, particles/shaders, Boss2, and broader biome art replacement remain out of scope.
- Next: continue deeper Old Factory content after the spillway visual pass, preferably a compact ACT-visible beat with frame-animated combat or a small route handoff, while keeping verification bounded and continuing to replace player-facing blocky placeholders with generated assets.

## Session Extract -- /dev-story 2026-07-11

- Story: `production/epics/player-abilities/story-126-old-factory-tailrace-exit-spillway-sluice-leech-skirmish.md` -- Old Factory Tailrace Exit Spillway Sluice Leech Skirmish
- Files changed: `src/gameplay/old_factory_entrance_scene.gd`, `scenes/factory_route_transition_shell.tscn`, `src/gameplay/factory_sluice_leech.gd`, `src/gameplay/factory_sluice_leech.tscn`, `src/characters/factory_sluice_leech.gd`, `scenes/characters/factory_sluice_leech.tscn`, `assets/characters/factory_sluice_leech/`, `design/assets/specs/factory-sluice-leech.md`, `design/assets/asset-manifest.md`, `design/assets/entity-inventory.md`, `tests/unit/gameplay/old_factory_tailrace_exit_spillway_sluice_leech_skirmish_test.gd`, `tests/unit/gameplay/old_factory_lower_deck_forward_pressure_aftershock_condenser_overflow_pump_runoff_outlet_service_sluice_tailrace_relay_runoff_pincer_exit_spillway_test.gd`, `tests/smoke/old_factory_tailrace_exit_spillway_sluice_leech_skirmish_smoke.gd`, `tests/smoke/critical-paths.md`, Story126/Epic/index metadata, QA evidence, and this session extract.
- Implementation: Added the first distinct Factory Sluice Leech family after the crossed Tailrace Exit Spillway. Crossing x `17360` activates entity `2146` at `Vector2(17760,482)`, targets Cinderpaw, starts an `18`-frame warning, and drives a short active-frame lunge through the shared CollisionComponent hit path. Defeat persists activated/defeated/cleared flags, advances feedback from `Break Tailrace Sluice Leech` to `Tailrace Sluice Leech Cleared`, backfills Story124 on clear-only restore, and preserves the Story119 Tailrace Relay checkpoint. Route support now reaches right wall `18120`, camera/background `18140`, ground right edge `18240`, and `73` floor visuals.
- Asset pipeline: Built-in image generation created a strict `3x6` magenta-keyed mutated industrial leech sheet. Local processing retained the `972x1619` RGB source and RGBA alpha source, generated a `288x576` preview, and normalized eighteen transparent `96x96` frames with shared x `48` and baseline y `88`. `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` each have three frames in `factory_sluice_leech_sprite_frames.tres`; Godot 4.7 import exited `0`.
- Test written: Story126 focused GdUnit covers source/runtime asset structure, alpha/canvas dimensions, character and enemy scenes, family/entity ids, Story124 gating, activation, pacing, bounds, defeat, persistence, backfill, and checkpoint preservation. The targeted smoke covers activation through lunge, damage, clear, and restore. The stale Story124 texture assertion now follows Story125's dedicated spillway asset.
- Verification: RED `reports/report_1385/` captured five expected missing contracts. Focused GREEN `reports/report_1388/` passed `2/2` cleanly; related GREEN `reports/report_1390/` passed Story126 plus Story124, Story125, and Story121 `7/7`. Headless smoke exited `0` with marker `old_factory_tailrace_exit_spillway_sluice_leech_skirmish_smoke=passed`. Godot AI MCP `2.9.1` on Godot `4.7-stable` reloaded the disk scene, found the character and runtime enemy, confirmed six 3-frame animations, live activation, the 18-frame startup, nonzero forward lunge, defeat/restore state, preserved checkpoint, `current_run_errors=[]`, no new cursor-scoped editor log rows, and a non-empty `960x539` screenshot showing Cinderpaw and the leech.
- Notes: Retained editor rows from an intermediate patch predated the final helper definition and filesystem rescan; final focused/related tests, smoke, current-run error set, game log, and cursor-scoped editor log were clean. The `96x96` frame size intentionally matches existing Old Factory enemies instead of the Art Bible's generic `64x64` small-enemy target and is documented in the asset spec.
- Blockers: None for Story126. The broader game goal remains active; route/chapter handoff, minimap, skill-tree branches, authored audio, MainScene art cleanup, and Boss2 polish remain candidates.
- Next: continue with a deliberate Tailrace route/chapter handoff or another bounded player-visible slice, using generated assets where new visuals are required and keeping validation focused plus MCP runtime evidence.

## Session Extract -- /dev-story 2026-07-11

- Delivery checkpoint: Story126 was committed as `346a9fcf` (`Implement tailrace sluice leech skirmish`) and pushed to `origin/master` before Story127 began.
- Story: `production/epics/player-abilities/story-127-old-factory-tailrace-sluice-matriarch-arena-handoff.md` -- Old Factory Tailrace Sluice Matriarch Arena Handoff
- Files changed: Factory route scene/controller, new Sluice Matriarch arena scene/controller, SceneManager registry/schema, generated source/runtime backdrop and asset records, Story127 focused test, Story126 next-objective expectations, targeted smoke/critical paths, Story/Epic/index metadata, QA evidence, and this session extract.
- Implementation: Added `FactoryTailraceSluiceMatriarchRoute` inside the existing Story126 bounds. Story126 clear changes its prompt to `Enter Sluice Matriarch Lair` and permits one asynchronous request to `boss_03_sluice_matriarch_arena / boss_entry`. The registered arena aligns Cinderpaw at `BossEntrySpawn`, supplies bounded floor/walls, Camera2D, objective label, and `FactoryReturnRoute`; contact requests `area_03_factory / tailrace_matriarch_gate_return`. Returning places Cinderpaw at `(17840,456)`, preserves the Sluice Leech clear and Tailrace Relay checkpoint, and clears transient request latches for re-entry.
- Asset pipeline: Built-in image generation produced a `1672x941` opaque RGB tailrace pressure-cathedral source with a dormant leech cocoon, rusted machinery, damp pipes, cyan entrance lighting, and readable floor. The retained source was resized to an opaque `1280x720` runtime backdrop, imported through Godot 4.7, and recorded in the manifest, entity inventory, asset spec, generation record, and QA evidence.
- Test written: Story127 focused GdUnit covers route gating/request rejection, registry/schema, arena structure/background, and bidirectional request contracts. The targeted smoke drives the actual SceneManager runtime root through Factory -> arena -> Factory and checks exact spawns, Story126 clear persistence, and transient latches; Story126 related regression plus MCP restore evidence cover Tailrace Relay preservation.
- Verification: RED `reports/report_1391/` exposed the expected missing contracts. A test-only `Image.detect_alpha()` enum mismatch was corrected after `report_1392`. Focused GREEN `reports/report_1393/` passed `2/2`; final related GREEN `reports/report_1395/` passed Story127, Story126, and two SceneManager suites `17/17`. Headless smoke exited `0` with marker `old_factory_tailrace_sluice_matriarch_arena_handoff_smoke=passed`. Godot AI MCP `2.9.1` on Godot `4.7-stable` verified both scenes, bidirectional requests and actual swaps, exact spawns, persistence, clean current-run logs, and non-empty Factory/arena screenshots. The first arena screenshot exposed a clipped left prompt; positions were corrected and force-reloaded before final evidence.
- Notes: Three attempts to start parallel sidecars failed before task execution because the multi-agent backend supplied unsupported `reasoning.effort=max` to models capped at `xhigh`. Integration and review continued locally; no code or asset output was accepted from failed agents.
- Blockers: None for Story127. The Sluice Matriarch boss character, generated frame animation, combat AI, HP/HUD, room seals, phases, defeat state, reward, and `aerial_attack` unlock remain intentionally unimplemented.
- Next: implement Story128 as a bounded playable Sluice Matriarch Boss3 slice in the existing arena, using `AnimatedSprite2D + SpriteFrames`, image-generated character frames, one readable core attack loop, boss HP/HUD, room seals, defeat persistence, focused tests, one smoke, and MCP runtime proof.

## Session Extract -- /dev-story 2026-07-11

- Delivery checkpoint: Story127 was committed as `ce61b155` (`Add Sluice Matriarch arena handoff`) and pushed to `origin/master` before Story128 integration completed.
- Story: `production/epics/player-abilities/story-128-sluice-matriarch-playable-boss3-core.md` -- Sluice Matriarch Playable Boss3 Core.
- Files changed: generated Sluice Matriarch source/alpha/preview and eighteen runtime frames, SpriteFrames/character/runtime scenes and scripts, arena scene/controller, shared player respawn hurtbox restoration, Story128 and Story127 tests/smokes, critical-path list, asset spec/manifest/inventory, Story/Epic/index metadata, QA evidence, and this session extract.
- Implementation: Mounted entity `2300` with `120` HP and shared Health/Collision/Combat/Status components. Its pressure lunge uses an 18-frame no-hitbox tell, six active frames with body movement and deterministic 16 damage, and 18-frame recovery. At 50% HP the second phase raises movement from 14 to 20 pixels per frame and lowers cooldown from 42 to 28 frames. The arena mounts the shared WeaponComponent, binds Cinderpaw's real hitbox chain to Boss3, displays a live Boss HUD, owns the ADR-0007 scene lock, seals both exits until victory, persists defeat, then exposes the Story127 Factory return route.
- Retry behavior: Player death now respawns Cinderpaw at `BossEntrySpawn` with full HP and resets the boss to full HP, phase one, and `(930,540)`. MCP exposed that the shared `PlayerController.respawn_at()` restored HP but left the Core hurtbox `gone`; Story128 added a failing assertion and fixed the shared respawn entry to restore `normal`/monitorable collision state.
- Asset pipeline: Built-in image generation produced a strict `3x6` magenta-keyed giant industrial leech sheet. Local processing retained the `1254x1254` RGB and RGBA sources, generated a `576x1152` transparent preview, and normalized eighteen `192x192` frames. `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` each have three frames; Godot 4.7 import exited `0`.
- Verification: Initial RED `report_1396`; focused development and regression reports through `report_1406`; respawn-hurtbox RED/GREEN `report_1407`/`report_1408`; ADR-0007 scene-lock RED/GREEN `report_1410`/`report_1411`; player WeaponComponent chain RED/GREEN `report_1413`/`report_1414`; final bounded related GREEN `report_1415` passed `14/14`. The targeted headless smoke exited `0`. Godot AI MCP `2.9.1` on Godot `4.7-stable` verified the 37-node arena, six three-frame animations, Cinderpaw `cat_claw_light` damage `120 -> 108` against target `2300`, startup/active Boss attack states, 16-damage metadata, combat-capable retry, synchronized Phase II HUD, active SceneManager lock and defeat release, defeat-open route, persistent death state, non-empty screenshots, `current_run_errors=[]`, and no new cursor-scoped editor rows.
- Scope notes: Story128 intentionally keeps one attack family and two phases, reuses existing generated room-seal art, and leaves the persistent death sprite visible/non-damaging. Full three-phase data migration, authored audio/VFX/portrait, victory reward, and post-Boss3 route remain out of scope.
- Blockers: None for Story128. The broader game goal remains active.
- Next: implement Story129 as a compact player-visible Boss3 victory payoff that presents and persists the `aerial_attack` unlock, then connects it to a demonstrable traversal/combat use before extending the route.

## Session Extract -- /dev-story 2026-07-11

- Delivery checkpoint: Story128 was committed as `f50e83f5` (`Implement playable Sluice Matriarch Boss3`) and pushed to `origin/master` before Story129 integration completed.
- Story: `production/epics/player-abilities/story-129-sluice-matriarch-aerial-attack-reward-payoff.md` -- Sluice Matriarch Aerial Attack Reward Payoff.
- Implementation: Boss3 defeat now reveals one generated `AerialAttackRewardSource`; proximity claim unlocks `aerial_attack`, updates HUD/objective feedback, persists the claimed flag, and merges unlocked abilities into Factory/Main SceneManager states before return. Airborne regular attack input prefers `cat_claw_aerial`, drives Cinderpaw downward with a dedicated three-frame animation, deals shared 12 damage, grants eight cat energy, bounces once, and restores one consumed double-jump use.
- Asset pipeline: Built-in image generation produced a three-cell Cinderpaw aerial strip and a dedicated Boss3 ability core. Local chroma-key processing retained source/alpha records, normalized three transparent `96x96` runtime frames, produced a transparent `256x256` reward, and imported both through Godot 4.7. Asset spec, manifest, and entity inventory record the prompts and runtime paths.
- Verification: RED `reports/report_1416/`; final focused GREEN `reports/report_1419/` passed `3/3`; bounded related GREEN `reports/report_1420/` passed `20/20`; targeted smoke exited `0` with marker `sluice_matriarch_aerial_attack_reward_payoff_smoke=passed`. Godot AI MCP `2.9.1` on Godot `4.7-stable` force-reloaded the arena, confirmed the 42-node authored and 72-node runtime hierarchies, player AnimatedSprite2D/SpriteFrames path, generated reward texture path, non-empty `1278x718` gameplay screenshot, `current_run_errors=[]`, helper-only game log, and no new editor rows after cursor `3`.
- Notes: Parallel design/art/QA sidecars failed before task execution because the backend supplied unsupported `reasoning.effort=max`; integration and review continued locally. Retained Old Factory parse rows were marked as pre-run history and did not recur in the final MCP run.
- Blockers: None for Story129. The broader game goal remains active.
- Next: implement Story130 as a bounded aerial-attack exploration gate and Factory-to-Underground route handoff, reusing the completed ability contract instead of widening Story129.

## Session Extract -- /dev-story 2026-07-11

- Delivery checkpoint: Story129 was committed as `65887a61` (`Implement Boss3 aerial attack reward`) and pushed to `origin/master` before Story130 began.
- Story: `production/epics/player-abilities/story-130-factory-aerial-breach-underground-passage-handoff.md` -- Factory Aerial Breach Underground Passage Handoff.
- Implementation: Added `FactoryTailraceUndergroundAerialBreach` using the shared ExplorationGate. It remains locked without `aerial_attack`; real airborne activation within 104 px opens it once, disables collision, plays shared generated feedback, persists `factory_tailrace_underground_aerial_breach_opened`, merges abilities into destination state, and requests `area_04_underground_passage / factory_drop_entry`. The new bounded Underground scene has Cinderpaw, Camera2D, floor/walls, HUD/objective, generated background, and a repeatable Factory return route to `tailrace_underground_return`.
- Asset pipeline: Built-in image generation produced an opaque Underground source and a magenta-keyed cracked floor. Local processing produced exact opaque `1280x720` and transparent `384x160` runtime assets, imported them through Godot 4.7, and recorded source/alpha/runtime paths in generation records, spec, manifest, and inventory.
- Verification: RED `reports/report_1421/`; final focused GREEN `reports/report_1423/` passed `2/2`; bounded adjacent GREEN `reports/report_1424/` passed `11/11`; real SceneManager smoke exited `0` with marker `factory_aerial_breach_underground_passage_handoff_smoke=passed`. Godot AI MCP `2.9.1` on Godot `4.7-stable` verified Factory gate properties/runtime metadata, Underground 26-node editor and 47-node runtime hierarchies, generated texture paths, clean current-run logs, and a non-empty `1278x718` gameplay screenshot.
- Debugging: The smoke exposed missing ability propagation into the destination and stale active VFX on cached Factory return. Target-state merging and restore-time feedback completion fixed both without widening the gate state machine.
- Blockers: None for Story130. The broader game goal remains active.
- Next: implement Story131 as the first compact playable Underground traversal or combat beat, keeping the Story130 entry/return contract and bounded validation.

## Session Extract -- /dev-story 2026-07-11

- Delivery checkpoint: Story130 was committed as `c15be403` (`Add Factory Underground aerial breach`) and pushed to `origin/master` before Story131 began.
- Story: `production/epics/player-abilities/story-131-underground-corrosion-channel-skirmish.md` -- Underground Corrosion Channel Skirmish.
- Implementation: Expanded Underground Passage to `2560x720` with a second generated background, three stepping platforms, an `8`-damage/`1.0s` cooldown corrosive runoff hazard, rear/front generated combat seals, two existing six-animation Factory Sluice Leeches (entities `2401/2402`), shared Weapon/Combat/Collision hit routing, dual-defeat clear, a persistent one-shot `+20 Gears` salvage cache, proximity-only prompt, sewer audio requests, and preserved Factory return state.
- Asset pipeline: Built-in image generation produced the opaque corrosion channel plus magenta-keyed runoff, seal, and cache. Local chroma-key processing retained RGB/alpha sources, normalized exact `1280x720`, `512x160`, `256x384`, and `256x256` runtime assets, and imported all files through Godot 4.7. Four generation records, a shared asset spec, manifest rows, and inventory rows record the pipeline.
- Verification: RED `reports/report_1426/`; final focused GREEN `reports/report_1432/` passed `3/3`; bounded related GREEN `reports/report_1429/` passed `7/7`; real SceneManager smoke exited `0` with marker `underground_corrosion_channel_skirmish_smoke=passed`. Godot AI MCP `2.9.1` / Godot `4.7-stable` final run token `27` verified the 56-node authored and 90-node runtime hierarchies, real movement to x `1510.93`, rear seal safely behind at x `1370`, two live AnimatedSprite2D enemies, hidden distant cache prompt, non-empty `1278x718` screenshot, `current_run_errors=[]`, helper-only game log, and no editor rows after cursor `3`.
- Debugging: MCP play found that the initial rear seal at x `1488` would close in front of the x `1450` trigger; it moved to x `1370` and gained a geometry assertion. A clipped distant cache prompt was also hidden until clear plus proximity.
- Notes: Design/art/QA sidecars failed before task execution because the backend forced unsupported `reasoning.effort=max` even when `high` was requested; integration and all three reviews continued locally.
- Blockers: None for Story131. The broader game goal remains active.
- Next: implement Story132 as a deeper Underground route/savepoint or a distinct second encounter from the secured corrosion channel.

## Session Extract -- /create-stories 2026-07-11

- Delivery checkpoint: Story131 was committed as `4fc21ff4` (`feat: implement Underground corrosion skirmish`) and pushed to `origin/master`; local and remote hashes matched before Story132 planning.
- Story: `production/epics/player-abilities/story-132-underground-recovery-cistern-savepoint-traverse.md` -- Underground Recovery Cistern Savepoint Traverse.
- Design: Extend `area_04_underground_passage` to a third `1280x720` viewport with a recovery relay before a platform gap, a lethal fall zone, a far-side endpoint, real savepoint autosave/full recovery, and the existing GameFlow 1.5s death plus 50% HP/2.0s revive contract. Keep the behavior in a dedicated child controller instead of expanding the 1107-line parent controller.
- Alternatives rejected: a second immediate dual-enemy encounter repeats Story131; a new registered area scene widens this slice into registry/schema/transition work.
- Parallel review: level, technical-art, and QA sidecars were attempted twice, but the backend forced unsupported `reasoning.effort=max` before task execution. Their scopes continue locally without blocking implementation.
- Next: write focused RED acceptance tests, generate the three recovery-cistern visuals, implement the dedicated controller and thin parent integration, then run focused/related, smoke, and Godot MCP runtime verification.

## Session Extract -- /dev-story 2026-07-11

- Story: `production/epics/player-abilities/story-132-underground-recovery-cistern-savepoint-traverse.md` -- Underground Recovery Cistern Savepoint Traverse.
- Implementation: Expanded Underground Passage to `3840x720` with a dedicated `UndergroundRecoveryCisternController`, generated third background, generated one-shot recovery relay, three stepping platforms, lethal fall zone, generated endpoint, Camera2D/right-wall bounds, JSON-safe local state, and SceneManager relay spawn alignment. Relay activation restores full HP, dispatches shared audio/VFX plus one slot-0 autosave, and becomes the GameFlow savepoint for a 1.5s death beat, 50% HP revive, and 2.0s lock/invincibility window.
- Runtime fixes: MCP found the Underground HUD was not bound to player health; the parent scene now updates `HUDManager` from `player_health_changed`. A physics-frame endpoint test then exposed synchronous Area2D monitoring changes inside `body_entered`; relay, endpoint, and fall-zone monitoring now use deferred updates and no longer emit Godot runtime errors.
- Asset pipeline: Built-in image generation produced an opaque `1672x941` cistern source, a `1254x1254` keyed relay, and an `887x1774` keyed endpoint. Local processing retained both RGBA alpha sources and normalized exact opaque `1280x720`, transparent `256x256`, and transparent `256x384` runtime assets. Godot 4.7 imported all source/alpha/runtime files; three generation records, one asset spec, manifest rows, and inventory rows document the pipeline.
- Verification: Initial RED `report_1433`; HUD RED `report_1442`; physics-monitoring diagnostic `report_1444`; final focused GREEN `report_1445` passed `3/3`; bounded related GREEN `report_1446` passed `20/20`; targeted SceneManager smoke exited `0` with `underground_recovery_cistern_savepoint_traverse_smoke=passed`. Godot AI MCP `2.9.1` on Godot `4.7-stable` force-reloaded the scene, verified authored/runtime nodes and texture paths, used real input for the Story131 clear, relay, fall, 50% HUD revive, and ability-complete platform traversal, produced a non-empty `1278x718` relay/gap/endpoint screenshot, and returned helper-only game logs plus no new editor rows after cursor `3`.
- Parallel review: Two rounds of level/art/QA sidecars failed before execution because the backend forced unsupported `reasoning.effort=max`; integration, review, and verification were completed by the integrating agent.
- Blockers: None for Story132. ADR-0018/0019/0021 remain project-level Proposed records already used as governing guidance by Stories129-132; this Story does not alter their status. The broader game goal remains active.
- Next: plan Story133 as a compact deep-Underground encounter or scene handoff from the secured endpoint, using frame animation for any new visible character and keeping verification focused plus MCP runtime evidence.

## Session Extract -- /create-stories 2026-07-11

- Delivery checkpoint: Story132 was committed as `b9966c78` (`feat: add Underground recovery cistern`) and pushed to `origin/master` before Story133 planning.
- Story: `production/epics/player-abilities/story-133-underground-deep-cistern-stalker-ambush.md` -- Underground Deep Cistern Stalker Ambush.
- Design: Extend `area_04_underground_passage` to a fourth viewport after the secured recovery endpoint. Gate a single new 48 HP Cistern Stalker behind Story132 traversal, close two generated Underground seals at x `3980/4960`, expose a 24-frame tell plus 6-frame leap-lunge, and clear the route through the shared combat chain.
- Alternatives rejected: an immediate scene handoff creates an empty destination; another Sluice Leech pair repeats Story131. Boss4 and wall-climb remain out of scope until their design contracts exist.
- Art contract: Generate one opaque deep-cistern background and one strict keyed 3x6 Stalker animation sheet. Normalize six three-frame transparent `96x96` animations and wire them through `AnimatedSprite2D + SpriteFrames`.
- Verification budget: three focused acceptance tests, one bounded related run, one targeted smoke, and one final Godot MCP runtime pass. Do not run the full suite repeatedly.
- Parallel review: Do not retry the sidecars that failed twice before execution on the unsupported backend reasoning setting; complete the bounded design, art, QA, and integration reviews locally.
- Next: write the focused RED suite before production code, then generate/import assets and implement the dedicated controller plus thin parent integration.

## Session Extract -- /dev-story 2026-07-11

- Story: `production/epics/player-abilities/story-133-underground-deep-cistern-stalker-ambush.md` -- Underground Deep Cistern Stalker Ambush.
- Implementation: Expanded Underground Passage to `5120x720` with a fourth generated background, continuous arena ground, rear/front seals, and `UndergroundDeepCisternAmbushController`. Story132 traversal unlocks a new entity `2501` Cistern Stalker with 48 HP, a 24-frame red-spine tell, 6-frame 14-damage leap-lunge, 18-frame recovery, shared component combat routing, durable activation/clear state, and `Deep Cistern Secured` objective.
- Frame animation: Built-in image generation produced a strict magenta `3x6` Stalker sheet. Local helper removal and equal-cell normalization produced eighteen transparent `96x96` frames for `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death`; each animation has three frames and is wired through `AnimatedSprite2D + SpriteFrames` character/runtime scenes.
- Asset pipeline: Built-in image generation also produced an opaque fourth-view background. Source, alpha, preview, prompts, processing, runtime paths, spec, manifest, and inventory records are complete and imported through Godot 4.7.
- Runtime fixes: Focused combat exposed the parent player's fixed 12-damage calculator overriding the authored 14-damage leap; the enemy now uses the dedicated controller adapter. MCP exposed a clipped completed Story132 endpoint label; relay/endpoint prompts now use 192 px proximity visibility. Local review exposed immediate enemy hiding during clear; gameplay state now resolves immediately while the non-damaging `death` animation remains visible and fades out.
- Verification: RED `report_1448`; death-presentation regression RED `report_1455`; final focused GREEN `report_1456` passed `3/3`; bounded Story131-133 GREEN `report_1451` passed `9/9`; targeted smoke exited `0` with `underground_deep_cistern_stalker_ambush_smoke=passed`. Godot MCP `2.9.1` / Godot `4.7-stable` force-reloaded 97 authored nodes, ran 146 runtime nodes with real movement/attack input, verified the generated texture and SpriteFrames paths, produced a non-empty `1278x718` screenshot, captured the visible fading Stalker `death` animation with already-open seals in run `36`, returned `current_run_errors=[]`, helper-only final current-run logs, and no editor rows after cursor `3`.
- Blockers: None for Story133. The broader game goal remains active.
- Next: plan Story134 as a bounded deep-Underground route handoff or Boss4 approach design. Do not invent Boss4 or wall-climb implementation before the corresponding GDD/Story contract exists.

## Session Extract -- /dev-story 2026-07-11

- Delivery checkpoint: Story133 was committed as `b5659fdb` (`feat: add Underground Cistern Stalker ambush`) and pushed to `origin/master` before Story134 integration completed.
- Story: `production/epics/player-abilities/story-134-deep-cistern-ascender-factory-upper-altar-approach.md` -- Deep Cistern Ascender Factory Upper Altar Approach.
- Design: Boss4 remains unimplemented because the repository has no approved Boss4 configuration or story contract. Story134 instead follows the ability GDD's alternate source by connecting the secured deep cistern to a dormant hidden altar on the Old Factory upper platform, without granting `wall_climb`.
- Implementation: Registered `area_03_factory_upper_altar`, mounted a Story133-gated `DeepCisternAscenderRoute` in Underground Passage, persisted Story131-133 state plus unlocked abilities before SceneManager handoff, and added a bounded `1280x720` Factory upper approach with three collision-backed ascending platforms, Cinderpaw, Camera2D, HUD/objective, idempotent dormant-altar discovery, and a return route to `deep_cistern_ascender_return`.
- Asset pipeline: Built-in image generation produced a `1672x941` opaque upper-works source and a `1536x1024` keyed ascender/altar sheet. Local processing normalized exact opaque RGB `1280x720`, transparent RGBA `384x512`, and transparent RGBA `384x384` runtime assets. Godot 4.7 imported source, alpha, and runtime files; prompts, processing, spec, manifest, and inventory records are complete.
- Runtime fixes: MCP exposed a stale `Deep Cistern Secured` objective after fixture state changed, a right-edge Underground prompt, altar/HUD overlap, player occlusion, and duplicate discovery text. Objective refresh is now continuous where state priority changes, prompts remain inside viewport bounds, and altar layering/prompt behavior leaves Cinderpaw and the single authoritative objective readable.
- Verification: Initial RED `report_1457`; objective regression RED `report_1461`; final focused GREEN `report_1463` passed `3/3`; bounded related GREEN `report_1459` passed `15/15`; targeted smoke exited `0` with `deep_cistern_ascender_factory_upper_altar_approach_smoke=passed`. Godot AI MCP `2.9.1` on Godot `4.7-stable` runs `39` and `41` verified the authored 38-node destination, real SceneManager swap, generated textures, collision nodes, real horizontal movement, discovered altar state, readable screenshots, `current_run_errors=[]`, helper-only game logs, and no new cursor-scoped editor errors.
- Parallel review: Design/art/QA sidecars were attempted twice but failed before execution because the backend supplied unsupported `reasoning.effort=max`; bounded design, art, QA, and integration review continued locally without blocking delivery.
- Blockers: None for Story134. The broader game goal remains active.
- Next: define and implement Story135 as the hidden altar `wall_climb` reward and runtime movement slice, with player-visible frame animation and a compact traversal proof. Do not invent Boss4 until its design contract exists.

## Session Extract -- /dev-story 2026-07-11

- Delivery checkpoint: Story134 was committed as `77fb92df` (`feat: add Factory upper altar approach`) and pushed to `origin/master` before Story135 delivery.
- Story: `production/epics/player-abilities/story-135-factory-hidden-altar-wall-climb-reward-traversal.md` -- Factory Hidden Altar Wall Climb Reward Traversal.
- Implementation: The Story134 altar now grants data-driven `wall_climb` exactly once through AbilityComponent, persists claim plus unlocked abilities immediately, runs a `1.5s` reward beat, swaps to a generated awakened visual, and updates route objectives. PlayerController owns real wall contact, climb/slide, wall jump, regrab lock, blocking-state cleanup, diagnostics, and a dedicated three-frame `wall_climb` animation. The upper scene adds generated magnetic-wall/contact visuals, one-way proof perch, high proof area, and a top boundary; route completion persists `factory_upper_wall_climb_route_proven=true` and shows `Rooftop Route Reached`.
- Asset pipeline: Built-in image generation produced the three-cell Cinderpaw strip, awakened altar, magnetic wall, and contact glow. Local sampled-key matte/despill processing normalized three transparent `96x96` frames plus transparent `384x384`, `256x512`, and `192x192` props/VFX. Godot 4.7 imported source, alpha, runtime, SpriteFrames, and scene resources; generation records, asset spec, manifest, and inventory are complete.
- Verification: Initial RED `report_1464`; first focused GREEN `report_1465`; bounded related GREEN `report_1466` passed `12/12`; one-way regression RED/GREEN `report_1467/1468`; top-boundary regression RED/GREEN `report_1469/1470`; final focused GREEN `report_1471` passed `3/3`; targeted headless smoke passed with `factory_hidden_altar_wall_climb_reward_smoke=passed`. Godot AI MCP `2.9.1` on Godot `4.7-stable` runs `42-45` used real interaction/movement/jump/dash input, observed the wall-climb animation, found and verified the one-way-perch and top-boundary fixes, landed Cinderpaw on the lowered proof perch, captured a non-empty generated-art gameplay frame with `Rooftop Route Reached`, and returned error-free current game logs.
- Parallel review: Do not retry the sidecars that already failed twice before task execution because the backend inherited unsupported `reasoning.effort=max`; bounded design, art, QA, and integration review remained local.
- Blockers: None for Story135. Boss4, wall stamina, wall combat, and the Neon Rooftops destination remain out of scope. The broader game goal remains active.
- Next: define Story136 as a bounded Neon Rooftops magnetic-wall gate and registered scene handoff from the proven upper Factory route, reusing the finished wall-climb mechanics and keeping validation focused.

## Session Extract -- /dev-story 2026-07-11

- Delivery checkpoint: Story135 was committed as `6f3611d5` (`feat: add hidden altar wall climb`) and pushed to `origin/master` before Story136 began.
- Story: `production/epics/player-abilities/story-136-neon-rooftops-magnetic-wall-gate-handoff.md` -- Neon Rooftops Magnetic Wall Gate Handoff.
- Implementation: Registered `area_05_neon_rooftops`, added a generated bridge-beacon route and permanent gate state to the Factory high perch, merged abilities into destination state, and implemented exact `neon_rooftops_return` alignment after restore. The new bounded rooftop scene has generated environment art, generated magnetic tower and bridge, real invisible collision, one-way upper roof, top/side bounds, Cinderpaw/HUD/objective, rooftop music/ambient requests, persistent high-route proof, and a bidirectional Factory route.
- Asset pipeline: Built-in image generation produced one opaque `1672x941` rooftop source and one magenta-keyed `1672x941` two-prop sheet. Local resize and sampled-key matte/despill/trim processing produced exact opaque `1280x720`, transparent `256x512`, and transparent `256x384` runtime assets. Godot 4.7 imported source, alpha, runtime, scene, and script resources; prompts, processing, asset spec, manifest, and inventory are complete.
- Verification: Initial RED `report_1472` recorded `18` expected failures across `3` cases; focused GREEN `report_1475` passed `3/3`; the first related run `report_1476` found one stale Story135 objective expectation; final bounded related GREEN `report_1477` passed Stories134-136 `9/9`. The real SceneManager/physics smoke exited `0` with `neon_rooftops_magnetic_wall_handoff_smoke=passed`. Godot AI MCP `2.9.1` on Godot `4.7-stable` inspected the `36`-node authored scene, exact textures, player AnimatedSprite2D/SpriteFrames, camera limits and one-way collision; real `E` entered the registered area in run `46`; clean final run `48` captured Cinderpaw visibly in `wall_climb` against the generated rooftop/tower with `current_run_errors=[]`, helper/fixture-only game logs, and no editor rows after cursor `3`.
- MCP notes: Two exploratory eval probes produced temporary eval-only debugger breaks; both runs were stopped and discarded. Final validation used a temporary `tmp/` fixture, produced clean evidence, and deleted the fixture afterward.
- Blockers: None for Story136. Boss4, additional rooftop rooms, enemies, secrets, savepoints, minimap work, and Central Tower remain out of scope. The broader game goal remains active.
- Next: plan Story137 as a compact first Neon Rooftops combat or traversal expansion from the secured high roof, with frame-animated visible characters and bounded verification.

## Session Extract -- /dev-story 2026-07-12

- Delivery checkpoint: Story136 was committed as `4dfda23c` (`feat: add Neon Rooftops magnetic wall route`) and pushed to `origin/master` before Story137 delivery.
- Story: `production/epics/player-abilities/story-137-neon-rooftops-signal-rat-ambush.md` -- Neon Rooftops Signal Rat Ambush.
- Implementation: Expanded Neon Rooftops to `2560x720` with a generated second background, physical descent/arena collision, generated rear/front seals, generated reward cache, and `NeonSignalRoofEncounterController`. Story136 traversal gates entity `2601`, a data-driven `36` HP Signal Rat with an 18-frame tell, 5-frame 11-damage magnetic lunge, shared combat routing, durable activation/defeat/claim state, shared audio, objectives, and one `+20 Gears` reward.
- Frame animation: Built-in image generation produced a strict keyed `3x6` Signal Rat sheet. Installed chroma-key processing and equal-cell normalization produced eighteen transparent `96x96` frames for `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death`; each animation has three common-anchor frames wired through `AnimatedSprite2D + SpriteFrames` character/runtime scenes.
- Asset pipeline: Built-in image generation also produced the opaque Signal Roof background and keyed seal/cache sheet. Local processing normalized exact RGB `1280x720`, RGBA `256x384`, RGBA `256x256`, source/alpha/preview records, runtime assets, spec, manifest, and inventory; Godot 4.7 imported the complete set.
- Verification: Initial RED `report_1478` recorded `36` expected failures; focused GREEN `report_1481` passed `3/3`; the first adjacent run `report_1482` exposed one stale Story136 objective expectation; final Story136-137 GREEN `report_1483` passed `6/6`. Targeted headless smoke exited `0` with `neon_rooftops_signal_rat_ambush_smoke=passed`. Godot AI MCP `2.9.1` on Godot `4.7-stable` force-reloaded `58` authored nodes, ran `86` runtime nodes, used real movement and attack input, inspected the live Signal Rat `attack_tell` animation and exact SpriteFrames/script paths, captured a non-empty `1278x718` generated-art combat frame with Cinderpaw at `67/100` HP, returned `current_run_errors=[]`, helper/data/fixture-only game logs, and no new editor rows after cursor `3`.
- Parallel review: Three design/art/QA sidecars were attempted twice but failed before execution because the backend injected unsupported `reasoning.effort=max`; bounded design, art, QA, and integration reviews completed locally.
- Blockers: None for Story137. Boss4 remains out of scope until an approved configuration and encounter contract exist. The broader game goal remains active.
- Next: commit and push Story137, then define Story138 as a bounded post-Signal-Roof traversal or savepoint beat using the completed encounter state.

## Session Extract -- /dev-story 2026-07-12

- Delivery checkpoint: Story137 was committed as `3a9664b4` (`feat: add Neon Signal Roof ambush`) and pushed to `origin/master` before Story138 delivery.
- Story: `production/epics/player-abilities/story-138-neon-rooftops-relay-spire-savepoint-traverse.md` -- Neon Rooftops Relay Spire Savepoint Traverse.
- Implementation: Expanded Neon Rooftops to `3840x720`. The Story137 signal-cache claim opens a reused access seal, then `NeonRelaySpireController` owns a generated roost savepoint, lethal-gap death/revive, magnetic-spire traversal, Tower Approach endpoint, objective priority, spawn alignment, diagnostics, and durable state while the parent scene exposes only narrow adapters. `SavepointRuntime`, `SaveTriggerAdapter`, and `GameFlowController` provide one-shot autosave, full-HP activation, a `1.5s` death beat, 50% HP roost respawn, and the existing `2.0s` revived control lock.
- Asset pipeline: Built-in image generation produced one opaque rooftop viewport and one magenta-keyed three-prop sheet. Local sampled-key matte/despill, trim, fit, and resize processing produced exact RGB `1280x720`, transparent RGBA `256x256`, `256x512`, and `256x384` runtime assets. Godot 4.7 imported all source, alpha, runtime, scene, script, and test resources; prompts, processing records, asset spec, manifest, and inventory are complete.
- Verification: Initial RED `report_1484` recorded `24` expected failures across `3` cases; focused GREEN `report_1485` passed `3/3`; the first adjacent run `report_1486` found one stale exact camera-width assertion; final Story137-138 GREEN `report_1487` passed `6/6`. Targeted headless smoke exited `0` with `neon_rooftops_relay_spire_savepoint_traverse_smoke=passed`. Godot AI MCP `2.9.1` on Godot `4.7-stable` force-reloaded `87` authored nodes, ran `145` runtime nodes, used real movement plus climb input, inspected Cinderpaw's live three-frame `wall_climb` animation at frame `1`, captured a non-empty `1278x718` generated-art traversal frame, returned `current_run_errors=[]`, and found no new editor rows after cursor `3`.
- Parallel review: Three read-only level/Godot/QA sidecars were dispatched, but the backend changed their supported effort to invalid `reasoning.effort=max` before execution. They were closed without retries; bounded design, architecture, QA, and integration review completed locally.
- Blockers: None for Story138. Central Tower and Boss4 remain out of scope until approved gate, configuration, and encounter contracts exist. The broader game goal remains active.
- Next: design Story139 as either a bounded rooftop branch or the parry/all-prerequisites Central Tower gate contract, keeping implementation and validation focused.

## Session Extract -- /dev-story 2026-07-12

- Delivery checkpoint: Story138 remains a complete, verified local change layered after pushed commit `3a9664b4`; no new commit or push was performed without a new repository-history instruction.
- Story: `production/epics/player-abilities/story-139-neon-rooftops-central-tower-parry-laser-trial.md` -- Neon Rooftops Central Tower Parry-Laser Trial.
- Design: The exploration GDD defines Central Tower as `parry` plus all prior areas, while the repository has no approved tower interior or Boss4 configuration. Story139 therefore uses Story138 traversal as proof of the implemented prerequisite chain and builds only a fourth-screen outer laser timing trial, permanent gate, and threshold endpoint.
- Implementation: Expanded Neon Rooftops to `5120x720`. `NeonTowerParryTrialController` owns Story138-gated access, exported `0.60s / 0.18s / 0.55s` pulse timing, three typed real-parry reflections, `18` miss damage, shared parry/gate audio and VFX requests, ExplorationGate collision, objectives, durable progress, and endpoint state. Lethal misses reuse Story138's existing GameFlowController and active roost for 50% HP no-loss revive.
- Asset pipeline: Built-in image generation produced an opaque `1672x941` Central Tower exterior and keyed `1774x887` gate/pulse/beacon sheet. Sampled-key matte/despill/trim processing normalized exact RGB `1280x720` and transparent RGBA `384x512`, `512x128`, and `256x384` assets. Godot 4.7 imported source, alpha, runtime, scene, script, and test resources; prompt records, asset spec, manifest, and inventory are complete.
- Verification: Initial RED `report_1488`; final focused GREEN `report_1491` passed `3/3`; final Story138-139 GREEN `report_1492` passed `6/6`. Targeted headless smoke passed with `neon_rooftops_central_tower_parry_laser_trial_smoke=passed`, covering lethal miss, roost revive, real parry input, three reflections, gate/endpoint, and restore. Intermediate `report_1489/1490` and the first smoke run exposed test-harness timing only; production rollover behavior remained unchanged.
- MCP: Session `cinderpaw@e40d`, Godot `4.7-stable`, MCP `2.9.1`. A forced disk reload exposed `108` authored nodes. Run `56` hit a stale new-class editor cache; after stopping, reimporting five related files, and scanning to `288` global classes, clean runs `57-58` exposed `145` runtime nodes. Real MCP `parry` input advanced objective `0/3 -> 1/3`, changed the pulse to cyan reflected state, and exposed Cinderpaw `AnimatedSprite2D animation=parry, frame=2` with exact SpriteFrames. The `1278x718` gameplay capture is non-empty and readable; clean runs returned `current_run_errors=[]`, final game logs were helper/data/fixture only, and editor cursor `3` gained no rows.
- Parallel review: Three read-only level/art/QA sidecars were explicitly requested with supported `high` effort, but the backend rewrote them to invalid `reasoning.effort=max`. They failed before execution, were closed once, and were not retried; bounded review completed locally.
- Blockers: None for Story139. Central Tower interior and Boss4 remain out of scope until approved design/data contracts exist. The broader game goal remains active.
- Next: define Story140 as a Central Tower threshold scene-handoff slice only after authoring its interior contract, or select another player-visible rooftop branch while that contract is absent.

## Session Extract -- /dev-story 2026-07-12

- Delivery checkpoint: Story140 was committed as `c7bb69be` (`feat: add Central Tower threshold guard`) and pushed to `origin/master` before Story141 implementation began. Story141 remains a complete verified local change; no later commit or push was performed without a new repository-history instruction.
- Story: `production/epics/player-abilities/story-141-central-tower-inner-relay-skirmish.md` -- Central Tower Inner Relay Skirmish.
- Design: Expanded the existing `area_05_central_tower` instead of inventing a new scene id or Boss4. Story140 guard clear gates one second-viewport Service Spine loop: close two shutters, parry one real relay pulse, fight one ordinary enemy, and claim one established small cache.
- Implementation: The Tower is now bounded at `2560x720`. `CentralTowerInnerRelayController` owns `0.55/0.18/0.55s` pulse timing, 8-damage misses, real strike-window parry signal handling, entity `2702`, dual shutters, objective priority, failed-attempt reset, death-window durable clear, cache persistence, and narrow parent adapters. Relay Mantis has `40` HP, data-driven `20/6/20` scythe timing, `12` damage, and shared Health/Collision/Combat/StatusEffect routing. The cache records one `+20 Gears` payload without changing abilities.
- Frame animation: Built-in image generation produced a strict keyed `3x6` Relay Mantis sheet. Chroma processing and common-anchor normalization produced eighteen transparent `96x96` frames for `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death`, wired through mandatory character/runtime scenes with `AnimatedSprite2D + SpriteFrames`.
- Asset pipeline: Built-in image generation also produced one opaque Service Spine background and one keyed five-prop sheet. Processing retained source/alpha/prompt/preview files and normalized exact RGB `1280x720` plus transparent RGBA `256x512`, `384x512`, `256x256`, `256x256`, and `512x128` runtime assets. Godot 4.7 imported the complete set; asset spec, manifest, and inventory records are complete.
- Verification: Initial RED `report_1503`; final focused GREEN `report_1507` passed `3/3`; independent read-only review and rerun `report_1508` passed `3/3`; Story140 adjacent `report_1509` passed `3/3`; targeted smoke exited `0` with `central_tower_inner_relay_skirmish_smoke=passed`. Godot AI MCP `2.9.1` on Godot `4.7-stable` force-reloaded `63` authored nodes; run `65` used real `parry` input, changed the pulse from visible strike to hidden complete, activated the live Mantis at collision `2/17`, inspected its `run` animation and exact six-by-three SpriteFrames contract, captured a non-empty `1278x718` generated-art combat frame, returned `current_run_errors=[]`, helper/data-only current logs, and no new editor row after cursor `3`.
- Parallel review: Three read-only design/art/QA agents completed bounded recommendations before implementation; a final independent read-only integration reviewer found no blocking bug or soft lock. The integrating agent owned all shared Godot files and final verification.
- Blockers: None for Story141. Boss4 identity, arena, data, phases, music, reward, and ending content remain out of scope until explicitly authored. The broader complete-game goal remains active.
- Next: define Story142 as one bounded deeper-Tower route/traversal contract that consumes `central_tower_relay_mantis_defeated` or the claimed relay cache; do not invent Boss4 yet.

## Session Extract -- /dev-story 2026-07-12

- Delivery checkpoint: Story140 remains pushed as `c7bb69be`; Story141 and Story142 are complete verified local changes. No commit or push was performed for either later story without a new repository-history instruction.
- Story: `production/epics/player-abilities/story-142-central-tower-cooling-shaft-roost-traverse.md` -- Central Tower Cooling Shaft Roost Traverse.
- Design: Expanded the existing `area_05_central_tower` to a third viewport rather than inventing Boss4 or a new scene id. Relay Mantis defeat gates one post-combat recovery/traversal loop: activate a second Roost, cross a lethal suspension gap using existing movement abilities, read and avoid a cyclic arc, then secure one bounded Deep Lift endpoint. The Story141 cache remains optional.
- Implementation: The Tower is now bounded at `3840x720`. `CentralTowerCoolingShaftController` owns route gating, `SavepointRuntime` activation, exact `0.75/0.50/0.35/0.70s` hazard timing, `10` damage with `1.0s` contact cooldown, lethal fall, endpoint, objectives, autosave/audio/VFX diagnostics, and durable state. The parent Tower controller adds only narrow proxies, save snapshot/state merge, objective priority, newest-savepoint selection, and Cooling Roost spawn alignment. Existing GameFlow supplies the `1.5s` death beat, 50% HP revive, and 120 i-frames.
- Asset pipeline: Built-in image generation produced one opaque Cooling Shaft background and one keyed `3x2` six-asset sheet. Processing retained both exact prompts, source images, the transparent alpha intermediate, and normalized runtime RGB `1280x720` plus RGBA `256x256`, `256x512`, `384x128`, `256x384`, `512x160`, and `192x192` assets. Godot 4.7 imported the complete set; asset spec, manifest, and entity inventory are complete.
- Verification: Expected RED `report_1510`; final focused GREEN `report_1513` passed `3/3`; adjacent Story140/141 plus savepoint regression `report_1514` passed `10/10`; target smoke exited `0` with `central_tower_cooling_shaft_roost_traverse_smoke=passed`. Coverage includes exact assets/geometry, Story141 gate, Roost/autosave, arc damage/cooldown, lethal fall/revive, real double-jump/dash APIs, endpoint, exact abilities, and fresh restore without feedback replay.
- MCP: Session `cinderpaw@e40d`, Godot `4.7-stable`, MCP `2.9.1`. Run `66` exposed a stale live-editor global class cache; reimporting the four Tower scripts increased the scan from `288` to `292` classes. Final run `68` exposed `94` authored and `128` runtime nodes, exact generated textures, active Roost/arc, readable objective/HUD, live Cinderpaw SpriteFrames, real `jump` frame `1`, and a real dash of about `129px`. It captured a non-empty `1278x718` generated-art gameplay frame, returned `current_run_errors=[]`, added no editor rows after cursor `3`, and stopped cleanly.
- Parallel review: Three read-only design/art/QA agents completed bounded planning before shared-file implementation. The integrating agent owned scene/controller integration and all final focused, regression, smoke, visual, and MCP verification.
- Blockers: None for Story142. Boss4 identity, arena, data, phases, music, reward, narrative, and ending remain out of scope until explicitly authored. The broader complete-game goal remains active.
- Next: define Story143 as a bounded Deep Lift or deeper-Tower handoff that consumes `central_tower_cooling_shaft_traversed`, keeping Boss4 out of implementation until its complete contract exists.

## Session Extract -- /dev-story 2026-07-12

- Delivery checkpoint: Story140 remains pushed as `c7bb69be`; Story141-143 are complete verified local changes. No commit or push was performed for Story141-143 without a new repository-history instruction.
- Story: `production/epics/player-abilities/story-143-central-tower-deep-lift-counterweight-ambush.md` -- Central Tower Deep Lift Counterweight Ambush.
- Implementation: Expanded `area_05_central_tower` to `5120x720`. `CentralTowerDeepLiftController` owns the Story142 gate, real physics-synchronized lift, lower/upper shutters, Sentry lifecycle, attempt reset, durable clear, upper endpoint, objectives, feedback, and diagnostics. Entity `2703` has data-driven `44` HP and a `24/5/24`-frame, 12-damage counterweight ram through shared combat components.
- Frame animation and assets: Image generation produced the fourth background, six transparent lift prop/VFX assets, and a strict `3x6` Sentry source. Eighteen transparent `96x96` frames provide three-frame `idle`, `run`, `attack_tell`, `attack`, `hurt`, and `death` animations through mandatory `AnimatedSprite2D + SpriteFrames` character/runtime scenes. Source, prompt, alpha, preview, spec, manifest, and inventory records are complete.
- Runtime fix: MCP Run69 found that Story142 disabled its fall zone after traversal, so a pre-clear Deep Lift death could leave the player falling forever while returning from Cooling Roost. The fall zone now remains active after traversal while the electrical arc still disables; a focused post-traversal death/revive regression covers the route.
- Verification: Expected RED `report_1516`; implementation diagnostic `report_1517`; final focused GREEN `report_1520` passed `3/3`; adjacent Story141-142 GREEN `report_1519` passed `6/6`; post-fix Story142-143 GREEN `report_1521` passed `6/6`; fresh closure regression `report_1522` again passed Story142-143 `6/6`; target smoke passed with `central_tower_deep_lift_counterweight_ambush_smoke=passed`. Godot AI MCP `2.9.1` / Godot `4.7-stable` Run73 used real `E`, movement, and `J` input, carried Cinderpaw from y `552` to `412`, damaged the live Sentry `44 -> 32`, inspected its exact SpriteFrames in `attack` frame `2`, captured the generated-art combat frame including `hurt`, returned `current_run_errors=[]`, added no editor rows after cursor `3`, and stopped cleanly.
- Blockers: None for Story143. Boss4 and the upper-Tower continuation remain out of scope until an approved contract exists. The broader complete-game goal remains active.
- Next: author the bounded upper-Tower continuation contract before Story144 implementation; do not infer Boss4 content from the current endpoint.

## Session Extract -- /story-done 2026-07-12

- Verdict: COMPLETE WITH NOTES.
- Story: `production/epics/player-abilities/story-144-central-tower-apex-conduit-purge-run.md` -- Central Tower Apex Conduit Purge Run.
- Implementation: Expanded `area_05_central_tower` to `6400x720` with a generated fifth background, Apex Roost, authored catwalk/magnetic-spine route, `0.75s` warning, deterministic `150px/s` purge wall, lethal fall, retry reset and durable Apex Approach endpoint. No Boss4, enemy, ability or reward was inferred.
- Asset pipeline: Built-in image generation produced one opaque background and one strict keyed `3x2` source. Five selected cells became transparent Roost, spine, emitter, beacon and purge-wall runtime assets; source, prompt, alpha, spec, manifest and inventory records are retained.
- Verification: RED `report_1523`; fresh focused GREEN `report_1528` passed `3/3`; fresh Story143-144 GREEN `report_1529` passed `6/6`; target smoke printed `central_tower_apex_conduit_purge_run_smoke=passed`. Focused coverage includes both purge-wall and bottom-fall lethal paths, 50% HP revive, 120 i-frames, exact abilities, endpoint and fresh restore.
- MCP: Godot `4.7-stable` / MCP `2.9.1` Run74 proved live pursuit and complete route traversal, then exposed and triggered repair of a stale global-class cache. Final Run75 returned `current_run_errors=[]`, no new editor rows after cursor `8`, live Cinderpaw `AnimatedSprite2D`, generated assets and a non-empty `1278x718` screenshot; the run stopped cleanly.
- Review: Integrator review found and closed the missing direct fall assertion. Two requested full-review agents failed before project access because the backend supplied unsupported effort `max`; no independent-agent approval is claimed.
- Tech debt logged: None. Boss4 and any later upper-Tower continuation remain blocked on an authored contract. The broader complete-game goal remains active.
- Next recommended: author the Boss4 approach/handoff or another bounded upper-Tower continuation contract before Story145 implementation.

## Session Extract -- /story-done 2026-07-12

- Delivery checkpoint: Story141-144 were committed and pushed as `a17399f2` (`feat: extend Central Tower through Apex Conduit`). Story145 is a complete verified local change; no additional commit or push was performed without a new repository-history instruction.
- Story: `production/epics/player-abilities/story-145-central-tower-crown-warden-arena-handoff.md` -- Central Tower Crown Warden Arena Handoff.
- Design: Authored Boss4 as `boss_04_crown_warden` / Crown Warden, a mechanical owl crown-defense sentinel. Story145 implements only the generated-art Crown Observatory and exact Tower round trip; it does not show a static Boss placeholder or pre-empt Story146's frame-animation/combat contract.
- Implementation: Registered `boss_04_crown_warden_arena`; added the Story144-gated Tower crown route, `apex_approach_return` at `(6200,296)`, and a bounded `1280x720` arena with existing animated Cinderpaw, floor, side walls, Camera2D, objective and return route. Retryable SceneManager failures, one-shot requests, durable state and exact ability transfer are covered.
- Asset pipeline: Built-in image generation produced a retained `1672x941` RGB observatory source and `1024x1536` keyed crown gate. Exact prompts, full gate alpha intermediate, normalized RGB `1280x720` background and transparent sRGBA `256x384` gate are imported and recorded in spec, manifest, inventory and QA evidence.
- Verification: Expected RED `report_1530`; intermediate `report_1531` was rejected because resource-loader errors remained; clean focused GREEN `report_1532` and post-MCP-visual-fix `report_1534` passed `2/2`; review hardening `report_1535` exposed and corrected a GdUnit autoload test assumption; final focused `report_1536` passed `2/2`; final Story144-145 related `report_1537` passed `5/5`; target smoke passed and exited without cleanup errors. No full suite was run.
- MCP: Session `cinderpaw@e40d`, Godot `4.7-stable`, MCP `2.9.1`. Final Run77 exposed `25` authored and `29` runtime nodes, live `Player/Sprite: AnimatedSprite2D`, no Crown Warden node, real movement x `220 -> 291.667`, generated background/gate and complete objective/return text in a non-empty `1278x718` frame. `current_run_errors=[]`, game log was helper-only, editor cursor stayed `8 -> 8`, and the run stopped cleanly.
- Review: The integrating agent fixed both a false-positive GREEN caused by stale imports and one MCP-visible clipped return prompt before closure. Parallel agents were not retried because the backend previously rejected their rewritten unsupported effort setting.
- Blockers: None for Story145. The broader complete-game goal remains active.
- Next: Story146 Crown Warden playable Boss4 core, with mandatory multi-frame character states, data-backed combat, Boss HUD, room seals, death/retry and MCP gameplay evidence. Keep reward/ending as separate authored slices.

## Session Extract -- /story-done 2026-07-13

- Delivery checkpoint: Story141-144 remain pushed as `a17399f2`; Stories145-146
  are complete verified local changes. No additional commit or push was
  performed without a new repository-history instruction.
- Story: `production/epics/player-abilities/story-146-crown-warden-playable-boss4-core.md`
  -- Crown Warden Playable Boss4 Core.
- Implementation: Added Boss4 data/schema, entity `2400`, generated eight-state
  frame animation, shared combat components, exact dive/sweep hitboxes,
  chain-safe Phase II, Boss HUD, room seals, scene lock, death retry, persistent
  victory and fresh restore. Shared `CollisionComponent` now resolves same-frame
  deferred hurtbox restoration correctly.
- Verification: RED `report_1547/1549`; focused GREEN `report_1551` passed
  `6/6`; shared collision GREEN `report_1552` passed `6/6`; bounded related
  `report_1553` passed `34/34`; target smoke marker
  `crown_warden_playable_boss4_core_smoke=passed`. No full suite was run.
- MCP: Session `cinderpaw@13e3`, Godot `4.7-stable`, MCP `2.9.1`. Final Run
  `r3362590-4` used real attack input and real Boss overlaps for exact
  `12/18/14` damage, verified pending/complete Phase II, collidable retry,
  defeat and fresh restore, captured two non-empty `1278x718` frames, returned
  helper/DataManager-only game logs and added no editor rows after cursor `4`.
- Review: Three read-only acceptance, asset and QA agents completed bounded
  reviews; the integrating agent fixed all blocking findings and owned final
  test/MCP acceptance.
- Blockers: None for Story146. The broader complete-game goal remains active.
- Next: Story147 Crown Warden `wall_climb` reward payoff. Keep ending, credits,
  cinematic transition, Boss parry reaction and arena mutation in separately
  approved bounded stories.

## Session Extract -- /story-done 2026-07-13

- Delivery checkpoint: Story141-144 remain pushed as `a17399f2`; Stories145-147
  are complete verified local changes. No additional commit or push was
  performed without a new repository-history instruction.
- Story: `production/epics/player-abilities/story-147-crown-warden-wall-climb-reward-payoff.md`
  -- Crown Warden Wall Climb Reward Payoff.
- Implementation: Boss4 death reveals a generated Crown Core through the
  shared reward source. Grounded contact consumes it once, unlocks missing
  `wall_climb` or safely confirms Story135's alternate path, presents an exact
  `1.5s` control/HUD beat, and merges abilities into arena/Tower/Main state.
- Runtime fixes: MCP exposed an unreachable 100px grounded claim and the final
  scene uses a matching 128px interaction/claim radius. Bounded regression also
  exposed `RouteTransitionShell` changing Area2D monitor state inside a physics
  signal; physics-frame changes are now deferred.
- Verification: RED `report_1554`; final focused `report_1559` passed `3/3`;
  final Story146/Story135 related `report_1558` passed `9/9`; grounded target
  smoke passed. No full suite was run.
- MCP: Session `cinderpaw@13e3`, Godot `4.7-stable`, MCP `2.9.1`, Run
  `r7762730-6`. Real `move_right` input claimed the core from the ground,
  runtime diagnostics reported `wall_climb=true` and one exact feedback beat,
  two non-empty `1278x718` captures were retained, current game logs were
  helper/DataManager-only and editor cursor stayed `4 -> 4`.
- Parallel review: Three requested read-only sidecars failed before project
  access because the backend rewrote effort to invalid `max`; bounded design,
  art and QA review was completed locally by the integrating agent.
- Blockers: None for Story147. The broader complete-game goal remains active.
- Next: author Story148 as a bounded post-Boss4 continuation contract before
  implementing ending, credits or cinematic presentation.

## Session Extract -- /story-done 2026-07-13

- Delivery checkpoint: Story141-144 remain pushed as `a17399f2`; Stories145-148
  are complete verified local changes. No additional commit or push was
  performed without a new repository-history instruction.
- Story: `production/epics/player-abilities/story-148-crown-warden-victory-recall-to-scrap-roost.md`
  -- Crown Warden Victory Recall To Scrap Roost.
- Implementation: Added one generated right-side recall transmitter after
  Boss4 defeat/reward while preserving the left Apex return. Arena persistence
  records and rolls back exact recall proof around SceneManager requests;
  MainScene accepts only complete proof at `main / scrap_roost`, moves
  Cinderpaw to the existing savepoint and records one secured return.
- Verification: Expected RED `report_1560`; final bounded GREEN `report_1564`
  passed `16/16`; target smoke printed
  `crown_warden_victory_recall_to_scrap_roost_smoke=passed`. No full suite was
  run. A realistic Main persistence fixture then reproduced the Rat King return
  in RED `report_1565`; related GREEN `report_1567` passed `13/13` after the
  restoration fix.
- MCP: Session `cinderpaw@13e3`, Godot `4.7-stable`, MCP `2.9.1`, final Run
  `r21750636-14`. Physical `E` triggered the runtime swap to
  `main / scrap_roost`; both defeated MainScene bosses, Rat King collisions and
  Boss HUD stayed inactive. Both screenshots were non-empty `1278x718`, game
  logs were helper/DataManager info only and editor cursor remained `4 -> 4`.
- Blockers: None for Story148. The broader complete-game goal remains active.
- Next: do not infer Boss5 from the current five-Boss full-concept line because
  Tier 4 defines a four-Boss degraded complete scope. Select a bounded hub
  polish/content gap or resolve that scope conflict before Story149.

## Session Extract -- /story-done 2026-07-14

- Delivery checkpoint: Story160 is complete as verified local work. No commit
  or push was performed without a repository-history instruction.
- Story: `production/epics/player-abilities/story-160-skill-tree-cat-claw-t1b-damage-choice.md`
  -- Skill Tree Cat Claw T1-B Damage Choice.
- Implementation: Added the 1 SP `Honed Claws` node, persisted unlock, current-
  weapon modifier filtering, one capped floating damage modifier across shared
  attack paths, and final-floor DamageCalculator consumption. The GDD now makes
  the T1-B F7/F9 boundary explicit and forbids registering one node on both
  tracks.
- Verification: RED `report_1672`; focused GREEN `report_1676` and final fresh
  focused `report_1679` each passed `1/1`;
  bounded related GREEN `report_1678` passed `23/23`; both skill-tree JSON files
  parse. No full suite was run.
- MCP: Session `cinderpaw@3736`, Godot `4.7-stable`, plugin/server `3.0.2`, run
  `r6401979-3`. A real `SkillUnlockButton.pressed` spent SP `1 -> 0`; real
  collision damage changed `25 -> 26`; both `1278x718` captures were non-empty,
  game logs were three info rows, editor logs were empty, and stop returned the
  editor to `ready`.
- Assets: No new visual/audio asset was needed; the slice reuses existing
  image-generated runtime art.
- Blockers: None for Story160. The broader complete-game goal remains active.
- Next: continue an approved bounded skill-tree node or another directly
  playable ACT gap; do not expand Story160 into a broad F9/weapon-upgrade
  migration.

## Session Extract -- /story-done 2026-07-14

- Delivery checkpoint: Story161 is complete as verified local work. No commit
  or push was performed without a repository-history instruction.
- Story: `production/epics/player-abilities/story-161-skill-tree-long-tail-t1b-damage-choice.md`
  -- Skill Tree Long Tail T1-B Damage Choice.
- Implementation: Added the 1 SP `Honed Tailblade` data/schema node and reused
  Story160's weapon-conditioned F7 damage path. No shared gameplay controller,
  DamageCalculator, scene, animation or asset file was changed for this slice.
- Verification: RED `report_1680`; focused GREEN `report_1681` passed `1/1`;
  bounded related GREEN `report_1683` passed `22/22`; both skill-tree JSON files
  parse. `report_1682` only exposed stale menu-index assertions and is not pass
  evidence. No full suite or redundant post-documentation focused run was used.
- MCP: Session `cinderpaw@3736`, Godot `4.7-stable`, plugin/server `3.0.2`, final
  run `r10362250-5`. A real `SkillUnlockButton.pressed` spent SP `1 -> 0`;
  the real Long Tail collision chain changed damage `37 -> 39`; both corrected
  `1278x718` captures were non-empty and visually inspected, game logs were
  three info rows, editor logs were empty, and stop returned readiness `ready`.
- Assets: No new visual/audio asset or image generation was needed. Existing
  generated Long Tail arc and runtime art were reused.
- Blockers: None for Story161. The broader complete-game goal remains active.
- Next: continue one approved bounded skill-tree node or another directly
  playable ACT gap without broad F9 or weapon-base migration.

## Session Extract -- /story-done 2026-07-14

- Delivery checkpoint: Story162 is complete as verified local work. No commit
  or push was performed without a repository-history instruction.
- Story: `production/epics/player-abilities/story-162-skill-tree-fish-bone-t1b-damage-choice.md`
  -- Skill Tree Fish Bone T1-B Damage Choice.
- Implementation: Added the 1 SP `Honed Fishbone` data/schema node and reused
  Story160's weapon-conditioned F7 damage path. No shared gameplay controller,
  DamageCalculator, scene, animation or asset file was changed for this slice.
- Verification: RED `report_1684`; focused GREEN `report_1685` passed `1/1`;
  bounded related GREEN `report_1686` passed `16/16`; both skill-tree JSON files
  parse. No full suite or redundant post-documentation focused run was used.
- MCP: Session `cinderpaw@3736`, Godot `4.7-stable`, plugin/server `3.0.2`, final
  run `r13362848-6`. A real `SkillUnlockButton.pressed` spent SP `1 -> 0`;
  the real Fish Bone collision chain changed damage `100 -> 108`; both
  `1278x718` captures were non-empty and visually inspected, game logs were
  three info rows, editor logs were empty, and stop returned readiness `ready`.
- Assets: No new visual/audio asset or image generation was needed. Existing
  generated Fish Bone wave and runtime art were reused.
- Blockers: None for Story162. The broader complete-game goal remains active.
- Next: continue one approved bounded skill-tree node or another directly
  playable ACT gap without broad F9 or weapon-base migration.

## Session Extract -- /story-done 2026-07-14

- Delivery checkpoint: Story163 is complete as verified local work. No commit
  or push was performed without a repository-history instruction.
- Story: `production/epics/player-abilities/story-163-crown-warden-phase-two-transition-readability.md`
  -- Crown Warden Phase II Transition Readability.
- Implementation: Crown Warden now waits for the active attack chain to finish,
  then runs one 2.5-second Phase II transition with movement/attacks paused,
  `hurt` animation, `gone` Hurtbox, rejected damage, Phase II HUD, existing
  overlay/debris and `sfx_boss_phase`. The exact 2.50-second boundary restores
  normal collision and combat.
- Verification: RED `report_1687`; focused GREEN `report_1688` passed `1/1`;
  bounded Boss4 related GREEN `report_1689` passed `15/15`; target smoke printed
  `crown_warden_phase_two_transition_feedback_smoke=passed`. No full suite or
  redundant post-documentation focused run was used.
- MCP: Session `cinderpaw@3736`, Godot `4.7-stable`, plugin/server `3.0.2`, final
  run `r18107187-8`. Runtime diagnostics proved the 2.5-second invulnerable
  window, one transition signal, 32 debris pieces, HUD/audio routing and exact
  recovery boundary. The `1278x718` capture was non-empty and visually checked;
  game logs were three info rows, editor logs were empty, and stop returned
  readiness `ready`.
- Assets: No new image or audio asset was needed. Existing generated phase
  overlay/debris, Crown Warden `hurt` frames and phase SFX were reused.
- Parallel review: Read-only design, QA and technical-art review informed slice
  selection and acceptance. The integrating agent rejected an undefined final
  route expansion, owned all edits/tests/MCP validation, and retained the
  technical-art finding that the existing full-screen phase overlay obscures
  the combat center too long.
- Blockers: None for Story163. The broader complete-game goal remains active.
- Next: isolate the Boss phase overlay center-clear/short-fade correction in
  Combat Presentation without reopening the verified phase-state logic.

## Session Extract -- /story-done 2026-07-14

- Delivery checkpoint: Combat Presentation Story019 is complete as verified
  local work. No commit or push was performed without a repository-history
  instruction.
- Story: `production/epics/combat-presentation/story-019-boss-phase-overlay-readability.md`
  -- Boss Phase Overlay Readability.
- Implementation: Replaced the runtime phase image with a generated steel-blue
  edge frame whose center `640x360` pixels are hard-cleared to alpha zero. One
  CanvasLayer/TextureRect fades linearly and exits at `0.40s`; 32 existing metal
  debris pieces continue independently to `1.50s`; HUD remains on layer `1`
  above the effect's layer `0`.
- Verification: Clean RED `report_1690`; focused GREEN `report_1692` passed
  `1/1`; bounded related GREEN `report_1693` passed `40/40`; target Crown Warden
  smoke printed `crown_warden_phase_two_transition_feedback_smoke=passed`.
  `report_1691` is rejected because it emitted a pre-import ResourceLoader
  error. No full suite or redundant post-documentation test was used.
- MCP: Fresh session `cinderpaw@af5f`, Godot `4.7-stable`, plugin/server
  `3.0.2`, run `r22854-1`. Runtime diagnostics proved Phase II `80/160`, one
  loaded overlay, 32 debris, `0.39/0.41/1.51s` boundaries, HUD ordering, and
  three-frame player/Boss animation states. The `1278x718` screenshot is
  non-empty and visually inspected; game logs are three info rows, editor logs
  are empty, and stop returned readiness `ready`.
- Assets: Retained keyed source, alpha intermediate, runtime PNG and exact
  generation/processing spec. Godot imported all three PNGs; final center alpha
  min/max/mean are zero.
- Parallel review: Independent read-only design and QA reviews selected the
  bounded Presentation correction and validation scope. The integrating agent
  owned image processing, code, tests, MCP acceptance and final evidence.
- Blockers: None for Story019. The broader complete-game goal remains active.
- Next: select the next bounded player-visible ACT gap from current GDD/Story
  state; do not reopen the verified Boss phase transition or overlay timing
  without new evidence.

## Session Extract -- /story-done 2026-07-14

- Delivery checkpoint: Story164 is complete as verified local work. No commit
  or push was performed without a repository-history instruction.
- Story: `production/epics/player-abilities/story-164-skill-tree-electro-bell-t1b-damage-choice.md`
  -- Skill Tree Electro Bell T1-B Damage Choice.
- Implementation: Added the 1 SP `Honed Bell` data/schema node and reused
  Story160's weapon-conditioned F7 damage path. No shared gameplay controller,
  DamageCalculator, scene, animation or asset file changed for this slice.
- Verification: RED `report_1694`; focused GREEN `report_1696` passed `1/1`;
  bounded related GREEN `report_1697` passed `13/13`; both skill-tree JSON files
  parse. No full suite or redundant post-documentation focused run was used.
- MCP: Session `cinderpaw@af5f`, Godot `4.7-stable`, plugin/server `3.0.2`, final
  run `r3330877-4`. A real `SkillUnlockButton.pressed` spent SP `1 -> 0`; the
  real Electro Bell collision chain changed damage `30 -> 31`; both corrected
  `1278x718` captures are non-empty and visually inspected, game logs are three
  info rows, editor logs are empty, and stop returned readiness `ready`.
- Assets: No new visual/audio asset or image generation was needed. Existing
  generated Electro Bell arc and runtime art were reused.
- Parallel review: Read-only design review selected this bounded gap. QA review
  also reproduced a Story019 overlay crop; that visible defect is the next
  repair and supersedes the old "do not reopen without evidence" note.
- Blockers: None for Story164. The broader complete-game goal remains active.
- Next: reopen only Story019's runtime layout acceptance, fix the doubled
  full-rect offsets, and preserve its verified 0.40/1.50-second timing.

## Session Extract -- Story019 layout repair 2026-07-14

- Correction checkpoint: Combat Presentation Story019 was reopened only for a
  reproduced runtime layout defect; no commit or push was performed.
- Root cause: `PRESET_FULL_RECT` anchors plus positive right/bottom offsets
  `1280/720` doubled `BossPhaseOverlay` to `2560x1440` and cropped its right and
  bottom edge. Run1 remains timing/transition evidence, but its screenshot is
  explicitly superseded for layout acceptance.
- Implementation: Kept full-rect anchors and changed all four offsets to `0`.
  Overlay fade `0.40s`, debris `1.50s`, phase state, assets and layer ordering
  were unchanged.
- Verification: Repair RED `report_1698` reproduced `2560x1440`; focused GREEN
  `report_1699` passed `1/1`; related GREEN `report_1700` passed `39/39`.
- MCP: Godot `4.7-stable`, MCP plugin/server `3.0.2`, session
  `cinderpaw@af5f`, final run `r7097860-5`. Real Main Rat King Phase II produced
  position `(0,0)`, rect/texture/viewport `1280x720`, anchors `[0,0,1,1]`, four
  zero offsets and overlay/debris `1/32`. The repaired `1278x718` screenshot
  shows all four edges and a readable combat center; logs were three info rows,
  editor logs were empty, and stop returned `ready`.
- Blockers: None. The broader complete-game goal remains active.
- Next: select the next bounded player-visible ACT gap from current GDD/Story
  evidence; preserve the repaired phase overlay layout and timing.

## Session Extract -- Story165 2026-07-14

- Delivery checkpoint: Player Abilities Story165 is complete as verified local
  work. No commit or push was performed without a repository-history
  instruction.
- Story: `production/epics/player-abilities/story-165-boss2-echo-guardian-attack-tell-frame-animation-runtime.md`
  -- Echo Guardian Attack Tell Frame Animation Runtime.
- Implementation: Added a generated non-looping three-frame `attack_tell` to
  the existing Echo Guardian `AnimatedSprite2D + SpriteFrames`. Startup now
  uses the coil-up tell and holds its last frame through Focus-extended startup;
  active frames keep the existing `attack` and unchanged hitbox/gameplay data.
- Verification: RED `report_1701`; hold regression RED `report_1704`; focused
  GREEN `report_1705` passed `1/1`; bounded related GREEN `report_1708` passed
  `16/16`. `report_1706` was rejected as loop-sampling-sensitive and isolated
  `report_1707` passed `6/6` before the assertion was corrected. No full suite
  or redundant post-documentation test was used.
- MCP: Godot `4.7-stable`, MCP plugin/server `3.0.2`, session
  `cinderpaw@af5f`, final run `r12850599-8`. Real Main handoff proved Focus
  startup `14`, `attack_tell` frame `2` hold with inactive hitbox, then active
  `attack` with active hitbox. Both `1278x718` screenshots are non-empty and
  visually distinct; game logs are three info rows, editor logs are empty, and
  stop returned `ready`.
- Assets: Retained generated source, alpha source, JSON prompt/processing
  metadata and three transparent `160x128` runtime frames under the required
  character animation path. Godot imported all new PNGs.
- Parallel review: Design and QA read-only reviews constrained the slice to
  presentation-only state mapping and thin verification. Technical-art review
  confirmed exact canvas size, alpha and shared foot baseline, while recording
  the existing project-level pixel-filter/resource-budget debt. The integrating
  agent accepted the authored 12px visible centroid change after reviewing the
  fixed pivot and final runtime captures, and owned all edits and acceptance.
- Blockers: None for Story165. The broader complete-game goal remains active.
- Next: select the next bounded player-visible ACT gap; preserve Echo Guardian
  combat timing, hitbox, phase, audio, save and reward contracts.

## Session Extract -- Story166 2026-07-14

- Delivery checkpoint: Player Abilities Story166 is complete as verified local
  work. No commit or push was performed without a repository-history
  instruction.
- Story: `production/epics/player-abilities/story-166-cinderpaw-real-input-three-stage-light-combo-runtime.md`
  -- Cinderpaw Real-Input Three-Stage Light Combo Runtime.
- Implementation: Real `attack` InputMap presses now enter Core recovery-window
  chaining and drive stages `0/1/2`. Player presentation follows Core totals
  `12/18/30` and maps to generated `attack/attack_2/attack_3`; hold input does
  not auto-chain, stage 3 cannot restart a fourth stage, and a completed chain
  starts again at stage 0. Existing light-hitbox timing remains unchanged.
- Verification: RED `report_1709`; final focused GREEN `report_1713` passed
  `2/2`; bounded related GREEN `report_1714` passed `20/20` across six directly
  related suites. No full suite or redundant post-documentation test was used.
- MCP: Godot `4.7-stable`, plugin/server `3.0.2`, session `cinderpaw@af5f`, run
  `r55211566-9`. Real Main input reached `attack_2` and `attack_3`; a fourth
  press advanced Core frame `12 -> 13` without restart; post-chain input reset
  to `combo 0`. Both `1278x718` captures were non-empty and visually checked;
  game logs were three info rows, editor logs were empty, and stop returned
  readiness `ready`.
- Assets: Retained generated `1254x1254` RGB source, RGBA alpha intermediate,
  prompt/processing metadata, and nine transparent `96x96` runtime frames. All
  alpha bounds share `y=88`; Godot imported the new files; Cinderpaw now uses
  Nearest filtering.
- Parallel review: Design, QA, and technical-art read-only reviews identified
  the unreachable real-input combo and constrained the slice. The integrating
  agent owned code, asset processing, tests, MCP acceptance, and final evidence.
- Blockers: None for Story166. The broader complete-game goal remains active.
- Next: select the next bounded player-visible ACT gap. Keep authored
  animation-frame hitbox timing as a separate collision/balance Story rather
  than silently changing Story166's preserved combat contract.

## Session Extract -- Story167 2026-07-15

- Delivery checkpoint: Player Abilities Story167 is complete as verified local
  work. No commit or push was performed without a repository-history instruction.
- Story: `production/epics/player-abilities/story-167-cinderpaw-authored-three-stage-light-hitbox-timing.md`
  -- Cinderpaw Authored Three-Stage Light Hitbox Timing.
- Implementation: Replaced the immediate fixed six-frame light hitbox with
  authored `4/4/4`, `6/6/6`, and `10/10/10` startup/active/pure-recovery
  windows. Core frame signals now schedule activation; active-period presses
  queue until contact ends; light animation frames `0/1/2` are driven by the
  same phases. Baseline damage `10`, cat energy `+5`, duplicate suppression,
  skill metadata and other action states remain unchanged.
- Verification: Initial timing RED `report_1715`; MCP-driven visual-sync RED
  `report_1725`; final focused GREEN `report_1730` passed `3/3`; bounded related
  GREEN `report_1731` passed `34/34` across nine suites. No full suite or
  redundant post-documentation test was used.
- MCP: Godot `4.7-stable`, plugin/server `3.0.2`, session `cinderpaw@af5f`, final
  run `r59179809-12`. Stage boundaries proved sprite/hitbox `0/false -> 1/true`
  at Core frames `4`, `6`, and `10`; active inputs queued successfully. The
  `1278x718` screenshot is non-empty and visually inspected; game logs contain
  three info rows, editor logs are empty, and stop returned readiness `ready`.
- Assets: No new generation or import was needed; Story166's existing generated
  `attack`, `attack_2`, and `attack_3` character frames were reused.
- Parallel review: Read-only design, technical-art and QA reviews established
  the phase windows, asset reuse and bounded validation scope. The integrating
  agent owned code, tests, MCP acceptance and final evidence.
- Blockers: None for Story167. The broader complete-game goal remains active.
- Next: select the next bounded player-visible ACT gap; preserve Story167's
  verified phase-driven light timing unless new runtime evidence requires change.

## Session Extract -- Combat Presentation Story020 2026-07-15

- Delivery checkpoint: Combat Presentation Story020 is complete as verified
  local work. No follow-up commit or push was performed after the requested
  pre-Story upload.
- Story: `production/epics/combat-presentation/story-020-cat-claw-combo-finisher-impact-feedback.md`
  -- Cat Claw Combo Finisher Impact Feedback.
- Implementation: `CombatPresentation` now consumes confirmed Cat Claw light
  `combo_index/combo_stage=2` metadata. A non-critical third hit requests five
  feedback frames, `4px/5-frame` shake, one gold `28px` damage number, one gold
  `终结` Label and existing hit sparks at `1.5x`; critical feedback keeps higher
  priority. Damage, cat energy, hitbox timing, animation and input are unchanged.
- Verification: expected RED `report_1732`; focused GREEN `report_1733` passed
  `1/1`; Presentation and critical-priority GREEN `report_1734` passed `35/35`;
  bounded authored-timing/real-input/Main regression `report_1735` passed `9/9`.
  No full suite or redundant post-documentation test was used.
- MCP: Godot `4.7-stable`, plugin/server `3.0.2`, session `cinderpaw@af5f`, run
  `r62054889-14`. The live Main chain produced combo `2`, damage `18`, Enemy HP
  `300 -> 282`, Cat Energy `0 -> 12`, `attack_3` frame `1`, feedback `5 / 4.0/5`,
  gold `28px` damage, visible gold `终结`, and actual spark scale `1.5`. The
  `1278x718` screenshot is non-empty and visually inspected; game logs are three
  info rows, editor logs are empty, and stop returned readiness `ready`.
- Assets: No new image/audio generation or import. Existing hit spark and
  Story166 `attack_3` frames were reused; both new texts are runtime Labels.
- Blockers: None for Story020. The broader complete-game goal remains active.
- Next: implement real gameplay-wide hitstop freezing with buffered input as a
  separate architecture-bounded Story; do not reopen Story167 timing or Story020
  visual values while doing so.

## Session Extract -- Combat Presentation Story021 2026-07-15

- Delivery checkpoint: Combat Presentation Story021 is complete for the Main
  playable scene as verified local work. No follow-up commit or push was
  performed after the requested pre-Story upload.
- Story: `production/epics/combat-presentation/story-021-main-scene-real-hitstop-input-buffer.md`
  -- Main Scene Real Hitstop + Input Buffer.
- Implementation: CombatPresentation can now freeze pausable gameplay for an
  exact physics-frame count while processing in ALWAYS mode and restoring the
  prior pause state. Main places InputManager into BUFFERING, captures trigger
  actions during the freeze, releases at most one action through
  PlayerController, and disconnects the duplicate direct CombatComponent route
  so Core and presentation advance exactly once.
- Verification: clean expected RED `report_1737`; focused GREEN `report_1746`
  passed `1/1`; bounded related `report_1747` passed `68/68` across nine
  executed suites; corrected parry regression `report_1748` passed `5/5`.
  No full suite or redundant post-documentation test was used.
- MCP: Godot `4.7-stable`, plugin/server `3.0.2`, session `cinderpaw@af5f`,
  final valid run `r65195448-16`. A real Main collision changed Enemy HP
  `300 -> 290`, froze gameplay for three completed frames, buffered one attack
  for `36ms`, dispatched it once, advanced the combo to stage `1`, restored
  DIRECT input and left game/editor logs clean. The `1278x718` screenshot is
  non-empty and shows the existing Cinderpaw/Rat King game art.
- Assets: No new visual/audio asset or image generation was needed. Existing
  Cinderpaw SpriteFrames and combat feedback resources were reused.
- Scope: Story021 is Main-only. Combat Presentation is now In Progress rather
  than globally Complete because Crown Warden Arena and any other independent
  player-facing CombatPresentation owner still need the same runtime handoff.
- Blockers: None for Story021. The broader complete-game goal remains active.
- Next: implement Story022 as reusable or Crown Warden-specific hitstop/input
  integration, with thin TDD and one MCP runtime acceptance in that arena.

## Session Extract -- Combat Presentation Story022 2026-07-15

- Delivery checkpoint: Combat Presentation Story022 is complete for Main and
  Crown Warden Arena as verified local work. No commit or push was performed.
- Story: `production/epics/combat-presentation/story-022-reusable-hitstop-input-bridge-crown-warden.md`
  -- Reusable Hitstop Input Bridge + Crown Warden Arena.
- Implementation: Extracted Main's freeze/input handoff into
  `HitstopInputBridge`, integrated Crown Warden Arena, and made
  CombatComponent carry `damage_applied/damage_was_applied`. Player and Crown
  now emit ordinary hit presentation only when damage actually applies, so
  dodge/parry/phase rejection cannot create false damage feedback.
- Verification: Initial RED `report_1750`; review-hardening RED `report_1759`;
  focused GREEN `report_1761` passed `3/3`; bounded related `report_1762`
  passed `93/93` across fourteen suites; final focused `report_1763` passed
  `3/3`. `report_1760` is rejected because its dodge setup had not entered the
  authored i-frame. No full suite was run.
- MCP: Godot `4.7-stable`, plugin/server `3.0.2`, session `cinderpaw@af5f`, run
  `r68236156-17`. Player hit changed Boss HP `160 -> 148`, buffered one attack,
  dispatched once and advanced to the second hit (`136` HP). Real wing sweep
  changed Player HP `100 -> 86`. Both paths completed exactly three hitstop
  frames, restored DIRECT input, used visible three-frame AnimatedSprite2D
  characters, produced non-empty `1278x718` screenshots and clean logs.
- Assets: No image/audio generation or import. Existing Cinderpaw/Crown Warden
  SpriteFrames, Crown Observatory environment, HUD and VFX were reused.
- Parallel review: Design and QA required true bidirectional collision and
  rejection-path coverage; art review confirmed existing generated assets were
  sufficient. The integrating agent owned all edits, tests and MCP acceptance.
- Scope: Combat Presentation remains In Progress because independent combat
  scenes outside Main and Crown Warden still need the reusable bridge.
- Blockers: None for Story022. The broader complete-game goal remains active.
- Next: select the next bounded player-visible ACT gap without reopening the
  verified Main/Crown hitstop values or single-dispatch contract.

## Session Extract -- Combat Presentation Story023 2026-07-15

- Delivery checkpoint: Combat Presentation Story023 is complete for Sluice
  Matriarch Arena and uploaded in commit `c027cb90`.
- Story: `production/epics/combat-presentation/story-023-sluice-matriarch-real-hitstop-input-buffer.md`
  -- Sluice Matriarch Arena Real Hitstop + Input Buffer.
- Implementation: Mounted one shared `CombatPresentation` and
  `HitstopInputBridge`, routed real player/Boss hits to presentation and audio,
  suppressed ordinary feedback when Boss damage is rejected, and forwarded the
  existing player parry event with current AnimatedSprite2D frame data. Boss3
  phase, reward, route, damage, and timing rules remain unchanged.
- Verification: Initial RED `report_1765`; initial GREEN `report_1767` passed
  `3/3`; related fixture RED/GREEN `report_1768` and `report_1769`; PERFECT
  parry RED/GREEN `report_1770` and `report_1771`; final bounded related
  `report_1772` passed `50/50` across six suites; fresh completion focused
  `report_1773/report_1` passed `4/4` with exit `0` and only the known GdUnit
  exit cleanup notice. Godot 4.7 headless editor load exited `0`; no full suite
  was run.
- MCP: Godot `4.7-stable`, plugin/server `3.0.2`, session `cinderpaw@af5f`,
  final run `r74236222-21`. Real Cat Claw changed Boss HP `120 -> 108`, buffered
  and dispatched one attack, and completed three hitstop frames. Real pressure
  lunge changed Player HP `100 -> 84`, recorded actual damage `16`, and completed
  the same freeze. Player and Boss AnimatedSprite2D nodes were visible; all six
  Boss animations had three frames; two `1278x718` screenshots were non-empty;
  final game/editor logs were clean.
- Diagnostic note: An intermediate probe called `respawn_at()` and immediately
  attacked into the authored `120` respawn i-frames. MCP confirmed
  `iframe_remaining=120`; a clean vulnerable-state run then verified the real
  Boss hit. No production respawn or damage rule was changed.
- Assets: No image/audio generation or import. Existing Cinderpaw/Sluice
  Matriarch SpriteFrames, arena environment, HUD and VFX were sufficient.
- Parallel review: Design, technical-art and QA read-only reviews agreed on
  bidirectional real collision, single dispatch, dodge rejection, PERFECT parry
  preservation, and reuse of existing art. The integrating agent owned edits,
  tests, runtime acceptance and documentation.
- Scope: Combat Presentation remains In Progress because other independent
  combat scenes still require the shared bridge. The complete-game goal remains
  active.
- Blockers: None for Story023.

## Session Extract -- Combat Presentation Story024 2026-07-15

- Delivery checkpoint: Combat Presentation Story024 is complete for Central
  Tower as verified local work. It follows uploaded Story023 commit `c027cb90`
  and stays isolated from report/tmp noise.
- Story: `production/epics/combat-presentation/story-024-central-tower-real-hitstop-input-buffer.md`
  -- Central Tower Real Hitstop + Input Buffer.
- Implementation: Mounted one shared `CombatPresentation` and
  `HitstopInputBridge` in Central Tower, routed player and all three enemy
  landed-hit signals through the scene owner, and made the shared RatMinion
  enemy chain suppress ordinary presentation when Health rejects damage.
  Player/Guard real damage, PERFECT parry, dodge/respawn i-frames, encounter
  pacing, route state, rewards, and authored frame timing otherwise stay intact.
- Verification: Initial RED `report_1774/report_1` had `2` expected failures;
  focused GREEN `report_1779` passed `6/6`; final bounded related
  `report_1787` passed `66/66` across nine suites; MCP warning-cleanup regression
  `report_1788` passed `6/6`; fresh completion focused `report_1789` passed
  `6/6` with exit `0`. No full suite or redundant broad rerun was used.
- MCP: Godot `4.7-stable`, plugin/server `3.0.2`, session `cinderpaw@af5f`.
  Functional run `r81591668-24` verified Guard `48 -> 36`, Player `100 -> 86`,
  exact three-frame hitstop, one buffered dispatch, respawn rejection, one
  presentation/bridge, multi-frame Player/Guard/Mantis/Sentry animations, clean
  logs and a non-empty `1278x718` screenshot. Final reload run `r82274190-25`
  removed all editor warnings and stopped with readiness `ready`.
- Assets: No image/audio generation or import. Existing generated Cinderpaw,
  Central Tower enemy, environment, HUD, audio and VFX assets were reused.
- Performance boundary: Final clean MCP sample was about `120 FPS` and `398`
  draw calls. The route remains playable, but its existing draw-call cost is a
  separate performance debt; Story024 does not claim that budget as passing.
- Parallel review: Design, technical-art and QA read-only reviews selected the
  Central Tower gap, confirmed existing assets were sufficient, and bounded
  acceptance to real collision and shared-handler behavior. The integrating
  agent owned edits, test correction, MCP acceptance and documentation.
- Blockers: None for Story024. The broader complete-game goal remains active.
- Next after this isolated checkpoint: select the next bounded player-visible
  ACT gap without reopening the verified hitstop values.

## Session Extract -- Combat Presentation Story025 2026-07-15

- Delivery checkpoint: Combat Presentation Story025 is complete as verified
  local work on top of uploaded Story024 commit `85aee81e`; report/tmp noise
  remains excluded from the isolated change set.
- Story: `production/epics/combat-presentation/story-025-crown-warden-victory-death-presentation-hold.md`
  -- Crown Warden Victory Death Presentation Hold.
- Implementation: Boss4 durable defeat now persists immediately while a
  transient `2.0s` hold keeps its three-frame `death` visible, hitboxes off,
  player/room/scene locks active, and reward/return/recall unavailable. The
  existing kill profile supplies six hitstop frames and 18 debris; completion
  releases the arena and spawns one reward reveal. Loaded defeat state does not
  replay transient timing or VFX.
- Verification: Initial RED `report_1790` failed only on the two missing
  Story025 APIs; focused GREEN `report_1791` passed `1/1`; bounded Boss4 core,
  reward, recall, and hitstop regressions `report_1792` through `report_1795`
  passed `15/15`, for `16/16` total. `git diff --check` passed. No full suite or
  repeated broad test pass was used.
- MCP: Godot `4.7-stable`, plugin/server `3.0.2`, session `cinderpaw@af5f`, run
  `r86792500-26`. Runtime lethal probe verified pending `2.0`, three death
  frames, zero hitboxes, six hitstop frames, 18 debris, locked arena, delayed
  reward/routes, one post-hold reveal, non-empty `1278x718` screenshot, clean
  game logs, and stopped editor readiness `ready`.
- Assets: No image/audio generation or import. Existing Crown Warden
  AnimatedSprite2D/SpriteFrames, Observatory, Wall Climb reward, HUD and combat
  VFX were sufficient; no placeholder character art was added.
- Parallel review: Game design prioritized the Boss4 victory climax over
  another bridge-only scene; technical-art confirmed the existing death frames
  were production-usable; QA bounded regressions. The integrating agent owned
  implementation, tests, MCP acceptance and documentation.
- Scope: This closes the Boss4 death-to-reward presentation beat but does not
  claim a fifth Boss or final ending. The complete-game goal and Combat
  Presentation Epic remain active.
- Blockers: None for Story025.
- Next after this isolated checkpoint: prioritize the next player-visible ACT
  gap, with Neon Rooftops and Underground Passage as bounded candidates.

## Session Extract -- Combat Presentation Story026 2026-07-15

- Delivery checkpoint: Combat Presentation Story026 is complete as verified
  local work on top of uploaded Story025 commit `3eec7f2d`; report/tmp noise and
  the unrelated generated Story025 test UID remain excluded.
- Story: `production/epics/combat-presentation/story-026-neon-rooftops-combat-impact.md`
  -- Neon Rooftops Combat Impact.
- Implementation: Mounted one shared `CombatPresentation` and
  `HitstopInputBridge`, routed real Cat Claw and Signal Rat landed hits through
  scene presentation/audio, added one-shot lethal feedback, forwarded Tower
  laser PERFECT parry frame data, exposed focused diagnostics, and reconfigured
  the bridge when a cached scene instance is reattached.
- Verification: Initial RED `report_1796` had 11 expected failures across six
  cases; focused GREEN `report_1798` passed `6/6`; Tower laser and shared
  hitstop passed `3/3` each in `report_1801`; corrected Signal Rat timing passed
  `3/3` in `report_1802`; fresh Godot 4.7 completion gate `report_1803`
  passed Story026 `6/6` with exit `0`. Full suite was not run.
- MCP: Godot `4.7-stable`, plugin/server `3.0.2`, session `cinderpaw@af5f`.
  Real Cat Claw changed Signal Rat HP `36 -> 24` with three hitstop frames, six
  sparks, one damage number and buffering input. Tower laser PERFECT parry used
  eight frames, 22 sparks, one flash and one gold afterimage with no damage
  number. Both `1278x718` screenshots were non-empty and showed Cinderpaw,
  authored Neon environments/HUD, and the target combat feedback. Final run
  `r90548920-30` had clean game logs; two unrelated Relay Spire shadow warnings
  remain documented in QA evidence.
- Assets: No image/audio generation or import. Existing Cinderpaw, six
  three-frame Signal Rat animations, Neon environment, HUD, audio and combat
  VFX were sufficient; no placeholder character art was added.
- Parallel review: Game design selected the rooftop impact gap, technical-art
  confirmed the existing Signal Rat assets were production-usable, and QA
  identified cached-scene reconnection as the highest hidden risk. The
  integrating agent owned all edits, runtime probes, test corrections and final
  verification.
- Scope: Combat Presentation remains In Progress because other independent
  scenes, including Underground Passage, still need player-facing coverage.
  The complete-game goal remains active.
- Blockers: None for Story026.

## Session Extract -- Combat Presentation Story027 2026-07-15

- Delivery checkpoint: Combat Presentation Story027 is complete for Underground
  Passage as verified local work on top of uploaded Story026 commit `3baea7ce`;
  report/tmp noise and the unrelated generated Story025 test UID remain excluded.
- Story: `production/epics/combat-presentation/story-027-underground-passage-combat-impact.md`
  -- Underground Passage Combat Impact.
- Implementation: Mounted one shared `CombatPresentation` and
  `HitstopInputBridge`; routed Cat Claw, both Sluice Leech, and Cistern Stalker
  landed hits through scene presentation/audio; connected PERFECT parry frame
  data; preserved one-shot lethal feedback; and made cached reentry ignore freed
  enemy references. The existing Leech damage calculator adapter is now wired,
  so its authored `11` damage lunge resolves through the real collision chain.
- Verification: Initial RED `report_1804` had 14 expected failures across six
  cases; initial GREEN `report_1808` passed `6/6`; review-hardening RED
  `report_1814` reproduced missing parry feedback and a freed-instance runtime
  error; final focused `report_1815` passed `7/7`; final corrosion/Stalker
  related regression `report_1816` passed `6/6`. Final focused/related total is
  `13/13`; full suite was not run.
- MCP: Godot `4.7-stable`, plugin/server `3.0.2`, session `cinderpaw@af5f`.
  Both Leech lunge paths applied `11` damage with three-frame hitstop. PERFECT
  parry used eight frames, 22 sparks, one flash and one gold afterimage with no
  damage. Final run `r92976327-34` killed Stalker `12 -> 0` with six-frame
  hitstop, six sparks, 18 debris and one kill event. Two `1278x718` screenshots
  were non-empty; final game log had no error and stop restored editor `ready`.
  Two unrelated Recovery Cistern shadow warnings remain documented.
- Assets: No image/audio generation or import. Existing Cinderpaw, Leech,
  Stalker, four-view Underground environment, HUD, audio and combat VFX were
  sufficient; all visible characters remain multi-frame SpriteFrames.
- Parallel review: Game design selected this as the smallest high-value ACT
  gap; technical art confirmed no new assets were required and recorded later
  character/environment polish debt; QA found the parry and freed-reference
  lifecycle risks. The integrating agent owned implementation, tests, MCP and
  documentation.
- Scope: Combat Presentation remains In Progress because other independent
  scenes still need coverage. The complete-game goal remains active.
- Blockers: None for Story027.
