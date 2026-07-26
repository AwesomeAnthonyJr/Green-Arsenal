extends Node3D

@export var flag_index: int
@onready var anim = $AnimationPlayer
@onready var interact = $InteractArea

func _ready() -> void:
	if SaveManager.player_save.game_flags[flag_index]:
		anim.play("already_pressed")
		interact.on = false
	else:
		anim.play("not_pressed")
		interact.on = true

func activate():
	SaveManager.player_save.game_flags[flag_index] = true
	print("BUTTON ACTIVATED!")

func press(obj):
	if obj is Player:
		anim.play("press")
