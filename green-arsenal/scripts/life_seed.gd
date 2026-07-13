extends Bullet
#is a subclass of bullet
#as such, requires a timer, a racyast, and a shapecast as a child

func plant_seed():
	print("PLANTING A LIFE SEED!")

func hit_enemy(obj):
	print("HIT ", obj.name, " WITH A LIFE SEED!")
	if obj.has_method("take_damage"):
		print("Healing damage")
		obj.take_damage(-1)
	destroy_bullet()
