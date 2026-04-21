extends Control

@onready var title_label: Label = $TitleLabel
@onready var start_button: Button = $StartButton
@onready var quit_button: Button = $QuitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_start_pressed() -> void:
	EventBus.run_started.emit()
	print("Hollow Grid — Run started (placeholder)")

func _on_quit_pressed() -> void:
	get_tree().quit()
