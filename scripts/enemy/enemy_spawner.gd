extends Node2D

@export var enemy_scenes: PackedScene = preload("res://scenes/enemy/enemy.tscn")  # Preload enemy scenes
@export var max_enemies_per_round: int = 2

var active_enemies = []

func spawn_enemies():
	var enemy_count = randi_range(1, max_enemies_per_round)
	for i in enemy_count:
		var enemy_scene = enemy_scenes
		var enemy_instance = enemy_scene.instantiate()
		add_child(enemy_instance)
		active_enemies.append(enemy_instance)
	
	return active_enemies  # Return list of spawned enemies

func clear_enemies():
	for enemy in active_enemies:
		enemy.queue_free()
	active_enemies.clear()
