# Codex Game Studios -- Game Studio Agent Architecture

Indie game development managed through 49 coordinated Codex subagents.
Each agent owns a specific domain, enforcing separation of concerns and quality.

## Technology Stack

- **Engine**: Godot 4.7
- **Godot AI MCP**: 2.9.1
- **Language**: GDScript
- **Version Control**: Git with trunk-based development
- **Build System**: SCons (engine), Godot Export Templates
- **Asset Pipeline**: Godot Import System + custom resource pipeline

> **Note**: Engine-specialist agents exist for Godot, Unity, and Unreal with
> dedicated sub-specialists. Use the set matching your engine.

## Project Structure

@.claude/docs/directory-structure.md

## Engine Version Reference

@docs/engine-reference/godot/VERSION.md

## Technical Preferences

@.claude/docs/technical-preferences.md

## Coordination Rules

@.claude/docs/coordination-rules.md

## Parallel Agent Use

- Parallel Codex subagents are the default for sizable slices. Whenever a slice
  contains two or more independent workstreams that do not write the same files
  or depend on the same unresolved decision, split the work instead of running it
  serially in one agent.
- Good parallel splits include: asset prompt/spec review, documentation/evidence
  updates, isolated test failure investigation, and scene/runtime verification.
- Start read-only review or validation-planning subagents early for sizable
  slices; do not wait until implementation is finished if art direction,
  acceptance criteria, test scope, or MCP validation can be checked in parallel.
- Keep shared gameplay code, scene wiring, and resource ownership changes under
  one integrating agent unless the write sets are clearly disjoint.
- Use read-only subagents aggressively for GDD/ADR/story traceability checks,
  acceptance-criteria review, and MCP validation planning while implementation
  proceeds in the integrating agent.
- Do not let two agents edit the same Godot scene, `.tres` animation resource,
  gameplay controller, or asset manifest in parallel unless a prior split assigns
  non-overlapping files and one agent owns final integration.
- The integrating agent must review subagent results, resolve conflicts, and run
  the final Godot/GdUnit/MCP verification before reporting completion. Passing
  subagent output is advisory until the integrating agent verifies it.
- Subagents should receive narrow, self-contained tasks and return findings,
  proposed edits, or verification evidence; the integrating agent owns final
  file edits unless a subagent write set is explicitly isolated.

## Language

所有对话、审查报告、问题描述、修订说明均使用**中文**与用户交流。代码注释、变量命名、文件命名仍按 Coding Standards 执行（英文）。GDD 文档正文使用中文，技术术语可保留英文原文。

## Godot 帧动画规则 / Godot 2D Frame Animation Rules

动作类游戏必须把玩家可见角色推进到帧动画表现，不能长期停留在静态方块、
纯色矩形或单张占位图。新增或重做 2D 角色动画时遵守以下规则：

1. 所有 2D 角色帧动画统一使用 `AnimatedSprite2D` + `SpriteFrames`。
2. 角色动画素材必须放在 `assets/characters/<character_name>/<animation_name>/`。
3. PNG 帧必须透明背景、尺寸一致、锚点一致、命名连续，例如
   `<character_name>_<animation_name>_000.png`。
4. 新增角色必须同时创建 `scenes/characters/<character_name>.tscn` 和
   `src/characters/<character_name>.gd`，并将动画资源接入场景。
5. 玩家可见动作状态默认必须是多帧动画；除非 Story 明确豁免并标记为临时
   fixture，每个 gameplay state 至少 3 帧，不能用单帧贴图伪装动画。
6. 修改 Godot 场景、`SpriteFrames`、角色脚本或动画资源后，必须通过
   Godot MCP 检查场景加载、脚本错误、运行时日志和关键节点可见性；不能只凭文件内容判断场景可用。
7. 如果 MCP 返回 Godot 报错，必须先修复报错并重新验证，不能继续新增功能。
8. 如果 MCP 临时不可用，必须先诊断 MCP 连接；阻塞时可用 Godot CLI/headless
   作为临时验证，但后续仍要补 MCP 运行时检查。
9. 动画资源必须映射到明确 gameplay state，例如 `idle`、`run`、`attack`、
   `dodge`、`hurt`、`death`、`revive`、`jump`、`fall`；新增状态必须有
   单元测试或运行时测试覆盖触发条件。
10. MCP 验收至少要覆盖目标场景打开成功、`AnimatedSprite2D` 实例存在、
   `SpriteFrames` 动画名和帧数符合 Story 验收、游戏运行日志无新增错误、截图非空且能看到目标角色。
11. 新增视觉素材优先通过 image2/image generation 生成；生成提示词、用途和
   导入位置必须记录在资产规格、manifest 或 QA evidence 中。
12. 不接受只有占位方块、纯色矩形或单帧静态图的新增角色验收，除非该文件明确
    标记为临时测试 fixture 且不接入玩家可见 gameplay。

## Collaboration Protocol

**User-driven collaboration, not autonomous execution.**
Every task follows: **Question -> Options -> Decision -> Draft -> Approval**

- Standing approval is granted by the user for project work, including
  destructive local filesystem writes when needed for the active task:
  implementation code, tests, documentation, story metadata, local validation
  commands, generated/imported game assets, replacing files, and deleting
  obsolete local project files may proceed without asking "May I write this to
  [filepath]?" each time.
- Multi-file changes aligned with the active goal, approved stories, GDDs, ADRs,
  tests, or asset pipeline are pre-approved. Agents should still provide concise
  progress summaries and final change summaries.
- Do not pause for approval before local destructive project-file operations
  that are necessary to complete the active task. Avoid reverting unrelated
  user changes unless the current task specifically requires it.
- The user explicitly approved destructive local project-file writes for the
  active task; do not ask again before replacing, deleting, or regenerating
  local project files when the operation is necessary for implementation,
  validation, documentation, or asset pipeline work.
- Agents MUST still ask before external or repository-history operations:
  commits, pushes, force operations, publishing, sending external messages,
  installing external services, or spending money.
- No commits without user instruction

See `docs/COLLABORATIVE-DESIGN-PRINCIPLE.md` for full protocol and examples.

> **First session?** If the project has no engine configured and no game concept,
> run `/start` to begin the guided onboarding flow.

## Coding Standards

@.claude/docs/coding-standards.md

## Context Management

@.claude/docs/context-management.md
