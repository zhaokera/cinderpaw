## JSON 数据 Schema 验证器（静态工具类）。
##
## 检查必填字段、类型匹配、数值范围、枚举值约束。
## Foundation 层组件——零游戏逻辑。
##
## Schema 格式示例:
##   {
##     "entries": {
##       "cat_claw": {
##         "required": ["weapon_base", "scaling_factor"],
##         "fields": {
##           "weapon_base": {"type": "int", "min": 0, "max": 999},
##           "damage_type": {"type": "String", "enum": ["physical", "magical"]}
##         }
##       }
##     }
##   }
##
## ADR-0003: 数据管理架构
class_name SchemaValidator

## 支持的类型名称 → Godot Variant.Type 常量
const TYPE_MAP: Dictionary = {
	"int": TYPE_INT,
	"float": TYPE_FLOAT,
	"String": TYPE_STRING,
	"bool": TYPE_BOOL,
	"Array": TYPE_ARRAY,
	"Dictionary": TYPE_DICTIONARY,
}


## 验证域数据是否符合 Schema 定义。
##
## 仅验证 schema["entries"] 中明确定义的条目。未在 schema 中定义的条目会被跳过。
##
## Parameters:
##   domain_name - 域名，用于错误消息前缀
##   data - 域数据（包含 "entries" 键的完整域 Dictionary）
##   schema - Schema 定义 Dictionary
##
## Returns: ValidationResult
static func validate(domain_name: String, data: Dictionary, schema: Dictionary) -> ValidationResult:
	var result: ValidationResult = ValidationResult.new()

	var schema_entries: Dictionary = schema.get("entries", {})
	var data_entries: Dictionary = data.get("entries", {})

	for entry_id: String in schema_entries:
		var entry_schema: Dictionary = schema_entries[entry_id]

		if not data_entries.has(entry_id):
			result.add_error("%s.%s: entry missing from data" % [domain_name, entry_id])
			continue

		var entry_data: Dictionary = data_entries[entry_id] as Dictionary
		if entry_data == null:
			result.add_error("%s.%s: entry is not a Dictionary" % [domain_name, entry_id])
			continue

		_validate_entry(domain_name, entry_id, entry_data, entry_schema, result)

	return result


## 验证单条数据条目。
static func _validate_entry(
	domain_name: String,
	entry_id: String,
	entry_data: Dictionary,
	entry_schema: Dictionary,
	result: ValidationResult,
) -> void:
	# 1. 必填字段检查
	var required_fields: Array = entry_schema.get("required", [])
	for field_name: String in required_fields:
		if not entry_data.has(field_name):
			result.add_error("%s.%s.%s: required field missing" % [
				domain_name, entry_id, field_name])

	# 2-4. 字段约束检查（类型、范围、枚举）
	var field_schemas: Dictionary = entry_schema.get("fields", {})
	for field_name: String in field_schemas:
		if not entry_data.has(field_name):
			continue

		var field_schema: Dictionary = field_schemas[field_name]
		var value: Variant = entry_data[field_name]
		var path: String = "%s.%s.%s" % [domain_name, entry_id, field_name]

		# 2. 类型匹配
		if field_schema.has("type"):
			var expected_type: String = field_schema["type"]
			if not _check_type(value, expected_type):
				result.add_error("%s: expected %s, got %s (%s)" % [
					path, expected_type, type_string(typeof(value)), _format_value(value)])
				continue

			# 3. 数值范围
			if field_schema.has("min") or field_schema.has("max"):
				_validate_range(value, field_schema, path, result)

			# 4. 枚举值
			if field_schema.has("enum"):
				var allowed: Array = field_schema["enum"]
				if value not in allowed:
					result.add_error("%s: value %s not in enum %s" % [
						path, _format_value(value), str(allowed)])

			# 5. 嵌套 Dictionary 字段约束
			if field_schema.has("fields") and value is Dictionary:
				_validate_nested_fields(value as Dictionary, field_schema, path, result)

			# 6. Array 元素约束
			if field_schema.has("items") and value is Array:
				_validate_array_items(value as Array, field_schema, path, result)


static func _validate_nested_fields(
	entry_data: Dictionary,
	entry_schema: Dictionary,
	path: String,
	result: ValidationResult
) -> void:
	var required_fields: Array = entry_schema.get("required", [])
	for field_name: String in required_fields:
		if not entry_data.has(field_name):
			result.add_error("%s.%s: required field missing" % [path, field_name])

	var field_schemas: Dictionary = entry_schema.get("fields", {})
	for field_name: String in field_schemas:
		if not entry_data.has(field_name):
			continue
		var field_schema: Dictionary = field_schemas[field_name]
		var value: Variant = entry_data[field_name]
		var field_path: String = "%s.%s" % [path, field_name]
		_validate_field(value, field_schema, field_path, result)


static func _validate_field(
	value: Variant,
	field_schema: Dictionary,
	path: String,
	result: ValidationResult
) -> void:
	if field_schema.has("type"):
		var expected_type: String = field_schema["type"]
		if not _check_type(value, expected_type):
			result.add_error("%s: expected %s, got %s (%s)" % [
				path, expected_type, type_string(typeof(value)), _format_value(value)])
			return
	if field_schema.has("min") or field_schema.has("max"):
		_validate_range(value, field_schema, path, result)
	if field_schema.has("enum"):
		var allowed: Array = field_schema["enum"]
		if value not in allowed:
			result.add_error("%s: value %s not in enum %s" % [
				path, _format_value(value), str(allowed)])
	if field_schema.has("fields") and value is Dictionary:
		_validate_nested_fields(value as Dictionary, field_schema, path, result)
	if field_schema.has("items") and value is Array:
		_validate_array_items(value as Array, field_schema, path, result)


static func _validate_array_items(
	values: Array,
	array_schema: Dictionary,
	path: String,
	result: ValidationResult
) -> void:
	var item_schema: Dictionary = array_schema.get("items", {})
	if item_schema.is_empty():
		return
	for index: int in range(values.size()):
		_validate_field(values[index], item_schema, "%s[%d]" % [path, index], result)


## 检查值是否匹配指定类型名称。
static func _check_type(value: Variant, expected_type: String) -> bool:
	if not TYPE_MAP.has(expected_type):
		return true
	var expected: int = TYPE_MAP[expected_type]
	var actual: int = typeof(value)
	if expected == TYPE_INT and actual == TYPE_FLOAT:
		return value == floor(value)
	if expected == TYPE_FLOAT and actual == TYPE_INT:
		return true
	return actual == expected


## 验证数值范围约束（min/max）。
static func _validate_range(
	value: Variant, field_schema: Dictionary, path: String, result: ValidationResult,
) -> void:
	if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
		return
	if field_schema.has("min") and value < field_schema["min"]:
		result.add_error("%s: value %s below minimum %s" % [
			path, _format_value(value), str(field_schema["min"])])
	if field_schema.has("max") and value > field_schema["max"]:
		result.add_error("%s: value %s above maximum %s" % [
			path, _format_value(value), str(field_schema["max"])])


## 将值格式化为字符串用于错误消息。
static func _format_value(value: Variant) -> String:
	match typeof(value):
		TYPE_INT, TYPE_FLOAT:
			return str(value)
		TYPE_STRING:
			return '"%s"' % value
		_:
			return str(value)
