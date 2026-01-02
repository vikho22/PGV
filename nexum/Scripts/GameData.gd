extends Node

## Configuracion de las distintas armas a 1/1/2026
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

## Multiplicadores de daño en función de la rareza del arma
var rarity_multipliers = {
	"comun": 1.0,      
	"rara": 1.5,       
	"epica": 2.0,      
	"legendaria": 3.0  
}

## Funcion para obtener las stats de un arma y rareza concretas
func get_weapon_config(weapon_type: String, rarity: String) -> Dictionary:
	var base = weapon_stats[weapon_type].duplicate()
	var mult = rarity_multipliers[rarity]
	
	# Aplicamos la magia de la rareza
	base["damage"] = int(base["damage"] * mult)
	
	return base
	
	
# ------------------------ SISTEMA DE PUNTUACION -------------------------------------
## Puntuación global de la partida
var score: int = 0
## Ronda actual del juego
var current_round: int = 1

## Puntuación de los distintos enemigos a 2/1/2026
var enemy_scores = {
	"zombie": 10,
	"Demon": 20,
	"Goleling": 500
}

signal score_updated(score)

## Manda una señal a la UI con la puntuación actualizada
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
