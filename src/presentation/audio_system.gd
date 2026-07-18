## Presentation-layer audio bus, pool, and playback request coordinator.
##
## ADR-0001 defines AudioSystem as Autoload #3, after InputManager and before
## SaveSystem. Missing streams fail silently so gameplay never depends on asset
## readiness.
extends Node

signal sfx_requested(sfx_id: StringName, metadata: Dictionary)
signal music_requested(music_id: StringName, metadata: Dictionary)
signal ambient_requested(ambient_id: StringName, metadata: Dictionary)
signal ui_sfx_requested(ui_sfx_id: StringName, metadata: Dictionary)
signal bus_volume_changed(bus_name: StringName, volume_percent: int)
signal scene_transition_audio_started(scene_id: StringName, metadata: Dictionary)
signal scene_transition_audio_completed(scene_id: StringName, metadata: Dictionary)
signal scene_transition_audio_failed(scene_id: StringName, reason: StringName)

const BUS_NAMES: Array[StringName] = [&"Master", &"Music", &"SFX", &"Ambient", &"UI"]
const BUS_VOLUME_DEFAULTS: Dictionary = {
	&"Master": 80,
	&"Music": 60,
	&"SFX": 80,
	&"Ambient": 50,
	&"UI": 70,
}
const MAX_CONCURRENT_SFX: int = 16
const MAX_CONCURRENT_UI_SFX: int = 4
const MAX_SFX_DISTANCE_PX: float = 600.0
const SAME_SFX_MERGE_WINDOW_MS: int = 100
const SAME_SFX_MERGE_VOLUME_MULTIPLIER: float = 1.2
const MENU_MUSIC_DUCK_RATIO: float = 0.5
const SCENE_TRANSITION_FORCE_FADE_SEC: float = 2.0
const DEFAULT_SCENE_CROSSFADE_SEC: float = 3.0
const BOSS_MUSIC_HARD_CUT_SEC: float = 1.0
const BOSS_PHASE_MUSIC_TRANSITION_SEC: float = 2.0
const BOSS_MUSIC_END_FADE_SEC: float = 3.0
const AUDIO_STATE_NORMAL: StringName = &"NORMAL"
const AUDIO_STATE_BOSS_FIGHT: StringName = &"BOSS_FIGHT"
const AUDIO_STATE_LOW_HP: StringName = &"LOW_HP"
const AUDIO_STATE_MENU: StringName = &"MENU"
const SFX_PRIORITY_NORMAL: int = 50
const SFX_PRIORITY_DODGE: int = 60
const SFX_PRIORITY_DASH: int = 60
const SFX_PRIORITY_DAMAGE: int = 70
const SFX_PRIORITY_HIGH: int = 90
const SFX_PRIORITY_CRITICAL: int = 100
const WEAPON_ATTACK_SFX: Dictionary = {
	"cat_claw": &"sfx_claw_attack",
	"long_tail": &"sfx_blade_attack",
	"fish_bone": &"sfx_bone_attack",
	"electro_bell": &"sfx_bell_attack",
}
const DEFAULT_SCENE_AUDIO_CUES: Dictionary = {
	"hub": {
		"music_id": &"mus_hub",
		"ambient_id": &"amb_hub",
		"crossfade_sec": DEFAULT_SCENE_CROSSFADE_SEC,
	},
	"main": {
		"music_id": &"mus_street",
		"ambient_id": &"amb_street",
		"crossfade_sec": DEFAULT_SCENE_CROSSFADE_SEC,
	},
	"area_02_sewer": {
		"music_id": &"mus_sewer",
		"ambient_id": &"amb_sewer",
		"crossfade_sec": DEFAULT_SCENE_CROSSFADE_SEC,
	},
	"area_03_factory": {
		"music_id": &"mus_factory",
		"ambient_id": &"amb_factory",
		"crossfade_sec": DEFAULT_SCENE_CROSSFADE_SEC,
	},
	"area_05_neon_rooftops": {
		"music_id": &"mus_rooftop",
		"ambient_id": &"amb_rooftop",
		"crossfade_sec": DEFAULT_SCENE_CROSSFADE_SEC,
	},
}
const DEFAULT_BOSS_MUSIC_CUES: Dictionary = {
	"boss_01_rat_king": {
		1: &"mus_boss_rat_p1",
		2: &"mus_boss_rat_p2",
		3: &"mus_boss_rat_p3",
	},
	"boss_02_echo_guardian": {
		1: &"mus_boss_rat_p1",
		2: &"mus_boss_rat_p2",
	},
}
const DEFAULT_CORE_COMBAT_SFX_STREAMS: Dictionary = {
	&"sfx_claw_attack": "res://assets/audio/sfx/sfx_claw_attack.wav",
	&"sfx_blade_attack": "res://assets/audio/sfx/sfx_blade_attack.wav",
	&"sfx_bone_attack": "res://assets/audio/sfx/sfx_bone_attack.wav",
	&"sfx_bell_attack": "res://assets/audio/sfx/sfx_bell_attack.wav",
	&"sfx_hit_normal": "res://assets/audio/sfx/sfx_hit_normal.wav",
	&"sfx_hit_crit": "res://assets/audio/sfx/sfx_hit_crit.wav",
	&"sfx_parry_perfect": "res://assets/audio/sfx/sfx_parry_perfect.wav",
	&"sfx_parry_good": "res://assets/audio/sfx/sfx_parry_good.wav",
	&"sfx_dodge": "res://assets/audio/sfx/sfx_dodge.wav",
	&"sfx_dash": "res://assets/audio/sfx/sfx_dash.wav",
	&"sfx_damage_taken": "res://assets/audio/sfx/sfx_damage_taken.wav",
	&"sfx_damage_taken_lowhp": "res://assets/audio/sfx/sfx_damage_taken_lowhp.wav",
	&"sfx_enemy_death": "res://assets/audio/sfx/sfx_enemy_death.wav",
	&"sfx_boss_phase": "res://assets/audio/sfx/sfx_boss_phase.wav",
	&"sfx_focus_mode_activate": "res://assets/audio/sfx/sfx_focus_mode_activate.wav",
	&"sfx_double_jump": "res://assets/audio/sfx/sfx_double_jump.wav",
	&"sfx_door_unlock": "res://assets/audio/sfx/sfx_door_unlock_baseline_short.wav",
}
const DEFAULT_BOSS2_SFX_STREAMS: Dictionary = {
	&"sfx_boss2_chase_start": "res://assets/audio/sfx/sfx_boss2_chase_start.wav",
	&"sfx_boss2_attack_startup": "res://assets/audio/sfx/sfx_boss2_attack_startup.wav",
	&"sfx_boss2_attack_active": "res://assets/audio/sfx/sfx_boss2_attack_active.wav",
	&"sfx_boss2_hurt": "res://assets/audio/sfx/sfx_boss2_hurt.wav",
	&"sfx_boss2_defeat": "res://assets/audio/sfx/sfx_boss2_defeat.wav",
	&"sfx_boss2_reward_claim": "res://assets/audio/sfx/sfx_boss2_reward_claim.wav",
}
const BOSS2_EVENT_SFX: Dictionary = {
	&"chase_start": &"sfx_boss2_chase_start",
	&"attack_startup": &"sfx_boss2_attack_startup",
	&"attack_active": &"sfx_boss2_attack_active",
	&"hurt": &"sfx_boss2_hurt",
	&"defeated": &"sfx_boss2_defeat",
	&"reward_claimed": &"sfx_boss2_reward_claim",
}
const BOSS2_EVENT_PRIORITIES: Dictionary = {
	&"chase_start": SFX_PRIORITY_DAMAGE,
	&"attack_startup": SFX_PRIORITY_HIGH,
	&"attack_active": SFX_PRIORITY_CRITICAL,
	&"hurt": SFX_PRIORITY_DAMAGE,
	&"defeated": SFX_PRIORITY_CRITICAL,
	&"reward_claimed": SFX_PRIORITY_HIGH,
}
const DEFAULT_UI_AUDIO_STREAMS: Dictionary = {
	&"ui_menu_open": "res://assets/audio/ui/ui_menu_open.wav",
	&"ui_menu_close": "res://assets/audio/ui/ui_menu_close.wav",
	&"ui_navigate": "res://assets/audio/ui/ui_navigate.wav",
	&"ui_confirm": "res://assets/audio/ui/ui_confirm.wav",
	&"ui_cancel": "res://assets/audio/ui/ui_cancel.wav",
	&"ui_save": "res://assets/audio/ui/ui_save.wav",
	&"ui_load": "res://assets/audio/ui/ui_load.wav",
}
const DEFAULT_MUSIC_AMBIENT_STREAMS: Dictionary = {
	&"mus_hub": "res://assets/audio/music/mus_hub.wav",
	&"mus_street": "res://assets/audio/music/mus_street.wav",
	&"mus_sewer": "res://assets/audio/music/mus_sewer.wav",
	&"mus_factory": "res://assets/audio/music/mus_factory.wav",
	&"mus_rooftop": "res://assets/audio/music/mus_rooftop.wav",
	&"mus_tower": "res://assets/audio/music/mus_tower.wav",
	&"mus_boss_rat_p1": "res://assets/audio/music/mus_boss_rat_p1.wav",
	&"mus_boss_rat_p2": "res://assets/audio/music/mus_boss_rat_p2.wav",
	&"mus_boss_rat_p3": "res://assets/audio/music/mus_boss_rat_p3.wav",
	&"amb_hub": "res://assets/audio/ambient/amb_hub.wav",
	&"amb_street": "res://assets/audio/ambient/amb_street.wav",
	&"amb_sewer": "res://assets/audio/ambient/amb_sewer.wav",
	&"amb_factory": "res://assets/audio/ambient/amb_factory.wav",
	&"amb_rooftop": "res://assets/audio/ambient/amb_rooftop.wav",
	&"amb_tower": "res://assets/audio/ambient/amb_tower.wav",
}

