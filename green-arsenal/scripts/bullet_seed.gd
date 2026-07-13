extends Bullet
#is a subclass of bullet
#as such, requires a timer, a racyast, and a shapecast as a child

func plant_seed(point, norm):
	print("PLANTING A BULLET SEED!")
	print(point, "\n", norm)
	var inst = Preloads.bullet_sprout.instantiate()
	get_parent().add_child(inst)
	inst.global_position = point
	align_collision_rotation(norm, inst)

func hit_enemy(obj):
	print("HIT ", obj.name, " WITH A BULLET SEED!")
	if obj.has_method("take_damage"):
		print("Taking damage")
		obj.take_damage(1)
	destroy_bullet()
