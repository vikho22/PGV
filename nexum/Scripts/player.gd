extends CharacterBody3D
class_name Player


@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree.get("parameters/playback")
@onready var camera = $Camera3D
@onready var view_camera: Camera3D = get_viewport().get_camera_3d()

@export var SPEED = 4.0
@export var JUMP_VELOCITY = 5.5

#Variables de vida:
var max_health: float = 100.0
var current_health: float = 100.0
var max_shield: float = 100.0
var current_shield: float = 0.0
var can_take_damage = true
var damage_timeout = 1.0
var weapon = null
var melee = true

const BLEND_SPEED = 10.0

func rotar_hacia_mouse(delta: float):
	# 1. Obtenemos la posición del ratón en la pantalla (2D)
	var mouse_pos = get_viewport().get_mouse_position()

	# 2. Creamos un plano matemático horizontal (Vector3.UP) 
	# que corta exactamente a la altura de nuestro personaje (global_position.y)
	var drop_plane = Plane(Vector3.UP, global_position.y)

	# 3. Proyectamos un rayo desde la cámara
	var ray_origin = view_camera.project_ray_origin(mouse_pos)
	var ray_normal = view_camera.project_ray_normal(mouse_pos)

	# 4. Calculamos dónde choca ese rayo con nuestro plano imaginario
	var intersection_point = drop_plane.intersects_ray(ray_origin, ray_normal)

	# 5. Si hay intersección (el ratón está sobre el mundo visible), rotamos
	if intersection_point:# 1. Calculamos el vector dirección hacia el punto
		var look_direction = intersection_point - global_position
		
		# 2. Obtenemos el ángulo hacia ese punto
		# Sumamos PI porque tu modelo mira hacia Z positivo
		var target_angle = atan2(look_direction.x, look_direction.z)
		
		# 3. Aplicamos la rotación suavemente
		# El valor 10.0 controla la velocidad del giro, puedes ajustarlo
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 10.0)

func _physics_process(delta: float) -> void:
	# Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	#var current_state = state_machine.get_current_node()
	
	#if current_state == "attack" or current_state == "shoot":
		#rotar_hacia_mouse(delta)
		#velocity = Vector3.ZERO
		#move_and_slide()
		#return
	
	# Movimiento
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	if direction != Vector3.ZERO:
		
		anim_tree.set("parameters/BlendTree/Movement/blend_position", Vector2(0, 1))
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		anim_tree.set("parameters/BlendTree/Movement/blend_position", Vector2(0, 0))
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	# Rotación
	if !anim_tree.get("parameters/BlendTree/AttackType/active"):
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 0.15) # Ajusta 0.15 para suavidad
	else:
		rotar_hacia_mouse(delta)
		
	
	# Camara
	camera.top_level = true 
	camera.global_position = global_position + Vector3(0, 15, 5)
	camera.global_rotation.x = deg_to_rad(-60)
	camera.global_rotation.y = deg_to_rad(0) 
	
	# Animación ataque
	var move_speed = Vector2(velocity.x,velocity.z).length()
	
	if !melee:
		var target_hold = 0.0 if move_speed > 0 else 1.0
		var current_hold = anim_tree.get("parameters/BlendTree/Blend2/blend_amount")
		var new_hold = lerp(float(current_hold), target_hold, delta * BLEND_SPEED)
		anim_tree.set("parameters/BlendTree/Blend2/blend_amount", new_hold)
	
	move_and_slide()

func take_damage(has: bool):
	if can_take_damage and has:
		for i in range(get_slide_collision_count()):
			if get_slide_collision(i).get_collider() is CharacterBody3D:
				var damage := 10

				var shield := $DataBars/Shield/Sprite3D
				var health := $DataBars/Health/Sprite3D
				
				
				if shield.real_value > 0:
					shield.take_damage(damage)

					if shield.real_value <= 0:
						var leftover = -shield.real_value
						if leftover > 0:
							health.take_damage(leftover)

				else:
					health.take_damage(damage)
				
				can_take_damage = false
				await get_tree().create_timer(damage_timeout).timeout
				can_take_damage = true
				break
				
				

func _on_sprite_3d_no_hp_left() -> void:
	queue_free()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if !anim_tree.get("parameters/BlendTree/AttackType/active"):
			if melee:
				anim_tree.set("parameters/BlendTree/Transition/transition_request", "attack")
			else:
				anim_tree.set("parameters/BlendTree/Transition/transition_request", "shoot")
			anim_tree.set("parameters/BlendTree/AttackType/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	$DataBars/Health/Sprite3D.heal(amount)
	
func get_shield(amount: float) -> void:
	current_shield = min(current_shield + amount, max_shield)
	$DataBars/Shield/Sprite3D.get_shield(amount)
