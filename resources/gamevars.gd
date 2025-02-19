extends Node

# These are just defaults at this point
@onready var BaseEnergy = 3
@onready var CharacterSelection = null

# General Vars for the player deck
@onready var DeckRadius: int = 1000
@onready var CardAngle: float = -90.0
@onready var AngleLimit: float = 25
@onready var MaxCardSpreadAngle: float = 5
@onready var MaxPlayingCards: int = 10
