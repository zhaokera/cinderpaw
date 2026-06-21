# 输入系统 (Input System)

> **Status**: Designed (awaiting review)
> **Author**: 用户 + AI
> **Last Updated**: 2026-06-18
> **Implements Pillar**: 猫科战斗美学, 技巧优先成长
> **Indirectly supports**: 可爱与危险的视觉反差
> **Systems Index**: #1 | MVP核心 | Foundation
> **Creative Director Review (CD-GDD-ALIGN)**: CONCERNS (accepted — contextual input mapping to be validated in Tier 1 prototype) [2026-06-18]

## Overview

**输入系统**是《废土喵影》的基础设施层，负责将玩家的物理操作（按键、摇杆、触控）转化为游戏内可消费的动作指令。它管理多平台输入映射（PC键鼠/手柄/移动端触控）、输入缓冲（格斗游戏式buffer）、以及平台自适应切换。

**玩家直接感受它**：对于一个以"猫科战斗美学"为核心卖点的ACT游戏，输入系统的响应速度和精度直接决定战斗手感。每一次闪避、弹反、连招都依赖输入系统在**帧级精度**内捕获并传递玩家意图。输入延迟超过2帧（33ms @ 60fps），"精准闪避"的体验就会被破坏。

**技术职责**：
- 统一输入抽象层：所有平台输入归一化为游戏动作（`attack`, `dodge`, `jump`, `dash` 等）
- 输入缓冲队列：在动画锁定期间预存下一个输入，保证连招流畅性
- 平台检测与动态切换：运行时检测输入设备变化，自动切换UI提示和操作映射
- 输入优先级：同时按下多个键时的冲突解决规则

**为什么存在**：没有输入系统，玩家无法与游戏交互。它是所有玩家行为的前提。

## Player Fantasy

**「意念通达」— 身体延伸幻想**

输入系统的终极使命是**自我消隐**。当它完美运作时，玩家完全意识不到它的存在——手柄消失了，屏幕消失了，玩家觉得自己**就是**那只猫。

**锚定时刻**：Boss第三阶段，连续五次完美闪避后接弹反——玩家的手指在按键上飞舞，猫武士在屏幕上同步闪转腾挪。那一刻，"想到"和"做到"之间没有任何延迟。玩家的意志直接化为猫武士的动作，中间不经过任何机械翻译。

**核心承诺**：
- **零犹豫感**：按下即执行，输入延迟不超过1帧（16.6ms）
- **身心合一**：输入缓冲让连招像猫的本能一样自然流出——按下攻击键的瞬间，下一个动作已经在身体里准备好了
- **无意识掌控**：当玩家进入心流状态时，手指的操作变成肌肉记忆，输入系统必须忠实地传递这种无意识的精准

**身体即是武器，意念即是动作。** 这是猫科动物最核心的体验——输入系统是玩家与猫武士之间唯一不应存在的隔阂。

## Detailed Design

### Core Rules

#### 规则1：游戏动作定义（12个核心动作）

| 动作ID | 名称 | 类型 | 可缓冲 | 优先级权重 |
|--------|------|------|--------|-----------|
| `move_left/right/up/down` | 移动 | Continuous | 否 | — |
| `jump` | 跳跃 | Trigger | 是 | 50 |
| `dash` | 冲刺 | Trigger | 是 | 80 |
| `attack` | 轻攻击 | Trigger | 是 | 60 |
| `heavy_attack` | 重攻击 | Trigger | 是 | 70 |
| `dodge` | 闪避 | Trigger | 是 | 90 |
| `parry` | 弹反 | Trigger | 是 | 100 |
| `interact` | 交互 | Trigger | 否 | 10 |
| `pause` | 暂停 | Trigger | 否 | ∞(最高) |

**Trigger（触发型）**：按下=执行一次，支持缓冲。
**Continuous（持续型）**：按住=持续生效，每帧直接读取，不缓冲。

#### 规则2：默认键位映射

| 动作 | 键盘 | 手柄(Xbox布局) | 触控 |
|------|------|----------------|------|
| 移动 | WASD/方向键 | 左摇杆/D-Pad | 虚拟摇杆 |
| jump | Space | A(南) | 按钮A |
| dash | Shift | B(东) | 按钮B |
| attack | J/鼠标左键 | X(西) | 按钮X |
| heavy_attack | K/鼠标右键 | Y(北) | 按钮Y |
| dodge | L | RB | 右肩触控 |
| parry | I | LB | 左肩触控 |
| interact | E | RT | 浮现按钮 |
| pause | Esc | Start | 右上角 |

