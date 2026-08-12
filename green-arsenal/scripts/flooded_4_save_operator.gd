extends SaveOperator

var just_picked_up : bool = false
var has_interacted : bool = false
@onready var previous_value = SaveManager.player_save.seed_types[4]

func _ready() -> void:
	Dialogic.signal_event.connect(_on_dialogic_signal)
	label.text = SaveManager.player_settings.get_text("interact").to_upper()
	if SaveManager.player_save.seed_types[5] == true:
		scene_index = operator_scenes.size() - 1

func _process(delta: float) -> void:
	if previous_value != SaveManager.player_save.seed_types[0]:
		just_picked_up = true
	previous_value = SaveManager.player_save.seed_types[0]

func extra_stuff_in_signal_func(arg):
	if arg == "scene_end_op" and has_interacted == false:
		has_interacted = true

func extra_stuff_in_physics_process():
	if SaveManager.player_save.seed_types[5] == true and just_picked_up:
		scene_index = operator_scenes.size() - 2
	elif SaveManager.player_save.seed_types[5] == false and has_interacted:
		scene_index = operator_scenes.size() - 1
