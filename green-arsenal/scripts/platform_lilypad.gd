extends Plant

@onready var raycast = $RayCast3D

func seek_surface():
	print("SEEK SURFACE")
	raycast.force_raycast_update()
	if raycast.is_colliding():
		print(raycast.get_collider().name)
		if raycast.get_collider().is_in_group("fresh_water"):
			print(raycast.get_collision_point().distance_to(global_position))
			global_position = raycast.get_collision_point()
			