var _bus_volume_percent: Dictionary = {}
var _audio_streams: Dictionary = {}
var _audio_stream_paths: Dictionary = {}
var _scene_audio_cues: Dictionary = {}
var _boss_music_cues: Dictionary = {}
var _sfx_players: Array[AudioStreamPlayer2D] = []
var _ui_sfx_players: Array[AudioStreamPlayer] = []
var _music_player: AudioStreamPlayer
var _ambient_player: AudioStreamPlayer
var _active_sfx_requests: Array[Dictionary] = []
var _last_sfx_request: Dictionary = {}
var _last_ui_sfx_request: Dictionary = {}
var _dropped_sfx_count: int = 0
var _current_music_id: StringName = &""
var _current_ambient_id: StringName = &""
var _music_fade_in_sec: float = 0.0
var _music_fade_out_sec: float = 0.0
var _ambient_fade_in_sec: float = 0.0
var _ambient_fade_out_sec: float = 0.0
var _scene_transition_audio_active: bool = false
var _scene_transition_target_scene_id: StringName = &""
var _scene_transition_spawn_point: StringName = &""
var _scene_transition_metadata: Dictionary = {}
var _scene_transition_failed_scene_id: StringName = &""
var _scene_transition_failed_reason: StringName = &""
var _audio_state: StringName = AUDIO_STATE_NORMAL
var _focus_mode_audio_active: bool = false
var _menu_audio_active: bool = false
var _pre_menu_audio_state: StringName = AUDIO_STATE_NORMAL
var _pre_menu_music_volume_percent: int = int(BUS_VOLUME_DEFAULTS[&"Music"])
var _menu_ducked_music_volume_percent: int = int(BUS_VOLUME_DEFAULTS[&"Music"])
var _last_menu_audio_event: Dictionary = {}
var _last_gameplay_audio_event: Dictionary = {}
var _boss_music_active: bool = false
var _current_boss_id: StringName = &""
var _current_boss_phase: int = 0
var _current_boss_music_id: StringName = &""
var _last_boss_music_event: Dictionary = {}


func _ready() -> void:
	configure_scene_audio_cues(DEFAULT_SCENE_AUDIO_CUES)
	configure_boss_music_cues(DEFAULT_BOSS_MUSIC_CUES)
	load_audio_streams_from_paths(DEFAULT_CORE_COMBAT_SFX_STREAMS)
	load_audio_streams_from_paths(DEFAULT_BOSS2_SFX_STREAMS)
	load_audio_streams_from_paths(DEFAULT_UI_AUDIO_STREAMS)
	load_audio_streams_from_paths(DEFAULT_MUSIC_AMBIENT_STREAMS)
	_initialize_buses()
	_initialize_audio_players()


func _exit_tree() -> void:
	for player: AudioStreamPlayer2D in _sfx_players:
		if is_instance_valid(player):
			player.stop()
	for player: AudioStreamPlayer in _ui_sfx_players:
		if is_instance_valid(player):
			player.stop()
	if is_instance_valid(_music_player):
		_music_player.stop()
	if is_instance_valid(_ambient_player):
		_ambient_player.stop()


