extends CharacterBody3D

#FOR FLYING ENEMY
@export var speed: float = 2.0
@export var maxHealth = 1
@export var contact_damage = 1
@export var attack_speed = 3.0
@export var hunts_plants: bool = false
var player = null
var home: Vector3

@onready var currHealth: int = maxHealth
var move_velocity: Vector3 = Vector3.ZERO
var target_velocity: Vector3 = Vector3.ZERO
@onready var shapecast = $ShapeCast3D

@onready var hand_right = $HandRight
@onready var hand_left = $HandLeft
var right_arm_position: Vector3
var left_arm_position: Vector3
var target_found_left: bool = false
var target_found_right: bool = false
@onready var anim: AnimationPlayer = $FancyModel/AnimationPlayer
var targeting: bool = false
var target_routine: float = 0.0
var target_obj: Node3D
@onready var hurtbox_l = $FancyModel/Skeleton3D/LeftArm/Hurtbox/CollisionShape3D
@onready var hurtbox_r = $FancyModel/Skeleton3D/RightArm/Hurtbox/CollisionShape3D
@onready var right_default = $FancyModel/Skeleton3D/RightDefault
@onready var left_default = $FancyModel/Skeleton3D/LeftDefault
var home_override = 0.0
var original_speed: float = 0.0
var activated: bool = false
@onready var hunting_audio = $AudioStreamPlayer3D

var dead: bool = false
@onready var smoke_particles = $SmokeParticles
@onready var deathcast = $ShapeCast3D2
@onready var mesh = $FancyModel/Skeleton3D/Sphere

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if player == null:
		find_player()
	home = global_position
	original_speed = speed

func find_player():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		return
	var level = get_tree().current_scene
	if level:
		for c in level.get_children():
			if c.is_in_group("player_package") and player == null:
				player = c.get_child(0)

func _physics_process(delta: float) -> void:
	if dead:
		velocity.y -= 9.8 * delta
		move_and_slide()
		if deathcast.is_colliding():
			really_die()
	else:
		if player != null:
			var target_pos = player.global_position
			var dist = global_position.distance_to(target_pos)
			if hunts_plants:
				for p in player.active_plants:
					if is_instance_valid(p) and !p.dead:
						var temp_pos = p.global_position
						var temp_dist = global_position.distance_to(temp_pos)
						if temp_dist < dist:
							dist = temp_dist
							target_pos = temp_pos
			if dist > 0.1 and dist < 10.0:
				look_at(target_pos, Vector3.UP)
				var direction = (target_pos - global_position).normalized()
				move_velocity.x = direction.x * speed
				move_velocity.y = direction.y * speed
				move_velocity.z = direction.z * speed
				home_override = 0.0
				#print(name, " actively searching: ", target_pos, "; speed: ", speed)
			else:
				var home_dist = global_position.distance_to(home)
				if home_dist < 40.0 or home_override < randf_range(5.0, 10.0):
					look_at(target_pos, Vector3.UP)
					var direction = (target_pos - global_position).normalized()
					move_velocity.x = direction.x * speed
					move_velocity.y = direction.y * speed
					move_velocity.z = direction.z * speed
					#print(name, " still near home")
				else:
					if !home.is_equal_approx(global_position):
						look_at(home, Vector3.UP)
					var direction = (home - global_position).normalized()
					move_velocity.x = direction.x * speed * 0.75
					move_velocity.y = direction.y * speed * 0.75
					move_velocity.z = direction.z * speed * 0.75
					home_override += delta
					#print(name, " going home ", home_override)
		else:
			move_velocity.x = 0
			move_velocity.z = 0
		velocity = target_velocity + move_velocity
		move_and_slide()
		target_velocity = target_velocity.lerp(Vector3.ZERO, delta)
		
		if targeting and is_instance_valid(target_obj):
			left_arm_position = target_obj.global_position
			target_routine += delta * attack_speed
			if target_routine < 3.0:
				speed = lerpf(speed, 0.0, 0.8)
			elif target_routine < 5.0:
				speed = lerpf(speed, original_speed + 6.0, 0.5)
			elif target_routine < 6.5:
				speed = original_speed
				targeting = false
		else:
			speed = original_speed
			attack_detection()
func take_damage(amount: int) -> void:
	currHealth -= amount
	print("Remaining health: ", currHealth)
	if currHealth <= 0:
		die()

func take_knockback(amount: Vector3) -> void:
	target_velocity += amount

func die() -> void:
	#print("Enemy dead")
	SoundManager.play_root_destroy()
	dead = true
	smoke_particles.emitting = true
	mesh.set_surface_override_material(1, Preloads.pure_black_mat)
	#queue_free() 

func really_die():
	SoundManager.play_enemy_destroy()
	var inst = Preloads.explosion_particles.instantiate()
	get_parent().add_child(inst)
	inst.global_position = global_position
	queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	hand_right.global_position = hand_right.global_position.lerp(right_arm_position, 0.2)
	hand_left.global_position = hand_left.global_position.lerp(left_arm_position, 0.2)
	if !target_found_right:
		right_arm_position = lerp(right_arm_position, right_default.global_position, 0.5)
		#print(right_arm_position)
	if !target_found_left:
		left_arm_position = lerp(left_arm_position, left_default.global_position, 0.5)

func attack_detection():
	var target_pos = Vector3.ZERO
	var found_a_player = false
	for i in shapecast.get_collision_count():
		var obj = shapecast.get_collider(i)
		if is_instance_valid(obj):
			if obj.is_in_group("player") or (hunts_plants and obj.is_in_group("plant")):
				found_a_player = true
				target_found_left = true
				target_obj = obj
				target_pos = shapecast.get_collision_point(i)
	if found_a_player:
		hunting_audio.play()
		target_found_left = true
		anim.play("snap_left")
		left_arm_position = target_pos
		targeting = true
		target_routine = 0.0
		hurtbox_l.disabled = false
	else:
		target_found_left = false
		anim.stop()
		targeting = false
		hurtbox_l.disabled = true

func _on_hurtbox_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			if !body.iframes:
				body.take_damage(contact_damage)
			take_knockback(5.0 * global_basis.z)
	elif body.is_in_group("plant"):
		body.get_parent().wither_self()
		if player is Player:
			player.check_special_plants()
	else:
		take_knockback(1.0 * global_basis.z)
