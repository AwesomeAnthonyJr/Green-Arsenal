extends Node3D
class_name Plant

var dead = false

func destroy_self():
	queue_free()

func wither_self():
	print("WITHERING AWAY!")
	destroy_self()

func grow():
	pass
