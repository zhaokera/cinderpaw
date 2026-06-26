## Scene-level ability gate that turns player ability unlocks into level access.
class_name ExplorationGate
extends Node2D

signal gate_state_changed(gate_id: StringName, state: StringName)

const GROUP_NAME: StringName = &"exploration_gate"
const STATE_LOCKED: StringName = &"locked"
const STATE_UNLOCKABLE: StringName = &"unlockable"
const STATE_UNLOCKED: StringName = &"unlocked"
const DEFAULT_UNLOCK_FEEDBACK_TEXTURE_PATH: String = "res://assets/environment/ability_gate/vfx/vfx_ability_gate_unlock_dissolve_burst_256.png"
const UNLOCK_FEEDBACK_ASSET_SOURCE: String = "image_generation"
const UNLOCK_VFX_NODE_NAME: StringName = &"UnlockVfx"

@export var gate_id: String = ""
@export var required_ability: String = "dash"
@export var target_area_id: String = "area_02_sewer"
@export var unlock_radius_px: float = 96.0
@export var unlock_feedback_texture_path: String = DEFAULT_UNLOCK_FEEDBACK_TEXTURE_PATH
@export var unlock_feedback_duration_sec: float = 0.5
@export var unlock_feedback_scale: float = 1.0
@export var locked_prompt_text: String = "Requires Dash"
@export var unlockable_prompt_text: String = "Dash through"
@export var locked_modulate: Color = Color(1.0, 0.24, 0.16, 1.0)
@export var unlockable_modulate: Color = Color(1.0, 0.86, 0.20, 1.0)
@export var unlocked_modulate: Color = Color(0.48, 0.92, 1.0, 0.28)

var _ability_provider: Object = null
var _state: StringName = STATE_LOCKED
var _collision_shape: CollisionShape2D = null
var _visual: CanvasItem = null
var _prompt_label: Label = null
var _unlock_feedback_texture: Texture2D = null
var _unlock_feedback_vfx: Sprite2D = null
var _unlock_feedback_elapsed_sec: float = 0.0
var _unlock_feedback_spawn_count: int = 0
var _last_unlock_feedback_spawn: Dictionary = {}


func _ready() -> void:
	set_process(false)
	add_to_group(GROUP_NAME)
	_resolve_child_nodes()
	if _ability_provider == null:
		var provider: Object = _find_default_ability_provider()
		if provider != null:
			set_ability_provider(provider)
			return
	refresh_gate_state()


func _process(delta: float) -> void:
	advance_unlock_feedback_time(delta)


## Sets the ability provider used for has_ability queries and ability signals.
func set_ability_provider(provider: Object) -> void:
	if _ability_provider == provider:
		refresh_gate_state()
		return
	_disconnect_ability_provider()
	_ability_provider = provider
	_connect_ability_provider()
	refresh_gate_state()


func get_gate_id() -> StringName:
	if not gate_id.is_empty():
		return StringName(gate_id)
	return StringName(name)


func get_required_ability() -> StringName:
	return StringName(required_ability)


func get_target_area_id() -> StringName:
	return StringName(target_area_id)


func get_gate_state() -> StringName:
	return _state


func get_unlock_feedback_texture_path() -> String:
	return unlock_feedback_texture_path


func get_unlock_feedback_snapshot() -> Dictionary:
	return {
		"texture_path": get_unlock_feedback_texture_path(),
		"asset_source": UNLOCK_FEEDBACK_ASSET_SOURCE,
		"duration_sec": maxf(0.01, unlock_feedback_duration_sec),
		"active_count": 1 if _is_unlock_feedback_active() else 0,
		"spawn_count": _unlock_feedback_spawn_count,
		"elapsed_sec": _unlock_feedback_elapsed_sec,
		"last_spawn": _last_unlock_feedback_spawn.duplicate(true),
	}


func is_unlocked() -> bool:
	return _state == STATE_UNLOCKED


func is_collision_blocking() -> bool:
	return _collision_shape != null and not _collision_shape.disabled


func is_provider_in_unlock_range() -> bool:
	if _ability_provider == null or not is_instance_valid(_ability_provider):
		return false
	if not (_ability_provider is Node2D):
		return false
	var provider_node := _ability_provider as Node2D
	return provider_node.global_position.distance_to(global_position) <= maxf(0.0, unlock_radius_px)


