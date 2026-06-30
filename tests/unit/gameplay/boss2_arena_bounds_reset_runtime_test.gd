## Story 026: Boss2 arena bounds and reset semantics.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const BOSS_NODE_NAME: String = "Boss2EchoGuardian"
const BOSS2_ENTITY_ID: int = 2200
const RUN_ANIMATION: StringName = &"run"
const IDLE_ANIMATION: StringName = &"idle"
const BOSS2_MAX_HP: int = 36

var scene: Node2D


func before_test() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_boss2_chase_clamps_inside_local_arena_bounds() -> void:
	var boss: Node2D = scene.get_node(BOSS_NODE_NAME) as Node2D
	var player: Node2D = scene.get_node("Player") as Node2D
	assert_bool(boss.has_method("advance_behavior_frames")).is_true()
	assert_bool(boss.has_method("get_auto_pressure_diagnostics")).is_true()
	assert_bool(boss.has_method("set_attack_target")).is_true()
	if not (
		boss.has_method("advance_behavior_frames")
		and boss.has_method("get_auto_pressure_diagnostics")
		and boss.has_method("set_attack_target")
	):
		return

	var initial_diagnostics: Dictionary = boss.call("get_auto_pressure_diagnostics")
	assert_bool(initial_diagnostics.has("arena_min_x")).is_true()
	assert_bool(initial_diagnostics.has("arena_max_x")).is_true()
	assert_bool(initial_diagnostics.has("arena_anchor_position")).is_true()
	if not initial_diagnostics.has("arena_min_x"):
		return

	var arena_min_x: float = float(initial_diagnostics.get("arena_min_x", 0.0))
	player.global_position = Vector2(arena_min_x - 120.0, boss.global_position.y)
	boss.global_position = Vector2(arena_min_x + 4.0, boss.global_position.y)
	boss.call("set_attack_target", player)
	boss.call("advance_behavior_frames", 12)

	var diagnostics: Dictionary = boss.call("get_auto_pressure_diagnostics")
	assert_float(boss.global_position.x).is_greater_equal(arena_min_x)
	assert_bool(bool(diagnostics.get("is_chasing", false))).is_true()
	assert_str(String(diagnostics.get("behavior_phase", ""))).is_equal("chase")
	assert_str(String((boss.get_node("Sprite") as AnimatedSprite2D).animation)).is_equal(String(RUN_ANIMATION))


func test_boss2_leash_return_moves_back_to_anchor_and_settles_idle() -> void:
	var boss: Node2D = scene.get_node(BOSS_NODE_NAME) as Node2D
	var player: Node2D = scene.get_node("Player") as Node2D
	var sprite := boss.get_node("Sprite") as AnimatedSprite2D
	assert_bool(boss.has_method("advance_behavior_frames")).is_true()
	assert_bool(boss.has_method("get_auto_pressure_diagnostics")).is_true()
	assert_bool(boss.has_method("set_attack_target")).is_true()
	if not (
		boss.has_method("advance_behavior_frames")
		and boss.has_method("get_auto_pressure_diagnostics")
		and boss.has_method("set_attack_target")
	):
		return

	var initial_diagnostics: Dictionary = boss.call("get_auto_pressure_diagnostics")
	assert_bool(initial_diagnostics.has("arena_anchor_position")).is_true()
	if not initial_diagnostics.has("arena_anchor_position"):
		return
	var anchor_position: Vector2 = initial_diagnostics.get("arena_anchor_position", boss.global_position)

	boss.global_position = anchor_position + Vector2(-96.0, 0.0)
	player.global_position = anchor_position + Vector2(640.0, 0.0)
	boss.call("set_attack_target", player)
	boss.call("advance_behavior_frames", 1)
	var returning_diagnostics: Dictionary = boss.call("get_auto_pressure_diagnostics")
	assert_bool(bool(returning_diagnostics.get("is_returning_to_anchor", false))).is_true()
	assert_str(String(returning_diagnostics.get("behavior_phase", ""))).is_equal("return")
	assert_float(boss.global_position.x).is_greater(anchor_position.x - 96.0)

	boss.call("advance_behavior_frames", 64)
	var settled_diagnostics: Dictionary = boss.call("get_auto_pressure_diagnostics")
	assert_bool(bool(settled_diagnostics.get("is_returning_to_anchor", true))).is_false()
	assert_str(String(settled_diagnostics.get("behavior_phase", ""))).is_equal("idle")
	assert_float(boss.global_position.x).is_equal_approx(anchor_position.x, 0.01)
	assert_str(String(sprite.animation)).is_equal(String(IDLE_ANIMATION))


