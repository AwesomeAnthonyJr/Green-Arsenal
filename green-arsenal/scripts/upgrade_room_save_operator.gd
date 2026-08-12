extends SaveOperator


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	label.text = SaveManager.player_settings.get_text("interact").to_upper()
	if SaveManager.player_save.game_flags[17] == true and SaveManager.player_save.game_flags[18] == true:
		scene_index = operator_scenes.size() - 1
