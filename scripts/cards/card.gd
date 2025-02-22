@tool
class_name Card extends Node2D

signal mouse_entered(card: Card)
signal mouse_exited(card: Card)

@export var CardName: String = "Card Name"
@export var CardDescription: String = "Card Description"
@export var CardCost : int = 1
@export var CardType: String = "Type"
@export var CardImage = Sprite2D
@export var CardImagePath: String = "res://assets/cards/lizard/block.png"

# Onready vars
@onready var CardNameLabel: Label = $CardName/CardNameLabel
@onready var CardDescriptionLabel: Label = $CardDescription/CardDescriptionLabel
@onready var CardCostLabel: Label = $CostDisplay/CostLabel
@onready var CardTypeLabel: Label = $CardType/Label
@onready var BaseCardSprite: Sprite2D = $BaseCardSprite
@onready var CardImageSprite: Sprite2D = $CardImage/CardImageSprite

var is_hovered: bool = false  # Track hover state

## To store the effects in
var Effects: Array = []

## Function to highlight the card when hovering
func highlight():
	if is_hovered:
		return  # Prevent multiple triggers
	is_hovered = true
	BaseCardSprite.set_modulate(Color(1, 0.5, 0.1, 1))
	z_index = 10  # Move the card visually to the front
	set_scale(Vector2(1.2, 1.2))  # Scale up the card slightly


## Function to inhighlight the card when no longer hovering
func unhighlight():
	is_hovered = false
	BaseCardSprite.set_modulate(Color(1, 1, 1, 1))
	z_index = 0  # Reset Z-index
	set_scale(Vector2(1, 1))  # Reset scalehovered

## Function to update the graphics on the card
func _update_graphics():
	if CardNameLabel and CardNameLabel.get_text() != str(CardName):
		CardNameLabel.set_text(str(CardName))
	if CardDescriptionLabel and CardDescriptionLabel.get_text()  != str(CardDescription):
		CardDescriptionLabel.set_text(str(CardDescription))
	if CardCostLabel and CardCostLabel.get_text() != str(CardCost):
		CardCostLabel.set_text(str(CardCost))
	if CardTypeLabel and CardTypeLabel.get_text() != str(CardType):
		CardTypeLabel.set_text(str(CardType))
		
	# Load and set the card image if it exists
	if CardImageSprite and CardImagePath:
		var texture = load(CardImagePath)
		if texture:
			CardImageSprite.texture = texture

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
func set_card_values(name: String, cost: int, description: String, type: String, image_path: String, effects: Array = []):
	CardName = name
	CardCost = cost
	CardDescription = description
	if type == "enchantment":
		CardType = "enchant"
	else:
		CardType = type
	CardImagePath = image_path
	Effects = effects
	_update_graphics()

## Function handling when the mouse has entered the Area2D of the card
func _on_area_2d_mouse_entered() -> void:
	mouse_entered.emit(self)

## Function handling when the mouse has left the Area2D of the card
func _on_area_2d_mouse_exited() -> void:
	mouse_exited.emit(self)

## Debug function temp
func debug_effects():
	#print("[DEBUG] Card: " + CardName + " | Effects: " + str(Effects))
	pass

## Process Function
func _process(delta: float) -> void:
	_update_graphics()
