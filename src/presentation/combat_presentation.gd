## Presentation-layer combat feedback for hit impact, damage numbers, and shake.
extends Node2D
class_name CombatPresentation

const NORMAL_HITSTOP_FRAMES: int = 3
const CRIT_HITSTOP_FRAMES: int = 6
const KILL_HITSTOP_FRAMES: int = 6
const NORMAL_SHAKE_INTENSITY: float = 2.0
const CRIT_SHAKE_INTENSITY: float = 5.0
const KILL_SHAKE_INTENSITY: float = 5.0
const PARRY_SHAKE_INTENSITY: float = 8.0
const DAMAGE_NUMBER_LIFETIME_SEC: float = 1.5
const SPARK_LIFETIME_SEC: float = 0.3
const DEBRIS_LIFETIME_SEC: float = 1.0
const PARRY_SPARK_LIFETIME_SEC: float = 0.8
const PARRY_FLASH_LIFETIME_SEC: float = 8.0 / 60.0
const CLAW_TRAIL_LIFETIME_SEC: float = 0.4
const LONG_TAIL_ARC_LIFETIME_SEC: float = 0.5
const FISH_BONE_WAVE_LIFETIME_SEC: float = 0.3
const ELECTRO_BELL_ARC_LIFETIME_SEC: float = 0.4
const DODGE_AFTERIMAGE_LIFETIME_SEC: float = 0.35
const DOUBLE_JUMP_VFX_LIFETIME_SEC: float = 0.32
const BOSS_PHASE_HITSTOP_FRAMES: int = 4
const BOSS_PHASE_SHAKE_INTENSITY: float = 6.0
const BOSS_PHASE_SHAKE_FRAMES: int = 4
const BOSS_PHASE_OVERLAY_LIFETIME_SEC: float = 1.5
const BOSS_PHASE_OVERLAY_ALPHA: float = 0.82
const BOSS_PHASE_DEBRIS_LIFETIME_SEC: float = 1.5
const NORMAL_SPARK_COUNT: int = 6
const CRIT_SPARK_COUNT: int = 12
const KILL_DEBRIS_COUNT: int = 18
const PERFECT_PARRY_SPARK_COUNT: int = 22
const CLAW_TRAIL_COUNT: int = 3
const LONG_TAIL_ARC_COUNT: int = 1
const FISH_BONE_WAVE_COUNT: int = 1
const ELECTRO_BELL_ARC_COUNT: int = 6
const DOUBLE_JUMP_VORTEX_COUNT: int = 3
const BOSS_PHASE_DEBRIS_COUNT: int = 32
const MAX_ACTIVE_PARTICLES: int = 200
const PARTICLE_FRAME_BUDGET_MS: float = 2.0
const SHAKE_HITSTOP_FRAME_BUDGET_MS: float = 0.1
const TOTAL_PRESENTATION_FRAME_BUDGET_MS: float = 3.0
const DODGE_AFTERIMAGE_ALPHAS: Array[float] = [0.5, 0.3, 0.1]
const PERFECT_PARRY_HITSTOP_FRAMES: int = 8
const PERFECT_PARRY_FLASH_ALPHA: float = 0.8
const NORMAL_DAMAGE_COLOR: Color = Color.WHITE
const MID_DAMAGE_COLOR: Color = Color("#FACC15")
const HEAVY_DAMAGE_COLOR: Color = Color("#F59E0B")
const CRIT_DAMAGE_COLOR: Color = Color("#ECC94B")
const LEGENDARY_DAMAGE_OUTLINE_COLOR: Color = Color.WHITE
const LEGENDARY_DAMAGE_OUTLINE_SIZE: int = 2
const DAMAGE_NUMBER_SHADOW_COLOR: Color = Color(0.0, 0.0, 0.0, 0.82)
const DAMAGE_NUMBER_SHADOW_OFFSET: Vector2i = Vector2i(1, 1)
const DAMAGE_NUMBER_FLOAT_DISTANCE_PX: float = 30.0
const SPARK_COLOR: Color = Color(1.0, 0.94, 0.76, 1.0)
const DEBRIS_COLOR: Color = Color(0.78, 0.18, 0.16, 1.0)
const PARRY_SPARK_COLOR: Color = Color(1.0, 0.96, 0.72, 1.0)
const CLAW_TRAIL_COLOR: Color = Color(1.0, 0.9, 0.48, 1.0)
const LONG_TAIL_ARC_COLOR: Color = Color("#DDE8F2")
const FISH_BONE_WAVE_COLOR: Color = Color("#F8F4E8")
const ELECTRO_BELL_ARC_COLOR: Color = Color("#38BDF8")
const DODGE_AFTERIMAGE_COLOR: Color = Color.WHITE
const BOSS_PHASE_DEBRIS_COLOR: Color = Color("#6B8A9E")
const BOSS_PHASE_OVERLOAD_DEBRIS_COLOR: Color = Color("#E53E3E")
const COLORBLIND_NONE: StringName = &"none"
const COLORBLIND_RED_GREEN: StringName = &"red_green"
const COLORBLIND_BLUE_YELLOW: StringName = &"blue_yellow"
const FOCUS_MODE_SHAKE_MULTIPLIER: float = 0.7
const RG_NORMAL_SPARK_COLOR: Color = Color("#4299E1")
const RG_EMPHASIS_COLOR: Color = Color("#F6E05E")
const RG_DEBRIS_COLOR: Color = Color("#D69E2E")
const RG_BOSS_METAL_COLOR: Color = Color("#2B6CB0")
const BY_NORMAL_SPARK_COLOR: Color = Color("#FED7D7")
const BY_EMPHASIS_COLOR: Color = Color("#F97316")
const BY_PARRY_SPARK_COLOR: Color = Color("#FFFFFF")
const BY_DEBRIS_COLOR: Color = Color("#E53E3E")
const BY_BOSS_OVERLOAD_COLOR: Color = Color("#FFFFFF")
const HIT_SPARK_TEXTURE_PATH: String = "res://assets/generated/combat_hit_spark.png"
const ENEMY_DEBRIS_TEXTURE_PATH: String = "res://assets/generated/combat_enemy_debris.png"
const PARRY_SPARK_TEXTURE_PATH: String = "res://assets/generated/combat_parry_spark.png"
const PARRY_FLASH_TEXTURE_PATH: String = "res://assets/generated/combat_parry_flash_overlay.png"
const CLAW_TRAIL_TEXTURE_PATH: String = "res://assets/generated/combat_claw_trail.png"
const LONG_TAIL_ARC_TEXTURE_PATH: String = "res://assets/generated/combat_long_tail_arc_runtime.png"
const FISH_BONE_WAVE_TEXTURE_PATH: String = "res://assets/generated/combat_fish_bone_wave_runtime.png"
const ELECTRO_BELL_ARC_TEXTURE_PATH: String = "res://assets/generated/combat_electro_bell_arc_runtime.png"
const DOUBLE_JUMP_VORTEX_TEXTURE_PATH: String = "res://assets/generated/player_double_jump_vortex_runtime.png"
const BOSS_PHASE_OVERLAY_TEXTURE_PATH: String = "res://assets/generated/combat_boss_phase_overlay.png"
const SPARK_SPRITE_SCALE: Vector2 = Vector2(0.16, 0.16)
const DEBRIS_SPRITE_SCALE: Vector2 = Vector2(0.12, 0.12)
const PARRY_SPARK_SPRITE_SCALE: Vector2 = Vector2(0.18, 0.18)
const CLAW_TRAIL_SPRITE_SCALE: Vector2 = Vector2(0.34, 0.34)
const LONG_TAIL_ARC_SPRITE_SCALE: Vector2 = Vector2(0.44, 0.44)
const FISH_BONE_WAVE_SPRITE_SCALE: Vector2 = Vector2(0.40, 0.40)
const ELECTRO_BELL_ARC_SPRITE_SCALE: Vector2 = Vector2(0.24, 0.24)
const DOUBLE_JUMP_VORTEX_SPRITE_SCALE: Vector2 = Vector2(0.32, 0.32)
const BOSS_PHASE_DEBRIS_SPRITE_SCALE: Vector2 = Vector2(0.14, 0.14)
const DODGE_AFTERIMAGE_OFFSET_PX: float = 14.0

