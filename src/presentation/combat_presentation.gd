## Presentation-layer combat feedback for hit impact, damage numbers, and shake.
extends Node2D
class_name CombatPresentation

const NORMAL_HITSTOP_FRAMES: int = 3
const CRIT_HITSTOP_FRAMES: int = 6
const KILL_HITSTOP_FRAMES: int = 6
const NORMAL_SHAKE_INTENSITY: float = 2.0
const CRIT_SHAKE_INTENSITY: float = 5.0
const KILL_SHAKE_INTENSITY: float = 5.0
const DAMAGE_NUMBER_LIFETIME_SEC: float = 1.5
const SPARK_LIFETIME_SEC: float = 0.3
const DEBRIS_LIFETIME_SEC: float = 1.0
const NORMAL_SPARK_COUNT: int = 6
const CRIT_SPARK_COUNT: int = 12
const KILL_DEBRIS_COUNT: int = 18
const NORMAL_DAMAGE_COLOR: Color = Color.WHITE
const CRIT_DAMAGE_COLOR: Color = Color("#ECC94B")
const SPARK_COLOR: Color = Color(1.0, 0.94, 0.76, 1.0)
const DEBRIS_COLOR: Color = Color(0.78, 0.18, 0.16, 1.0)
const HIT_SPARK_TEXTURE: Texture2D = preload("res://assets/generated/combat_hit_spark.png")
const ENEMY_DEBRIS_TEXTURE: Texture2D = preload("res://assets/generated/combat_enemy_debris.png")
const SPARK_SPRITE_SCALE: Vector2 = Vector2(0.16, 0.16)
const DEBRIS_SPRITE_SCALE: Vector2 = Vector2(0.12, 0.12)

var _hitstop_frames_remaining: int = 0
var _screen_shake_intensity: float = 0.0
var _screen_shake_frames_remaining: int = 0
var _camera: Camera2D
var _camera_base_offset: Vector2 = Vector2.ZERO
var _damage_numbers: Array[Dictionary] = []
var _sparks: Array[Dictionary] = []
var _debris: Array[Dictionary] = []
var _last_damage_number_text: String = ""
var _last_damage_number_color: Color = NORMAL_DAMAGE_COLOR


func _process(delta: float) -> void:
	advance_time(delta)
	_apply_camera_shake()


func _physics_process(_delta: float) -> void:
	_hitstop_frames_remaining = maxi(_hitstop_frames_remaining - 1, 0)
	_screen_shake_frames_remaining = maxi(_screen_shake_frames_remaining - 1, 0)
	if _screen_shake_frames_remaining <= 0:
		_screen_shake_intensity = 0.0
		if _camera != null:
			_camera.offset = _camera_base_offset


func set_camera(camera: Camera2D) -> void:
	_camera = camera
	_camera_base_offset = camera.offset if camera != null else Vector2.ZERO


func on_hit_event(hit_data: Dictionary) -> void:
	var damage: int = maxi(1, int(hit_data.get("damage", 1)))
	var hit_position: Vector2 = _read_vector2(hit_data.get("hit_position", Vector2.ZERO))
	var is_crit: bool = bool(hit_data.get("is_crit", false))
	var hitstop_frames: int = CRIT_HITSTOP_FRAMES if is_crit else NORMAL_HITSTOP_FRAMES
	var shake_intensity: float = CRIT_SHAKE_INTENSITY if is_crit else NORMAL_SHAKE_INTENSITY
	var spark_count: int = CRIT_SPARK_COUNT if is_crit else NORMAL_SPARK_COUNT
	var damage_color: Color = CRIT_DAMAGE_COLOR if is_crit else _damage_color_for_amount(damage)
	var spark_color: Color = CRIT_DAMAGE_COLOR if is_crit else SPARK_COLOR

	play_hitstop(hitstop_frames)
	play_screen_shake(shake_intensity, hitstop_frames)
	_spawn_damage_number(hit_position, damage, damage_color)
	_spawn_sparks(hit_position, spark_count, spark_color)


func on_kill_event(_target_id: int, world_position: Vector2) -> void:
	play_hitstop(KILL_HITSTOP_FRAMES)
	play_screen_shake(KILL_SHAKE_INTENSITY, KILL_HITSTOP_FRAMES)
	_spawn_debris(world_position, KILL_DEBRIS_COUNT)


func play_hitstop(frames: int) -> void:
	_hitstop_frames_remaining = maxi(_hitstop_frames_remaining, maxi(0, frames))


func play_screen_shake(intensity: float, duration_frames: int, _direction: Vector2 = Vector2.ZERO) -> void:
	if intensity <= 0.0 or duration_frames <= 0:
		return
	if intensity >= _screen_shake_intensity:
		_screen_shake_intensity = intensity
	_screen_shake_frames_remaining = maxi(_screen_shake_frames_remaining, duration_frames)


func advance_time(delta_sec: float) -> void:
	var safe_delta: float = maxf(0.0, delta_sec)
	_tick_effects(_damage_numbers, safe_delta)
	_tick_effects(_sparks, safe_delta)
	_tick_effects(_debris, safe_delta)


