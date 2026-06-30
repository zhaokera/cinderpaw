# ADR-0013: 像素艺术渲染管线 (SMAA, Shader Baker)

## Summary
定义像素艺术渲染管线：使用 Godot 4.5+ 的 SMAA 1x 抗锯齿和 Shader Baker 预编译。Viewport 缩放采用 `canvas_items` 模式，保持像素完美。

## Status
Proposed

## Date
2026-06-22

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 |
| **Domain** | Rendering / Presentation |
| **Knowledge Risk** | MEDIUM — SMAA 1x 和 Shader Baker 是 4.5+ 新增 (post-cutoff) |
| **References Consulted** | `docs/engine-reference/godot/current-best-practices.md` |
| **Post-Cutoff APIs Used** | `Viewport.scaling_3d_mode` (SMAA), Shader Baker CLI (4.5+) |
| **Verification Required** | 验证 SMAA 1x 对像素艺术的视觉效果；Shader Baker 对启动时间的实际影响 |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0012 (2D物理引擎) |
| **Enables** | 视觉呈现 |
| **Blocks** | 无（可推迟到美术资产就绪） |

## Context

### Problem Statement

游戏采用 16-32bit 像素艺术风格。需要决定：
1. 抗锯齿策略（像素艺术通常需要关闭 AA，但 SMAA 1x 可能提供折中方案）
2. Shader 预编译（减少启动卡顿）
3. Viewport 缩放模式（保持像素完美）
4. 后处理效果（glow, color grading）

### Constraints

- **像素完美**: 缩放时不能出现模糊或亚像素抖动
- **性能**: 目标 60fps，帧时间 <16.6ms
- **启动时间**: Shader 编译不能造成明显卡顿

## Decision

### Viewport 配置

```
Project Settings → Display → Window
├── Size: 1280×720 (逻辑分辨率)
├── Stretch Mode: canvas_items
├── Stretch Aspect: keep
└── Scale Mode: nearest (像素完美)
```

**规则**:
- 逻辑分辨率 1280×720（16:9）
- `canvas_items` 模式：UI 跟随缩放，2D 节点保持像素完美
- `nearest` 缩放：避免线性插值导致的模糊

### 抗锯齿策略

**选择**: SMAA 1x（Godot 4.5+）

**理由**:
- SMAA 1x 是轻量级后处理 AA，对像素艺术影响小
- 比 FXAA 更清晰，比 TAA 更便宜
- 可以减少精灵边缘的闪烁（尤其是移动时）

**配置**:
```
Project Settings → Rendering → Anti Aliasing
└── Quality: SMAA 1x
```

**降级方案**: 如果 SMAA 1x 对像素艺术视觉效果不佳，可以关闭 AA（默认 `Disabled`）

### Shader Baker（预编译）

**选择**: 启用 Shader Baker

**理由**:
- 预编译 shader 避免运行时编译卡顿
- Godot 4.5 报告某些 demo 启动时间减少 20x
- 对像素艺术 shader（简单，数量少）效果显著

**配置**:
```bash
# 构建时预编译
godot --headless --import  # 首次导入时自动编译
godot --shader-bake        # 显式预编译所有 shader
```

### 后处理效果

| 效果 | 启用 | 配置 | 用途 |
|------|------|------|------|
| Glow | ✅ | 低强度 (0.3), 大半径 (8px) | 弹反闪光、技能特效 |
| Color Grading | ✅ | 自定义 LUT | 区域氛围（废土暖色 vs 机械冷色） |
| Vignette | ❌ | — | 不需要（可能干扰像素艺术） |
| SSAO | ❌ | — | 2D 游戏不需要 |
| SSR | ❌ | — | 2D 游戏不需要 |

### 纹理过滤

```
Project Settings → Rendering → Textures
├── Default Texture Filter: Nearest
└── Canvas Items Texture Filter: Nearest
```

**规则**: 所有像素艺术纹理使用 `Nearest` 过滤，保持锐利边缘。

## Consequences

### Positive
- **视觉质量**: SMAA 1x 减少边缘闪烁
- **性能**: Shader Baker 减少启动卡顿
- **像素完美**: Viewport 配置确保缩放不失真

### Negative
- **兼容性**: SMAA 1x 在某些低端设备可能不支持（移动端需要测试）
- **构建时间**: Shader Baker 增加构建时间（可接受，一次性）

### Risk Mitigation
- **原型验证**: 在 Tier 1 原型中测试 SMAA 1x 视觉效果
- **降级方案**: 提供关闭 AA 的选项（设置菜单）
- **移动端**: 移动端可能使用 FXAA 或关闭 AA

## GDD Requirements Addressed

- `design/gdd/game-concept.md` — Visual Identity Anchor (像素艺术风格)
- `design/gdd/combat-presentation.md` — 视觉特效需求

## Verification

- [ ] 像素艺术在不同分辨率下保持锐利
- [ ] SMAA 1x 不会模糊像素边缘
- [ ] Shader Baker 减少首次启动卡顿
- [ ] Glow 效果在弹反时视觉反馈清晰
- [ ] 移动端性能测试（如果 SMAA 1x 有问题，测试降级方案）
