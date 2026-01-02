extends Node3D

# Definimos los pasos del tutorial
enum Steps {
	MOVE,
	JUMP,
	WEAPONS,
	SHIELD,
	ATTACK,
	OBJECTS,
	FINISHED
}

var current_step = Steps.MOVE
@onready var label = $CanvasLayer/PanelContainer/Label


func _ready() -> void:
	get_tree().paused = true # Congela todo (física, enemigos)
	%Zombie.player_target = null
	await get_tree().process_frame
	get_tree().call_group("Objetos_Tutorial","hide")
	label.text = "Bienvenido al entrenamiento. Pulsa INTERACT para empezar."
	await get_tree().create_timer(2.0).timeout
	#update_instruction()

func update_instruction() -> void:
	match current_step:
		Steps.MOVE:
			label.text = "Usa WASD para caminar."
		Steps.JUMP:
			label.text = "¡Bien! Ahora pulsa ESPACIO para saltar el obstáculo."
		Steps.WEAPONS:
			%PickupPistol.show()
			label.text = "Podemos tener diferentes armas, para seleccionarla deberemos de darle a la E"
		Steps.SHIELD:
			%Bottle.show()
			label.text = "Al matar enemigos podrán aparecer, para que puedas aumentar tu nivel de escudo, acercate a ellos para poder obtenerlo."
		Steps.ATTACK:
			label.text = "Pueden aparecer varios tipos de enemigos"
			%Zombie.show()
			%Demon.show()
			%Zombie.player_target = %Player
			%Demon.player_target = %Player
			label.text = "Pulsa CLICK IZQUIERDO para atacar al objetivo."
		Steps.OBJECTS:
			%Apple.show()
			if %Player.current_health < 100:
				%Zombie.hide()
			label.text = "Al matar enemigos podrán aparecer, para que puedas aumentar tu nivel de vida, acercate a ellos para poder obtenerlo."
		Steps.FINISHED:
			label.text = "¡Tutorial completado!"
			await get_tree().create_timer(2.0).timeout
			get_tree().change_scene_to_file("res://Mapa/Mapa.tscn")

# Esta función la llamaremos desde fuera cuando el jugador cumpla una tarea
func complete_step(step_completed: int) -> void:
	if current_step == step_completed:
		current_step += 1
		update_instruction()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and get_tree().paused:
		get_tree().paused = false 
		update_instruction()

	if current_step == Steps.JUMP and event.is_action_pressed("jump"): # o "jump"
		complete_step(Steps.JUMP)
	
	if current_step == Steps.ATTACK and event.is_action_pressed("attack"):
		complete_step(Steps.ATTACK)
	
	if current_step == Steps.WEAPONS and event.is_action_pressed("interact"):
		complete_step(Steps.WEAPONS)


func _on_area_3d_body_entered(body: Node3D) -> void:
	# Verificamos si fue el jugador quien entró
	if body.name == "Player" and current_step == Steps.MOVE:
		complete_step(Steps.MOVE)
		# Opcional: Eliminar el área para que no moleste más
		#$TutorialTriggers/Area3D_Movimiento.queue_free()
