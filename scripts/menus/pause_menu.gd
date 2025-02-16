extends Control

func _ready() -> void:
	get_tree().paused = true

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("action_pause_menu"):
		get_tree().paused = false
		queue_free()

func _on_resume_button_pressed() -> void:
		get_tree().paused = false
		queue_free()

func _on_start_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(Config.StartMenuScene)

func _on_exit_button_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
