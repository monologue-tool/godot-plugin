class_name MonologueTimeline extends Node


signal node_reached(node: Dictionary)
signal selected_option(option: Dictionary)

signal _input_next

const KEY_END_OF_SCENE := -1

var base_path: String
var root_node_id: String
var node_list: Array
var images := MonologueResourceManager.new()
var audios := MonologueResourceManager.new()
var voicelines := MonologueResourceManager.new()

var variables: Dictionary = {}
var options: Dictionary = {}

var text_box: MonologueTextBox
var choice_selector
var settings: MonologueProcessSettings

var Action := preload("res://addons/monologue/core/process_logic/action.gd").new()
var Audio := preload("res://addons/monologue/core/process_logic/audio.gd").new()
var Bridge := preload("res://addons/monologue/core/process_logic/bridge.gd").new()
var Choice := preload("res://addons/monologue/core/process_logic/choice.gd").new()
var Condition := preload("res://addons/monologue/core/process_logic/condition.gd").new()
var EndPath := preload("res://addons/monologue/core/process_logic/end_path.gd").new()
var Event := preload("res://addons/monologue/core/process_logic/event.gd").new()
var Random := preload("res://addons/monologue/core/process_logic/random.gd").new()
var Reroute := preload("res://addons/monologue/core/process_logic/reroute.gd").new()
var Root := preload("res://addons/monologue/core/process_logic/root.gd").new()
var Sentence := preload("res://addons/monologue/core/process_logic/sentence.gd").new()
var Setter := preload("res://addons/monologue/core/process_logic/setter.gd").new()
var Wait := preload("res://addons/monologue/core/process_logic/wait.gd").new()


static func load(path: String) -> MonologueTimeline:
	var file = FileAccess.open(path, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	
	var timeline := MonologueTimeline.new()
	timeline.base_path = file.get_path().get_base_dir()
	timeline._load_from_dict(data)
	
	return timeline


func _load_from_dict(dict: Dictionary) -> void:
	node_list = dict.get("ListNodes", [])
	root_node_id = dict.get("RootNodeID")
	
	for variable in dict.get("Variables"):
		variables[variable.get("Name")] = variable
	
	for option in get_nodes_from_type("NodeOption"):
		options[option.get("ID")] = option
		options[option.get("ID")]["Enable"] = option.get("EnableByDefault")
	
	_load_resources(images, "NodeBackground", "Image")
	print("[Monologue] load %s images" % images.size())
	
	_load_resources(audios, "NodeAudio", "Audio")
	print("[Monologue] load %s audio files" % audios.size())
	
	_load_resources(voicelines, "NodeSentence", "Voiceline")
	print("[Monologue] load %s voicelines" % audios.size())
	


func _load_resources(res_manager: MonologueResourceManager, node_type: String, property_name: String) -> void:
	var nodes = get_nodes_from_type(node_type)
	for node in nodes:
		if node.get(property_name) == "":
			continue
		var resource_path = _get_correct_path(node.get(property_name, ""))
		res_manager.load_resource(resource_path, node.get("ID"))


func process() -> void:
	var context := MonologueContext.new()
	context.nodes = node_list
	context.timeline = self
	context.settings = settings
	context.next_node_id = root_node_id
	
	var key = 0
	while key != KEY_END_OF_SCENE:
		choice_selector._clear()
		text_box.show()
		
		var node = context.get_node_from_id(context.next_node_id)
		var node_type = node.get("$type")
		
		var process_result: MonologueProcessResult
		match node_type:
			"NodeAction":
				process_result = await Action.process(context, node)
			"NodeAudio":
				process_result = await Audio.process(context, node)
			"NodeSentence":
				process_result = await Sentence.process(context, node)
			"NodeChoice":
				process_result = await Choice.process(context, node)
			"NodeCondition":
				process_result = await Condition.process(context, node)
			"NodeBridgeIn", "NodeBridgeOut":
				process_result = await Bridge.process(context, node)
			"NodeEndPath":
				process_result = await EndPath.process(context, node)
			"NodeEvent":
				process_result = await Event.process(context, node)
			"NodeRandom":
				process_result = await Random.process(context, node)
			"RerouteNode":
				process_result = await Reroute.process(context, node)
			"NodeRoot":
				process_result = await Root.process(context, node)
			"NodeSetter":
				process_result = await Setter.process(context, node)
			"NodeWait":
				process_result = await Wait.process(context, node)
			_:
				process_result = MonologueProcessResult.exit_process("Riched an unknown node")
		
		match process_result.type:
			MonologueProcessResult.TYPE.CONTINUE:
				context.next_node_id = process_result.data.get("next_node_id")
			MonologueProcessResult.TYPE.INTERRUPT:
				context.next_node_id = process_result.data.get("next_node_id")
				await _input_next
			MonologueProcessResult.TYPE.EXIT:
				key = KEY_END_OF_SCENE


func get_node_from_id(node_id: String) -> Dictionary:
	if node_id is String:
		for node in node_list:
			if node.get("ID") == node_id:
				return node
	return {}


func get_nodes_from_type(type: String) -> Array:
	var result := []
	
	for node in node_list:
		if node.get("$type") != type:
			continue
		result.append(node)
	
	return result


func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_continue"):
		if text_box.visible_characters != -1:
			text_box.force_display()
		_input_next.emit()


func _get_correct_path(path: String) -> String:
	return base_path.path_join(path).simplify_path()


func create_timer(time_sec: float, process_always: bool = true, process_in_physics: bool = false, ignore_time_scale: bool = false) -> SceneTreeTimer:
	return get_tree().create_timer(time_sec, process_always, process_in_physics, ignore_time_scale)
