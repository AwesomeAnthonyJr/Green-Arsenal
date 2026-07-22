extends Plant
class_name SpringVine

@onready var anim = $AnimationPlayer
@export var bounce_strength: float = 100.0
@onready var shapecast = $ShapeCast3D
@onready var skeleton = $Armature/Skeleton3D
var target_y = 0.0

func _physics_process(delta: float) -> void:
	target_y = lerpf(-5.0, 0.0, shapecast.get_closest_collision_safe_fraction())
	skeleton.position.y = lerpf(skeleton.position.y, target_y, 0.5)

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is RigidBody3D:
		var imp = bounce_strength * global_transform.basis.y * body.mass
		
		if body is Player:
			imp *= 0.75
			#body.is_jump_drifting = true
		print(imp)
		body.apply_central_impulse(imp)
		

func grow():
	anim.play("grow")
