extends Control

@onready var circles = [$Node2D/Grown1, $Node2D/Grown2, $Node2D/Grown3]

func update_visibility(n):
	for i in circles.size():
		if i < n:
			circles[i].visible = true
		else:
			circles[i].visible = false

func update_sprites(arr: Array):
	var n = arr.size()
	for i in circles.size():
		if i < n:
			circles[i].get_child(0).visible = true
			circles[i].get_child(1).visible = false
			circles[i].get_child(0).frame = arr[i].sprite_frame
		else:
			circles[i].get_child(0).visible = false
			circles[i].get_child(1).visible = true
