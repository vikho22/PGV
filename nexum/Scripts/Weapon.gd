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

func shoot():
	# 1. Comprobamos si podemos disparar
	if not can_shoot or bullet_scene == null:
		return
	
	# 2. Instanciamos la bala
	var new_bullet = bullet_scene.instantiate()
	
	# 3. La añadimos al mundo 
	get_tree().root.add_child(new_bullet)
	
	# 4. Colocamos la bala en el Muzzle
	new_bullet.global_transform = muzzle.global_transform
	new_bullet.damage = damage # Pasamos el daño del arma a la bala
	
	# 5. Iniciamos el enfriamiento
	can_shoot = false
	timer.start()

# Cuando el timer termina, podemos disparar de nuevo
func _on_shoot_timer_timeout():
	can_shoot = true
