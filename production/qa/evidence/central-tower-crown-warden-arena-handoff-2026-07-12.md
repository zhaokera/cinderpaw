# QA Evidence: Central Tower Crown Warden Arena Handoff

## 范围

Story145 将 Story144 的持久 Apex Approach 终点接到真实异步场景
`boss_04_crown_warden_arena`，并提供可重复进入、可返回中央塔且不丢失能力或
Story140-144 状态的 Crown Observatory。该 Story 只实现 arena handoff；Crown
Warden 的角色帧动画、Boss 战、HUD、封门、奖励与结局明确由 Story146 及后续
切片负责。

## 自动化证据

- 预期 RED：`reports/report_1530/report_1/results.xml`，2 个用例共 10 个失败，
  退出 `100`；缺失 arena、脚本、素材和 Tower route API。
- 第一次实现运行 `reports/report_1531/results.xml` 虽显示断言 `2/2`，但日志有
  两个新 PNG 尚未导入的 resource-loader ERROR，因此不计为 GREEN。
- Godot 4.7 editor/headless import 注册 `CrownWardenArena` 并导入背景、gate、
  source 和 alpha 后，fresh focused `reports/report_1532/results.xml` 通过 `2/2`，
  `0` error、`0` failure、`0` skipped，退出 `0`，运行日志无资源加载错误。
- MCP 修正 return prompt 裁切后，final focused
  `reports/report_1534/results.xml` 再次通过 `2/2`，`0` error、`0` failure、
  `0` skipped、`0` orphan，退出 `0`。
- 关闭审查补充 missing/locked/unknown 直接断言时，`report_1535` 暴露 GdUnit
  会自动注入真实 SceneManager；测试改为显式注入 `null`，不再误触真实切场。
- 最终 hardened focused `reports/report_1536/results.xml` 通过 `2/2`，最终
  Story144-145 related `reports/report_1537/results.xml` 通过 `5/5`；两者均为
  `0` error、`0` failure、`0` skipped、`0` orphan，退出 `0`。Story144 的 raw
  PNG 尺寸检查产生既有 export warning，不是当前运行时错误。
- 目标 smoke 以 Godot `4.7.stable` 串联真实 SceneManager 进场、arena 检查、
  返回和精确能力状态，打印
  `central_tower_crown_warden_arena_handoff_smoke=passed`；加入音频释放等待后
  退出 `0` 且无 ObjectDB/resource cleanup ERROR。未运行全量套件。

## 素材证据

- Built-in image generation 保留 `1672x941` RGB 观测场 source、精确 prompt，
  以及 `1024x1536` keyed gate source、精确 prompt 和完整 alpha intermediate。
- 运行时背景为 opaque RGB `1280x720`，SHA-256
  `787b945f5f95c6c46bdfcd33fffe05cfe89a580626dbbcae4e055e1806ece5f1`；
  gate 为 transparent sRGBA `256x384`，SHA-256
  `448d943ac35e8e361ec5208d5d3f423b2115f4f28a7bbd58f3d9203832f4ad1f`。
- focused 测试检查精确尺寸、背景无 alpha、gate 透明角、source/prompt/alpha
  留存和 Godot 场景导入路径。
- Story145 不新增角色素材；运行时 Cinderpaw 仍使用既有
  `AnimatedSprite2D + SpriteFrames`。不存在静态 Crown Warden 占位图。

## 运行时结果

- Tower route 在 `central_tower_apex_approach_secured=false` 时显示
  `Secure Apex Approach`，完成后切换为 `Enter Crown Observatory`，目标为
  `boss_04_crown_warden_arena / boss_entry`。
- 越界、SceneManager missing/loading/locked/unknown 和 request rejection 均不
  锁死 route；成功请求只触发一次并先持久化 Tower 状态。
- Arena spawn 为 `(220,536)`，return route 指向
  `area_05_central_tower / apex_approach_return`。返回后玩家对齐 `(6200,296)`，
  Story144 状态和排序后的能力列表保持一致。
- Arena 场景只有背景、地面、边墙、玩家、相机、返回 route 和 objective；无
  Crown Warden、Boss HUD、封门、hitbox、奖励或结束逻辑。

## Godot MCP 证据

- Session `cinderpaw@e40d`；Godot `4.7-stable (official)`；Godot AI MCP
  plugin/server `2.9.1`。
- MCP force-open 成功，edited scene 有 `25` 个 authored nodes；运行态有 `29`
  个 nodes，包含 `Player/Sprite: AnimatedSprite2D`、generated background、
  `CentralTowerReturnRoute/Visual`，且没有 Crown Warden node。
- Run76 首次截图发现 return prompt 左边缘被裁切。停止游戏、把 label rect 从
  x `-54..246` 调整到屏幕内 x `16..316` 后 force reload，Run77 重新验收。
- Run77 id `r456423025-77`，`current_run_errors=[]`。真实 `move_right` 输入把玩家
  x 从 `220` 移到 `291.667`；objective 与 return prompt 均完整可见。
- 最终 game log 只有 helper 注册信息；editor logger cursor `8 -> 8`，无新增行。
  MCP inline game capture 为非空 PNG `1278x718`，显示机械观测场、动画玩家、
  crown gate 和两条不裁切文字。retained recent errors 明确早于当前 run。
- Run77 已停止，editor 返回 `ready`。结构化证据见
  `production/qa/evidence/central-tower-crown-warden-arena-handoff-mcp-run77.json`。

## 结论

PASS。Story145 已形成玩家可见、可进可退、状态无损的 Boss4 arena handoff，
生成素材与 Godot 导入完整，自动化和最终 MCP run 均满足本 Story 范围；Boss4
本体仍需 Story146 按帧动画规则实现。
