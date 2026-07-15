# Godot Engine — Version Reference

| Field | Value |
|-------|-------|
| **Engine Version** | Godot 4.7 |
| **Local Binary Verified** | 4.7.stable.official.5b4e0cb0f |
| **Godot AI MCP Baseline** | 3.0.2 |
| **Project Pinned** | 2026-07-14 |
| **Last Docs Verified** | 2026-07-14 |
| **LLM Knowledge Cutoff** | May 2025 |
| **Risk Level** | HIGH — versions 4.4, 4.5, 4.6, and 4.7 are beyond LLM training data |

## Knowledge Gap Warning

The LLM's training data likely covers Godot up to approximately 4.3. Versions
4.4 through 4.7 introduced engine behavior and API changes that agents must not
guess from memory. Always cross-reference this directory and the official
Godot 4.7 docs before suggesting version-sensitive Godot API calls.

## Post-Cutoff Version Timeline

| Version | Release | Risk Level | Key Theme |
|---------|---------|------------|-----------|
| 4.4 | 2025 | MEDIUM | Jolt physics option, FileAccess return types, shader texture type changes |
| 4.5 | 2025 | HIGH | Accessibility, variadic args, @abstract, shader baker, SMAA |
| 4.6 | 2026 | HIGH | Jolt default, glow rework, D3D12 default on Windows, IK restored, stricter required parameters/return values |
| 4.6.1 | 2026 | LOW | Bug fixes and usability improvements |
| 4.6.2 | 2026 | LOW | Stability fixes |
| 4.6.3 | 2026 | LOW | Maintenance fixes |
| 4.7 | 2026 | HIGH | Migration-required API cleanup, stricter GDScript override typing, input device semantics, UI/audio API changes |

## Key Breaking Changes Summary (4.3 → 4.7)

### Godot 4.7

- **GDScript override typing**: overriding methods must keep compatible return
  types. Recheck inheritance-heavy gameplay code and test fixtures after
  engine upgrades.
- **Input device semantics**: input device IDs changed for emulation/default
  handling. Tests or gameplay code that compare `InputEvent.device` directly
  should use named constants or Godot's documented semantics.
- **RichTextLabel image APIs**: image insertion/update APIs changed. HUD or
  menu code using `RichTextLabel.add_image()` / `update_image()` must be
  checked against the 4.7 docs.
- **AudioEffectSpectrumAnalyzer**: `tap_back_pos` was removed. Audio analyzer
  code must use the current 4.7 API.
- **Editor/project format**: projects opened in Godot 4.7 update
  `project.godot` feature metadata to `4.7`; avoid mixing 4.6 and 4.7 editors
  for committed scene/resource edits.

### Godot 4.6

- **Jolt Physics Default**: Jolt is now the default 3D physics engine for new
  projects. Existing projects keep their configured physics backend.
- **Glow Rework**: glow/bloom rendering was significantly reworked.
- **D3D12 Default on Windows**: Direct3D 12 became the default rendering backend
  on Windows.
- **IK Restored**: inverse kinematics functionality was restored after being
  incomplete in earlier 4.x versions.
- **Required Parameters/Return Values**: API parameters and return values can
  be declared required; nullable values are no longer implicitly safe.
- **Scene Compatibility**: scenes saved in 4.5 can still be loaded in 4.6 and
  vice versa, but this guarantee does not imply 4.7 scenes should be edited in
  4.6 after this project upgrade.

### Godot 4.5

- **Accessibility**: AccessKit support improved Control-node accessibility.
- **Variadic arguments**: GDScript supports variadic arguments.
- **@abstract annotation**: GDScript supports abstract classes and methods.
- **Shader Baker**: shader baking was added to reduce runtime hitches.
- **SMAA**: Subpixel Morphological Anti-Aliasing was added.
- **Rendering**: various rendering pipeline improvements landed.

### Godot 4.4

- **Jolt Physics**: Jolt was added as an alternative physics engine.
- **FileAccess**: some method return types changed.
- **Shader texture types**: shader texture declarations changed.
- **TileMap**: continued refinement of the TileMapLayer workflow.

## Project Migration Audit — 4.6.3 → 4.7

Date: 2026-07-02.

| Area | Result |
|------|--------|
| Local binary | `/Applications/Godot 2.app/Contents/MacOS/Godot --version` returns `4.7.stable.official.5b4e0cb0f` |
| `project.godot` | `config/features=PackedStringArray("4.7")` |
| Deprecated API scan | No project `src/` hits for the 4.7 high-risk migration watch list |
| Risk | LOW for the current 2D ACT/GDScript gameplay path, HIGH for future engine-sensitive API suggestions because 4.7 is beyond model training data |

Scan terms used for the 4.7 audit included `RichTextLabel.add_image`,
`RichTextLabel.update_image`, `tap_back_pos`, `AudioEffectSpectrumAnalyzer`,
direct `InputEvent.device` comparisons, removed physics/particle server names,
and compatibility-sensitive override hooks.

## Verified Sources

- Official docs: https://docs.godotengine.org/en/4.7/
- 4.6→4.7 migration: https://docs.godotengine.org/en/4.7/tutorials/migrating/upgrading_to_godot_4.7.html
- Stable docs: https://docs.godotengine.org/en/stable/
- Release notes: https://godotengine.org/releases/4.7/
- Changelog: https://github.com/godotengine/godot/blob/master/CHANGELOG.md
- Interactive changelog: https://godotengine.github.io/godot-interactive-changelog/

## Migration Quick Reference

When upgrading or editing this project:

1. Use Godot 4.7 for editor scene/resource saves.
2. Do not save committed `.tscn`, `.tres`, `.import`, or `project.godot` files
   from Godot 4.6 after this upgrade.
3. Before changing version-sensitive APIs, check `breaking-changes.md` and
   `deprecated-apis.md`.
4. For visible gameplay/scene/animation changes, verify with Godot 4.7 CLI or
   MCP runtime, not the old 4.6.3 binary.

## For LLM Agents

**MANDATORY**: Before suggesting any Godot API call:

1. Check `deprecated-apis.md` in this directory.
2. Check `breaking-changes.md` for the relevant version transition.
3. If uncertain about an API, verify against official Godot 4.7 docs.
4. Never assume pre-4.7 API signatures are still valid.
