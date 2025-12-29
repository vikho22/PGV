extends Enemy

@onready var weapon_hitbox = $"CharacterArmature/Skeleton3D/BoneAttachment3D/Area3D"

func _ready() -> void:
	navigation.target_desired_distance = 1.5
	navigation.path_desired_distance = 0.5
	strength = 3
	
	
	set_movement_target_position(Vector3(0,1,0))


func _physics_process(delta: float) -> void:
	
	# 1. SEGURIDAD: Si no hay jugador, no hacemos nada (evita crashes)
	if player_target == null:
		return

	var current_node = state_machine.get_current_node()
	
	if current_node == "attack":
		velocity.x = move_toward(velocity.x,0,speed)
		velocity.z = move_toward(velocity.z,0,speed)
		move_and_slide()
		return
	
	# Actualizamos destino
	set_movement_target_position(player_target.global_position)
	
	# 2. LÓGICA DE ATAQUE
	if navigation.is_navigation_finished() && !onCooldowm:
		attack()
	
	# 3. LÓGICA DE MOVIMIENTO 
	var current_position = global_position
	var next_path_position = navigation.get_next_path_position()
	var direction = (next_path_position - current_position).normalized()
	
	var moving = Vector2.ZERO
		
	if direction != Vector3.ZERO:
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 0.2)
		
	if !navigation.is_navigation_finished():
		moving = Vector2(1,0)
		velocity = direction * speed

	anim_tree.set("parameters/Movement/blend_position",moving)
	move_and_slide()

func _on_area_3d_area_entered(area: Area3D) -> void:
	var target = area.get_parent()
	if target.has_method("take_damage"):
		target.take_damage(strength)
		set_deferred("monitoring", false)

func attack():
	onCooldowm = true
	state_machine.travel("attack")
	await get_tree().create_timer(0.2).timeout
	weapon_hitbox.monitoring = true
	
	#deal_damage()
	await get_tree().create_timer(attack_cooldown).timeout
	weapon_hitbox.monitoring = false
	onCooldowm = false
