extends Node2D

@onready var anim_tree = $AnimationTree

func _ready() -> void:
	#anim_tree["parameters/playback"].travel("second_position")
	pass

func travel_first_position():
	anim_tree["parameters/playback"].travel("first_position")

func travel_second_position():
	anim_tree["parameters/playback"].travel("second_position")

func travel_third_position():
	anim_tree["parameters/playback"].travel("third_position")

func travel_fourth_position():
	anim_tree["parameters/playback"].travel("fourth_position")

func travel_fifth_position():
	anim_tree["parameters/playback"].travel("fifth_position")

func travel_sixth_position():
	anim_tree["parameters/playback"].travel("sixth_position")

func travel_shrunk_position():
	anim_tree["parameters/playback"].travel("shrunk_position")

func travel_expanded_position():
	anim_tree["parameters/playback"].travel("expanded_position")
