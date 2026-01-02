extends Node3D

# Definimos los pasos del tutorial
enum Steps {
	MOVE,
	JUMP,
	SHIELD,
	ATTACK,
	OBJECTS,
	FINISHED
}

var current_step = Steps.MOVE

func _ready() -> void:
	get_tree().paused = true # Congela todo (física, enemigos)
	%Zombie.player_target = null
	%Zombie.hide()
	%Bottle.hide()
	%Apple.hide()
	$CanvasLayer/PanelContainer/Label.text = "Bienvenido al entrenamiento. Pulsa ENTER para empezar."
	await(1.0)
	update_instruction()

func update_instruction() -> void:
	match current_step:
		Steps.MOVE:
			$CanvasLayer/PanelContainer/Label.text = "Usa WASD para caminar."
		Steps.JUMP:
			$CanvasLayer/PanelContainer/Label.text = "¡Bien! Ahora pulsa ESPACIO para saltar el obstáculo."
		Steps.SHIELD:
			%Bottle.show()
			$CanvasLayer/PanelContainer/Label.text = "Te iran apareciendo objetos, para que puedas aumentar tu nivel de escudo, acercate a ellos para poder obtenerlo."
		Steps.ATTACK:
			%Zombie.show()
			%Zombie.player_target = %Player
			$CanvasLayer/PanelContainer/Label.text = "Pulsa CLICK IZQUIERDO para atacar al objetivo."
		Steps.OBJECTS:
			%Apple.show()
			$CanvasLayer/PanelContainer/Label.text = "Te iran apareciendo objetos, para que puedas aumentar tu nivel de vida, acercate a ellos para poder obtenerlo."
		Steps.FINISHED:
			$CanvasLayer/PanelContainer/Label.text = "¡Tutorial completado!"
			# Aquí podrías cargar el nivel 1 real:
			# get_tree().change_scene_to_file("res://Nivel1.tscn")
			print("Comenzamos el Nivel 1")
			get_tree().change_scene_to_file("res://Mapa/Mapa.tscn")

# Esta función la llamaremos desde fuera cuando el jugador cumpla una tarea
func complete_step(step_completed: int) -> void:
	if current_step == step_completed:
		current_step += 1
		update_instruction()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enter") and get_tree().paused:
		get_tree().paused = false 
		update_instruction()

	if current_step == Steps.JUMP and event.is_action_pressed("jump"): # o "jump"
		complete_step(Steps.JUMP)
	
	if current_step == Steps.ATTACK and event.is_action_pressed("attack"):
		complete_step(Steps.ATTACK)


func _on_area_3d_body_entered(body: Node3D) -> void:
	# Verificamos si fue el jugador quien entró
	if body.name == "Player" and current_step == Steps.MOVE:
		complete_step(Steps.MOVE)
		# Opcional: Eliminar el área para que no moleste más
		#$TutorialTriggers/Area3D_Movimiento.queue_free()
