extends Bullet
#is a subclass of bullet
#as such, requires a timer, a racyast, and a shapecast as a child

func plant_seed(point, norm, obj):
	#print("PLANTING A BOUNCE SEED!")
	var inst = Preloads.seeker_flower.instantiate()
	obj.add_child(inst)
	inst.global_position = point
	align_collision_rotation(norm, inst)
	
	inst.grow()
	player.active_plants.append(inst)
	player.check_special_plants()

func hit_enemy(obj):
	#print("HIT ", obj.name, " WITH A BOUNCE SEED!")
	if obj.has_method("take_damage"):
		obj.take_damage(1)
	destroy_bullet()
