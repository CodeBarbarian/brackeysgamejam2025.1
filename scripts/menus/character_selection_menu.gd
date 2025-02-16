extends Control

@onready var CharacterNameLabel : Label = $CharacterNameLabel
@onready var CharacterDescriptionLabel : Label = $CharacterDescriptionLabel
@onready var CharacterHealthLabel : Label = $CharacterHPLabel

func DisplayCharacterInformation(Name, Description, Health) -> void:
	CharacterNameLabel.set_text(str(Name))
	CharacterDescriptionLabel.set_text(str(Description))
	CharacterHealthLabel.set_text(str(Health))

func _on_embark_button_pressed() -> void:
	get_tree().change_scene_to_packed(Config.GameScene)

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_packed(Config.StartMenuScene)

func _on_character_1_button_pressed() -> void:
	Gamevars.CharacterSelection = 1
	DisplayCharacterInformation(Characters.Character1_Name, Characters.Character1_Description, Characters.Character1_Health)

func _on_character_2_button_pressed() -> void:
	Gamevars.CharacterSelection = 2
	DisplayCharacterInformation(Characters.Character2_Name, Characters.Character2_Description, Characters.Character2_Health)
	
func _on_character_3_button_pressed() -> void:
	Gamevars.CharacterSelection = 3
	DisplayCharacterInformation(Characters.Character3_Name, Characters.Character3_Description, Characters.Character3_Health)
