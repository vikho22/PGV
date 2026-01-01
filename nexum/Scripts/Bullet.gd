extends Area3D

var speed: float = 20
var damage: int = 0

var start_position: Vector3 = Vector3.ZERO
var max_range: float = 20.0
var damage_dropoff: bool = true

func _ready():
	if start_position == Vector3.ZERO:
		start_position = global_position
		

func _physics_process(delta):
	# Mover hacia adelante
	position -= transform.basis.z * speed * delta
	
	if global_position.distance_to(start_position) > max_range + 5.0:
		queue_free()
		
func calculate_damage(objetivo):
	print("Impacto con: ", objetivo.name)
	
	if objetivo.has_method("take_damage"):
		var daño_final = damage
		
		# Cálculo de distancia (Funciona igual para Body y Area)
		if damage_dropoff:
			var distancia = global_position.distance_to(start_position)
			
			var multiplier = 1.0 - clamp(distancia / max_range, 0.0, 1.0)
			daño_final = int(damage * multiplier)
			daño_final = max(1, daño_final) # Mínimo 1 de daño
			
		# Aplicamos el daño
		objetivo.take_damage(daño_final)

func _on_body_entered(body):
	# Si choca con pared o cuerpo físico
	calculate_damage(body)
	queue_free()

# Señal: Se acabó el tiempo de vida
func _on_life_timer_timeout():
	queue_free()


func _on_area_entered(area: Area3D) -> void:
	var objetivo = area
	if not area.has_method("take_damage") and area.get_parent().has_method("take_damage"):
		objetivo = area.get_parent()
		
	calculate_damage(objetivo)
	queue_free()
