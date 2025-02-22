extends CanvasLayer

@onready var BackgroundSprite: Sprite2D = $BackgroundSprite

func _update_background():
	var Backgrounds: Array = [
		"res://assets/world/arena/arena1.png",
		"res://assets/world/arena/arena2.png",
		"res://assets/world/arena/arena3.png",
		"res://assets/world/arena/arena4.png",
		"res://assets/world/arena/arena5.png",
		"res://assets/world/arena/arena6.png",
		"res://assets/world/arena/arena7.png"
	]
	
	# Pick a random background
	var selection = Backgrounds[randi() % Backgrounds.size()]
	
	# Load and set the texture
	var texture = load(selection)
	if texture:
		BackgroundSprite.texture = texture
