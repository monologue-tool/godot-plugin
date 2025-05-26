@tool
class_name MonologueResourceManager


var resources: Dictionary = {}


func is_fully_loaded() -> bool:
	return true


func load_resource(resource_path: String, resource_id: Variant, meta: Dictionary = {}) -> void:
	var res = load(resource_path)
	resources[resource_id] = {
		"ressource": res,
		"metadata": meta
	}


func load_premade_resource(resource: Variant, resource_id: Variant, meta: Dictionary = {}) -> void:
	resources[resource_id] = {
		"ressource": resource,
		"metadata": meta
	}


func get_resource(resource_id: Variant) -> Variant:
	return resources.get(resource_id, {}).get("ressource")


func get_resource_meta(resource_id: Variant) -> Variant:
	return resources.get(resource_id, {}).get("metadata")


func clear() -> void:
	resources.clear()


func size() -> int:
	return resources.size()
