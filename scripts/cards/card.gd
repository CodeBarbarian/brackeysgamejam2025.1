@tool
class_name Card extends Node2D

signal mouse_entered(card: Card)
signal mouse_exited(card: Card)

@export var CardName: String = "Card Name"
@export var CardDescription: String = "Card Description"
@export var CardCost : int = 1
@export var CardType: String = "Type"
@export var CardImage = Sprite2D

# Onready vars
@onready var CardNameLabel: Label = $CardName/CardNameLabel
@onready var CardDescriptionLabel: Label = $CardDescription/CardDescriptionLabel
@onready var CardCostLabel: Label = $CostDisplay/CostLabel
@onready var CardTypeLabel: Label = $CardType/Label
@onready var BaseCardSprite: Sprite2D = $BaseCardSprite

## Function to highlight the card when hovering
func highlight():
	BaseCardSprite.set_modulate(Color(1, 0.5, 0.1, 1))

## Function to inhighlight the card when no longer hovering
func unhighlight():
	BaseCardSprite.set_modulate(Color(1,1,1,1))

## Function to update the graphics on the card
func _update_graphics():
	if CardNameLabel.get_text() != str(CardName):
		CardNameLabel.set_text(str(CardName))
	if CardDescriptionLabel.get_text()  != str(CardDescription):
		CardDescriptionLabel.set_text(str(CardDescription))
	if CardCostLabel.get_text() != str(CardCost):
		CardCostLabel.set_text(str(CardCost))
	if CardTypeLabel.get_text() != str(CardType):
		CardTypeLabel.set_text(str(CardType))

## Helper function to set thee card name
func set_card_name(name: String) -> void:
	CardName = name

## Helper function to set the card cost
func set_card_cost(cost: int) -> void:
	CardCost = cost

## Helper function to set the card description
func set_card_description(description: String) -> void:
	CardDescription = description

## Helper function to set the card type
func set_card_type(type: String) -> void:
	CardType = type

## Helper function to set all the card values at the same time
func set_card_values(name: String, cost: int, description: String, type: String) -> void:
	set_card_name(name)
	set_card_cost(cost)
	set_card_description(description)
	set_card_type(type)

	_update_graphics()

## Function handling when the mouse has entered the Area2D of the card
func _on_area_2d_mouse_entered() -> void:
	mouse_entered.emit(self)

## Function handling when the mouse has left the Area2D of the card
func _on_area_2d_mouse_exited() -> void:
	mouse_exited.emit(self)

## Onready function
func _ready():
	set_card_values(CardName, CardCost, CardDescription, CardType)

## Process Function
func _process(delta: float) -> void:
	_update_graphics()
