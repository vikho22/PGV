extends Node3D

@onready var player = $"character-d"
@onready var zombie = $"character-l"
@onready var demon = $Demon2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zombie.player_target = player
	#demon.player_target = player
	pass # Replace with function body.
