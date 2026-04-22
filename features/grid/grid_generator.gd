class_name GridGenerator

const MAX_SOLVE_ATTEMPTS := 100

static func generate(w: int, h: int, mines: int, safe_pos: Vector2i) -> GridData:
	for attempt in range(MAX_SOLVE_ATTEMPTS):
		var grid := _create_grid(w, h, mines, safe_pos)
		if GridSolver.is_solvable(grid, safe_pos):
			return grid
	push_warning("GridGenerator: Could not generate solvable grid after %d attempts, using last attempt." % MAX_SOLVE_ATTEMPTS)
	return _create_grid(w, h, mines, safe_pos)

static func _create_grid(w: int, h: int, mines: int, safe_pos: Vector2i) -> GridData:
	var grid := GridData.new(w, h)
	grid.mine_count = mines
	
	var safe_positions: Dictionary = {}
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var sp := Vector2i(safe_pos.x + dx, safe_pos.y + dy)
			safe_positions[sp] = true
	
	var candidates: Array[Vector2i] = []
	for y in range(h):
		for x in range(w):
			var pos := Vector2i(x, y)
			if not safe_positions.has(pos):
				candidates.append(pos)
	
	candidates.shuffle()
	var actual_mines := mini(mines, candidates.size())
	for i in range(actual_mines):
		grid.set_mine(candidates[i], true)
	
	grid.compute_adjacent_counts()
	grid.first_click_done = true
	return grid
