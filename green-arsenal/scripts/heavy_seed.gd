extends Bullet
#is a subclass of bullet
#as such, requires a timer, a racyast, and a shapecast as a child

func plant_seed(point, norm, obj):
	var inst = Preloads.boulder_fruit.instantiate()
	obj.add_child(inst)
	if obj.is_in_group("propellable"):
		obj.get_parent().weights.append(inst)
		obj.get_parent().check_propellers()
		inst.platform = obj.get_parent()
	inst.global_position = point
	align_collision_rotation(norm, inst)
	
	player.active_plants.append(inst)
	player.check_special_plants()

func hit_enemy(obj):
	###TODO: make this unique for the heavy seed!!!
	if obj.has_method("take_damage"):
		obj.take_damage(1)
	#destroy_bullet()
