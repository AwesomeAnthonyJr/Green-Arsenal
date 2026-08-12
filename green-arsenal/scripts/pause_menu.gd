extends Node
class_name PauseMenu

var main: Main

enum MenuSelection {
	STATUS,
	CONTROLS,
	CONFIG,
	MAP
} 

var current_menu = MenuSelection.STATUS

enum StatusSelection {
	BIG_LEFT,
	BIG_RIGHT,
	SEED_1,
	SEED_2,
	SEED_3,
	SEED_4,
	SEED_5,
	SEED_6,
	SEED_7,
	HEART,
	GROWTH_1,
	GROWTH_2,
	GROWTH_3
}

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

enum ConfigSelection {
	BIG_LEFT,
	BIG_RIGHT,
	MASTER_HOVER,
	MASTER_SLIDER,
	MUSIC_HOVER,
	MUSIC_SLIDER,
	SOUND_HOVER,
	SOUND_SLIDER,
	MOUSE_HOVER,
	MOUSE_SLIDER,
	TO_TITLE_1,
	TO_TITLE_2,
	TO_TITLE_3
}

enum MapSelection {
	BIG_LEFT,
	BIG_RIGHT,
	BUTTON_1,
	BUTTON_2,
	BUTTON_3,
	BUTTON_4,
	BUTTON_5,
	BUTTON_6,
	BUTTON_7,
	BUTTON_8,
	BUTTON_9
}

var current_menu_2 = StatusSelection.SEED_1

@onready var main_anim_tree = $CanvasLayer/SubViewportContainer/SubViewport/Camera3D/Pivot/AnimationTree
@onready var select_anim_tree = $AnimationTree
@onready var bar_text = $CanvasLayer/BottomBar/BarText

@onready var status_menu = $CanvasLayer/SubViewportContainer/SubViewport/Camera3D/Pivot/Status/MeshInstance3D/SubViewport/PauseStatus
@onready var controls_menu = $CanvasLayer/SubViewportContainer/SubViewport/Camera3D/Pivot/Controls/MeshInstance3D/SubViewport/Controls
@onready var config_menu = $CanvasLayer/SubViewportContainer/SubViewport/Camera3D/Pivot/Audio/MeshInstance3D/SubViewport/Audio
@onready var map_menu = $CanvasLayer/SubViewportContainer/SubViewport/Camera3D/Pivot/Map/MeshInstance3D/SubViewport/Map

@onready var status_buttons = $CanvasLayer/StatusButtons
@onready var controls_buttons = $CanvasLayer/ControlsButtons
@onready var config_buttons = $CanvasLayer/ConfigButtons
@onready var config_title_buttons = $CanvasLayer/ConfigButtons/ToTitleButtons
@onready var map_buttons = $CanvasLayer/MapButtons

#status stuff
var inspecting = false

#controls stuff
var remapping = false
var action_to_remap: String
var suppress_next_input = false

#for pausing/unpausing
var in_menu = false

func _ready() -> void:
	main = Generics.find_main(self)
	connect_inputs()
	status_buttons.hide()
	controls_buttons.hide()
	config_buttons.hide()
	config_title_buttons.hide()
	map_buttons.hide()
	
func connect_inputs():
	var manager = main.input_manager
	manager.up.connect(read_up)
	manager.down.connect(read_down)
	manager.left.connect(read_left)
	manager.right.connect(read_right)
	manager.sprint_burst.connect(read_big_left)
	manager.jump.connect(read_big_right)
	manager.pause.connect(read_pause)
	#manager.shoot.connect(read_shoot)
	manager.reload.connect(read_back)
	manager.interact.connect(read_accept)
func _process(delta: float) -> void:
	if suppress_next_input:
		suppress_next_input = false

#this is where the game handles pausing.
func read_pause():
	if main.not_gameplay:
		return
	if remapping:
		return
	var p = get_tree().paused
	if !p:
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
		current_menu = MenuSelection.STATUS
		current_menu_2 = StatusSelection.SEED_1
		update_visually()
		initialize_map_frame()
		await get_tree().create_timer(0.2).timeout
		in_menu = true
		SoundManager.play_menu_open()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);
		close_pause_menu()
		SoundManager.play_menu_close()

func close_pause_menu():
	get_tree().paused = false
	in_menu = false
	status_buttons.hide()
	controls_buttons.hide()
	config_buttons.hide()
	config_title_buttons.hide()
	map_buttons.hide()
	var playback = main_anim_tree["parameters/playback"]
	match current_menu:
		MenuSelection.STATUS:
			playback.travel("close_menu_status")
		MenuSelection.CONTROLS:
			playback.travel("close_menu_controls")
		MenuSelection.CONFIG:
			playback.travel("close_menu_config")
		MenuSelection.MAP:
			playback.travel("close_menu_map")
	playback = select_anim_tree["parameters/playback"]
	playback.travel("hide_selector")
	SaveManager.write_settings()