## Returns the managed audio bus names in architecture order.
func get_bus_names() -> Array[StringName]:
	return BUS_NAMES.duplicate()


## Returns the current logical volume percentage for a managed bus.
func get_bus_volume_percent(bus_name: StringName) -> int:
	if not _is_managed_bus(bus_name):
		return -1
	return int(_bus_volume_percent.get(bus_name, BUS_VOLUME_DEFAULTS[bus_name]))


## Sets a managed bus volume in percent, clamped to 0..100.
func set_bus_volume(bus_name: StringName, volume_percent: int) -> bool:
	if not _is_managed_bus(bus_name):
		return false
	var clamped_volume: int = clampi(volume_percent, 0, 100)
	_bus_volume_percent[bus_name] = clamped_volume
	_apply_bus_volume(bus_name, clamped_volume)
	bus_volume_changed.emit(bus_name, clamped_volume)
	return true


## Registers an AudioStream by id for tests, tools, and later asset manifests.
func register_audio_stream(audio_id: StringName, stream: AudioStream) -> bool:
	return _register_audio_stream(audio_id, stream, "")


## Loads AudioStream resources from a cue-id to res:// path manifest.
func load_audio_streams_from_paths(audio_stream_paths: Dictionary) -> int:
	var loaded_count: int = 0
	for audio_key: Variant in audio_stream_paths.keys():
		var audio_id: StringName = StringName(String(audio_key))
		var stream_path: String = String(audio_stream_paths.get(audio_key, ""))
		if audio_id == &"" or stream_path.is_empty():
			continue
		var resource: Resource = load(stream_path)
		if not resource is AudioStream:
			continue
		if _register_audio_stream(audio_id, resource as AudioStream, stream_path):
			loaded_count += 1
	return loaded_count


func get_registered_audio_stream_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for audio_id: Variant in _audio_streams.keys():
		ids.append(StringName(String(audio_id)))
	return ids


func get_audio_stream_path(audio_id: StringName) -> String:
	return String(_audio_stream_paths.get(audio_id, ""))


func _register_audio_stream(audio_id: StringName, stream: AudioStream, source_path: String) -> bool:
	if audio_id == &"" or stream == null:
		return false
	_audio_streams[audio_id] = stream
	if source_path.is_empty():
		_audio_stream_paths.erase(audio_id)
	else:
		_audio_stream_paths[audio_id] = source_path
	return true


func unregister_audio_stream(audio_id: StringName) -> bool:
	if not _audio_streams.has(audio_id):
		return false
	_audio_streams.erase(audio_id)
	_audio_stream_paths.erase(audio_id)
	return true


func get_max_concurrent_sfx() -> int:
	return MAX_CONCURRENT_SFX


func get_sfx_pool_size() -> int:
	return _sfx_players.size()


func get_ui_sfx_pool_size() -> int:
	return _ui_sfx_players.size()


func get_active_sfx_count() -> int:
	return _active_sfx_requests.size()


func get_dropped_sfx_count() -> int:
	return _dropped_sfx_count


func get_last_sfx_request() -> Dictionary:
	return _last_sfx_request.duplicate(true)


func get_last_ui_sfx_request() -> Dictionary:
	return _last_ui_sfx_request.duplicate(true)


## Plays or records an SFX request. Missing streams return false without errors.
func play_sfx(
	sfx_id: StringName,
	position: Vector2 = Vector2.ZERO,
	volume_db: float = 0.0,
	pitch_offset: float = 0.0,
	priority: int = 0
) -> bool:
	var pitch_scale: float = _pitch_offset_to_scale(pitch_offset)
	var request: Dictionary = {
		"sfx_id": sfx_id,
		"position": position,
		"volume_db": volume_db,
		"pitch_offset": pitch_offset,
		"pitch_scale": pitch_scale,
		"priority": priority,
		"timestamp_ms": Time.get_ticks_msec(),
		"stream_found": _audio_streams.has(sfx_id),
	}
	_last_sfx_request = request.duplicate(true)
	sfx_requested.emit(sfx_id, request.duplicate(true))

	var stream: AudioStream = _audio_streams.get(sfx_id, null)
	if stream == null:
		return false
	_prune_finished_sfx_requests()
	var merge_index: int = _find_mergeable_sfx_request(sfx_id, int(request["timestamp_ms"]))
	if merge_index >= 0:
		var merged_request: Dictionary = _merge_sfx_request(merge_index, request)
		_last_sfx_request = merged_request.duplicate(true)
		return true

	var player_index: int = _reserve_sfx_player(priority)
	if player_index < 0:
		_dropped_sfx_count += 1
		return false

	request["player_index"] = player_index
	_active_sfx_requests.append(request.duplicate(true))
	_last_sfx_request = request.duplicate(true)
	_play_sfx_player(player_index, stream, position, volume_db, pitch_scale)
	return true


## Plays a global UI cue on the UI bus without spatial attenuation.
func play_ui_sfx(
	ui_sfx_id: StringName,
	volume_db: float = 0.0,
	pitch_offset: float = 0.0,
	priority: int = SFX_PRIORITY_NORMAL
) -> bool:
	return _request_ui_sfx(&"ui_sfx", ui_sfx_id, {}, volume_db, pitch_offset, priority)


## Requests music playback and records fade metadata even when no stream exists.
func play_music(music_id: StringName, fade_in_sec: float = 1.0) -> bool:
	_current_music_id = music_id
	_music_fade_in_sec = maxf(0.0, fade_in_sec)
	_music_fade_out_sec = 0.0
	var metadata: Dictionary = {
		"music_id": music_id,
		"fade_in_sec": _music_fade_in_sec,
		"stream_found": _audio_streams.has(music_id),
	}
	music_requested.emit(music_id, metadata.duplicate(true))
	var stream: AudioStream = _audio_streams.get(music_id, null)
	if stream == null:
		return false
	_music_player.stream = stream
	_music_player.bus = "Music"
	_music_player.play()
	return true


func stop_music(fade_out_sec: float = 1.0) -> void:
	_music_fade_out_sec = maxf(0.0, fade_out_sec)
	_current_music_id = &""
	if is_instance_valid(_music_player):
		_music_player.stop()


func get_current_music_id() -> StringName:
	return _current_music_id


func get_music_fade_in_sec() -> float:
	return _music_fade_in_sec


func get_music_fade_out_sec() -> float:
	return _music_fade_out_sec


