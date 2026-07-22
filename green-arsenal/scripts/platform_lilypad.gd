extends Plant
class_name PlatformLilypad

@onready var raycast = $RayCast3D
@onready var platform = $AnimatableBody3D
@onready var plat_collider = $AnimatableBody3D/CollisionShape3D
@onready var avoidance_area = $AnimatableBody3D/Area3D
@onready var bone_attatchment = $FancyModel/Skeleton3D/BoneAttachment3D
@onready var anim = $AnimationPlayer
@onready var skeleton = $FancyModel/Skeleton3D

var own_soil: Node3D
var pos_offset = Vector3(0, 10.0, -1.0)
var default_push: Vector3
const PUSH_SPEED = 10.0

var do_push = false
var pusher_countdown = 0.0

func _ready() -> void:
	bone_attatchment.rotate_y(randf_range(-PI, PI))

func _physics_process(delta: float) -> void:
	var s = skeleton.get_bone_pose_scale(0).x
	platform.global_transform.origin = global_position + Vector3.ZERO.lerp(pos_offset, s)
	avoidance_area.scale = Vector3(1, 1, 1) * 1.0/s
	if do_push:
		push_away_from_others(delta)
		pusher_countdown += 0.1 * delta

func push_away_from_others(delta):
	var count = 0
	for body in avoidance_area.get_overlapping_bodies():
		if body != platform:
			count += 1
	if count > 0:
		var push_direction = Vector3.ZERO
		for body in avoidance_area.get_overlapping_bodies():
			if body != platform:
				var away = platform.global_position - body.global_position
				#if body.get_parent() is PlatformLilypad or body.get_parent() is RootSystem or body is Player:
				#	away = platform.global_position - body.global_position
				if body == own_soil:
					#force use default (normal from this soil)
					away = Vector3.ZERO
				away.y = 0
				if away.length_squared() > 0.001:
					push_direction += away
				else:
					push_direction += Vector3(default_push.x, 0, default_push.z)
		pos_offset += push_direction.normalized() * delta * PUSH_SPEED
		pos_offset += Vector3(0, pusher_countdown, 0) * delta
	else:
		if skeleton.get_bone_pose_scale(0).x >= 1:
			do_push = false
		

func default_height():
	
	#assume ceiling
	if default_push.y < -0.75:
		pos_offset = Vector3(-2, -0.5, -2)
	else:
		pos_offset = Vector3(0, 0.5, 0)
	
	await get_tree().physics_frame
	do_push = true
	await get_tree().physics_frame
	plat_collider.disabled = false

func seek_surface():
	
	print("SEEK SURFACE")
	raycast.force_raycast_update()
	if raycast.is_colliding():
		#print(raycast.get_collider().name)
		if raycast.get_collider().is_in_group("fresh_water"):
			#print(raycast.get_collision_point().distance_to(global_position))
			pos_offset = raycast.get_collision_point() - global_position
	
	await get_tree().physics_frame
	do_push = true
	await get_tree().physics_frame
	plat_collider.disabled = false

func grow():
	anim.play("grow")
