extends Node3D

signal target_destroyed

func shot():
	target_destroyed.emit()
	queue_free()
