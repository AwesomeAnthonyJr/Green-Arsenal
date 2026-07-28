extends Resource
class_name SaveFile

@export var seed_types: Array[bool] = [
	true, #blaze
	true, #life
	false, #bounce
	false, #seeker
	false, #platform
	false, #propeller
	false #heavy
]
@export var max_hp: int = 3
@export var growth_charges: int = 1

###this is for like doors and stuff, depending on the rooms
@export var game_flags: Array[bool] = [
	false, #forest 1_NEW - strangler gate | 0
	false, #forest 2 - torch 1
	false, #forest 2 - torch 2
	false, #forest 2 - torch 3
	false, #forest 2 - strangler gate
	false, #forest 5 - strangler gate | 5
	false, #underground_entrance - torch 1
	false, #underground_entrance - torch 2
	false, #underground_2 - torch 1
	false, #underground_2 - torch 2
	false, #bounce_seed - button | 10
	false, #combo_puzzle_1 - strangler gate
	false, #bounce_seed - strangler gate
	false, #underground_3 - button
	false, #underground_3 - strangler gate
	false, #underground_4 - growth pickup | 15
	false, #underground_4 - health pickup
	false, #underground_4 - torch 1
	false, #underground_4 - torch 2
	false, #underground_5 - torch 1
	false, #underground_5 - torch 2 | 20
]
###this is mostly for the map screen to hide certain layers until its time
@export var farthest_floor: int = 2
###this is to set the player to load in different positions depending on their last save
@export var load_point: int = 4