var _hitstop_frames_remaining: int = 0
var _screen_shake_intensity: float = 0.0
var _screen_shake_frames_remaining: int = 0
var _camera: Camera2D
var _camera_base_offset: Vector2 = Vector2.ZERO
var _damage_numbers: Array[Dictionary] = []
var _sparks: Array[Dictionary] = []
var _debris: Array[Dictionary] = []
var _parry_sparks: Array[Dictionary] = []
var _trails: Array[Dictionary] = []
var _flashes: Array[Dictionary] = []
var _afterimages: Array[Dictionary] = []
var _double_jump_vfx: Array[Dictionary] = []
var _boss_phase_debris: Array[Dictionary] = []
var _boss_phase_overlays: Array[Dictionary] = []
var _particle_effect_order: Array[Dictionary] = []
var _particle_eviction_count: int = 0
var _hit_spark_texture: Texture2D = load(HIT_SPARK_TEXTURE_PATH) as Texture2D
var _enemy_debris_texture: Texture2D = load(ENEMY_DEBRIS_TEXTURE_PATH) as Texture2D
var _parry_spark_texture: Texture2D = load(PARRY_SPARK_TEXTURE_PATH) as Texture2D
var _parry_flash_texture: Texture2D = load(PARRY_FLASH_TEXTURE_PATH) as Texture2D
var _claw_trail_texture: Texture2D = load(CLAW_TRAIL_TEXTURE_PATH) as Texture2D
var _long_tail_arc_texture: Texture2D = load(LONG_TAIL_ARC_TEXTURE_PATH) as Texture2D
var _fish_bone_wave_texture: Texture2D = load(FISH_BONE_WAVE_TEXTURE_PATH) as Texture2D
var _electro_bell_arc_texture: Texture2D = load(ELECTRO_BELL_ARC_TEXTURE_PATH) as Texture2D
var _double_jump_vortex_texture: Texture2D = load(DOUBLE_JUMP_VORTEX_TEXTURE_PATH) as Texture2D
var _boss_phase_overlay_texture: Texture2D = load(BOSS_PHASE_OVERLAY_TEXTURE_PATH) as Texture2D
var _last_damage_number_text: String = ""
var _last_damage_number_color: Color = NORMAL_DAMAGE_COLOR
var _last_damage_number_font_size: int = 12
var _last_damage_number_outline_size: int = 0
var _last_damage_number_float_distance: float = DAMAGE_NUMBER_FLOAT_DISTANCE_PX
var _last_damage_number_lifetime_sec: float = DAMAGE_NUMBER_LIFETIME_SEC
var _last_flash_alpha: float = 0.0
var _last_afterimage_alphas: Array[float] = []
var _last_afterimage_positions: Array[Vector2] = []
var _last_double_jump_vfx_texture_path: String = ""
var _last_boss_phase_entity_id: int = 0
var _last_boss_phase: int = 0
var _last_boss_phase_metadata: Dictionary = {}
var _last_boss_phase_overlay_texture_path: String = ""
var _colorblind_mode: StringName = COLORBLIND_NONE
var _focus_mode_active: bool = false
var _last_spark_color: Color = SPARK_COLOR
var _last_debris_color: Color = DEBRIS_COLOR
var _last_parry_spark_color: Color = PARRY_SPARK_COLOR
var _last_claw_trail_color: Color = CLAW_TRAIL_COLOR
var _last_boss_phase_debris_color: Color = BOSS_PHASE_DEBRIS_COLOR
var _last_weapon_vfx_color_by_weapon: Dictionary = {}
var _last_weapon_vfx_lifetime_by_weapon: Dictionary = {}
var _last_weapon_vfx_texture_path_by_weapon: Dictionary = {}


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


## Selects the accessibility color palette used by newly spawned combat VFX.
func set_colorblind_mode(mode: StringName) -> void:
	_colorblind_mode = _normalize_colorblind_mode(mode)


func get_colorblind_mode() -> StringName:
	return _colorblind_mode


## Consumes HealthComponent focus-mode changes without querying gameplay nodes.
func on_focus_mode_changed(_entity_id: int, active: bool, _metadata: Dictionary) -> void:
	_focus_mode_active = active


func is_focus_mode_active() -> bool:
	return _focus_mode_active


func on_hit_event(hit_data: Dictionary) -> void:
	var damage: int = maxi(1, int(hit_data.get("final_damage", hit_data.get("damage", 1))))
	var hit_position: Vector2 = _read_vector2(hit_data.get("hit_position", Vector2.ZERO))
	var is_crit: bool = bool(hit_data.get("is_crit", false))
	var hitstop_frames: int = CRIT_HITSTOP_FRAMES if is_crit else NORMAL_HITSTOP_FRAMES
	var shake_intensity: float = CRIT_SHAKE_INTENSITY if is_crit else NORMAL_SHAKE_INTENSITY
	var spark_count: int = CRIT_SPARK_COUNT if is_crit else NORMAL_SPARK_COUNT
	var damage_color: Color = CRIT_DAMAGE_COLOR if is_crit else _damage_color_for_amount(damage)
	var spark_color: Color = _spark_color_for_hit(is_crit)
	var show_damage_number: bool = bool(hit_data.get("show_damage_number", true))

	play_hitstop(hitstop_frames)
	play_screen_shake(shake_intensity, hitstop_frames)
	if show_damage_number:
		_spawn_damage_number(hit_position, damage, damage_color)
	_spawn_sparks(hit_position, spark_count, spark_color)


