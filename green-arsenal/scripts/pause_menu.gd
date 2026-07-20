extends Node

enum MenuSelection {
	STATUS,
	CONTROLS,
	CONFIG,
	MAP
} 

var current_menu = MenuSelection.CONTROLS

enum ControlsSelection {
	BIG_LEFT,
	BIG_RIGHT,
	MOVE_FORWARD,
	MOVE_BACK,
	MOVE_LEFT,
	MOVE_RIGHT,
	SPRINT,
	JUMP,
	PAUSE,
	RELOAD,
	INTERACT,
	SHOOT,
	PUT_AWAY
}

var current_menu_2 = ControlsSelection.BIG_LEFT

@onready var main_anim_tree = $CanvasLayer/SubViewportContainer/SubViewport/Camera3D/Pivot/AnimationTree
@onready var controls_menu = $CanvasLayer/SubViewportContainer/SubViewport/Camera3D/Pivot/Controls/MeshInstance3D/SubViewport/Controls

#controls stuff
var remapping = false
var action_to_remap: String
var suppress_next_input = false

func _ready() -> void:
	connect_inputs()
func connect_inputs():
	var manager = find_main(self).input_manager
	manager.up.connect(read_up)
	manager.down.connect(read_down)
	manager.left.connect(read_left)
	manager.right.connect(read_right)
	manager.sprint_burst.connect(read_big_left)
	manager.jump.connect(read_big_right)
	#manager.pause.connect(read_pause)
	#manager.shoot.connect(read_shoot)
	manager.reload.connect(read_back)
	manager.interact.connect(read_accept)
func find_main(x) -> Main:
	var p = x.get_parent()
	if p is Main:
		return p
	else:
		return find_main(p)

func _process(delta: float) -> void:
	if suppress_next_input:
		suppress_next_input = false

#TODO: handle all animations here!
func update_visually():
	var playback = main_anim_tree["parameters/playback"]
	match current_menu:
		MenuSelection.STATUS:
			playback.travel("on_status")
		MenuSelection.CONTROLS:
			playback.travel("on_controls")
			playback = controls_menu.anim_tree["parameters/playback"]
			match current_menu_2:
				ControlsSelection.BIG_LEFT:
					playback.travel("on_BIG_LEFT")
				ControlsSelection.BIG_RIGHT:
					playback.travel("on_BIG_RIGHT")
				ControlsSelection.MOVE_FORWARD:
					playback.travel("on_MOVE_FORWARD")
				ControlsSelection.MOVE_BACK:
					playback.travel("on_MOVE_BACK")
				ControlsSelection.MOVE_LEFT:
					playback.travel("on_MOVE_LEFT")
				ControlsSelection.MOVE_RIGHT:
					playback.travel("on_MOVE_RIGHT")
				ControlsSelection.SPRINT:
					playback.travel("on_SPRINT")
				ControlsSelection.JUMP:
					playback.travel("on_JUMP")
				ControlsSelection.PAUSE:
					playback.travel("on_PAUSE")
				ControlsSelection.RELOAD:
					playback.travel("on_RELOAD")
				ControlsSelection.INTERACT:
					playback.travel("on_INTERACT")
				ControlsSelection.SHOOT:
					playback.travel("on_SHOOT")
				ControlsSelection.PUT_AWAY:
					playback.travel("on_PUT_AWAY")
		MenuSelection.CONFIG:
			playback.travel("on_config")
		MenuSelection.MAP:
			playback.travel("on_map")

func read_up():
	if suppress_next_input:
		return
	match current_menu:
		MenuSelection.STATUS:
			pass
		MenuSelection.CONTROLS:
			match current_menu_2:
				ControlsSelection.BIG_LEFT:
					pass
				ControlsSelection.BIG_RIGHT:
					pass
				ControlsSelection.MOVE_FORWARD:
					pass
				ControlsSelection.MOVE_BACK:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_FORWARD
				ControlsSelection.MOVE_LEFT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_FORWARD
				ControlsSelection.MOVE_RIGHT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_FORWARD
				ControlsSelection.SPRINT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_LEFT
				ControlsSelection.JUMP:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_RIGHT
				ControlsSelection.PAUSE:
					pass
				ControlsSelection.RELOAD:
					pass
				ControlsSelection.INTERACT:
					pass
				ControlsSelection.SHOOT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.PUT_AWAY
				ControlsSelection.PUT_AWAY:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.RELOAD
		MenuSelection.CONFIG:
			pass
		MenuSelection.MAP:
			pass
	update_visually()

