extends RigidBody3D
class_name Player

@export var jumpForce: float = 6.0;
#guys feel free to tweak these this is just some random guesses
@export var light_grav: float = 0.8
@export var heavy_grav: float = 2.0
#switched raycast to shapecast for more coverage
@onready var groundCast: ShapeCast3D = $GroundCast;

const walkSpeed = 1.5;
const sprintSpeed = 2.0;
var currentSpeed = walkSpeed;
const max_speed_factor = 5.0

@export var look_pivot: Node3D
@export var hud: HUD
var move_dir = Vector2.ZERO
var is_sprinting = false
var is_jump_drifting = false
var is_grounded = false
var supress_movement = false
var supress_shooting = false

@onready var cameraRig = $"../CameraRig/TwistPivot/PitchPivot/Camera3D"
@onready var aimRayCast = $"../CameraRig/TwistPivot/PitchPivot/Camera3D/AimRayCast"
@onready var shooter = $Pivot/Pivot2/Model/Armature_001/Skeleton3D/BoneAttachment3D/Gun/Node3D/Shooter
@onready var hand_looker = $Pivot/Pivot2/Model/Armature_001/Skeleton3D/LookAtModifier3D
@export var aiming_target: Node3D

@onready var pivot = $Pivot
@onready var pivot_2 = $Pivot/Pivot2
@onready var model_anim_tree = $Pivot/Pivot2/Model/Armature_001/Skeleton3D/AnimationTree

var is_reloading = false
var current_bullet = 0
var loaded_in_gun = [0, 0, 0, 0, 0, 0]
var max_health = 3
var current_health = max_health

var plant_max = 3
var active_plants = []

var iframes = false

var interactable_obj: InteractArea
var ground_normal: Vector3

@onready var forward_step_cast: ShapeCast3D = $Pivot/Pivot2/Model/ForwardStepCast
@onready var forward_step_cast_2: ShapeCast3D = $Pivot/Pivot2/Model/ForwardStepCast2
@onready var ground_cast_2: ShapeCast3D = $GroundCast2
var forward_steppable = false
var forward_step_height = 0.0
var currently_stepping = false


#Default speeds for walking vs. sprinting
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect_inputs()
	await get_tree().process_frame
	if HUD != null:
		hud.update_petals(loaded_in_gun)
		connect_hud()
		hud.update_health_display(max_health, current_health)
	hand_looker.target_node = aiming_target.get_path()
	

func connect_hud():
	hud.load_special_seed.connect(reload_special_seed)

func connect_inputs():
	var manager = find_main(self).input_manager
	manager.move_dir.connect(read_move_direction)
	manager.move_stop.connect(read_move_stop)
	manager.sprint.connect(read_sprint)
	manager.jump.connect(read_jump)
	manager.end_jump.connect(read_end_jump)
	manager.shoot.connect(read_shoot)
	manager.reload.connect(read_reload)
	manager.interact.connect(read_interact)
	
func read_move_direction(z, x):
	move_dir.x = z
	move_dir.y = x
	if !move_dir.is_zero_approx():
		physics_material_override.friction = 0.6
func read_move_stop():
	move_dir = Vector2.ZERO
	physics_material_override.friction = 1.0
func read_sprint(b):
	is_sprinting = b
func read_jump():
	playerJump()
func read_end_jump():
	is_jump_drifting = false
###read_pause(): has moved to the pause menu script!
func read_shoot():
	if get_tree().paused:
		return
	if supress_shooting:
		return
	is_reloading = false
	#print(current_bullet)
	if current_bullet < 7:
		var new_curr = 5
		for i in loaded_in_gun.size():
			if loaded_in_gun[i] != 0:
				new_curr = min(new_curr, i)
		current_bullet = new_curr
		if loaded_in_gun[current_bullet] != 0:
			shoot()
			loaded_in_gun[current_bullet] = 0
			hud.shoot_petal(current_bullet)
			current_bullet += 1
			hud.update_revolver(loaded_in_gun)
func read_reload():
	if get_tree().paused:
		return
	if supress_shooting:
		return
	if is_reloading:
		hud.reset_rot()
		reload_bullet_seed()
		hud.update_revolver(loaded_in_gun)
	else:
		is_reloading = true
		hud.update_petals(loaded_in_gun)
		hud.reset_rot()
		current_bullet = 0

func read_interact():
	if get_tree().paused:
		return
	if supress_shooting:
		return
	if is_reloading:
		pass
	else:
		#not sure if the null check is needed but better safe than sorry!
		if is_instance_valid(interactable_obj) and interactable_obj != null:
			interactable_obj.interact()
func exit_reload_early():
	if get_tree().paused:
		return
	is_reloading = false
	current_bullet = 0
	for i in loaded_in_gun.size():
		if loaded_in_gun[i] != 0:
			current_bullet = i
			break 
	hud.revolver.spin_to_bullet(current_bullet)
