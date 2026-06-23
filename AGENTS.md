# Codex Game Studios -- Game Studio Agent Architecture

Indie game development managed through 49 coordinated Codex subagents.
Each agent owns a specific domain, enforcing separation of concerns and quality.

## Technology Stack

- **Engine**: Godot 4.6.3
- **Language**: GDScript
- **Version Control**: Git with trunk-based development
- **Build System**: SCons (engine), Godot Export Templates
- **Asset Pipeline**: Godot Import System + custom resource pipeline

> **Note**: Engine-specialist agents exist for Godot, Unity, and Unreal with
> dedicated sub-specialists. Use the set matching your engine.

## Project Structure

@.Codex/docs/directory-structure.md

## Engine Version Reference

@docs/engine-reference/godot/VERSION.md

## Technical Preferences

@.Codex/docs/technical-preferences.md

## Coordination Rules

@.Codex/docs/coordination-rules.md

## Language

所有对话、审查报告、问题描述、修订说明均使用**中文**与用户交流。代码注释、变量命名、文件命名仍按 Coding Standards 执行（英文）。GDD 文档正文使用中文，技术术语可保留英文原文。

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

@.Codex/docs/coding-standards.md

## Context Management

@.Codex/docs/context-management.md
