extends Control

@onready var CharacterNameLabel : Label = $CharacterNameLabel
@onready var CharacterDescriptionLabel : Label = $CharacterDescriptionLabel
@onready var CharacterTypeLabel : Label = $CharacterTypeLabel
@onready var CharacterHealthLabel : Label = $CharacterHPLabel

func _ready() -> void:
	var Character = Characters.GetCharacter(1)
	DisplayCharacterInformation(Character[0], Character[1], Character[2], Character[3])

func DisplayCharacterInformation(Name, Type, Description, Health) -> void:
	CharacterNameLabel.set_text(str(Name))
	CharacterDescriptionLabel.set_text(str(Description))
	CharacterTypeLabel.set_text(str(Type))
	CharacterHealthLabel.set_text(str(Health))

func _on_embark_button_pressed() -> void:
	get_tree().change_scene_to_packed(Config.GameScene)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_packed(Config.StartMenuScene)

func _on_character_1_button_pressed() -> void:
	var Character = Characters.GetCharacter(1)
	DisplayCharacterInformation(Character[0], Character[1], Character[2], Character[3])

func _on_character_2_button_pressed() -> void:
	var Character = Characters.GetCharacter(2)
	DisplayCharacterInformation(Character[0], Character[1], Character[2], Character[3])
	
func _on_character_3_button_pressed() -> void:
	var Character = Characters.GetCharacter(3)
	DisplayCharacterInformation(Character[0], Character[1], Character[2], Character[3])
