extends Area3D

@export var velocidad : float = 40.0 
@export var tiempo_vida : float = 3.0 

var timer : float = 0.0

func _process(delta):
	# 1. Mover hacia adelante (Z negativo local)
	translate(Vector3(0, 0, -velocidad * delta))
	
	# 2. Temporizador de autodestrucción
	timer += delta
	if timer >= tiempo_vida:
		queue_free()

# --- EXTRA: Para cuando tengamos enemigos ---
func _on_body_entered(body):
	# Si choca con algo que no sea el jugador (para no dispararte a ti mismo)
	if body.name != "character-d": 
		print("Bala impactó contra: ", body.name)
		# Aquí pondrías código para hacer daño: body.recibir_dano()
		queue_free() # La bala se destruye al impactar
