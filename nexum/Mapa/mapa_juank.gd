extends Node3D


@onready var player = $"character-d"
@onready var zombie = $"character-l"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	zombie.player_target = player


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
