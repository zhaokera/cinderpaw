# Crown Warden 弹反反击运行时验收证据

> **Story**: Player Abilities 155
> **日期**: 2026-07-14
> **结论**: PASS

## 交付合同

- Crown Warden 的真实攻击 Area 接触处于 PARRYING 的 Cinderpaw 时，仍由
  Player `CombatComponent` 负责 PERFECT/GOOD/LATE 判定，并阻止本次玩家伤害。
- Arena 消费既有 `on_parry_resolved` 信号，读取当前武器有效基础伤害并按
  BossConfig 的 `5.0x` 结算一次反击；Crown Warden 不进入 STUN。
- PERFECT 继续路由现有金色残影、闪光、火花和 perfect-parry SFX。玩家切换
  到现有三帧 attack/counter 表现，但不会额外开启玩家攻击 hitbox。
- 本切片没有新增视觉或音频资产，继续复用已导入的 image-generated Cinderpaw、
  Crown Warden 帧动画和现有 CombatPresentation 资源。

## 自动化证据

- 初始 RED：`reports/report_1627/results.xml`，`1` case 产生 `2` 个预期
  failure，锁定 BossConfig 从错误的 `1.5x + enter_stun` 回归到
  `5.0x + no-STUN`。
- Runtime refinement RED：`reports/report_1628/results.xml`，配置断言已通过，
  真实运行测试因手动跳过 startup、未形成物理重叠而产生 `1` 个预期 failure；
  fixture 随后改为物理帧驱动。
- Focused GREEN：`reports/report_1629/results.xml`，`2/2` 通过，0 error、
  failure、flaky、skipped、orphan。
- Final bounded related GREEN：`reports/report_1630/results.xml`，Story155、
  Crown Warden core、Core parry timing、Boss parry immunity、damage
  crit/combo/parry 和 Main perfect-parry afterimage 共 `24/24` 通过，0 error、
  failure、flaky、skipped、orphan。
- Target smoke：`tests/smoke/crown_warden_parry_counter_runtime_smoke.gd`
  退出码 0，输出 `crown_warden_parry_counter_runtime_smoke=passed`。
- 未运行 full suite；风险边界由 focused、六套相关回归、真实 overlap smoke
  和 MCP 运行态共同覆盖。Godot 退出时保留既有 `6 ObjectDB` leaks 与
  `3 resources in use` 噪声，本切片没有新增 test error 或 orphan。

## Godot MCP 运行证据

Godot `4.7-stable`，Godot AI MCP plugin/server `2.9.2`，session
`cinderpaw@d40a`，最终 run `r19802568-24`：

- MCP 打开 `res://scenes/bosses/crown_warden_arena.tscn` 并启动运行，
  `current_run_errors=[]`，helper live。
- 真实 `talon_dive` overlap 后请求 parry，诊断得到 `parry_type=perfect`、
  `parry_frame=2`、玩家 HP `100 -> 100`、Boss HP `160 -> 110`。
- 当前武器有效基础伤害为 `10`，BossConfig multiplier 为 `5.0`，反击伤害
  为 `50`，`counter_count=1`，`enter_stun=false`，Boss 无 STUN。
- `BossConfigComponent` 与 `CombatPresentation` 均存在；玩家和 Crown Warden
  的当前 SpriteFrames 动画均为 3 帧。MCP 视觉重放仅复用同一 PERFECT 表现，
  未再次结算伤害；金色残影 count 为 1，color `#ECC94B`、alpha `0.82`、
  lifetime `0.35s`、offset `12px`，material 为 `ShaderMaterial`。
- 截图
  `reports/visual/cinderpaw-mcp-crown-warden-perfect-parry-counter-20260714.png`
  是非空 `1278x718` PNG；人工检查可见生成的 Crown Warden、金色 Cinderpaw
  剪影与 Boss `110/160`、Player `100/100` HUD。
- 最终 game log 只有 helper、EnemyStats 与 BossConfig 加载共 3 条 info；
  editor log 0 行；clean stop 后 readiness 为 `ready`。

## MCP 探索性运行说明

最终 run 前，一次探索性 `game_eval` 在 MCP 临时 helper 脚本中混用了空格与
tab，触发 helper parser break。该脚本不是项目文件，且当次
`current_run_errors=[]`。运行已立即停止、日志已清理，并由最终 run24 从干净
状态完整复验；项目脚本、最终 game log 和 editor log 均无新增错误。
