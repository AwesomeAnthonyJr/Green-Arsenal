extends Node3D

### by Anthony D. Salsbury ###

### - a nicer feeling camera, using interpolation + raycasts

@export var mirror: Node3D

@onready var twist_pivot := $TwistPivot;
@onready var pitch_pivot := $TwistPivot/PitchPivot;

@onready var actual_camera = $TwistPivot/PitchPivot/Camera3D
#maybe update to shapecast if theres clipping problems
@onready var raycast = $TwistPivot/PitchPivot/RayCast3D

@onready var aimRayCast = $TwistPivot/PitchPivot/AimRayCast

const MAX_DIST = 3.0
const PITCH_OFFSET = Vector3(0, 0.6, 0)

var supress_looking = false

func connect_inputs():
	var manager = find_main(self).input_manager
	manager.look.connect(read_look)

func read_look(y, x):
	if !supress_looking:
		twist_pivot.rotate_y(y);
		pitch_pivot.rotate_x(x);
		pitch_pivot.rotation.x = clamp(
			pitch_pivot.rotation.x,
			deg_to_rad(-60),
			deg_to_rad(45)
		)
	#Locks the camera so it doesn't go beyond boundaries
	
# simple recursive solution to find the main node.
func find_main(x) -> Main:
	var p = x.get_parent()
	if p is Main:
		return p
	else:
		return find_main(p)

func _ready() -> void:
	connect_inputs()

func _physics_process(delta: float) -> void:
	#has the camera move close if it would clip through geometry
	var dist = MAX_DIST
	if raycast.is_colliding():
		dist = global_position.distance_to(raycast.get_collision_point())
	actual_camera.position.z = lerpf(actual_camera.position.z, dist, 0.5)


func _process(delta: float) -> void:
	global_position = global_position.lerp(mirror.global_position + PITCH_OFFSET, 0.5)
