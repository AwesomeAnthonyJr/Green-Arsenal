extends Resource
class_name SaveFile

@export var seed_types: Array[bool] = [
	false,
	false,
	false,
	false,
	false,
	false,
	false
]
@export var max_hp: int = 3
@export var growth_charges: int = 1

###this is for like doors and stuff, depending on the rooms
@export var game_flags: Array[bool] = [
	false, #forest 1_NEW - strangler gate
	false, #forest 2 - torch 1
	false, #forest 2 - torch 2
	false, #forest 2 - torch 3
]
###this is mostly for the map screen to hide certain layers until its time
@export var farthest_floor: int = 2
