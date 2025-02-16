extends Control

@onready var FullScreenButton: CheckButton = %FullScreenButton
@onready var FullScreen = false

# Change the Window Mode Fullscreen
func WindowMode_FullScreen():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

# Change the Window Mode Windowed
func WindowMode_Windowed():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _ready():
	if DisplayServer.window_get_mode() == 0:
		FullScreenButton.set_pressed_no_signal(false)
	else:
		FullScreenButton.set_pressed_no_signal(true)

func _on_start_menu_button_pressed() -> void:
	get_tree().change_scene_to_packed(Config.StartMenuScene)

func _on_full_screen_button_pressed() -> void:
	if FullScreen == false:
		FullScreen = true
		FullScreenButton.set_pressed_no_signal(true)
		WindowMode_FullScreen()
	else:
		FullScreen = false
		FullScreenButton.set_pressed_no_signal(false)
		WindowMode_Windowed()
