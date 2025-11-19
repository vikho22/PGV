extends CharacterBody3D

@onready var max_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_zombie = $"zombie/AnimationPlayer"
@export var speed = 2.0
@export  var target_position = Vector3(0,1,0)

var vida: float = 100
var player_target : CharacterBody3D = null


func _ready() -> void:
	max_agent.target_desired_distance = 2
	max_agent.path_desired_distance = 0.5
	
	set_movement_target_position(target_position)
	

func _physics_process(delta: float) -> void:
	set_movement_target_position(player_target.position)
	if max_agent.is_navigation_finished():
		anim_zombie.play("attack-kick-left")
		return
	
	var current_position = global_position
	var init_path_position = max_agent.get_next_path_position()
	var direction = current_position.direction_to(init_path_position)
	
	
	# Normaliza para que la velocidad sea constante incluso en diagonal
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Calcula rotación hacia el movimiento
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 0.2)
		anim_zombie.play("walk")


	
	velocity = direction * speed
	move_and_slide()
	

func set_movement_target_position(target: Vector3):
	max_agent.set_target_position(target)
	pass
