extends SaveOperator

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	label.text = SaveManager.player_settings.get_text("interact").to_upper()
	if SaveManager.player_save.seed_types[2] == true and SaveManager.player_save.seed_types[3] == true:
		scene_index = operator_scenes.size() - 1
