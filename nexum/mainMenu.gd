extends Control

@onready var music: AudioStreamPlayer2D = $Music
@onready var jugar_button: Button = $Buttons/Play
@onready var tutorial_button: Button = $Buttons/Tutorial
@onready var logros_button: Button = $Buttons/Logros
@onready var music_button: Button = $Buttons/Music
@onready var setting_button: Button = $Buttons/Settings

func _ready() -> void:
	
	# Música
	if music and not music.playing:
		music.play()
	
	# Conectar botones
	jugar_button.pressed.connect(_on_jugar_pressed)
	tutorial_button.pressed.connect(_on_tutorial_pressed)
	logros_button.pressed.connect(_on_logros_pressed)
	setting_button.pressed.connect(_on_settings_pressed)


func _on_jugar_pressed() -> void:
	# Cambiar a la escena del mapa / juego principal
	get_tree().change_scene_to_file("res://Mapa/Mapa.tscn")


func _on_tutorial_pressed() -> void:
	# Por ahora solo mostramos algo en la consola
	# luego aquí puedes cambiar de escena a un Tutorial.tscn
	print("Ir al tutorial (pendiente de implementar)")


func _on_logros_pressed() -> void:
	# Igual: por ahora mensaje
	print("Ir a logros (pendiente de implementar)")


func _on_settings_pressed() -> void:
	# Pantalla de controles (remapeo)
	get_tree().change_scene_to_file("res://Controles.tscn")