func update_display():
	match current_menu:
		MenuSelection.STATUS:
			match current_menu_2:
				StatusSelection.BIG_LEFT:
					bar_text.display("[center][color=#fad019][b]To MAP[/b][/color][/center]")
				StatusSelection.BIG_RIGHT:
					bar_text.display("[center][color=#fad019][b]To CONTROLS[/b][/color][/center]")
				###NOTE! with a new seed order will need to manually move these around!
				StatusSelection.SEED_1:
					if SaveManager.player_save.seed_types[0]:
						if inspecting:
							bar_text.display("Blaze Flower. Press [bgcolor=white][color=black][outline_color=white][b]{reload}[/b][/outline_color][/color][/bgcolor] to go back")
						else:
							bar_text.display("Blaze Seed. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to inspect")
					else:
						bar_text.display("[center][color=#b4b4b4]Unknown Seed[/color][/center]")
				StatusSelection.SEED_2:
					if SaveManager.player_save.seed_types[1]:
						if inspecting:
							bar_text.display("Life Fruit. Press [bgcolor=white][color=black][outline_color=white][b]{reload}[/b][/outline_color][/color][/bgcolor] to go back")
						else:
							bar_text.display("Life Seed. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to inspect")
					else:
						bar_text.display("[center][color=#b4b4b4]Unknown Seed[/color][/center]")
				StatusSelection.SEED_3:
					if SaveManager.player_save.seed_types[2]:
						if inspecting:
							bar_text.display("Spring Vine. Press [bgcolor=white][color=black][outline_color=white][b]{reload}[/b][/outline_color][/color][/bgcolor] to go back")
						else:
							bar_text.display("Bounce Seed. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to inspect")
					else:
						bar_text.display("[center][color=#b4b4b4]Unknown Seed[/color][/center]")
				StatusSelection.SEED_4:
					if SaveManager.player_save.seed_types[3]:
						if inspecting:
							bar_text.display("Seeking Stalk. Press [bgcolor=white][color=black][outline_color=white][b]{reload}[/b][/outline_color][/color][/bgcolor] to go back")
						else:
							bar_text.display("Seeker Seed. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to inspect")
					else:
						bar_text.display("[center][color=#b4b4b4]Unknown Seed[/color][/center]")
				StatusSelection.SEED_5:
					if SaveManager.player_save.seed_types[4]:
						if inspecting:
							bar_text.display("Platform Pad. Press [bgcolor=white][color=black][outline_color=white][b]{reload}[/b][/outline_color][/color][/bgcolor] to go back")
						else:
							bar_text.display("Platform Seed. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to inspect")
					else:
						bar_text.display("[center][color=#b4b4b4]Unknown Seed[/color][/center]")
				StatusSelection.SEED_6:
					if SaveManager.player_save.seed_types[5]:
						if inspecting:
							bar_text.display("Propeller Flower. Press [bgcolor=white][color=black][outline_color=white][b]{reload}[/b][/outline_color][/color][/bgcolor] to go back")
						else:
							bar_text.display("Propeller Seed. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to inspect")
					else:
						bar_text.display("[center][color=#b4b4b4]Unknown Seed[/color][/center]")
				StatusSelection.SEED_7:
					if SaveManager.player_save.seed_types[6]:
						if inspecting:
							bar_text.display("Boulder Fruit. Press [bgcolor=white][color=black][outline_color=white][b]{reload}[/b][/outline_color][/color][/bgcolor] to go back")
						else:
							bar_text.display("Heavy Seed. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to inspect")
					else:
						bar_text.display("[center][color=#b4b4b4]Unknown Seed[/color][/center]")
				StatusSelection.HEART:
					bar_text.display("Your max health is currently [b]{max_hp}[/b]")
				StatusSelection.GROWTH_1:
					bar_text.display("A growth charge. You have [b]{growth_charges}[/b]")
				StatusSelection.GROWTH_2:
					bar_text.display("A growth charge. You have [b]{growth_charges}[/b]")
				StatusSelection.GROWTH_3:
					bar_text.display("A growth charge. You have [b]{growth_charges}[/b]")
		MenuSelection.CONTROLS:
			if remapping:
				bar_text.display("[center][pulse freq=1.0 color=#b4b4b4 ease=-2.0]Awaiting Input...[/pulse][/center]")
			else:
				match current_menu_2:
					ControlsSelection.BIG_LEFT:
						bar_text.display("[center][color=#fad019][b]To STATUS[/b][/color][/center]")
					ControlsSelection.BIG_RIGHT:
						bar_text.display("[center][color=#fad019][b]To CONFIG[/b][/color][/center]")
					ControlsSelection.MOVE_FORWARD:
						bar_text.display("Move Forward. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to begin remapping")
					ControlsSelection.MOVE_BACK:
						bar_text.display("Move Back. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to begin remapping")
					ControlsSelection.MOVE_LEFT:
						bar_text.display("Move Left. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to begin remapping")
					ControlsSelection.MOVE_RIGHT:
						bar_text.display("Move Right. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to begin remapping")
					ControlsSelection.SPRINT:
						bar_text.display("Sprint. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to begin remapping")
					ControlsSelection.JUMP:
						bar_text.display("Jump. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to begin remapping")
					ControlsSelection.PAUSE:
						bar_text.display("Pause. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to begin remapping")
					ControlsSelection.RELOAD:
						bar_text.display("Reload. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to begin remapping")
					ControlsSelection.INTERACT:
						bar_text.display("Interact. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to begin remapping")
					ControlsSelection.SHOOT:
						bar_text.display("Shoot. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to begin remapping")
					ControlsSelection.PUT_AWAY:
						bar_text.display("Put Away. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to begin remapping")
		MenuSelection.CONFIG:
			match current_menu_2:
				ConfigSelection.BIG_LEFT:
					bar_text.display("[center][color=#fad019][b]To CONTROLS[/b][/color][/center]")
				ConfigSelection.BIG_RIGHT:
					bar_text.display("[center][color=#fad019][b]To MAP[/b][/color][/center]")
				ConfigSelection.MASTER_HOVER:
					bar_text.display("Master Volume. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to modify")
				ConfigSelection.MASTER_SLIDER:
					bar_text.display("[center][bgcolor=white][color=black][outline_color=white][b]{move_left}[/b][/outline_color][/color][/bgcolor]      < {master_vol}% >      [bgcolor=white][color=black][outline_color=white][b]{move_right}[/b][/outline_color][/color][/bgcolor][/center]")
				ConfigSelection.MUSIC_HOVER:
					bar_text.display("Music Volume. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to modify")
				ConfigSelection.MUSIC_SLIDER:
					bar_text.display("[center][bgcolor=white][color=black][outline_color=white][b]{move_left}[/b][/outline_color][/color][/bgcolor]      < {music_vol}% >      [bgcolor=white][color=black][outline_color=white][b]{move_right}[/b][/outline_color][/color][/bgcolor][/center]")
				ConfigSelection.SOUND_HOVER:
					bar_text.display("Sound Volume. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to modify")
				ConfigSelection.SOUND_SLIDER:
					bar_text.display("[center][bgcolor=white][color=black][outline_color=white][b]{move_left}[/b][/outline_color][/color][/bgcolor]      < {sound_vol}% >      [bgcolor=white][color=black][outline_color=white][b]{move_right}[/b][/outline_color][/color][/bgcolor][/center]")
				ConfigSelection.MOUSE_HOVER:
					bar_text.display("Mouse Sensitivity. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to modify")
				ConfigSelection.MOUSE_SLIDER:
					bar_text.display("[center][bgcolor=white][color=black][outline_color=white][b]{move_left}[/b][/outline_color][/color][/bgcolor]      < {mouse_sense} >      [bgcolor=white][color=black][outline_color=white][b]{move_right}[/b][/outline_color][/color][/bgcolor][/center]")
				ConfigSelection.TO_TITLE_1:
					bar_text.display("Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to return to title")
				ConfigSelection.TO_TITLE_2:
					bar_text.display("Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to go back")
				ConfigSelection.TO_TITLE_3:
					bar_text.display("Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to actually return to title")
		MenuSelection.MAP:
			match current_menu_2:
				MapSelection.BIG_LEFT:
					bar_text.display("[center][color=#fad019][b]To CONFIG[/b][/color][/center]")
				MapSelection.BIG_RIGHT:
					bar_text.display("[center][color=#fad019][b]To STATUS[/b][/color][/center]")
				MapSelection.BUTTON_1:
					bar_text.display("Forest Map Layer. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to view")
				MapSelection.BUTTON_2:
					bar_text.display("Forest Map Layer. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to view")
				MapSelection.BUTTON_3:
					bar_text.display("Forest Map Layer. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to view")
				MapSelection.BUTTON_4:
					bar_text.display("Forest Map Layer. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to view")
				MapSelection.BUTTON_5:
					bar_text.display("Forest Map Layer. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to view")
				MapSelection.BUTTON_6:
					bar_text.display("Forest Map Layer. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to view")
				MapSelection.BUTTON_7:
					bar_text.display("Forest Map Layer. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to view")
				MapSelection.BUTTON_8:
					bar_text.display("Forest Map Layer. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to view")
				MapSelection.BUTTON_9:
					bar_text.display("Forest Map Layer. Press [bgcolor=white][color=black][outline_color=white][b]{interact}[/b][/outline_color][/color][/bgcolor] to view")

