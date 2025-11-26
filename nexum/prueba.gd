extends Node3D

@onready var player = $Player
@onready var enemies = $Enemies


func _ready() -> void:
	enemies.player_target = player
	enemies
	pass
	
