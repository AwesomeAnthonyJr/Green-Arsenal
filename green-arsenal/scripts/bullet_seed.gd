extends Bullet
#is a subclass of bullet
#as such, requires a timer, a racyast, and a shapecast as a child

func plant_seed():
	print("PLANTING A BULLET SEED!")

func hit_enemy(obj):
	print("HIT ", obj.name, " WITH A BULLET SEED!")
	super(obj)
	destroy_bullet()
