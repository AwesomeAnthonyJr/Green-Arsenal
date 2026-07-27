extends Area3D

@export var new_id: int

func _ready() -> void:
	###texture is only visible in editor!
	hide()

func _on_body_entered(body: Node3D) -> void:
	pass
	#moved to exit


func _on_body_exited(body: Node3D) -> void:
	if get_parent().active:
		if body.is_in_group("player"):
			get_parent().go_to_room(new_id)
