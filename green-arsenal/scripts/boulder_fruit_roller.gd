extends RigidBody3D

var attatched = true
@onready var boss = $"../../../.."
var dead = false
@onready var anim = $AnimationPlayer

func die():
	dead = true
	anim.play("die")

func detatch():
	attatched = false
	boss.detatch(self)
	#this gets "room_loader"
	var rl = Generics.find_room_loader(self)
	var old_pos = global_position
	get_parent().remove_child(self)
	rl.add_child(self)
	global_position = old_pos
	scale = Vector3(1.0, 1.0, 1.0)
	freeze = false

func take_damage(amount: int) -> void:
	if attatched:
		detatch()
func take_knockback(amount: Vector3) -> void:
	if attatched:
		detatch()
		amount *= 0.5
	apply_central_impulse(amount)
