@tool
class_name Player extends Node2D

signal health_updated(current_hp, max_hp)
signal action_chosen(enemy, action)

@export var max_hp: int = 60
@export var current_hp: int = 60
@export var armor: int = 0
@export var strength: int = 0 

var status_effects: Dictionary = {}

func _ready() -> void:
	var CharacterData = Characters.GetCharacter(Gamevars.CharacterSelection)
	max_hp = CharacterData['health']
	current_hp = CharacterData['health']

func draw_cards(amount: int):
	pass

func apply_status(effect_name: String, amount: int):
	pass

func modify_strength(amount: int):
	pass

func take_damage(amount: int):
	pass

func die():
	pass

func heal(amount: int):
	pass

func add_armor(amount: int):
	armor += amount

func strip_armor():
	armor = 0
