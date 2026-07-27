extends SaveOperator

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	SaveManager.read_save()
	if SaveManager.player_save.game_flags[0] == true:
		scene_index = operator_scenes.size() - 1
