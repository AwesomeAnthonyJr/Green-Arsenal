extends RigidBody3D

var attatched = true

func detatch():
	attatched = false
	get_parent().detatch(self)
	var parparpar = get_parent().get_parent().get_parent()
	var old_pos = global_position
	get_parent().remove_child(self)
	parparpar.add_child(self)
	global_position = old_pos
	freeze = false

func take_damage(amount: int) -> void:
	if attatched:
		detatch()
func take_knockback(amount: Vector3) -> void:
	if attatched:
		detatch()
		amount *= 0.5
	apply_central_impulse(amount)
