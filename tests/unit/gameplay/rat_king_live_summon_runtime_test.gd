## Rat King phase two live summon runtime integration.
extends GdUnitTestSuite

const MAIN_SCENE: PackedScene = preload("res://scenes/main.tscn")
const RAT_KING_BOSS_ID: StringName = &"boss_01_rat_king"
const RAT_MINION_CHARACTER_SCENE_PATH: String = "res://scenes/characters/rat_minion.tscn"
const RAT_MINION_CHARACTER_SCRIPT_PATH: String = "res://src/characters/rat_minion.gd"
const RAT_MINION_RUNTIME_SCENE_PATH: String = "res://src/gameplay/rat_minion.tscn"
const RAT_MINION_RUNTIME_SCRIPT_PATH: String = "res://src/gameplay/rat_minion.gd"
const RAT_MINION_SPRITE_FRAMES_PATH: String = (
	"res://assets/characters/rat_minion/rat_minion_sprite_frames.tres"
)
const REQUIRED_MINION_ANIMATIONS: Array[StringName] = [
	&"idle",
	&"run",
	&"attack",
	&"hurt",
	&"death",
]
const MIN_FRAMES_PER_ANIMATION: int = 3
const PHASE_TWO_DAMAGE: int = 120
const SUMMON_INTERVAL_SEC: float = 15.0
const PHASE_TRANSITION_BUFFER_SEC: float = 3.0

var scene: Node2D


func after_test() -> void:
	if is_instance_valid(scene):
		if scene.get_parent() != null:
			scene.get_parent().remove_child(scene)
		scene.free()
	scene = null


