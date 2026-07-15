## Headless Story156 smoke for the Main Rat King to Boss2 handoff.
extends SceneTree

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const RAT_KING_DEFEATED_FLAG: StringName = &"boss_rat_king_defeated"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var main := MAIN_SCENE.instantiate() as Node2D
	root.add_child(main)
	await process_frame

	var initial: Dictionary = main.call("get_boss2_encounter_handoff_diagnostics")
	if (
		not bool(initial.get("rat_king_visible", false))
		or bool(initial.get("boss2_encounter_active", true))
		or bool(initial.get("boss2_visible", true))
		or bool(initial.get("boss2_arena_frame_visible", true))
		or bool(initial.get("boss2_room_seals_enabled", true))
		or bool(initial.get("boss2_camera_lock_enabled", true))
		or not String(initial.get("boss_hud_label", "")).contains("垃圾桶鼠王")
	):
		_fail("initial_rat_king_contract_failed", initial)
		return

	main.call("set_world_progress_flag", RAT_KING_DEFEATED_FLAG, true)
	await process_frame
	var activated: Dictionary = main.call("get_boss2_encounter_handoff_diagnostics")
	var boss: Node = main.get_node_or_null("Boss2EchoGuardian")
	var sprite := (
		boss.get_node_or_null("Sprite") as AnimatedSprite2D
		if boss != null
		else null
	)
	var animation_frame_count: int = (
		sprite.sprite_frames.get_frame_count(sprite.animation)
		if sprite != null and sprite.sprite_frames != null
		else 0
	)
	activated["sprite_type"] = sprite.get_class() if sprite != null else "missing"
	activated["animation"] = String(sprite.animation) if sprite != null else "missing"
	activated["animation_frame_count"] = animation_frame_count
	print("main_scene_sequential_boss_handoff_diagnostics=", JSON.stringify(activated))
	if (
		bool(activated.get("rat_king_visible", true))
		or not bool(activated.get("boss2_encounter_active", false))
		or not bool(activated.get("boss2_visible", false))
		or not bool(activated.get("boss2_has_target", false))
		or int(activated.get("boss2_collision_layer", 0)) <= 0
		or not bool(activated.get("boss2_arena_frame_visible", false))
		or not bool(activated.get("boss2_room_seals_enabled", false))
		or not bool(activated.get("boss2_camera_lock_enabled", false))
		or not String(activated.get("boss_hud_label", "")).contains("Echo Guardian")
		or sprite == null
		or animation_frame_count < 3
	):
		_fail("activated_boss2_contract_failed", activated)
		return

	print("main_scene_sequential_boss_handoff_smoke=passed")
	_cleanup(main)
	await process_frame
	quit(0)


func _cleanup(main: Node) -> void:
	if main != null and is_instance_valid(main):
		if main.get_parent() != null:
			main.get_parent().remove_child(main)
		main.free()


func _fail(reason: String, diagnostics: Dictionary) -> void:
	push_error("main_scene_sequential_boss_handoff_smoke=%s %s" % [
		reason,
		JSON.stringify(diagnostics),
	])
	quit(1)
