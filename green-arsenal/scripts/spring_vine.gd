extends Plant

@export var bounce_strength: float = 100.0


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		body.apply_central_impulse(bounce_strength * global_transform.basis.y)
