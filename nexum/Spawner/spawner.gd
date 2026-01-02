extends Node3D

@export var enemigo_scene: PackedScene
@export var radio_spawn: float = 2.0
@export var MAX_ZOMBIES: int = 20

var objetivo_jugador : Player = null
var contar_zombies: int = 0

func _ready():
	# Conectamos el timer por código (o hazlo por el editor si prefieres)
	if contar_zombies < MAX_ZOMBIES:
		$Timer.timeout.connect(spawnear_enemigo)
		$Timer.start()

func spawnear_enemigo():
	if enemigo_scene == null:
		print("Necesitas añadir la escena")
		return
	# Calculamos un desplazamiento aleatorio en función de un radio aleatorio, modificable por nosotros.
	var offset_x = randf_range(-radio_spawn, radio_spawn)
	var offset_z = randf_range(-radio_spawn, radio_spawn)


	var pos_random =  global_position + Vector3(offset_x, 0, offset_z)
	var nav_map = get_world_3d().navigation_map
	var pos_navegable = NavigationServer3D.map_get_closest_point(nav_map,pos_random)
	
	if pos_navegable == Vector3.ZERO:
		return
	#Para comprobar si es o no null
		#Instanciamos al enemigo
	var nuevo_enemigo = enemigo_scene.instantiate()
	if objetivo_jugador:
		nuevo_enemigo.player_target = objetivo_jugador
	
	nuevo_enemigo.global_position = pos_navegable
	
	get_parent().add_child(nuevo_enemigo)
	contar_zombies += 1

func _enemigo_eliminado():
	contar_zombies -= 1
