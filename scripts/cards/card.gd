@tool
class_name Card extends Node2D

signal mouse_entered(card: Card)
signal mouse_exited(card: Card)

@export var CardName: String = "Card Name"
@export var CardDescription: String = "Card Description"
@export var CardCost : int = 1
@export var CardImage = Sprite2D

@onready var CardNameLabel: Label = $CardName/CardNameLabel
@onready var CardDescriptionLabel: Label = $CardDescription/CardDescriptionLabel
@onready var CardCostLabel: Label = $CostDisplay/CostLabel
@onready var BaseCardSprite: Sprite2D = $BaseCardSprite
#BaseCardSprite.set_modulate(Color(1, 0.5, 0.1, 1))
func highlight():
	BaseCardSprite.set_modulate(Color(1, 0.5, 0.1, 1))
#BaseCardSprite.set_modulate(Color(1, 1, 1, 1))
func unhighlight():
	BaseCardSprite.set_modulate(Color(1,1,1,1))

func _update_graphics():
	if CardNameLabel.get_text() != str(CardName):
		CardNameLabel.set_text(str(CardName))
	if CardDescriptionLabel.get_text()  != str(CardDescription):
		CardDescriptionLabel.set_text(str(CardDescription))
	if CardCostLabel.get_text() != str(CardCost):
		CardCostLabel.set_text(str(CardCost))

func set_card_name(name: String) -> void:
	CardName = name
	
func set_card_cost(cost: int) -> void:
	CardCost = cost
	
func set_card_description(description: String) -> void:
	CardDescription = description

func set_card_values(name: String, cost: int, description: String) -> void:
	set_card_name(name)
	set_card_cost(cost)
	set_card_description(description)

	_update_graphics()

func _ready():
	set_card_values(CardName, CardCost, CardDescription)

func _process(delta: float) -> void:
	_update_graphics()


func _on_area_2d_mouse_entered() -> void:
	mouse_entered.emit(self)


func _on_area_2d_mouse_exited() -> void:
	mouse_exited.emit(self)
