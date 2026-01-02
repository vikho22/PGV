extends Node3D

# --- CONFIGURACIÓN ---
@export_group("Stats")
@export var damage: int = 10
@export var fire_rate: float = 0.5 
@export var automatic: bool = false
@export var bullet_scene: PackedScene 

@export var shot_count: int = 1
@export var max_range: float = 20.0
@export var spread: float = 0.0
@export var damage_dropoff = true

# --- REFERENCIAS ---
@onready var muzzle = $Muzzle
@onready var timer = $ShootTimer
@onready var model_container = $Model

var can_shoot: bool = true

func configure(stats: Dictionary):
	damage = stats["damage"]
	fire_rate = stats["fire_rate"]
	spread = stats["spread"]
	shot_count = stats["shot_count"]
	automatic = stats["automatic"]
	damage_dropoff = stats["damage_dropoff"]
	max_range = stats["max_range"]
	
	# Reiniciamos el timer con la nueva cadencia
	if timer:
		timer.wait_time = fire_rate

func _ready():
	timer.wait_time = fire_rate

func shoot(target_point: Vector3 = Vector3.ZERO):
	if not can_shoot or bullet_scene == null:
		return
	
	# Repetimos el proceso por cada bala que tenga el arma
	for i in range(shot_count):
		var new_bullet = bullet_scene.instantiate()
		
		
		# 1. Posición inicial
		new_bullet.global_position = muzzle.global_position
		
		# 2. Configurar datos de la bala (Daño y Distancia)
		new_bullet.damage = damage
		new_bullet.start_position = muzzle.global_position
		new_bullet.max_range = max_range
		new_bullet.damage_dropoff = damage_dropoff
		get_tree().root.add_child(new_bullet)
		
		# 3. Configuración del Spread
		if target_point != Vector3.ZERO:
			# Calculamos una desviación aleatoria
			var spread_offset = Vector3.ZERO
			if spread > 0:
				spread_offset = Vector3(
					randf_range(-spread, spread), 
					0, 
					randf_range(-spread, spread)
				)
			
			# Sumamos la desviación al objetivo original
			var final_target = target_point + spread_offset
			
			# Mantenemos la altura del muzzle para que no dispare al suelo
			var aim_target = Vector3(final_target.x, muzzle.global_position.y, final_target.z)
			
			new_bullet.look_at(aim_target, Vector3.UP)
		else:
			# Si no hay objetivo, aplicamos rotación del muzzle + rotación aleatoria
			new_bullet.global_rotation = muzzle.global_rotation
			if spread > 0:
				new_bullet.rotate_y(deg_to_rad(randf_range(-spread * 5, spread * 5)))
				
		

	# 4. Control de cadencia 
	can_shoot = false
	timer.wait_time = fire_rate
	timer.start()

# Cuando el timer termina, podemos disparar de nuevo
func _on_shoot_timer_timeout():
	can_shoot = true
