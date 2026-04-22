class_name GridData

enum CellState {
	HIDDEN,
	REVEALED,
	FLAGGED,
	EXPLODED,
}

var width: int
var height: int
var mine_count: int
var cells: Array = []
var first_click_done: bool = false
var flag_count: int = 0
var revealed_count: int = 0

func _init(w: int, h: int) -> void:
	width = w
	height = h
	mine_count = 0
	flag_count = 0
	revealed_count = 0
	cells.clear()
	for y in range(height):
		var row := []
		for x in range(width):
			row.append({
				"is_mine": false,
				"adjacent_mines": 0,
				"state": CellState.HIDDEN,
			})
		cells.append(row)

func in_bounds(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < width and pos.y >= 0 and pos.y < height

func get_cell(pos: Vector2i) -> Dictionary:
	return cells[pos.y][pos.x]

func is_mine(pos: Vector2i) -> bool:
	return get_cell(pos)["is_mine"]

func is_revealed(pos: Vector2i) -> bool:
	return get_cell(pos)["state"] == CellState.REVEALED

func is_hidden(pos: Vector2i) -> bool:
	return get_cell(pos)["state"] == CellState.HIDDEN

func is_flagged(pos: Vector2i) -> bool:
	return get_cell(pos)["state"] == CellState.FLAGGED

func adjacent_mines(pos: Vector2i) -> int:
	return get_cell(pos)["adjacent_mines"]

func get_neighbors(pos: Vector2i) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			if dx == 0 and dy == 0:
				continue
			var n := Vector2i(pos.x + dx, pos.y + dy)
			if in_bounds(n):
				result.append(n)
	return result

func set_mine(pos: Vector2i, value: bool) -> void:
	get_cell(pos)["is_mine"] = value

func compute_adjacent_counts() -> void:
	for y in range(height):
		for x in range(width):
			var pos := Vector2i(x, y)
			if is_mine(pos):
				get_cell(pos)["adjacent_mines"] = -1
				continue
			var count := 0
			for n in get_neighbors(pos):
				if is_mine(n):
					count += 1
			get_cell(pos)["adjacent_mines"] = count

func reveal(pos: Vector2i) -> void:
	var cell := get_cell(pos)
	if cell["state"] != CellState.HIDDEN:
		return
	cell["state"] = CellState.REVEALED
	revealed_count += 1

func flag(pos: Vector2i) -> void:
	var cell := get_cell(pos)
	if cell["state"] != CellState.HIDDEN:
		return
	cell["state"] = CellState.FLAGGED
	flag_count += 1

func unflag(pos: Vector2i) -> void:
	var cell := get_cell(pos)
	if cell["state"] != CellState.FLAGGED:
		return
	cell["state"] = CellState.HIDDEN
	flag_count -= 1

func explode(pos: Vector2i) -> void:
	var cell := get_cell(pos)
	cell["state"] = CellState.EXPLODED

func total_cells() -> int:
	return width * height

func safe_cells() -> int:
	return total_cells() - mine_count

func is_won() -> bool:
	return revealed_count == safe_cells()

func all_mines_flagged_or_exploded() -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	for y in range(height):
		for x in range(width):
			var pos := Vector2i(x, y)
			if is_mine(pos):
				result.append(pos)
	return result