func read_down():
	if suppress_next_input:
		return
	match current_menu:
		MenuSelection.STATUS:
			pass
		MenuSelection.CONTROLS:
			match current_menu_2:
				ControlsSelection.BIG_LEFT:
					pass
				ControlsSelection.BIG_RIGHT:
					pass
				ControlsSelection.MOVE_FORWARD:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_BACK
				ControlsSelection.MOVE_BACK:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.SPRINT
				ControlsSelection.MOVE_LEFT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_BACK
				ControlsSelection.MOVE_RIGHT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_BACK
				ControlsSelection.SPRINT:
					pass
				ControlsSelection.JUMP:
					pass
				ControlsSelection.PAUSE:
					pass
				ControlsSelection.RELOAD:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.PUT_AWAY
				ControlsSelection.INTERACT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.PUT_AWAY
				ControlsSelection.SHOOT:
					pass
				ControlsSelection.PUT_AWAY:
					pass
		MenuSelection.CONFIG:
			pass
		MenuSelection.MAP:
			pass
	update_visually()

func read_left():
	if suppress_next_input:
		return
	match current_menu:
		MenuSelection.STATUS:
			pass
		MenuSelection.CONTROLS:
			match current_menu_2:
				ControlsSelection.BIG_LEFT:
					pass
				ControlsSelection.BIG_RIGHT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.INTERACT
				ControlsSelection.MOVE_FORWARD:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_LEFT
				ControlsSelection.MOVE_BACK:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_LEFT
				ControlsSelection.MOVE_LEFT:
					current_menu_2 = ControlsSelection.BIG_LEFT
				ControlsSelection.MOVE_RIGHT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_LEFT
				ControlsSelection.SPRINT:
					current_menu_2 = ControlsSelection.BIG_LEFT
				ControlsSelection.JUMP:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.SPRINT
				ControlsSelection.PAUSE:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.JUMP
				ControlsSelection.RELOAD:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_RIGHT
				ControlsSelection.INTERACT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.RELOAD
				ControlsSelection.SHOOT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.PAUSE
				ControlsSelection.PUT_AWAY:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.SHOOT
		MenuSelection.CONFIG:
			pass
		MenuSelection.MAP:
			pass
	update_visually()

func read_right():
	if suppress_next_input:
		return
	match current_menu:
		MenuSelection.STATUS:
			pass
		MenuSelection.CONTROLS:
			match current_menu_2:
				ControlsSelection.BIG_LEFT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_LEFT
				ControlsSelection.BIG_RIGHT:
					pass
				ControlsSelection.MOVE_FORWARD:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_RIGHT
				ControlsSelection.MOVE_BACK:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_RIGHT
				ControlsSelection.MOVE_LEFT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_RIGHT
				ControlsSelection.MOVE_RIGHT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.RELOAD
				ControlsSelection.SPRINT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.JUMP
				ControlsSelection.JUMP:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.PAUSE
				ControlsSelection.PAUSE:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.SHOOT
				ControlsSelection.RELOAD:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.INTERACT
				ControlsSelection.INTERACT:
					current_menu_2 = ControlsSelection.BIG_RIGHT
				ControlsSelection.SHOOT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.PUT_AWAY
				ControlsSelection.PUT_AWAY:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.INTERACT
		MenuSelection.CONFIG:
			pass
		MenuSelection.MAP:
			pass
	update_visually()

