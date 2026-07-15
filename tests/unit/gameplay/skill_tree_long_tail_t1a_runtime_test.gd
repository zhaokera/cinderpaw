## Story149: selectable second skill node and Long Tail T1-A range modifier.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const CAT_CLAW_T1A_SKILL_ID: StringName = &"cat_claw_t1a"
const CAT_CLAW_T1B_SKILL_ID: StringName = &"cat_claw_t1b"
const LONG_TAIL_T1A_SKILL_ID: StringName = &"long_tail_t1a"
const LONG_TAIL_RANGE_BONUS_TILES: float = 0.3
const LONG_TAIL_BASE_RANGE_TILES: float = 2.0
const LONG_TAIL_BASE_HITBOX_WIDTH_PX: float = 64.0
const COMBAT_TILE_SIZE_PX: float = 32.0

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


func test_skill_tree_can_select_and_persist_long_tail_t1a() -> void:
	var hud: Node = scene.get_node("HUD")
	scene.call("grant_skill_points", 2)
	scene.call("show_skill_tree_menu")

	var has_selection_api: bool = (
		hud.has_method("get_active_skill_tree_entry_id")
		and hud.has_method("select_next_skill_tree_entry")
	)
	assert_bool(has_selection_api).is_true()
	if not has_selection_api:
		return

	assert_str(String(hud.call("get_active_skill_tree_entry_id"))).is_equal(
		String(CAT_CLAW_T1A_SKILL_ID)
	)
	assert_bool(bool(hud.call("select_next_skill_tree_entry"))).is_true()
	assert_str(String(hud.call("get_active_skill_tree_entry_id"))).is_equal(
		String(CAT_CLAW_T1B_SKILL_ID)
	)
	assert_bool(bool(hud.call("select_next_skill_tree_entry"))).is_true()
	assert_str(String(hud.call("get_active_skill_tree_entry_id"))).is_equal(
		String(LONG_TAIL_T1A_SKILL_ID)
	)
	assert_str(String(hud.call("get_skill_unlock_button_text"))).is_equal("Learn Extended Sweep")
	assert_str(String(hud.call("get_menu_subtitle"))).contains("Long Tail T1")
	assert_str(String(hud.call("get_menu_subtitle"))).contains("range by 0.3 tile")

	assert_bool(bool(scene.call("try_unlock_skill", LONG_TAIL_T1A_SKILL_ID))).is_true()
	assert_bool(bool(scene.call("try_unlock_skill", LONG_TAIL_T1A_SKILL_ID))).is_false()
	assert_int(int(scene.call("get_skill_points"))).is_equal(1)
	assert_str(String(hud.call("get_active_skill_tree_entry_id"))).is_equal(
		String(LONG_TAIL_T1A_SKILL_ID)
	)
	assert_str(String(hud.call("get_skill_unlock_button_text"))).is_equal("Extended Sweep learned")

	var snapshot: Dictionary = scene.call("capture_save_snapshot")
	var restored_scene: Node2D = MAIN_SCENE.instantiate() as Node2D
	add_child(restored_scene)
	restored_scene.call("restore_save_snapshot", snapshot)
	assert_bool(bool(restored_scene.call("has_skill", LONG_TAIL_T1A_SKILL_ID))).is_true()
	assert_bool(bool(restored_scene.call("has_skill", CAT_CLAW_T1A_SKILL_ID))).is_false()
	assert_int(int(restored_scene.call("get_skill_points"))).is_equal(1)
	restored_scene.get_parent().remove_child(restored_scene)
	restored_scene.free()


func test_long_tail_t1a_extends_only_first_light_attack_core_hitbox() -> void:
	var player: Node = scene.get_node("Player")
	var combat: Node = player.call("get_combat_component")
	var collision: Node = player.call("get_collision_component")

	scene.call("grant_skill_points", 1)
	assert_bool(bool(scene.call("try_unlock_skill", LONG_TAIL_T1A_SKILL_ID))).is_true()
	assert_bool(bool(scene.call("request_weapon_swap"))).is_true()
	scene.call("advance_weapon_swap_time", 0.5)

	assert_bool(bool(player.call("request_attack"))).is_true()
	var hitbox: Area2D = collision.call("get_hitbox", &"long_tail_light") as Area2D
	var first_metadata: Dictionary = hitbox.call("get_attack_metadata")
	assert_int(int(first_metadata.get("combo_index", -1))).is_equal(0)
	assert_float(float(first_metadata.get("skill_range_tiles", 0.0))).is_equal_approx(
		LONG_TAIL_RANGE_BONUS_TILES,
		0.001
	)
	assert_float(float(first_metadata.get("attack_range", 0.0))).is_equal_approx(
		LONG_TAIL_BASE_RANGE_TILES + LONG_TAIL_RANGE_BONUS_TILES,
		0.001
	)
	assert_float(float(hitbox.call("get_hitbox_size").x)).is_equal_approx(
		LONG_TAIL_BASE_HITBOX_WIDTH_PX + LONG_TAIL_RANGE_BONUS_TILES * COMBAT_TILE_SIZE_PX,
		0.001
	)

	combat.call("advance_attack_frames", 4)
	assert_bool(bool(player.call("request_attack"))).is_true()
	var second_metadata: Dictionary = hitbox.call("get_attack_metadata")
	assert_int(int(second_metadata.get("combo_index", -1))).is_equal(1)
	assert_float(float(second_metadata.get("skill_range_tiles", -1.0))).is_equal_approx(0.0, 0.001)
	assert_float(float(second_metadata.get("attack_range", 0.0))).is_equal_approx(
		LONG_TAIL_BASE_RANGE_TILES,
		0.001
	)
	assert_float(float(hitbox.call("get_hitbox_size").x)).is_equal_approx(
		LONG_TAIL_BASE_HITBOX_WIDTH_PX,
		0.001
	)


func test_long_tail_t1a_does_not_change_cat_claw_first_attack() -> void:
	var player: Node = scene.get_node("Player")
	var collision: Node = player.call("get_collision_component")

	scene.call("grant_skill_points", 1)
	assert_bool(bool(scene.call("try_unlock_skill", LONG_TAIL_T1A_SKILL_ID))).is_true()
	assert_bool(bool(player.call("request_attack"))).is_true()

	var hitbox: Area2D = collision.call("get_hitbox", &"cat_claw_light") as Area2D
	var metadata: Dictionary = hitbox.call("get_attack_metadata")
	assert_float(float(metadata.get("skill_range_tiles", -1.0))).is_equal_approx(0.0, 0.001)
	assert_float(float(metadata.get("attack_range", 0.0))).is_equal_approx(1.0, 0.001)
	assert_float(float(hitbox.call("get_hitbox_size").x)).is_equal_approx(32.0, 0.001)
