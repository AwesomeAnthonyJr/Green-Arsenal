extends Plant
@onready var anim = $AnimationPlayer

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		pass
		#body.heal_1()
		#destroy_self()

func grow():
	anim.play("grow")

func wither_self():
	dead = true
	anim.play("die")
	await get_tree().create_timer(1.0).timeout
	destroy_self()
