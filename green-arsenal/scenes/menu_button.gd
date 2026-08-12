extends Button

@export var current_menu: int
@export var current_menu_2: int
var pause_menu: PauseMenu

func _ready() -> void:
	pause_menu = Generics.find_pause_menu(self)

func _on_pressed() -> void:
	if !pause_menu.remapping:
		pause_menu.current_menu = current_menu
		pause_menu.current_menu_2 = current_menu_2
		pause_menu.read_accept()


func _on_mouse_entered() -> void:
	if current_menu == 3:
		if SaveManager.player_save.farthest_floor + 1 < current_menu_2:
			hide()
			return
		else:
			show()
	if !pause_menu.remapping:
		pause_menu.current_menu = current_menu
		pause_menu.current_menu_2 = current_menu_2
		if current_menu == 0:
			pause_menu.inspecting = false
			match current_menu_2:
				2:
					pause_menu.status_menu.update_status_plants(SaveManager.get_seed_types()[0], Constants.seed_order[0])
				3:
					pause_menu.status_menu.update_status_plants(SaveManager.get_seed_types()[1], Constants.seed_order[1])
				4:
					pause_menu.status_menu.update_status_plants(SaveManager.get_seed_types()[2], Constants.seed_order[2])
				5:
					pause_menu.status_menu.update_status_plants(SaveManager.get_seed_types()[3], Constants.seed_order[3])
				6:
					pause_menu.status_menu.update_status_plants(SaveManager.get_seed_types()[4], Constants.seed_order[4])
				7:
					pause_menu.status_menu.update_status_plants(SaveManager.get_seed_types()[5], Constants.seed_order[5])
				8:
					pause_menu.status_menu.update_status_plants(SaveManager.get_seed_types()[6], Constants.seed_order[6])
		SoundManager.play_menu_next()
		pause_menu.update_visually()
