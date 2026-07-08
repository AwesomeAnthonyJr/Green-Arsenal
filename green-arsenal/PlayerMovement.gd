extends RigidBody3D

var mouse_sensitivity := 0.001;
var twist_input := 0.0;
var pitch_input := 0.0;

@onready var twist_pivot := $TwistPivot;
@onready var pitch_pivot := $TwistPivot/PitchPivot;

@export var jumpForce: float = 10.0;
@onready var groundCast: RayCast3D = $GroundCast;
var jumpFlag: bool = false;
const walkSpeed = 1.5;
const sprintSpeed = 2.5;

var currentSpeed = walkSpeed;
#Default speeds for walking vs. sprinting
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	#Locks cursor


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var input := Vector3.ZERO;
	input.x = Input.get_axis("move_left", "move_right");
	input.z = Input.get_axis("move_forward", "move_back");
	if Input.is_action_pressed("sprint"):
		currentSpeed = sprintSpeed;
	else:
		currentSpeed = walkSpeed;
		#Sprint mechanic 
	apply_central_force(twist_pivot.basis * input.normalized() * 1200.0 * delta * currentSpeed);
	#Moves the player
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	#Unlocks the curser on esc press
	if jumpFlag:
		playerJump();
		jumpFlag = false;
	twist_pivot.rotate_y(twist_input);
	pitch_pivot.rotate_x(pitch_input);
	pitch_pivot.rotation.x = clamp(
		pitch_pivot.rotation.x,
		deg_to_rad(-30),
		deg_to_rad(30)
	)
	twist_input = 0.0;
	pitch_input = 0.0;
	#Locks the camera so it doesn't go beyond boundaries
	
func playerJump() -> void:
	if groundCast.is_colliding():
		apply_central_impulse(Vector3.UP * jumpForce);
	#Applies jump force 
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = - event.relative.x * mouse_sensitivity;
			pitch_input = - event.relative.y * mouse_sensitivity;
	if event.is_action_pressed("jump"):
		jumpFlag = true;
			
