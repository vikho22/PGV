extends Enemy

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	health = max_health
	pass # Replace with function body.


func _on_area_3d_area_entered(area: Area3D) -> void:
	var player = area.get_parent()
	if player.has_method("take_damage"):
		player.take_damage(strength)
