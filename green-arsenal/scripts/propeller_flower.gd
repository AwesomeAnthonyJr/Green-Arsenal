extends Plant
class_name PropellerFlower

var prop_speed = 0.0
const MAX_SPEED = 15.0
@onready var anim = $AnimationPlayer
@onready var skeleton = $FancyModel/Skeleton3D

var direction: Vector3
var platform: PropellablePlatform

func _process(delta: float) -> void:
	if !dead:
		prop_speed += delta * 1.5
	else:
		prop_speed -= delta * 3
	prop_speed = min(MAX_SPEED, prop_speed)
	prop_speed = max(0, prop_speed)
	var new = skeleton.get_bone_pose(1).rotated(Vector3.UP, prop_speed * delta)
	skeleton.set_bone_pose(1, new) 

func grow():
	anim.play("grow")
	prop_speed = 0.0

func wither_self():
	dead = true
	if platform != null:
		direction = Vector3.ZERO
		platform.check_propellers()
	anim.play("die")
	await get_tree().create_timer(1.0).timeout
	destroy_self()
