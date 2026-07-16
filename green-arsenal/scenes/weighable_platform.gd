extends PropellerPlatform

@export var weights_needed: int = 1

var propellers = []
var propeller_values = []
var direction_diff: Vector3
var lift_progress: float = 0.0
var grav_influence: float
var bodies = []
var body_starts = []
var body_ends = []

func _ready() -> void:
	direction_diff = (end_position - start_position)
	grav_influence = calc_influence(Vector3.DOWN) * 0.5
	for c in get_children():
		if c is AnimatableBody3D:
			bodies.append(c)
			body_starts.append(c.global_position)
			body_ends.append(c.global_position + direction_diff)

func calc_influence(vect):
	return direction_diff.normalized().dot(vect)

func _physics_process(delta):
	for p in propeller_values:
		lift_progress += p * delta
	lift_progress += grav_influence * delta
	var max = min(calc_propel_percentage(), 1.0)
	if lift_progress > max:
		lift_progress = max
	if lift_progress < 0:
		lift_progress = 0
	for i in bodies.size():
		bodies[i].global_position = body_starts[i].lerp(body_ends[i], lift_progress)

func calc_propel_percentage():
	return propellers.size() / float(propellers_needed)

func check_propellers():
	var temp_props = []
	for p in propellers:
		if is_instance_valid(p):
			temp_props.append(p)
	propellers = temp_props
	var temp_vals = []
	for p in propellers:
		print(p.direction)
		temp_vals.append(calc_influence(p.direction))
	propeller_values = temp_vals
	print(propeller_values)
