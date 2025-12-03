extends CharacterBody3D

@onready var anim_player = $AnimationPlayer

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5

#Variables de vida:
var max_health: float = 100.0
var current_health: float = 100.0
var can_take_damage = true
var damage_timeout = 1.0


func _physics_process(delta: float) -> void:
	# Aplicar gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Vector3.ZERO

	# Movimiento en plano XZ
	if Input.is_action_pressed("left"):
		direction.x -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("forward"):
		direction.z -= 1
	if Input.is_action_pressed("backward"):
		direction.z += 1

	# Normaliza para que la velocidad sea constante incluso en diagonal
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		# Calcula rotación hacia el movimiento
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 0.2)
		anim_player.play("walk")
	else:
		anim_player.play("idle")

	# Aplica velocidad horizontal
	var horizontal_velocity = direction * SPEED
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	
	var has_collision = move_and_slide()
	take_damage(has_collision)

func take_damage(has: bool):
	if can_take_damage and has:
		for i in range(get_slide_collision_count()):
			if get_slide_collision(i).get_collider() is CharacterBody3D:
				$Health/Sprite3D.take_damage(10)
				can_take_damage = false
				await get_tree().create_timer(damage_timeout).timeout
				can_take_damage = true
				break

func _on_sprite_3d_no_hp_left() -> void:
	queue_free()

func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	$Health/Sprite3D.heal(amount)