func get_active_damage_number_count() -> int:
	return _damage_numbers.size()


func get_active_spark_count() -> int:
	return _sparks.size()


func get_active_debris_count() -> int:
	return _debris.size()


func get_hitstop_frames_remaining() -> int:
	return _hitstop_frames_remaining


func get_screen_shake_intensity() -> float:
	return _screen_shake_intensity


func get_last_damage_number_text() -> String:
	return _last_damage_number_text


func get_last_damage_number_color() -> Color:
	return _last_damage_number_color


func _spawn_damage_number(world_position: Vector2, damage: int, color: Color) -> void:
	_last_damage_number_text = str(damage)
	_last_damage_number_color = color

	var label := Label.new()
	label.text = _last_damage_number_text
	label.position = world_position + Vector2(-12, -42)
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", _damage_font_size(damage))
	label.z_index = 90
	add_child(label)

	var tween: Tween = create_tween()
	tween.tween_property(label, "position", label.position + Vector2(0, -30), DAMAGE_NUMBER_LIFETIME_SEC)
	tween.parallel().tween_property(label, "modulate:a", 0.0, DAMAGE_NUMBER_LIFETIME_SEC)
	tween.tween_callback(label.queue_free)

	_damage_numbers.append({
		"node": label,
		"remaining": DAMAGE_NUMBER_LIFETIME_SEC,
	})


func _spawn_sparks(world_position: Vector2, count: int, color: Color) -> void:
	for index: int in range(maxi(0, count)):
		var spark := _create_vfx_sprite(HIT_SPARK_TEXTURE, color, SPARK_SPRITE_SCALE)
		spark.position = world_position + Vector2(float((index % 4) * 8 - 12), float(floori(float(index) / 4.0) * 7 - 10))
		spark.rotation = float(index) * 0.5
		spark.z_index = 80
		add_child(spark)
		var tween: Tween = create_tween()
		tween.tween_property(spark, "position", spark.position + Vector2((float(index) - float(count) / 2.0) * 4.0, -18.0), SPARK_LIFETIME_SEC)
		tween.parallel().tween_property(spark, "modulate:a", 0.0, SPARK_LIFETIME_SEC)
		tween.tween_callback(spark.queue_free)
		_sparks.append({
			"node": spark,
			"remaining": SPARK_LIFETIME_SEC,
		})


func _spawn_debris(world_position: Vector2, count: int) -> void:
	for index: int in range(maxi(0, count)):
		var shard := _create_vfx_sprite(ENEMY_DEBRIS_TEXTURE, DEBRIS_COLOR, DEBRIS_SPRITE_SCALE)
		shard.position = world_position + Vector2(float((index % 6) * 7 - 20), float(floori(float(index) / 6.0) * 7 - 12))
		shard.rotation = float(index) * 0.7
		shard.z_index = 82
		add_child(shard)
		var tween: Tween = create_tween()
		tween.tween_property(shard, "position", shard.position + Vector2((float(index) - float(count) / 2.0) * 3.0, 18.0), DEBRIS_LIFETIME_SEC)
		tween.parallel().tween_property(shard, "modulate:a", 0.0, DEBRIS_LIFETIME_SEC)
		tween.tween_callback(shard.queue_free)
		_debris.append({
			"node": shard,
			"remaining": DEBRIS_LIFETIME_SEC,
		})


func _create_vfx_sprite(texture: Texture2D, color: Color, sprite_scale: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = true
	sprite.scale = sprite_scale
	sprite.modulate = color
	return sprite


func _tick_effects(effects: Array[Dictionary], delta_sec: float) -> void:
	var index: int = effects.size() - 1
	while index >= 0:
		var effect: Dictionary = effects[index]
		var remaining: float = float(effect.get("remaining", 0.0)) - delta_sec
		if remaining <= 0.0:
			var node: Node = effect.get("node", null)
			if node != null and is_instance_valid(node):
				node.queue_free()
			effects.remove_at(index)
		else:
			effect["remaining"] = remaining
			effects[index] = effect
		index -= 1


func _apply_camera_shake() -> void:
	if _camera == null or _screen_shake_intensity <= 0.0 or _screen_shake_frames_remaining <= 0:
		return
	var direction: float = -1.0 if _screen_shake_frames_remaining % 2 == 0 else 1.0
	_camera.offset = _camera_base_offset + Vector2(direction * _screen_shake_intensity, 0.0)


func _read_vector2(value: Variant) -> Vector2:
	if value is Vector2:
		return value
	return Vector2.ZERO


func _damage_color_for_amount(damage: int) -> Color:
	if damage >= 16:
		return Color("#FACC15")
	return NORMAL_DAMAGE_COLOR


func _damage_font_size(damage: int) -> int:
	if damage >= 61:
		return 36
	if damage >= 31:
		return 28
	if damage >= 16:
		return 20
	if damage >= 6:
		return 16
	return 12
