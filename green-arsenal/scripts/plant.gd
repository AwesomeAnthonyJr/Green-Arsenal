extends Node3D
class_name Plant

func destroy_self():
	queue_free()

func wither_self():
	print("WITHERING AWAY!")
	destroy_self()