#handle all animations here!
func update_visually():
	update_display()
	var playback = main_anim_tree["parameters/playback"]
	match current_menu:
		MenuSelection.STATUS:
			playback.travel("on_status")
			status_menu.update_status_seeds()
			status_menu.update_status_health()
			status_buttons.show()
			controls_buttons.hide()
			config_buttons.hide()
			config_title_buttons.hide()
			map_buttons.hide()
			playback = status_menu.anim_tree["parameters/playback"]
			match current_menu_2:
				StatusSelection.BIG_LEFT:
					playback.travel("on_BIG_LEFT")
				StatusSelection.BIG_RIGHT:
					playback.travel("on_BIG_RIGHT")
				StatusSelection.SEED_1:
					playback.travel("on_SEED_1")
					#status_menu.update_status_plants(SaveManager.get_seed_types()[0], Constants.seed_order[0])
					status_menu.update_status_plant_lighting(0)
					status_menu.handle_status_description(inspecting, 0)
				StatusSelection.SEED_2:
					playback.travel("on_SEED_2")
					#status_menu.update_status_plants(SaveManager.get_seed_types()[1], Constants.seed_order[1])
					status_menu.update_status_plant_lighting(1)
					status_menu.handle_status_description(inspecting, 1)
				StatusSelection.SEED_3:
					playback.travel("on_SEED_3")
					#status_menu.update_status_plants(SaveManager.get_seed_types()[2], Constants.seed_order[2])
					status_menu.update_status_plant_lighting(2)
					status_menu.handle_status_description(inspecting, 2)
				StatusSelection.SEED_4:
					playback.travel("on_SEED_4")
					#status_menu.update_status_plants(SaveManager.get_seed_types()[3], Constants.seed_order[3])
					status_menu.update_status_plant_lighting(3)
					status_menu.handle_status_description(inspecting, 3)
				StatusSelection.SEED_5:
					playback.travel("on_SEED_5")
					#status_menu.update_status_plants(SaveManager.get_seed_types()[4], Constants.seed_order[4])
					status_menu.update_status_plant_lighting(4)
					status_menu.handle_status_description(inspecting, 4)
				StatusSelection.SEED_6:
					playback.travel("on_SEED_6")
					#status_menu.update_status_plants(SaveManager.get_seed_types()[5], Constants.seed_order[5])
					status_menu.update_status_plant_lighting(5)
					status_menu.handle_status_description(inspecting, 5)
				StatusSelection.SEED_7:
					playback.travel("on_SEED_7")
					#status_menu.update_status_plants(SaveManager.get_seed_types()[6], Constants.seed_order[6])
					status_menu.update_status_plant_lighting(6)
					status_menu.handle_status_description(inspecting, 6)
				StatusSelection.HEART:
					playback.travel("on_HEART")
					status_menu.handle_status_description(inspecting, 0)
				StatusSelection.GROWTH_1:
					playback.travel("on_GROWTH_1")
					status_menu.handle_status_description(inspecting, 0)
				StatusSelection.GROWTH_2:
					playback.travel("on_GROWTH_2")
					status_menu.handle_status_description(inspecting, 0)
				StatusSelection.GROWTH_3:
					playback.travel("on_GROWTH_3")
					status_menu.handle_status_description(inspecting, 0)
		MenuSelection.CONTROLS:
			playback.travel("on_controls")
			status_buttons.hide()
			controls_buttons.show()
			config_buttons.hide()
			config_title_buttons.hide()
			map_buttons.hide()
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
			status_buttons.hide()
			controls_buttons.hide()
			config_buttons.show()
			map_buttons.hide()
			playback = config_menu.anim_tree["parameters/playback"]
			match current_menu_2:
				ConfigSelection.BIG_LEFT:
					playback.travel("on_BIG_LEFT")
					config_title_buttons.hide()
				ConfigSelection.BIG_RIGHT:
					playback.travel("on_BIG_RIGHT")
					config_title_buttons.hide()
				ConfigSelection.MASTER_HOVER:
					playback.travel("on_MASTER_HOVER")
					config_title_buttons.hide()
				ConfigSelection.MASTER_SLIDER:
					playback.travel("on_MASTER_SLIDER")
					config_title_buttons.hide()
				ConfigSelection.MUSIC_HOVER:
					playback.travel("on_MUSIC_HOVER")
					config_title_buttons.hide()
				ConfigSelection.MUSIC_SLIDER:
					playback.travel("on_MUSIC_SLIDER")
					config_title_buttons.hide()
				ConfigSelection.SOUND_HOVER:
					playback.travel("on_SOUND_HOVER")
					config_title_buttons.hide()
				ConfigSelection.SOUND_SLIDER:
					playback.travel("on_SOUND_SLIDER")
					config_title_buttons.hide()
				ConfigSelection.MOUSE_HOVER:
					playback.travel("on_MOUSE_HOVER")
					config_title_buttons.hide()
				ConfigSelection.MOUSE_SLIDER:
					playback.travel("on_MOUSE_SLIDER")
					config_title_buttons.hide()
				ConfigSelection.TO_TITLE_1:
					playback.travel("on_TO_TITLE_1")
					config_title_buttons.hide()
				ConfigSelection.TO_TITLE_2:
					playback.travel("on_TO_TITLE_2")
					config_title_buttons.show()
				ConfigSelection.TO_TITLE_3:
					playback.travel("on_TO_TITLE_3")
					config_title_buttons.show()
		MenuSelection.MAP:
			playback.travel("on_map")
			status_buttons.hide()
			controls_buttons.hide()
			config_buttons.hide()
			config_title_buttons.hide()
			map_buttons.show()
			playback = map_menu.anim_tree["parameters/playback"]
			#map_menu.match_map_buttons(find_current_floor() - 2)
			match current_menu_2:
				MapSelection.BIG_LEFT:
					playback.travel("on_BIG_LEFT")
				MapSelection.BIG_RIGHT:
					playback.travel("on_BIG_RIGHT")
				MapSelection.BUTTON_1:
					playback.travel("on_BUTTON_1")
				MapSelection.BUTTON_2:
					playback.travel("on_BUTTON_2")
				MapSelection.BUTTON_3:
					playback.travel("on_BUTTON_3")
				MapSelection.BUTTON_4:
					playback.travel("on_BUTTON_4")
				MapSelection.BUTTON_5:
					playback.travel("on_BUTTON_5")
				MapSelection.BUTTON_6:
					playback.travel("on_BUTTON_6")
				MapSelection.BUTTON_7:
					playback.travel("on_BUTTON_7")
				MapSelection.BUTTON_8:
					playback.travel("on_BUTTON_8")
				MapSelection.BUTTON_9:
					playback.travel("on_BUTTON_9")
	playback = select_anim_tree["parameters/playback"]
	if current_menu_2 == StatusSelection.BIG_LEFT or current_menu_2 == ControlsSelection.BIG_LEFT or current_menu_2 == ConfigSelection.BIG_LEFT or current_menu_2 == MapSelection.BIG_LEFT:
		playback.travel("select_big_left")
	elif current_menu_2 == StatusSelection.BIG_RIGHT or current_menu_2 == ControlsSelection.BIG_RIGHT or current_menu_2 == ConfigSelection.BIG_RIGHT or current_menu_2 == MapSelection.BIG_RIGHT:
		playback.travel("select_big_right")
	else:
		playback.travel("hide_selector")

