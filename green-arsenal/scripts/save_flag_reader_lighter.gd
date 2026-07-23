extends Node

@export var flag_index: int
@export var torch: Torch

func _ready() -> void:
	if SaveManager.player_save.game_flags[flag_index]:
		torch.light_torch()
