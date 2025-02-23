extends Node2D

@export var enemy_scenes: PackedScene = preload("res://scenes/enemy/enemy.tscn")  # Preload enemy scenes
@export var max_enemies_per_round: int = 1

var active_enemies = []

func _ready() -> void:
	pass

## **Spawns enemies for a new round**
func spawn_enemies():
	if !Gamevars.SavedEnemies.is_empty():
		restore_saved_enemies()
		return active_enemies

	var enemy_count = randi_range(1, max_enemies_per_round)

	for i in enemy_count:
		var enemy_instance = enemy_scenes.instantiate()
		enemy_instance.scale_enemy_stats(Gamevars.CurrentRound)
		add_child(enemy_instance)
		active_enemies.append(enemy_instance)

		# Connect signals for UI updates
		if enemy_instance.has_signal("health_updated"):
			enemy_instance.health_updated.connect(get_parent()._on_enemy_health_updated)
		if enemy_instance.has_signal("armor_updated"):
			enemy_instance.armor_updated.connect(get_parent()._on_enemy_armor_updated)

		# Connect enemy actions to game logic
		enemy_instance.enemy_action.connect(get_parent()._on_enemy_action)

		# Ensure the enemy takes a turn when spawned
		print("[DEBUG] New enemy spawned. Name:", enemy_instance.EnemyName)
		await get_tree().process_frame  # Ensure proper initialization
		enemy_instance.take_turn(get_parent().Player)  # Force turn execution

	return active_enemies


func clear_enemies():
	print("[INFO] Clearing enemies. Current count: ", active_enemies.size())

	# Ensure all instances are properly freed
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			print("[DEBUG] Removing enemy: ", enemy.EnemyName)
			enemy.queue_free()
	
	await get_tree().process_frame  # Wait before modifying active_enemies

	active_enemies.clear()
	print("[INFO] Enemies cleared. Remaining count: ", active_enemies.size())

func restore_saved_enemies():
	print("[INFO] Restoring saved enemies...")
	active_enemies.clear()  # Clear previous enemies before restoring

	for enemy_data in Gamevars.load_enemy_state():
		var enemy_instance = enemy_scenes.instantiate()

		# Add restored enemies to EnemySpawner itself
		add_child(enemy_instance)

		# Restore the saved enemy state
		enemy_instance.restore_state(enemy_data)

		# Force UI updates and ensure it's in the correct parent node
		await get_tree().process_frame  
		enemy_instance.emit_signal("health_updated", enemy_instance.current_hp, enemy_instance.max_hp)
		enemy_instance.emit_signal("armor_updated", enemy_instance.armor)

		# Add to active enemies list
		active_enemies.append(enemy_instance)

		print("[DEBUG] Enemy restored and added to EnemySpawner:", enemy_instance)

	print("[INFO] Enemy restoration complete.")