func find_current_floor():
	var room_loader = main.room_loader
	if is_instance_valid(room_loader):
		return room_loader.get_floor() + 1
	else:
		return 2

func limit_map_selection(n: int):
	if n - 1 <= SaveManager.player_save.farthest_floor:
		SoundManager.play_menu_next()
	return min(n - 1, SaveManager.player_save.farthest_floor) + 1
	

func read_up():
	if remapping:
		return
	if suppress_next_input:
		return
	if !in_menu:
		return
	match current_menu:
		MenuSelection.STATUS:
			match current_menu_2:
				StatusSelection.BIG_LEFT:
					pass
				StatusSelection.BIG_RIGHT:
					pass
				StatusSelection.SEED_1:
					pass
				StatusSelection.SEED_2:
					pass
				StatusSelection.SEED_3:
					pass
				StatusSelection.SEED_4:
					pass
				StatusSelection.SEED_5:
					pass
				StatusSelection.SEED_6:
					pass
				StatusSelection.SEED_7:
					pass
				StatusSelection.HEART:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.SEED_1
					status_menu.update_status_plants(SaveManager.get_seed_types()[0], Constants.seed_order[0])
					SoundManager.play_menu_next()
				StatusSelection.GROWTH_1:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.SEED_5
					status_menu.update_status_plants(SaveManager.get_seed_types()[4], Constants.seed_order[4])
					SoundManager.play_menu_next()
				StatusSelection.GROWTH_2:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.GROWTH_1
					SoundManager.play_menu_next()
				StatusSelection.GROWTH_3:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.GROWTH_2
					SoundManager.play_menu_next()
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
					SoundManager.play_menu_next()
				ControlsSelection.MOVE_LEFT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_FORWARD
					SoundManager.play_menu_next()
				ControlsSelection.MOVE_RIGHT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_FORWARD
					SoundManager.play_menu_next()
				ControlsSelection.SPRINT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_LEFT
					SoundManager.play_menu_next()
				ControlsSelection.JUMP:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_RIGHT
					SoundManager.play_menu_next()
				ControlsSelection.PAUSE:
					pass
				ControlsSelection.RELOAD:
					pass
				ControlsSelection.INTERACT:
					pass
				ControlsSelection.SHOOT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.PUT_AWAY
					SoundManager.play_menu_next()
				ControlsSelection.PUT_AWAY:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.RELOAD
					SoundManager.play_menu_next()
		MenuSelection.CONFIG:
			match current_menu_2:
				ConfigSelection.BIG_LEFT:
					pass
				ConfigSelection.BIG_RIGHT:
					pass
				ConfigSelection.MASTER_HOVER:
					pass
				ConfigSelection.MASTER_SLIDER:
					pass
				ConfigSelection.MUSIC_HOVER:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.MASTER_HOVER
					SoundManager.play_menu_next()
				ConfigSelection.MUSIC_SLIDER:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.MASTER_HOVER
					SoundManager.play_menu_next()
				ConfigSelection.SOUND_HOVER:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.MUSIC_HOVER
					SoundManager.play_menu_next()
				ConfigSelection.SOUND_SLIDER:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.MUSIC_HOVER
					SoundManager.play_menu_next()
				ConfigSelection.MOUSE_HOVER:
					pass
				ConfigSelection.MOUSE_SLIDER:
					pass
				ConfigSelection.TO_TITLE_1:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.MOUSE_HOVER
					SoundManager.play_menu_next()
				ConfigSelection.TO_TITLE_2:
					pass
				ConfigSelection.TO_TITLE_3:
					pass
		MenuSelection.MAP:
			match current_menu_2:
				MapSelection.BIG_LEFT:
					pass
				MapSelection.BIG_RIGHT:
					pass
				MapSelection.BUTTON_1:
					pass
				MapSelection.BUTTON_2:
					current_menu_2 = limit_map_selection(MapSelection.BUTTON_1)
				MapSelection.BUTTON_3:
					current_menu_2 = limit_map_selection(MapSelection.BUTTON_2)
				MapSelection.BUTTON_4:
					current_menu_2 = limit_map_selection(MapSelection.BUTTON_3)
				MapSelection.BUTTON_5:
					current_menu_2 = limit_map_selection(MapSelection.BUTTON_4)
				MapSelection.BUTTON_6:
					current_menu_2 = limit_map_selection(MapSelection.BUTTON_5)
				MapSelection.BUTTON_7:
					current_menu_2 = limit_map_selection(MapSelection.BUTTON_6)
				MapSelection.BUTTON_8:
					current_menu_2 = limit_map_selection(MapSelection.BUTTON_7)
				MapSelection.BUTTON_9:
					current_menu_2 = limit_map_selection(MapSelection.BUTTON_8)
	update_visually()