func on_kill_event(_target_id: int, world_position: Vector2) -> void:
	play_hitstop(KILL_HITSTOP_FRAMES)
	play_screen_shake(KILL_SHAKE_INTENSITY, KILL_HITSTOP_FRAMES)
	_spawn_debris(world_position, KILL_DEBRIS_COUNT)


func on_boss_phase_transition_started(entity_id: int, phase: int, metadata: Dictionary) -> void:
	_last_boss_phase_entity_id = entity_id
	_last_boss_phase = phase
	_last_boss_phase_metadata = metadata.duplicate(true)
	play_hitstop(BOSS_PHASE_HITSTOP_FRAMES)
	play_screen_shake(BOSS_PHASE_SHAKE_INTENSITY, BOSS_PHASE_SHAKE_FRAMES)
	var phase_position: Vector2 = _boss_phase_world_position(metadata)
	_spawn_boss_phase_overlay(phase)
	_spawn_boss_phase_debris(phase_position, BOSS_PHASE_DEBRIS_COUNT, phase)


func on_parry_event(parry_data: Dictionary) -> void:
	var parry_type: StringName = StringName(String(parry_data.get("parry_type", &"")))
	if parry_type != &"perfect":
		return
	var parry_position: Vector2 = _read_vector2(parry_data.get("position", Vector2.ZERO))
	play_hitstop(PERFECT_PARRY_HITSTOP_FRAMES)
	play_screen_shake(PARRY_SHAKE_INTENSITY, PERFECT_PARRY_HITSTOP_FRAMES)
	_spawn_screen_flash(PERFECT_PARRY_FLASH_ALPHA, PARRY_FLASH_LIFETIME_SEC)
	_spawn_parry_sparks(parry_position, PERFECT_PARRY_SPARK_COUNT)


func on_weapon_attack_event(attack_data: Dictionary) -> void:
	var weapon_id: StringName = StringName(String(attack_data.get("weapon_id", &"")))
	var attack_position: Vector2 = _read_vector2(attack_data.get("attack_position", attack_data.get("position", Vector2.ZERO)))
	var facing: float = _read_float(attack_data.get("facing", 1.0), 1.0)
	match weapon_id:
		&"cat_claw":
			_spawn_claw_trails(attack_position, facing)
		&"long_tail":
			_spawn_long_tail_arc(attack_position, facing)
		&"fish_bone":
			_spawn_fish_bone_wave(attack_position)
		&"electro_bell":
			_spawn_electro_bell_arcs(attack_position, facing)


func on_dodge_event(texture: Texture2D, world_position: Vector2, facing: float) -> void:
	if texture == null:
		return
	_spawn_dodge_afterimages(texture, world_position, facing)


func on_double_jump_event(_texture: Texture2D, world_position: Vector2, facing: float) -> void:
	_spawn_double_jump_vortex(world_position, facing)


func play_hitstop(frames: int) -> void:
	_hitstop_frames_remaining = maxi(_hitstop_frames_remaining, maxi(0, frames))


func play_screen_shake(intensity: float, duration_frames: int, _direction: Vector2 = Vector2.ZERO) -> void:
	var effective_intensity: float = _effective_screen_shake_intensity(intensity)
	if effective_intensity <= 0.0 or duration_frames <= 0:
		return
	if effective_intensity >= _screen_shake_intensity:
		_screen_shake_intensity = effective_intensity
	_screen_shake_frames_remaining = maxi(_screen_shake_frames_remaining, duration_frames)


func advance_time(delta_sec: float) -> void:
	var safe_delta: float = maxf(0.0, delta_sec)
	_tick_effects(_damage_numbers, safe_delta)
	_tick_effects(_sparks, safe_delta)
	_tick_effects(_debris, safe_delta)
	_tick_effects(_parry_sparks, safe_delta)
	_tick_effects(_trails, safe_delta)
	_tick_effects(_flashes, safe_delta)
	_tick_effects(_afterimages, safe_delta)
	_tick_effects(_double_jump_vfx, safe_delta)
	_tick_effects(_boss_phase_debris, safe_delta)
	_tick_effects(_boss_phase_overlays, safe_delta)


func get_active_damage_number_count() -> int:
	return _damage_numbers.size()


func get_active_spark_count() -> int:
	return _sparks.size()


func get_active_debris_count() -> int:
	return _debris.size()


func get_active_parry_spark_count() -> int:
	return _parry_sparks.size()


func get_active_trail_count() -> int:
	return _trails.size()


func get_active_flash_count() -> int:
	return _flashes.size()


func get_active_afterimage_count() -> int:
	return _afterimages.size()


func get_active_double_jump_vfx_count() -> int:
	return _double_jump_vfx.size()


func get_particle_cap() -> int:
	return MAX_ACTIVE_PARTICLES


func get_active_particle_count() -> int:
	return (
		_sparks.size()
		+ _debris.size()
		+ _parry_sparks.size()
		+ _trails.size()
		+ _afterimages.size()
		+ _double_jump_vfx.size()
		+ _boss_phase_debris.size()
	)


func get_particle_eviction_count() -> int:
	return _particle_eviction_count


func capture_performance_budget_sample(sample_frames: int = 120) -> Dictionary:
	var frames: int = maxi(1, sample_frames)
	var particle_start_usec: int = Time.get_ticks_usec()
	var sampled_particles: int = 0
	for _frame: int in range(frames):
		sampled_particles += _sample_particle_work()
	var particle_frame_ms: float = _elapsed_frame_ms(particle_start_usec, frames)

	var shake_start_usec: int = Time.get_ticks_usec()
	var sampled_shake_state: float = 0.0
	for _frame: int in range(frames):
		sampled_shake_state += _sample_shake_hitstop_work()
	var shake_hitstop_frame_ms: float = _elapsed_frame_ms(shake_start_usec, frames)
	var total_frame_ms: float = particle_frame_ms + shake_hitstop_frame_ms

	return {
		"sample_frames": frames,
		"active_particle_count": get_active_particle_count(),
		"particle_cap": MAX_ACTIVE_PARTICLES,
		"particle_budget_ms": PARTICLE_FRAME_BUDGET_MS,
		"shake_hitstop_budget_ms": SHAKE_HITSTOP_FRAME_BUDGET_MS,
		"total_budget_ms": TOTAL_PRESENTATION_FRAME_BUDGET_MS,
		"particle_frame_ms": particle_frame_ms,
		"shake_hitstop_frame_ms": shake_hitstop_frame_ms,
		"total_frame_ms": total_frame_ms,
		"sampled_particles": sampled_particles,
		"sampled_shake_state": sampled_shake_state,
		"within_budget": (
			particle_frame_ms < PARTICLE_FRAME_BUDGET_MS
			and shake_hitstop_frame_ms < SHAKE_HITSTOP_FRAME_BUDGET_MS
			and total_frame_ms < TOTAL_PRESENTATION_FRAME_BUDGET_MS
		),
	}


