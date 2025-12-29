extends Area3D

@export var speed: float = 2.0
var damage: int = 0 

func _ready():
	$LifeTimer.start()

func _physics_process(delta):
	# Mover hacia adelante
	position -= transform.basis.z * speed * delta

func _on_body_entered(body):
	#var target = body.get_parent()
	print("Impacto con: ", body.name)
	
	if body.has_method("take_damage"):
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