func read_down():
	if remapping:
		return
	if suppress_next_input:
		return
	if !in_menu:
		return
	match current_menu:
		MenuSelection.STATUS:
			match current_menu_2:
				StatusSelection.BIG_LEFT:
					pass
				StatusSelection.BIG_RIGHT:
					pass
				StatusSelection.SEED_1:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.HEART
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_2:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.HEART
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_3:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.HEART
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_4:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.HEART
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_5:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.GROWTH_1
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_6:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.GROWTH_1
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_7:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.GROWTH_1
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.HEART:
					pass
				StatusSelection.GROWTH_1:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.GROWTH_2
					SoundManager.play_menu_next()
				StatusSelection.GROWTH_2:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.GROWTH_3
					SoundManager.play_menu_next()
				StatusSelection.GROWTH_3:
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
					SoundManager.play_menu_next()
				ControlsSelection.MOVE_BACK:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.SPRINT
					SoundManager.play_menu_next()
				ControlsSelection.MOVE_LEFT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_BACK
					SoundManager.play_menu_next()
				ControlsSelection.MOVE_RIGHT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_BACK
					SoundManager.play_menu_next()
				ControlsSelection.SPRINT:
					pass
				ControlsSelection.JUMP:
					pass
				ControlsSelection.PAUSE:
					pass
				ControlsSelection.RELOAD:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.PUT_AWAY
					SoundManager.play_menu_next()
				ControlsSelection.INTERACT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.PUT_AWAY
					SoundManager.play_menu_next()
				ControlsSelection.SHOOT:
					pass
				ControlsSelection.PUT_AWAY:
					pass
		MenuSelection.CONFIG:
			match current_menu_2:
				ConfigSelection.BIG_LEFT:
					pass
				ConfigSelection.BIG_RIGHT:
					pass
				ConfigSelection.MASTER_HOVER:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.MUSIC_HOVER
					SoundManager.play_menu_next()
				ConfigSelection.MASTER_SLIDER:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.MUSIC_HOVER
					SoundManager.play_menu_next()
				ConfigSelection.MUSIC_HOVER:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.SOUND_HOVER
					SoundManager.play_menu_next()
				ConfigSelection.MUSIC_SLIDER:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.SOUND_HOVER
					SoundManager.play_menu_next()
				ConfigSelection.SOUND_HOVER:
					pass
				ConfigSelection.SOUND_SLIDER:
					pass
				ConfigSelection.MOUSE_HOVER:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.TO_TITLE_1
					SoundManager.play_menu_next()
				ConfigSelection.MOUSE_SLIDER:
					pass
				ConfigSelection.TO_TITLE_1:
					pass
				ConfigSelection.TO_TITLE_2:
					pass
				ConfigSelection.TO_TITLE_3:
					pass
		MenuSelection.MAP:
			match current_menu_2:
				MapSelection.BIG_LEFT:
					pass
				MapSelection.BIG_RIGHT:
					pass
				MapSelection.BUTTON_1:
					current_menu_2 = limit_map_selection(MapSelection.BUTTON_2)
				MapSelection.BUTTON_2:
					current_menu_2 = limit_map_selection(MapSelection.BUTTON_3)
				MapSelection.BUTTON_3:
					current_menu_2 = limit_map_selection(MapSelection.BUTTON_4)
				MapSelection.BUTTON_4:
					current_menu_2 = limit_map_selection(MapSelection.BUTTON_5)
				MapSelection.BUTTON_5:
					current_menu_2 = limit_map_selection(MapSelection.BUTTON_6)
				MapSelection.BUTTON_6:
					current_menu_2 = limit_map_selection(MapSelection.BUTTON_7)
				MapSelection.BUTTON_7:
					current_menu_2 = limit_map_selection(MapSelection.BUTTON_8)
				MapSelection.BUTTON_8:
					current_menu_2 = limit_map_selection(MapSelection.BUTTON_9)
				MapSelection.BUTTON_9:
					pass
	update_visually()

