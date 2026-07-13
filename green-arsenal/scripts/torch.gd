extends Node3D

var lit = false
@onready var flame = $Sprite3D

func _process(delta: float) -> void:
	flame.visible = lit

func light_torch():
	lit = true
	print("LIGHTING TORCH!!!")
