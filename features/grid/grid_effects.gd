extends Node

var _grid_data: GridData = null
var _game_node: Node = null
var _shake_target: Control = null
var _rumble_intensity: float = 0.0
var _rumble_origin: Vector2 = Vector2.ZERO

func setup(grid_data: GridData, game_node: Node, shake_target: Control) -> void:
	_grid_data = grid_data
	_game_node = game_node
	if _shake_target:
		var old: GridRenderer = _shake_target as GridRenderer
		if old and old.cascade_cell_revealed.is_connected(_on_cascade_cell):
			old.cascade_cell_revealed.disconnect(_on_cascade_cell)
	_shake_target = shake_target
	_rumble_intensity = 0.0
	var renderer: GridRenderer = _shake_target as GridRenderer
	if renderer:
		renderer.cascade_cell_revealed.connect(_on_cascade_cell)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	EventBus.screen_shake_requested.connect(_on_screen_shake)
	EventBus.hit_stop_requested.connect(_on_hit_stop)
	EventBus.grid_exploded.connect(_on_explosion)
	EventBus.grid_cleared.connect(_on_grid_cleared)

func _process(delta: float) -> void:
	if not _shake_target or _rumble_intensity < 0.05:
		if _shake_target and _rumble_intensity > 0.0:
			_shake_target.position = _rumble_origin
			_rumble_intensity = 0.0
		return
	var offset := Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _rumble_intensity
	_shake_target.position = _rumble_origin + offset
	_rumble_intensity = lerpf(_rumble_intensity, 0.0, delta * 5.0)

func _on_cascade_cell(count: int, total: int) -> void:
	if count == 1:
		_rumble_origin = _shake_target.position
	_rumble_intensity = clampf(float(count) * 0.07, 0.3, 2.5)

func _on_screen_shake(intensity: float, duration: float) -> void:
	if not _shake_target:
		return
	var tween := get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	var steps := int(duration / 0.016)
	var orig_pos: Vector2 = _shake_target.position
	for i in range(steps):
		var offset := Vector2(randf() * 2.0 - 1.0, randf() * 2.0 - 1.0) * intensity
		tween.tween_property(_shake_target, "position", orig_pos + offset, 0.008)
		tween.tween_property(_shake_target, "position", orig_pos, 0.008)
	tween.tween_property(_shake_target, "position", orig_pos, 0.01)

func _on_hit_stop(duration: float) -> void:
	get_tree().paused = true
	await get_tree().create_timer(duration, true, false, true).timeout
	get_tree().paused = false

func _on_explosion() -> void:
	EventBus.screen_shake_requested.emit(3.0, 0.4)
	EventBus.hit_stop_requested.emit(0.15)

func _on_grid_cleared() -> void:
	EventBus.screen_shake_requested.emit(1.0, 0.15)