func read_left():
	if remapping:
		return
	if suppress_next_input:
		return
	if !in_menu:
		return
	match current_menu:
		MenuSelection.STATUS:
			match current_menu_2:
				StatusSelection.BIG_LEFT:
					pass
				StatusSelection.BIG_RIGHT:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.SEED_7
					status_menu.update_status_plants(SaveManager.get_seed_types()[6], Constants.seed_order[6])
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_1:
					current_menu_2 = StatusSelection.BIG_LEFT
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_2:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.SEED_1
					status_menu.update_status_plants(SaveManager.get_seed_types()[0], Constants.seed_order[0])
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_3:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.SEED_2
					status_menu.update_status_plants(SaveManager.get_seed_types()[1], Constants.seed_order[1])
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_4:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.SEED_3
					status_menu.update_status_plants(SaveManager.get_seed_types()[2], Constants.seed_order[2])
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_5:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.SEED_4
					status_menu.update_status_plants(SaveManager.get_seed_types()[3], Constants.seed_order[3])
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_6:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.SEED_5
					status_menu.update_status_plants(SaveManager.get_seed_types()[4], Constants.seed_order[4])
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_7:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.SEED_6
					status_menu.update_status_plants(SaveManager.get_seed_types()[5], Constants.seed_order[5])
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.HEART:
					current_menu_2 = StatusSelection.BIG_LEFT
					SoundManager.play_menu_next()
				StatusSelection.GROWTH_1:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.HEART
					SoundManager.play_menu_next()
				StatusSelection.GROWTH_2:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.GROWTH_1
					SoundManager.play_menu_next()
				StatusSelection.GROWTH_3:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.GROWTH_2
					SoundManager.play_menu_next()
		MenuSelection.CONTROLS:
			match current_menu_2:
				ControlsSelection.BIG_LEFT:
					pass
				ControlsSelection.BIG_RIGHT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.INTERACT
					SoundManager.play_menu_next()
				ControlsSelection.MOVE_FORWARD:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_LEFT
					SoundManager.play_menu_next()
				ControlsSelection.MOVE_BACK:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_LEFT
					SoundManager.play_menu_next()
				ControlsSelection.MOVE_LEFT:
					current_menu_2 = ControlsSelection.BIG_LEFT
					SoundManager.play_menu_next()
				ControlsSelection.MOVE_RIGHT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_LEFT
					SoundManager.play_menu_next()
				ControlsSelection.SPRINT:
					current_menu_2 = ControlsSelection.BIG_LEFT
					SoundManager.play_menu_next()
				ControlsSelection.JUMP:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.SPRINT
					SoundManager.play_menu_next()
				ControlsSelection.PAUSE:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.JUMP
					SoundManager.play_menu_next()
				ControlsSelection.RELOAD:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_RIGHT
					SoundManager.play_menu_next()
				ControlsSelection.INTERACT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.RELOAD
					SoundManager.play_menu_next()
				ControlsSelection.SHOOT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.PAUSE
					SoundManager.play_menu_next()
				ControlsSelection.PUT_AWAY:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.SHOOT
					SoundManager.play_menu_next()
		MenuSelection.CONFIG:
			match current_menu_2:
				ConfigSelection.BIG_LEFT:
					pass
				ConfigSelection.BIG_RIGHT:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.MOUSE_HOVER
					SoundManager.play_menu_next()
				ConfigSelection.MASTER_HOVER:
					current_menu_2 = ConfigSelection.BIG_LEFT
					SoundManager.play_menu_next()
				ConfigSelection.MASTER_SLIDER:
					SaveManager.player_settings.increment_volume(0, -5)
					SoundManager.play_menu_tick()
				ConfigSelection.MUSIC_HOVER:
					current_menu_2 = ConfigSelection.BIG_LEFT
					SoundManager.play_menu_next()
				ConfigSelection.MUSIC_SLIDER:
					SaveManager.player_settings.increment_volume(1, -5)
					SoundManager.play_menu_tick()
				ConfigSelection.SOUND_HOVER:
					current_menu_2 = ConfigSelection.BIG_LEFT
					SoundManager.play_menu_next()
				ConfigSelection.SOUND_SLIDER:
					SaveManager.player_settings.increment_volume(2, -5)
					SoundManager.play_menu_tick()
				ConfigSelection.MOUSE_HOVER:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.MASTER_HOVER
					SoundManager.play_menu_next()
				ConfigSelection.MOUSE_SLIDER:
					SaveManager.player_settings.increment_sense(-0.05)
					SoundManager.play_menu_tick()
				ConfigSelection.TO_TITLE_1:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.MUSIC_HOVER
					SoundManager.play_menu_next()
				ConfigSelection.TO_TITLE_2:
					pass
				ConfigSelection.TO_TITLE_3:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.TO_TITLE_2
					SoundManager.play_menu_next()
		MenuSelection.MAP:
			match current_menu_2:
				MapSelection.BIG_LEFT:
					pass
				MapSelection.BIG_RIGHT:
					map_menu.selector.travel_shrunk_position()
					current_menu_2 = find_current_floor()
					SoundManager.play_menu_next()
				MapSelection.BUTTON_1:
					current_menu_2 = MapSelection.BIG_LEFT
					SoundManager.play_menu_next()
				MapSelection.BUTTON_2:
					current_menu_2 = MapSelection.BIG_LEFT
					SoundManager.play_menu_next()
				MapSelection.BUTTON_3:
					current_menu_2 = MapSelection.BIG_LEFT
					SoundManager.play_menu_next()
				MapSelection.BUTTON_4:
					current_menu_2 = MapSelection.BIG_LEFT
					SoundManager.play_menu_next()
				MapSelection.BUTTON_5:
					current_menu_2 = MapSelection.BIG_LEFT
					SoundManager.play_menu_next()
				MapSelection.BUTTON_6:
					current_menu_2 = MapSelection.BIG_LEFT
					SoundManager.play_menu_next()
				MapSelection.BUTTON_7:
					current_menu_2 = MapSelection.BIG_LEFT
					SoundManager.play_menu_next()
				MapSelection.BUTTON_8:
					current_menu_2 = MapSelection.BIG_LEFT
					SoundManager.play_menu_next()
				MapSelection.BUTTON_9:
					current_menu_2 = MapSelection.BIG_LEFT
					SoundManager.play_menu_next()
	update_visually()

func read_right():
	if remapping:
		return
	if suppress_next_input:
		return
	if !in_menu:
		return
	match current_menu:
		MenuSelection.STATUS:
			match current_menu_2:
				StatusSelection.BIG_LEFT:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.SEED_1
					status_menu.update_status_plants(SaveManager.get_seed_types()[0], Constants.seed_order[0])
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.BIG_RIGHT:
					pass
				StatusSelection.SEED_1:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.SEED_2
					status_menu.update_status_plants(SaveManager.get_seed_types()[1], Constants.seed_order[1])
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_2:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.SEED_3
					status_menu.update_status_plants(SaveManager.get_seed_types()[2], Constants.seed_order[2])
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_3:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.SEED_4
					status_menu.update_status_plants(SaveManager.get_seed_types()[3], Constants.seed_order[3])
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_4:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.SEED_5
					status_menu.update_status_plants(SaveManager.get_seed_types()[4], Constants.seed_order[4])
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_5:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.SEED_6
					status_menu.update_status_plants(SaveManager.get_seed_types()[5], Constants.seed_order[5])
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_6:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.SEED_7
					status_menu.update_status_plants(SaveManager.get_seed_types()[6], Constants.seed_order[6])
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.SEED_7:
					current_menu_2 = StatusSelection.BIG_RIGHT
					inspecting = false
					SoundManager.play_menu_next()
				StatusSelection.HEART:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.GROWTH_1
					SoundManager.play_menu_next()
				StatusSelection.GROWTH_1:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.GROWTH_2
					SoundManager.play_menu_next()
				StatusSelection.GROWTH_2:
					status_menu.selector.travel_shrunk_position()
					current_menu_2 = StatusSelection.GROWTH_3
					SoundManager.play_menu_next()
				StatusSelection.GROWTH_3:
					current_menu_2 = StatusSelection.BIG_RIGHT
					SoundManager.play_menu_next()
		MenuSelection.CONTROLS:
			match current_menu_2:
				ControlsSelection.BIG_LEFT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_LEFT
					SoundManager.play_menu_next()
				ControlsSelection.BIG_RIGHT:
					pass
				ControlsSelection.MOVE_FORWARD:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_RIGHT
					SoundManager.play_menu_next()
				ControlsSelection.MOVE_BACK:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_RIGHT
					SoundManager.play_menu_next()
				ControlsSelection.MOVE_LEFT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.MOVE_RIGHT
					SoundManager.play_menu_next()
				ControlsSelection.MOVE_RIGHT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.RELOAD
					SoundManager.play_menu_next()
				ControlsSelection.SPRINT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.JUMP
					SoundManager.play_menu_next()
				ControlsSelection.JUMP:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.PAUSE
					SoundManager.play_menu_next()
				ControlsSelection.PAUSE:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.SHOOT
					SoundManager.play_menu_next()
				ControlsSelection.RELOAD:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.INTERACT
					SoundManager.play_menu_next()
				ControlsSelection.INTERACT:
					current_menu_2 = ControlsSelection.BIG_RIGHT
					SoundManager.play_menu_next()
				ControlsSelection.SHOOT:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.PUT_AWAY
					SoundManager.play_menu_next()
				ControlsSelection.PUT_AWAY:
					controls_menu.selector.travel_shrunk_position()
					current_menu_2 = ControlsSelection.INTERACT
					SoundManager.play_menu_next()
		MenuSelection.CONFIG:
			match current_menu_2:
				ConfigSelection.BIG_LEFT:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.MASTER_HOVER
					SoundManager.play_menu_next()
				ConfigSelection.BIG_RIGHT:
					pass
				ConfigSelection.MASTER_HOVER:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.MOUSE_HOVER
					SoundManager.play_menu_next()
				ConfigSelection.MASTER_SLIDER:
					SaveManager.player_settings.increment_volume(0, 5)
					SoundManager.play_menu_tick()
				ConfigSelection.MUSIC_HOVER:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.TO_TITLE_1
					SoundManager.play_menu_next()
				ConfigSelection.MUSIC_SLIDER:
					SaveManager.player_settings.increment_volume(1, 5)
					SoundManager.play_menu_tick()
				ConfigSelection.SOUND_HOVER:
					pass
				ConfigSelection.SOUND_SLIDER:
					SaveManager.player_settings.increment_volume(2, 5)
					SoundManager.play_menu_tick()
				ConfigSelection.MOUSE_HOVER:
					current_menu_2 = ConfigSelection.BIG_RIGHT
					SoundManager.play_menu_next()
				ConfigSelection.MOUSE_SLIDER:
					SaveManager.player_settings.increment_sense(0.05)
					SoundManager.play_menu_tick()
				ConfigSelection.TO_TITLE_1:
					current_menu_2 = ConfigSelection.BIG_RIGHT
					SoundManager.play_menu_next()
				ConfigSelection.TO_TITLE_2:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.TO_TITLE_3
					SoundManager.play_menu_next()
				ConfigSelection.TO_TITLE_3:
					pass
		MenuSelection.MAP:
			match current_menu_2:
				MapSelection.BIG_LEFT:
					map_menu.selector.travel_shrunk_position()
					current_menu_2 = find_current_floor()
					SoundManager.play_menu_next()
				MapSelection.BIG_RIGHT:
					pass
				MapSelection.BUTTON_1:
					current_menu_2 = MapSelection.BIG_RIGHT
					SoundManager.play_menu_next()
				MapSelection.BUTTON_2:
					current_menu_2 = MapSelection.BIG_RIGHT
					SoundManager.play_menu_next()
				MapSelection.BUTTON_3:
					current_menu_2 = MapSelection.BIG_RIGHT
					SoundManager.play_menu_next()
				MapSelection.BUTTON_4:
					current_menu_2 = MapSelection.BIG_RIGHT
					SoundManager.play_menu_next()
				MapSelection.BUTTON_5:
					current_menu_2 = MapSelection.BIG_RIGHT
					SoundManager.play_menu_next()
				MapSelection.BUTTON_6:
					current_menu_2 = MapSelection.BIG_RIGHT
					SoundManager.play_menu_next()
				MapSelection.BUTTON_7:
					current_menu_2 = MapSelection.BIG_RIGHT
					SoundManager.play_menu_next()
				MapSelection.BUTTON_8:
					current_menu_2 = MapSelection.BIG_RIGHT
					SoundManager.play_menu_next()
				MapSelection.BUTTON_9:
					current_menu_2 = MapSelection.BIG_RIGHT
					SoundManager.play_menu_next()
	update_visually()

