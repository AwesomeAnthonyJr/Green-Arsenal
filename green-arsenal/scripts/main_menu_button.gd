extends Button

@export var menu_position: int
@export var main_menu: MainMenu

func _on_pressed() -> void:
	main_menu.menu_position = menu_position
	main_menu.read_accept()


func _on_mouse_entered() -> void:
	main_menu.menu_position = menu_position
	SoundManager.play_menu_next()
	main_menu.update_visuals()
