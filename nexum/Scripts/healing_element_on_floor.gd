extends RigidBody3D

@export var rotation_speed: float = 1.5
@export var float_amplitude: float = 0.05  # altura del vaivén
@export var float_speed: float = 2.0       # velocidad del vaivén
@export var activated: bool = false;
@export var max_rotation_speed: float = 20.0
@export var acceleration: float = 30.0

var base_height: float = 0.0
var time: float = 0.0

func _ready() -> void:
	base_height = position.y

func _process(delta: float) -> void:
	# Rotación
	
	if activated:
		rotation_speed = min(rotation_speed + acceleration * delta, max_rotation_speed)
	
	rotation.y += rotation_speed * delta

	# Flotación
	time += delta
	position.y = base_height + sin(time * float_speed) * float_amplitude


func _on_body_entered(body: Node) -> void:
	if activated:
		return  # Ya está activado → ignorar toques posteriores

	activated = true  # Solo se ejecuta la primera vez

	# Desaparecer después de 1 segundo (tú puedes ajustar el tiempo)
	await get_tree().create_timer(1.0).timeout
	queue_free()
