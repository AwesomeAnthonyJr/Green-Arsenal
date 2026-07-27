extends Node
class_name Main

@export var input_manager: InputManager
@export var room_loader: RoomLoader

#basically testing is for testing and active is for active gameplay.
@onready var testing = $Testing
@onready var active = $Active

#a variable for whenever we want to not let the player control if the game is paused
var override_pause: bool = false

var not_gameplay: bool = true

func _ready() -> void:
	testing_check()
func testing_check():
	if testing.get_child_count() > 0:
		active.queue_free()
		print("REMOVED ACTIVE! IN TESTING!")
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _process(delta: float) -> void:
	#print(Engine.get_frames_per_second())
	pass
