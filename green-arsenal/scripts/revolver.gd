extends Control

@onready var curr_seed = $InteractMenu/SeedCircle/Sprite2D2
@onready var prev_seed = $InteractMenu/SeedCircleW/Sprite2D2
@onready var next_seed = $InteractMenu/SeedCircleS/Sprite2D2
@onready var animation_tree = $AnimationTree

@onready var load_0 = $Sprite2D/Control/Loaded0
@onready var load_1 = $Sprite2D/Control/Loaded1
@onready var load_2 = $Sprite2D/Control/Loaded2
@onready var load_3 = $Sprite2D/Control/Loaded3
@onready var load_4 = $Sprite2D/Control/Loaded4
@onready var load_5 = $Sprite2D/Control/Loaded5

#TODO: read from save data instead! just assume we have all of them for now.
var seeds = [2, 3, 4, 5, 6, 7, 8, 9, 10]
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

func update_loaded_sprites(arr):
	load_0.frame = arr[0]
	load_1.frame = arr[1]
	load_2.frame = arr[2]
	load_3.frame = arr[3]
	load_4.frame = arr[4]
	load_5.frame = arr[5]

func pick_next():
	seed_select = select_increment(seed_select)
	update_sprites()

func pick_prev():
	seed_select = select_decrement(seed_select)
	update_sprites()

func get_selection():
	return seeds[seed_select]

func spin_to_bullet(n):
	var playback = animation_tree["parameters/playback"]
	match n:
		0:
			playback.travel("on_bullet_0 2")
		1:
			playback.travel("on_bullet_1 2")
		2:
			playback.travel("on_bullet_2 2")
		3:
			playback.travel("on_bullet_3 2")
		4:
			playback.travel("on_bullet_4 2")
		5:
			playback.travel("on_bullet_5 2")
func reloading_anim():
	animation_tree["parameters/playback"].travel("reloading 2")
