extends Node

signal grid_cell_revealed(pos: Vector2i)
signal grid_cell_flagged(pos: Vector2i)
signal grid_cell_unflagged(pos: Vector2i)
signal grid_generated(width: int, height: int, mine_count: int)
signal grid_cleared
signal grid_exploded

signal card_drawn(card_id: String)
signal card_played(card_id: String, target_pos: Vector2i)
signal card_discarded(card_id: String)
signal hand_refilled

signal concentration_changed(old_value: int, new_value: int)
signal intuitions_changed(old_value: int, new_value: int)
signal noise_changed(old_value: float, new_value: float)

signal run_started
signal run_ended(victory: bool)
signal node_entered(node_type: String)
signal encounter_completed

signal hp_changed(old_value: int, new_value: int)
signal gold_changed(old_value: int, new_value: int)

signal reward_offered(cards: Array)
signal relic_acquired(relic_id: String)

signal screen_shake_requested(intensity: float, duration: float)
signal hit_stop_requested(duration: float)

signal game_restart_requested
signal difficulty_selected(size: String)
