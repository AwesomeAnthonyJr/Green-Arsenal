extends Area3D
class_name InteractArea

var player: Player
signal interact_sig(obj)
@export var on = true
@export var one_time = true

func interact():
	print("INTERACT!!!!!!!!!")
	interact_sig.emit(player)
	if one_time:
		on = false
		if is_instance_valid(player) and player != null:
			player.interactable_obj = null
			player = null

func _on_body_entered(body: Node3D) -> void:
	if on:
		if body is Player:
			body.interactable_obj = self
			player = body


func _on_body_exited(body: Node3D) -> void:
	if on:
		if body is Player:
			body.interactable_obj = null
			player = null
