extends Node

# Dictionary storing character data dynamically
var characters = {
	1: {
		"Name": "Brutus",
		"Type": "Lizard/Brute",
		"Description": "A male lizard brute with extreme strength",
		"Health": "100/100",
		"BaseEnergy": 3
	},
	2: {
		"Name": "Oracle",
		"Type": "Wizard/Druid",
		"Description": "A female elf wizard/druid with the power of nature",
		"Health": "50/50",
		"BaseEnergy": 3
	},
	3: {
		"Name": "Lucious",
		"Type": "Demon/Imp Rogue",
		"Description": "A demon/imp rogue with the ability to cast from the shadows",
		"Health": "10/10",
		"BaseEnergy": 3
	}
}

func GetCharacter(character: int) -> Array:
	if character in characters:
		var data = characters[character]
		return [data["Name"], data["Type"], data["Description"], data["Health"], data["BaseEnergy"]]
	else:
		print("Character not found")
		return []

# Example usage:
# var char_data = GetCharacter(1)
# print(char_data)  # Outputs: ["Brutus", "Lizard/Brute", "A male lizard brute with extreme strength", "100/100", 3]
