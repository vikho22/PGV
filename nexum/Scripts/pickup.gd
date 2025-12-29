extends Area3D

@export var weapon_scene_to_give: PackedScene
@onready var label_prompt: Label3D = $Label3D

# --- Variables Visuales (Igual que antes) ---
@export var rotation_speed: float = 1.5
@export var float_amplitude: float = 0.05
@export var float_speed: float = 2.0
var base_height: float = 0.0
var time: float = 0.0

var player_in_range = null # Quitamos el tipado estricto un momento para evitar errores

func _ready() -> void:
	base_height = position.y
	if label_prompt: label_prompt.visible = false

func _process(delta: float) -> void:
	# Visuales
	rotation.y += rotation_speed * delta
	time += delta
	position.y = base_height + sin(time * float_speed) * float_amplitude
	
	# --- DEBUGGING ---
	# Si pulsas E, imprime algo. Si no sale este mensaje, el Input Map (Paso 1) está mal.
	if Input.is_action_just_pressed("interact"):
		print("DEBUG: Tecla E pulsada. ¿Hay jugador?: ", player_in_range != null)

	if player_in_range != null and Input.is_action_just_pressed("interact"):
		pick_up_weapon()

func _on_body_entered(body: Node3D) -> void:
	print("DEBUG: Algo entró: ", body.name) # ¿Sale esto en consola al acercarte?
	
	# USAMOS "is Player" porque pusiste "class_name Player" en tu script del personaje.
	# Esto es mucho mejor que comprobar el nombre "Player".
	if body is Player: 
		print("DEBUG: ¡Es el jugador!")
		player_in_range = body
		if label_prompt: label_prompt.visible = true

func _on_body_exited(body: Node3D) -> void:
	if body == player_in_range:
		print("DEBUG: Jugador salió")
		player_in_range = null
		if label_prompt: label_prompt.visible = false

func pick_up_weapon():
	print("DEBUG: Intentando recoger...")
	if weapon_scene_to_give == null:
		print("ERROR: ¡Se te olvidó arrastrar la escena del arma (Rifle.tscn) en el Inspector del Pickup!")
		return
		
	if player_in_range.has_method("add_weapon"):
		player_in_range.add_weapon(weapon_scene_to_give)
		queue_free()
	else:
		print("ERROR: El script del Player no tiene la función 'add_weapon'")
