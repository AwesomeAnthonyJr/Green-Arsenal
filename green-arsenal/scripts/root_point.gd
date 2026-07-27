extends Node3D
class_name RootPoint

@export var radius: float = 0.5

func find_system(x: Node3D):
	var p = x.get_parent()
	if p is RootSystem:
		return p
	else:
		return find_system(p)

func destroy():
	await get_tree().create_timer(0.1).timeout
	var sys = find_system(self)
	var p = get_parent()
	if p is RootSystem:
		sys.dont_collision = false
	else:
		sys.dont_collision = true
	sys.delayed_setup()
	
	
	if p is RootPoint:
		p.destroy()
	queue_free()
	
