# Health & Death Detection — Design Review Log

## Review — 2026-06-20 — Verdict: NEEDS REVISION → Rev.1 Applied
Scope signal: M
Specialists: game-designer, qa-lead
Blocking items: 4 | Recommended: 12

**Summary**: GDD 技术架构扎实（信号设计、接口签名、edge cases），但 Player Fantasy 交付层存在显著断裂。核心"猫科镇定"体验依赖两个关键感知（前摇减速+低HP氛围），两者均太弱或被移除。

**BLOCKING 项及修复**：
1. ✅ GD-1: windup_modifier 0.9→0.8（20%延长，进入感知阈值）
2. ✅ GD-2: 添加受伤音效低频混响作为替代感知通道
3. ✅ QA-1: 添加 AC-15（死亡元数据结构完整性）
4. ✅ QA-2: AC-9 拆分为 AC-9a（单元/信号）+ AC-9b（手动/视觉）

**同步修复**：
- P3-1: 信号顺序修正（on_hp_changed → milestones → focus → on_death）
- QA-3: AC-2/6/8 修正（补全初始值、具体数值、公式验证）
- QA-4: 新增 9 条 AC（14→23条），覆盖 Rule 6/9/10 + 边缘用例
- GD-4: Rule 7 添加闪避冷却交叉引用（feline-combat.md）
- 下游同步: ai-framework.md windup_modifier 0.9→0.8

**未修复（RECOMMENDED/NICE-TO-HAVE，留待后续）**：
- GD-3: Boss战专注模式阈值（playtest验证）
- GD-6: 死亡元数据信息架构分层
- GD-8: 无被动回复vs探索冲突（playtest验证）
- GD-10: 全局speed_scale vs 仅前摇减速（技术可行性待验证）
- P3-2: revive() milestone重置显式伪代码
- P3-5: i-frame倒计时管理者明确

Prior verdict resolved: First review

## Review — 2026-06-21 — Verdict: MAJOR REVISION NEEDED → Rev.2 Applied
Scope signal: M→L
Specialists: game-designer, systems-designer, qa-lead, ux-designer, creative-director
Blocking items: 13 | Recommended: 8

**Summary**: GDD 架构骨架（信号设计、状态机、接口签名）扎实，但 Rev.1 引入的全局 speed_scale 切换构成 P0 级实现危险（mid-animation 变速可能杀死玩家），三个设计哲学分歧（专注模式范围、被动回复、护盾去留）需要 creative-director 裁决，4 个公式/伪代码错误需修复。

**CD 裁决要点**：
- 专注模式 = 信息优势为主（"猫在黑暗中瞳孔放大"），不添加额外机制奖励
- 无被动回复 — "被困"感受由关卡设计缓解，被动回复会摧毁设计张力
- 护盾系统 = 保留接口标记休眠，职责移交状态效果系统

**BLOCKING 项及修复（Rev.2）**：
1. ✅ P0: 全局 speed_scale → 逐招式前摇帧数修正（windup_extension_frames）
2. ✅ P1: 三个设计哲学裁决已写入规则文本
3. ✅ P2-5: HD-F1 添加 max(1, max_hp) 内联保护
4. ✅ P2-6: HD-F3 添加空数组前置检查
5. ✅ P2-7: Boss阶段跳过 if→while + 修复绝对值/百分比比较
6. ✅ P2-8: i-frame 7帧→8帧（与 feline-combat.md 统一）
7. ✅ P2-9: Dependencies 添加 get_battle_stats() 接口
8. ✅ P2-10: AC-22 重写为完整 4 信号顺序
9. ✅ P2-11: revive() 添加 focus_mode_active 重置
10. ✅ P2-12: Rule 10 "场景周期"→"生命周期"
11. ✅ P2-13: Rule 4 伪代码 bug（已合并到 P2-7）
12. ✅ 感知变化 9→4 项 + 阈值迟滞 + 战斗状态前置条件
13. ✅ AC 合并(9a+13) + 新增 5 条(24-28) = 总计 28 条

**跨系统同步**：
- ai-framework.md: set_global_windup_modifier → windup_extension_frames
- systems-index.md: 状态更新为 Rev.2

**未修复（RECOMMENDED，留待后续/playtest）**：
- 死亡动画 1.5s→1.0s（playtest 决定）
- Boss HP 条移动端响应式（hud-ui.md 负责）
- 死亡元数据消费层强化（death-respawn.md 修改）
- HP 条颜色微调（hud-ui.md 负责）

Prior verdict resolved: Yes (Rev.1 blocking items → Rev.2 进一步深入修复)

## Review — 2026-06-21 — Verdict: NEEDS REVISION → Rev.3 Applied
Scope signal: L
Specialists: game-designer, systems-designer, qa-lead, ux-designer, audio-director, godot-specialist, creative-director
Blocking items: 8 (5本文档 + 3跨文档) | Recommended: 8
Summary: 规则和公式层扎实（第三轮），核心问题转向幻想交付感知设计和跨系统一致性。专注模式4项感知变化均低于高压战斗感知阈值（根因：缺少激活信号），伪代码存在4项防护缺口（state guard/零伤害/除法保护/entity统一），audio-system.md心跳音与本文档矛盾。CD裁定：添加激活信号解决感知危机，伪代码全面防护，音效规格化。

**BLOCKING 项及修复（Rev.3）**：
1. ✅ 专注模式激活信号：Rule 8 新增第0项（猫眼金闪光0.3s + 低频猫科提示音0.5s），Visual/Audio + 音效设计同步更新，新增AC-31
2. ✅ 伪代码状态机防护：Rule 2 添加 `entity.state != ALIVE` 守卫
3. ✅ 伪代码零伤害守卫：Rule 2 添加 `final_damage <= 0` 守卫（与AC-27对齐）
4. ✅ 伪代码除法保护：Rule 2/4 改用 get_hp_percentage()（内含max(1,max_hp)）
5. ✅ 接口entity统一：全部改为entity_id + get_entity()查找
6. ✅ 低频混响触发统一：绑定focus_mode（含迟滞），删除HP≤25%直绑
7. ✅ 受伤音高规格化：新增HD-F4公式（线性偏移）+ injury_pitch_max_semitones旋钮
8. ✅ AC补至31条：+AC-14b（迟滞边界）、AC-29（on_death_in_zone）、AC-30（脱战退出）、AC-31（激活信号）

**跨文档待修复（Open Questions #4-#7）**：
- ⚠️ #4: audio-system.md 移除心跳音（LOW_HP状态+sfx_low_hp资产+对应AC）
- ⚠️ #5: death-respawn.md revive HP统一为50%
- ⚠️ #6: audio-system.md 添加pitch_offset参数（HD-F4依赖）
- ⚠️ #7: active_enemies_count来源系统待producer分配

Prior verdict resolved: Yes (Rev.2 blocking items → Rev.3 感知设计+实施防护修复)
