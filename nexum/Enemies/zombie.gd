extends CharacterBody3D

@onready var max_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_zombie = $"zombie/AnimationPlayer"
@export var speed = 2.0
@export  var target_position = Vector3(0,1,0)

var vida: float = 100
var player_target : CharacterBody3D = null



func _ready() -> void:
	max_agent.target_desired_distance = 0.1
	max_agent.path_desired_distance = 0.1
	
	set_movement_target_position(target_position)
	

func _physics_process(delta: float) -> void:
	if max_agent.is_navigation_finished():
		return
	
	var current_position = global_position
	var init_path_position = max_agent.get_next_path_position()
	
	velocity = current_position.direction_to(init_path_position) * speed
	
	anim_zombie.play("walk")
	move_and_slide()
	

func set_movement_target_position(target: Vector3):
	max_agent.set_target_position(target)
	pass
