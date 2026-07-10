#extends Node
extends RigidBody3D
@export var speed: float = 30.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	global_transform.origin -= global_transform.basis.z * speed * delta
	
