extends RigidBody3D

@onready var twist_pivot := $TwistPivot;
@onready var pitch_pivot := $TwistPivot/PitchPivot;

@export var jumpForce: float = 10.0;
@onready var groundCast: RayCast3D = $GroundCast;
var jumpFlag: bool = false;
const walkSpeed = 1.5;
const sprintSpeed = 2.5;

var currentSpeed = walkSpeed;

var move_dir = Vector2.ZERO
var is_sprinting = false
#Default speeds for walking vs. sprinting
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	connect_inputs()

func connect_inputs():
	var manager = find_main(self).input_manager
	manager.move_dir.connect(read_move_direction)
	manager.move_stop.connect(read_move_stop)
	manager.sprint.connect(read_sprint)
	manager.jump.connect(read_jump)
	manager.pause.connect(read_pause)
	# if this script is just for the movement of the player these
	# should probably be handled elswhere
	"""
	manager.pause.connect(read_shoot)
	manager.reload.connect(read_reload)
	manager.interact.connect(read_interact)
	"""
	manager.look.connect(read_look)
func read_move_direction(z, x):
	move_dir.x = z
	move_dir.y = x
func read_move_stop():
	move_dir = Vector2.ZERO
	#can do more here if we want to halt all movement too!
func read_sprint(b):
	is_sprinting = b
func read_jump():
	playerJump()
#TODO: improve this / handle pausing in some other script! (fine for now)
func read_pause():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	#Unlocks the curser on esc press
func read_look(y, x):
	twist_pivot.rotate_y(y);
	pitch_pivot.rotate_x(x);
	pitch_pivot.rotation.x = clamp(
		pitch_pivot.rotation.x,
		deg_to_rad(-30),
		deg_to_rad(30)
	)
	#Locks the camera so it doesn't go beyond boundaries
	
# simple recursive solution to find the main node.
func find_main(x) -> Main:
	var p = x.get_parent()
	if p is Main:
		return p
	else:
		return find_main(p)

#like process but called in the physics thread, uses a consistent framerate
func _physics_process(delta: float) -> void:
	var input := Vector3.ZERO;
	input.x = move_dir.y;
	input.z = move_dir.x;
	if is_sprinting:
		currentSpeed = sprintSpeed;
	else:
		currentSpeed = walkSpeed;
		#Sprint mechanic 
	apply_central_force(twist_pivot.basis * input.normalized() * 1200.0 * delta * currentSpeed);
	#Moves the player


#TODO: improve the jump!
func playerJump() -> void:
	if groundCast.is_colliding():
		apply_central_impulse(Vector3.UP * jumpForce);
	#Applies jump force 
