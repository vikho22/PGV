extends Control

# Screen to let the player remap movement keys.
# Uses the Keybinds autoload singleton.

const ACTIONS := ["left", "right", "forward", "backward", "jump"]

var waiting_action: String = ""

@onready var info_label: Label = $Panel/VBox/Info
@onready var binds := {
	"left": $Panel/VBox/RowLeft/Bind,
	"right": $Panel/VBox/RowRight/Bind,
	"forward": $Panel/VBox/RowForward/Bind,
	"backward": $Panel/VBox/RowBackward/Bind,
	"jump": $Panel/VBox/RowJump/Bind,
}

func _ready() -> void:
	# Ensure we show current saved binds
	Keybinds.apply_saved_binds()
	_refresh()

	# Connect buttons safely (so the scene works even if signals weren't wired)
	$Panel/VBox/RowLeft/Action.pressed.connect(func(): _start_rebind("left"))
	$Panel/VBox/RowRight/Action.pressed.connect(func(): _start_rebind("right"))
	$Panel/VBox/RowForward/Action.pressed.connect(func(): _start_rebind("forward"))
	$Panel/VBox/RowBackward/Action.pressed.connect(func(): _start_rebind("backward"))
	$Panel/VBox/RowJump/Action.pressed.connect(func(): _start_rebind("jump"))

	$Panel/VBox/Buttons/Reset.pressed.connect(_on_Reset_pressed)
	$Panel/VBox/Buttons/Back.pressed.connect(_on_Back_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if waiting_action == "":
		return

	# Cancel with ESC
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		waiting_action = ""
		_refresh()
		get_viewport().set_input_as_handled()
		return

	# Accept first pressed key
	if event is InputEventKey and event.pressed and not event.echo:
		Keybinds.set_key_for_action(waiting_action, event)
		Keybinds.save_current_binds()
		waiting_action = ""
		_refresh()
		get_viewport().set_input_as_handled()

func _refresh() -> void:
	for a in ACTIONS:
		binds[a].text = Keybinds.get_key_text(a)

	if waiting_action != "":
		info_label.text = "Presiona una tecla para: %s  (Esc para cancelar)" % waiting_action
	else:
		info_label.text = "Selecciona una acción para cambiar su tecla."

func _start_rebind(action: String) -> void:
	waiting_action = action
	_refresh()

func _on_Reset_pressed() -> void:
	Keybinds.reset_to_defaults()
	_refresh()

func _on_Back_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
