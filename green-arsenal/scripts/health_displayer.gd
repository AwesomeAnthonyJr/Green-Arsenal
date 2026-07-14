extends Control

@onready var hearts = [$Node2D/Heart1, $Node2D/Heart2, $Node2D/Heart3, $Node2D/Heart4, $Node2D/Heart5, $Node2D/Heart6, $Node2D/Heart7]

func update_visibility(n):
	for i in hearts.size():
		if i < n:
			hearts[i].visible = true
		else:
			hearts[i].visible = false

func update_sprites(n):
	for i in hearts.size():
		if i < n:
			hearts[i].get_child(0).visible = true
		else:
			hearts[i].get_child(0).visible = false
