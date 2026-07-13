extends Bullet
#is a subclass of bullet
#as such, requires a timer, a racyast, and a shapecast as a child

func plant_seed(point, norm):
	print("PLANTING A BOUNCE SEED!")
	var inst = Preloads.spring_vine.instantiate()
	get_parent().add_child(inst)
	inst.global_position = point
	align_collision_rotation(norm, inst)
	
	player.active_plants.append(inst)
	player.check_special_plants()

func hit_enemy(obj):
	print("HIT ", obj.name, " WITH A BOUNCE SEED!")
	if obj.has_method("take_knockback"):
		obj.take_knockback(35.00 * -global_transform.basis.z)
	destroy_bullet()
