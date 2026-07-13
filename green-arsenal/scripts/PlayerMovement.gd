extends RigidBody3D
class_name Player

@export var jumpForce: float = 10.0;
#guys feel free to tweak these this is just some random guesses
@export var light_grav: float = 0.7
@export var heavy_grav: float = 1.5
#switched raycast to shapecast for more coverage
@onready var groundCast: ShapeCast3D = $GroundCast;

const walkSpeed = 1.5;
const sprintSpeed = 2.5;
var currentSpeed = walkSpeed;

@export var look_pivot: Node3D
@export var hud: HUD
var move_dir = Vector2.ZERO
var is_sprinting = false
var is_jump_drifting = false
var is_grounded = false
var supress_movement = false

@onready var cameraRig = $"../CameraRig/TwistPivot/PitchPivot/Camera3D"
@onready var aimRayCast = $"../CameraRig/TwistPivot/PitchPivot/AimRayCast"
@onready var shooter = $Pivot/Pivot2/Model/Armature_001/Skeleton3D/BoneAttachment3D/Gun/Node3D/Shooter
@onready var hand_looker = $Pivot/Pivot2/Model/Armature_001/Skeleton3D/LookAtModifier3D
@export var aiming_target: Node3D

@onready var pivot = $Pivot
@onready var pivot_2 = $Pivot/Pivot2

var is_reloading = false
var current_bullet = 0
var loaded_in_gun = [0, 0, 0, 0, 0, 0]
var max_health = 3
var current_health = 1

var plant_max = 3
var active_plants = []

#Default speeds for walking vs. sprinting
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
	connect_inputs()
	await get_tree().process_frame
	if HUD != null:
		hud.update_petals(loaded_in_gun)
		connect_hud()
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
	manager.pause.connect(read_pause)
	manager.shoot.connect(read_shoot)
	manager.reload.connect(read_reload)
	manager.interact.connect(read_interact)
	
func read_move_direction(z, x):
	move_dir.x = z
	move_dir.y = x
func read_move_stop():
	move_dir = Vector2.ZERO
	#can do more here if we want to halt all movement too!
func read_sprint(b):
	is_sprinting = b
func read_jump():
	playerJump()
func read_end_jump():
	is_jump_drifting = false
#TODO: improve this / handle pausing in some other script! (fine for now)
func read_pause():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
	#Unlocks the curser on esc press
func read_shoot():
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
	if is_reloading:
		pass
	else:
		pass

func reload_special_seed(n):
	if loaded_in_gun[current_bullet] == 0:
		loaded_in_gun[current_bullet] = n
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
	supress_movement = is_reloading
	cameraRig.get_parent().get_parent().get_parent().supress_looking = is_reloading

#like process but called in the physics thread, uses a consistent framerate
func _physics_process(delta: float) -> void:
	#print(is_grounded, ", ", gravity_scale)
	if groundCast.get_collision_count() > 0:
		if !is_grounded:
			for i in groundCast.get_collision_count():
				var how_groundy = Vector3.UP.dot(groundCast.get_collision_normal(i))
				if how_groundy > 0.5:
					is_grounded = true
	else:
		is_grounded = false
	if !supress_movement:
		physics_movement(delta)
		physics_looking()
		gun_rotation()
	if !is_grounded:
		apply_air_drift(delta)
	else:
		#weirdly the player just kinda doesnt fall without this??? (when removing lilypad platforms)
		apply_central_force(Vector3.DOWN)
		gravity_scale = 1.0
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
		ground_mult = 0.3
	if is_sprinting:
		currentSpeed = sprintSpeed;
	else:
		currentSpeed = walkSpeed;
		#Sprint mechanic 
	apply_central_force(look_pivot.basis * input.normalized() * 1200.0 * delta * currentSpeed * ground_mult);
	#Moves the player

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
	if is_grounded and !supress_movement:
		#print()
		var speed_mult = lerpf(1.0, 1.75, linear_velocity.slide(Vector3.UP).length() / 12.0)
		apply_central_impulse(Vector3.UP * jumpForce * speed_mult);
		is_jump_drifting = true
	#Applies jump force 

func shoot():
	#using the global "Preloads" script means it just preloads it once i think (less expensive?)
	var bullet = Preloads.bullet_seed.instantiate()
	var is_special = false
	match loaded_in_gun[current_bullet]:
		4:
			bullet = Preloads.life_seed.instantiate()
		5:
			bullet = Preloads.platform_seed.instantiate()
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
	if active_plants.size() > plant_max:
		active_plants[0].wither_self()

func heal_1():
	current_health += 1
	if current_health > max_health:
		current_health = max_health
