extends Node
var save_file_path = "user://saves/"
var save_file_name = "GreenArsenal_save.tres"
var save_settings_name = "GreenArsenal_settings.tres"
var player_save = SaveFile.new()
var player_settings = Settings.new()

signal save_read
signal input_changed

func _ready() -> void:
	verify_directories()
	read_save()
	read_settings()
	#reset_save()

func set_load_point(i: int):
	player_save.load_point = i

func broadcast_input_changed():
	input_changed.emit()

func reset_save():
	player_save = SaveFile.new()
	player_settings = Settings.new()
	player_settings.input_changed.connect(broadcast_input_changed)
	write_save()
	write_settings()

func get_seed_types():
	return player_save.seed_types

func update_flag(index: int, value: bool):
	player_save.game_flags[index] = value

func verify_dir(path: String):
	DirAccess.make_dir_absolute(path)

func verify_directories():
	verify_dir(save_file_path)
	#leaving this seperate in case we need other stuff later

func read_save():
	print("WE ARE READING A SAVE!!!")
	print_stack()
	player_save = SaveFile.new()
	if (ResourceLoader.exists(save_file_path + save_file_name)):
		player_save = ResourceLoader.load(save_file_path + save_file_name)
	save_read.emit()

func write_save():
	ResourceSaver.save(player_save, save_file_path + save_file_name)

func test_save():
	player_save = SaveFile.new()
	###this is where you put anything you want to change for testing!
	player_save.load_point = -1
	player_save.seed_types[0] = true
	player_save.seed_types[1] = true
	player_save.seed_types[2] = true
	player_save.seed_types[3] = true
	player_save.seed_types[4] = true
	player_save.max_hp = 4
	player_save.growth_charges = 2
	save_read.emit()

func read_settings():
	player_settings = Settings.new()
	if (ResourceLoader.exists(save_file_path + save_settings_name)):
		player_settings = ResourceLoader.load(save_file_path + save_settings_name)
	player_settings.input_changed.connect(broadcast_input_changed)

func write_settings():
	ResourceSaver.save(player_settings, save_file_path + save_settings_name)
