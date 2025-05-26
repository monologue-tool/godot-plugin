class_name MonologueTimeline extends Node
## A node for interpreting a Monologue file.
##
## The [MonologueTimeline] node is responsible for interpreting and processing a specific dialogue timeline defined in a JSON file.[br]
## It manages the sequence of dialogue nodes, resource loading, and progression through the dialogue.[br]
## [br]
## We advise you not to instantiate it yourself, but to use a [MonologueProcess] node instead.

# Signals to track node and option states
signal timeline_ended
signal node_reached(node: Dictionary)
signal selected_option(option: Dictionary)
signal _input_next

# Basic timeline properties
var base_path: String
var root_node_id: String
var node_list: Array
var fallback_id_stack: Array = []

# Resource managers
var images := MonologueResourceManager.new()
var audios := MonologueResourceManager.new()
var voicelines := MonologueResourceManager.new()

# Timeline variables and options
var variables: Dictionary = {}
var characters: Array = []
var options: Dictionary = {}

# UI component references
var text_box: MonologueTextBox
var text_box_container: Control
var choice_selector: Node
var background: TextureRect
var character_displayer: MonologueCharacterDisplayer
var settings: MonologueProcessSettings

# Preload and instantiate logic nodes
var Action := preload("res://addons/monologue/core/process_logic/action.gd").new()
var Audio := preload("res://addons/monologue/core/process_logic/audio.gd").new()
var Bridge := preload("res://addons/monologue/core/process_logic/bridge.gd").new()
var Background := preload("res://addons/monologue/core/process_logic/background.gd").new()
var Character := preload("res://addons/monologue/core/process_logic/character.gd").new()
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

# List of available logic nodes
var logic_nodes = [Action, Audio, Bridge, Choice, 
	Condition, EndPath, Event, Random, 
	Reroute, Root, Sentence, Setter, Wait]

# Context and current state of the timeline
var context := MonologueContext.new()
var current_logic: MonologueProcessLogic = null
var current_node: Dictionary = {}
var last_result: MonologueProcessResult
var _active: bool = false
var text_box_container_mouse_hovering: bool = false

# Static method to load a timeline from a file
static func load(path: String) -> MonologueTimeline:
	var file = FileAccess.open(path, FileAccess.READ)
	var data: Dictionary = JSON.parse_string(file.get_as_text())
	
	var timeline := MonologueTimeline.new()
	timeline.base_path = file.get_path().get_base_dir()
	timeline._load_from_dict(data)
	
	for node in timeline.logic_nodes:
		timeline.add_child(node)
	
	return timeline

# Load timeline data from a dictionary
func _load_from_dict(dict: Dictionary) -> void:
	node_list = dict.get("ListNodes", [])
	root_node_id = dict.get("RootNodeID")
	
	# Load characters
	var raw_characters: Array = dict.get("Characters", [])
	characters.resize(raw_characters.size())
	for character in raw_characters:
		characters[int(character.get("EditorIndex"))] = character
	
	# Load variables
	for variable in dict.get("Variables", []):
		variables[variable.get("Name")] = variable
	
	# Load options
	for option in get_nodes_from_type("NodeOption"):
		options[option.get("ID")] = option
		options[option.get("ID")]["Enable"] = option.get("EnableByDefault", true)
	
	# Load resources
	_load_resources(images, "NodeBackground", "Image")
	_load_resources(audios, "NodeAudio", "Audio")
	_load_characters()
	_load_voicelines()
	
	# Print loading statistics
	print("[Monologue] Loaded %s images" % images.size())
	print("[Monologue] Loaded %s audio files" % audios.size())
	print("[Monologue] Loaded %s voicelines" % voicelines.size())


# Load resources for a specific node type
func _load_resources(res_manager: MonologueResourceManager, node_type: String, property_name: String) -> void:
	for node in get_nodes_from_type(node_type):
		var resource_path = node.get(property_name, "")
		if resource_path.is_empty():
			continue
		res_manager.load_resource(_get_correct_path(resource_path), node.get("ID"))


