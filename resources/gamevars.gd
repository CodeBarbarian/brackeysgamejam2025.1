extends Node

@onready var BaseEnergy = 3
@onready var CharacterSelection = 1

# General Vars for player deck
@onready var DeckRadius: int = 1000
@onready var CardAngle: float = -90.0
@onready var AngleLimit: float = 25
@onready var MaxCardSpreadAngle: float = 5
@onready var MaxPlayingCards: int = 10

@onready var CurrentRound = 0
@onready var SavedEnemies: Array = []
@onready var GameScenePath: String = "res://scenes/game.tscn"

## **Saves the enemy state before the player dies**
func save_enemy_state(enemies: Array):
	SavedEnemies.clear()
	for enemy in enemies:
		if enemy and enemy.is_inside_tree():
			var sprite_path = enemy.EnemySprite.texture.resource_path if enemy.EnemySprite.texture else ""
			SavedEnemies.append({
				"name": enemy.EnemyName,
				"max_hp": enemy.max_hp,
				"current_hp": max(enemy.current_hp, 1),  # Ensure no negative HP
				"armor": enemy.armor,
				"shield": enemy.shield,
				"gold_drop": enemy.gold_drop,
				"status_effects": enemy.status_effects.duplicate(true),  # Deep copy effects
				"sprite_path": sprite_path
			})
			print("[DEBUG] Saved enemy sprite path: ", sprite_path)
	print("[INFO] Enemy state saved: ", SavedEnemies)


## **Loads the enemy state after the player respawns**
func load_enemy_state() -> Array:
	return SavedEnemies.duplicate(true)  # Return a copy to prevent modification issues
