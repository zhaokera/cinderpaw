## Combat Presentation Story037: shared RatMinion hurt/death frames stay readable.
extends GdUnitTestSuite

const FACTORY_SCENE: PackedScene = preload(
	"res://scenes/factory_route_transition_shell.tscn"
)
const FACTORY_SPARK_RAT_SCENE: PackedScene = preload(
	"res://src/gameplay/factory_spark_rat.tscn"
)
const HURT_ANIMATION: StringName = &"hurt"
const DEATH_ANIMATION: StringName = &"death"
const EXPECTED_HURT_FRAMES: int = 3
const EXPECTED_DEATH_FRAMES: int = 3
const EXPECTED_HURT_SPEED_FPS: float = 8.0
const EXPECTED_DEATH_SPEED_FPS: float = 6.0
const HIT_FLASH_RELEASE_MS: int = 70
const HURT_SIGNAL_TIMEOUT_MS: int = 500
const HURT_RECOVERY_MS: int = 60
const DEATH_SIGNAL_TIMEOUT_MS: int = 700
const CORPSE_HOLD_PROBE_MS: int = 1900
const CLEANUP_PROBE_MS: int = 350

var _spawned_nodes: Array[Node] = []


func after_test() -> void:
	for node: Node in _spawned_nodes:
		if not is_instance_valid(node):
			continue
		if node.get_parent() != null:
			node.get_parent().remove_child(node)
		node.free()
	_spawned_nodes.clear()


