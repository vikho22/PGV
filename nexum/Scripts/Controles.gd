extends Control

# Screen to let the player remap keys.
# Uses the Keybinds autoload singleton.

const ACTIONS := ["left", "right", "forward", "backward", "jump", "attack", "interact"]

var waiting_action: String = ""

@onready var info_label: Label = $Panel/VBox/Info

# action -> Label (Bind)
var binds: Dictionary = {}

# action -> Button (Action)
var buttons: Dictionary = {}

func _ready() -> void:
	_bind_nodes_if_exist()

	# Ensure we show current saved binds
	Keybinds.apply_saved_binds()
	_refresh()

	# Connect buttons (only for rows that exist)
	for action in buttons.keys():
		var btn: Button = buttons[action]
		btn.pressed.connect(func(): _start_rebind(action))

	$Panel/VBox/Buttons/Reset.pressed.connect(_on_Reset_pressed)
	$Panel/VBox/Buttons/Back.pressed.connect(_on_Back_pressed)

func _bind_nodes_if_exist() -> void:
	# Mapea las filas que existan en tu escena (si no existen, se ignoran)
	_try_bind_row("left", "RowLeft")
	_try_bind_row("right", "RowRight")
	_try_bind_row("forward", "RowForward")
	_try_bind_row("backward", "RowBackward")
	_try_bind_row("jump", "RowJump")
	_try_bind_row("attack", "RowAttack")
	_try_bind_row("interact", "RowInteract")

func _try_bind_row(action: String, row: String) -> void:
	var bind_path := "Panel/VBox/%s/Bind" % row
	var action_path := "Panel/VBox/%s/Action" % row

	if has_node(bind_path):
		binds[action] = get_node(bind_path)
	if has_node(action_path):
		buttons[action] = get_node(action_path)

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
	for a in binds.keys():
		(binds[a] as Label).text = Keybinds.get_key_text(a)

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
