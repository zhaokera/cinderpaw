# Godot Engine — Version Reference

| Field | Value |
|-------|-------|
| **Engine Version** | Godot 4.6.3 |
| **Release Date** | January 2026 (4.6), Maintenance 4.6.3 May 2026 |
| **Project Pinned** | 2026-06-18 |
| **Last Docs Verified** | 2026-06-18 |
| **LLM Knowledge Cutoff** | May 2025 |
| **Risk Level** | HIGH — versions 4.4, 4.5, 4.6 are beyond LLM training data |

## Knowledge Gap Warning

The LLM's training data likely covers Godot up to ~4.3. Versions 4.4, 4.5,
and 4.6 introduced significant changes that the model does NOT know about.
Always cross-reference this directory before suggesting Godot API calls.

## Post-Cutoff Version Timeline

| Version | Release | Risk Level | Key Theme |
|---------|---------|------------|-----------|
| 4.4 | ~Mid 2025 | MEDIUM | Jolt physics option, FileAccess return types, shader texture type changes |
| 4.5 | ~Late 2025 | HIGH | Accessibility (AccessKit), variadic args, @abstract, shader baker, SMAA |
| 4.6 | Jan 2026 | HIGH | Jolt default, glow rework, D3D12 default on Windows, IK restored, required parameters/return values |
| 4.6.1 | Feb 2026 | LOW | Bug fixes and usability improvements |
| 4.6.2 | Mar 2026 | LOW | Stability fixes |
| 4.6.3 | May 2026 | LOW | 86 fixes, 41 contributors |

## Key Breaking Changes Summary (4.3 → 4.6)

### Godot 4.4
- **Jolt Physics**: Now available as an alternative physics engine (opt-in)
- **FileAccess**: Return types changed — methods now return typed values instead of Error codes in some cases
- **Shader texture types**: Changes to how texture types are declared in shaders
- **TileMap**: Continued refinement of the new TileMap system introduced in 4.3

### Godot 4.5
- **Accessibility (AccessKit)**: Major accessibility improvements integrated
- **Variadic arguments**: GDScript now supports variadic arguments in functions
- **@abstract annotation**: New `@abstract` keyword for class declarations
- **Shader Baker**: New tool for baking shaders at build time
- **SMAA**: Subpixel Morphological Anti-Aliasing added as rendering option
- **Rendering**: Various rendering pipeline improvements

### Godot 4.6
- **Jolt Physics Default**: Jolt is now the default physics engine (replacing Godot Physics as default)
- **Glow Rework**: Glow/bloom rendering system has been significantly reworked
- **D3D12 Default on Windows**: Direct3D 12 is now the default rendering backend on Windows
- **IK Restored**: Inverse Kinematics functionality restored after being incomplete in earlier 4.x versions
- **Required Parameters/Return Values**: API parameters and return values can now be declared as required — nullable values are no longer implicitly allowed. This is a significant API strictness change.
- **Scene Compatibility**: Scenes saved in 4.5 can still be loaded in 4.6 and vice-versa

## Known Issues (Community Reported)

- **GLSL Shader Changes**: The 4.5→4.6 migration guide initially missed some important breaking changes to GLSL shaders. Custom shaders may need updates.
- **Color/Rendering Shifts**: Some users report color rendering differences after upgrading to 4.6. If visual fidelity is critical, test before upgrading.

## Verified Sources

- Official docs: https://docs.godotengine.org/en/stable/
- 4.5→4.6 migration: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.6.html
- 4.4→4.5 migration: https://docs.godotengine.org/en/stable/tutorials/migrating/upgrading_to_godot_4.5.html
- 4.3→4.4 migration: https://docs.godotengine.org/en/4.4/tutorials/migrating/upgrading_to_godot_4.4.html
- Changelog: https://github.com/godotengine/godot/blob/master/CHANGELOG.md
- Release notes: https://godotengine.org/releases/4.6/
- GDQuest workflow changes: https://www.gdquest.com/library/godot_4_6_workflow_changes/
- Interactive changelog: https://godotengine.github.io/godot-interactive-changelog/

## Migration Quick Reference

When upgrading an existing project:
1. **Back up your project**
2. Open it in Godot 4.6.3
3. Use **Project → Tools → Upgrade Project Files**
4. Review breaking changes in the official migration guide
5. Test thoroughly — especially custom shaders and rendering

## For LLM Agents

**MANDATORY**: Before suggesting any Godot API call:
1. Check `deprecated-apis.md` in this directory
2. Check `breaking-changes.md` for the relevant version transition
3. If uncertain about an API, use WebSearch to verify against the official 4.6 docs
4. Never assume pre-4.4 API signatures are still valid