func get_active_boss_phase_debris_count() -> int:
	return _boss_phase_debris.size()


func get_active_boss_phase_overlay_count() -> int:
	return _boss_phase_overlays.size()


func get_hitstop_frames_remaining() -> int:
	return _hitstop_frames_remaining


func get_screen_shake_intensity() -> float:
	return _screen_shake_intensity


func get_screen_shake_frames_remaining() -> int:
	return _screen_shake_frames_remaining


func get_last_damage_number_text() -> String:
	return _last_damage_number_text


func get_last_damage_number_color() -> Color:
	return _last_damage_number_color


func get_last_damage_number_font_size() -> int:
	return _last_damage_number_font_size


func get_last_damage_number_outline_size() -> int:
	return _last_damage_number_outline_size


func get_last_damage_number_float_distance() -> float:
	return _last_damage_number_float_distance


func get_last_damage_number_lifetime_sec() -> float:
	return _last_damage_number_lifetime_sec


func get_last_damage_number_snapshot() -> Dictionary:
	var label := _latest_active_damage_number_label()
	return {
		"text": _last_damage_number_text,
		"color": _last_damage_number_color,
		"font_size": _last_damage_number_font_size,
		"outline_size": _last_damage_number_outline_size,
		"shadow_color": (
			label.get_theme_color("font_shadow_color")
			if label != null
			else DAMAGE_NUMBER_SHADOW_COLOR
		),
		"shadow_offset": (
			Vector2i(
				label.get_theme_constant("shadow_offset_x"),
				label.get_theme_constant("shadow_offset_y")
			)
			if label != null
			else DAMAGE_NUMBER_SHADOW_OFFSET
		),
		"float_distance_px": _last_damage_number_float_distance,
		"lifetime_sec": _last_damage_number_lifetime_sec,
		"active_count": get_active_damage_number_count(),
		"visible": label != null and label.visible and label.modulate.a > 0.0,
		"position": label.position if label != null else Vector2.ZERO,
		"z_index": label.z_index if label != null else 0,
	}


func get_last_flash_alpha() -> float:
	return _last_flash_alpha


func get_last_afterimage_alphas() -> Array[float]:
	var result: Array[float] = []
	result.assign(_last_afterimage_alphas)
	return result


func get_last_afterimage_positions() -> Array[Vector2]:
	var result: Array[Vector2] = []
	result.assign(_last_afterimage_positions)
	return result


func get_last_double_jump_vfx_texture_path() -> String:
	return _last_double_jump_vfx_texture_path


func get_double_jump_vfx_lifetime_sec() -> float:
	return DOUBLE_JUMP_VFX_LIFETIME_SEC


func get_last_boss_phase_entity_id() -> int:
	return _last_boss_phase_entity_id


func get_last_boss_phase() -> int:
	return _last_boss_phase


func get_last_boss_phase_metadata() -> Dictionary:
	return _last_boss_phase_metadata.duplicate(true)


func get_last_boss_phase_overlay_texture_path() -> String:
	return _last_boss_phase_overlay_texture_path


func get_last_spark_color() -> Color:
	return _last_spark_color


func get_last_debris_color() -> Color:
	return _last_debris_color


func get_last_parry_spark_color() -> Color:
	return _last_parry_spark_color


func get_last_claw_trail_color() -> Color:
	return _last_claw_trail_color


func get_weapon_vfx_snapshot(weapon_id: StringName) -> Dictionary:
	var normalized_weapon_id: StringName = StringName(String(weapon_id))
	return {
		"weapon_id": normalized_weapon_id,
		"count": _count_active_weapon_vfx(normalized_weapon_id),
		"color": _last_weapon_vfx_color_by_weapon.get(normalized_weapon_id, Color.TRANSPARENT),
		"lifetime_sec": float(_last_weapon_vfx_lifetime_by_weapon.get(normalized_weapon_id, 0.0)),
		"texture_path": String(_last_weapon_vfx_texture_path_by_weapon.get(normalized_weapon_id, "")),
	}


func get_last_boss_phase_debris_color() -> Color:
	return _last_boss_phase_debris_color


func get_boss_phase_debris_lifetime_sec() -> float:
	return BOSS_PHASE_DEBRIS_LIFETIME_SEC


func _spawn_damage_number(world_position: Vector2, damage: int, color: Color) -> void:
	_last_damage_number_text = str(damage)
	_last_damage_number_color = color
	_last_damage_number_font_size = _damage_font_size(damage)
	_last_damage_number_outline_size = _damage_outline_size(damage)
	_last_damage_number_float_distance = DAMAGE_NUMBER_FLOAT_DISTANCE_PX
	_last_damage_number_lifetime_sec = DAMAGE_NUMBER_LIFETIME_SEC

	var label := Label.new()
	label.text = _last_damage_number_text
	label.position = world_position + Vector2(-12, -42)
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", _last_damage_number_font_size)
	label.add_theme_constant_override("outline_size", _last_damage_number_outline_size)
	label.add_theme_color_override("font_shadow_color", DAMAGE_NUMBER_SHADOW_COLOR)
	label.add_theme_constant_override("shadow_offset_x", DAMAGE_NUMBER_SHADOW_OFFSET.x)
	label.add_theme_constant_override("shadow_offset_y", DAMAGE_NUMBER_SHADOW_OFFSET.y)
	if _last_damage_number_outline_size > 0:
		label.add_theme_color_override("font_outline_color", LEGENDARY_DAMAGE_OUTLINE_COLOR)
	label.z_index = 90
	add_child(label)

	var tween: Tween = create_tween()
	tween.tween_property(
		label,
		"position",
		label.position + Vector2(0, -_last_damage_number_float_distance),
		DAMAGE_NUMBER_LIFETIME_SEC
	)
	tween.parallel().tween_property(label, "modulate:a", 0.0, DAMAGE_NUMBER_LIFETIME_SEC)
	tween.tween_callback(label.queue_free)

	_damage_numbers.append({
		"node": label,
		"remaining": DAMAGE_NUMBER_LIFETIME_SEC,
	})


