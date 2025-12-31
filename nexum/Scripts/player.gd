extends CharacterBody3D
class_name Player

@onready var weapon_hitbox = $"character-d/root/torso/arm-left/Area3D"

@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree.get("parameters/playback")
@onready var camera = $Camera3D
@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var view_camera: Camera3D = get_viewport().get_camera_3d()
@export var weapon_holder: Node3D

@export var SPEED = 4.0
@export var JUMP_VELOCITY = 5.5
@export var strength = 10

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

func get_mouse_position_3d() -> Vector3:
	var mouse_pos = get_viewport().get_mouse_position()
	var drop_plane = Plane(Vector3.UP, global_position.y)
	var ray_origin = view_camera.project_ray_origin(mouse_pos)
	var ray_normal = view_camera.project_ray_normal(mouse_pos)
	return drop_plane.intersects_ray(ray_origin, ray_normal)

func rotar_hacia_mouse(delta: float):
	var intersection_point = get_mouse_position_3d()
	
	if intersection_point:
		var look_direction = intersection_point - global_position
		var target_angle = atan2(look_direction.x, look_direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * 10.0)

func _physics_process(delta: float) -> void:
	# 1. Gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# 2. Salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		
	# 3. Movimiento
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
	
	# 4. Rotación
	# Si estamos atacando, miramos al ratón. Si corremos, miramos al frente.
	if !anim_tree.get("parameters/BlendTree/AttackType/active"):
		if direction != Vector3.ZERO:
			var target_rotation = atan2(direction.x, direction.z)
			rotation.y = lerp_angle(rotation.y, target_rotation, 0.15)
	else:
		rotar_hacia_mouse(delta)

	if !melee and weapon != null:
		var apretando_boton = false
		
		# Lógica Híbrida:
		# 1. ¿Acabas de pulsar? (Prioridad al clic inicial para disparar SIEMPRE la primera bala)
		if Input.is_action_just_pressed("attack"):
			apretando_boton = true
			
		# 2. ¿Mantienes pulsado Y el arma es automática? (Para la ráfaga continua)
		elif Input.is_action_pressed("attack") and weapon.get("automatic") == true:
			apretando_boton = true
		
		if apretando_boton:
			rotar_hacia_mouse(delta) 
			realizar_disparo()

	var move_speed = Vector2(velocity.x,velocity.z).length()
	
	if !melee:
		var target_hold = 0.0 if move_speed > 0 else 1.0
		var current_hold = anim_tree.get("parameters/BlendTree/Blend2/blend_amount")
		var new_hold = lerp(float(current_hold), target_hold, delta * BLEND_SPEED)
		anim_tree.set("parameters/BlendTree/Blend2/blend_amount", new_hold)
	
	move_and_slide()
	
func add_weapon(weapon_scene: PackedScene):
	# 1. Borrar arma anterior si existe
	if weapon != null:
		weapon.queue_free()

	# 2. Instanciar nueva arma
	var new_weapon = weapon_scene.instantiate()
	weapon_holder.add_child(new_weapon)
	
	# 3. Actualizar referencias
	weapon = new_weapon
	melee = false # Cambiamos modo a disparo
	print("Arma equipada: ", new_weapon.name)

func take_damage(damage: float):
	var shield := $DataBars/Shield/Sprite3D
	var health := $DataBars/Health/Sprite3D
	
	if shield.real_value > 0:
		shield.take_damage(damage)
		current_shield -= max(0,damage)
		if shield.real_value <= 0:
			var leftover = -shield.real_value
			if leftover > 0:
				health.take_damage(leftover)
				current_health -= leftover
	else:
		health.take_damage(damage)
		current_health -= damage
	
	if current_health <= 0:
		die()
		return
	
	can_take_damage = false
	await get_tree().create_timer(damage_timeout).timeout
	can_take_damage = true
	
func die():
	if not is_physics_processing():
		return
	set_physics_process(false) 
	velocity = Vector3.ZERO    

	$CollisionShape3D.set_deferred("disabled", true)
	
	state_machine.travel("die") 
	
	await get_tree().create_timer(2.0).timeout
	queue_free()
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		if !anim_tree.get("parameters/BlendTree/AttackType/active"):
			if melee:
				# 1. Le decimos al AnimationTree que cambie a la rama de "attack"
				anim_tree.set("parameters/BlendTree/Transition/transition_request", "attack")
				
				# 2. Disparamos la animación (OneShot)
				anim_tree.set("parameters/BlendTree/AttackType/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
			
				# 3. Lógica de la Hitbox (Sincronización del daño con el movimiento del brazo)
				await get_tree().create_timer(0.2).timeout
				
				# Activamos la detección de colisiones del arma/puño
				if weapon_hitbox: 
					weapon_hitbox.monitoring = true
				
				await get_tree().create_timer(0.2).timeout
				
				if weapon_hitbox:
					weapon_hitbox.monitoring = false
				
				
func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	$DataBars/Health/Sprite3D.heal(amount)
	
func get_shield(amount: float) -> void:
	current_shield = min(current_shield + amount, max_shield)
	$DataBars/Shield/Sprite3D.get_shield(amount)


func _on_area_3d_area_entered(area: Area3D) -> void:
	var target = area.get_parent()
	print("attacked")
	if target.has_method("take_damage"):
		target.take_damage(strength)
		set_deferred("monitoring", false)
		
		
func realizar_disparo():
	# Activar animación
	anim_tree.set("parameters/BlendTree/Transition/transition_request", "shoot")
	anim_tree.set("parameters/BlendTree/AttackType/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	# Ordenar al arma disparar
	if weapon.has_method("shoot"):
		var target = get_mouse_position_3d()
		if target:
			weapon.shoot(target)
		else:
			weapon.shoot()
