extends Node

@export var flag_index: int
@export var destroy_if_true: Array[Node3D]

func _ready() -> void:
	if SaveManager.player_save.game_flags[flag_index]:
		await get_tree().process_frame
		for o in destroy_if_true:
			o.queue_free()
