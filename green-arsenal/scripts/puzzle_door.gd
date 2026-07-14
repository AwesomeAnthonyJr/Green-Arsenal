extends Node3D

@onready var animation = $AnimationPlayer

func open_door():
	animation.play("open")
