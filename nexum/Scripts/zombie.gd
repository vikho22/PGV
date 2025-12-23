extends CharacterBody3D

@onready var max_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_zombie = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var anim_state = anim_tree.get("parameters/playback")


@onready var barra_vida = $Health/Sprite3D/SubViewport/Panel/ProgressBar
@export var speed = 2.0
@export  var target_position: Vector3 = Vector3(0,1,0)

#Health:
var max_health: float = 100.0
var current_health: float = 100.0
var cooldown: float = 1
var onCooldowm: bool = false


#Position:
var player_target : Player = null

#Weapons:
var weapon: Node3D = null
var can_take_damage = true
var damage_timeout= 1.0

func _ready() -> void:
	max_agent.target_desired_distance = 2
	max_agent.path_desired_distance = 0.5
	
	set_movement_target_position(target_position)


func _physics_process(delta: float) -> void:
	
	# 1. SEGURIDAD: Si no hay jugador, no hacemos nada (evita crashes)
	if player_target == null:
		return

	var current_node = anim_state.get_current_node()
	
	if current_node == "attack":
		velocity.x = move_toward(velocity.x,0,speed)
		velocity.z = move_toward(velocity.z,0,speed)
		move_and_slide()
		return
	
	# Actualizamos destino
	set_movement_target_position(player_target.global_position)
	
	# 2. LÓGICA DE ATAQUE
	if max_agent.is_navigation_finished() && !onCooldowm:
		anim_state.travel("attack")
		deal_damage()
		onCooldowm = true
		await get_tree().create_timer(cooldown).timeout
		onCooldowm = false
		return 
	
	# 3. LÓGICA DE MOVIMIENTO 
	var current_position = global_position
	var next_path_position = max_agent.get_next_path_position()
	var direction = (next_path_position - current_position).normalized()
	
	var moving = Vector2.ZERO
		
	if direction != Vector3.ZERO:
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 0.2)
		
	if !max_agent.is_navigation_finished():
		moving = Vector2(1,0)
		velocity = direction * speed

	anim_tree.set("parameters/Movement/blend_position",moving)
	move_and_slide()

# 4. FUNCIÓN NUEVA: Esta función será llamada por la animación
func deal_damage():
	if global_position.distance_to(player_target.global_position) <= 2: 
		if player_target.has_method("take_damage"):
			player_target.take_damage(20)

# Función de Movimiento
func set_movement_target_position(target: Vector3):
	max_agent.set_target_position(target)
	pass


func _on_sprite_3d_no_hp_left() -> void:
	if not is_physics_processing():
		return

	set_physics_process(false) # Deja de perseguir
	velocity = Vector3.ZERO    # Frena en seco

	$CollisionShape3D.set_deferred("disabled", true)
	
	anim_state.travel("Death") 
	
	await get_tree().create_timer(4.0).timeout
	queue_free()
	queue_free()
