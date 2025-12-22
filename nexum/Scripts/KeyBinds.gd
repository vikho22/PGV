extends Node

# Singleton (autoload) used to remap movement keys at runtime and persist them.
# Actions expected to exist in Project Settings > Input Map:
#   left, right, forward, backward, jump

const ACTIONS := ["left", "right", "forward", "backward", "jump"]
const CONFIG_PATH := "user://keybinds.cfg"
const SECTION := "keys"

# Copy of the original InputMap events (defaults) captured at boot.
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
	var err := cfg.load(CONFIG_PATH)
	if err != OK:
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
	# We only remap keyboard keys here.
	if not (event is InputEventKey):
		return

	# Remove previous keyboard bindings for that action (keep mouse/gamepad if any).
	for e in InputMap.action_get_events(action):
		if e is InputEventKey:
			InputMap.action_erase_event(action, e)

	InputMap.action_add_event(action, event)

func get_key_text(action: String) -> String:
	for e in InputMap.action_get_events(action):
		if e is InputEventKey:
			# Keycode -> readable name (W, A, Space, etc.)
			return OS.get_keycode_string(e.keycode)
	return "(sin tecla)"

func reset_to_defaults() -> void:
	# Restore defaults captured at boot.
	for action in ACTIONS:
		for e in InputMap.action_get_events(action):
			InputMap.action_erase_event(action, e)

		var arr: Array = _defaults.get(action, [])
		for e in arr:
			InputMap.action_add_event(action, e)

	_delete_saved_file()

func _dup_events(events: Array) -> Array:
	var out: Array = []
	for e in events:
		out.append(e.duplicate())
	return out

func _delete_saved_file() -> void:
	if FileAccess.file_exists(CONFIG_PATH):
		var abs_path := ProjectSettings.globalize_path(CONFIG_PATH)
		DirAccess.remove_absolute(abs_path)