## Rechecks ability state unless the gate has already been permanently opened.
func refresh_gate_state() -> void:
	_resolve_child_nodes()
	if _state == STATE_UNLOCKED:
		_apply_state(STATE_UNLOCKED)
		return
	if _has_required_ability():
		_apply_state(STATE_UNLOCKABLE)
	else:
		_apply_state(STATE_LOCKED)


## Restores a persisted open state; false falls back to current ability checks.
func set_gate_unlocked(unlocked: bool) -> void:
	if unlocked:
		_apply_state(STATE_UNLOCKED, false, false)
		return
	_state = STATE_LOCKED
	refresh_gate_state()


func unlock_gate(play_feedback: bool = true) -> void:
	_apply_state(STATE_UNLOCKED, true, play_feedback)


func advance_unlock_feedback_time(delta_sec: float) -> void:
	if not _is_unlock_feedback_active():
		set_process(false)
		return
	_unlock_feedback_elapsed_sec += maxf(0.0, delta_sec)
	var duration: float = maxf(0.01, unlock_feedback_duration_sec)
	var progress: float = clampf(_unlock_feedback_elapsed_sec / duration, 0.0, 1.0)
	_unlock_feedback_vfx.modulate = Color(1.0, 1.0, 1.0, 1.0 - progress)
	var current_scale: float = lerpf(unlock_feedback_scale, unlock_feedback_scale * 1.12, progress)
	_unlock_feedback_vfx.scale = Vector2(current_scale, current_scale)
	if _unlock_feedback_elapsed_sec >= duration:
		_clear_unlock_feedback_vfx()


func _resolve_child_nodes() -> void:
	if _collision_shape == null or not is_instance_valid(_collision_shape):
		_collision_shape = find_child("CollisionShape2D", true, false) as CollisionShape2D
	if _visual == null or not is_instance_valid(_visual):
		_visual = find_child("Visual", true, false) as CanvasItem
	if _prompt_label == null or not is_instance_valid(_prompt_label):
		_prompt_label = find_child("PromptLabel", true, false) as Label


func _find_default_ability_provider() -> Object:
	if not is_inside_tree():
		return null
	var scene_root: Node = get_tree().current_scene
	if scene_root != null:
		var player: Node = scene_root.get_node_or_null("Player")
		if player != null:
			return player
	var parent_node: Node = get_parent()
	if parent_node != null:
		return parent_node.get_node_or_null("Player")
	return null


func _connect_ability_provider() -> void:
	if _ability_provider is PlayerController:
		var player := _ability_provider as PlayerController
		if not player.ability_unlocked.is_connected(_on_ability_unlocked):
			player.ability_unlocked.connect(_on_ability_unlocked)
		if not player.ability_activated.is_connected(_on_ability_activated):
			player.ability_activated.connect(_on_ability_activated)
	elif _ability_provider is AbilityComponent:
		var abilities := _ability_provider as AbilityComponent
		if not abilities.ability_unlocked.is_connected(_on_ability_unlocked):
			abilities.ability_unlocked.connect(_on_ability_unlocked)
		if not abilities.ability_activated.is_connected(_on_ability_activated):
			abilities.ability_activated.connect(_on_ability_activated)


func _disconnect_ability_provider() -> void:
	if _ability_provider == null or not is_instance_valid(_ability_provider):
		return
	if _ability_provider is PlayerController:
		var player := _ability_provider as PlayerController
		if player.ability_unlocked.is_connected(_on_ability_unlocked):
			player.ability_unlocked.disconnect(_on_ability_unlocked)
		if player.ability_activated.is_connected(_on_ability_activated):
			player.ability_activated.disconnect(_on_ability_activated)
	elif _ability_provider is AbilityComponent:
		var abilities := _ability_provider as AbilityComponent
		if abilities.ability_unlocked.is_connected(_on_ability_unlocked):
			abilities.ability_unlocked.disconnect(_on_ability_unlocked)
		if abilities.ability_activated.is_connected(_on_ability_activated):
			abilities.ability_activated.disconnect(_on_ability_activated)


func _has_required_ability() -> bool:
	if _ability_provider == null or not is_instance_valid(_ability_provider):
		return false
	var required_ability_id: StringName = get_required_ability()
	if _ability_provider.has_method("has_ability"):
		return bool(_ability_provider.call("has_ability", required_ability_id))
	var ability_component: AbilityComponent = null
	if _ability_provider is Node:
		ability_component = (_ability_provider as Node).get_node_or_null("AbilityComponent") as AbilityComponent
	return ability_component != null and ability_component.has_ability(required_ability_id)