func _spawn_sparks(world_position: Vector2, count: int, color: Color) -> void:
	_last_spark_color = color
	for index: int in range(maxi(0, count)):
		var spark := _create_vfx_sprite(_hit_spark_texture, color, SPARK_SPRITE_SCALE)
		spark.position = world_position + Vector2(float((index % 4) * 8 - 12), float(floori(float(index) / 4.0) * 7 - 10))
		spark.rotation = float(index) * 0.5
		spark.z_index = 80
		add_child(spark)
		var tween: Tween = create_tween()
		tween.tween_property(spark, "position", spark.position + Vector2((float(index) - float(count) / 2.0) * 4.0, -18.0), SPARK_LIFETIME_SEC)
		tween.parallel().tween_property(spark, "modulate:a", 0.0, SPARK_LIFETIME_SEC)
		tween.tween_callback(spark.queue_free)
		_register_particle_effect(_sparks, {
			"node": spark,
			"remaining": SPARK_LIFETIME_SEC,
			"tween": tween,
		})


func _spawn_parry_sparks(world_position: Vector2, count: int) -> void:
	var parry_color: Color = _parry_spark_color()
	_last_parry_spark_color = parry_color
	for index: int in range(maxi(0, count)):
		var angle: float = (float(index) / float(maxi(1, count))) * TAU
		var outward: Vector2 = Vector2.RIGHT.rotated(angle)
		var spark := _create_vfx_sprite(_parry_spark_texture, parry_color, PARRY_SPARK_SPRITE_SCALE)
		spark.position = world_position + outward * (6.0 + float(index % 3) * 2.0)
		spark.rotation = angle
		spark.z_index = 86
		add_child(spark)
		var tween: Tween = create_tween()
		tween.tween_property(spark, "position", spark.position + outward * 42.0, PARRY_SPARK_LIFETIME_SEC)
		tween.parallel().tween_property(spark, "modulate:a", 0.0, PARRY_SPARK_LIFETIME_SEC)
		tween.tween_callback(spark.queue_free)
		_register_particle_effect(_parry_sparks, {
			"node": spark,
			"remaining": PARRY_SPARK_LIFETIME_SEC,
			"tween": tween,
		})


func _spawn_screen_flash(alpha: float, duration_sec: float) -> void:
	_last_flash_alpha = clampf(alpha, 0.0, 1.0)
	var layer := CanvasLayer.new()
	layer.layer = 100
	var flash := TextureRect.new()
	flash.texture = _parry_flash_texture
	flash.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	flash.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	flash.modulate = Color(1.0, 1.0, 1.0, _last_flash_alpha)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.offset_left = 0.0
	flash.offset_top = 0.0
	flash.offset_right = 1280.0
	flash.offset_bottom = 720.0
	layer.add_child(flash)
	add_child(layer)
	var tween: Tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, maxf(0.01, duration_sec))
	tween.tween_callback(layer.queue_free)
	_flashes.append({
		"node": layer,
		"remaining": duration_sec,
	})


func _spawn_claw_trails(world_position: Vector2, facing: float) -> void:
	var facing_sign: float = -1.0 if facing < 0.0 else 1.0
	var trail_color: Color = _claw_trail_color()
	_last_claw_trail_color = trail_color
	_remember_weapon_vfx(&"cat_claw", trail_color, CLAW_TRAIL_LIFETIME_SEC, CLAW_TRAIL_TEXTURE_PATH)
	for index: int in range(CLAW_TRAIL_COUNT):
		var trail := _create_vfx_sprite(_claw_trail_texture, trail_color, CLAW_TRAIL_SPRITE_SCALE)
		var row_offset: float = float(index - 1) * 8.0
		trail.position = world_position + Vector2(float(index) * 5.0 * facing_sign, row_offset)
		trail.flip_h = facing_sign < 0.0
		trail.rotation = (-0.28 * facing_sign) + float(index - 1) * 0.07
		trail.modulate.a = 0.9 - float(index) * 0.12
		trail.z_index = 84
		add_child(trail)
		var tween: Tween = create_tween()
		tween.tween_property(trail, "position", trail.position + Vector2(26.0 * facing_sign, -4.0), CLAW_TRAIL_LIFETIME_SEC)
		tween.parallel().tween_property(trail, "modulate:a", 0.0, CLAW_TRAIL_LIFETIME_SEC)
		tween.tween_callback(trail.queue_free)
		_register_particle_effect(_trails, {
			"node": trail,
			"remaining": CLAW_TRAIL_LIFETIME_SEC,
			"tween": tween,
			"weapon_id": &"cat_claw",
		})


func _spawn_long_tail_arc(world_position: Vector2, facing: float) -> void:
	var facing_sign: float = -1.0 if facing < 0.0 else 1.0
	var arc_color: Color = _long_tail_arc_color()
	_remember_weapon_vfx(&"long_tail", arc_color, LONG_TAIL_ARC_LIFETIME_SEC, LONG_TAIL_ARC_TEXTURE_PATH)
	for _index: int in range(LONG_TAIL_ARC_COUNT):
		var arc := _create_vfx_sprite(_long_tail_arc_texture, arc_color, LONG_TAIL_ARC_SPRITE_SCALE)
		arc.position = world_position + Vector2(12.0 * facing_sign, -2.0)
		arc.flip_h = facing_sign < 0.0
		arc.rotation = -0.12 * facing_sign
		arc.modulate.a = 0.92
		arc.z_index = 84
		add_child(arc)
		var tween: Tween = create_tween()
		tween.tween_property(
			arc,
			"position",
			arc.position + Vector2(44.0 * facing_sign, -2.0),
			LONG_TAIL_ARC_LIFETIME_SEC
		)
		tween.parallel().tween_property(
			arc,
			"rotation",
			arc.rotation + 0.18 * facing_sign,
			LONG_TAIL_ARC_LIFETIME_SEC
		)
		tween.parallel().tween_property(arc, "modulate:a", 0.0, LONG_TAIL_ARC_LIFETIME_SEC)
		tween.tween_callback(arc.queue_free)
		_register_particle_effect(_trails, {
			"node": arc,
			"remaining": LONG_TAIL_ARC_LIFETIME_SEC,
			"tween": tween,
			"weapon_id": &"long_tail",
		})


