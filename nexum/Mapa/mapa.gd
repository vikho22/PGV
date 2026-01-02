extends Node3D

@onready var player = $Player
#@onready var zombie = $Zombie
@onready var spawner = $Spawner
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
#	zombie.player_target = player
	spawner.objetivo_jugador = player
	pass # Replace with function body.
