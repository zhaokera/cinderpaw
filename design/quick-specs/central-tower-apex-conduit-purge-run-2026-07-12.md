# Quick Design Spec: Central Tower Apex Conduit Purge Run

> **Status**: Approved for bounded implementation
> **Type**: Addition
> **Story**: 144
> **System**: Central Tower traversal / save-respawn / environmental hazard
> **GDD Reference**: `design/gdd/exploration-ability-gating.md`,
> `design/gdd/player-abilities.md`, `design/gdd/death-respawn.md`
> **Date**: 2026-07-12

## 问题

Story143 让玩家乘坐 Deep Lift 抵达中央塔上层，但当前终点后没有可玩的
上层路线。仓库也没有获批的 Boss4 身份、配置、竞技场、奖励或叙事合同，不能
凭“五个区域、五个 Boss”的远期概念直接制作 Boss4。

## 决策

把 `area_05_central_tower` 从四个扩展到五个 `1280x720` 视口，增加一段
短促的环境追逐：玩家先激活 Apex Roost，再触发从左向右推进的净化墙，利用
已有 `double_jump`、`dash`、`wall_climb` 穿过导管平台，最终激活 Apex
Approach Beacon。该切片不新增能力、敌人或 Boss。

1. 只有 `central_tower_deep_lift_ascended=true` 才显示并开放 Apex Roost。
2. 玩家在 `(5260,252)` 附近激活 Roost 后，记录最新复活点并自动保存一次。
3. 玩家越过 x `5360` 后进入 `0.75s` 警告；随后净化墙从 x `5200` 以
   `150px/s` 向右推进。
4. 净化墙接触和底部坠落都是致死伤害，统一走既有 GameFlow 的 `1.5s`
   死亡节拍、50% HP 复活和 120 i-frames。
5. 死亡后保留已激活 Roost 和 Story140-143 的耐久状态，但重置净化墙、警告、
   当前追逐进度和临时反馈；玩家在 Apex Roost 重试。
6. 玩家在净化墙启动后的当前尝试中抵达 `(6280,296)`，可激活
   `central_tower_apex_approach_endpoint`。完成后持久化
   `central_tower_apex_approach_secured=true`，关闭净化墙并显示
   `Apex Approach Secured`。
7. fresh restore 恢复 Roost/终点状态且不重放 autosave、audio、VFX 或完成反馈。

## 稳定合同

| Contract | Value |
|----------|-------|
| Scene id / path | `area_05_central_tower` / `res://scenes/areas/central_tower_threshold.tscn` |
| Expanded scene size | `6400x720` |
| Route prerequisite | `central_tower_deep_lift_ascended` |
| Controller | `CentralTowerApexPurgeController` |
| Roost | `central_tower_apex_roost` / spawn `(5260,252)` |
| Trigger | x `5360`, warning `0.75s` |
| Purge wall | start x `5200`, speed `150px/s`, lethal contact |
| Endpoint | `central_tower_apex_approach_endpoint` at `(6280,296)` |
| Durable completion | `central_tower_apex_approach_secured` |

## 关卡几何

- 第五背景中心：`(5760,360)`。
- 入口上层甲板：x `5120..5440`，表面 y `276`。
- 下层导管踏板：x `5500..5700`，表面 y `470`。
- 磁性攀爬脊柱：中心 `(5770,370)`，碰撞 `48x320`。
- 上层导管踏板：x `5820..6060`，表面 y `270`。
- 终点甲板：x `6140..6400`，表面 y `320`。
- 坠落区：x `5440..6400`，中心 y `680`。
- TopBoundary 宽度、中心、RightBoundary 和 Camera2D 右边界分别更新为
  `6400`、x `3200`、x `6420` 和 `6400`；Story140-143 的节点和坐标不变。

这些跨度刻意保持在现有移动能力的可达范围内：入口可直接下落到踏板，踏板
紧邻可攀爬脊柱，上层到终点只需要普通跳跃或 dash，不增加新的移动规则。

## 视觉方向

- 背景是一条接近塔冠的横向维护导管：冷黑钢、青色电流和少量安全琥珀，
  远处能看到城市但不能构成 Boss arena。
- Apex Roost 使用紧凑的猫形机械栖点轮廓，与 Cooling Roost 同族但有更高层级
  的青白核心。
- 磁性脊柱必须清楚表达“可攀爬”；发射器位于左侧，终点信标位于右侧。
- 净化墙是透明背景的纵向电离能量幕，边缘清晰、核心半透明，不能遮满玩家
  前方视野，也不能包含文字或角色。
- 所有新增运行时视觉素材由 image generation 生成并保留 source、prompt、
  alpha 中间文件和 preview；本 Story 不新增角色，因此不创建新的 SpriteFrames。

## 状态与重试

- 耐久：`central_tower_apex_roost_activated`、
  `central_tower_apex_last_savepoint`、`central_tower_apex_approach_secured`。
- 尝试态：警告倒计时、净化墙位置、是否移动、当前尝试是否触发、接触计数。
- 完成终点后净化墙永久禁用；Roost 仍是当前 Tower 最新复活点。
- `restore_no_loss_state()` 必须合并死亡前快照与死亡窗口中新产生的耐久结果，
  不能回滚 Story140-143 或玩家能力。

## 受影响系统

| System | Impact | Action Required |
|--------|--------|-----------------|
| Central Tower scene | 第五视口、碰撞、控制器与父场景窄适配 | 更新 scene/script |
| Save/respawn | 新est Tower Roost 与死亡重试 | 复用 SavepointRuntime/GameFlow |
| Player abilities | 只消费已有移动 API | 不改 PlayerController |
| Assets | 五个生成素材及导入记录 | 更新 spec/manifest/inventory |
| Boss progression | 只形成 Boss 前置入口 | 不新增 Boss4 合同 |

## 验收标准

- [ ] 第五视口、碰撞、边界和五项生成素材按稳定合同存在且可被 Godot 导入。
- [ ] Story143 完成是唯一门槛；Roost 激活一次并成为最新复活点。
- [ ] 真实玩家越过触发线后，警告结束才启动净化墙；墙以确定速度推进并造成
  致死接触，底部坠落同样进入既有死亡/复活流程。
- [ ] Roost 复活保留精确能力和 Story140-143 耐久状态，并重置未完成追逐。
- [ ] 终点只在当前尝试已启动且玩家靠近时完成，持久化后禁用危险并避免反馈重放。
- [ ] focused RED/GREEN、Story143 相关回归、target smoke 和一次 MCP 实玩
  检查均通过，截图非空、日志无新增错误。
- [ ] 无回归：Deep Lift 仍可从 Cooling Roost 直接重骑并完成 Story143。

## GDD Update Required?

No。该切片只细化既有 Central Tower 关卡推进和现有移动/死亡规则，不改变
GDD 的能力门槛或核心系统合同。

## 范围外

- Boss4 身份、数据、竞技场、阶段、音乐、奖励、叙事、结局或场景切换。
- 新敌人、角色帧动画、能力、武器、Charm、货币奖励、NPC、对白、地图或快传。
- PlayerController、GameFlow、SaveSystem、SceneManager、Combat、Collision、
  Ability 的共享重构。
- full suite；本 Story 只做风险匹配的 focused/related/smoke/MCP 验证。
