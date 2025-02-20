extends Control

@onready var CharacterNameLabel : Label = $CharacterNameLabel
@onready var CharacterDescriptionLabel : Label = $CharacterDescriptionLabel
@onready var CharacterTypeLabel : Label = $CharacterTypeLabel
@onready var CharacterHealthLabel : Label = $CharacterHPLabel

func _ready() -> void:
	var Character = Characters.GetCharacter(1)
	DisplayCharacterInformation(Character['name'], Character['type'], Character['description'], Character['health'], Character['base_energy'])

func DisplayCharacterInformation(Name, Type, Description, Health, BaseEnergy) -> void:
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
	DisplayCharacterInformation(Character['name'], Character['type'], Character['description'], Character['health'], Character['base_energy'])
	Gamevars.CharacterSelection = 1

func _on_character_2_button_pressed() -> void:
	var Character = Characters.GetCharacter(2)
	DisplayCharacterInformation(Character['name'], Character['type'], Character['description'], Character['health'], Character['base_energy'])
	Gamevars.CharacterSelection = 2
	
func _on_character_3_button_pressed() -> void:
	var Character = Characters.GetCharacter(3)
	DisplayCharacterInformation(Character['name'], Character['type'], Character['description'], Character['health'], Character['base_energy'])
	Gamevars.CharacterSelection = 3
