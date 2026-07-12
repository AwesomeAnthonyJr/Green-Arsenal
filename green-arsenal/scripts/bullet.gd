extends Node3D
class_name Bullet
#class name so special seeds can just extend the behavior

@export var speed: float = 50.0
#Bullet Speed

#raycast to detect soil / puzzle stuff
@onready var puzzle_cast: RayCast3D = $RayCast3D
#shapecast to give a slight margin in favor of the player for enemies; enemy colliders on layer 3
@onready var enemy_cast: ShapeCast3D = $ShapeCast3D



func _physics_process(delta: float) -> void:
	global_transform.origin -= global_transform.basis.z * speed * delta
	
	enemy_cast.force_shapecast_update()
	puzzle_cast.force_raycast_update()
	
	if enemy_cast.is_colliding():
		hit_enemy(enemy_cast.get_collider(0))
		return
	if puzzle_cast.is_colliding():
		if puzzle_cast.get_collider().is_in_group("soil"):
			plant_seed()
		destroy_bullet()
			
	
	

#will be inherited by subclasses
func plant_seed():
	print("PLANTING A SEED!")

#will be inherited by subclasses
func hit_enemy(obj):
	print("HIT ", obj.name)
	if obj.has_method("take_damage"):
		print("Taking damage")
		obj.take_damage(2)
	else:
		print("FAIL: obj does not have take_damageFunction")
	destroy_bullet()


func _on_timer_timeout() -> void:
	destroy_bullet()

func destroy_bullet():
	queue_free() 
