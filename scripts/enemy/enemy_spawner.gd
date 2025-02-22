extends Node2D

@export var enemy_scenes: PackedScene = preload("res://scenes/enemy/enemy.tscn")  # Preload enemy scenes
@export var max_enemies_per_round: int = 1

var active_enemies = []

func spawn_boss():
	var boss = null # Needs to be implemented, awaiting art
	add_child(boss)
	active_enemies.append(boss)
	
	return active_enemies

func spawn_enemies():
	var enemy_count = randi_range(1, max_enemies_per_round)
	
	# Spawn regular Enemies
	for i in enemy_count:
		var enemy_scene = enemy_scenes
		var enemy_instance = enemy_scene.instantiate()
		add_child(enemy_instance)
		
		active_enemies.append(enemy_instance)
	
	return active_enemies  # Return list of spawned enemies

func clear_enemies():
	# Filter out already freed instances before trying to free them
	active_enemies = active_enemies.filter(func(enemy): return is_instance_valid(enemy))
	
	# Now safely free remaining valid enemies
	for enemy in active_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	
	# Clear the list once all valid instances are removed
	active_enemies.clear()
