extends Bullet
#is a subclass of bullet
#as such, requires a timer, a racyast, and a shapecast as a child

func plant_seed(point, norm, obj):
	print("PLANTING A PLATFORM SEED!")
	var inst = Preloads.platform_lilypad.instantiate()
	obj.add_child(inst)
	inst.global_position = point
	if in_water:
		inst.seek_surface()
	else:
		print("PLEASE DO DEFAULT HEIGHT?")
		inst.default_height()
	inst.default_push = norm
	inst.own_soil = obj
	inst.platform.global_transform.origin = point
	#align_collision_rotation(norm, inst)
	
	player.active_plants.append(inst)
	player.check_special_plants()

func hit_enemy(obj):
	print("HIT ", obj.name, " WITH A PLATFORM SEED!")
	if obj.has_method("wear_shield"):
		obj.wear_shield()
	destroy_bullet()
