class_name MonologueTextBox extends RichTextLabel


signal display_finished

signal next_requested
signal choice_made(target_id)


var _current_speed: int = 0
var _clock: float = 0

@export var speaker_container: Control
@export var speaker_label: Label


func _ready() -> void:
	bbcode_enabled = true
	process_mode = PROCESS_MODE_DISABLED


func display(new_text: String, character_name: String = "", speed: int = 0) -> void:
	_current_speed = speed
	_clock = 0
	if speed <= 0:
		visible_characters = -1
	else:
		visible_characters = 0
		process_mode = PROCESS_MODE_INHERIT
	
	speaker_container.visible = character_name != ""
	
	text = new_text


func force_display() -> void:
	visible_ratio = 1
	display_finished.emit()
	process_mode = PROCESS_MODE_DISABLED


func _process(delta: float) -> void:
	_clock += delta
	
	var tpc = 1/_current_speed
	if _clock >= tpc:
		visible_characters += 1
		_clock = 0
		
	if visible_ratio >= 1:
		display_finished.emit()
		process_mode = PROCESS_MODE_DISABLED
