extends Control


func _on_lets_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(Config.GameScene)


func _on_change_character_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menus/character_selection_menu.tscn")
