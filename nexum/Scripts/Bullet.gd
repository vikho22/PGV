extends Area3D

var speed: float = 20
var damage: int = 0

var start_position: Vector3 = Vector3.ZERO
var max_range: float = 20.0
var damage_dropoff: bool = false 

func _ready():
	if start_position == Vector3.ZERO:
		start_position = global_position

func _physics_process(delta):
	# Mover hacia adelante
	position -= transform.basis.z * speed * delta
	
	if global_position.distance_to(start_position) > max_range + 5.0:
		queue_free()

func _on_body_entered(body):
	#var target = body.get_parent()
	print("Impacto con: ", body.name)
	
	if body.has_method("take_damage"):
		if damage_dropoff:
			var distance = global_position.distance_to(start_position)
			print(distance)
			# A 0m = 100% daño. A max_range = 0% daño.
			var multiplier = 1.0 - clamp(distance / max_range, 0.0, 1.0)
			damage = int(damage * multiplier)
			
			# Asegurar mínimo 1 de daño si impacta
			damage = max(1, damage)
			
		body.take_damage(damage)
	
	# Destruir la bala
	queue_free()

# Señal: Se acabó el tiempo de vida
func _on_life_timer_timeout():
	queue_free()


func _on_area_entered(area: Area3D) -> void:
	var target = area.get_parent()
	print("Impacto con: ", target.name)
	
	if target.has_method("take_damage"):
		target.take_damage(damage)
	
	# Destruir la bala
	queue_free()
