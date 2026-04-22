extends Node

var _grid_data: GridData = null
var _renderer: Control = null

enum GameMode {
	IDLE,
	PLAYING,
	WON,
	LOST,
}

var mode: GameMode = GameMode.IDLE
var timer_elapsed: float = 0.0
var timer_running: bool = false

signal game_won
signal game_lost
signal mines_changed(count: int)
signal timer_changed(seconds: float)

func setup(data: GridData, renderer: Control) -> void:
	_grid_data = data
	_renderer = renderer
	mode = GameMode.IDLE
	timer_elapsed = 0.0
	timer_running = false
	_mines_changed()

func handle_left_click(pos: Vector2i) -> void:
	if mode == GameMode.WON or mode == GameMode.LOST:
		return
	if not _grid_data.in_bounds(pos):
		return
	if _grid_data.is_flagged(pos):
		return
	if _grid_data.is_revealed(pos):
		return
	
	if not _grid_data.first_click_done:
		_start_first_click(pos)
		return
	
	if _grid_data.is_mine(pos):
		_trigger_mine(pos)
		return
	
	_reveal_at(pos)

func handle_right_click(pos: Vector2i) -> void:
	if mode == GameMode.WON or mode == GameMode.LOST:
		return
	if not _grid_data.in_bounds(pos):
		return
	if _grid_data.is_revealed(pos):
		return
	
	if _grid_data.is_flagged(pos):
		_grid_data.unflag(pos)
		_renderer.update_cell(pos)
		EventBus.grid_cell_unflagged.emit(pos)
		PlaceholderAudio.play_unflag()
	else:
		_grid_data.flag(pos)
		_renderer.update_cell(pos)
		EventBus.grid_cell_flagged.emit(pos)
		PlaceholderAudio.play_flag()
	_mines_changed()

func handle_middle_click(pos: Vector2i) -> void:
	if mode == GameMode.WON or mode == GameMode.LOST:
		return
	if not _grid_data.in_bounds(pos):
		return
	if not _grid_data.is_revealed(pos):
		return
	
	var adj := _grid_data.adjacent_mines(pos)
	if adj <= 0:
		return
	
	var neighbors := _grid_data.get_neighbors(pos)
	var flagged_count := 0
	for n in neighbors:
		if _grid_data.is_flagged(n):
			flagged_count += 1
	
	if flagged_count != adj:
		return
	
	for n in neighbors:
		if _grid_data.is_hidden(n):
			if _grid_data.is_mine(n):
				_trigger_mine(n)
				return
			_reveal_at(n)

func _start_first_click(pos: Vector2i) -> void:
	var new_data := GridGenerator.generate(
		_grid_data.width,
		_grid_data.height,
		_grid_data.mine_count,
		pos
	)
	new_data.mine_count = _grid_data.mine_count
	_grid_data = new_data
	_renderer.set_grid_data(_grid_data)
	
	mode = GameMode.PLAYING
	timer_running = true
	EventBus.grid_generated.emit(_grid_data.width, _grid_data.height, _grid_data.mine_count)
	
	_reveal_at(pos)

func _reveal_at(pos: Vector2i) -> void:
	var revealed_cells := _flood_reveal(pos)
	if revealed_cells.is_empty():
		PlaceholderAudio.play_reveal()
		return
	
	for rpos in revealed_cells:
		EventBus.grid_cell_revealed.emit(rpos)
	
	if revealed_cells.size() > 3:
		_renderer.cascade_reveal(revealed_cells)
		_renderer.cascade_finished.connect(_check_win, CONNECT_ONE_SHOT)
	else:
		for rpos in revealed_cells:
			_renderer.update_cell(rpos)
		PlaceholderAudio.play_reveal()
		_check_win()

func _check_win() -> void:
	if _grid_data.is_won():
		_on_win()

func _flood_reveal(start: Vector2i) -> Array[Vector2i]:
	var revealed: Array[Vector2i] = []
	var stack: Array[Vector2i] = [start]
	while stack.size() > 0:
		var pos: Vector2i = stack.pop_back()
		if not _grid_data.in_bounds(pos):
			continue
		if not _grid_data.is_hidden(pos):
			continue
		_grid_data.reveal(pos)
		revealed.append(pos)
		if _grid_data.adjacent_mines(pos) == 0:
			for n in _grid_data.get_neighbors(pos):
				if _grid_data.is_hidden(n):
					stack.append(n)
	return revealed

func _trigger_mine(pos: Vector2i) -> void:
	mode = GameMode.LOST
	timer_running = false
	_grid_data.explode(pos)
	_renderer.update_cell(pos)
	PlaceholderAudio.play_explosion()
	EventBus.grid_exploded.emit()
	_renderer.reveal_mines()
	game_lost.emit()

func _on_win() -> void:
	mode = GameMode.WON
	timer_running = false
	PlaceholderAudio.play_victory()
	EventBus.grid_cleared.emit()
	game_won.emit()

func _mines_changed() -> void:
	var remaining := _grid_data.mine_count - _grid_data.flag_count
	mines_changed.emit(remaining)

func _process(delta: float) -> void:
	if timer_running:
		timer_elapsed += delta
		timer_changed.emit(timer_elapsed)

func get_grid_data() -> GridData:
	return _grid_data
