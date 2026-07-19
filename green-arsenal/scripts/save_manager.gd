extends Node
var save_file_path = "user://saves/"
var save_file_name = "GreenArsenal_save.tres"
var save_settings_name = "GreenArsenal_settings.tres"
var player_save = SaveFile.new()
var player_settings = Settings.new()

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
	player_save = SaveFile.new()
	if (ResourceLoader.exists(save_file_path + save_file_name)):
		player_save = ResourceLoader.load(save_file_path + save_file_name)

func write_save():
	ResourceSaver.save(player_save, save_file_path + save_file_name)

func read_settings():
	player_settings = Settings.new()
	if (ResourceLoader.exists(save_file_path + save_settings_name)):
		player_settings = ResourceLoader.load(save_file_path + save_settings_name)

func write_settings():
	ResourceSaver.save(player_settings, save_file_path + save_settings_name)
