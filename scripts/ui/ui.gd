extends Control

@onready var RoundLabel: Label = $UIPanel/RoundControl/CurrentRoundLabel
@onready var TurnLabel: Label = $UIPanel/RoundControl/CurrentTurnLabel
@onready var HealthLabel: Label = $UIPanel/HealthEnergy/Health
@onready var HealthBar: ProgressBar = $StatusBar/HealthValueBar/HealthValue
@onready var EnergyLabel: Label = $UIPanel/HealthEnergy/Energy
@onready var EnergyBar: ProgressBar = $StatusBar/EnergyValueBar/EnergyValue
@onready var CharacterLabel: Label = $UIPanel/Debug/CharacterLabel
@onready var ArmorLabel: Label = $UIPanel/Debug/ArmorLabel
@onready var MessageLabel: Label = $MessageLabel

var message_queue: Array = []  # Store messages to display

func _ready() -> void:
	MessageLabel.set_text("")

func update_ui_round(round: int):
	RoundLabel.set_text(str(round))

func update_ui_turn(turn: int):
	TurnLabel.set_text(str(turn))

func update_ui_health(current: int, max: int): 
	HealthLabel.set_text(str(current) + "/" + str(max))
	
	HealthBar.set_value(current)
	HealthBar.max_value = max

func update_ui_energy(current: int, max: int):
	EnergyLabel.set_text(str(current) + "/" + str(max))
	
	EnergyBar.set_value(current)
	EnergyBar.max_value = max

func update_ui_character(character: String) -> void:
	CharacterLabel.set_text(str(character))

func update_ui_armor(armor: int) -> void:
	ArmorLabel.set_text(str(armor))

func show_message(text: String):
	message_queue.append(text)
	if message_queue.size() == 1:
		_display_next_message()

func _display_next_message():
	if message_queue.is_empty():
		MessageLabel.set_text("")  # Clear label
		return

	MessageLabel.set_text(message_queue[0])

	await get_tree().create_timer(1.5).timeout  

	message_queue.pop_front()

	_display_next_message()