func test_boss2_reset_encounter_restores_arena_anchor_and_clears_pressure() -> void:
	var boss: Node2D = scene.get_node(BOSS_NODE_NAME) as Node2D
	var player: Node2D = scene.get_node("Player") as Node2D
	assert_bool(boss.has_method("reset_encounter")).is_true()
	assert_bool(boss.has_method("advance_behavior_frames")).is_true()
	assert_bool(boss.has_method("get_auto_pressure_diagnostics")).is_true()
	assert_bool(boss.has_method("set_attack_target")).is_true()
	if not (
		boss.has_method("reset_encounter")
		and boss.has_method("advance_behavior_frames")
		and boss.has_method("get_auto_pressure_diagnostics")
		and boss.has_method("set_attack_target")
	):
		return

	var initial_diagnostics: Dictionary = boss.call("get_auto_pressure_diagnostics")
	assert_bool(initial_diagnostics.has("arena_anchor_position")).is_true()
	if not initial_diagnostics.has("arena_anchor_position"):
		return
	var anchor_position: Vector2 = initial_diagnostics.get("arena_anchor_position", boss.global_position)

	player.global_position = anchor_position + Vector2(-180.0, 0.0)
	boss.global_position = anchor_position + Vector2(-72.0, 0.0)
	boss.call("set_attack_target", player)
	boss.call("advance_behavior_frames", 1)

	boss.call("reset_encounter")
	var diagnostics: Dictionary = boss.call("get_auto_pressure_diagnostics")
	assert_float(boss.global_position.x).is_equal_approx(anchor_position.x, 0.01)
	assert_float(boss.global_position.y).is_equal_approx(anchor_position.y, 0.01)
	assert_bool(bool(diagnostics.get("is_chasing", true))).is_false()
	assert_bool(bool(diagnostics.get("is_returning_to_anchor", true))).is_false()
	assert_str(String(diagnostics.get("behavior_phase", ""))).is_equal("idle")
	assert_str(String((boss.get_node("Sprite") as AnimatedSprite2D).animation)).is_equal(String(IDLE_ANIMATION))


