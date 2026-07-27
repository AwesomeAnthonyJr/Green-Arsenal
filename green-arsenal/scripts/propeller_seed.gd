extends Bullet
#is a subclass of bullet
#as such, requires a timer, a racyast, and a shapecast as a child

func plant_seed(point, norm, obj):
	#print("PLANTING A PROPELLER SEED!")
	var inst = Preloads.propeller_flower.instantiate()
	obj.add_child(inst)
	inst.direction = norm
	if obj.is_in_group("propellable"):
		obj.get_parent().propellers.append(inst)
		obj.get_parent().check_propellers()
		inst.platform = obj.get_parent()
	inst.global_position = point
	align_collision_rotation(norm, inst)
	
	inst.grow()
	player.active_plants.append(inst)
	player.check_special_plants()

func hit_enemy(obj):
	if obj.has_method("take_damage"):
		obj.take_damage(1)
	#destroy_bullet()