**情境分离规则**：
- Space键：地面=jump，空中=jump（**键盘默认**；地面闪避使用L键。此映射为初始设计，Tier 1原型中验证地面Space=jump是否满足ACT操作需求）
- 手柄A键：地面+面朝敌人=parry，其他=jump

PC版支持完全自定义键位，映射存储在 `user://input_bindings.cfg`。

#### 规则3：输入缓冲系统

| 参数 | 值 | 说明 |
|------|----|------|
| 缓冲窗口 | **150ms (≈9帧@60fps)** | 按键按下后150ms内有效 |
| 队列深度 | **3** | 最多同时缓冲3个输入，超出丢弃最早 |
| 预输入窗口 | **50ms (≈3帧)** | 动画结束前50ms内的输入获得+20权重加成 |

**消费规则**：动画锁定结束后的1帧内，按优先级权重降序消费最高优先级输入。同权重按时间先入先出。

**连招链（Combo Chain）**：`attack`连续缓冲消费时维护combo_counter。两次attack时间差 < 300ms = 连招继续，否则重置。战斗系统根据combo_index选择连招动画（第1/2/3击）。

#### 规则4：Coyote Time + Jump Buffer

| 参数 | 值 | 说明 |
|------|----|------|
| Coyote Time | **5-8帧 (83-133ms)** | 离开平台边缘后仍可跳跃 |
| Jump Buffer | **5-8帧 (83-133ms)** | 落地前按跳跃，落地瞬间自动执行 |

#### 规则5：平台检测与动态切换

| 参数 | 值 | 说明 |
|------|----|------|
| 防抖窗口 | **500ms** | 防止多设备同时操作时反复切换 |
| 设备优先级 | gamepad > kbm > touch | 手柄是一等公民 |

切换规则：检测到新设备事件 → 防抖窗口外 → 更新current_device → 发射`device_changed`信号 → HUD下帧更新图标。战斗中不切换。

#### 规则6：输入冲突解决

**互斥动作对**（同帧只执行优先级高的）：
- dodge + attack → dodge（防御优先）
- parry + dodge → parry（风险更高=意图更明确）
- dash + jump → dash（有冷却=意图更明确）

**Continuous + Trigger 共存**：move（Continuous）和 attack（Trigger）可同帧共存，不冲突。

### States and Transitions

三状态有限状态机：

**DIRECT（直通模式）**：角色可操作时。Trigger输入立即执行，延迟=0帧。
**BUFFERING（缓冲模式）**：动画锁定中。Trigger输入写入缓冲区，动画结束后1帧内消费。
**TRANSITIONING（切换模式）**：设备切换时。持续1帧，不清空缓冲区，不阻断当前动作。

转换规则：
- DIRECT → BUFFERING：执行的Trigger动作导致动画锁定
- BUFFERING → DIRECT：动画锁定结束 + 缓冲区为空或所有条目已过期
- 任意 → TRANSITIONING：检测到新设备事件（500ms防抖后）
- TRANSITIONING → 回到之前状态：信号发射完成（1帧）

### Interactions with Other Systems

#### 输出信号

| 信号 | 参数 | 监听者 |
|------|------|--------|
| `action_triggered(action_id, metadata)` | action + {combo_index, is_pre_input, buffer_delay_ms, source_device} | 战斗系统, 移动系统 |
| `device_changed(old, new)` | 旧设备 + 新设备 | HUD系统 |

#### 查询接口

- `is_action_pressed(action) → bool` — Continuous: 移动系统每帧读取
- `is_action_just_pressed(action) → bool` — Trigger: 弹反时机检查
- `get_action_strength(action) → float` — 0.0~1.0: 摇杆幅度
- `get_action_duration(action) → float` — 按住秒数: heavy_attack蓄力
- `clear_buffer() → void` — 被击飞/场景切换时清空

#### 输入接口（其他系统写入输入系统）

| 提供方 | 接口 | 说明 |
|--------|------|------|
| 战斗系统 | `notify_animation_lock(duration_ms)` | 同帧感知，直接方法调用（非信号） |
| 战斗系统 | `notify_animation_unlock()` | 触发consume_window |
| 移动系统 | 同上 | 冲刺等也触发锁定 |

