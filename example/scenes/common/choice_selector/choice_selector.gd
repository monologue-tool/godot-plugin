class_name ChoiceSelector
extends VBoxContainer

signal choice_made(option)

var theme_ref := preload("res://example/theme/theme.tres")
var last_option: Dictionary


func display_option(option: Dictionary) -> void:
	show()
	var button := Button.new()
	button.text = option.get("Option")
	button.theme = theme_ref
	button.connect("pressed", _on_button_pressed.bind(option))
	add_child(button)
	(get_child(0) as Button).grab_focus()


func _clear() -> void:
	hide()
	for child in get_children():
		remove_child(child)
		child.queue_free()


func _on_button_pressed(option: Dictionary) -> void:
	last_option = option
	choice_made.emit(option)
	_clear()