## Requests ambience playback and records fade metadata even when no stream exists.
func play_ambient(ambient_id: StringName, fade_in_sec: float = 1.0) -> bool:
	_current_ambient_id = ambient_id
	_ambient_fade_in_sec = maxf(0.0, fade_in_sec)
	_ambient_fade_out_sec = 0.0
	var metadata: Dictionary = {
		"ambient_id": ambient_id,
		"fade_in_sec": _ambient_fade_in_sec,
		"stream_found": _audio_streams.has(ambient_id),
	}
	ambient_requested.emit(ambient_id, metadata.duplicate(true))
	var stream: AudioStream = _audio_streams.get(ambient_id, null)
	if stream == null:
		return false
	_ambient_player.stream = stream
	_ambient_player.bus = "Ambient"
	_ambient_player.play()
	return true


func stop_ambient(fade_out_sec: float = 2.0) -> void:
	_ambient_fade_out_sec = maxf(0.0, fade_out_sec)
	_current_ambient_id = &""
	if is_instance_valid(_ambient_player):
		_ambient_player.stop()


func get_current_ambient_id() -> StringName:
	return _current_ambient_id


func get_ambient_fade_in_sec() -> float:
	return _ambient_fade_in_sec


func get_ambient_fade_out_sec() -> float:
	return _ambient_fade_out_sec


func configure_scene_audio_cues(scene_audio_cues: Dictionary) -> void:
	_scene_audio_cues.clear()
	for scene_key: Variant in scene_audio_cues.keys():
		var cue: Variant = scene_audio_cues.get(scene_key)
		if not cue is Dictionary:
			continue
		_scene_audio_cues[String(scene_key)] = _normalize_scene_audio_cue(Dictionary(cue))


func get_scene_audio_cue(scene_id: StringName) -> Dictionary:
	return Dictionary(_scene_audio_cues.get(String(scene_id), {})).duplicate(true)


func configure_boss_music_cues(boss_music_cues: Dictionary) -> void:
	_boss_music_cues.clear()
	for boss_key: Variant in boss_music_cues.keys():
		var phase_cues_value: Variant = boss_music_cues.get(boss_key)
		if not phase_cues_value is Dictionary:
			continue
		var normalized_phase_cues: Dictionary = {}
		var phase_cues: Dictionary = Dictionary(phase_cues_value)
		for phase_key: Variant in phase_cues.keys():
			var phase: int = int(phase_key)
			var music_id: StringName = StringName(String(phase_cues.get(phase_key, "")))
			if phase <= 0 or music_id == &"":
				continue
			normalized_phase_cues[phase] = music_id
		if not normalized_phase_cues.is_empty():
			_boss_music_cues[String(boss_key)] = normalized_phase_cues


func get_boss_music_cue(boss_id: StringName, phase: int) -> StringName:
	var phase_cues: Dictionary = Dictionary(_boss_music_cues.get(String(boss_id), {}))
	return StringName(String(phase_cues.get(phase, "")))


func is_boss_music_active() -> bool:
	return _boss_music_active


func get_boss_music_state() -> Dictionary:
	return {
		"active": _boss_music_active,
		"boss_id": _current_boss_id,
		"phase": _current_boss_phase,
		"music_id": _current_boss_music_id,
		"audio_state": _audio_state,
		"last_event": _last_boss_music_event.duplicate(true),
	}


func is_scene_transition_audio_active() -> bool:
	return _scene_transition_audio_active


func get_scene_transition_audio_state() -> Dictionary:
	return {
		"active": _scene_transition_audio_active,
		"target_scene_id": _scene_transition_target_scene_id,
		"spawn_point": _scene_transition_spawn_point,
		"metadata": _scene_transition_metadata.duplicate(true),
		"failed_scene_id": _scene_transition_failed_scene_id,
		"failed_reason": _scene_transition_failed_reason,
	}


func get_audio_state() -> StringName:
	return _audio_state


func is_focus_mode_audio_active() -> bool:
	return _focus_mode_audio_active


func is_menu_audio_active() -> bool:
	return _menu_audio_active


func get_menu_audio_state() -> Dictionary:
	return {
		"active": _menu_audio_active,
		"previous_audio_state": _pre_menu_audio_state,
		"music_volume_before_duck": _pre_menu_music_volume_percent,
		"music_volume_ducked": _menu_ducked_music_volume_percent,
		"last_event": _last_menu_audio_event.duplicate(true),
	}


func get_last_gameplay_audio_event() -> Dictionary:
	return _last_gameplay_audio_event.duplicate(true)


## Enters MENU audio state and ducks Music to half of its pre-menu volume.
func on_menu_opened(metadata: Dictionary = {}) -> bool:
	var event_metadata: Dictionary = metadata.duplicate(true)
	if not _menu_audio_active:
		_pre_menu_audio_state = _audio_state
		_pre_menu_music_volume_percent = get_bus_volume_percent(&"Music")
		_menu_ducked_music_volume_percent = int(
			float(_pre_menu_music_volume_percent) * MENU_MUSIC_DUCK_RATIO
		)
		_menu_audio_active = true
		_audio_state = AUDIO_STATE_MENU
		set_bus_volume(&"Music", _menu_ducked_music_volume_percent)
	_last_menu_audio_event = {
		"event_id": &"menu_opened",
		"metadata": event_metadata,
		"previous_audio_state": _pre_menu_audio_state,
		"music_volume_before_duck": _pre_menu_music_volume_percent,
		"music_volume_ducked": _menu_ducked_music_volume_percent,
	}
	return _request_ui_sfx(&"menu_opened", &"ui_menu_open", event_metadata)


## Leaves MENU audio state and restores the Music bus volume captured on open.
func on_menu_closed(metadata: Dictionary = {}) -> bool:
	var event_metadata: Dictionary = metadata.duplicate(true)
	if _menu_audio_active:
		_menu_audio_active = false
		_audio_state = _pre_menu_audio_state
		set_bus_volume(&"Music", _pre_menu_music_volume_percent)
	_last_menu_audio_event = {
		"event_id": &"menu_closed",
		"metadata": event_metadata,
		"previous_audio_state": _pre_menu_audio_state,
		"music_volume_before_duck": _pre_menu_music_volume_percent,
		"music_volume_ducked": _menu_ducked_music_volume_percent,
	}
	return _request_ui_sfx(&"menu_closed", &"ui_menu_close", event_metadata)


func on_ui_navigate(metadata: Dictionary = {}) -> bool:
	return _request_ui_sfx(&"ui_navigate", &"ui_navigate", metadata)


