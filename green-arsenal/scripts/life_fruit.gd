extends Plant


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		body.heal_1()
		destroy_self()
