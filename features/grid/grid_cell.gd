extends Control

signal cell_clicked(pos: Vector2i, button: int)
signal right_clicked(pos: Vector2i)
signal middle_clicked(pos: Vector2i)

var grid_pos: Vector2i
var _state: int = GridData.CellState.HIDDEN
var _adjacent_mines: int = 0
var _is_mine: bool = false
var _reveal_tween: Tween = null

@onready var _sprite: TextureRect = $Sprite

func setup(pos: Vector2i) -> void:
	grid_pos = pos
	custom_minimum_size = Vector2(PlaceholderSprites.CELL_SIZE, PlaceholderSprites.CELL_SIZE)
	size = custom_minimum_size
	_refresh_visual()

func set_hidden() -> void:
	_state = GridData.CellState.HIDDEN
	_refresh_visual()

func set_revealed(adj: int) -> void:
	_state = GridData.CellState.REVEALED
	_adjacent_mines = adj
	_animate_reveal()

func set_flagged(flagged: bool) -> void:
	_state = GridData.CellState.FLAGGED if flagged else GridData.CellState.HIDDEN
	_refresh_visual()

func set_mine_revealed() -> void:
	_is_mine = true
	_state = GridData.CellState.REVEALED
	_sprite.texture = PlaceholderSprites.cell_mine

func set_exploded() -> void:
	_state = GridData.CellState.EXPLODED
	_sprite.texture = PlaceholderSprites.cell_exploded
	modulate = Color.WHITE

func get_cell_state() -> int:
	return _state

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			match event.button_index:
				MOUSE_BUTTON_LEFT:
					cell_clicked.emit(grid_pos, MOUSE_BUTTON_LEFT)
				MOUSE_BUTTON_RIGHT:
					right_clicked.emit(grid_pos)
				MOUSE_BUTTON_MIDDLE:
					middle_clicked.emit(grid_pos)
			accept_event()

func _refresh_visual() -> void:
	match _state:
		GridData.CellState.HIDDEN:
			_sprite.texture = PlaceholderSprites.cell_hidden
		GridData.CellState.FLAGGED:
			_sprite.texture = PlaceholderSprites.cell_flagged
		GridData.CellState.REVEALED:
			if _is_mine:
				_sprite.texture = PlaceholderSprites.cell_mine
			elif _adjacent_mines > 0:
				var idx := _adjacent_mines - 1
				if idx < PlaceholderSprites.number_textures.size():
					_sprite.texture = PlaceholderSprites.number_textures[idx]
				else:
					_sprite.texture = PlaceholderSprites.cell_revealed
			else:
				_sprite.texture = PlaceholderSprites.cell_revealed
		GridData.CellState.EXPLODED:
			_sprite.texture = PlaceholderSprites.cell_exploded

func _animate_reveal() -> void:
	if _reveal_tween and _reveal_tween.is_valid():
		_reveal_tween.kill()
	modulate = Color(1.3, 1.3, 1.5, 1.0)
	_refresh_visual()
	_reveal_tween = create_tween()
	_reveal_tween.tween_property(self, "modulate", Color.WHITE, 0.12)
