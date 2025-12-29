extends SpringArm3D

@export var target: Node3D
@export var follow_speed: float = 10.0
@export var zoom_speed: float = 8.0

@export var offset = Vector3(0,2.0,0)

@onready var camera = $Camera3D
var current_dist: float

func _ready():
	top_level = true
	current_dist = spring_length
	camera.position.z = spring_length

func _physics_process(delta):
	if not target: return

	global_position = global_position.lerp(target.global_position + offset, follow_speed * delta)

	var hit_dist = get_hit_length()
	
	current_dist = lerp(current_dist, hit_dist, zoom_speed * delta)
	
	camera.position.z = current_dist
