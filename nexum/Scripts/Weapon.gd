extends Node3D

# --- CONFIGURACIÓN ---
@export_group("Stats")
@export var damage: int = 10
@export var fire_rate: float = 0.5 
@export var bullet_scene: PackedScene 

# --- REFERENCIAS ---
@onready var muzzle = $Muzzle
@onready var timer = $ShootTimer
@onready var model_container = $Model

var can_shoot: bool = true

func _ready():
	timer.wait_time = fire_rate

func shoot(target_point: Vector3 = Vector3.ZERO):
	if not can_shoot or bullet_scene == null:
		return
	
	var new_bullet = bullet_scene.instantiate()
	get_tree().root.add_child(new_bullet)
	
	# Colocamos la bala en la boca del cañón (Posición)
	new_bullet.global_position = muzzle.global_position
	new_bullet.damage = damage
	
	if target_point != Vector3.ZERO:
		var aim_target = Vector3(target_point.x, muzzle.global_position.y, target_point.z)
		new_bullet.look_at(aim_target, Vector3.UP)
	else:
		new_bullet.global_rotation = muzzle.global_rotation

	can_shoot = false
	timer.start()

# Cuando el timer termina, podemos disparar de nuevo
func _on_shoot_timer_timeout():
	can_shoot = true