func read_accept():
	if remapping:
		return
	if suppress_next_input:
		return
	if !in_menu:
		return
	match current_menu:
		MenuSelection.STATUS:
			match current_menu_2:
				StatusSelection.BIG_LEFT:
					read_big_left()
					SoundManager.play_menu_accept()
				StatusSelection.BIG_RIGHT:
					read_big_right()
					SoundManager.play_menu_accept()
				StatusSelection.SEED_1:
					if !inspecting and SaveManager.player_save.seed_types[0]:
						inspecting = true
						SoundManager.play_seed_shot(2)
				StatusSelection.SEED_2:
					if !inspecting and SaveManager.player_save.seed_types[1]:
						inspecting = true
						SoundManager.play_seed_shot(4)
				StatusSelection.SEED_3:
					if !inspecting and SaveManager.player_save.seed_types[2]:
						inspecting = true
						SoundManager.play_seed_shot(3)
				StatusSelection.SEED_4:
					if !inspecting and SaveManager.player_save.seed_types[3]:
						inspecting = true
						SoundManager.play_seed_shot(6)
				StatusSelection.SEED_5:
					if !inspecting and SaveManager.player_save.seed_types[4]:
						inspecting = true
						SoundManager.play_seed_shot(5)
				StatusSelection.SEED_6:
					if !inspecting and SaveManager.player_save.seed_types[5]:
						inspecting = true
						SoundManager.play_seed_shot(7)
				StatusSelection.SEED_7:
					if !inspecting and SaveManager.player_save.seed_types[6]:
						inspecting = true
						SoundManager.play_seed_shot(8)
				StatusSelection.HEART:
					pass
				StatusSelection.GROWTH_1:
					pass
				StatusSelection.GROWTH_2:
					pass
				StatusSelection.GROWTH_3:
					pass
			update_visually()
		MenuSelection.CONTROLS:
			match current_menu_2:
				ControlsSelection.BIG_LEFT:
					read_big_left()
					SoundManager.play_menu_accept()
				ControlsSelection.BIG_RIGHT:
					read_big_right()
					SoundManager.play_menu_accept()
				ControlsSelection.MOVE_FORWARD:
					action_to_remap = "move_forward"
					await get_tree().process_frame
					remapping = true
					SoundManager.play_menu_accept()
				ControlsSelection.MOVE_BACK:
					action_to_remap = "move_back"
					await get_tree().process_frame
					remapping = true
					SoundManager.play_menu_accept()
				ControlsSelection.MOVE_LEFT:
					action_to_remap = "move_left"
					await get_tree().process_frame
					remapping = true
					SoundManager.play_menu_accept()
				ControlsSelection.MOVE_RIGHT:
					action_to_remap = "move_right"
					await get_tree().process_frame
					remapping = true
					SoundManager.play_menu_accept()
				ControlsSelection.SPRINT:
					action_to_remap = "sprint"
					await get_tree().process_frame
					remapping = true
					SoundManager.play_menu_accept()
				ControlsSelection.JUMP:
					action_to_remap = "jump"
					await get_tree().process_frame
					remapping = true
					SoundManager.play_menu_accept()
				ControlsSelection.PAUSE:
					action_to_remap = "pause"
					await get_tree().process_frame
					remapping = true
					SoundManager.play_menu_accept()
				ControlsSelection.RELOAD:
					action_to_remap = "reload"
					await get_tree().process_frame
					remapping = true
					SoundManager.play_menu_accept()
				ControlsSelection.INTERACT:
					action_to_remap = "interact"
					await get_tree().process_frame
					remapping = true
					SoundManager.play_menu_accept()
				ControlsSelection.SHOOT:
					action_to_remap = "shoot"
					await get_tree().process_frame
					remapping = true
					SoundManager.play_menu_accept()
				ControlsSelection.PUT_AWAY:
					action_to_remap = "close_reload"
					await get_tree().process_frame
					remapping = true
					SoundManager.play_menu_accept()
			controls_menu.hide_controls_text(action_to_remap)
			update_visually()
		MenuSelection.CONFIG:
			match current_menu_2:
				ConfigSelection.BIG_LEFT:
					read_big_left()
					update_visually()
					SoundManager.play_menu_accept()
				ConfigSelection.BIG_RIGHT:
					read_big_right()
					update_visually()
					SoundManager.play_menu_accept()
				ConfigSelection.MASTER_HOVER:
					current_menu_2 = ConfigSelection.MASTER_SLIDER
					update_visually()
					SoundManager.play_menu_accept()
				ConfigSelection.MASTER_SLIDER:
					current_menu_2 = ConfigSelection.MASTER_HOVER
					update_visually()
					SoundManager.play_menu_accept()
				ConfigSelection.MUSIC_HOVER:
					current_menu_2 = ConfigSelection.MUSIC_SLIDER
					update_visually()
					SoundManager.play_menu_accept()
				ConfigSelection.MUSIC_SLIDER:
					current_menu_2 = ConfigSelection.MUSIC_HOVER
					update_visually()
					SoundManager.play_menu_accept()
				ConfigSelection.SOUND_HOVER:
					current_menu_2 = ConfigSelection.SOUND_SLIDER
					update_visually()
					SoundManager.play_menu_accept()
				ConfigSelection.SOUND_SLIDER:
					current_menu_2 = ConfigSelection.SOUND_HOVER
					update_visually()
					SoundManager.play_menu_accept()
				ConfigSelection.MOUSE_HOVER:
					current_menu_2 = ConfigSelection.MOUSE_SLIDER
					update_visually()
					SoundManager.play_menu_accept()
				ConfigSelection.MOUSE_SLIDER:
					current_menu_2 = ConfigSelection.MOUSE_HOVER
					update_visually()
					SoundManager.play_menu_accept()
				ConfigSelection.TO_TITLE_1:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.TO_TITLE_2
					update_visually()
					SoundManager.play_menu_accept()
				ConfigSelection.TO_TITLE_2:
					config_menu.selector.travel_shrunk_position()
					current_menu_2 = ConfigSelection.TO_TITLE_1
					update_visually()
					SoundManager.play_menu_accept()
				ConfigSelection.TO_TITLE_3:
					main.active.load_main_menu()
					close_pause_menu()
					SoundManager.play_menu_accept()
		MenuSelection.MAP:
			match current_menu_2:
				MapSelection.BIG_LEFT:
					read_big_left()
					SoundManager.play_menu_accept()
				MapSelection.BIG_RIGHT:
					read_big_right()
					SoundManager.play_menu_accept()
				MapSelection.BUTTON_1:
					map_menu.match_map_frame(0)
					SoundManager.play_menu_accept()
				MapSelection.BUTTON_2:
					map_menu.match_map_frame(1)
					SoundManager.play_menu_accept()
				MapSelection.BUTTON_3:
					map_menu.match_map_frame(2)
					SoundManager.play_menu_accept()
				MapSelection.BUTTON_4:
					map_menu.match_map_frame(3)
					SoundManager.play_menu_accept()
				MapSelection.BUTTON_5:
					map_menu.match_map_frame(4)
					SoundManager.play_menu_accept()
				MapSelection.BUTTON_6:
					map_menu.match_map_frame(5)
					SoundManager.play_menu_accept()
				MapSelection.BUTTON_7:
					map_menu.match_map_frame(6)
					SoundManager.play_menu_accept()
				MapSelection.BUTTON_8:
					map_menu.match_map_frame(7)
					SoundManager.play_menu_accept()
				MapSelection.BUTTON_9:
					map_menu.match_map_frame(8)
					SoundManager.play_menu_accept()
			update_visually()

