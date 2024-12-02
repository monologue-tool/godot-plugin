extends Control


var main_scene := preload("res://example/scenes/main/main.tscn")


func _on_btn_play_pressed() -> void:
	get_tree().change_scene_to_packed(main_scene)


func _on_btn_settings_pressed() -> void:
	pass # Replace with function body.


func _on_btn_quit_pressed() -> void:
	get_tree().quit()
