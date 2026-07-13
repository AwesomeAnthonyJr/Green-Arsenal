extends Control

@onready var curr_seed = $InteractMenu/SeedCircle/Sprite2D2
@onready var prev_seed = $InteractMenu/SeedCircleW/Sprite2D2
@onready var next_seed = $InteractMenu/SeedCircleS/Sprite2D2

#TODO: read from save data instead! just assume we have all of them for now.
var seeds = [2, 3, 4, 5, 6]
var seed_select = 0

func select_increment(n):
	var temp = n + 1
	if temp >= seeds.size():
		temp = 0
	return temp

func select_decrement(n):
	var temp = n - 1
	if temp < 0:
		temp = seeds.size() - 1
	return temp

func update_sprites():
	curr_seed.frame = seeds[seed_select]
	prev_seed.frame = seeds[select_decrement(seed_select)]
	next_seed.frame = seeds[select_increment(seed_select)]

func pick_next():
	seed_select = select_increment(seed_select)
	update_sprites()

func pick_prev():
	seed_select = select_decrement(seed_select)
	update_sprites()

func get_selection():
	return seeds[seed_select]
