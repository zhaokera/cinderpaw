## Scene-local one-shot combat cache gated by an encounter clear state.
class_name FactoryCombatCache
extends Node2D

signal cache_claimed(cache_id: StringName, reward: Dictionary)

@export var cache_id: StringName = &"old_factory_entrance_cache"
@export var reward_gears: int = 10
@export var claim_radius_px: float = 96.0
@export var locked_prompt_text: String = "Clear room"
@export var available_prompt_text: String = "+10 Gears"
@export var claimed_prompt_text: String = "Claimed"

@onready var _visual: Sprite2D = get_node_or_null("Visual") as Sprite2D
@onready var _prompt_label: Label = get_node_or_null("PromptLabel") as Label
@onready var _interaction_area: Area2D = get_node_or_null("InteractionArea") as Area2D

var _available: bool = false
var _claimed: bool = false


func _ready() -> void:
	add_to_group("factory_combat_cache")
	_sync_state()


## Returns the deterministic room cache id used for save/diagnostic state.
func get_cache_id() -> StringName:
	return cache_id


## Returns the imported texture path mounted by the visible cache sprite.
func get_visual_texture_path() -> String:
	if _visual == null or _visual.texture == null:
		return ""
	return _visual.texture.resource_path


## Returns whether combat has cleared and this cache can be claimed.
func is_available() -> bool:
	return _available


## Returns whether a nearby player can claim the cache right now.
func is_claim_available() -> bool:
	return _available and not _claimed


## Returns whether this cache's one-time reward has already been consumed.
func is_claimed() -> bool:
	return _claimed


## Sets whether the room clear state makes the cache available.
func set_available(available: bool) -> void:
	_available = available
	_sync_state()


## Restores or applies the one-time claimed state.
func set_claimed(claimed: bool) -> void:
	_claimed = claimed
	_sync_state()


## Checks whether a provider node is close enough to claim the cache.
func is_provider_in_reward_range(provider: Node) -> bool:
	if provider == null or not provider is Node2D:
		return false
	var provider_node := provider as Node2D
	return global_position.distance_to(provider_node.global_position) <= claim_radius_px


## Returns the deterministic reward payload without mutating claim state.
func get_reward_payload() -> Dictionary:
	return {
		"cache_id": String(cache_id),
		"gears": reward_gears,
		"source": "old_factory_combat_cache",
	}


## Attempts a once-only claim for a nearby provider.
func try_claim(provider: Node = null) -> bool:
	if not is_claim_available():
		return false
	if provider != null and not is_provider_in_reward_range(provider):
		return false
	_claimed = true
	_sync_state()
	cache_claimed.emit(cache_id, get_reward_payload())
	return true


func _sync_state() -> void:
	if _visual != null:
		if _claimed:
			_visual.modulate = Color(0.45, 0.52, 0.62, 0.42)
		elif _available:
			_visual.modulate = Color.WHITE
		else:
			_visual.modulate = Color(0.56, 0.62, 0.72, 0.72)
	if _prompt_label != null:
		_prompt_label.text = _prompt_text()
		_prompt_label.visible = not _claimed
	if _interaction_area != null:
		_interaction_area.monitoring = is_claim_available()
		_interaction_area.monitorable = is_claim_available()


func _prompt_text() -> String:
	if _claimed:
		return claimed_prompt_text
	if _available:
		return available_prompt_text
	return locked_prompt_text
