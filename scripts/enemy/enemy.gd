@tool
class_name Enemy extends Node2D

signal health_updated(current_hp, max_hp)
signal action_chosen(enemy, action)

@onready var HealthBar: ProgressBar = $HealthBar
@onready var HealthBarLabel: Label = $HealthBarLabel

@export var EnemyName: String = "Enemy"
@export var max_hp: float = 30
@export var current_hp: int = 30
@export var armor: int = 0

var status_effects: Dictionary = {}

func apply_status(effect_name: String, amount: int):
	pass

func take_damage(amount: int):
	pass

func add_armor(amount: int):
	armor += amount

func remove_armor(amount: int):
	armor -= amount

func strip_armor():
	armor = 0

func take_turn(player: Node2D):
	pass

func is_dead():
	pass

func die():
	pass