func on_ui_confirm(metadata: Dictionary = {}) -> bool:
	return _request_ui_sfx(&"ui_confirm", &"ui_confirm", metadata)


func on_ui_cancel(metadata: Dictionary = {}) -> bool:
	return _request_ui_sfx(&"ui_cancel", &"ui_cancel", metadata)


func on_ui_save(metadata: Dictionary = {}) -> bool:
	return _request_ui_sfx(&"ui_save", &"ui_save", metadata)


func on_ui_load(metadata: Dictionary = {}) -> bool:
	return _request_ui_sfx(&"ui_load", &"ui_load", metadata)


func on_scene_load_started(
	scene_id: StringName,
	spawn_point: StringName,
	metadata: Dictionary
) -> void:
	_scene_transition_audio_active = true
	_scene_transition_target_scene_id = scene_id
	_scene_transition_spawn_point = spawn_point
	_scene_transition_metadata = metadata.duplicate(true)
	_scene_transition_failed_scene_id = &""
	_scene_transition_failed_reason = &""
	stop_music(SCENE_TRANSITION_FORCE_FADE_SEC)
	stop_ambient(SCENE_TRANSITION_FORCE_FADE_SEC)
	scene_transition_audio_started.emit(scene_id, get_scene_transition_audio_state())


func on_scene_changed(_old_scene: StringName, new_scene: StringName) -> void:
	_scene_transition_audio_active = false
	_scene_transition_target_scene_id = new_scene
	var cue: Dictionary = get_scene_audio_cue(new_scene)
	var crossfade_sec: float = maxf(
		0.0,
		float(cue.get("crossfade_sec", DEFAULT_SCENE_CROSSFADE_SEC))
	)
	var music_id: StringName = StringName(String(cue.get("music_id", "")))
	var ambient_id: StringName = StringName(String(cue.get("ambient_id", "")))
	if music_id != &"":
		play_music(music_id, crossfade_sec)
	if ambient_id != &"":
		play_ambient(ambient_id, crossfade_sec)
	scene_transition_audio_completed.emit(new_scene, get_scene_transition_audio_state())


func on_scene_load_failed(scene_id: StringName, reason: StringName) -> void:
	_scene_transition_audio_active = false
	_scene_transition_failed_scene_id = scene_id
	_scene_transition_failed_reason = reason
	scene_transition_audio_failed.emit(scene_id, reason)


## Routes a resolved hit event to normal or crit impact SFX.
func on_hit_event(hit_data: Dictionary) -> bool:
	var is_crit: bool = bool(hit_data.get("is_crit", false))
	var sfx_id: StringName = &"sfx_hit_crit" if is_crit else &"sfx_hit_normal"
	var priority: int = SFX_PRIORITY_CRITICAL if is_crit else SFX_PRIORITY_NORMAL
	return _request_gameplay_sfx(
		&"hit",
		sfx_id,
		_event_position(hit_data, ["hit_position", "position", "world_position"]),
		priority,
		hit_data
	)


## Routes successful parry events to the matching parry SFX.
func on_parry_event(parry_data: Dictionary) -> bool:
	var parry_type: StringName = StringName(String(parry_data.get("parry_type", &"")))
	var sfx_id: StringName = &""
	var priority: int = SFX_PRIORITY_HIGH
	match parry_type:
		&"perfect":
			sfx_id = &"sfx_parry_perfect"
			priority = SFX_PRIORITY_CRITICAL
		&"good":
			sfx_id = &"sfx_parry_good"
		_:
			return false
	return _request_gameplay_sfx(
		&"parry",
		sfx_id,
		_event_position(parry_data, ["position", "world_position", "hit_position"]),
		priority,
		parry_data
	)


## Routes a player dodge start to spatial dodge SFX.
func on_dodge_event(
	texture_or_metadata: Variant = null,
	world_position: Vector2 = Vector2.ZERO,
	facing: float = 1.0
) -> bool:
	var metadata: Dictionary = {}
	var dodge_position: Vector2 = world_position
	if texture_or_metadata is Dictionary:
		metadata = Dictionary(texture_or_metadata).duplicate(true)
		dodge_position = _event_position(metadata, ["position", "world_position", "hit_position"])
	else:
		metadata = {
			"position": world_position,
			"facing": facing,
		}
	return _request_gameplay_sfx(
		&"dodge",
		&"sfx_dodge",
		dodge_position,
		SFX_PRIORITY_DODGE,
		metadata
	)


## Routes a successful Dash start to its dedicated spatial wind SFX.
func on_dash_event(
	texture_or_metadata: Variant = null,
	world_position: Vector2 = Vector2.ZERO,
	facing: float = 1.0
) -> bool:
	var metadata: Dictionary = {}
	var dash_position: Vector2 = world_position
	if texture_or_metadata is Dictionary:
		metadata = Dictionary(texture_or_metadata).duplicate(true)
		dash_position = _event_position(metadata, ["position", "world_position", "hit_position"])
	else:
		metadata = {
			"position": world_position,
			"facing": facing,
		}
	return _request_gameplay_sfx(
		&"dash",
		&"sfx_dash",
		dash_position,
		SFX_PRIORITY_DASH,
		metadata
	)


## Routes a successful Double Jump activation to the bounce/vortex SFX.
func on_double_jump_event(
	texture_or_metadata: Variant = null,
	world_position: Vector2 = Vector2.ZERO,
	facing: float = 1.0
) -> bool:
	var metadata: Dictionary = {}
	var double_jump_position: Vector2 = world_position
	if texture_or_metadata is Dictionary:
		metadata = Dictionary(texture_or_metadata).duplicate(true)
		double_jump_position = _event_position(metadata, ["position", "world_position", "hit_position"])
	else:
		metadata = {
			"position": world_position,
			"facing": facing,
		}
	return _request_gameplay_sfx(
		&"double_jump",
		&"sfx_double_jump",
		double_jump_position,
		SFX_PRIORITY_DODGE,
		metadata
	)


## Routes a fresh exploration gate unlock to the shared door-open SFX.
func on_exploration_gate_unlocked(
	gate_id: StringName,
	required_ability: StringName,
	target_area_id: StringName,
	world_position: Vector2,
	metadata: Dictionary = {}
) -> bool:
	var event_metadata: Dictionary = metadata.duplicate(true)
	event_metadata["gate_id"] = gate_id
	event_metadata["required_ability"] = required_ability
	event_metadata["target_area_id"] = target_area_id
	event_metadata["world_position"] = world_position
	return _request_gameplay_sfx(
		&"exploration_gate_unlocked",
		&"sfx_door_unlock",
		world_position,
		SFX_PRIORITY_HIGH,
		event_metadata
	)


