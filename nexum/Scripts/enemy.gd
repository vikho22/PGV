extends CharacterBody3D
class_name Enemy

@onready var navigation: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player = $AnimationPlayer
@onready var anim_tree = $AnimationTree
@onready var state_machine = anim_tree.get("parameters/playback")

## Tipos de enemigos aceptados a 1/1/2026
@export_enum("zombie", "Demon", "Goleling") var enemy_type: String = "zombie"
@export var speed = 2.0
@export var strength: float = 50.0
@export var max_health: float = 100.0
var health: float = 100.0
@export var attack_cooldown: float = 1
var onCooldowm: bool = false
var can_take_damage: bool = true
var damage_cooldown: float = 1
var dying: bool = false

var player_target : Player = null


@export var drop_items := {
	"nothing": { "scene": null, "chance": 20 },
	"bottle": {
		"scene": preload("res://Shield/Scenes/bottle.tscn"),
		"chance": 40
	},
	"apple": {
		"scene": preload("res://Healing/Scenes/apple.tscn"),
		"chance": 40
	}
}

#Weapons:
var weapon: Node3D = null


func set_movement_target_position(target: Vector3):
	navigation.set_target_position(target)
	pass


func die() -> void:
	if dying:
		return
		
	dying = true

	set_physics_process(false)
	velocity = Vector3.ZERO

	$CollisionShape3D.set_deferred("disabled", true)
	
	state_machine.travel("die")
	GameData.add_kill_score(enemy_type)
	
	await get_tree().create_timer(2.0).timeout
	drop_loot()
	queue_free()

func take_damage(damage: float):
	print("attacked")
	print(GameData.score)
	if can_take_damage:
		var health_bar := $Health/Sprite3D
		
		if health_bar:
			health_bar.take_damage(damage)
		health -= damage
		
		if health <= 0:
			die()
			return
		
		can_take_damage = false
		await get_tree().create_timer(damage_cooldown).timeout
		can_take_damage = true
		
		
func drop_loot():
	var random = randi() % 100
	
	var accumulated := 0
	for item in drop_items.values():
		accumulated += item["chance"]
		if random < accumulated:
			if item["scene"] == null:
				return
			var instance = item["scene"].instantiate()
			get_parent().add_child(instance)
			instance.global_position = global_position
			return
	