func _spawn_fish_bone_wave(world_position: Vector2) -> void:
	var wave_color: Color = _fish_bone_wave_color()
	_remember_weapon_vfx(&"fish_bone", wave_color, FISH_BONE_WAVE_LIFETIME_SEC, FISH_BONE_WAVE_TEXTURE_PATH)
	for _index: int in range(FISH_BONE_WAVE_COUNT):
		var wave := _create_vfx_sprite(_fish_bone_wave_texture, wave_color, FISH_BONE_WAVE_SPRITE_SCALE)
		wave.position = world_position + Vector2(0.0, 6.0)
		wave.modulate.a = 0.88
		wave.z_index = 83
		add_child(wave)
		var tween: Tween = create_tween()
		tween.tween_property(
			wave,
			"scale",
			FISH_BONE_WAVE_SPRITE_SCALE * 1.32,
			FISH_BONE_WAVE_LIFETIME_SEC
		)
		tween.parallel().tween_property(wave, "modulate:a", 0.0, FISH_BONE_WAVE_LIFETIME_SEC)
		tween.tween_callback(wave.queue_free)
		_register_particle_effect(_trails, {
			"node": wave,
			"remaining": FISH_BONE_WAVE_LIFETIME_SEC,
			"tween": tween,
			"weapon_id": &"fish_bone",
		})


func _spawn_electro_bell_arcs(world_position: Vector2, facing: float) -> void:
	var facing_sign: float = -1.0 if facing < 0.0 else 1.0
	var arc_color: Color = _electro_bell_arc_color()
	_remember_weapon_vfx(&"electro_bell", arc_color, ELECTRO_BELL_ARC_LIFETIME_SEC, ELECTRO_BELL_ARC_TEXTURE_PATH)
	for index: int in range(ELECTRO_BELL_ARC_COUNT):
		var angle: float = -0.9 + float(index) * (1.8 / float(maxi(1, ELECTRO_BELL_ARC_COUNT - 1)))
		var outward: Vector2 = Vector2(facing_sign, 0.0).rotated(angle)
		var arc := _create_vfx_sprite(_electro_bell_arc_texture, arc_color, ELECTRO_BELL_ARC_SPRITE_SCALE)
		arc.position = world_position + outward * (8.0 + float(index % 3) * 4.0)
		arc.flip_h = facing_sign < 0.0
		arc.rotation = outward.angle()
		arc.modulate.a = 0.9
		arc.z_index = 85
		add_child(arc)
		var tween: Tween = create_tween()
		tween.tween_property(
			arc,
			"position",
			arc.position + outward * (24.0 + float(index % 2) * 6.0),
			ELECTRO_BELL_ARC_LIFETIME_SEC
		)
		tween.parallel().tween_property(
			arc,
			"rotation",
			arc.rotation + 0.22 * facing_sign,
			ELECTRO_BELL_ARC_LIFETIME_SEC
		)
		tween.parallel().tween_property(arc, "modulate:a", 0.0, ELECTRO_BELL_ARC_LIFETIME_SEC)
		tween.tween_callback(arc.queue_free)
		_register_particle_effect(_trails, {
			"node": arc,
			"remaining": ELECTRO_BELL_ARC_LIFETIME_SEC,
			"tween": tween,
			"weapon_id": &"electro_bell",
		})


func _spawn_dodge_afterimages(texture: Texture2D, world_position: Vector2, facing: float) -> void:
	var facing_sign: float = -1.0 if facing < 0.0 else 1.0
	_last_afterimage_alphas.clear()
	_last_afterimage_positions.clear()
	for index: int in range(DODGE_AFTERIMAGE_ALPHAS.size()):
		var alpha: float = DODGE_AFTERIMAGE_ALPHAS[index]
		var afterimage := _create_vfx_sprite(texture, DODGE_AFTERIMAGE_COLOR, Vector2.ONE)
		afterimage.position = world_position - Vector2(facing_sign * DODGE_AFTERIMAGE_OFFSET_PX * float(index), 0.0)
		afterimage.flip_h = facing_sign < 0.0
		afterimage.modulate.a = alpha
		afterimage.z_index = 78 - index
		add_child(afterimage)
		var tween: Tween = create_tween()
		tween.tween_property(afterimage, "modulate:a", 0.0, DODGE_AFTERIMAGE_LIFETIME_SEC)
		tween.tween_callback(afterimage.queue_free)
		_register_particle_effect(_afterimages, {
			"node": afterimage,
			"remaining": DODGE_AFTERIMAGE_LIFETIME_SEC,
			"tween": tween,
		})
		_last_afterimage_alphas.append(alpha)
		_last_afterimage_positions.append(afterimage.position)


func _spawn_double_jump_vortex(world_position: Vector2, facing: float) -> void:
	var facing_sign: float = -1.0 if facing < 0.0 else 1.0
	_last_double_jump_vfx_texture_path = DOUBLE_JUMP_VORTEX_TEXTURE_PATH
	for index: int in range(DOUBLE_JUMP_VORTEX_COUNT):
		var vortex := _create_vfx_sprite(
			_double_jump_vortex_texture,
			Color.WHITE,
			DOUBLE_JUMP_VORTEX_SPRITE_SCALE * (1.0 + float(index) * 0.08)
		)
		vortex.position = world_position + Vector2(
			facing_sign * float(index - 1) * 4.0,
			30.0 - float(index) * 6.0
		)
		vortex.flip_h = facing_sign < 0.0
		vortex.rotation = float(index - 1) * 0.08 * facing_sign
		vortex.modulate.a = 0.9 - float(index) * 0.16
		vortex.z_index = 83 + index
		add_child(vortex)
		var tween: Tween = create_tween()
		tween.tween_property(
			vortex,
			"position",
			vortex.position + Vector2(facing_sign * (6.0 + float(index) * 2.0), -26.0),
			DOUBLE_JUMP_VFX_LIFETIME_SEC
		)
		tween.parallel().tween_property(
			vortex,
			"scale",
			DOUBLE_JUMP_VORTEX_SPRITE_SCALE * (1.18 + float(index) * 0.12),
			DOUBLE_JUMP_VFX_LIFETIME_SEC
		)
		tween.parallel().tween_property(vortex, "modulate:a", 0.0, DOUBLE_JUMP_VFX_LIFETIME_SEC)
		tween.tween_callback(vortex.queue_free)
		_register_particle_effect(_double_jump_vfx, {
			"node": vortex,
			"remaining": DOUBLE_JUMP_VFX_LIFETIME_SEC,
			"tween": tween,
		})


func _spawn_debris(world_position: Vector2, count: int) -> void:
	var debris_color: Color = _debris_color()
	_last_debris_color = debris_color
	for index: int in range(maxi(0, count)):
		var shard := _create_vfx_sprite(_enemy_debris_texture, debris_color, DEBRIS_SPRITE_SCALE)
		shard.position = world_position + Vector2(float((index % 6) * 7 - 20), float(floori(float(index) / 6.0) * 7 - 12))
		shard.rotation = float(index) * 0.7
		shard.z_index = 82
		add_child(shard)
		var tween: Tween = create_tween()
		tween.tween_property(shard, "position", shard.position + Vector2((float(index) - float(count) / 2.0) * 3.0, 18.0), DEBRIS_LIFETIME_SEC)
		tween.parallel().tween_property(shard, "modulate:a", 0.0, DEBRIS_LIFETIME_SEC)
		tween.tween_callback(shard.queue_free)
		_register_particle_effect(_debris, {
			"node": shard,
			"remaining": DEBRIS_LIFETIME_SEC,
			"tween": tween,
		})


