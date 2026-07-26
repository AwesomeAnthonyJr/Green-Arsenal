extends Resource
class_name SaveFile

@export var seed_types: Array[bool] = [
	false, #blaze
	false,
	false, #bounce
	false, #seeker
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
	false, #forest 2 - strangler gate
	false, #forest 5 - strangler gate
	false, #underground_entrance - torch 1
	false, #underground_entrance - torch 2
	false, #underground_2 - torch 1
	false, #underground_2 - torch 2
	false, #bounce_seed - button
	false, #combo_puzzle_1 - strangler gate
]
###this is mostly for the map screen to hide certain layers until its time
@export var farthest_floor: int = 2
