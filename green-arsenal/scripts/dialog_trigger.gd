extends Area3D

@export var dialogic_scene : DialogicTimeline

var scene_played = false
var player_ref

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	SaveManager.read_save()
	if SaveManager.player_save.game_flags[0] == true:
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
