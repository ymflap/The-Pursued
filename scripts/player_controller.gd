extends Node3D

## The Pursued - Human Player Prototype
## Compatible with the current Node3D player in main.tscn.
## Temporary movement only; physics collisions will be added later.

@export var walk_speed: float = 4.0
@export var sprint_speed: float = 6.0
@export var turn_speed: float = 10.0
@export var movement_enabled: bool = true

var body_mesh: Node3D
var body_base_y: float = 1.0
var walk_time: float = 0.0


func _ready() -> void:
	body_mesh = get_node_or_null("Body") as Node3D

	if body_mesh:
		body_base_y = body_mesh.position.y

	_setup_input_actions()


func _process(delta: float) -> void:
	if not movement_enabled:
		return

	var input_vector := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)

	var direction := Vector3(
		input_vector.x,
		0.0,
		input_vector.y
	)

	if direction.length_squared() > 1.0:
		direction = direction.normalized()

	var current_speed := walk_speed
	if Input.is_action_pressed("sprint"):
		current_speed = sprint_speed

	if direction.length_squared() > 0.001:
		position += direction * current_speed * delta

		var target_angle := atan2(direction.x, direction.z)
		rotation.y = lerp_angle(
			rotation.y,
			target_angle,
			clampf(turn_speed * delta, 0.0, 1.0)
		)

		walk_time += delta * current_speed

		if body_mesh:
			body_mesh.position.y = body_base_y + absf(
				sin(walk_time * 2.0)
			) * 0.045
	else:
		if body_mesh:
			body_mesh.position.y = move_toward(
				body_mesh.position.y,
				body_base_y,
				0.15 * delta
			)


func _setup_input_actions() -> void:
	_add_key_action("move_forward", KEY_W)
	_add_key_action("move_back", KEY_S)
	_add_key_action("move_left", KEY_A)
	_add_key_action("move_right", KEY_D)
	_add_key_action("sprint", KEY_SHIFT)


func _add_key_action(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	var key_event := InputEventKey.new()
	key_event.physical_keycode = keycode

	var events := InputMap.action_get_events(action_name)
	for event in events:
		if (
			event is InputEventKey
			and event.physical_keycode == keycode
		):
			return

	InputMap.action_add_event(action_name, key_event)
