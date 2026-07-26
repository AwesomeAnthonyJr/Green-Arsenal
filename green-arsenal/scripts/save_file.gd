extends Resource
class_name SaveFile

@export var seed_types: Array[bool] = [
	true,
	false,
	true,
	true,
	false,
	false,
	false
]
@export var max_hp: int = 3
@export var growth_charges: int = 1

###this is for like doors and stuff, depending on the rooms
@export var game_flags: Array[bool] = [
	true, #forest 1_NEW - strangler gate
	true, #forest 2 - torch 1
	true, #forest 2 - torch 2
	true, #forest 2 - torch 3
	true, #forest 2 - strangler gate
	true, #forest 5 - strangler gate
	true, #underground_entrance - torch 1
	true, #underground_entrance - torch 2
	false, #underground_2 - torch 1
	false, #underground_2 - torch 2
	false, #bounce_seed - button
	false, #combo_puzzle_1 - strangler gate
]
###this is mostly for the map screen to hide certain layers until its time
@export var farthest_floor: int = 2
