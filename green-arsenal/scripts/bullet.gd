extends Node3D
class_name Bullet
#class name so special seeds can just extend the behavior

@export var speed: float = 50.0
#Bullet Speed

#raycast to detect soil / puzzle stuff
@onready var puzzle_cast = $RayCast3D
#shapecast to give a slight margin in favor of the player for enemies; enemy colliders on layer 3
@onready var enemy_cast = $ShapeCast3D



func _physics_process(delta: float) -> void:
	global_transform.origin -= global_transform.basis.z * speed * delta
	
	if puzzle_cast.is_colliding():
		if puzzle_cast.get_collider().is_in_group("soil"):
			plant_seed()
			destroy_bullet()
		else:
			destroy_bullet()

#will be inherited by subclasses
func plant_seed():
	print("PLANTING A SEED!")

func _on_timer_timeout() -> void:
	destroy_bullet()

func destroy_bullet():
	queue_free() 
