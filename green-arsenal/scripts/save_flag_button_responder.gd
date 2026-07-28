extends Node

@export var flag_indices: Array[int]

var activated_already = false
signal flags_true

func check_flags():
	for i in flag_indices:
		if !SaveManager.player_save.game_flags[i]:
			return false
	return true

func _ready() -> void:
	var all_set = check_flags()
	activated_already = all_set
	if all_set:
		flags_true.emit()

func _process(delta: float) -> void:
	if !activated_already:
		if check_flags():
			activated_already = true
			flags_true.emit()
