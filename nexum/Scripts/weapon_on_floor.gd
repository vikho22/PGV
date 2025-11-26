extends Node3D

@export var rotation_speed: float = 1.5
@export var float_amplitude: float = 0.05  # altura del vaivén
@export var float_speed: float = 2.0       # velocidad del vaivén

var base_height: float = 0.0
var time: float = 0.0

func _ready() -> void:
	base_height = position.y

func _process(delta: float) -> void:
	# Rotación
	rotation.y += rotation_speed * delta

	# Flotación
	time += delta
	position.y = base_height + sin(time * float_speed) * float_amplitude
