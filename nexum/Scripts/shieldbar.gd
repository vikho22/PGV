extends Sprite3D

signal no_shield_left

@export var max_shield: int = 100
var real_value: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SubViewport/Panel/ProgressBar.max_value = max_shield
	$SubViewport/Panel/ProgressBar.value = 0
	real_value = 0

func take_damage(damage: float):
	real_value -= damage
	
	create_tween().tween_property($SubViewport/Panel/ProgressBar,"value",real_value,0.3)
	
	if real_value <= 0.1:
		no_shield_left.emit()
		
		

func get_shield(getting_shield: float):
	real_value += getting_shield
	real_value = min(real_value, max_shield)
	
	create_tween().tween_property($SubViewport/Panel/ProgressBar,"value",real_value,0.3)
	