## Formulas

**1. 缓冲过期判定**
`is_expired = (current_time_ms - press_time_ms) > BUFFER_WINDOW_MS`
- BUFFER_WINDOW_MS = 150ms（可调）

**2. 连招链超时判定**
`combo_reset = (current_time_ms - last_attack_time_ms) > COMBO_CHAIN_WINDOW_MS`
- COMBO_CHAIN_WINDOW_MS = 300ms（可调）

**3. 预输入判定**
`is_pre_input = (animation_end_time_ms - press_time_ms) <= PRE_INPUT_WINDOW_MS`
- PRE_INPUT_WINDOW_MS = 50ms（可调）
- 预输入获得 +20 优先级权重加成

**4. Coyote Time / Jump Buffer 帧窗口**
- Coyote: `frames_since_left_ground <= COYOTE_FRAMES` (默认6帧)
- Jump Buffer: `frames_since_jump_press <= JUMP_BUFFER_FRAMES` (默认6帧)

**5. 设备切换防抖**
`should_switch = (current_time_ms - last_switch_time_ms) > DEVICE_SWITCH_DEBOUNCE_MS`
- DEVICE_SWITCH_DEBOUNCE_MS = 500ms

## Edge Cases

- **动画锁定期间连续按同一键多次**：保留最新一次时间戳，旧条目被覆盖（不堆积）
- **缓冲区已满（3个）时收到新输入**：丢弃最早的条目，新输入入队
- **手柄在Boss战中断连**：不切换设备，保持当前映射。发射`device_changed`信号但不影响战斗。重新连接后恢复
- **不可操作状态（眩晕/击飞）按攻击**：输入被丢弃（clear_buffer()由战斗系统调用），角色有明确的受击动画告知玩家
- **pause和其他动作同帧按下**：pause永远优先（优先级∞），立即生效
- **同时使用键盘和手柄**：500ms防抖窗口内忽略切换，按设备优先级（gamepad > kbm）确定主导设备
- **heavy_attack长按后在蓄力完成前被击中**：蓄力中断，heavy_attack不执行，combo_counter重置
- **移动端触控按钮被快速连点**：与物理按键相同逻辑——Trigger类型，同动作不堆积

## Dependencies

**上游依赖（输入系统需要的）**：
- 无（Foundation层，零依赖）
- Godot Engine: `InputMap`, `Input` singleton, `InputEvent` 类

**下游被依赖（依赖输入系统的）**：
- 猫科战斗系统 — 消费`action_triggered`信号，调用`notify_animation_lock/unlock`
- 玩家移动系统 — 每帧读取`is_action_pressed(move_*)`
- 碰撞与判定系统 — 通过`is_action_just_pressed`检查弹反/闪避时机
- HUD/UI系统 — 监听`device_changed`信号更新按钮图标
- 场景管理系统 — 场景切换时调用`clear_buffer()`

## Tuning Knobs

| 旋钮 | 默认值 | 安全范围 | 过高影响 | 过低影响 |
|------|--------|---------|---------|---------|
| BUFFER_WINDOW_MS | 150ms | 80-250ms | 角色"自动驾驶" | 连招断裂 |
| BUFFER_QUEUE_SIZE | 3 | 1-5 | 输入堆积失控 | 连招受限 |
| PRE_INPUT_WINDOW_MS | 50ms | 30-80ms | 预输入误判 | 连招不流畅 |
| COMBO_CHAIN_WINDOW_MS | 300ms | 200-500ms | 连招太宽松 | 连招断裂 |
| COYOTE_FRAMES | 6帧 | 4-10帧 | 跳跃太宽容 | 频繁掉崖 |
| JUMP_BUFFER_FRAMES | 6帧 | 4-10帧 | 跳跃延迟感 | 连续跳粘滞 |
| DEVICE_SWITCH_DEBOUNCE_MS | 500ms | 200-1000ms | 切换迟钝 | 反复切换 |
| 各动作优先级权重 | 见规则1 | 10-100 | 优先级排序变化 | 优先级排序变化 |

所有旋钮通过数据基础设施（JSON/Resource）配置，支持热重载。

## Visual/Audio Requirements

输入系统本身不产生视觉/音频，但它触发的事件需要下游系统提供反馈：

