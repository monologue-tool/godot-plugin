class_name MonologueProcess extends Node
## Core component used to manage [MonologueTimeline] and UI components.
##
## The [MonologueProcess] class is a core component of the Monologue dialogue system, responsible for managing [MonologueTimeline] and their associated UI components.[br]
## It acts as a high-level manager that coordinates the display of dialogue, user interactions, and settings.[br]
## [br]
## Usage:
## [codeblock]
## @onready var process: MonologueProcess = $MonologueProcess
## 
## func _ready() -> void:
##     var timeline: MonologueTimeline = process.preload_timeline(storyline_path)
##     process.start_timeline(timeline)
## [/codeblock]


@export var settings: MonologueProcessSettings

@export_subgroup("layout")
@export var text_box: MonologueTextBox
@export var text_box_container: Control
@export var choice_selector: Node
@export var background: TextureRect
@export var character_displayer: MonologueCharacterDisplayer


signal state_changed(new_state: States)

signal timeline_started

signal timeline_ended


enum States {
	IDLE,
	REVEALING_TEXT,
	AWAITING_CHOICE,
	WAITING
}

var current_timeline: MonologueTimeline = null


func start_timeline(timeline: MonologueTimeline, skip_idx = "") -> void:
	current_timeline = timeline
	
	current_timeline.parent_process = self
	current_timeline.text_box = text_box
	current_timeline.text_box_container = text_box_container
	current_timeline.choice_selector = choice_selector
	current_timeline.background = background
	current_timeline.character_displayer = character_displayer
	current_timeline.settings = settings
	
	current_timeline.timeline_ended.connect(_on_timeline_ended)
	
	character_displayer.set_filter(settings.texture_filter)
	character_displayer.set_interpolation_type(settings.interpolation_type)
	character_displayer.set_ease_type(settings.ease_type)

	add_child(current_timeline)
	
	current_timeline.process()
	timeline_started.emit()


func preload_timeline(path: String) -> MonologueTimeline:
	var timeline := MonologueTimeline.load(path as String)
	if timeline == null:
		printerr("Can't preload timeline")
	
	return timeline


func _on_timeline_ended(next_timeline_path: String) -> void:
	if not next_timeline_path:
		return
	
	var timeline := MonologueTimeline.load_from_timeline(next_timeline_path as String, current_timeline)
	if timeline == null:
		printerr("Can't preload timeline")
		
	start_timeline(timeline)
