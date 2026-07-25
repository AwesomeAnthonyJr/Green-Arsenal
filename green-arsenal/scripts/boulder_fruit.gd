extends Plant
var platform: Node3D
var original_fruit: Node3D

@onready var skeleton = $FancyModel/Skeleton3D
@onready var anim = $AnimationPlayer

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

func grow():
	anim.play("grow")
	skeleton.set_bone_pose_rotation(12, Quaternion(Vector3.UP, 10000.0 * randf_range(-PI, PI)))

func wither_self():
	if platform != null:
		if platform is PropellablePlatform:
			platform.weights.erase(self)
			platform.check_propellers()
	destroy_self()
