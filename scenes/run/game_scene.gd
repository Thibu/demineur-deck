extends Control

enum Difficulty {
	SMALL,
	MEDIUM,
	LARGE,
}

const SIZES := {
	Difficulty.SMALL: {"width": 8, "height": 8, "mines": 10},
	Difficulty.MEDIUM: {"width": 16, "height": 16, "mines": 40},
	Difficulty.LARGE: {"width": 24, "height": 16, "mines": 70},
}

var _difficulty: Difficulty = Difficulty.SMALL
var _grid_actions: Node = null
var _grid_effects: Node = null

@onready var _renderer: GridRenderer = $GameViewport/SubViewport/GridRenderer
@onready var _mine_label: Label = $UI/MineLabel
@onready var _timer_label: Label = $UI/TimerLabel
@onready var _restart_btn: Button = $UI/RestartBtn
@onready var _menu_btn: Button = $UI/MenuBtn
@onready var _difficulty_btns: HBoxContainer = $UI/DifficultyBtns
@onready var _btn_small: Button = $UI/DifficultyBtns/BtnSmall
@onready var _btn_medium: Button = $UI/DifficultyBtns/BtnMedium
@onready var _btn_large: Button = $UI/DifficultyBtns/BtnLarge
@onready var _status_label: Label = $UI/StatusLabel

func _ready() -> void:
	_restart_btn.pressed.connect(_on_restart)
	_menu_btn.pressed.connect(_on_menu)
	_btn_small.pressed.connect(func(): _set_difficulty(Difficulty.SMALL))
	_btn_medium.pressed.connect(func(): _set_difficulty(Difficulty.MEDIUM))
	_btn_large.pressed.connect(func(): _set_difficulty(Difficulty.LARGE))
	_grid_actions = $GridActions
	_grid_effects = $GridEffects
	_renderer.cell_left_clicked.connect(_grid_actions.handle_left_click)
	_renderer.cell_right_clicked.connect(_grid_actions.handle_right_click)
	_renderer.cell_middle_clicked.connect(_grid_actions.handle_middle_click)
	_grid_actions.mines_changed.connect(_on_mines_changed)
	_grid_actions.timer_changed.connect(_on_timer_changed)
	_grid_actions.game_won.connect(_on_game_won)
	_grid_actions.game_lost.connect(_on_game_lost)
	_start_game()

func _start_game() -> void:
	var s: Dictionary = SIZES[_difficulty]
	var data := GridData.new(s["width"], s["height"])
	data.mine_count = s["mines"]
	_renderer.set_grid_data(data)
	_grid_actions.setup(data, _renderer)
	_grid_effects.setup(data, self, _renderer)
	_mine_label.text = "Mines: %d" % s["mines"]
	_timer_label.text = "Time: 0.0"
	_status_label.text = ""
	_layout_grid()

const _GAME_W: int = 480
const _GAME_H: int = 270

func _layout_grid() -> void:
	var s: Dictionary = SIZES[_difficulty]
	var cell_size := PlaceholderSprites.CELL_SIZE
	var grid_w: int = int(s["width"]) * cell_size
	var grid_h: int = int(s["height"]) * cell_size
	_renderer.scale = Vector2.ONE
	_renderer.position = Vector2(
		(_GAME_W - grid_w) / 2.0,
		(_GAME_H - grid_h) / 2.0
	)

func _on_restart() -> void:
	_start_game()

func _on_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")

func _set_difficulty(d: Difficulty) -> void:
	_difficulty = d
	_start_game()

func _on_mines_changed(count: int) -> void:
	_mine_label.text = "Mines: %d" % count

func _on_timer_changed(seconds: float) -> void:
	_timer_label.text = "Time: %.1f" % seconds

func _on_game_won() -> void:
	_status_label.text = "CLEARED!"
	_status_label.add_theme_color_override("font_color", Color(0.471, 0.816, 0.502))

func _on_game_lost() -> void:
	_status_label.text = "DETONATED"
	_status_label.add_theme_color_override("font_color", Color(0.847, 0.388, 0.318))

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_R:
			_on_restart()
			accept_event()
		elif event.pressed and event.keycode == KEY_ESCAPE:
			_on_menu()
			accept_event()
