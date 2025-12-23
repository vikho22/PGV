extends CharacterBody3D

@onready var anim_player = $AnimationPlayer
@onready var equiped_weapon = $"character-d/root/torso/arm-right/blaster-a"
#@onready var spring_arm = %SpringArm3D

@export var SPEED = 5.0
@export var JUMP_VELOCITY = 4.5
@export var bullet_scene = preload("res://Weapons/Scenes/bullet.tscn")
@onready var shot_point = $"character-d/root/torso/arm-right/blaster-a/PuntoDisparo"

#Variables de vida:
var max_health: float = 100.0
var current_health: float = 100.0
var can_take_damage = true
var damage_timeout = 1.0

#Variables de arma
var has_weapon: bool = false

func _ready():
	#spring_arm.set_as_top_level(true)
	if equiped_weapon:
		equiped_weapon.visible = false

func _physics_process(delta: float) -> void:
	# Aplicar gravedad
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# disparo
	if Input.is_action_just_pressed("shoot"):
		if has_weapon and bullet_scene != null:
			print("HOLA")
			try_shooting() 
	
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
		

		if anim_player.current_animation != "holding-right-shoot":
			anim_player.play("walk")
			
	else:
		if anim_player.current_animation != "holding-right-shoot":
			anim_player.play("idle")

	# Aplica velocidad horizontal
	var horizontal_velocity = direction * SPEED
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	
	var has_collision = move_and_slide()
	take_damage(has_collision)
	#spring_arm.global_position = global_position

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

func obtener_arma():
	print("¡Arma equipada en el personaje!")
	has_weapon = true
	equiped_weapon.visible = true 
	
# Usamos _unhandled_input para detectar pulsaciones únicas (no mantener pulsado)
func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		
		# Solo disparamos si tenemos el arma y la escena de la bala está cargada
		if has_weapon and bullet_scene != null:
			try_shooting()
			

func try_shooting():
	anim_player.play("holding-right-shoot")
	anim_player.seek(0, true)
	
	var new_bullet = bullet_scene.instantiate()
	
	get_tree().root.add_child(new_bullet)
	
	new_bullet.global_transform = shot_point.global_transform
