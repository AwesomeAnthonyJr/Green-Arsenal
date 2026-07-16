extends Plant
var platform: Node3D
var original_fruit: Node3D

func detatch(obj):
	original_fruit = obj
	if platform != null:
		if platform is PropellablePlatform:
			platform.weights.erase(self)
			platform.check_propellers()

func destroy_self():
	if original_fruit != null and is_instance_valid(original_fruit):
		original_fruit.queue_free()
	queue_free()

func wither_self():
	if platform != null:
		if platform is PropellablePlatform:
			platform.weights.erase(self)
			platform.check_propellers()
	destroy_self()