### 输入确认反馈（按下瞬间）
| 动作 | 视觉 | 音频 |
|------|------|------|
| attack | 猫武士攻击预备帧（身体后仰） | 爪刃出鞘音 |
| dodge | 角色开始虚化（残影起始帧） | 短促风声 |
| parry（进入架势） | 短暂金色闪光 | 金属嗡鸣 |
| jump | 压缩动画（蹲→弹） | 弹跳音 |
| dash | 身体拉长+速度线 | 嗖声 |

### 弹反结果反馈
| 结果 | 视觉 | 音频 | 手柄震动 |
|------|------|------|----------|
| 完美弹反（6帧内） | 全屏闪白+火花粒子+8帧帧停 | 清脆金属碰撞（高频） | 短促强震 |
| 普通格挡（窗口外） | 小火花+2帧帧停 | 沉闷金属碰撞（低频） | 微弱震动 |

### 缓冲执行反馈
- 缓冲动作执行时从动画最后一帧无缝过渡（无空白帧）
- 可有极轻微的"加速感"（1-2帧快进效果）

## UI Requirements

### 跨平台输入提示图标
三套图标资产，根据`device_changed`信号动态切换：

| 平台 | 图标风格 | 示例 |
|------|----------|------|
| 键盘 | 方形键帽+字母 | `[J]` `[Space]` |
| 手柄 | 圆形按钮+符号 | `(X)` `(B)` `(LB)` |
| 触控 | 手指图标+手势 | 点击、滑动、长按 |

### 切换规则
- 游戏启动时检测最后活跃设备
- 运行中新设备输入 → 2秒延迟后平滑切换（淡出→淡入0.3秒）
- **战斗中不切换**——锁定为战斗开始时的设备
- 暂停菜单始终显示当前设备图标

### 动态上下文提示
- 不在屏幕中央弹大提示
- HUD边缘小图标提示当前可用动作（如靠近NPC显示`[E]交谈`）
- 新机制用环境叙事引导（符合反支柱"NOT显式教学UI"）

## Acceptance Criteria

- **GIVEN** 玩家在DIRECT模式按下attack，**WHEN** 角色处于idle状态，**THEN** attack在**同一帧**内执行（0帧延迟）
- **GIVEN** 角色在attack动画锁定中，**WHEN** 玩家在150ms窗口内按下dodge，**THEN** 动画结束后1帧内dodge被执行
- **GIVEN** 缓冲区有3个条目，**WHEN** 新输入到达，**THEN** 最早条目被丢弃，新输入入队
- **GIVEN** 玩家在attack动画结束前50ms内按下attack，**WHEN** 动画结束，**THEN** 该输入被标记为pre_input并获得+20权重加成
- **GIVEN** 玩家连续按attack两次（间隔<300ms），**WHEN** 两次都被消费，**THEN** combo_counter=0→1，战斗系统播放第2击动画
- **GIVEN** 玩家离开平台边缘，**WHEN** 在6帧内按jump，**THEN** 跳跃成功执行
- **GIVEN** 玩家在落地前5帧按jump，**WHEN** 落地，**THEN** 跳跃自动执行
- **GIVEN** 玩家使用手柄操作，**WHEN** 碰到鼠标，**THEN** 500ms内不切换设备图标
- **GIVEN** 玩家在Boss战中，**WHEN** 手柄断连，**THEN** 不切换设备，保持当前映射
- **GIVEN** 玩家按下pause，**WHEN** 角色处于任何状态（包括动画锁定），**THEN** 暂停立即生效
- **GIVEN** 玩家同时按dodge+attack，**WHEN** 在同一帧，**THEN** 只执行dodge（优先级90 > 60）
- **GIVEN** 战斗系统调用clear_buffer()，**WHEN** 角色被击飞，**THEN** 所有缓冲输入被清空

## Open Questions

| # | 问题 | 负责人 | 目标解决时间 |
|---|------|--------|-------------|
| 1 | 弹反窗口6帧是否需要辅助选项（12帧/自动）？ | game-designer | Tier 1原型验证后 |
| 2 | 移动端触控布局的具体按钮尺寸和位置？ | ux-designer | 移动端开发阶段 |
| 3 | SDL3手柄API在Godot 4.5+是否有签名变化？ | gameplay-programmer | 技术验证原型 |
| 4 | 4.6双焦点系统是否提供检测活跃输入设备的新API？ | gameplay-programmer | 技术验证原型 |
| 5 | 连招链是否应支持不同武器的混合连招？ | game-designer | 武器流派系统GDD设计时 |
