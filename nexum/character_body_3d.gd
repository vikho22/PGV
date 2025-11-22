extends CharacterBody3D

@onready var anim_player = $"character-e/AnimationPlayer"

@export var speed = 5.0
@export var jumpVelocity = 4.5

func _physics_process(delta: float) -> void:
	# Aplicar gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Salto
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jumpVelocity

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
	var horizontal_velocity = direction * speed
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

	move_and_slide()
