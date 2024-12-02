@tool
class_name MonologueProcess extends Node

## Base class used to interpret a Monologue file


@export var settings: MonologueProcessSettings

@export_subgroup("layout")
@export var text_box: MonologueTextBox
@export var choice_selector: Node
@export var background: TextureRect
#@export var character_displayer: Node2D


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
	
	current_timeline.text_box = text_box
	current_timeline.choice_selector = choice_selector
	current_timeline.settings = settings
	#current_timeline.background = background

	add_child(current_timeline)
	
	current_timeline.process()
	timeline_started.emit()


func preload_timeline(path: String) -> MonologueTimeline:
	var timeline := MonologueTimeline.load(path as String)
	if timeline == null:
		printerr("Can't preload timeline")
	
	return timeline
