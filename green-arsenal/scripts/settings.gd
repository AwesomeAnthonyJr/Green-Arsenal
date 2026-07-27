extends Resource
class_name Settings

@export var master_vol: int = 100
@export var music_vol: int = 100
@export var sound_vol: int = 100
@export var mouse_sense: float = 1.0
@export var action_dict = {
	"move_forward": InputMap.action_get_events("move_forward")[0],
	"move_back": InputMap.action_get_events("move_back")[0],
	"move_left": InputMap.action_get_events("move_left")[0],
	"move_right": InputMap.action_get_events("move_right")[0],
	"sprint": InputMap.action_get_events("sprint")[0],
	"jump": InputMap.action_get_events("jump")[0],
	"pause": InputMap.action_get_events("pause")[0],
	"shoot": InputMap.action_get_events("shoot")[0],
	"reload": InputMap.action_get_events("reload")[0],
	"interact": InputMap.action_get_events("interact")[0],
	"close_reload": InputMap.action_get_events("close_reload")[0],
}
signal input_changed

func get_sense_text():
	return "%0*.*f" % [4, 2, mouse_sense]

func get_mono_audio_text(i: int):
	var num_result = 0
	match i:
		0:
			num_result = master_vol
		1:
			num_result = music_vol
		2:
			num_result = sound_vol
	num_result = str(num_result)
	match num_result.length():
		1:
			num_result = "  " + num_result
		2:
			num_result = " " + num_result
	return num_result

func increment_sense(n: float):
	mouse_sense += n
	
	mouse_sense = max(0.05, mouse_sense)
	mouse_sense = min(5.0, mouse_sense)

func increment_volume(i: int, n: int):
	match i:
		0:
			master_vol += n
		1:
			music_vol += n
		2:
			sound_vol += n
	
	master_vol = max(0, master_vol)
	master_vol = min(100, master_vol)
	music_vol = max(0, music_vol)
	music_vol = min(100, music_vol)
	sound_vol = max(0, sound_vol)
	sound_vol = min(100, sound_vol)
	update_audio_bus()

func load_action_dict():
	for a in action_dict:
		InputMap.action_erase_events(a)
		InputMap.action_add_event(a, action_dict[a])
		#print(InputMap)

func cleanString(input):
	var str = str(input)
	#print(str)
	str = str.to_lower()
	if str == "escape":
		str = "esc"
	if str == "escape (physical)":
		str = "esc"
	if str == "windows":
		str = "win"
	if str == "left mouse button":
		str = "lmb"
	if str == "left mouse button (double click)":
		str = "lmb"
	if str == "right mouse button":
		str = "rmb"
	if str == "right mouse button (double click)":
		str = "rmb"
	if str == "middle mouse button":
		str = "mmb"
	if str.find(" ") != -1:
		str = str.erase(str.find(" "),str.length()-1)
	#print(str)
	return str

func update_audio_bus():
	AudioServer.set_bus_volume_db(0, linear_to_db(master_vol/100.0))
	AudioServer.set_bus_volume_db(1, linear_to_db(music_vol/100.0))
	AudioServer.set_bus_volume_db(2, linear_to_db(sound_vol/100.0))

func find_duplicate_actions(n: String, event):
	print(n, ", " ,event)
	print("------------")
	var e_text = cleanString(event.as_text())
	for a in action_dict:
		if a != n:
			if cleanString(action_dict[a].as_text()) == e_text:
				print("DUPLICATE ON ", a)
				return a
	return n

func rebindAction(n: String, event):
	action_dict[n] = event
	InputMap.action_erase_events(n)
	InputMap.action_add_event(n, event)
	input_changed.emit()

func get_text(code):
	match code:
		"move_forward":
			return cleanString(action_dict.get("move_forward").as_text())
		"move_back":
			return cleanString(action_dict.get("move_back").as_text())
		"move_left":
			return cleanString(action_dict.get("move_left").as_text())
		"move_right":
			return cleanString(action_dict.get("move_right").as_text())
		"sprint":
			return cleanString(action_dict.get("sprint").as_text())
		"jump":
			return cleanString(action_dict.get("jump").as_text())
		"pause":
			return cleanString(action_dict.get("pause").as_text())
		"shoot":
			return cleanString(action_dict.get("shoot").as_text())
		"reload":
			return cleanString(action_dict.get("reload").as_text())
		"interact":
			return cleanString(action_dict.get("interact").as_text())
		"close_reload":
			return cleanString(action_dict.get("close_reload").as_text())
