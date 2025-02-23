@tool
class_name Enemy extends Node2D

signal health_updated(current_hp, max_hp)
signal armor_updated(current)
signal action_chosen(enemy, action)
signal enemy_action(message)

@onready var HealthBar: ProgressBar = $EnemyStatus/HealthBar
@onready var HealthBarLabel: Label = $EnemyStatus/HealthBarLabel

@export var EnemyName: String = "Enemy"
@export var max_hp: int = 30
@export var current_hp: int = 30
@export var armor: int = 0
@onready var EnemySprite: Sprite2D = $EnemySprite

var status_effects: Dictionary = {}

func _ready() -> void:
	var Enemies: Array = [
		"res://assets/enemies/angry_ghost.png",
		"res://assets/enemies/masked_big.png",
		"res://assets/enemies/masked_small.png",
		"res://assets/enemies/slele.png",
		"res://assets/enemies/slime.png",
		"res://assets/enemies/water_bears.png"
	]
	
	# Pick a random background
	var selection = Enemies[randi() % Enemies.size()]
	
	# Load and set the texture
	var texture = load(selection)
	if texture:
		EnemySprite.texture = texture
		
	emit_signal("health_updated", current_hp, max_hp)

# Apply a status effect like "stun" or "weaken"
func apply_status(effect_name: String, amount: int):
	if status_effects.has(effect_name):
		status_effects[effect_name] += amount
	else:
		status_effects[effect_name] = amount

	print("[INFO] " + EnemyName + " received status effect: " + effect_name + " (" + str(amount) + ")")

	# If stunned, enemy will skip their turn
	if effect_name == "stun":
		print("[INFO] " + EnemyName + " is stunned and skips their next turn.")

# Enemy takes damage
func take_damage(amount: int):
	var effective_damage = max(amount - armor, 0)  # Reduce damage by armor amount
	armor = max(armor - amount, 0)  # Reduce armor if hit
	emit_signal("armor_updated", armor)
	current_hp = max(current_hp - effective_damage, 0)  # Reduce HP but prevent negative values
	_update_graphics()
	emit_signal("health_updated", current_hp, max_hp)

	print("[INFO] " + EnemyName + " took " + str(effective_damage) + " damage. Current HP: " + str(current_hp))

	# Check if enemy is dead
	if is_dead():
		die()

func _update_graphics():
	emit_signal("health_updated", current_hp, max_hp)
	#HealthBar.set_value(current_hp)
	#HealthBarLabel.set_text(str(current_hp)+"/"+str(max_hp))
	
# Add armor (defensive action)
func add_armor(amount: int):
	armor += amount
	emit_signal("armor_updated", armor)
	print("[INFO] " + EnemyName + " gained " + str(amount) + " armor. Current armor: " + str(armor))

# Remove armor (effect from some cards)
func remove_armor():
	armor = 0
	emit_signal("armor_updated", armor)
	print("[INFO] " + EnemyName + " lost all armor.")

# Strip armor (specific effect)
func strip_armor():
	remove_armor()

# Check if the enemy is dead
func is_dead() -> bool:
	return current_hp <= 0

# Enemy dies
func die():
	print("[DEAD] " + EnemyName + " has been defeated!")
	if get_parent():
		get_parent().active_enemies.erase(self) 

	queue_free()  # Remove enemy from scene

# Enemy AI turn logic
func take_turn(player):
	if is_dead():
		return

	# If the enemy is stunned, they skip their turn
	if status_effects.has("stun") and status_effects["stun"] > 0:
		print("[INFO] " + EnemyName + " is stunned and skips their turn.")
		status_effects["stun"] -= 1  # Reduce stun duration
		emit_signal("enemy_action", EnemyName + " is stunned! Skipping turn.")
		return

	# Choose an action randomly
	var actions = ["attack", "defend"]
	var chosen_action = actions[randi() % actions.size()]

	match chosen_action:
		"attack":
			var damage = randi_range(4, 8)
			print("[INFO] " + EnemyName + " attacks for " + str(damage) + " damage.")
			player.take_damage(damage)
			emit_signal("enemy_action", EnemyName + " attacks for " + str(damage) + " damage!")
		"defend":
			add_armor(3)
			emit_signal("enemy_action", EnemyName + " gains 3 armor!")
			emit_signal("armor_updated", armor)

	emit_signal("action_chosen", self, chosen_action)
