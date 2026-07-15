extends Node3D
class_name Bullet
#class name so special seeds can just extend the behavior

var player: Player
var in_water = false

@export var speed: float = 50.0
#Bullet Speed

#raycast to detect soil / puzzle stuff
@onready var puzzle_cast: RayCast3D = $RayCast3D
#shapecast to give a slight margin in favor of the player for enemies; enemy colliders on layer 3
@onready var enemy_cast: ShapeCast3D = $ShapeCast3D

func become_a_fireball():
	var inst = Preloads.fireball.instantiate()
	get_parent().add_child(inst)
	inst.global_position = global_position
	inst.global_rotation = global_rotation
	inst.speed = speed / 2.0
	destroy_bullet()

func align_collision_rotation(norm, obj):
	#print(norm)
	obj.global_rotation = global_rotation
	var new_y = norm
	var new_x = new_y.cross(obj.global_transform.basis.z).normalized()
	var new_z = new_x.cross(new_y).normalized()
	obj.global_transform.basis = Basis(new_x, new_y, new_z)

func _physics_process(delta: float) -> void:
	global_transform.origin -= global_transform.basis.z * speed * delta
	
	enemy_cast.force_shapecast_update()
	puzzle_cast.force_raycast_update()
	
	if enemy_cast.is_colliding():
		if enemy_cast.get_collider(0).is_in_group("blaze_flower"):
			become_a_fireball()
		elif enemy_cast.get_collider(0).is_in_group("fresh_water"):
			in_water = true
		elif enemy_cast.get_collider(0).is_in_group("seeker_flower"):
			get_parent().remove_child(self)
			enemy_cast.get_collider(0).get_parent().store(self)
		else:
			hit_enemy(enemy_cast.get_collider(0))
			return
	if puzzle_cast.is_colliding():
		if puzzle_cast.get_collider().is_in_group("soil"):
			plant_seed(puzzle_cast.get_collision_point(), puzzle_cast.get_collision_normal())
		destroy_bullet()
	
	

#will be inherited by subclasses
func plant_seed(point, norm):
	print("PLANTING A SEED!")

#will be inherited by subclasses
func hit_enemy(obj):
	print("HIT ", obj.name)
	if obj.has_method("take_damage"):
		print("Taking damage")
		obj.take_damage(2)
	else:
		print("FAIL: obj does not have take_damage Function")
	destroy_bullet()


func _on_timer_timeout() -> void:
	destroy_bullet()

func destroy_bullet():
	queue_free() 
