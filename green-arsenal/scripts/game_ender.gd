extends Node3D

func end_the_game(obj):
	if obj is Player:
		get_tree().quit()