func read_accept():
	if suppress_next_input:
		return
	match current_menu:
		MenuSelection.STATUS:
			pass
		MenuSelection.CONTROLS:
			match current_menu_2:
				ControlsSelection.BIG_LEFT:
					read_big_left()
				ControlsSelection.BIG_RIGHT:
					read_big_right()
				ControlsSelection.MOVE_FORWARD:
					action_to_remap = "move_forward"
					await get_tree().process_frame
					remapping = true
				ControlsSelection.MOVE_BACK:
					action_to_remap = "move_back"
					await get_tree().process_frame
					remapping = true
				ControlsSelection.MOVE_LEFT:
					action_to_remap = "move_left"
					await get_tree().process_frame
					remapping = true
				ControlsSelection.MOVE_RIGHT:
					action_to_remap = "move_right"
					await get_tree().process_frame
					remapping = true
				ControlsSelection.SPRINT:
					action_to_remap = "sprint"
					await get_tree().process_frame
					remapping = true
				ControlsSelection.JUMP:
					action_to_remap = "jump"
					await get_tree().process_frame
					remapping = true
				ControlsSelection.PAUSE:
					action_to_remap = "pause"
					await get_tree().process_frame
					remapping = true
				ControlsSelection.RELOAD:
					action_to_remap = "reload"
					await get_tree().process_frame
					remapping = true
				ControlsSelection.INTERACT:
					action_to_remap = "interact"
					await get_tree().process_frame
					remapping = true
				ControlsSelection.SHOOT:
					action_to_remap = "shoot"
					await get_tree().process_frame
					remapping = true
				ControlsSelection.PUT_AWAY:
					action_to_remap = "close_reload"
					await get_tree().process_frame
					remapping = true
		MenuSelection.CONFIG:
			pass
		MenuSelection.MAP:
			pass

func read_back():
	if suppress_next_input:
		return
	match current_menu:
		MenuSelection.STATUS:
			pass
		MenuSelection.CONTROLS:
			pass
		MenuSelection.CONFIG:
			pass
		MenuSelection.MAP:
			pass

func read_big_left():
	if suppress_next_input:
		return
	match current_menu:
		MenuSelection.STATUS:
			current_menu = MenuSelection.MAP
		MenuSelection.CONTROLS:
			current_menu = MenuSelection.STATUS
		MenuSelection.CONFIG:
			current_menu = MenuSelection.CONTROLS
		MenuSelection.MAP:
			current_menu = MenuSelection.CONFIG
	update_visually()
func read_big_right():
	if suppress_next_input:
		return
	match current_menu:
		MenuSelection.STATUS:
			current_menu = MenuSelection.CONTROLS
		MenuSelection.CONTROLS:
			current_menu = MenuSelection.CONFIG
		MenuSelection.CONFIG:
			current_menu = MenuSelection.MAP
		MenuSelection.MAP:
			current_menu = MenuSelection.STATUS
	update_visually()

func match_next_remapping(n: String):
	match n:
		"move_forward":
			current_menu_2 = ControlsSelection.MOVE_FORWARD
		"move_back":
			current_menu_2 = ControlsSelection.MOVE_BACK
		"move_left":
			current_menu_2 = ControlsSelection.MOVE_LEFT
		"move_right":
			current_menu_2 = ControlsSelection.MOVE_RIGHT
		"sprint":
			current_menu_2 = ControlsSelection.SPRINT
		"jump":
			current_menu_2 = ControlsSelection.JUMP
		"pause":
			current_menu_2 = ControlsSelection.PAUSE
		"shoot":
			current_menu_2 = ControlsSelection.SHOOT
		"reload":
			current_menu_2 = ControlsSelection.RELOAD
		"close_reload":
			current_menu_2 = ControlsSelection.PUT_AWAY
		"interact":
			current_menu_2 = ControlsSelection.INTERACT

func _input(event):
	if remapping:
		#print(event)
		if event is InputEventKey && event.pressed:
			#print("REACHED REBIND!")
			var temp = SaveManager.player_settings.find_duplicate_actions(action_to_remap, event)
			var next_remapping = true
			if temp == action_to_remap:
				temp = ""
				next_remapping = false
			SaveManager.player_settings.rebindAction(action_to_remap, event)
			if next_remapping:
				match_next_remapping(temp)
			remapping = next_remapping
			suppress_next_input = true
			action_to_remap = temp
			update_visually()
		elif event is InputEventMouseButton && event.pressed:
			var temp = SaveManager.player_settings.find_duplicate_actions(action_to_remap, event)
			var next_remapping = true
			if temp == action_to_remap:
				temp = ""
				next_remapping = false
			SaveManager.player_settings.rebindAction(action_to_remap, event)
			if next_remapping:
				match_next_remapping(temp)
			remapping = next_remapping
			suppress_next_input = true
			action_to_remap = temp
			update_visually()
