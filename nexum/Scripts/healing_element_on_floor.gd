extends RigidBody3D

@export var heal_amount: float = 25.0
var rotation_speed: float = 1.5
var max_rotation_speed: float = 20.0
var acceleration: float = 30.0
var float_amplitude: float = 0.05
var float_speed: float = 2.0

var base_height: float = 0.0
var time: float = 0.0
var activated := false

func _ready() -> void:
	base_height = position.y
	# Conecta la señal del Area3D
	$Area3D.body_entered.connect(_on_Area3D_body_entered)

func _process(delta: float) -> void:
	if activated:
		rotation_speed = min(rotation_speed + acceleration * delta, max_rotation_speed)

	rotation.y += rotation_speed * delta
	time += delta
	position.y = base_height + sin(time * float_speed) * float_amplitude

func _on_Area3D_body_entered(body: Node) -> void:
	if activated:
		return
	if body is CharacterBody3D:
		activated = true
		var manager = get_tree().get_first_node_in_group("Tutorial")
		if manager:
			manager.complete_step(manager.Steps.OBJECTS)

		if body.has_method("heal"):
			body.heal(heal_amount)

		await get_tree().create_timer(1.0).timeout
		set_deferred("monitoring", false) # Desactiva el área primero
		queue_free()