func _spawn_boss_phase_overlay(phase: int) -> void:
	_last_boss_phase_overlay_texture_path = BOSS_PHASE_OVERLAY_TEXTURE_PATH
	var layer := CanvasLayer.new()
	layer.layer = 99
	var overlay := TextureRect.new()
	overlay.texture = _boss_phase_overlay_texture
	overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	overlay.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	var phase_alpha: float = BOSS_PHASE_OVERLAY_ALPHA if phase < 3 else 0.92
	overlay.modulate = Color(1.0, 0.9 if phase >= 3 else 1.0, 0.9 if phase >= 3 else 1.0, phase_alpha)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.offset_left = 0.0
	overlay.offset_top = 0.0
	overlay.offset_right = 1280.0
	overlay.offset_bottom = 720.0
	layer.add_child(overlay)
	add_child(layer)
	var tween: Tween = create_tween()
	tween.tween_property(overlay, "modulate:a", 0.0, BOSS_PHASE_OVERLAY_LIFETIME_SEC)
	tween.tween_callback(layer.queue_free)
	_boss_phase_overlays.append({
		"node": layer,
		"remaining": BOSS_PHASE_OVERLAY_LIFETIME_SEC,
	})


func _spawn_boss_phase_debris(world_position: Vector2, count: int, phase: int) -> void:
	var debris_color: Color = _boss_phase_debris_color(phase)
	_last_boss_phase_debris_color = debris_color
	for index: int in range(maxi(0, count)):
		var angle: float = (float(index) / float(maxi(1, count))) * TAU
		var outward: Vector2 = Vector2.RIGHT.rotated(angle)
		var shard := _create_vfx_sprite(
			_enemy_debris_texture,
			debris_color,
			BOSS_PHASE_DEBRIS_SPRITE_SCALE
		)
		shard.position = world_position + outward * (12.0 + float(index % 5) * 5.0)
		shard.rotation = angle + float(index % 3) * 0.25
		shard.z_index = 88
		add_child(shard)
		var tween: Tween = create_tween()
		tween.tween_property(
			shard,
			"position",
			shard.position + outward * (58.0 + float(index % 6) * 7.0) + Vector2(0.0, 14.0),
			BOSS_PHASE_DEBRIS_LIFETIME_SEC
		)
		tween.parallel().tween_property(shard, "rotation", shard.rotation + 0.85, BOSS_PHASE_DEBRIS_LIFETIME_SEC)
		tween.parallel().tween_property(shard, "modulate:a", 0.0, BOSS_PHASE_DEBRIS_LIFETIME_SEC)
		tween.tween_callback(shard.queue_free)
		_register_particle_effect(_boss_phase_debris, {
			"node": shard,
			"remaining": BOSS_PHASE_DEBRIS_LIFETIME_SEC,
			"tween": tween,
		})


func _create_vfx_sprite(texture: Texture2D, color: Color, sprite_scale: Vector2) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = true
	sprite.scale = sprite_scale
	sprite.modulate = color
	return sprite


func _latest_active_damage_number_label() -> Label:
	var index: int = _damage_numbers.size() - 1
	while index >= 0:
		var effect: Dictionary = _damage_numbers[index]
		var node: Node = effect.get("node", null)
		if node != null and is_instance_valid(node) and node is Label:
			return node as Label
		index -= 1
	return null


func _remember_weapon_vfx(
	weapon_id: StringName,
	color: Color,
	lifetime_sec: float,
	texture_path: String
) -> void:
	var normalized_weapon_id: StringName = StringName(String(weapon_id))
	_last_weapon_vfx_color_by_weapon[normalized_weapon_id] = color
	_last_weapon_vfx_lifetime_by_weapon[normalized_weapon_id] = lifetime_sec
	_last_weapon_vfx_texture_path_by_weapon[normalized_weapon_id] = texture_path


func _count_active_weapon_vfx(weapon_id: StringName) -> int:
	var count: int = 0
	for effect: Dictionary in _trails:
		if StringName(String(effect.get("weapon_id", &""))) == weapon_id:
			count += 1
	return count


func _tick_effects(effects: Array[Dictionary], delta_sec: float) -> void:
	var index: int = effects.size() - 1
	while index >= 0:
		var effect: Dictionary = effects[index]
		var remaining: float = float(effect.get("remaining", 0.0)) - delta_sec
		if remaining <= 0.0:
			_remove_effect_from_particle_order(effect)
			_release_effect(effect, false)
			effects.remove_at(index)
		else:
			effect["remaining"] = remaining
			effects[index] = effect
		index -= 1


func _register_particle_effect(effects: Array[Dictionary], effect: Dictionary) -> void:
	effect["is_particle"] = true
	effects.append(effect)
	_particle_effect_order.append(effect)
	_enforce_particle_cap()


func _enforce_particle_cap() -> void:
	while get_active_particle_count() > MAX_ACTIVE_PARTICLES and not _particle_effect_order.is_empty():
		var effect: Dictionary = _particle_effect_order.pop_front()
		if _remove_effect_from_particle_buckets(effect):
			_release_effect(effect, true)
			_particle_eviction_count += 1


func _remove_effect_from_particle_buckets(effect: Dictionary) -> bool:
	var removed: bool = false
	removed = _remove_effect_from_bucket(_sparks, effect) or removed
	removed = _remove_effect_from_bucket(_debris, effect) or removed
	removed = _remove_effect_from_bucket(_parry_sparks, effect) or removed
	removed = _remove_effect_from_bucket(_trails, effect) or removed
	removed = _remove_effect_from_bucket(_afterimages, effect) or removed
	removed = _remove_effect_from_bucket(_double_jump_vfx, effect) or removed
	removed = _remove_effect_from_bucket(_boss_phase_debris, effect) or removed
	return removed


func _remove_effect_from_bucket(effects: Array[Dictionary], effect: Dictionary) -> bool:
	var index: int = effects.find(effect)
	if index < 0:
		return false
	effects.remove_at(index)
	return true


func _remove_effect_from_particle_order(effect: Dictionary) -> void:
	if not bool(effect.get("is_particle", false)):
		return
	var index: int = _particle_effect_order.find(effect)
	if index >= 0:
		_particle_effect_order.remove_at(index)


func _release_effect(effect: Dictionary, detach_immediately: bool) -> void:
	var tween: Tween = effect.get("tween", null)
	if tween != null and is_instance_valid(tween):
		tween.kill()
	var node: Node = effect.get("node", null)
	if node == null or not is_instance_valid(node):
		return
	if detach_immediately and node.get_parent() != null:
		node.get_parent().remove_child(node)
	node.queue_free()


