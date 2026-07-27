extends Node3D
#looks like fireball cannot be a bullet so we'll just copy stuff over

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
		if enemy_cast.get_collider(0).is_in_group("torch"):
			enemy_cast.get_collider(0).get_parent().light_torch()
			destroy_bullet()
		elif enemy_cast.get_collider(0).is_in_group("blaze_flower"):
			pass
		else:
			#print("HIT ENEMY?")
			hit_enemy(enemy_cast.get_collider(0))
	if puzzle_cast.is_colliding():
		#print("HIT FLOOR?")
		destroy_bullet()
	
	
#will be inherited by subclasses
func hit_enemy(obj):
	if obj.has_method("take_damage"):
		#print("Taking damage from a fireball")
		obj.take_damage(10)
	destroy_bullet()


func _on_timer_timeout() -> void:
	destroy_bullet()

func destroy_bullet():
	queue_free() 
