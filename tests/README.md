# Test Infrastructure

**Engine**: Godot 4.6.3
**Test Framework**: GdUnit4
**CI**: `.github/workflows/tests.yml`
**Setup date**: 2026-06-21

## Directory Layout

```
tests/
  unit/           # Isolated unit tests (formulas, state machines, logic)
  integration/    # Cross-system and save/load tests
  smoke/          # Critical path test list for /smoke-check gate
  evidence/       # Screenshot logs and manual test sign-off records
```

## Installing GdUnit4

1. Open Godot → AssetLib → search "GdUnit4" → Download & Install
2. Enable the plugin: Project → Project Settings → Plugins → GdUnit4 ✓
3. Restart the editor
4. Verify: `res://addons/gdunit4/` exists

## Running Tests

### In Editor
- GdUnit4 panel (bottom dock) → Run All Tests

### Headless (CI)
```bash
godot --headless --script tests/gdunit4_runner.gd
```

### Single Test File
```bash
godot --headless --script tests/gdunit4_runner.gd --test tests/unit/combat/
```

## Test Naming

- **Files**: `[system]_[feature]_test.gd`
- **Functions**: `test_[scenario]_[expected]`
- **Example**: `damage_calculation_formula_test.gd` → `test_base_attack_returns_expected_damage()`

## Story Type → Test Evidence

| Story Type | Required Evidence | Location |
|---|---|---|
| Logic | Automated unit test — must pass | `tests/unit/[system]/` |
| Integration | Integration test OR playtest doc | `tests/integration/[system]/` |
| Visual/Feel | Screenshot + lead sign-off | `tests/evidence/` |
| UI | Manual walkthrough OR interaction test | `tests/evidence/` |
| Config/Data | Smoke check pass | `production/qa/smoke-*.md` |

## CI

Tests run automatically on every push to `main` and on every pull request.
A failed test suite blocks merging.

## Test Conventions (from coding-standards.md)

- **Determinism**: Tests must produce the same result every run
- **Isolation**: Each test sets up and tears down its own state
- **No hardcoded data**: Use constant files or factory functions
- **Independence**: Unit tests do not call external APIs or file I/O