func _sample_particle_work() -> int:
	return (
		_sample_particle_array(_sparks)
		+ _sample_particle_array(_debris)
		+ _sample_particle_array(_parry_sparks)
		+ _sample_particle_array(_trails)
		+ _sample_particle_array(_afterimages)
		+ _sample_particle_array(_double_jump_vfx)
		+ _sample_particle_array(_boss_phase_debris)
	)


func _sample_particle_array(effects: Array[Dictionary]) -> int:
	var count: int = 0
	for effect: Dictionary in effects:
		var node: Node = effect.get("node", null)
		if node != null and is_instance_valid(node) and node is Sprite2D:
			var sprite: Sprite2D = node as Sprite2D
			if sprite.visible and sprite.modulate.a >= 0.0:
				count += 1
	return count


func _sample_shake_hitstop_work() -> float:
	return (
		float(_hitstop_frames_remaining)
		+ float(_screen_shake_frames_remaining)
		+ _screen_shake_intensity
		+ _camera_base_offset.length_squared()
	)


func _elapsed_frame_ms(start_usec: int, frames: int) -> float:
	return (float(Time.get_ticks_usec() - start_usec) / 1000.0) / float(maxi(1, frames))


func _apply_camera_shake() -> void:
	if _camera == null or _screen_shake_intensity <= 0.0 or _screen_shake_frames_remaining <= 0:
		return
	var direction: float = -1.0 if _screen_shake_frames_remaining % 2 == 0 else 1.0
	_camera.offset = _camera_base_offset + Vector2(direction * _screen_shake_intensity, 0.0)


func _boss_phase_world_position(metadata: Dictionary) -> Vector2:
	if metadata.has("world_position"):
		return _read_vector2(metadata.get("world_position"))
	if metadata.has("position"):
		return _read_vector2(metadata.get("position"))
	if metadata.has("boss_position"):
		return _read_vector2(metadata.get("boss_position"))
	return Vector2(640.0, 360.0)


func _boss_phase_debris_color(phase: int) -> Color:
	if _colorblind_mode == COLORBLIND_RED_GREEN:
		if phase >= 3:
			return RG_EMPHASIS_COLOR
		return RG_BOSS_METAL_COLOR
	if _colorblind_mode == COLORBLIND_BLUE_YELLOW:
		if phase >= 3:
			return BY_BOSS_OVERLOAD_COLOR
		return BY_EMPHASIS_COLOR
	if phase >= 3:
		return BOSS_PHASE_OVERLOAD_DEBRIS_COLOR
	return BOSS_PHASE_DEBRIS_COLOR


func _normalize_colorblind_mode(mode: StringName) -> StringName:
	if mode == COLORBLIND_RED_GREEN or mode == COLORBLIND_BLUE_YELLOW:
		return mode
	return COLORBLIND_NONE


func _effective_screen_shake_intensity(intensity: float) -> float:
	if _focus_mode_active:
		return intensity * FOCUS_MODE_SHAKE_MULTIPLIER
	return intensity


func _spark_color_for_hit(is_crit: bool) -> Color:
	if _colorblind_mode == COLORBLIND_RED_GREEN:
		return RG_EMPHASIS_COLOR if is_crit else RG_NORMAL_SPARK_COLOR
	if _colorblind_mode == COLORBLIND_BLUE_YELLOW:
		return BY_EMPHASIS_COLOR if is_crit else BY_NORMAL_SPARK_COLOR
	return CRIT_DAMAGE_COLOR if is_crit else SPARK_COLOR


func _parry_spark_color() -> Color:
	if _colorblind_mode == COLORBLIND_RED_GREEN:
		return RG_EMPHASIS_COLOR
	if _colorblind_mode == COLORBLIND_BLUE_YELLOW:
		return BY_PARRY_SPARK_COLOR
	return PARRY_SPARK_COLOR


func _claw_trail_color() -> Color:
	if _colorblind_mode == COLORBLIND_RED_GREEN:
		return RG_EMPHASIS_COLOR
	if _colorblind_mode == COLORBLIND_BLUE_YELLOW:
		return BY_EMPHASIS_COLOR
	return CLAW_TRAIL_COLOR


func _long_tail_arc_color() -> Color:
	if _colorblind_mode == COLORBLIND_RED_GREEN:
		return RG_BOSS_METAL_COLOR
	if _colorblind_mode == COLORBLIND_BLUE_YELLOW:
		return BY_PARRY_SPARK_COLOR
	return LONG_TAIL_ARC_COLOR


func _fish_bone_wave_color() -> Color:
	if _colorblind_mode == COLORBLIND_RED_GREEN:
		return RG_EMPHASIS_COLOR
	if _colorblind_mode == COLORBLIND_BLUE_YELLOW:
		return BY_PARRY_SPARK_COLOR
	return FISH_BONE_WAVE_COLOR


func _electro_bell_arc_color() -> Color:
	if _colorblind_mode == COLORBLIND_RED_GREEN:
		return RG_NORMAL_SPARK_COLOR
	if _colorblind_mode == COLORBLIND_BLUE_YELLOW:
		return BY_EMPHASIS_COLOR
	return ELECTRO_BELL_ARC_COLOR


func _debris_color() -> Color:
	if _colorblind_mode == COLORBLIND_RED_GREEN:
		return RG_DEBRIS_COLOR
	if _colorblind_mode == COLORBLIND_BLUE_YELLOW:
		return BY_DEBRIS_COLOR
	return DEBRIS_COLOR


func _read_vector2(value: Variant) -> Vector2:
	if value is Vector2:
		return value
	if value is Dictionary:
		var data: Dictionary = value
		return Vector2(float(data.get("x", 0.0)), float(data.get("y", 0.0)))
	return Vector2.ZERO


func _read_float(value: Variant, fallback: float) -> float:
	if value is float or value is int:
		return float(value)
	return fallback


func _damage_color_for_amount(damage: int) -> Color:
	if damage >= 61:
		return CRIT_DAMAGE_COLOR
	if damage >= 31:
		return HEAVY_DAMAGE_COLOR
	if damage >= 16:
		return MID_DAMAGE_COLOR
	return NORMAL_DAMAGE_COLOR


func _damage_font_size(damage: int) -> int:
	if damage >= 151:
		return 48
	if damage >= 61:
		return 36
	if damage >= 31:
		return 28
	if damage >= 16:
		return 20
	if damage >= 6:
		return 16
	return 12


func _damage_outline_size(damage: int) -> int:
	if damage >= 151:
		return LEGENDARY_DAMAGE_OUTLINE_SIZE
	return 0
