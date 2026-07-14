extends CanvasLayer
class_name HUD

@export var player: Player
@onready var crosshair = $Crosshair
@onready var revolver = $Revolver
@onready var health = $Health

signal load_special_seed(n)

func _ready() -> void:
	connect_inputs()

func connect_inputs():
	var manager = find_main(self).input_manager
	manager.up.connect(read_up)
	manager.down.connect(read_down)
	#manager.sprint.connect(read_sprint)
	manager.jump.connect(read_accept)
	#manager.end_jump.connect(read_end_jump)
	manager.pause.connect(read_back)
	#manager.shoot.connect(read_shoot)
	#manager.reload.connect(read_reload)
	manager.interact.connect(read_accept)

func read_up():
	if player.is_reloading:
		revolver.pick_prev()

func read_down():
	if player.is_reloading:
		revolver.pick_next()

func read_back():
	if player.is_reloading:
		player.is_reloading = false

func read_accept():
	if player.is_reloading:
		load_special_seed.emit(revolver.get_selection())
		#await get_tree().process_frame
		update_revolver(player.loaded_in_gun)
		#print(revolver.get_selection())

func find_main(x) -> Main:
	var p = x.get_parent()
	if p is Main:
		return p
	else:
		return find_main(p)

func update_petals(arr):
	crosshair.petal_1_id = min(arr[0], 1)
	crosshair.petal_2_id = min(arr[1], 1)
	crosshair.petal_3_id = min(arr[2], 1)
	crosshair.petal_4_id = min(arr[3], 1)
	crosshair.petal_5_id = min(arr[4], 1)
	crosshair.petal_6_id = min(arr[5], 1)
	
	crosshair.update_petals()

func update_revolver(arr):
	revolver.update_loaded_sprites(arr)

func shoot_petal(curr_bull):
	crosshair.current_bullet = curr_bull + 1
	crosshair.shoot_petal(curr_bull + 1)
	await get_tree().create_timer(0.1).timeout
	crosshair.current_bullet += 1
	if crosshair.current_bullet > 6:
		crosshair.current_bullet = 1
	crosshair.update_rotation()
	revolver.spin_to_bullet(player.current_bullet)

func reset_rot():
	crosshair.animation_tree["parameters/playback"].travel("RESET")
	crosshair.reset_petal_animations()
	revolver.reloading_anim()

func update_health_display(max, curr):
	health.update_visibility(max)
	health.update_sprites(curr)
