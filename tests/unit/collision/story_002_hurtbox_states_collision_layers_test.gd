## Story 002: Hurtbox states and collision layer configuration.
extends GdUnitTestSuite

const COLLISION_COMPONENT_SCRIPT: Script = preload("res://src/core/collision_component.gd")

var collision


func before_test() -> void:
	collision = COLLISION_COMPONENT_SCRIPT.new()
	add_child(collision)


func after_test() -> void:
	if is_instance_valid(collision):
		if collision.get_parent() != null:
			collision.get_parent().remove_child(collision)
		collision.free()
	collision = null


func test_hurtbox_state_transitions_apply_monitorable_and_size() -> void:
	collision.configure_entity(101, &"player")
	collision.set_hurtbox_size(Vector2(24, 48))

	collision.set_hurtbox_state(&"normal")

	assert_bool(collision.get_hurtbox().monitorable).is_true()
	assert_float(collision.get_hurtbox_size().x).is_equal(24.0)
	assert_float(collision.get_hurtbox_size().y).is_equal(48.0)

	collision.set_hurtbox_state(&"shrunk")

	assert_bool(collision.get_hurtbox().monitorable).is_true()
	assert_float(collision.get_hurtbox_size().x).is_equal(12.0)
	assert_float(collision.get_hurtbox_size().y).is_equal(24.0)

	collision.set_hurtbox_state(&"gone")

	assert_bool(collision.get_hurtbox().monitorable).is_false()


func test_unknown_hurtbox_state_falls_back_to_normal() -> void:
	collision.configure_entity(101, &"player")
	collision.set_hurtbox_size(Vector2(30, 50))

	collision.set_hurtbox_state(&"missing_state")

	assert_str(String(collision.get_hurtbox_state())).is_equal("normal")
	assert_bool(collision.get_hurtbox().monitorable).is_true()
	assert_float(collision.get_hurtbox_size().x).is_equal(30.0)
	assert_float(collision.get_hurtbox_size().y).is_equal(50.0)


func test_collision_layer_constants_match_adr_bitmasks() -> void:
	assert_int(COLLISION_COMPONENT_SCRIPT.COLLISION_LAYER_PLAYER_ATTACK).is_equal(1)
	assert_int(COLLISION_COMPONENT_SCRIPT.COLLISION_LAYER_ENEMY_ATTACK).is_equal(2)
	assert_int(COLLISION_COMPONENT_SCRIPT.COLLISION_LAYER_PLAYER_HURT).is_equal(4)
	assert_int(COLLISION_COMPONENT_SCRIPT.COLLISION_LAYER_ENEMY_HURT).is_equal(8)
	assert_int(COLLISION_COMPONENT_SCRIPT.COLLISION_LAYER_ENVIRONMENT).is_equal(16)

	assert_int(COLLISION_COMPONENT_SCRIPT.COLLISION_MASK_PLAYER_ATTACK).is_equal(8)
	assert_int(COLLISION_COMPONENT_SCRIPT.COLLISION_MASK_ENEMY_ATTACK).is_equal(4)
	assert_int(COLLISION_COMPONENT_SCRIPT.COLLISION_MASK_ENVIRONMENT).is_equal(12)


func test_player_configuration_applies_hitbox_and_hurtbox_layers() -> void:
	collision.configure_entity(101, &"player")
	var hitbox: Area2D = collision.get_hitbox(&"slash_1")
	var hurtbox: Area2D = collision.get_hurtbox()

	assert_int(collision.get_entity_id()).is_equal(101)
	assert_str(String(collision.get_allegiance())).is_equal("player")
	assert_int(hitbox.collision_layer).is_equal(COLLISION_COMPONENT_SCRIPT.COLLISION_LAYER_PLAYER_ATTACK)
	assert_int(hitbox.collision_mask).is_equal(COLLISION_COMPONENT_SCRIPT.COLLISION_MASK_PLAYER_ATTACK)
	assert_int(hurtbox.collision_layer).is_equal(COLLISION_COMPONENT_SCRIPT.COLLISION_LAYER_PLAYER_HURT)
	assert_int(hurtbox.collision_mask).is_equal(0)


func test_enemy_configuration_applies_to_existing_hitboxes() -> void:
	var hitbox: Area2D = collision.get_hitbox(&"bite")

	collision.configure_entity(202, &"enemy")
	var hurtbox: Area2D = collision.get_hurtbox()

	assert_int(collision.get_entity_id()).is_equal(202)
	assert_str(String(collision.get_allegiance())).is_equal("enemy")
	assert_int(hitbox.collision_layer).is_equal(COLLISION_COMPONENT_SCRIPT.COLLISION_LAYER_ENEMY_ATTACK)
	assert_int(hitbox.collision_mask).is_equal(COLLISION_COMPONENT_SCRIPT.COLLISION_MASK_ENEMY_ATTACK)
	assert_int(hurtbox.collision_layer).is_equal(COLLISION_COMPONENT_SCRIPT.COLLISION_LAYER_ENEMY_HURT)
	assert_int(hurtbox.collision_mask).is_equal(0)