func read_back():
	if suppress_next_input:
		return
	if !in_menu:
		return
	match current_menu:
		MenuSelection.STATUS:
			if inspecting:
				inspecting = false
				update_visually()
		MenuSelection.CONTROLS:
			pass
		MenuSelection.CONFIG:
			match current_menu_2:
				ConfigSelection.MASTER_SLIDER:
					current_menu_2 = ConfigSelection.MASTER_HOVER
					update_visually()
				ConfigSelection.MUSIC_SLIDER:
					current_menu_2 = ConfigSelection.MUSIC_HOVER
					update_visually()
				ConfigSelection.SOUND_SLIDER:
					current_menu_2 = ConfigSelection.SOUND_HOVER
					update_visually()
				ConfigSelection.MOUSE_SLIDER:
					current_menu_2 = ConfigSelection.MOUSE_HOVER
					update_visually()
		MenuSelection.MAP:
			pass

func read_big_left():
	if remapping:
		return
	if suppress_next_input:
		return
	if !in_menu:
		return
	SoundManager.play_menu_tick()
	match current_menu:
		MenuSelection.STATUS:
			current_menu = MenuSelection.MAP
			current_menu_2 = MapSelection.BIG_LEFT
		MenuSelection.CONTROLS:
			current_menu = MenuSelection.STATUS
			current_menu_2 = StatusSelection.BIG_LEFT
		MenuSelection.CONFIG:
			current_menu = MenuSelection.CONTROLS
			current_menu_2 = ControlsSelection.BIG_LEFT
		MenuSelection.MAP:
			current_menu = MenuSelection.CONFIG
			current_menu_2 = ConfigSelection.BIG_LEFT
	update_visually()
func read_big_right():
	if remapping:
		return
	if suppress_next_input:
		return
	if !in_menu:
		return
	SoundManager.play_menu_tick()
	match current_menu:
		MenuSelection.STATUS:
			current_menu = MenuSelection.CONTROLS
			current_menu_2 = ControlsSelection.BIG_RIGHT
		MenuSelection.CONTROLS:
			current_menu = MenuSelection.CONFIG
			current_menu_2 = ConfigSelection.BIG_RIGHT
		MenuSelection.CONFIG:
			current_menu = MenuSelection.MAP
			current_menu_2 = MapSelection.BIG_RIGHT
		MenuSelection.MAP:
			current_menu = MenuSelection.STATUS
			current_menu_2 = StatusSelection.BIG_RIGHT
	update_visually()

func initialize_map_frame():
	map_menu.match_map_frame(find_current_floor() - 2)

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
			controls_menu.hide_controls_text(action_to_remap)
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
			controls_menu.hide_controls_text(action_to_remap)
			update_visually()
