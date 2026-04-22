class_name GridRenderer
extends Control

signal cell_left_clicked(pos: Vector2i)
signal cell_right_clicked(pos: Vector2i)
signal cell_middle_clicked(pos: Vector2i)
signal cascade_finished

var _grid_data: GridData = null
var _cells: Dictionary = {}
var _reveal_queue: Array[Vector2i] = []
var _reveal_timer: float = 0.0
var _reveal_speed: float = 0.02
var _is_cascading: bool = false
var _cell_scene: PackedScene = preload("res://features/grid/grid_cell.tscn")

func set_grid_data(data: GridData) -> void:
	_grid_data = data
	_clear_cells()
	_build_cells()

func get_grid_data() -> GridData:
	return _grid_data

func update_cell(pos: Vector2i) -> void:
	if not _cells.has(pos):
		return
	var cell_node: Node = _cells[pos]
	var cell := _grid_data.get_cell(pos)
	match cell["state"]:
		GridData.CellState.REVEALED:
			cell_node.set_revealed(cell["adjacent_mines"])
		GridData.CellState.FLAGGED:
			cell_node.set_flagged(true)
		GridData.CellState.HIDDEN:
			cell_node.set_flagged(false)
		GridData.CellState.EXPLODED:
			cell_node.set_exploded()

func reveal_mines() -> void:
	for y in range(_grid_data.height):
		for x in range(_grid_data.width):
			var pos := Vector2i(x, y)
			if _grid_data.is_mine(pos) and _grid_data.is_hidden(pos):
				_cells[pos].set_mine_revealed()

func cascade_reveal(positions: Array[Vector2i]) -> void:
	_reveal_queue.clear()
	_sort_by_distance(positions)
	_reveal_queue = positions.duplicate()
	_is_cascading = true
	_reveal_timer = 0.0

func _sort_by_distance(positions: Array[Vector2i]) -> void:
	if positions.is_empty():
		return
	var center := positions[0]
	positions.sort_custom(func(a: Vector2i, b: Vector2i) -> bool:
		return center.distance_squared_to(a) < center.distance_squared_to(b)
	)

func _process(delta: float) -> void:
	if not _is_cascading:
		return
	_reveal_timer += delta
	while _reveal_timer >= _reveal_speed and _reveal_queue.size() > 0:
		_reveal_timer -= _reveal_speed
		var pos: Vector2i = _reveal_queue.pop_front()
		update_cell(pos)
		PlaceholderAudio.play_cascade()
	if _reveal_queue.is_empty():
		_is_cascading = false
		cascade_finished.emit()

func _clear_cells() -> void:
	for child in get_children():
		child.queue_free()
	_cells.clear()

func _build_cells() -> void:
	var cell_size := PlaceholderSprites.CELL_SIZE
	for y in range(_grid_data.height):
		for x in range(_grid_data.width):
			var pos := Vector2i(x, y)
			var cell_node := _cell_scene.instantiate()
			add_child(cell_node)
			cell_node.setup(pos)
			cell_node.position = Vector2(x * cell_size, y * cell_size)
			cell_node.cell_clicked.connect(_on_cell_left)
			cell_node.right_clicked.connect(_on_cell_right)
			cell_node.middle_clicked.connect(_on_cell_middle)
			_cells[pos] = cell_node
	custom_minimum_size = Vector2(_grid_data.width * cell_size, _grid_data.height * cell_size)
	size = custom_minimum_size

func _on_cell_left(pos: Vector2i, _button: int) -> void:
	cell_left_clicked.emit(pos)

func _on_cell_right(pos: Vector2i) -> void:
	cell_right_clicked.emit(pos)

func _on_cell_middle(pos: Vector2i) -> void:
	cell_middle_clicked.emit(pos)
