extends Area3D

@export var new_id: int
var egg_hunt = 0

func _ready() -> void:
	###texture is only visible in editor!
	hide()

func _on_body_entered(body: Node3D) -> void:
	pass
	#moved to exit

func easter_egg_check():
	if SaveManager.player_save.egg:
		return new_id
	var temp = randi_range(0, 20)
	if temp < egg_hunt:
		return -new_id
	else:
		if egg_hunt < 10:
			egg_hunt += 1
	return new_id

func _on_body_exited(body: Node3D) -> void:
	if get_parent().active:
		if body.is_in_group("player"):
			var id = easter_egg_check()
			print(id)
			get_parent().go_to_room(id)
			await get_tree().create_timer(0.1).timeout
			body.check_special_plants()
