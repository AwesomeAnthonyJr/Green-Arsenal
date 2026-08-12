extends Node3D

@export var flag_index: int

func interact_pickup(obj):
	if obj is Player:
		SaveManager.player_save.growth_charges += 1
		#print(SaveManager.player_save.growth_charges)
		SaveManager.player_save.game_flags[flag_index] = true
		obj.check_special_plants()
		SoundManager.play_orb()
		queue_free()
