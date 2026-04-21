extends Node

enum GamePhase {
	MENU,
	RUN_MAP,
	GRID_PLAY,
	REWARD,
	EVENT,
	SHOP,
	BOSS,
	GAME_OVER,
	VICTORY,
}

var current_phase: GamePhase = GamePhase.MENU
var run_active: bool = false

func _ready() -> void:
	EventBus.run_started.connect(_on_run_started)
	EventBus.run_ended.connect(_on_run_ended)

func _on_run_started() -> void:
	run_active = true
	current_phase = GamePhase.RUN_MAP

func _on_run_ended(victory: bool) -> void:
	run_active = false
	current_phase = GamePhase.VICTORY if victory else GamePhase.GAME_OVER
