extends Plant
class_name SeekerFlower

@onready var twist_pivot = $Flower
@onready var pitch_pivot = $Flower/Pivot
@onready var shooter = $SeekerUI/SubViewportContainer/SubViewport/Node3D/Camera3D
@onready var seeker_ui = $SeekerUI
var has_bullet = false
var stored = null

func _ready() -> void:
	connect_inputs()

func connect_inputs():
	var manager = find_main(self).input_manager
	manager.look.connect(read_look)
	manager.shoot.connect(read_shoot)

func read_look(y, x):
	if has_bullet:
		twist_pivot.rotate_y(y);
		pitch_pivot.rotate_x(x);
		pitch_pivot.rotation.x = clamp(
			pitch_pivot.rotation.x,
			deg_to_rad(-89),
			deg_to_rad(89)
		)

func read_shoot():
	if has_bullet:
		get_parent().add_child(stored)
		stored.global_position = shooter.global_position
		stored.global_rotation = shooter.global_rotation
		has_bullet = false
		stored = null

func find_main(x) -> Main:
	var p = x.get_parent()
	if p is Main:
		return p
	else:
		return find_main(p)

func store(obj):
	stored = obj
	has_bullet = true
	#print("STORED", obj.name)

func _process(delta: float) -> void:
	seeker_ui.visible = has_bullet
