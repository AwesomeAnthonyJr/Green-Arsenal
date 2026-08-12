extends Node3D
class_name RoomLoader

#will not be export in final game!
var active_room: Room
var active_key = 4
@export var player: Node3D
var main: Main

#@export var positions = PackedVector3Array()
@export var test_position = Vector3()

@onready var song_player = $AudioStreamPlayer
@onready var song_anim = $AnimationPlayer

#for the load points
const positions = [
	Vector3(10.0, 1.2, 5.0),
	Vector3(20.0, 1.55, -6.0),
	Vector3(64.0, 1.8, -27.0),
	Vector3(-100.0, 1.8, -52.0),
	Vector3(-86.0, -6.5, -219.0),
	Vector3(-18.0, -6.5 , -293),
	Vector3(19.0, -75.0, -296.0),
]

#this tells it which room to start in basically; -1 for testing!
const load_point_keys = {
	-1: 20,
	0: 4,
	1: 4,
	2: 8,
	3: 10,
	4: 12,
	5: 17,
	6: 21,
}

const room_dict = {
	0: "res://scenes/rooms/room_a.tscn",
	1: "res://scenes/rooms/room_b.tscn",
	2: "res://scenes/rooms/room_c.tscn",
	
	4: "res://scenes/rooms/forest/forest_1_NEW.tscn",
	5: "res://scenes/rooms/forest/forest_2.tscn",
	6: "res://scenes/rooms/forest/forest_3_NEWER.tscn",
	7: "res://scenes/rooms/forest/forest_4_NEWER.tscn",
	8: "res://scenes/rooms/forest/forest_6.tscn",
	9: "res://scenes/rooms/forest/forest_5_NEWER.tscn",
	-10: "res://scenes/rooms/forest/easter_egg_room.tscn",
	10: "res://scenes/rooms/forest/life_seed.tscn",
	11: "res://scenes/rooms/forest/underground_entrance.tscn",
	
	12: "res://scenes/rooms/underground/underground_1.tscn",
	13: "res://scenes/rooms/underground/underground_2.tscn",
	14: "res://scenes/rooms/underground/bounce_seed.tscn",
	15: "res://scenes/rooms/underground/combo_puzzle_1.tscn",
	16: "res://scenes/rooms/underground/underground_3.tscn",
	17: "res://scenes/rooms/underground/underground_4.tscn",
	18: "res://scenes/rooms/underground/underground_5.tscn",
	19: "res://scenes/rooms/underground/flooded_entrance.tscn",
	
	20: "res://scenes/rooms/flooded/flooded_1.tscn",
	21: "res://scenes/rooms/flooded/flooded_2.tscn",
	22: "res://scenes/rooms/flooded/flooded_3.tscn",
	23: "res://scenes/rooms/flooded/flooded_4.tscn",
	24: "res://scenes/rooms/flooded/flooded_5.tscn",
	25: "res://scenes/rooms/flooded/flooded_6.tscn",
	26: "res://scenes/rooms/flooded/flooded_7.tscn",
	27: "res://scenes/rooms/flooded/flooded_8.tscn",
	28: "res://scenes/rooms/flooded/flooded_9.tscn",
	29: "res://scenes/rooms/flooded/grand_elevator.tscn",
	30: "res://scenes/rooms/farm/farm_1.tscn",
	
	99: "res://scenes/rooms/underground/ending_for_sprint3.tscn",
}
#must be the inverse of the first!!!
const reverse_dict = {
	"res://scenes/rooms/room_a.tscn": 0,
	"res://scenes/rooms/room_b.tscn": 1,
	"res://scenes/rooms/room_c.tscn": 2,
	
	"res://scenes/rooms/forest/forest_1_NEW.tscn" : 4,
	"res://scenes/rooms/forest/forest_2.tscn" : 5,
	"res://scenes/rooms/forest/forest_3_NEWER.tscn" : 6,
	"res://scenes/rooms/forest/forest_4_NEWER.tscn" : 7,
	"res://scenes/rooms/forest/forest_6.tscn" : 8,
	"res://scenes/rooms/forest/forest_5_NEWER.tscn" : 9,
	"res://scenes/rooms/forest/easter_egg_room.tscn" : -10,
	"res://scenes/rooms/forest/life_seed.tscn" : 10,
	"res://scenes/rooms/forest/underground_entrance.tscn" : 11,
	
	"res://scenes/rooms/underground/underground_1.tscn": 12,
	"res://scenes/rooms/underground/underground_2.tscn": 13,
	"res://scenes/rooms/underground/bounce_seed.tscn": 14,
	"res://scenes/rooms/underground/combo_puzzle_1.tscn": 15,
	"res://scenes/rooms/underground/underground_3.tscn": 16,
	"res://scenes/rooms/underground/underground_4.tscn": 17,
	"res://scenes/rooms/underground/underground_5.tscn": 18,
	"res://scenes/rooms/underground/flooded_entrance.tscn": 19,
	
	"res://scenes/rooms/flooded/flooded_1.tscn": 20,
	"res://scenes/rooms/flooded/flooded_2.tscn": 21,
	"res://scenes/rooms/flooded/flooded_3.tscn": 22,
	"res://scenes/rooms/flooded/flooded_4.tscn": 23,
	"res://scenes/rooms/flooded/flooded_5.tscn": 24,
	"res://scenes/rooms/flooded/flooded_6.tscn": 25,
	"res://scenes/rooms/flooded/flooded_7.tscn": 26,
	"res://scenes/rooms/flooded/flooded_8.tscn": 27,
	"res://scenes/rooms/flooded/flooded_9.tscn": 28,
	"res://scenes/rooms/flooded/grand_elevator.tscn": 29,
	"res://scenes/rooms/farm/farm_1.tscn": 30,
	
	"res://scenes/rooms/underground/ending_for_sprint3.tscn": 99,
}

