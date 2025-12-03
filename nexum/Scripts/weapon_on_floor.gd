extends RigidBody3D

# --- Variables de Animación ---
@export var velocidad_giro : float = 1.0
@export var altura_bote : float = 0.05 
@export var velocidad_bote : float = 2.0

# --- Referencias ---
# Usamos % para buscar el Label3D aunque lo muevas de sitio
@onready var cartel = $Label3D 

var tiempo : float = 0.0
var posicion_inicial_y : float = 0.0
#var jugador_en_zona : bool = false
var jugador_cercano = null

func _ready():
	posicion_inicial_y = position.y
	freeze = true 
	cartel.visible = false # Aseguramos que empiece invisible

func _process(delta):
	# 1. Animación (lo que ya tenías)
	tiempo += delta
	rotate_y(velocidad_giro * delta)
	position.y = posicion_inicial_y + sin(tiempo * velocidad_bote) * altura_bote
	
	# 2. Lógica de Recoger
	if jugador_cercano != null and Input.is_key_pressed(KEY_E):
		if Input.is_key_pressed(KEY_E):
			recoger()

func recoger():
	print("¡Arma recogida!")
	if jugador_cercano.has_method("obtener_arma"):
		jugador_cercano.obtener_arma()
		
	queue_free() # Destruye el arma del suelo

# --- SEÑALES (Las conectaremos ahora) ---
func _on_area_entrada(body):
	if body is CharacterBody3D:
		jugador_cercano = body # Guardamos la referencia al jugador
		cartel.visible = true

func _on_area_salida(body):
	if body == jugador_cercano:
		jugador_cercano = null # Olvidamos al jugador
		cartel.visible = false
