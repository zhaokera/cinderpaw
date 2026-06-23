# GdUnit4 test runner - invoked by CI and /smoke-check.
# Deprecated wrapper. Use the GdUnit4 command tool directly:
# godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit --ignoreHeadlessMode
extends SceneTree

func _init() -> void:
	push_error(
		"tests/gdunit4_runner.gd is deprecated. Use: godot --headless --path . -s res://addons/gdUnit4/bin/GdUnitCmdTool.gd -a res://tests/unit --ignoreHeadlessMode"
	)
	quit(1)
