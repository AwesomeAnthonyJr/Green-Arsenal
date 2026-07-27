extends Area3D

@export var dialogic_scene : DialogicTimeline
@export_enum("FLAG","SEED") var flag_or_seed
@export var fs_index : int

var scene_played = false
var player_ref

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	if flag_or_seed == 0:
		if SaveManager.player_save.game_flags[fs_index] == true:
			queue_free()
	elif flag_or_seed == 1:
		if SaveManager.player_save.seed_types[fs_index] == true:
			queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and scene_played == false:
		player_ref = body
		player_ref.paused = true
		Dialogic.start(dialogic_scene)

func _on_dialogic_signal(arg):
	if arg == "scene_end":
		player_ref.paused = false
		scene_played = true
