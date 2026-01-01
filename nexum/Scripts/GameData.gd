extends Node

var weapon_stats = {
	"pistola": {
		"damage": 10,
		"fire_rate": 0.5,
		"spread": 0.0,
		"shot_count": 1,
		"automatic": false,
		"max_range": 10
	},
	"subfusil": {
		"damage": 5,
		"fire_rate": 0.1,
		"spread": 0.0,
		"shot_count": 1,
		"automatic": true,
		"max_range": 10
	},
	"escopeta": {
		"damage": 20, 
		"fire_rate": 1.0,
		"spread": 2.0,
		"shot_count": 5,
		"automatic": false,
		"max_range": 2.5
	},
	"fusil": {
		"damage": 17, 
		"fire_rate": 0.3,
		"spread": 0.01,
		"shot_count": 1,
		"automatic": true,
		"max_range": 50.0
	}
}

var rarity_multipliers = {
	"comun": 1.0,      
	"rara": 1.5,       
	"epica": 2.0,      
	"legendaria": 3.0  
}

func get_weapon_config(weapon_type: String, rarity: String) -> Dictionary:
	var base = weapon_stats[weapon_type].duplicate()
	var mult = rarity_multipliers[rarity]
	
	# Aplicamos la magia de la rareza
	base["damage"] = int(base["damage"] * mult)
	
	return base
