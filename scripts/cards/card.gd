class_name Card extends Node2D

@export var CardName: String = "Card Name"
@export var CardDescription: String = "Card Description"
@export var CardCost : int = 1
@export var CardImage = Node2D

@onready var CardNameLabel: Label = $CardName/CardNameLabel
@onready var CardDescriptionLabel: Label = $CardDescription/CardDescriptionLabel
@onready var CostLabel: Label = $CostDisplay/CostLabel


func _ready():
	CardNameLabel.set_text(str(CardName))
	CardDescriptionLabel.set_text(str(CardDescription))
	CostLabel.set_text(str(CardCost))
