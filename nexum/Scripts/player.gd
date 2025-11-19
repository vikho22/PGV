extends Node3D

@onready var animation_player = $AnimationPlayer

@export var speed := 4.0
@export var jump_height := 2.0
var velocity := Vector3.ZERO
var gravity := -9.8
var is_jumping := false
var translation = 0.0

func _physics_process(delta):
	var direction = Vector3.ZERO

	# --- Movimiento (WASD) ---
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("move_backward"):
		direction.z += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1

	# --- Normaliza dirección ---
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		translation += direction * speed * delta
		animation_player.play("walk")
	else:
		animation_player.play("idle")

	# --- Salto (simple, sin física real) ---
	if Input.is_action_just_pressed("jump") and not is_jumping:
		is_jumping = true
		animation_player.play("jump")
		# Simulación simple del salto
		var jump_timer := get_tree().create_timer(0.6)
		jump_timer.timeout.connect(func(): is_jumping = false)
