class_name MonologueContext extends Node


var timeline: MonologueTimeline
var settings: MonologueProcessSettings

var nodes: Array :
	get: return timeline.node_list
var next_node_id: String = ""

var characters_pool: Array
var options: Dictionary :
	get: return timeline.options
var variables: Dictionary :
	get: return timeline.variables


func get_next_node() -> Dictionary:
	return timeline.get_node_from_id(next_node_id)


func display_text(text: String, speaker_name: String = "", override_speed: int = settings.text_speed) -> void:
	timeline.text_box.display(text, speaker_name, settings.text_speed)
	await timeline.text_box.display_finished
	

func display_option() -> void:
	pass


func clear_all_options() -> void:
	pass


func get_node_from_id(node_id: String) -> Dictionary: return timeline.get_node_from_id(node_id)
func get_nodes_from_type(type: String) -> Array: return timeline.get_nodes_from_type(type)
