@tool
class_name MonologueProcessSettings extends Node


@export var language: String = "English"


@export_subgroup("text")

## If [code]true[/code], the options are displayed directly after the last node. If [code]false[/code], you have to interact once before displaying them.
@export var auto_display_option: bool = true
## The speed of text display. [code]0[/code] is infinite, otherwise this is the number of characters per second to show.
@export_range(0, 999, 1.0, "suffix:cps") var text_speed: int = 20

@export_subgroup("text/auto-forward_mode", "afm_")
## If [code]true[/code], auto-forward move is enabled, otherwise [code]false[/code].
@export var afm_enable: bool = false 
## If [code]true[/code], the auto-forward mode will be continued after a click. If [code]false[/code], a click will end auto-forward mode.
@export var afm_after_click: bool = false
## The amount of time to wait for auto-forward mode. Bigger numbers are slower, though the conversion to wall time is complicated, as the speed takes into account line length.
@export var afm_time: int = 15


@export_subgroup("audio")

@export_subgroup("audio/voice")
## @experimental: If [code]true[/code], voice keeps playing until finished, or another voice line replaces it. If [code]false[/code], the voice line ends when the line of dialogue advances.
@export var voice_sustain: bool = false
## If [code]true[/code], auto-forward mode will wait for voice files and self-voicing to finish before advancing. If [code]false[/code], it will not.
@export var wait_voice: bool = false

@export_subgroup("audio/emphasize")
## If [code]true[/code], Monologue will emphasize the audio channels found in [param emphasize_audio_bus] by reducing the volume of other channels.
@export var emphasize_audio: bool = false:
	set(val):
		emphasize_audio = val
		notify_property_list_changed()

# TODO: Keep track of bus names with _on_bus_layout_changed and _on_bus_renamed
var emphasize_audio_bus_value: int = 0

func _ready() -> void:
	AudioServer.bus_layout_changed.connect(_on_bus_layout_changed)
	AudioServer.bus_renamed.connect(_on_bus_renamed)


func _on_bus_layout_changed() -> void: notify_property_list_changed()


func _on_bus_renamed(_bus_index: int, _old_name: StringName, _new_name: StringName) -> void:
	
	notify_property_list_changed()


#region CUSTOM PROPERTIES
func _get_property_list() -> Array[Dictionary]:
	if not emphasize_audio:
		return []
	
	var bus_list := get_all_bus()
	return [{
			name = "emphasize_audio_bus",
			type = TYPE_INT, 
			hint = PROPERTY_HINT_FLAGS,
			hint_string = ",".join(bus_list)
		}]


func _get(property: StringName):
	if property == "emphasize_audio_bus":
		return emphasize_audio_bus_value


func _set(property: StringName, value: Variant) -> bool:
	if property == "emphasize_audio_bus":
		emphasize_audio_bus_value = value
		notify_property_list_changed()
		return true
	
	return false
#endregion


#region EMPHASIZE AUDIO BUS UTILITY
func get_emphasize_audio_bus_idx() -> Array:
	var bin_value = to_binary(emphasize_audio_bus_value) + "0"
	var selected_bus = []
	var bus_idx = 0
	for bit in bin_value.reverse():
		if bit == '1':
			selected_bus.append(bus_idx)
		bus_idx += 1
	
	return selected_bus


func get_emphasize_audio_bus_name() -> Array:
	var bin_value = to_binary(emphasize_audio_bus_value) + "0"
	var selected_bus = []
	var bus_idx = 0
	for bit in bin_value.reverse():
		if bit == '1':
			selected_bus.append(AudioServer.get_bus_name(bus_idx))
		bus_idx += 1
	
	return selected_bus

func get_all_bus() -> Array:
	var bus_list = []
	for bus_idx in AudioServer.bus_count:
		bus_list.append(AudioServer.get_bus_name(bus_idx))
	bus_list.remove_at(0) # We don't care about Master
	
	return bus_list
#endregion


func to_binary(intValue: int) -> String:
	var bin_str: String = ""
	while intValue > 0:
		bin_str = str(intValue & 1) + bin_str
		intValue = intValue >> 1
	return bin_str
