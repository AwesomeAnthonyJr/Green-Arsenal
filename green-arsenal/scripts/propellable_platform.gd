extends Node3D
class_name PropellablePlatform

@export var end_position: Vector3
@export var start_position: Vector3
@export var propellers_needed: int = 1
@export var speed_limit: float = 1.0

var propellers = []
var propeller_values = []
var weights = []
var weight_values = []

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
			body_starts.append(c.position)
			body_ends.append(c.position + direction_diff)

func calc_influence(vect):
	return direction_diff.normalized().dot(vect)

func _physics_process(delta):
	var diff = 0.0
	for p in propeller_values:
		diff += p * delta
	for w in weight_values:
		diff += w * delta
	if calc_propel_percentage() > 0:
		diff += grav_influence * delta
	diff = min(diff, 2.5 * delta)
	diff = max(diff, -1.5 * delta)
	diff = min(diff, speed_limit)
	diff = max(diff, -speed_limit)
	#print(diff)
	lift_progress += diff
	var max = 1.0
	if direction_diff.normalized().y >= 0:
		max = min(calc_propel_percentage(), 1.0)
	if lift_progress > max:
		lift_progress = lerpf(lift_progress, max, 0.01)
		if lift_progress > 1.0:
			lift_progress = 1.0
	if lift_progress < 0:
		lift_progress = 0
	for i in bodies.size():
		bodies[i].position = body_starts[i].lerp(body_ends[i], lift_progress)

func calc_propel_percentage():
	return propellers.size() / float(propellers_needed)

func check_propellers():
	var temp_props = []
	for p in propellers:
		if is_instance_valid(p) and !p.dead:
			temp_props.append(p)
	propellers = temp_props
	var temp_vals = []
	for p in propellers:
		temp_vals.append(calc_influence(p.direction))
	propeller_values = temp_vals
	
	var temp_weights = []
	for w in weights:
		if is_instance_valid(w):
			temp_weights.append(w)
	weights = temp_weights
	temp_vals = []
	for w in weights:
		temp_vals.append(calc_influence(Vector3.DOWN))
	weight_values = temp_vals

func read_weight_enter(obj: Node3D):
	if obj.is_in_group("roller") and !obj.freeze:
		if !(obj in weights):
			weights.append(obj)
			check_propellers()

func read_weight_exit(obj: Node3D):
	if obj.is_in_group("roller") and !obj.freeze:
		if obj in weights:
			weights.erase(obj)
			check_propellers()
