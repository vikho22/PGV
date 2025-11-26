extends CharacterBody3D

@onready var max_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_zombie = $"zombie/AnimationPlayer"
@onready var barra_vida = $Health/Sprite3D/SubViewport/Panel/ProgressBar
@export var speed = 2.0
@export  var target_position = Vector3(0,1,0)

#Health:
var max_health: float = 100.0
var current_health: float = 100.0


#Position:
var player_target : CharacterBody3D = null

#Weapons:
var weapon: Node3D = null
var can_take_damage = true
var damage_timeout= 1.0

func _ready() -> void:
	max_agent.target_desired_distance = 2
	max_agent.path_desired_distance = 0.5
	
	set_movement_target_position(target_position)


#func _physics_process(delta: float) -> void:
	#set_movement_target_position(player_target.position)
	#if max_agent.is_navigation_finished():
		#anim_zombie.play("attack-kick-left")
	#
	#var current_position = global_position
	#var init_path_position = max_agent.get_next_path_position()
	#var direction = current_position.direction_to(init_path_position)
	#
	#
	## Normaliza para que la velocidad sea constante incluso en diagonal
	#if direction != Vector3.ZERO:
		#direction = direction.normalized()
		## Calcula rotación hacia el movimiento
		#var target_rotation = atan2(direction.x, direction.z)
		#rotation.y = lerp_angle(rotation.y, target_rotation, 0.2)
		#anim_zombie.play("walk")
#
#
	#
	#velocity = direction * speed
	#var has_collision = move_and_slide()
	#if can_take_damage and has_collision:
		#for i in range(get_slide_collision_count()):
			#if get_slide_collision(i).get_collider() is CharacterBody3D:
				#$Health/Sprite3D.take_damage(10)
				#can_take_damage = false
				#await get_tree().create_timer(damage_timeout).timeout
				#can_take_damage = true
				#break
	

func _physics_process(delta: float) -> void:
	# 1. SEGURIDAD: Si no hay jugador, no hacemos nada (evita crashes)
	if player_target == null:
		return

	# Actualizamos destino
	set_movement_target_position(player_target.global_position)
	
	# 2. LÓGICA DE ATAQUE
	# Si hemos llegado al jugador (el navigation ha terminado)
	if max_agent.is_navigation_finished():
		# Si no está sonando ya el ataque, lo reproducimos
		if anim_zombie.current_animation != "attack-kick-left":
			anim_zombie.play("attack-kick-left")
			deal_damage()
		return 
	
	# 3. LÓGICA DE MOVIMIENTO (Solo ocurre si NO entró en el 'if' de arriba)
	var current_position = global_position
	var next_path_position = max_agent.get_next_path_position()
	var direction = (next_path_position - current_position).normalized()
	
	if direction != Vector3.ZERO:
		var target_rotation = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_rotation, 0.2)
		
		# Solo ponemos Walk si no está atacando
		anim_zombie.play("walk")
	
	velocity = direction * speed
	move_and_slide()

# 4. FUNCIÓN NUEVA: Esta función será llamada por la animación
func deal_damage():
	# Verificamos de nuevo la distancia por si el jugador se alejó en el último segundo
	if global_position.distance_to(player_target.global_position) <= 2.5: # 2.5 es el rango del golpe
		if player_target.has_method("take_damage"):
			player_target.take_damage(10)

# Función de Movimiento
func set_movement_target_position(target: Vector3):
	max_agent.set_target_position(target)
	pass


func _on_sprite_3d_no_hp_left() -> void:
	queue_free() # Replace with function body.