## Routes a fresh savepoint activation to the shared door-open confirmation SFX.
func on_savepoint_activated(
	savepoint_id: StringName,
	scene_id: StringName,
	spawn_point: StringName,
	world_position: Vector2,
	metadata: Dictionary = {}
) -> bool:
	var event_metadata: Dictionary = metadata.duplicate(true)
	event_metadata["savepoint_id"] = savepoint_id
	event_metadata["scene_id"] = scene_id
	event_metadata["spawn_point"] = spawn_point
	event_metadata["world_position"] = world_position
	return _request_gameplay_sfx(
		&"savepoint_activated",
		&"sfx_door_unlock",
		world_position,
		SFX_PRIORITY_HIGH,
		event_metadata
	)


## Routes a fresh reward-cache claim to the shared cache-open confirmation SFX.
func on_reward_cache_claimed(
	cache_id: StringName,
	reward: Dictionary,
	world_position: Vector2,
	metadata: Dictionary = {}
) -> bool:
	var event_metadata: Dictionary = metadata.duplicate(true)
	event_metadata["cache_id"] = cache_id
	event_metadata["source"] = StringName(String(reward.get("source", cache_id)))
	event_metadata["gears"] = int(reward.get("gears", 0))
	event_metadata["reward_gears"] = int(reward.get("gears", 0))
	event_metadata["world_position"] = world_position
	return _request_gameplay_sfx(
		&"reward_cache_claimed",
		&"sfx_door_unlock",
		world_position,
		SFX_PRIORITY_HIGH,
		event_metadata
	)


## Routes weapon attack startup metadata to a weapon-specific swing SFX.
func on_weapon_attack_event(attack_data: Dictionary) -> bool:
	var weapon_id: StringName = StringName(String(attack_data.get("weapon_id", &"")))
	var sfx_id: StringName = StringName(String(WEAPON_ATTACK_SFX.get(String(weapon_id), &"")))
	if sfx_id == &"":
		return false
	return _request_gameplay_sfx(
		&"weapon_attack",
		sfx_id,
		_event_position(attack_data, ["attack_position", "position", "world_position"]),
		SFX_PRIORITY_NORMAL,
		attack_data
	)


## Routes player damage to standard or focus-mode low-HP injury SFX.
func on_damage_taken_event(damage_data: Dictionary) -> bool:
	var focus_damage: bool = (
		_focus_mode_audio_active
		or bool(damage_data.get("focus_mode_active", false))
	)
	var sfx_id: StringName = &"sfx_damage_taken_lowhp" if focus_damage else &"sfx_damage_taken"
	var priority: int = SFX_PRIORITY_HIGH if focus_damage else SFX_PRIORITY_DAMAGE
	return _request_gameplay_sfx(
		&"damage_taken",
		sfx_id,
		_event_position(damage_data, ["hit_position", "position", "world_position"]),
		priority,
		damage_data,
		float(damage_data.get("pitch_offset", 0.0))
	)


## Tracks LOW_HP audio state and plays the focus-mode activation cue on entry.
func on_focus_mode_changed(entity_id: int, active: bool, metadata: Dictionary) -> bool:
	_focus_mode_audio_active = active
	_audio_state = AUDIO_STATE_LOW_HP if active else AUDIO_STATE_NORMAL
	_last_gameplay_audio_event = {
		"event_id": &"focus_mode_changed",
		"entity_id": entity_id,
		"active": active,
		"metadata": metadata.duplicate(true),
	}
	if not active:
		return true
	return _request_gameplay_sfx(
		&"focus_mode_activate",
		&"sfx_focus_mode_activate",
		_event_position(metadata, ["position", "world_position", "hit_position"]),
		SFX_PRIORITY_HIGH,
		metadata
	)


## Routes enemy defeat presentation metadata to the enemy death SFX.
func on_enemy_defeated(metadata: Dictionary = {}) -> bool:
	return _request_gameplay_sfx(
		&"enemy_defeated",
		&"sfx_enemy_death",
		_event_position(metadata, ["position", "world_position", "hit_position"]),
		SFX_PRIORITY_HIGH,
		metadata
	)


## Routes Boss2 authored runtime feedback events to dedicated spatial SFX.
func on_boss2_audio_event(event_id: StringName, metadata: Dictionary = {}) -> bool:
	var sfx_id: StringName = StringName(String(BOSS2_EVENT_SFX.get(event_id, &"")))
	if sfx_id == &"":
		return false
	var event_metadata: Dictionary = metadata.duplicate(true)
	event_metadata["boss_id"] = StringName(String(event_metadata.get("boss_id", &"boss_02_echo_guardian")))
	event_metadata["event_id"] = event_id
	return _request_gameplay_sfx(
		event_id,
		sfx_id,
		_event_position(event_metadata, ["position", "world_position", "hit_position"]),
		int(BOSS2_EVENT_PRIORITIES.get(event_id, SFX_PRIORITY_HIGH)),
		event_metadata,
		float(event_metadata.get("pitch_offset", 0.0)),
		float(event_metadata.get("volume_db", 0.0))
	)


## Starts boss-fight music for a runtime encounter.
func on_boss_encounter_started(boss_id: StringName, metadata: Dictionary = {}) -> bool:
	var event_metadata: Dictionary = metadata.duplicate(true)
	var phase: int = maxi(1, int(event_metadata.get("phase", 1)))
	return _request_boss_music(
		&"boss_encounter_started",
		_normalize_boss_id(boss_id, event_metadata),
		phase,
		BOSS_MUSIC_HARD_CUT_SEC,
		event_metadata
	)


## Routes boss phase transition presentation metadata to boss phase SFX.
func on_boss_phase_transition_started(entity_id: int, phase: int, metadata: Dictionary) -> bool:
	_audio_state = AUDIO_STATE_BOSS_FIGHT
	var event_metadata: Dictionary = metadata.duplicate(true)
	event_metadata["entity_id"] = entity_id
	event_metadata["phase"] = phase
	var boss_music_requested: bool = _request_boss_music(
		&"boss_phase_transition",
		_normalize_boss_id(&"", event_metadata),
		phase,
		BOSS_PHASE_MUSIC_TRANSITION_SEC,
		event_metadata
	)
	var phase_sfx_requested: bool = _request_gameplay_sfx(
		&"boss_phase_transition",
		&"sfx_boss_phase",
		_event_position(event_metadata, ["world_position", "position", "hit_position"]),
		SFX_PRIORITY_CRITICAL,
		event_metadata
	)
	return boss_music_requested or phase_sfx_requested


