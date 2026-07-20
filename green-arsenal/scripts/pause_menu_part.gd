extends CanvasLayer

@onready var anim_tree = $AnimationTree
@onready var selector = $Selector

func not_on_seed_anymore():
	var display = $Control/Control/PlantDisplayer/SubViewport/Plants
	display.hide_all()

func update_status_plants(b: bool, n: int):
	var display = $Control/Control/PlantDisplayer/SubViewport/Plants
	display.hide_all()
	if b:
		display.show_plant(n-2)

func update_status_seeds():
	for i in Constants.seed_order.size():
		update_status_seed(SaveManager.get_seed_types()[i], Constants.seed_order[i])

func update_status_seed(b: bool, n: int):
	var seed: Sprite2D = null
	match n:
		2:
			seed = $Control/SeedBlaze
		3:
			seed = $Control/SeedBounce
		4:
			seed = $Control/SeedLife
		5:
			seed = $Control/SeedPlatform
		6:
			seed = $Control/SeedSeeker
		7:
			seed = $Control/SeedPropeller
		8:
			seed = $Control/SeedWeight
	if b:
		seed.modulate = Color(1.0, 1.0, 1.0, 1.0)
		seed.z_index = 1
	else:
		seed.modulate = Color(0.0, 0.0, 0.0, 1.0)
		seed.z_index = 0
