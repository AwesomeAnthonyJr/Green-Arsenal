extends RigidBody3D

@export var jumpForce: float = 10.0;
#guys feel free to tweak these this is just some random guesses
@export var light_grav: float = 0.7
@export var heavy_grav: float = 1.5
#switched raycast to shapecast for more coverage
@onready var groundCast: ShapeCast3D = $GroundCast;

const walkSpeed = 1.5;
const sprintSpeed = 2.5;
var currentSpeed = walkSpeed;

@export var look_pivot: Node3D
var move_dir = Vector2.ZERO
var is_sprinting = false
var is_jump_drifting = false
var is_grounded = false

@onready var cameraRig = $"../CameraRig/TwistPivot/PitchPivot/Camera3D"
@onready var aimRayCast = $"../CameraRig/TwistPivot/PitchPivot/AimRayCast"
@onready var gun = $Gun

const bulletScene = preload("res://scenes/Bullet.tscn")


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
	manager.end_jump.connect(read_end_jump)
	manager.pause.connect(read_pause)
	# if this script is just for the movement of the player these
	# should probably be handled elswhere
	"""
	manager.pause.connect(read_shoot)
	manager.reload.connect(read_reload)
	manager.interact.connect(read_interact)
	"""
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
func read_end_jump():
	is_jump_drifting = false
#TODO: improve this / handle pausing in some other script! (fine for now)
func read_pause():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	#Unlocks the curser on esc press

# simple recursive solution to find the main node.
func find_main(x) -> Main:
	var p = x.get_parent()
	if p is Main:
		return p
	else:
		return find_main(p)

#like process but called in the physics thread, uses a consistent framerate
func _physics_process(delta: float) -> void:
	if groundCast.get_collision_count() > 0:
		is_grounded = true
	else:
		is_grounded = false
	
	physics_movement(delta)
	if !is_grounded:
		apply_air_drift()
	else:
		#not entirely sure if this matters but might as well
		gravity_scale = 1.0

#putting the movement aside here 
func physics_movement(delta:float) -> void:
	var input := Vector3.ZERO;
	input.x = move_dir.y;
	input.z = move_dir.x;
	var ground_mult = 1.0
	if !is_grounded:
		#less control over in-air movement
		ground_mult = 0.3
	if is_sprinting:
		currentSpeed = sprintSpeed;
	else:
		currentSpeed = walkSpeed;
		#Sprint mechanic 
	apply_central_force(look_pivot.basis * input.normalized() * 1200.0 * delta * currentSpeed * ground_mult);
	#Moves the player

#handles the "air drift" for a better jump
func apply_air_drift() -> void:
	if is_jump_drifting:
		if linear_velocity.y < 0:
			is_jump_drifting = false
		gravity_scale = light_grav
	else:
		gravity_scale = heavy_grav

#jump has been improved a bit
func playerJump() -> void:
	if is_grounded:
		apply_central_impulse(Vector3.UP * jumpForce);
		is_jump_drifting = true
	#Applies jump force 

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		shoot()
func shoot():
	var targetPoint = Vector3()
	if aimRayCast.is_colliding():
		targetPoint = aimRayCast.get_collision_point()
	else:
		targetPoint = aimRayCast.global_position - (aimRayCast.global_transform.basis.z * 100)
	
	var bullet = bulletScene.instantiate()
	get_parent().add_child(bullet)
	
	bullet.global_position = gun.global_position
	bullet.look_at(targetPoint, Vector3.UP)
