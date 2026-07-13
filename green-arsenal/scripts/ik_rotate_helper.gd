@tool
extends Node3D

@export var skeleton: Skeleton3D
@export var bone_name: String

var bone = null

#this isnt working so i guess we'll just ignore it

func _ready() -> void:
	bone = skeleton.find_bone(bone_name)

func _process(delta: float) -> void:
	if bone != null:
		match_bone()

func match_bone():
	var b = global_transform.scaled(Vector3(1, 1, 1))
	skeleton.set_bone_global_pose(
	bone,
	b
	#(skeleton.get_bone_global_pose(skeleton.get_bone_parent(bone)).basis.inverse() * skeleton.global_basis.inverse() * global_basis).get_rotation_quaternion()
)
