extends Node

var weapon_stats = {
	"pistola": {
		"damage": 10,
		"fire_rate": 0.5,
		"spread": 0.0,
		"shot_count": 1,
		"automatic": false,
		"damage_dropoff": false,
		"max_range": 10
		
	},
	"subfusil": {
		"damage": 5,
		"fire_rate": 0.1,
		"spread": 0.0,
		"shot_count": 1,
		"automatic": true,
		"damage_dropoff": false,
		"max_range": 10
	},
	"escopeta": {
		"damage": 20, 
		"fire_rate": 1.0,
		"spread": 2.0,
		"shot_count": 5,
		"automatic": false,
		"damage_dropoff": true,
		"max_range": 10
	},
	"fusil": {
		"damage": 17, 
		"fire_rate": 0.3,
		"spread": 0.01,
		"shot_count": 1,
		"automatic": true,
		"damage_dropoff": true,
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
	
	
var score: int = 0
var current_round: int = 1

var enemy_scores = {
	"zombie": 10,
	"Demon": 20,
	"Goleling": 500
}

#signal(score_updated)

func add_kill_score(enemy_type: String):
	# 1. Obtenemos puntos base
	var base_points = enemy_scores.get(enemy_type, 10)
	
	# 2. Calculamos el Multiplicador de Ronda
	var round_multiplier = 1.0 + (current_round * 0.1)
	
	# 3. Calculamos total
	var final_points = int(base_points * round_multiplier)
	
	# 4. Sumamos y avisamos
	score += final_points
	emit_signal("score_updated", score)
	
	print("Muerte: ", enemy_type, " | Puntos: ", final_points, " | Total: ", score)
