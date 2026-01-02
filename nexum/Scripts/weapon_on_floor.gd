extends Area3D  


@export var rotation_speed: float = 1.5
@export var float_amplitude: float = 0.05 
@export var float_speed: float = 2.0       
@export var weapon_scene_to_give: PackedScene 

var base_height: float = 0.0
var time: float = 0.0

func _ready() -> void:
	base_height = position.y
	# Opcional: Si se te olvida conectar la señal en el editor, descomenta esto:
	# body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	# --- TU LÓGICA VISUAL (Se queda igual) ---
	# Esto rotará y moverá todo el objeto (incluido el colisionador)
	rotation.y += rotation_speed * delta

	time += delta
	position.y = base_height + sin(time * float_speed) * float_amplitude

# --- NUEVA FUNCIÓN: DETECTAR AL JUGADOR ---
# Recuerda conectar la señal "body_entered" del nodo Area3D a esta función
func _on_body_entered(body: Node3D) -> void:
	# Verificamos si lo que chocó es el Player
	if body.name == "Player": 
		
		# Verificamos si configuraste el arma a entregar
		if weapon_scene_to_give != null:
			# Intentamos dársela (asumiremos que crearás esta función en el Player luego)
			if body.has_method("add_weapon"):
				body.add_weapon(weapon_scene_to_give)
				print("Arma entregada: ", weapon_scene_to_give.resource_path)
				queue_free() # Desaparecer del suelo
			else:
				print("ERROR: El Player no tiene la función 'add_weapon'")
