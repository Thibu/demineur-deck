extends Node

var _grid_data: GridData = null
var _game_node: Node = null

func setup(grid_data: GridData, game_node: Node) -> void:
	_grid_data = grid_data
	_game_node = game_node

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.screen_shake_requested.connect(_on_screen_shake)
	EventBus.hit_stop_requested.connect(_on_hit_stop)
	EventBus.grid_exploded.connect(_on_explosion)
	EventBus.grid_cleared.connect(_on_grid_cleared)

func _on_screen_shake(intensity: float, duration: float) -> void:
	var camera := _get_camera()
	if not camera:
		return
	var tween := get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	var steps := int(duration / 0.016)
	var orig_pos := camera.offset
	for i in range(steps):
		var offset := Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0) * intensity
		tween.tween_property(camera, "offset", orig_pos + offset, 0.008)
		tween.tween_property(camera, "offset", orig_pos, 0.008)
	tween.tween_property(camera, "offset", orig_pos, 0.01)

func _on_hit_stop(duration: float) -> void:
	get_tree().paused = true
	await get_tree().create_timer(duration, true, false, true).timeout
	get_tree().paused = false

func _on_explosion() -> void:
	EventBus.screen_shake_requested.emit(3.0, 0.4)
	EventBus.hit_stop_requested.emit(0.15)

func _on_grid_cleared() -> void:
	EventBus.screen_shake_requested.emit(1.0, 0.15)

func _get_camera() -> Camera2D:
	if _game_node:
		return _game_node.get_node_or_null("Camera2D")
	return null
