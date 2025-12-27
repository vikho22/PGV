extends SpringArm3D

@export var target: Node3D
@export var follow_speed: float = 10.0
@export var zoom_speed: float = 8.0 # Cuanto más alto, más reactivo pero menos "suave"

@export var offset = Vector3(0,2.0,0)

@onready var camera = $Camera3D # Asegúrate de que se llame así
var current_dist: float

func _ready():
	top_level = true
	current_dist = spring_length
	# Forzamos que la cámara empiece en la distancia máxima
	camera.position.z = spring_length

func _physics_process(delta):
	if not target: return

	# 1. SEGUIMIENTO DE POSICIÓN
	global_position = global_position.lerp(target.global_position + offset, follow_speed * delta)

	# 2. LÓGICA DE COLISIÓN MANUAL
	# Aunque el brazo esté "Disabled", este método sigue funcionando 
	# y nos dice a qué distancia está el objeto más cercano.
	var hit_dist = get_hit_length()
	
	# Interpolamos la distancia actual hacia la distancia del choque (o la máxima)
	current_dist = lerp(current_dist, hit_dist, zoom_speed * delta)
	
	# Aplicamos la distancia a la cámara localmente
	# La cámara se mueve en su eje Z local dentro del brazo
	camera.position.z = current_dist