func reload_special_seed(n):
	if loaded_in_gun[current_bullet] == 0:
		loaded_in_gun[current_bullet] = n
		current_bullet += 1
	while current_bullet < 6 and loaded_in_gun[current_bullet] != 0:
		current_bullet += 1
	if current_bullet > 5:
			is_reloading = false
			current_bullet = 0
			hud.revolver.spin_to_bullet(current_bullet)
	hud.update_petals(loaded_in_gun)

func reload_bullet_seed():
	if loaded_in_gun[current_bullet] == 0:
		loaded_in_gun[current_bullet] = 1
		current_bullet += 1
	while current_bullet < 6 and loaded_in_gun[current_bullet] != 0:
		current_bullet += 1
	if current_bullet > 5:
		is_reloading = false
		current_bullet = 0
		hud.revolver.spin_to_bullet(current_bullet)
	hud.update_petals(loaded_in_gun)

# simple recursive solution to find the main node.
func find_main(x) -> Main:
	var p = x.get_parent()
	if p is Main:
		return p
	else:
		return find_main(p)

# going to just handle some flags here
func _process(delta: float) -> void:
	if is_reloading and Input.is_action_just_pressed("close_reload"):
		exit_reload_early()
	supress_movement = is_reloading or supress_shooting
	cameraRig.get_parent().get_parent().get_parent().supress_looking = is_reloading or supress_shooting
	supress_shooting = false
	for p in active_plants:
		if is_instance_valid(p):
			if !supress_shooting:
				if p is SeekerFlower and p.has_bullet:
					supress_shooting = true

func check_steps(delta):
	forward_steppable = false
	if forward_step_cast.get_collision_count() > 0 and !forward_step_cast_2.is_colliding():
		for i in forward_step_cast.get_collision_count():
			var o = forward_step_cast.get_collider(i)
			var temp_pos = forward_step_cast.global_position
			temp_pos.y -= 0.5
			var h = temp_pos.distance_to(forward_step_cast.get_collision_point(i))
			if is_instance_valid(o) and !o.is_in_group("not_ground") and !o.is_in_group("player"):
				var norm = forward_step_cast.get_collision_normal(i)
				var how_groundy = Vector3.UP.dot(norm)
				if o.is_in_group("springvine_ground") and linear_velocity.y < 0.1:
					how_groundy = 0
				if how_groundy > 0.9:
					forward_steppable = true
					#print(o)
					forward_step_height = h
					if is_nan(forward_step_height):
						forward_step_height = 0.0
	else:
		forward_steppable = false
		forward_step_height = 0.0
		currently_stepping = false

#like process but called in the physics thread, uses a consistent framerate
func _physics_process(delta: float) -> void:
	#print(linear_velocity.y)
	#print(gravity_scale)
	#print(is_grounded, ", ", physics_material_override.friction)
	var g_norm = Vector3.ZERO
	if groundCast.get_collision_count() > 0:
		for i in groundCast.get_collision_count():
			var o = groundCast.get_collider(i)
			if is_instance_valid(o) and !o.is_in_group("not_ground"):
				var norm = groundCast.get_collision_normal(i)
				g_norm += norm
				var how_groundy = Vector3.UP.dot(norm)
				if o.is_in_group("springvine_ground") and linear_velocity.y < 0.1:
					how_groundy = 0
				if how_groundy > 0.45:
					is_grounded = true
	else:
		is_grounded = false
		g_norm = Vector3.UP
	ground_normal = g_norm.normalized()
	if !supress_movement:
		if is_grounded or currently_stepping:
			check_steps(delta)
		else:
			forward_steppable = false
		physics_movement(delta)
		physics_looking()
		gun_rotation()
	if !is_grounded:
		apply_air_drift(delta)
		#apply_central_force(Vector3.DOWN * 10 * gravity_scale)
		#print(gravity_scale)
	else:
		pass
	
	#just going to use the walk animation to convey all movement for now...
	if move_dir.length() > 0 and !supress_movement:
		var move_speed = lerpf(1.0, 2.5, Vector2(linear_velocity.x, linear_velocity.z).length() / 12.0)
		model_anim_tree.set("parameters/TimeScale/scale", move_speed)
		model_anim_tree["parameters/WalkState/playback"].travel("left_step")
	else:
		model_anim_tree.set("parameters/TimeScale/scale", 1.0)
		model_anim_tree["parameters/WalkState/playback"].travel("standing")
	
func gun_rotation():
	var targetPoint = Vector3()
	if aimRayCast.is_colliding():
		targetPoint = aimRayCast.get_collision_point()
	else:
		targetPoint = aimRayCast.global_position - (aimRayCast.global_transform.basis.z * 100)
	if aiming_target != null:
		aiming_target.global_position = targetPoint
		shooter.look_at(targetPoint, Vector3.UP)

