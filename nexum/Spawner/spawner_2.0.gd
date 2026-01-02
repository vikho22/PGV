extends Area3D

@onready var enemy_scene = load("res://Enemies/zombie.tscn")
var bool_spawn = true

var random = RandomNumberGenerator.new()
@export var radio_spawn: float = 2.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	random.randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	spawn()

func spawn():
	if bool_spawn:
		$Timer.start()
		bool_spawn = false #Para que no añada más hasta que se acabe el tiempo.
		var enemy_instance = enemy_scene.instantiate()
		var offset_x = randf_range(-radio_spawn, radio_spawn)
		var offset_z = randf_range(-radio_spawn, radio_spawn)
		#Para que no se amontonen los Zombies.z
		enemy_instance.global_position = global_position + Vector3(offset_x, 0, offset_z)
		add_child(enemy_instance)



func _on_timer_timeout() -> void:
	bool_spawn = true
