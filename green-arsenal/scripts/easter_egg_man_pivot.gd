extends Node3D

var rot_target: Node3D
var aim_ray: RayCast3D
@onready var tree = $"../ManTree/StaticBody3D_L1"
@onready var interact_col = $Armature_001/InteractArea/CollisionShape3D

func _ready() -> void:
	await get_tree().process_frame
	var player = Generics.find_room_loader(self).player
	rot_target = player.get_child(2).get_child(0)
	aim_ray = player.get_child(0).aimRayCast

func _process(delta: float) -> void:
	if rot_target != null:
		rotation.y = rot_target.global_rotation.y - PI/2

func _physics_process(delta: float) -> void:
	if aim_ray != null:
		if aim_ray.is_colliding():
			if aim_ray.get_collider() != tree:
				if rot_target.global_position.distance_to(self.global_position) < 5.0:
					hide()
					interact_col.disabled = true
			else:
				show()
				interact_col.disabled = false


func _on_interact_area_interact_sig(obj: Variant) -> void:
	SaveManager.player_save.egg = true
	SoundManager.play_menu_accept()
	queue_free()
