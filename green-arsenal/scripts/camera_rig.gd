extends Node3D

### by Anthony D. Salsbury ###

### - a nicer feeling camera, using interpolation + raycasts

@export var mirror: Node3D

@onready var twist_pivot := $TwistPivot;
@onready var pitch_pivot := $TwistPivot/PitchPivot;

@onready var actual_camera = $TwistPivot/PitchPivot/Camera3D
#maybe update to shapecast if theres clipping problems
#update: there was clipping problems
@onready var camcast = $TwistPivot/PitchPivot/ShapeCast3D

@onready var aimRayCast = $TwistPivot/PitchPivot/Camera3D/AimRayCast
@onready var water_cast = $TwistPivot/PitchPivot/Camera3D/WaterRayCast
@onready var water_quad = $TwistPivot/PitchPivot/Camera3D/WaterMesh

const MAX_DIST = 3.0
const PITCH_OFFSET = Vector3(0, 0.6, 0)

var supress_looking = false

func connect_inputs():
	var manager = Generics.find_main(self).input_manager
	manager.look.connect(read_look)

func read_look(y, x):
	if get_tree().paused:
		return
	if !supress_looking:
		twist_pivot.rotate_y(y);
		pitch_pivot.rotate_x(x);
		pitch_pivot.rotation.x = clamp(
			pitch_pivot.rotation.x,
			deg_to_rad(-75),
			deg_to_rad(75)
		)
	#Locks the camera so it doesn't go beyond boundaries

func _ready() -> void:
	connect_inputs()

func _physics_process(delta: float) -> void:
	#has the camera move close if it would clip through geometry
	var dist = MAX_DIST
	if camcast.get_collision_count() > 0:
		dist = camcast.get_closest_collision_safe_fraction() * MAX_DIST
	actual_camera.position.z = lerpf(actual_camera.position.z, dist, 0.5)
	if water_cast.is_colliding():
		if water_cast.get_collider().is_in_group("fresh_water"):
			var water_dist = water_cast.get_collision_point().distance_to(water_cast.global_position)
			water_quad.position.y = -water_dist
	else:
		water_quad.position.y = lerpf(water_quad.position.y, -1.0, 0.1)


func _process(delta: float) -> void:
	global_position = global_position.lerp(mirror.global_position + PITCH_OFFSET, 0.5)
