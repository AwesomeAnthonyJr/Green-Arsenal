extends Plant
class_name SpringVine

@onready var anim = $AnimationPlayer
@export var bounce_strength: float = 100.0
@onready var shapecast = $ShapeCast3D
@onready var skeleton = $Armature/Skeleton3D
@onready var timer = $Timer
var target_y = 0.0
var holding_jump = false
var just_bounced = []

func _physics_process(delta: float) -> void:
	target_y = lerpf(-5.0, 0.0, shapecast.get_closest_collision_safe_fraction())
	skeleton.position.y = lerpf(skeleton.position.y, target_y, 0.5)

func read_jump(b):
	holding_jump = b

func connect_inputs():
	var manager = find_main(self).input_manager
	if not manager.jump_held.is_connected(read_jump):
		manager.jump_held.connect(read_jump)
func find_main(x) -> Main:
	var p = x.get_parent()
	if p is Main:
		return p
	else:
		return find_main(p)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		if !body in just_bounced:
			var imp = bounce_strength * global_transform.basis.y * body.mass
			
			if body is Player:
				if holding_jump:
					imp *= 1.25
				else:
					imp *= 0.75
				#body.is_jump_drifting = true
			just_bounced.append(body)
			timer.start()
			body.apply_central_impulse(imp)
		else:
			print("ALREADY BOUNCED, ", body)
		

func grow():
	anim.play("grow")
	connect_inputs()


func _on_timer_timeout() -> void:
	just_bounced.clear()
