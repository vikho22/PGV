extends Area3D

@export var weapon_scene_to_give: PackedScene
@export_enum("pistola", "subfusil", "escopeta", "fusil") var weapon_type: String = "pistola"
@export_enum("comun", "rara", "epica", "legendaria") var rarity: String = "comun"
@onready var label_prompt: Label3D = $Label3D
@onready var particles = $Particles

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
	update_visuals()

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
		
func update_visuals():
	# 1. Definimos los colores 
	var rarity_colors = {
		"comun": Color.LIME_GREEN,            
		"rara": Color(0.2, 0.6, 1.0),    
		"epica": Color(0.6, 0.2, 1.0),   
		"legendaria": Color(1.0, 0.5, 0.0) 
	}
	
	# 2. Obtenemos el color que toca
	var my_color = rarity_colors.get(rarity, Color.LIME_GREEN)
	

	# 4. Pintamos las particulas
	if particles:
		var mesh = particles.draw_pass_1
		if mesh and mesh.material:
			# Creamos una copia única del material 
			var unique_material = mesh.material.duplicate()
			unique_material.albedo_color = my_color
			# Asignamos el nuevo material a la malla
			particles.draw_pass_1.material = unique_material
			
		# B. Opción si usas "Process Material" (Color directo de partícula):
		# (Descomenta esto si la opción A no te cambia el color)
		# var unique_process = particles.process_material.duplicate()
		# unique_process.color = my_color
		# particles.process_material = unique_process