## Ends boss-fight music without requiring area music to be ready yet.
func on_boss_encounter_ended(boss_id: StringName, metadata: Dictionary = {}) -> void:
	var event_metadata: Dictionary = metadata.duplicate(true)
	var ended_boss_id: StringName = _normalize_boss_id(boss_id, event_metadata)
	event_metadata["boss_id"] = ended_boss_id
	_last_boss_music_event = {
		"event_id": &"boss_encounter_ended",
		"boss_id": ended_boss_id,
		"phase": _current_boss_phase,
		"music_id": _current_boss_music_id,
		"transition_kind": &"boss_end",
		"transition_sec": BOSS_MUSIC_END_FADE_SEC,
		"fade_out_sec": BOSS_MUSIC_END_FADE_SEC,
		"reason": StringName(String(event_metadata.get("reason", ""))),
		"metadata": event_metadata.duplicate(true),
	}
	_boss_music_active = false
	_current_boss_id = &""
	_current_boss_phase = 0
	_current_boss_music_id = &""
	_audio_state = AUDIO_STATE_LOW_HP if _focus_mode_audio_active else AUDIO_STATE_NORMAL
	stop_music(BOSS_MUSIC_END_FADE_SEC)


func _initialize_buses() -> void:
	for bus_name: StringName in BUS_NAMES:
		var default_volume: int = int(BUS_VOLUME_DEFAULTS[bus_name])
		_bus_volume_percent[bus_name] = default_volume
		_ensure_bus(bus_name)
		_apply_bus_volume(bus_name, default_volume)


func _initialize_audio_players() -> void:
	if _music_player == null:
		_music_player = AudioStreamPlayer.new()
		_music_player.name = "MusicPlayer"
		_music_player.bus = "Music"
		add_child(_music_player)
	if _ambient_player == null:
		_ambient_player = AudioStreamPlayer.new()
		_ambient_player.name = "AmbientPlayer"
		_ambient_player.bus = "Ambient"
		add_child(_ambient_player)
	while _sfx_players.size() < MAX_CONCURRENT_SFX:
		var player := AudioStreamPlayer2D.new()
		player.name = "SFXPlayer%02d" % _sfx_players.size()
		player.bus = "SFX"
		player.max_distance = MAX_SFX_DISTANCE_PX
		_sfx_players.append(player)
		add_child(player)
	while _ui_sfx_players.size() < MAX_CONCURRENT_UI_SFX:
		var player := AudioStreamPlayer.new()
		player.name = "UIPlayer%02d" % _ui_sfx_players.size()
		player.bus = "UI"
		_ui_sfx_players.append(player)
		add_child(player)


func _ensure_bus(bus_name: StringName) -> int:
	var bus_index: int = AudioServer.get_bus_index(bus_name)
	if bus_index >= 0:
		if bus_name != &"Master":
			AudioServer.set_bus_send(bus_index, &"Master")
		return bus_index
	AudioServer.add_bus(AudioServer.get_bus_count())
	bus_index = AudioServer.get_bus_count() - 1
	AudioServer.set_bus_name(bus_index, String(bus_name))
	if bus_name != &"Master":
		AudioServer.set_bus_send(bus_index, &"Master")
	return bus_index


func _apply_bus_volume(bus_name: StringName, volume_percent: int) -> void:
	var bus_index: int = _ensure_bus(bus_name)
	if bus_index < 0:
		return
	AudioServer.set_bus_volume_linear(bus_index, float(volume_percent) / 100.0)


func _pitch_offset_to_scale(pitch_offset: float) -> float:
	return pow(2.0, pitch_offset / 12.0)


func _reserve_sfx_player(priority: int) -> int:
	_prune_finished_sfx_requests()
	for index: int in range(_sfx_players.size()):
		if not _sfx_players[index].playing:
			return index
	if _active_sfx_requests.size() < MAX_CONCURRENT_SFX:
		return _active_sfx_requests.size()

	var lowest_priority_index: int = _lowest_priority_request_index()
	if lowest_priority_index < 0:
		return -1
	var lowest_priority: int = int(_active_sfx_requests[lowest_priority_index].get("priority", 0))
	if priority < lowest_priority:
		return -1

	var player_index: int = int(_active_sfx_requests[lowest_priority_index].get("player_index", -1))
	_active_sfx_requests.remove_at(lowest_priority_index)
	_dropped_sfx_count += 1
	return player_index


func _play_sfx_player(
	player_index: int,
	stream: AudioStream,
	world_position: Vector2,
	volume_db: float,
	pitch_scale: float
) -> void:
	if player_index < 0 or player_index >= _sfx_players.size():
		return
	var player: AudioStreamPlayer2D = _sfx_players[player_index]
	player.stop()
	player.stream = stream
	player.global_position = world_position
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.bus = "SFX"
	player.play()


func _play_ui_sfx_player(
	player_index: int,
	stream: AudioStream,
	volume_db: float,
	pitch_scale: float
) -> void:
	if player_index < 0 or player_index >= _ui_sfx_players.size():
		return
	var player: AudioStreamPlayer = _ui_sfx_players[player_index]
	player.stop()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.bus = "UI"
	player.play()


func _reserve_ui_sfx_player() -> int:
	for index: int in range(_ui_sfx_players.size()):
		if not _ui_sfx_players[index].playing:
			return index
	return 0 if not _ui_sfx_players.is_empty() else -1


func _prune_finished_sfx_requests() -> void:
	for index: int in range(_active_sfx_requests.size() - 1, -1, -1):
		var player_index: int = int(_active_sfx_requests[index].get("player_index", -1))
		if player_index < 0 or player_index >= _sfx_players.size():
			_active_sfx_requests.remove_at(index)
			continue
		if not _sfx_players[player_index].playing:
			_active_sfx_requests.remove_at(index)


func _lowest_priority_request_index() -> int:
	var lowest_index: int = -1
	var lowest_priority: int = 0
	for index: int in range(_active_sfx_requests.size()):
		var request_priority: int = int(_active_sfx_requests[index].get("priority", 0))
		if lowest_index < 0 or request_priority < lowest_priority:
			lowest_index = index
			lowest_priority = request_priority
	return lowest_index


