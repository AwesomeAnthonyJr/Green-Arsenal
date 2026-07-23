extends Node3D
class_name Torch

var lit = false
@onready var flame = $Sprite3D

signal torch_lit

func _process(delta: float) -> void:
	flame.visible = lit

func light_torch():
	lit = true
	torch_lit.emit()