func physics_looking() -> void:
	pivot.rotation.y = lerp_angle(pivot.rotation.y, look_pivot.rotation.y, 0.5)
	###extra stuff for more of a 3d platformer vibe, could be good to use later!
	#if move_dir != Vector2.ZERO:
	#	var temp = Vector2(-move_dir.y, -move_dir.x)
	#	pivot_2.rotation.y = lerp_angle(pivot_2.rotation.y, temp.angle(), 0.1)
	#pass

#putting the movement aside here 
func physics_movement(delta:float) -> void:
	var input := Vector3.ZERO;
	input.x = move_dir.y;
	input.z = move_dir.x;
	var ground_mult = 1.0
	if !is_grounded:
		#less control over in-air movement
		ground_mult = 0.35
	if is_sprinting:
		currentSpeed = sprintSpeed;
	else:
		currentSpeed = walkSpeed;
		#Sprint mechanic 
	var current_speed_in_dir = linear_velocity.dot((look_pivot.basis * input).normalized())
	var max_speed = max_speed_factor * currentSpeed
	var force = look_pivot.basis * input.normalized() * 1200.0 * delta * currentSpeed * ground_mult
	#print(ground_normal.y)
	#print(force)
	if ground_normal == Vector3.ZERO:
		ground_normal = Vector3.UP
	if current_speed_in_dir < max_speed:
		var temp = force.slide(ground_normal)
	
		#multiply the y force to better handle slopes
		if forward_step_cast.is_colliding():
			temp.y *= 1.5
			if temp.y != 0:
				print(temp.y)
		apply_central_force(temp);
	
	###faux-gravity - also a sticking force
	if is_grounded:
		apply_central_force(ground_normal * -9.8 * delta)
	elif ground_cast_2.is_colliding() and !is_jump_drifting:
		var frac = ground_cast_2.get_closest_collision_safe_fraction()
		apply_central_force(ground_normal * -9.8 * delta * gravity_scale * frac * 10.0)
		#print("niche; snap to floor")
	
	if move_dir.x < 0 and forward_steppable and forward_step_height != 0:
		currently_stepping = true
		var temp = sqrt(2.0 * gravity_scale * forward_step_height) * Vector3.UP * 0.5
		#print(temp.y)
		apply_central_impulse(temp);
		#position.y += forward_step_height + 0.05

#handles the "air drift" for a better jump
func apply_air_drift(delta) -> void:
	#print(gravity_scale)
	if is_jump_drifting:
		if linear_velocity.y < 0:
			is_jump_drifting = false
		gravity_scale = light_grav
		#apply_central_force(delta * Vector3.UP * jumpForce * 30.0)
	else:
		gravity_scale = heavy_grav

#jump has been improved a bit
func playerJump() -> void:
	if get_tree().paused:
		return
	if is_grounded and !supress_movement:
		#print()
		var speed_mult = lerpf(1.0, 1.5, linear_velocity.slide(Vector3.UP).length() / 20.0)
		print(speed_mult)
		apply_central_impulse(Vector3.UP * jumpForce * speed_mult);
		is_jump_drifting = true
	#Applies jump force 

func shoot():
	#using the global "Preloads" script means it just preloads it once i think (less expensive?)
	var bullet = Preloads.bullet_seed.instantiate()
	var is_special = false
	match loaded_in_gun[current_bullet]:
		2:
			bullet = Preloads.blaze_seed.instantiate()
		3:
			bullet = Preloads.bounce_seed.instantiate()
		4:
			bullet = Preloads.life_seed.instantiate()
		5:
			bullet = Preloads.platform_seed.instantiate()
		6:
			bullet = Preloads.seeker_seed.instantiate()
		7:
			bullet = Preloads.propeller_seed.instantiate()
		8:
			bullet = Preloads.heavy_seed.instantiate()
	get_parent().get_parent().add_child(bullet)
	
	bullet.global_position = shooter.global_position
	bullet.global_rotation = shooter.global_rotation
	bullet.player = self
	
	var temp_plants = []
	for p in active_plants:
		if is_instance_valid(p):
			temp_plants.append(p)
	active_plants = temp_plants

func check_special_plants():
	var temp_plants = []
	for p in active_plants:
		if is_instance_valid(p):
			temp_plants.append(p)
	active_plants = temp_plants
	if active_plants.size() > plant_max:
		active_plants[0].wither_self()

func heal_1():
	current_health += 1
	if current_health > max_health:
		current_health = max_health
	hud.update_health_display(max_health, current_health)

func take_damage(n):
	print(current_health)
	current_health -= n
	#TODO: make player death actually reload the game and stuff not just resetting position (obviously)
	if current_health <= 0:
		print("PLAYER DIES!!")
		current_health = max_health
		global_position = get_parent().global_position
	iframes = true
	hud.update_health_display(max_health, current_health)
	await get_tree().create_timer(0.1).timeout
	iframes = false