#this is for secondary things - to load in stages if certain rooms are too large
const room_dict_2 = {
}

var loadings = []
var loaded_objects_keys = []
var loaded_objects = []
var extra_loadings = {}

func get_floor():
	#forest
	if active_key > -1 and active_key < 12:
		return 1
	#underground
	elif active_key > 11 and active_key < 21:
		return 2
	#flooded
	elif active_key > 20 and active_key < 30:
		return 3
	#farm
	elif active_key > 29 and active_key < 999:
		return 4
	
	#special
	if active_key == -10:
		return 1
	return 0

func initialize():
	var lp = SaveManager.player_save.load_point
	active_key = load_point_keys[lp]
	var inst = Preloads.player_package.instantiate()
	add_child(inst)
	player = inst
	position_player(lp)
	setup_active_room(active_key)

func position_player(i: int):
	if i >= 0:
		player.global_position = positions[i]
	else:
		#print("USE TEST POS!")
		#print(test_position)
		player.global_position = test_position

func _ready() -> void:
	main = Generics.find_main(self)
	pass

func _process(delta):
	if main.not_gameplay:
		return 
	for path in loadings:
		var status = ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var already_loaded = false
			var key = reverse_dict[path]
			if key in loaded_objects_keys:
				already_loaded = true
				print("BUT IT ALREADY WAS LOADED!")
			if !already_loaded:
				var resource = ResourceLoader.load_threaded_get(path)
				var is_extra = extra_loadings.has(path)
				load_resource(resource, path, is_extra)
			extra_loadings.erase(path)
			loadings.erase(path)
	var erase_arr = []
	if is_instance_valid(active_room):
		for i in loaded_objects_keys.size():
			var k = loaded_objects_keys[i]
			var o = loaded_objects[i]
			if is_instance_valid(o):
				if !(k in active_room.adjacent_rooms and k > 0) and !(k == active_key):
					print("ROOM: ", k, " IS BEING REMOVED!!!")
					#print(active_key)
					o.queue_free()
					erase_arr.append(i)
			else:
				erase_arr.append(i)
	else:
		print("yo why is active room null?")
	if erase_arr.size() > 0:
		var i = erase_arr[0]
		if i < loaded_objects_keys.size():
			loaded_objects_keys.remove_at(i)
		if i < loaded_objects.size():
			loaded_objects.remove_at(i)
			#print("ERASED OBJECT ", i, " FROM ARRAYS.")
			#var k = loaded_objects_keys[i]
			#var o = loaded_objects[i]

func load_resource(resource: PackedScene, path: String, extra: bool):
	var inst = resource.instantiate()
	if !extra:
		add_child(inst)
		inst.global_position = inst.room_pos
	else:
		#print("EXTRA EXTRA")
		var key = extra_loadings[path]
		for i in loaded_objects_keys.size():
			#print(i, ", ", loaded_objects_keys[i], ", ", key)
			if loaded_objects_keys[i] == key:
				loaded_objects[i].add_child(inst)
				break
	if !extra:
		loaded_objects.append(inst)
		var key = reverse_dict[path]
		loaded_objects_keys.append(key)
		load_room_extra(key)

func load_room(key: int):
	var path = room_dict[key]
	ResourceLoader.load_threaded_request(path, "PackedScene")
	loadings.append(path)
	print("ROOM: ", key, " IS LOADED!")

func load_room_extra(key: int):
	if room_dict_2.has(key):
		var path = room_dict_2[key]
		ResourceLoader.load_threaded_request(path, "PackedScene")
		extra_loadings[path] = key
		loadings.append(path)
		print("EXTRAS FOR: ", key, " IS LOADED!")
		print(extra_loadings)

func setup_active_room(key: int):
	#some stuff will need to go here
	if is_instance_valid(active_room):
		active_room.active = false
	print("ON ROOM: ", key)
	var already_loaded = false
	for i in loaded_objects_keys.size():
		var k = loaded_objects_keys[i]
		var o = loaded_objects[i]
		if k == key:
			active_room = o
			active_key = k
			already_loaded = true
			song_check(key)
			break
	if !already_loaded:
		var path = room_dict[key]
		var resource = load(path)
		var inst = resource.instantiate()
		add_child(inst)
		inst.global_position = inst.room_pos
		loaded_objects.append(inst)
		loaded_objects_keys.append(key)
		active_room = inst
		active_key = key
		load_room_extra(key)
		song_check(key, false)
		print("RARE FIRST TIME LOAD HAS OCCURED! ", key)
	
	#its a different room now
	active_room.active = true
	
	for k in active_room.adjacent_rooms:
		if !(k in loaded_objects_keys) and k > 0:
			load_room(k)
		else:
			print("ROOM: ", k, " IS ALREADY LOADED!")

func song_change(new, smooth: bool = true):
	if new != song_player.stream:
		if smooth:
			song_anim.play("fade_vol_out")
			await get_tree().create_timer(1.0).timeout
		song_player.stream = new
		song_player.play()
		if smooth:
			song_anim.play("fade_vol_in")

func song_check(key: int, smooth: bool = true):
	match key:
		4, 8, 10, 11, 9:
			song_change(Preloads.gameplay_music_01, smooth)
		12, 17, 19:
			song_change(Preloads.gameplay_music_02, smooth)
		20, 21, 28:
			song_change(Preloads.gameplay_music_03, smooth)
		29:
			song_change(Preloads.silence, smooth)
		30:
			song_change(Preloads.gameplay_music_01, smooth)
		-10:
			song_change(Preloads.easter_egg_music, false)
