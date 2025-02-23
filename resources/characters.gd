extends Node

# Dictionary storing character data dynamically
var characters = {
	1: {
		"Name": "Brutus",
		"Type": "Lizard Brute",
		"Description": "A lizard brute with extreme strength",
		"Health": 60,
		"BaseEnergy": 3,
		"ImagePath": "res://assets/characters/lizard_character.png",
	},
	2: {
		"Name": "Oracle",
		"Type": "Elf Druid",
		"Description": "An elf druid with the power of nature",
		"Health": 40,
		"BaseEnergy": 3,
		"ImagePath": "res://assets/characters/elf_girl.png",
	},
	3: {
		"Name": "Lucious",
		"Type": "Demon Rogue",
		"Description": "A demon rogue with the ability to cast from the shadows",
		"Health": 55,
		"BaseEnergy": 3,
		"ImagePath": "res://assets/characters/imp_character.png"
	}
}

func GetCharacter(character: int) -> Dictionary:
	if character in characters:
		var data = characters[character]
		return {
			"name": data["Name"],
			"type": data["Type"],
			"description": data["Description"],
			"health": data["Health"],
			"base_energy": data["BaseEnergy"],
			"image_path": data["ImagePath"]
		}
	else:
		print("Character not found")
		return {}

# Example usage:
# var char_data = GetCharacter(1)
# print(char_data)  # Outputs: ["Brutus", "Lizard/Brute", "A male lizard brute with extreme strength", "100/100", 3]
