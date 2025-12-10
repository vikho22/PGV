extends Node3D

@onready var player = $Player
@onready var enemies = $Zombie

@onready var cameras := [$Camera1, $Camera2]
@onready var current_index := 0

func switch_camera():
	# Apagar la cámara actual
	cameras[current_index].current = false
	
	# Avanzar al siguiente índice
	current_index = (current_index + 1) % cameras.size()
	
	# Activar la nueva cámara
	cameras[current_index].current = true
	
func _ready() -> void:
	enemies.player_target = player
	cameras[current_index].current = true
	pass
	
func _input(event):
	if event.is_action_pressed("camera"):
		switch_camera()