func _load_characters() -> void:
	for character in characters:
		var character_data: Dictionary = character.get("Character")
		var character_idx: int = int(character.get("EditorIndex", 0))
		var portraits: Array = character_data.get("Portraits", [])
		for portrait in portraits:
			var portrait_name: String = portrait.get("Name", "")
			var portrait_data: Dictionary = portrait.get("Portrait", {})
			var portrait_type: String = portrait_data.get("PortraitType", "Image")
			
			if portrait_type == "Image":
				var image_path: String = portrait_data.get("ImagePath", "")
				if image_path.is_empty():
					continue
				var ressource_id: String = "%s_%s" % [character_idx, portrait_name]
				images.load_resource(_get_correct_path(image_path), ressource_id, portrait_data)
			elif portrait_type == "Animation":
				var animation_data: Dictionary = portrait_data.get("Animation", {})
				var fps: float = animation_data.get("Fps", 12.0)
				var frame_count: int = int(animation_data.get("FrameCount", 1))
				var layers: Array = animation_data.get("Layers", [])
				var combined_textures: Array[Texture2D] = []
				combined_textures.resize(frame_count)
				
				for i in range(frame_count):
					var layers_im: Array[Texture2D] = []
					for layer in layers:
						var frame_image_path: String = _animation_get_frame(layer, i)
						var im: CompressedTexture2D = load(_get_correct_path(frame_image_path))
						layers_im.append(im)
					
					if layers_im.size() > 0:
						combined_textures[i] = _combine_images(layers_im)
					else:
						combined_textures[i] = ImageTexture.create_from_image(
							Image.create_empty(1, 1, false, Image.FORMAT_RGBA8))
				
				var max_size: Vector2 = _get_bounding_box(combined_textures)
				var empty_image: ImageTexture = ImageTexture.create_from_image(
							Image.create_empty(max_size.x, max_size.y, false, Image.FORMAT_RGBA8))
				for texture in combined_textures:
					_combine_images([empty_image, texture])
				
				var ressource_id: String = "%s_%s" % [character_idx, portrait_name]
				var meta: Dictionary = {
					"PortraitType": portrait_type,
					"Fps": fps,
					"Mirror": portrait_data.get("Mirror", false),
					"OneShot": portrait_data.get("OneShot", false)
				}
				images.load_premade_resource(combined_textures, ressource_id, meta)


func _animation_get_frame(layer_data: Dictionary, frame_idx: int) -> String:
	var image_path: String = ""
	var frames: Dictionary = layer_data.get("Frames", {})
	
	for frame_key in frames.keys():
		var frame_data: Dictionary = frames[frame_key]
		var frame_i: int = int(frame_key)
		var frame_exposure: float = frame_data.get("Exposure", 1.0)-1
		if frame_i <= frame_idx and (frame_i + frame_exposure) >= frame_idx:
			image_path = frame_data.get("ImagePath", "")
			break
	
	return image_path


func _combine_images(textures: Array[Texture2D]) -> ImageTexture:
	var max_size: Vector2 = _get_bounding_box(textures)

	var image := Image.create(int(max_size.x), int(max_size.y), false, Image.FORMAT_RGBA8)
	for tex: Texture2D in textures:
		var im: Image = tex.get_image()
		image.blend_rect(im, Rect2i(Vector2i.ZERO, im.get_size()), (Vector2i(im.get_size()) - image.get_size())/2)

	var texture: ImageTexture = ImageTexture.create_from_image(image)
	return texture


func _get_bounding_box(textures: Array[Texture2D]) -> Vector2:
	var bounding_box: Vector2 = textures[0].get_image().get_size()

	for i in range(1, textures.size()):
		bounding_box = bounding_box.max(textures[i].get_size())

	return bounding_box


func _load_voicelines() -> void:
	for node in get_nodes_from_type("NodeSentence"):
		var node_voicelines = node.get("Voiceline", "")
		for language in node_voicelines:
			var voiceline_path = node_voicelines.get(language, "")
			if voiceline_path.is_empty():
				continue
			var ressource_id: String = "%s-%s" % [node.get("ID"), language]
			voicelines.load_resource(_get_correct_path(voiceline_path), ressource_id)


