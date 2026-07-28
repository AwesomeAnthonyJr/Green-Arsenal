extends Node3D

signal target_destroyed
@onready var normal_kinda = $Normish

func shot():
	target_destroyed.emit()
	queue_free()

func get_norm_to_match():
	return (normal_kinda.global_position - global_position).normalized() 
