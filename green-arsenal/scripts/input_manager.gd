extends Node
class_name InputManager
### by Anthony D. Salsbury ###

### - basically works as a hub that emits all the signals
### - it is the responsibility of each object that wants a signal to connect themselves to the manager

signal move_dir(z, x)
signal move_stop
signal sprint(b)
signal jump
signal end_jump
signal pause
signal shoot
signal reload
signal interact
signal look(x, y)
signal up
signal down
signal left
signal right
signal sprint_burst

var mouse_sensitivity = 0.001

#here calls all the smaller functions for each input
func _process(delta: float) -> void:
	move_input()
	sprint_input()
	jump_input()
	pause_input()
	shoot_input()
	reload_input()
	interact_input()
	up_input()
	down_input()
	left_input()
	right_input()

func move_input():
	if Input.is_action_pressed("move_forward") or Input.is_action_pressed("move_back") or Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		var z_axis = Input.get_axis("move_forward", "move_back")
		var x_axis = Input.get_axis("move_left", "move_right")
		move_dir.emit(z_axis, x_axis)
	else:
		move_stop.emit()

func sprint_input():
	sprint.emit(Input.is_action_pressed("sprint"))
	if Input.is_action_just_pressed("sprint"):
		sprint_burst.emit()

func jump_input():
	if Input.is_action_just_pressed("jump"):
		jump.emit()
	elif Input.is_action_just_released("jump"):
		end_jump.emit()

func pause_input():
	if Input.is_action_just_pressed("pause"):
		pause.emit()

func shoot_input():
	if Input.is_action_just_pressed("shoot"):
		shoot.emit()

func reload_input():
	if Input.is_action_just_pressed("reload"):
		reload.emit()

func interact_input():
	if Input.is_action_just_pressed("interact"):
		interact.emit()

func up_input():
	if Input.is_action_just_pressed("move_forward"):
		up.emit()

func down_input():
	if Input.is_action_just_pressed("move_back"):
		down.emit()

func left_input():
	if Input.is_action_just_pressed("move_left"):
		left.emit()

func right_input():
	if Input.is_action_just_pressed("move_right"):
		right.emit()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			var look_x = -1 * event.relative.x * mouse_sensitivity;
			var look_y = -1 * event.relative.y * mouse_sensitivity;
			look.emit(look_x, look_y)
