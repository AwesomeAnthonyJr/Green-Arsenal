extends Node

@export var flag_index: int

func set_flag_true():
	SaveManager.player_save.game_flags[flag_index] = true
