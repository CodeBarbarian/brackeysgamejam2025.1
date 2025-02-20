extends Node2D

func apply_effects(card, player, target, enemies):
	for effect in card.effects:
		match effect["type"]:
			"damage":
				apply_damage(effect, target, enemies)
			"status_effect":
				apply_status_effect(effect, target)
			"insta_kill":
				apply_insta_kill(effect, target)
			"strip_armor":
				strip_armor(effect, target)
			"update_max_hp":
				update_max_hp(effect, player, target)
			"armor":
				apply_armor(effect, player)
			"draw":
				draw_cards(effect, player)
			_:
				print("Unknown effect type:", effect["type"])

# ---------------------- EFFECT FUNCTIONS ----------------------

func apply_damage(effect, target, enemies = null):
	if effect["target"] == "enemy":
		target.take_damage(effect["amount"])
	elif effect["target"] == "all_enemies":
		for enemy in enemies:
			enemy.take_damage(effect["amount"])

func apply_status_effect(effect, target):
	target.apply_status(effect["effect"], effect["amount"])

func apply_insta_kill(effect, target):
	if "condition" in effect and effect["condition"] == "target_hp <= 40":
		if target.get_health_percentage() <= 40:
			target.kill()

func strip_armor(effect, target):
	target.remove_armor()

func update_max_hp(effect, player, target):
	if "condition" in effect and effect["condition"] == "target_hp <= 0":
		if target.is_dead():
			player.increase_max_hp(effect["amount"])

func apply_armor(effect, player):
	player.add_armor(effect["amount"])

func draw_cards(effect, player):
	player.draw_cards(effect["amount"])
