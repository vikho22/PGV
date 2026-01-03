extends Node

# Singleton (autoload) used to remap keys at runtime and persist them.
# Actions expected to exist in Project Settings > Input Map:
# left, right, forward, backward, jump, attack, interact

const ACTIONS := ["left", "right", "forward", "backward", "jump", "attack", "interact"]
const CONFIG_PATH := "user://keybinds.cfg"
const SECTION := "keys"

# Defaults típicos (solo teclado). Attack lo dejas en mouse, por eso no va aquí.
const DEFAULT_KEYS := {
	"left": KEY_A,
	"right": KEY_D,
	"forward": KEY_W,
	"backward": KEY_S,
	"jump": KEY_SPACE,
	"interact": KEY_E,
}

# Copy of the original InputMap events (captured at boot) in case you ever need them
var _defaults: Dictionary = {}

func _ready() -> void:
	_capture_defaults()
	apply_saved_binds()

func _capture_defaults() -> void:
	_defaults.clear()
	for action in ACTIONS:
		if not InputMap.has_action(action):
			InputMap.add_action(action)
		_defaults[action] = _dup_events(InputMap.action_get_events(action))

func apply_saved_binds() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CONFIG_PATH) != OK:
		return

	for action in ACTIONS:
		var code: int = int(cfg.get_value(SECTION, action, 0))
		if code == 0:
			continue

		var ev := InputEventKey.new()
		ev.keycode = code
		set_key_for_action(action, ev)

func save_current_binds() -> void:
	var cfg := ConfigFile.new()

	for action in ACTIONS:
		var code := 0
		for e in InputMap.action_get_events(action):
			if e is InputEventKey:
				code = e.keycode
				break
		cfg.set_value(SECTION, action, code)

	cfg.save(CONFIG_PATH)

func set_key_for_action(action: String, event: InputEvent) -> void:
	# Only remap keyboard keys
	if not (event is InputEventKey):
		return

	# Remove previous keyboard bindings for that action (keep mouse/gamepad if any).
	for e in InputMap.action_get_events(action):
		if e is InputEventKey:
			InputMap.action_erase_event(action, e)

	InputMap.action_add_event(action, event)

func get_key_text(action: String) -> String:
	# Show the first keyboard key assigned (if any)
	for e in InputMap.action_get_events(action):
		if e is InputEventKey:
			return OS.get_keycode_string(e.keycode)

	# If no keyboard key, show Mouse Left only for attack
	if action == "attack":
		return "Mouse Left"

	return "(sin tecla)"

func reset_to_defaults() -> void:
	# Force common videogame defaults (WASD, Space, E)
	# We only erase keyboard events, so mouse/gamepad bindings remain (attack keeps Mouse Left).
	for action in ACTIONS:
		for e in InputMap.action_get_events(action):
			if e is InputEventKey:
				InputMap.action_erase_event(action, e)

		# Apply default keyboard key if defined
		if DEFAULT_KEYS.has(action):
			var ev := InputEventKey.new()
			ev.keycode = int(DEFAULT_KEYS[action])
			InputMap.action_add_event(action, ev)

	# Persist these defaults
	save_current_binds()

func _dup_events(events: Array) -> Array:
	var out: Array = []
	for e in events:
		out.append(e.duplicate())
	return out

func _delete_saved_file() -> void:
	if FileAccess.file_exists(CONFIG_PATH):
		var abs_path := ProjectSettings.globalize_path(CONFIG_PATH)
		DirAccess.remove_absolute(abs_path)