func test_shared_rat_plays_full_hurt_and_death_before_corpse_cleanup() -> void:
	var rat: CharacterBody2D = FACTORY_SPARK_RAT_SCENE.instantiate() as CharacterBody2D
	add_child(rat)
	_spawned_nodes.append(rat)
	var sprite: AnimatedSprite2D = rat.get_node_or_null("Sprite") as AnimatedSprite2D
	var health: HealthComponent = rat.get_node_or_null("HealthComponent") as HealthComponent
	assert_that(sprite).is_not_null()
	assert_that(health).is_not_null()
	if sprite == null or health == null:
		return

	var frames: SpriteFrames = sprite.sprite_frames
	assert_int(frames.get_frame_count(HURT_ANIMATION)).is_equal(EXPECTED_HURT_FRAMES)
	assert_float(frames.get_animation_speed(HURT_ANIMATION)).is_equal_approx(
		EXPECTED_HURT_SPEED_FPS,
		0.001
	)
	assert_int(frames.get_frame_count(DEATH_ANIMATION)).is_equal(EXPECTED_DEATH_FRAMES)
	assert_float(frames.get_animation_speed(DEATH_ANIMATION)).is_equal_approx(
		EXPECTED_DEATH_SPEED_FPS,
		0.001
	)

	var observed_hurt_frames: Array[int] = []
	var observed_death_frames: Array[int] = []
	var health_events: Array[String] = []
	var record_frame: Callable = func() -> void:
		if sprite.animation == HURT_ANIMATION and not observed_hurt_frames.has(sprite.frame):
			observed_hurt_frames.append(sprite.frame)
		elif sprite.animation == DEATH_ANIMATION and not observed_death_frames.has(sprite.frame):
			observed_death_frames.append(sprite.frame)
	sprite.frame_changed.connect(record_frame)
	health.on_hp_changed.connect(func(_id: int, current_hp: int, _max_hp: int) -> void:
		health_events.append("hp:%d" % current_hp)
	)
	health.on_death.connect(func(_id: int, _metadata: Dictionary) -> void:
		health_events.append("death")
	)

	rat.call("apply_damage", 12, {"source": &"story037_hurt_probe"})
	_record_current_frame(sprite, HURT_ANIMATION, observed_hurt_frames)
	assert_that(sprite.animation).is_equal(HURT_ANIMATION)
	assert_float(sprite.modulate.g).is_equal_approx(0.9, 0.001)
	assert_array(health_events).contains_exactly(["hp:12"])

	await await_millis(HIT_FLASH_RELEASE_MS)
	assert_that(sprite.animation).override_failure_message(
		"RatMinion hurt animation must outlive the three-frame hit flash"
	).is_equal(HURT_ANIMATION)
	assert_float(sprite.modulate.g).override_failure_message(
		"Character hit flash must return to normal after three physics frames"
	).is_equal_approx(1.0, 0.001)

	await await_signal_on(sprite, "frame_changed", [], HURT_SIGNAL_TIMEOUT_MS)
	await await_signal_on(sprite, "frame_changed", [], HURT_SIGNAL_TIMEOUT_MS)
	assert_array(observed_hurt_frames).contains_exactly([0, 1, 2])
	await await_signal_on(sprite, "animation_finished", [], HURT_SIGNAL_TIMEOUT_MS)
	await await_millis(HURT_RECOVERY_MS)
	assert_that(sprite.animation).is_not_equal(HURT_ANIMATION)

	rat.call("apply_damage", 12, {"source": &"story037_death_probe"})
	_record_current_frame(sprite, DEATH_ANIMATION, observed_death_frames)
	assert_that(sprite.animation).is_equal(DEATH_ANIMATION)
	assert_bool(rat.visible).is_true()
	assert_array(health_events).contains_exactly(["hp:12", "hp:0", "death"])

	await await_signal_on(sprite, "frame_changed", [], DEATH_SIGNAL_TIMEOUT_MS)
	await await_signal_on(sprite, "frame_changed", [], DEATH_SIGNAL_TIMEOUT_MS)
	await await_signal_on(sprite, "animation_finished", [], DEATH_SIGNAL_TIMEOUT_MS)
	assert_bool(is_instance_valid(rat)).is_true()
	if not is_instance_valid(rat):
		return
	assert_array(observed_death_frames).override_failure_message(
		"All three death frames must display at full opacity before corpse hold"
	).contains_exactly([0, 1, 2])
	assert_int(sprite.frame).is_equal(2)
	assert_float(sprite.modulate.a).is_equal_approx(1.0, 0.02)

	await await_millis(CORPSE_HOLD_PROBE_MS)
	assert_bool(is_instance_valid(rat)).is_true()
	if not is_instance_valid(rat):
		return
	assert_bool(rat.visible).is_true()
	assert_float(sprite.modulate.a).is_equal_approx(1.0, 0.02)

	await await_millis(CLEANUP_PROBE_MS)
	assert_bool(is_instance_valid(rat)).override_failure_message(
		"RatMinion must clean up after the two-second corpse hold and short fade"
	).is_false()

	var factory: Node2D = FACTORY_SCENE.instantiate() as Node2D
	add_child(factory)
	_spawned_nodes.append(factory)
	factory.set_process(false)
	factory.set_physics_process(false)
	var factory_rat: CharacterBody2D = factory.get_node("FactorySparkRat") as CharacterBody2D
	factory_rat.visible = true
	factory_rat.call("apply_damage", 24, {"source": &"story037_factory_death_probe"})
	var factory_sprite: AnimatedSprite2D = factory_rat.get_node("Sprite") as AnimatedSprite2D
	var factory_collision: CollisionComponent = factory_rat.call(
		"get_collision_component"
	) as CollisionComponent
	assert_bool(factory_rat.visible).override_failure_message(
		"Factory defeat callback must not hide the shared RatMinion death presentation"
	).is_true()
	assert_that(factory_sprite.animation).is_equal(DEATH_ANIMATION)
	assert_bool(factory_rat.is_physics_processing()).is_false()
	assert_str(String(factory_collision.get_hurtbox_state())).is_equal("gone")


func _record_current_frame(
	sprite: AnimatedSprite2D,
	animation_name: StringName,
	observed_frames: Array[int]
) -> void:
	if sprite.animation != animation_name or observed_frames.has(sprite.frame):
		return
	observed_frames.append(sprite.frame)
