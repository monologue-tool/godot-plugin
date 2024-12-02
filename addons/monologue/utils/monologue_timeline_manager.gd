@tool
class_name MonologueResourceManager


var resources: Dictionary = {}


func is_fully_loaded() -> bool:
	return true


func load_resource(resource_path: String, resource_id: Variant) -> void:
	var res = load(resource_path)
	resources[resource_id] = res


func get_resource(resource_id: Variant) -> Variant:
	return resources.get(resource_id)


func clear() -> void:
	resources.clear()


func size() -> int:
	return resources.size()
