@tool
class_name Enemy extends Node2D

signal health_updated(current_hp, max_hp)
signal armor_updated(current)
signal action_chosen(enemy, action)
signal enemy_action(message)
signal enemy_died(enemy)

@onready var HealthBar: ProgressBar = $EnemyStatus/HealthBar
@onready var HealthBarLabel: Label = $EnemyStatus/HealthBarLabel
@onready var EnemySprite: Sprite2D = $EnemySprite

@export var EnemyName: String = "Enemy"
@export var max_hp: int = 30
@export var current_hp: int = 30
@export var armor: int = 0
@export var shield: int = 0
@export var gold_drop: int = 10  # Used for Pickpocketer relic

var status_effects: Dictionary = {}  # Stores active effects like {"bleed": 2, "cripple": 1}

func _ready() -> void:
	# Assign a sprite only if one is not already set
	if not EnemySprite.texture or EnemySprite.texture.resource_path == "":
		print("[WARNING] Enemy spawned without a texture! Assigning random sprite.")
		assign_random_sprite()
	else:
		print("[DEBUG] Enemy spawned with preloaded texture: ", EnemySprite.texture.resource_path)

	# nsure UI updates when the enemy spawns
	await get_tree().process_frame  

	emit_signal("health_updated", current_hp, max_hp)
	emit_signal("armor_updated", armor)
	print("[DEBUG] Enemy initialized and signals emitted: ", EnemyName)




## **Assigns a random sprite to newly spawned enemies**
func assign_random_sprite():
	var Enemies: Array = [
		"res://assets/enemies/angry_ghost.png",
		"res://assets/enemies/masked_big.png",
		"res://assets/enemies/masked_small.png",
		"res://assets/enemies/slele.png",
		"res://assets/enemies/slime.png",
		"res://assets/enemies/water_bear.png"
	]
	var selection = Enemies[randi() % Enemies.size()]
	EnemySprite.texture = load(selection)

func restore_state(enemy_data: Dictionary):
	EnemyName = enemy_data["name"]
	max_hp = enemy_data["max_hp"]
	current_hp = min(enemy_data["current_hp"], max_hp)  # Prevents overhealing
	armor = enemy_data["armor"]
	shield = enemy_data["shield"]
	gold_drop = enemy_data["gold_drop"]
	status_effects = enemy_data["status_effects"].duplicate(true)  # Deep copy status effects

	# Load and assign sprite
	if enemy_data.has("sprite_path") and enemy_data["sprite_path"] != "":
		var sprite_texture = load(enemy_data["sprite_path"])
		if sprite_texture:
			EnemySprite.texture = sprite_texture
			print("[DEBUG] Sprite loaded successfully: ", enemy_data["sprite_path"])
			# Force redraw
			EnemySprite.queue_redraw()
		else:
			print("[WARNING] Failed to load sprite: ", enemy_data["sprite_path"])
	else:
		print("[WARNING] No sprite path found, assigning random sprite.")
		assign_random_sprite()

	# Ensure the enemy is in the scene before updating UI
	await get_tree().process_frame  

	if is_inside_tree():
		emit_signal("health_updated", current_hp, max_hp)
		emit_signal("armor_updated", armor)
		# Force the node to refresh and re-render
		queue_redraw()
		print("[DEBUG] Enemy restored and ready: " + EnemyName + " | HP: " + str(current_hp) + "/" + str(max_hp))
	
	EnemySprite.visible = true
	EnemySprite.modulate = Color(1, 1, 1, 1)  # Ensure it's fully visible
	EnemySprite.queue_redraw()  # Force the engine to refresh it


## **Applies a status effect to the enemy**
func apply_status(effect_name: String, amount: int):
	if status_effects.has(effect_name):
		status_effects[effect_name] += amount
	else:
		status_effects[effect_name] = amount

	print("[INFO] " + EnemyName + " received status effect: " + effect_name + " (" + str(amount) + ")")

	if effect_name == "stun":
		print("[INFO] " + EnemyName + " is stunned and skips their next turn.")

## **Handles damage, factoring in armor, shield, and special effects**
func take_damage(amount: int, attacker = null):
	if shield > 0:
		shield = 0
		print("[INFO] " + EnemyName + "'s shield absorbed the attack.")
		return

	var effective_damage = max(amount - armor, 0)
	armor = max(armor - amount, 0)
	emit_signal("armor_updated", armor)

	current_hp = max(current_hp - effective_damage, 0)
	emit_signal("health_updated", current_hp, max_hp)

	if is_dead():
		die(attacker)

