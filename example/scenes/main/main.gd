extends Control


@export_file("*.json") var storyline_path

@onready var process: MonologueProcess = $MonologueProcess


func _ready() -> void:
	var timeline: MonologueTimeline = process.preload_timeline(storyline_path)
	process.start_timeline(timeline)
