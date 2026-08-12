extends Area3D


func _ready() -> void:
	set_collision_mask_value(1, true)

func _on_body_exited(body: Node3D) -> void:
	if body is AnimatableBody3D or body is RigidBody3D:
		SoundManager.play_splash()
		var inst = Preloads.splash_particles.instantiate()
		add_child(inst)
		inst.global_position = body.global_position