# Main timeline processing method
func process(from_node_id: String = root_node_id) -> void:
	context.nodes = node_list
	context.timeline = self
	context.settings = settings
	context.next_node_id = from_node_id
	
	if text_box_container:
		text_box_container.mouse_entered.connect(_on_text_box_container_mouse_entered)
		text_box_container.mouse_exited.connect(_on_text_box_container_mouse_exited)
	
	_active = true
	while _active:
		choice_selector._clear()
		text_box.show()
		
		current_node = context.get_node_from_id(context.next_node_id)
		var node_type: String = current_node.get("$type")
		
		# Select logic handler based on node type
		current_logic = _get_logic_for_node_type(node_type)
		
		if current_logic == null:
			# Stop process if node type is unknown
			var process_result = MonologueProcessResult.exit_process("Reached an unknown node")
			break
		
		current_logic.is_processing = true
		var logic_data: Dictionary = {}
		if last_result != null:
			logic_data = last_result.data
		var process_result = await current_logic.enter(context, current_node, logic_data)
		
		compute_process_result.call_deferred(process_result)
		await current_logic.process
		
		current_logic.exit(context, current_node)
		current_logic.is_processing = false
		
		var next_node_type: String = context.get_node_from_id(context.next_node_id).get("$type")
		var next_logic: MonologueProcessLogic = _get_logic_for_node_type(next_node_type)
		if next_logic.clear_text_box:
			text_box.clear()
		
		# Ensure proper update
		process_mode = PROCESS_MODE_DISABLED
		await get_tree().process_frame
		await get_tree().process_frame
		process_mode = PROCESS_MODE_INHERIT
		
		await get_tree().process_frame
	
	timeline_ended.emit()
	return

# Utility method to get appropriate logic handler
func _get_logic_for_node_type(node_type: String) -> MonologueProcessLogic:
	match node_type:
		"NodeAction": return Action
		"NodeAudio": return Audio
		"NodeCharacter": return Character
		"NodeChoice": return Choice
		"NodeCondition": return Condition
		"NodeBackground": return Background
		"NodeBridgeIn", "NodeBridgeOut": return Bridge
		"NodeEndPath": return EndPath
		"NodeEvent": return Event
		"NodeRandom": return Random
		"NodeReroute": return Reroute
		"NodeRoot": return Root
		"NodeSentence": return Sentence
		"NodeSetter": return Setter
		"NodeWait": return Wait
		_: return null


func _process(delta: float) -> void:
	if current_logic and current_logic.is_processing:
		var process_result: MonologueProcessResult = current_logic.update(context, current_node, delta)
		compute_process_result(process_result)
	
	for node in node_list:
		var logic_node = _get_logic_for_node_type(node.get("$type"))
		if logic_node == null:
			continue
		
		var process_result: MonologueProcessResult = logic_node.active_update(context, node)
		compute_process_result(process_result)
	
	# Inputs
	if Input.is_action_just_pressed("ui_continue") or \
	(Input.is_action_just_pressed("ui_mouse_continue") and text_box_container_mouse_hovering):
		_input_next.emit()	


func compute_process_result(result: MonologueProcessResult) -> void:
	if result == null or result.type == MonologueProcessResult.TYPE.NONE:
		return
	
	var next_node_id: Variant = null
	if result.data.get("next_node_id") is String:
		next_node_id = result.data.get("next_node_id")
	else:
		var next_fallback_id = fallback_id_stack.pop_front()
		if next_fallback_id:
			next_node_id = next_fallback_id
	
	if next_node_id != null:
		context.next_node_id = next_node_id
	
	match result.type:
		MonologueProcessResult.TYPE.CONTINUE:
			last_result = result
			current_logic.process.emit()
		MonologueProcessResult.TYPE.INTERRUPT:
			await _input_next
			last_result = result
			current_logic.process.emit()
		MonologueProcessResult.TYPE.EXIT:
			if next_node_id != null:
				current_logic.process.emit()
			else:
				current_logic.exit(context, current_node)
				current_logic.is_processing = false
				_active = false
	
	if next_node_id == null:
		_active = false
		


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


func _get_correct_path(path: String) -> String:
	return base_path.path_join(path).simplify_path()


func create_timer(time_sec: float, process_always: bool = true, process_in_physics: bool = false, ignore_time_scale: bool = false) -> SceneTreeTimer:
	return get_tree().create_timer(time_sec, process_always, process_in_physics, ignore_time_scale)


func _on_text_box_container_mouse_entered() -> void: text_box_container_mouse_hovering = true
func _on_text_box_container_mouse_exited() -> void: text_box_container_mouse_hovering = false
