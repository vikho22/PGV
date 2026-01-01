extends Area3D

@export var weapon_scene_to_give: PackedScene
@export_enum("pistola", "subfusil", "escopeta", "fusil") var weapon_type: String = "pistola"
@export_enum("comun", "rara", "epica", "legendaria") var rarity: String = "comun"
@onready var label_prompt: Label3D = $Label3D

# --- Variables Visuales  ---
@export var rotation_speed: float = 1.5
@export var float_amplitude: float = 0.05
@export var float_speed: float = 2.0
var base_height: float = 0.0
var time: float = 0.0

var player_in_range = null 

func _ready() -> void:
	base_height = position.y
	if label_prompt: label_prompt.visible = false

func _process(delta: float) -> void:
	# Visuales
	rotation.y += rotation_speed * delta
	time += delta
	position.y = base_height + sin(time * float_speed) * float_amplitude

	if player_in_range != null and Input.is_action_just_pressed("interact"):
		pick_up_weapon()

func _on_body_entered(body):
	
	if body.has_method("add_weapon"):
		player_in_range = body  
		if label_prompt:
			label_prompt.visible = true 
		

func _on_body_exited(body: Node3D) -> void:
	if body == player_in_range:
		print("DEBUG: Jugador salió")
		player_in_range = null
		if label_prompt: label_prompt.visible = false

func pick_up_weapon():
	print("DEBUG: Intentando recoger...")
	if weapon_scene_to_give == null:
		return
		
	if player_in_range != null:
		# 1. Buscamos los stats en el diccionario global
		var stats = GameData.get_weapon_config(weapon_type, rarity)
		
		# 2. Se lo damos al jugador
		player_in_range.add_weapon(weapon_scene_to_give, stats)
		
		# 3. Borramos el objeto del suelo
		queue_free()
