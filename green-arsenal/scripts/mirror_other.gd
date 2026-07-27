extends Node3D

###helper script to fully mirror global pos and rot of another node3d

@export var other: Node3D

func _process(delta: float) -> void:
	global_position = other.global_position
	global_rotation = other.global_rotation
