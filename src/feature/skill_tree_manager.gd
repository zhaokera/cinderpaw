## Scene-level skill tree modifier provider for unlocked player skills.
extends Node
class_name SkillTreeManager

signal skill_unlocked(skill_id: StringName)

const SKILL_TREE_GROUP: StringName = &"skill_tree_manager"
const SKILL_TREE_DOMAIN: StringName = &"skill_tree"

var _data_manager: Object = null
var _skill_entries: Dictionary = {}
var _unlocked_skills: Array[StringName] = []


func _ready() -> void:
	add_to_group(SKILL_TREE_GROUP)
	var root_data_manager: Node = get_node_or_null("/root/DataManager")
	if root_data_manager != null:
		set_data_manager(root_data_manager)


## Injects a DataManager-compatible source and loads skill node definitions.
func set_data_manager(data_manager: Object) -> void:
	_data_manager = data_manager
	_load_skill_entries()


## Returns true when the skill node exists in the loaded data.
func has_skill_definition(skill_id: StringName) -> bool:
	return not _get_skill_entry(skill_id).is_empty()


## Returns whether a skill node has already been unlocked.
func has_skill(skill_id: StringName) -> bool:
	return _unlocked_skills.has(skill_id)


## Unlocks a known skill once. SP cost is owned by the caller.
func unlock_skill(skill_id: StringName) -> bool:
	if skill_id == &"" or has_skill(skill_id) or not has_skill_definition(skill_id):
		return false
	_unlocked_skills.append(skill_id)
	skill_unlocked.emit(skill_id)
	return true


## Replaces unlocked skill state from save data.
func set_unlocked_skills(skill_ids: Array) -> void:
	_unlocked_skills.clear()
	for value: Variant in skill_ids:
		var skill_id: StringName = StringName(String(value))
		if skill_id != &"" and not _unlocked_skills.has(skill_id):
			_unlocked_skills.append(skill_id)


## Returns unlocked skill ids.
func get_unlocked_skills() -> Array[StringName]:
	return _unlocked_skills.duplicate()


## Returns the SP cost for a skill, or -1 if the skill is unknown.
func get_skill_cost(skill_id: StringName) -> int:
	var entry: Dictionary = _get_skill_entry(skill_id)
	if entry.is_empty():
		return -1
	return maxi(0, int(entry.get("cost", 0)))


## Returns the player-facing display name for a skill.
func get_skill_display_name(skill_id: StringName) -> String:
	var entry: Dictionary = _get_skill_entry(skill_id)
	return String(entry.get("display_name", String(skill_id)))


## Returns a short player-facing summary for a skill.
func get_skill_effect_summary(skill_id: StringName) -> String:
	var entry: Dictionary = _get_skill_entry(skill_id)
	return String(entry.get("effect_summary", ""))


## Returns modifiers from unlocked skills that target an action id.
func get_modifiers(action_id: StringName = &"") -> Array[Dictionary]:
	var modifiers: Array[Dictionary] = []
	for skill_id: StringName in _unlocked_skills:
		var entry: Dictionary = _get_skill_entry(skill_id)
		for raw_modifier: Variant in Array(entry.get("modifiers", [])):
			if not raw_modifier is Dictionary:
				continue
			var modifier: Dictionary = (raw_modifier as Dictionary).duplicate(true)
			var target_action: StringName = StringName(String(modifier.get("target_action", "")))
			if action_id != &"" and target_action != &"" and target_action != action_id:
				continue
			modifier["skill_id"] = skill_id
			modifiers.append(modifier)
	return modifiers


## Returns the summed flat value for a stat key across unlocked modifiers.
func get_stat_bonus(stat_key: StringName) -> float:
	var total: float = 0.0
	for modifier: Dictionary in get_modifiers():
		if StringName(String(modifier.get("stat_key", ""))) == stat_key:
			total += float(modifier.get("value", 0.0))
	return total


## Returns a compact UI model for the current minimal skill tree slice.
func get_hud_entries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for key: Variant in _skill_entries.keys():
		var skill_id: StringName = StringName(String(key))
		var entry: Dictionary = _get_skill_entry(skill_id)
		result.append({
			"skill_id": skill_id,
			"display_name": get_skill_display_name(skill_id),
			"branch": String(entry.get("branch", "")),
			"tier": String(entry.get("tier", "")),
			"node_type": String(entry.get("node_type", "")),
			"cost": get_skill_cost(skill_id),
			"effect_summary": get_skill_effect_summary(skill_id),
			"unlocked": has_skill(skill_id),
		})
	return result


func _load_skill_entries() -> void:
	_skill_entries.clear()
	if _data_manager == null or not _data_manager.has_method("get_domain"):
		return
	var domain: Variant = _data_manager.call("get_domain", SKILL_TREE_DOMAIN)
	if domain is Dictionary:
		_skill_entries = (domain as Dictionary).duplicate(true)


func _get_skill_entry(skill_id: StringName) -> Dictionary:
	if _skill_entries.has(skill_id):
		var entry: Variant = _skill_entries[skill_id]
		return (entry as Dictionary).duplicate(true) if entry is Dictionary else {}
	var string_id: String = String(skill_id)
	if _skill_entries.has(string_id):
		var entry: Variant = _skill_entries[string_id]
		return (entry as Dictionary).duplicate(true) if entry is Dictionary else {}
	return {}