## **Removes all armor from the enemy**
func remove_armor():
	armor = 0
	emit_signal("armor_updated", armor)

## **Adds armor to the enemy**
func add_armor(amount: int):
	armor += amount
	emit_signal("armor_updated", armor)
	print("[INFO] " + EnemyName + " gained " + str(amount) + " armor.")

## **Applies a shield (absorbs next hit)**
func apply_shield(amount: int):
	shield = amount
	print("[INFO] " + EnemyName + " received a shield.")

## **Heals the enemy up to its max HP**
func heal(amount: int):
	current_hp = min(current_hp + amount, max_hp)
	emit_signal("health_updated", current_hp, max_hp)

## **Checks if the enemy is dead**
func is_dead() -> bool:
	return current_hp <= 0

## **Handles enemy death**
func die(attacker = null):
	print("[DEAD] " + EnemyName + " has been defeated.")

	# Trigger player relics (Lethal Toxins, Pickpocketer, etc.)
	if attacker and attacker.has_method("apply_relics"):
		attacker.apply_relics("on_kill", self)

	# Ensure enemy is removed from active_enemies properly
	if get_parent() and self in get_parent().active_enemies:
		get_parent().active_enemies.erase(self)

	emit_signal("enemy_died", self)  # Ensure enemy death signal is emitted

	# Wait until next frame before freeing the enemy to avoid issues
	await get_tree().process_frame
	queue_free()



## **Instantly kills the enemy**
func apply_insta_kill():
	print("[INFO] " + EnemyName + " was instantly killed.")
	die()

## **Determines if the enemy intends to attack this turn**
func intends_to_attack() -> bool:
	return randi() % 2 == 0  # Placeholder, replace with actual AI logic

func take_turn(player):
	if is_dead():
		print("[ERROR] Attempting to take turn while dead:", EnemyName)
		return

	if status_effects.has("stun") and status_effects["stun"] > 0:
		status_effects["stun"] -= 1
		print("[INFO] " + EnemyName + " is stunned and skips turn.")
		emit_signal("enemy_action", EnemyName + " is stunned! Skipping turn.")
		return

	print("[DEBUG] " + EnemyName + " is taking its turn.")

	# Choose action
	var actions = ["attack", "defend"]
	var chosen_action = actions[randi() % actions.size()]

	match chosen_action:
		"attack":
			var base_damage = randi_range(4, 8)
			var attack_bonus = get_meta("attack_bonus") if has_meta("attack_bonus") else 0
			var final_damage = base_damage + attack_bonus

			print("[DEBUG] " + EnemyName + " is attacking for ", final_damage)
			player.take_damage(final_damage, self)
			emit_signal("enemy_action", EnemyName + " attacks for " + str(final_damage) + " damage!")

		"defend":
			add_armor(3)
			print("[DEBUG] " + EnemyName + " is defending!")
			emit_signal("enemy_action", EnemyName + " gains 3 armor!")

	emit_signal("action_chosen", self, chosen_action)

## **Returns enemy's health as a percentage (0-100)**
func get_health_percentage() -> float:
	if max_hp == 0:
		return 0.0  # Avoid division by zero
	return (float(current_hp) / float(max_hp)) * 100.0

func scale_enemy_stats(round: int):
	# Increase HP, Attack, and Armor as rounds progress
	var hp_bonus = round * 3  # Increase HP by 3 per round
	var attack_bonus = round * 1  # Increase attack power per round
	var armor_bonus = round / 3  # Every 3 rounds, gain 1 armor

	# Apply scaling
	max_hp += hp_bonus
	current_hp = max_hp  # Fully heal enemies
	armor += armor_bonus

	# Store attack bonus (used later in take_turn())
	set_meta("attack_bonus", attack_bonus)

	emit_signal("health_updated", current_hp, max_hp)
	emit_signal("armor_updated", armor)

	print("[INFO] Scaled Enemy Stats: " + EnemyName + " | HP: " + str(max_hp) + " | Armor: " + str(armor) + " | Attack Bonus: " + str(attack_bonus))