func _on_ability_unlocked(ability_id: StringName) -> void:
	if ability_id == get_required_ability():
		refresh_gate_state()


func _on_ability_activated(ability_id: StringName) -> void:
	if ability_id == get_required_ability() and _has_required_ability() and is_provider_in_unlock_range():
		unlock_gate()


func _apply_state(
	next_state: StringName,
	emit_state_signal: bool = true,
	play_unlock_feedback: bool = false
) -> void:
	var state_changed: bool = _state != next_state
	_state = next_state
	if _collision_shape != null:
		_collision_shape.disabled = _state == STATE_UNLOCKED
	if _visual != null:
		_visual.modulate = _modulate_for_state(_state)
	if _prompt_label != null:
		_prompt_label.text = _prompt_for_state(_state)
		_prompt_label.visible = _state != STATE_UNLOCKED
	set_meta("gate_id", String(get_gate_id()))
	set_meta("required_ability", String(get_required_ability()))
	set_meta("target_area_id", String(get_target_area_id()))
	set_meta("gate_state", String(_state))
	if state_changed and _state == STATE_UNLOCKED and play_unlock_feedback:
		_spawn_unlock_feedback_vfx()
	if state_changed and emit_state_signal:
		gate_state_changed.emit(get_gate_id(), _state)


func _modulate_for_state(state: StringName) -> Color:
	match state:
		STATE_UNLOCKED:
			return unlocked_modulate
		STATE_UNLOCKABLE:
			return unlockable_modulate
		_:
			return locked_modulate


func _prompt_for_state(state: StringName) -> String:
	match state:
		STATE_UNLOCKED:
			return ""
		STATE_UNLOCKABLE:
			return unlockable_prompt_text
		_:
			return locked_prompt_text


func _spawn_unlock_feedback_vfx() -> void:
	_clear_unlock_feedback_vfx()
	var texture: Texture2D = _load_unlock_feedback_texture()
	if texture == null:
		return
	var vfx := Sprite2D.new()
	vfx.name = String(UNLOCK_VFX_NODE_NAME)
	vfx.texture = texture
	vfx.centered = true
	vfx.z_index = 40
	vfx.scale = Vector2(unlock_feedback_scale, unlock_feedback_scale)
	vfx.set_meta("asset_source", UNLOCK_FEEDBACK_ASSET_SOURCE)
	vfx.set_meta("vfx_role", "ability_gate_unlock")
	vfx.set_meta("gate_id", String(get_gate_id()))
	vfx.set_meta("required_ability", String(get_required_ability()))
	vfx.set_meta("target_area_id", String(get_target_area_id()))
	add_child(vfx)
	_unlock_feedback_vfx = vfx
	_unlock_feedback_elapsed_sec = 0.0
	_unlock_feedback_spawn_count += 1
	_last_unlock_feedback_spawn = {
		"gate_id": get_gate_id(),
		"required_ability": get_required_ability(),
		"target_area_id": get_target_area_id(),
		"texture_path": get_unlock_feedback_texture_path(),
		"asset_source": UNLOCK_FEEDBACK_ASSET_SOURCE,
		"world_position": global_position,
	}
	set_process(true)


func _load_unlock_feedback_texture() -> Texture2D:
	if (
		_unlock_feedback_texture != null
		and is_instance_valid(_unlock_feedback_texture)
		and _unlock_feedback_texture.resource_path == unlock_feedback_texture_path
	):
		return _unlock_feedback_texture
	if unlock_feedback_texture_path.is_empty():
		return null
	var resource: Resource = load(unlock_feedback_texture_path)
	if resource is Texture2D:
		_unlock_feedback_texture = resource as Texture2D
		return _unlock_feedback_texture
	return null


func _is_unlock_feedback_active() -> bool:
	return _unlock_feedback_vfx != null and is_instance_valid(_unlock_feedback_vfx)


func _clear_unlock_feedback_vfx() -> void:
	if _is_unlock_feedback_active():
		if _unlock_feedback_vfx.get_parent() != null:
			_unlock_feedback_vfx.get_parent().remove_child(_unlock_feedback_vfx)
		_unlock_feedback_vfx.free()
	_unlock_feedback_vfx = null
	_unlock_feedback_elapsed_sec = 0.0
	set_process(false)
