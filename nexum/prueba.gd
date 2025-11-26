extends Node3D

@onready var player = $Player
@onready var enemies = $"character-l"


func _ready() -> void:
	enemies.player_target = player
	pass
	
