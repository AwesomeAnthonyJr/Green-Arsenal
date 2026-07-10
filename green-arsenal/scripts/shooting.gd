extends Node

@onready var cameraRig = $CameraRig
@onready var aimRayCast = $AimRayCast
@onready var gun = $Player

const bulletScene = preload("res://scenes/Bullet.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("this is running")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		shoot()
func shoot():
	var targetPoint = Vector3()
	if aimRayCast.is_colliding():
		targetPoint = aimRayCast.get_collision_point()
		print("shooting via ray")
	else:
		targetPoint = aimRayCast.global_position - (aimRayCast.global_transform.basis.z * 100)
		print("shooting via default")
	
	var bullet = bulletScene.instantiate()
	get_parent().add_child(bullet)
	
	bullet.global_position = gun.global_position
	bullet.look_at(targetPoint, Vector3.UP)
