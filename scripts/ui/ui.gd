extends Control

@onready var RoundLabel: Label = $UIPanel/RoundControl/CurrentRoundLabel
@onready var TurnLabel: Label = $UIPanel/RoundControl/CurrentTurnLabel
@onready var HealthLabel: Label = $UIPanel/HealthEnergy/Health
@onready var EnergyLabel: Label = $UIPanel/HealthEnergy/Energy
@onready var CharacterLabel: Label = $UIPanel/Debug/CharacterLabel
@onready var ArmorLabel: Label = $UIPanel/Debug/ArmorLabel

func update_ui_round(round: int):
	RoundLabel.set_text(str(round))

func update_ui_turn(turn: int):
	TurnLabel.set_text(str(turn))

func update_ui_health(current: int, max: int): 
	HealthLabel.set_text(str(current) + "/" + str(max))

func update_ui_energy(current: int, max: int):
	EnergyLabel.set_text(str(current) + "/" + str(max))

func update_ui_character(character: String) -> void:
	CharacterLabel.set_text(str(character))

func update_ui_armor(armor: int) -> void:
	ArmorLabel.set_text(str(armor))
