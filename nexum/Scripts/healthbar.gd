extends Sprite3D

signal no_hp_left

@export var max_hp: int = 100
var real_value: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SubViewport/Panel/ProgressBar.max_value = max_hp
	$SubViewport/Panel/ProgressBar.value = max_hp
	real_value = max_hp

func take_damage(damage: float):
	real_value -= damage
	
	create_tween().tween_property($SubViewport/Panel/ProgressBar,"value",real_value,0.3)
	
	if real_value <= 0.1:
		no_hp_left.emit()
		
		

func heal(healing: float):
	real_value += healing
	real_value = min(real_value, max_hp)
	
	create_tween().tween_property($SubViewport/Panel/ProgressBar,"value",real_value,0.3)
	
