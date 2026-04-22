class_name GridSolver

static func is_solvable(grid: GridData, first_click: Vector2i) -> bool:
	var sim_grid := _clone_grid(grid)
	_reveal_cell(sim_grid, first_click)
	
	var max_iterations := grid.width * grid.height * 4
	for _iter in range(max_iterations):
		var progress := false
		for y in range(sim_grid.height):
			for x in range(sim_grid.width):
				var pos := Vector2i(x, y)
				if not sim_grid.is_revealed(pos):
					continue
				var adj := sim_grid.adjacent_mines(pos)
				if adj <= 0:
					continue
				var neighbors := sim_grid.get_neighbors(pos)
				var hidden_count := 0
				var flagged_count := 0
				var hidden_cells: Array[Vector2i] = []
				for n in neighbors:
					if sim_grid.is_hidden(n):
						hidden_count += 1
						hidden_cells.append(n)
					elif sim_grid.is_flagged(n):
						flagged_count += 1
				
				if hidden_count == 0:
					continue
				
				if flagged_count == adj:
					for n in hidden_cells:
						_reveal_cell(sim_grid, n)
						progress = true
				elif flagged_count + hidden_count == adj:
					for n in hidden_cells:
						sim_grid.flag(n)
						progress = true
		
		if not progress:
			break
	
	return sim_grid.revealed_count == sim_grid.safe_cells()

static func _reveal_cell(grid: GridData, pos: Vector2i) -> void:
	if not grid.in_bounds(pos):
		return
	if not grid.is_hidden(pos):
		return
	grid.reveal(pos)
	if grid.adjacent_mines(pos) == 0:
		for n in grid.get_neighbors(pos):
			_reveal_cell(grid, n)

static func _clone_grid(grid: GridData) -> GridData:
	var clone := GridData.new(grid.width, grid.height)
	clone.mine_count = grid.mine_count
	clone.first_click_done = grid.first_click_done
	for y in range(grid.height):
		for x in range(grid.width):
			var src := grid.get_cell(Vector2i(x, y))
			var dst := clone.get_cell(Vector2i(x, y))
			dst["is_mine"] = src["is_mine"]
			dst["adjacent_mines"] = src["adjacent_mines"]
			dst["state"] = GridData.CellState.HIDDEN
	return clone