func test_rat_minion_character_asset_contract_uses_sprite_frames() -> void:
	assert_bool(FileAccess.file_exists(RAT_MINION_CHARACTER_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(RAT_MINION_CHARACTER_SCRIPT_PATH)).is_true()
	assert_bool(FileAccess.file_exists(RAT_MINION_SPRITE_FRAMES_PATH)).is_true()
	if not FileAccess.file_exists(RAT_MINION_CHARACTER_SCENE_PATH):
		return

	var minion_scene: PackedScene = load(RAT_MINION_CHARACTER_SCENE_PATH) as PackedScene
	assert_object(minion_scene).is_not_null()
	if minion_scene == null:
		return

	var minion := minion_scene.instantiate()
	add_child(minion)
	assert_bool(minion is AnimatedSprite2D).is_true()
	if not minion is AnimatedSprite2D:
		minion.queue_free()
		return

	var sprite := minion as AnimatedSprite2D
	assert_bool(sprite.sprite_frames != null).is_true()
	if sprite.sprite_frames == null:
		minion.queue_free()
		return
	assert_str(sprite.sprite_frames.resource_path).is_equal(RAT_MINION_SPRITE_FRAMES_PATH)

	for animation_name: StringName in REQUIRED_MINION_ANIMATIONS:
		assert_bool(sprite.sprite_frames.has_animation(animation_name)).is_true()
		if not sprite.sprite_frames.has_animation(animation_name):
			continue
		assert_int(sprite.sprite_frames.get_frame_count(animation_name)).is_greater_equal(
			MIN_FRAMES_PER_ANIMATION
		)
		assert_bool(
			_animation_frames_are_textured_and_same_size(sprite.sprite_frames, animation_name)
		).is_true()

	minion.queue_free()


func test_rat_minion_animation_assets_follow_project_pipeline_paths() -> void:
	for animation_name: StringName in REQUIRED_MINION_ANIMATIONS:
		for frame_index: int in range(MIN_FRAMES_PER_ANIMATION):
			var frame_path := "res://assets/characters/rat_minion/%s/rat_minion_%s_%03d.png" % [
				String(animation_name),
				String(animation_name),
				frame_index,
			]
			assert_bool(FileAccess.file_exists(frame_path)).is_true()


func test_rat_minion_runtime_scene_exposes_enemy_contract() -> void:
	assert_bool(FileAccess.file_exists(RAT_MINION_RUNTIME_SCENE_PATH)).is_true()
	assert_bool(FileAccess.file_exists(RAT_MINION_RUNTIME_SCRIPT_PATH)).is_true()
	if not FileAccess.file_exists(RAT_MINION_RUNTIME_SCENE_PATH):
		return

	var minion_scene: PackedScene = load(RAT_MINION_RUNTIME_SCENE_PATH) as PackedScene
	assert_object(minion_scene).is_not_null()
	if minion_scene == null:
		return

	var minion := minion_scene.instantiate()
	add_child(minion)
	assert_str(String(minion.get_script().resource_path)).is_equal(RAT_MINION_RUNTIME_SCRIPT_PATH)
	assert_bool(minion.has_signal("enemy_attack_landed")).is_true()
	assert_bool(minion.has_signal("enemy_defeated")).is_true()
	assert_bool(minion.has_method("configure_summon")).is_true()
	assert_bool(minion.has_method("set_attack_target")).is_true()
	assert_bool(minion.has_method("set_damage_calculator_adapter")).is_true()
	assert_bool(minion.has_method("request_attack")).is_true()
	assert_bool(minion.has_method("advance_attack_frames")).is_true()
	assert_bool(minion.has_method("apply_damage")).is_true()
	assert_bool(minion.has_method("kill_summon")).is_true()
	assert_bool(minion.has_method("get_entity_id")).is_true()
	assert_bool(minion.has_method("get_summon_owner_boss_id")).is_true()
	assert_bool(minion.has_method("get_current_hp")).is_true()
	assert_bool(minion.has_method("get_collision_component")).is_true()
	_assert_runtime_minion_sprite(minion)

	minion.queue_free()


func test_main_scene_spawns_live_phase_two_summon_from_boss_timer() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	_assert_main_scene_summon_adapter_contract(scene)
	if not scene.has_method("get_summoned_minion_nodes"):
		return

	var enemy := scene.get_node("Enemy")
	_enter_phase_two_and_advance(enemy, SUMMON_INTERVAL_SEC + PHASE_TRANSITION_BUFFER_SEC)

	assert_int(int(scene.call("get_active_summon_count", RAT_KING_BOSS_ID))).is_equal(1)
	var minions: Array = scene.call("get_summoned_minion_nodes")
	assert_int(minions.size()).is_equal(1)
	var minion: Node = minions[0] as Node
	assert_object(minion).is_not_null()
	if minion == null:
		return
	assert_bool(minion.is_visible_in_tree()).is_true()
	assert_str(String(minion.get_script().resource_path)).is_equal(RAT_MINION_RUNTIME_SCRIPT_PATH)
	assert_str(String(minion.call("get_summon_owner_boss_id"))).is_equal(String(RAT_KING_BOSS_ID))
	assert_str(String(enemy.get_node("Sprite").get("animation"))).is_equal("summon_minion")
	_assert_runtime_minion_sprite(minion)


func test_main_scene_enforces_summon_cap_and_replenishes_after_minion_death() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	_assert_main_scene_summon_adapter_contract(scene)
	if not scene.has_method("get_summoned_minion_nodes"):
		return

	var enemy := scene.get_node("Enemy")
	_enter_phase_two_and_advance(enemy, SUMMON_INTERVAL_SEC + PHASE_TRANSITION_BUFFER_SEC)
	enemy.call("advance_boss_runtime", SUMMON_INTERVAL_SEC)
	enemy.call("advance_boss_runtime", SUMMON_INTERVAL_SEC)

	assert_int(int(scene.call("get_active_summon_count", RAT_KING_BOSS_ID))).is_equal(2)
	var minions: Array = scene.call("get_summoned_minion_nodes")
	assert_int(minions.size()).is_equal(2)
	if minions.is_empty():
		return

	var first_minion: Node = minions[0] as Node
	first_minion.call("kill_summon", &"test_cleanup")
	assert_int(int(scene.call("get_active_summon_count", RAT_KING_BOSS_ID))).is_equal(1)

	enemy.call("advance_boss_runtime", SUMMON_INTERVAL_SEC)
	assert_int(int(scene.call("get_active_summon_count", RAT_KING_BOSS_ID))).is_equal(2)


func test_boss_death_cleans_up_live_summons() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	_assert_main_scene_summon_adapter_contract(scene)

	var enemy := scene.get_node("Enemy")
	_enter_phase_two_and_advance(enemy, SUMMON_INTERVAL_SEC + PHASE_TRANSITION_BUFFER_SEC)
	enemy.call("advance_boss_runtime", SUMMON_INTERVAL_SEC)
	assert_int(int(scene.call("get_active_summon_count", RAT_KING_BOSS_ID))).is_equal(2)

	var health: HealthComponent = enemy.call("get_health_component") as HealthComponent
	assert_object(health).is_not_null()
	if health == null:
		return
	health.apply_damage(999, {"source": &"summon_cleanup_test"})

	assert_int(int(scene.call("get_active_summon_count", RAT_KING_BOSS_ID))).is_equal(0)


func test_player_damage_adapter_routes_to_live_summon() -> void:
	scene = MAIN_SCENE.instantiate() as Node2D
	add_child(scene)
	_assert_main_scene_summon_adapter_contract(scene)
	if not scene.has_method("get_summoned_minion_nodes"):
		return

	var enemy := scene.get_node("Enemy")
	_enter_phase_two_and_advance(enemy, SUMMON_INTERVAL_SEC + PHASE_TRANSITION_BUFFER_SEC)
	var minions: Array = scene.call("get_summoned_minion_nodes")
	assert_int(minions.size()).is_equal(1)
	if minions.is_empty():
		return

	var minion: Node = minions[0] as Node
	var minion_entity_id: int = int(minion.call("get_entity_id"))
	var minion_hp: int = int(minion.call("get_current_hp"))
	assert_bool(bool(scene.call(
		"apply_damage",
		minion_entity_id,
		minion_hp,
		{"source": &"player_attack_test"}
	))).is_true()

	assert_int(int(scene.call("get_active_summon_count", RAT_KING_BOSS_ID))).is_equal(0)


func _assert_main_scene_summon_adapter_contract(main_scene: Node) -> void:
	assert_bool(main_scene.has_method("request_summon")).is_true()
	assert_bool(main_scene.has_method("get_active_summon_count")).is_true()
	assert_bool(main_scene.has_method("cleanup_summons")).is_true()
	assert_bool(main_scene.has_method("get_summoned_minion_nodes")).is_true()
	assert_bool(main_scene.has_method("apply_damage")).is_true()


func _enter_phase_two_and_advance(enemy: Node, runtime_delta_sec: float) -> void:
	var health: HealthComponent = enemy.call("get_health_component") as HealthComponent
	assert_object(health).is_not_null()
	if health == null:
		return
	health.apply_damage(PHASE_TWO_DAMAGE, {"source": &"summon_runtime_test"})
	enemy.call("advance_boss_runtime", 0.0)
	enemy.call("advance_boss_runtime", PHASE_TRANSITION_BUFFER_SEC)
	enemy.call("advance_boss_runtime", maxf(0.0, runtime_delta_sec - PHASE_TRANSITION_BUFFER_SEC))


func _assert_runtime_minion_sprite(minion: Node) -> void:
	var sprite: Node = minion.get_node_or_null("Sprite")
	assert_bool(sprite is AnimatedSprite2D).is_true()
	if not sprite is AnimatedSprite2D:
		return
	var animated_sprite := sprite as AnimatedSprite2D
	assert_bool(animated_sprite.sprite_frames != null).is_true()
	if animated_sprite.sprite_frames == null:
		return
	assert_str(animated_sprite.sprite_frames.resource_path).is_equal(RAT_MINION_SPRITE_FRAMES_PATH)
	for animation_name: StringName in REQUIRED_MINION_ANIMATIONS:
		assert_bool(animated_sprite.sprite_frames.has_animation(animation_name)).is_true()
		if animated_sprite.sprite_frames.has_animation(animation_name):
			assert_int(animated_sprite.sprite_frames.get_frame_count(animation_name)).is_greater_equal(
				MIN_FRAMES_PER_ANIMATION
			)


func _animation_frames_are_textured_and_same_size(
	sprite_frames: SpriteFrames,
	animation_name: StringName
) -> bool:
	var expected_size := Vector2.ZERO
	for frame_index: int in range(sprite_frames.get_frame_count(animation_name)):
		var texture := sprite_frames.get_frame_texture(animation_name, frame_index)
		if texture == null:
			return false
		var texture_size := texture.get_size()
		if expected_size == Vector2.ZERO:
			expected_size = texture_size
		elif texture_size != expected_size:
			return false
	return true
