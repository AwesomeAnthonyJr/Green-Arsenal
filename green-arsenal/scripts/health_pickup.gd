extends Node3D

@export var flag_index: int

func interact_pickup(obj):
	if obj is Player:
		SaveManager.player_save.max_hp += 1
		SaveManager.player_save.game_flags[flag_index] = true
		obj.max_1()
		queue_free()