func test_main_scene_boss_arena_reset_restores_live_boss2_entry_snapshot() -> void:
	var boss: Node2D = scene.get_node(BOSS_NODE_NAME) as Node2D
	var player: Node2D = scene.get_node("Player") as Node2D
	var sprite := boss.get_node("Sprite") as AnimatedSprite2D
	assert_bool(scene.has_method("capture_boss_arena_snapshot")).is_true()
	assert_bool(scene.has_method("reset_boss_arena_to_snapshot")).is_true()
	assert_bool(scene.has_method("apply_damage")).is_true()
	assert_bool(boss.has_method("advance_behavior_frames")).is_true()
	assert_bool(boss.has_method("get_auto_pressure_diagnostics")).is_true()
	assert_bool(boss.has_method("request_attack")).is_true()
	if not (
		scene.has_method("capture_boss_arena_snapshot")
		and scene.has_method("reset_boss_arena_to_snapshot")
		and scene.has_method("apply_damage")
		and boss.has_method("advance_behavior_frames")
		and boss.has_method("get_auto_pressure_diagnostics")
		and boss.has_method("request_attack")
	):
		return

	var entry_snapshot: Dictionary = scene.call("capture_boss_arena_snapshot")
	assert_bool(entry_snapshot.has("boss2_echo_guardian")).is_true()
	if not entry_snapshot.has("boss2_echo_guardian"):
		return
	var entry_diagnostics: Dictionary = boss.call("get_auto_pressure_diagnostics")
	var anchor_position: Vector2 = entry_diagnostics.get("arena_anchor_position", boss.global_position)

	player.global_position = anchor_position + Vector2(-180.0, 0.0)
	boss.global_position = anchor_position + Vector2(-84.0, 0.0)
	boss.call("set_attack_target", player)
	assert_bool(bool(boss.call("request_attack"))).is_true()
	assert_bool(scene.call("apply_damage", BOSS2_ENTITY_ID, 14, {
		"source": &"unit_test_boss2_arena_reset",
	})).is_true()
	assert_int(int(boss.call("get_current_hp"))).is_less(BOSS2_MAX_HP)
	assert_str(String(boss.call("get_attack_phase"))).is_not_equal("idle")

	scene.call("reset_boss_arena_to_snapshot", entry_snapshot)
	var reset_diagnostics: Dictionary = boss.call("get_auto_pressure_diagnostics")
	var collision: CollisionComponent = boss.call("get_collision_component") as CollisionComponent
	assert_int(int(boss.call("get_current_hp"))).is_equal(BOSS2_MAX_HP)
	assert_float(boss.global_position.x).is_equal_approx(anchor_position.x, 0.01)
	assert_float(boss.global_position.y).is_equal_approx(anchor_position.y, 0.01)
	assert_str(String(boss.call("get_attack_phase"))).is_equal("idle")
	assert_str(String(reset_diagnostics.get("behavior_phase", ""))).is_equal("idle")
	assert_bool(bool(reset_diagnostics.get("is_chasing", true))).is_false()
	assert_bool(bool(reset_diagnostics.get("is_returning_to_anchor", true))).is_false()
	assert_str(String(sprite.animation)).is_equal(String(IDLE_ANIMATION))
	assert_that(collision).is_not_null()
	if collision != null:
		assert_bool(collision.is_hitbox_active(&"boss2_echo_swipe")).is_false()
		assert_str(String(collision.get_hurtbox_state())).is_equal("normal")


func test_boss2_defeated_progress_is_not_revived_by_arena_reset() -> void:
	var boss: Node2D = scene.get_node(BOSS_NODE_NAME) as Node2D
	var hud: Node = scene.get_node("HUD")
	assert_bool(scene.has_method("capture_boss_arena_snapshot")).is_true()
	assert_bool(scene.has_method("reset_boss_arena_to_snapshot")).is_true()
	assert_bool(scene.has_method("set_world_progress_flag")).is_true()
	assert_bool(hud.has_method("get_boss_label_text")).is_true()
	if not (
		scene.has_method("capture_boss_arena_snapshot")
		and scene.has_method("reset_boss_arena_to_snapshot")
		and scene.has_method("set_world_progress_flag")
		and hud.has_method("get_boss_label_text")
	):
		return

	var entry_snapshot: Dictionary = scene.call("capture_boss_arena_snapshot")
	var original_position: Vector2 = boss.global_position
	scene.call("set_world_progress_flag", &"boss_02_echo_guardian_defeated", true)
	boss.global_position = original_position + Vector2(-120.0, 0.0)

	scene.call("reset_boss_arena_to_snapshot", entry_snapshot)
	var diagnostics: Dictionary = boss.call("get_auto_pressure_diagnostics")
	var label: String = String(hud.call("get_boss_label_text"))
	assert_bool(bool(diagnostics.get("defeated", false))).is_true()
	assert_str(String(diagnostics.get("behavior_phase", ""))).is_equal("defeated")
	assert_bool(bool(diagnostics.get("is_chasing", true))).is_false()
	assert_bool(boss.visible).is_false()
	assert_bool(label.contains("Echo Guardian")).is_false()
	assert_str(label).contains("垃圾桶鼠王")
