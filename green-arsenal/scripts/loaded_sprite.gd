extends Sprite2D

@onready var boss = $"../.."

#just want them to be rotationally aligned so it'll be a very simple, arguably dumb solution

func _process(delta: float) -> void:
	rotation = -boss.rotation
