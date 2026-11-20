extends Control

## The Pursued - Startup Splash Screen
## The final logo image will be added by the user later.

@export var splash_duration_seconds: float = 2.0
@export var resource_setup_scene_path: String = "res://scenes/resource_setup.tscn"

var elapsed_seconds: float = 0.0
var transition_started: bool = false

@onready var startup_progress: ProgressBar = (
	get_node_or_null("Content/StartupProgress") as ProgressBar
)


func _ready() -> void:
	if startup_progress:
		startup_progress.min_value = 0.0
		startup_progress.max_value = 100.0
		startup_progress.value = 0.0


func _process(delta: float) -> void:
	if transition_started:
		return

	elapsed_seconds += delta

	var duration: float = maxf(splash_duration_seconds, 0.1)
	var progress: float = clampf(elapsed_seconds / duration, 0.0, 1.0)

	if startup_progress:
		startup_progress.value = progress * 100.0

	if progress >= 1.0:
		_open_resource_setup()


func _open_resource_setup() -> void:
	if transition_started:
		return

	if not ResourceLoader.exists(resource_setup_scene_path):
		push_warning(
			"Startup is waiting for the resource setup scene: "
			+ resource_setup_scene_path
		)
		return

	transition_started = true

	var error: Error = get_tree().change_scene_to_file(
		resource_setup_scene_path
	)

	if error != OK:
		transition_started = false
		push_error(
			"Could not open the resource setup scene. Error: "
			+ str(error)
		)