func _find_mergeable_sfx_request(sfx_id: StringName, timestamp_ms: int) -> int:
	for index: int in range(_active_sfx_requests.size() - 1, -1, -1):
		var active_request: Dictionary = Dictionary(_active_sfx_requests[index])
		if StringName(String(active_request.get("sfx_id", &""))) != sfx_id:
			continue
		var player_index: int = int(active_request.get("player_index", -1))
		if player_index < 0 or player_index >= _sfx_players.size():
			continue
		if not _sfx_players[player_index].playing:
			continue
		var elapsed_ms: int = timestamp_ms - int(active_request.get("timestamp_ms", 0))
		if elapsed_ms >= 0 and elapsed_ms <= SAME_SFX_MERGE_WINDOW_MS:
			return index
	return -1


func _merge_sfx_request(merge_index: int, request: Dictionary) -> Dictionary:
	var active_request: Dictionary = Dictionary(_active_sfx_requests[merge_index])
	var player_index: int = int(active_request.get("player_index", -1))
	var current_volume_db: float = float(active_request.get("volume_db", 0.0))
	if player_index >= 0 and player_index < _sfx_players.size():
		current_volume_db = _sfx_players[player_index].volume_db
	var merged_volume_db: float = linear_to_db(
		db_to_linear(current_volume_db) * SAME_SFX_MERGE_VOLUME_MULTIPLIER
	)
	if player_index >= 0 and player_index < _sfx_players.size():
		_sfx_players[player_index].volume_db = merged_volume_db
	active_request["timestamp_ms"] = int(request.get("timestamp_ms", active_request.get("timestamp_ms", 0)))
	active_request["position"] = request.get("position", active_request.get("position", Vector2.ZERO))
	active_request["volume_db"] = merged_volume_db
	active_request["priority"] = maxi(int(active_request.get("priority", 0)), int(request.get("priority", 0)))
	active_request["merged"] = true
	active_request["merged_count"] = int(active_request.get("merged_count", 1)) + 1
	active_request["volume_multiplier"] = SAME_SFX_MERGE_VOLUME_MULTIPLIER
	_active_sfx_requests[merge_index] = active_request.duplicate(true)
	return active_request


func _is_managed_bus(bus_name: StringName) -> bool:
	return BUS_VOLUME_DEFAULTS.has(bus_name)


func _normalize_scene_audio_cue(cue: Dictionary) -> Dictionary:
	return {
		"music_id": StringName(String(cue.get("music_id", ""))),
		"ambient_id": StringName(String(cue.get("ambient_id", ""))),
		"crossfade_sec": maxf(
			0.0,
			float(cue.get("crossfade_sec", DEFAULT_SCENE_CROSSFADE_SEC))
		),
	}


func _normalize_boss_id(boss_id: StringName, metadata: Dictionary) -> StringName:
	if boss_id != &"":
		return boss_id
	return StringName(String(metadata.get("boss_id", "")))


func _request_boss_music(
	event_id: StringName,
	boss_id: StringName,
	phase: int,
	fade_in_sec: float,
	metadata: Dictionary
) -> bool:
	if boss_id == &"":
		return false
	var music_id: StringName = get_boss_music_cue(boss_id, phase)
	if music_id == &"":
		return false
	var transition_sec: float = maxf(0.0, fade_in_sec)
	var event_metadata: Dictionary = metadata.duplicate(true)
	event_metadata["boss_id"] = boss_id
	event_metadata["phase"] = phase
	_boss_music_active = true
	_current_boss_id = boss_id
	_current_boss_phase = phase
	_current_boss_music_id = music_id
	_audio_state = AUDIO_STATE_BOSS_FIGHT
	_last_boss_music_event = {
		"event_id": event_id,
		"boss_id": boss_id,
		"phase": phase,
		"music_id": music_id,
		"transition_kind": &"hard_cut" if phase <= 1 else &"phase_transition",
		"transition_sec": transition_sec,
		"fade_in_sec": transition_sec,
		"stream_found": _audio_streams.has(music_id),
		"audio_state": _audio_state,
		"world_position": _event_position(event_metadata, ["world_position", "position", "hit_position"]),
		"metadata": event_metadata.duplicate(true),
	}
	return play_music(music_id, transition_sec)


func _request_gameplay_sfx(
	event_id: StringName,
	sfx_id: StringName,
	world_position: Vector2,
	priority: int,
	metadata: Dictionary,
	pitch_offset: float = 0.0,
	volume_db: float = 0.0
) -> bool:
	_last_gameplay_audio_event = {
		"event_id": event_id,
		"sfx_id": sfx_id,
		"position": world_position,
		"priority": priority,
		"metadata": metadata.duplicate(true),
	}
	return play_sfx(sfx_id, world_position, volume_db, pitch_offset, priority)


func _request_ui_sfx(
	event_id: StringName,
	ui_sfx_id: StringName,
	metadata: Dictionary,
	volume_db: float = 0.0,
	pitch_offset: float = 0.0,
	priority: int = SFX_PRIORITY_NORMAL
) -> bool:
	var pitch_scale: float = _pitch_offset_to_scale(pitch_offset)
	var request: Dictionary = {
		"event_id": event_id,
		"ui_sfx_id": ui_sfx_id,
		"volume_db": volume_db,
		"pitch_offset": pitch_offset,
		"pitch_scale": pitch_scale,
		"priority": priority,
		"timestamp_ms": Time.get_ticks_msec(),
		"stream_found": _audio_streams.has(ui_sfx_id),
		"metadata": metadata.duplicate(true),
	}
	_last_ui_sfx_request = request.duplicate(true)
	ui_sfx_requested.emit(ui_sfx_id, request.duplicate(true))

	var stream: AudioStream = _audio_streams.get(ui_sfx_id, null)
	if stream == null:
		return false

	var player_index: int = _reserve_ui_sfx_player()
	if player_index < 0:
		return false
	request["player_index"] = player_index
	_last_ui_sfx_request = request.duplicate(true)
	_play_ui_sfx_player(player_index, stream, volume_db, pitch_scale)
	return true


func _event_position(metadata: Dictionary, keys: Array) -> Vector2:
	for key: Variant in keys:
		if metadata.has(String(key)):
			return _read_vector2(metadata.get(String(key)), Vector2.ZERO)
		if metadata.has(StringName(String(key))):
			return _read_vector2(metadata.get(StringName(String(key))), Vector2.ZERO)
	return Vector2.ZERO


func _read_vector2(value: Variant, fallback: Vector2) -> Vector2:
	if value is Vector2:
		return value
	if value is Dictionary:
		var data: Dictionary = Dictionary(value)
		return Vector2(float(data.get("x", fallback.x)), float(data.get("y", fallback.y)))
	return fallback
